
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



import Plots: plot

"""
    plot(d::Displacement)

Plot displacement, contrast and speed (averaged over 2 consecutive steps).
"""
function Plots.plot(d::Displacement)
    idx = findlast(!iszero,d.dT)
    @assert !isnothing(idx) "Displacement record is empty."
    
    dV = speed(d)

    p1 = plot(d.dT[1:idx]/1e3,d.dX[:,1:idx]'./1e12/1e-3;
        seriestype=:scatter,markersize=0.5,markerstrokewidth=0,
        xlabel="time [s]",ylabel="displacement [mm]")
    p2 = plot(d.dT[1:idx]/1e3,d.dC[:,1:idx]'/10;
        seriestype=:scatter,markersize=0.5,markerstrokewidth=0,
        xlabel="time [s]",ylabel="contrast [%]",ylim=[-5,105])
    p3 = plot(d.dT[2:idx-1]/1e3,dV'/1e12/1e-6;
        seriestype=:scatter,markersize=0.5,markerstrokewidth=0,
        xlabel="time [s]",ylabel="speed [mm/s]",ylim=[-2,2])
    # p3 = plot(d.dT[2:idx]/1e3,dV'/1e12/1e-6;
    #     seriestype=:scatter,markersize=0.5,markerstrokewidth=0,
    #     xlabel="time [s]",ylabel="speed [mm/s]",ylim=[-2,2])

    p = [p1,p2,p3]

    for i in 1:3
        push!(p,plot(d.dT[2:idx-1]/1e3,dV[i,:]/1e12/1e-6;
            seriestype=:scatter,markersize=0.5,markerstrokewidth=0,
            xlabel="time [s]",ylabel="speed [mm/s]",ylim=[-2,2],
            color=get_color_palette(:auto,3)[i],legend=false))
    end

    return p
end

"""
    speed(d::Displacement)

Return motor speed, averaged over two consecutive steps.
"""
function speed(d::Displacement)
    idx = findlast(!iszero,d.dT)
    dV = @. (d.dX[:,1:idx-2]-d.dX[:,2:idx-1])/(d.dT[1:idx-2]-d.dT[2:idx-1])'
    @. dV += (d.dX[:,2:idx-1]-d.dX[:,3:idx])/(d.dT[2:idx-1]-d.dT[3:idx])'
    dV /= 2.

    return dV
    
    # return @. (d.dX[:,1:idx-1]-d.dX[:,2:idx])/(d.dT[1:idx-1]-d.dT[2:idx])'
end



"""
    measurePos(device::TCPSocket,n::Int; dt::Real=0.)

Measure IDS position `n` times, return mean and standard deviation of the distribution.
Enforce delay `dt` between each measurement.
"""
function measurePos(device::TCPSocket,n::Int; dt::Real=0.)
    data = zeros(3,n)

    for i in 1:n
        data[:,i] = getAxesDisplacement(device,req)
        sleep(dt)   
    end
    
    return mean(data; dims=2)[:], std(data; dims=2)[:]
end
