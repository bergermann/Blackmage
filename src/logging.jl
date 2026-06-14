


function extend_write_to(dset::HDF5.Dataset,data::AbstractArray,extension::Tuple,
        inds::Union{Colon,Integer}...)

    dims = HDF5.get_extent_dims(dset)

    @assert length(dims) == length(extension) == length(inds) "Dimension mismatch for
        dataset or extension size."

    if all(@. ifelse(inds isa Integer,inds,0) <= dims[1])
        dset[inds...] = data
    else
        @assert all(@. sign(dims[2])*(dims[1]+extension) <= dims[2]) "Maximum dataset
            size is exceeded."

        if all(@. ifelse(inds isa Integer,inds,0) <= dims[1]+extension)
            HDF5.set_extent_dims(ds,dims[1].+extension)
            dset[inds...] = data
        else
            throw(HDF5.API.H5Error("Error extending dataset. Indices are out of extension
                bounds."))
        end
    end

    return
end

function extend_write_to(dset::HDF5.Dataset,data::AbstractArray,extension::Tuple,
        inds::Union{Colon,AbstractRange{<:Integer}}...)

    dims = HDF5.get_extent_dims(dset)

    @assert length(dims) == length(extension) == length(inds) "Dimension mismatch for
        dataset or extension size."

    if all([(inds[i] isa Colon ? 0 : maximum(inds[i])) <= dims[1][i]
            for i in eachindex(inds)])

        dset[inds...] = data
    else
        @assert all(@. sign(dims[2])*(dims[1]+extension) <= dims[2]) "Maximum dataset
            size is exceeded."

        if all([(inds[i] isa Colon ? 0 : maximum(inds[i])) <= dims[1][i]+extension[i]
                for i in eachindex(inds)])

            HDF5.set_extent_dims(ds,dims[1].+extension)
            dset[inds...] = data
        else
            throw(HDF5.API.H5Error("Error extending dataset. Indices are out of
                extension bounds."))
        end
    end

    return
end



function log_file(md::MultiDevice,filepath::String; timeout::Int=0,
        interval::Real=0.1,nreset::Int=5,treset::Real=1)

    ndisk = length(md.devices)
    
    if isfile(filepath)
        println("File already exists. Extend or replace? (e/r)")
        mode = lowercase(readline())

        if mode == e
            file = h5open(filepath,"r+")

            @assert haskey(file,"t0") ""
            @assert haskey(file,"t") ""
            @assert haskey(file,"pos") ""
        elseif mode == r
            println("Confirm replacing file $filepath. (type confirm)")
            confirm = lowercase(readline())

            if confirm != "confirm"
                @warn "Replace confirmation failed. Aborting logging."; return
            end

            rm(filepath); file = h5open(filepath,"cw")

            create_dataset(file,"t0",Int)
            create_dataset(file,"t",Int,dataspace((1000,),(-1,)))
            create_dataset(file,"data",Int,dataspace((1+3ndisk,1000),(1+3ndisk,-1));
                chunk=(1+3*ndisk,1000))
        else
            @warn "Mode not supported. Aborting logging."; return
        end
    else
        file = h5open(filepath,"cw")
        
        create_dataset(file,"t0",Int)
        create_dataset(file,"t",Int,dataspace((1000,),(-1,)))
        create_dataset(file,"data",Int,dataspace((1+3ndisk,1000),(1+3ndisk,-1));
            chunk=(1+3*ndisk,1000))
    end

    return file
end



"""
    record_!(d::Displacement,device::TCPSocket,req::Dict,tmax::Real;
        interval::Real=0.1,nreset::Int=5,treset::Real=1)

Periodically write IDS readout to container `d` for a maximum of `tmax` seconds, every
`interval` seconds. Attempt to clear persisting error a maximum of `nreset` times, wait
`treset` seconds between each try.
"""
function record_!(d::Displacement,device::TCPSocket,req::Dict,tmax::Real;
        interval::Real=0.1,nreset::Int=5,treset::Real=1)

    t0 = now()
    t  = Millisecond(0)
    t_ = Millisecond(0)

    tmax     = Millisecond(round(Int,    tmax*1000))
    interval = Millisecond(round(Int,interval*1000))

    nreset_ = 0
    
    while t < tmax && d.active
        try 
            t = now()-t0

            if t >= t_
                t_ += interval

                d.idx = d.idx%d.n+1

                d.dX[:,d.idx] .= getAxesDisplacement(device,req)
                d.dC[:,d.idx] .= getAxesSignalQuality(device,req; threshold=900)
                d.dT[d.idx] = (now()-d.t0).value

                if nreset_ > 0
                    @info "Successfully reset. Continuing recording."
                    nreset_ = 0
                end
            end
        catch err
            if nreset_ >= nreset
                d.active = false

                @info "Error could not reset. Stopping recording."

                Base.throwto(current_task(),err)
            else
                @info "Recording interrupted due to error. Attempting to reset."

                sleep(treset)

                resetError(device,req)

                nreset_ += 1
            end
        end
    end

    d.active = false

    @info "Recording finished."

    return
end

"""
    record!(d::Displacement,device::TCPSocket,tmax::Int;
        interval::Float64=0.1,nreset::Int=5,treset::Real=1)

Periodically write IDS readout to container `d` for a maximum of `tmax` seconds, every
`interval` seconds. Attempt to clear persisting error a maximum of `nreset` times, wait
`treset` between each try.

Recording runs asynchronously, an unused, additional thread is required. Stop recording
with [`stop_record!`](@ref).
"""
function record!(d::Displacement,device::TCPSocket,tmax::Int;
        interval::Float64=0.1,nreset::Int=5,treset::Real=1)
    
    @assert Threads.nthreads() > 1 "For parallel recording, multiple threads are required."
    @assert !d.active "Displacement record is already being used."

    req = Dict(
        "jsonrpc" => "2.0",
        "method" => "",
        "id" => "0",
        "api" => "2",
        "params" => [],
    )
    
    @assert getMeasurementEnabled(device,req) "Measurement not enabled."

    @info "Activating displacement recording."

    d.active = true

    Threads.@spawn record_!(d,device,req,tmax; interval=interval,nreset=nreset,treset=treset)

    return
end

"""
    stop_record!(d::Displacement)

Stop writing data to `d`.
"""
function stop_record!(d::Displacement)
    d.active = false; return
end


