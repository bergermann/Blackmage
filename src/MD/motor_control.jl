


"""
    mcStopAllMotors(md::MultiDevice)

Stop all motors of all devices in multidevice `md`.
"""
function mcStopAllMotors(md::MultiDevice)
    for i in eachindex(md)
        mcStopAllMotors(md[i].mc)
    end

    return
end



"""
    mcEnableFCM(md::MultiDevice;
        stepsize::Int=100,
        tol::Int=300,
        maxdist::Int=5000,
        freqmaster::Int=50,
        freqslave::Int=70)

Activate flexdrive control module for each device in multidevice `md`.
"""
function mcEnableFCM(md::MultiDevice;)
    for i in eachindex(md)
        ds = md[i].settings

        mcEnableFCM(md[i].mc;
            tol=ds.flextol,maxdist=ds.flexdist,
            freqmaster=ds.freq.master,freqslave=ds.freq.slave)
    end

    return
end

"""
    mcDisableFCM(md::MultiDevice)

Deactivate flexdrive control modules of all devices in multidevice `md`.
"""
function mcDisableFCM(md::MultiDevice)
    for i in eachindex(md)
        println("Disabling flexdrive mode of device $i.")
        mcDisableFCM(md[i].mc)
    end

    return
end

"""
    mcSetupFCM(md::MultiDevice)

Put motors into external drive mode and activate flexdrive control module for all devices in
multidevice `md`.
"""
function mcSetupFCM(md::MultiDevice)
    for i in eachindex(md)
        ds = md[i].settings

        mcSetupFCM(md[i].mc;
            master=ds.master,
            tol=ds.flextol,maxdist=ds.flexdist,
            freqmaster=ds.freq.master,freqslave=ds.freq.slave,temp=ds.temp)
    end

    return
end

"""
    mcReSetupFCM(md::MultiDevice)

Put motors back into external drive mode while flexdrive module is still active for all
devices in multidevice `md`. Use e.g. after having used a direct drive command while in
flexdrive mode, to perform another flexdrive command. See [`mcSetupFCM`](@ref).
"""
function mcReSetupFCM(md::MultiDevice)
    for i in eachindex(md)
        ds = md[i].settings

        mcReSetupFCM(md[i].mc;
            master=ds.master,
            tol=ds.flextol,maxdist=ds.flexdist,
            freqmaster=ds.freq.master,freqslave=ds.freq.slave,temp=ds.temp)
    end

    return
end



"""
    mcStopAll(md::MultiDevice)

Stop all motors and flexdrive commands, disable flexdrive module and put motors back into
direct drive mode for all devices in multidevice `md`.
"""
function mcStopAll(md::MultiDevice)
    for i in eachindex(md)
        mcStopAll(md[i].mc)
    end

    return
end



"""
    mcTargetFCM(md::MultiDevice,target::Real,unit::Symbol)

Set distance `target` value in metric `unit` from relative zero position for every device
in multidevice `md`. `target` vector assumes same ordering as multidevice ordering.
"""
function mcTargetFCM(md::MultiDevice,target::Vector{<:Real},unit::Symbol)
    @assert length(target) == length(md) "Target vector length mismatches multidevice length."

    idx = 1
    for i in sort!(collect(keys(md)))
        mcTargetFCM(md[i].mc,target[idx],unit); idx += 1
    end

    return
end




"""
    mcWaitForTarget(md::MultiDevice; interval::Real=0.1)

Wait for flexdrive command to reach its target, check every `interval` seconds.
"""
function mcWaitForTarget(md::MultiDevice; interval::Real=0.1)
    @assert interval >= 0 "Interval needs to be non-negative."

    for i in eachindex(md)
        mcWaitForTarget(md[i].mc; interval=interval)
    end

    return
end

"""
    mcStatusFCM(md::MultiDevice)

Movement state of all flexdrive modules in multidevice `nd`. Returns dict with active states,
target reached states for each axis and FCM internal motor positions in interferometer units
(not necessarily equal to IDS position).
"""
function mcStatusFCM(md::MultiDevice)
    status = Dict{Int,Tuple{Bool},Vector{Bool},Vector{Int}}()

    for i in eachindex(md)
        status[i] = mcStatusFCM(md[i].mc)
    end
    
    return status
end

"""
    mcStatusFCM!(md::MultiDevice,status::Dict{Int,Tuple{Bool,Vector{Bool},Vector{Int}}})

Overwrite existing multidevice `md` status dict.
"""
function mcStatusFCM!(md::MultiDevice,status::Dict{Int,Tuple{Bool,Vector{Bool},Vector{Int}}})
    for i in eachindex(md)
        status[i] = mcStatusFCM(md[i].mc)
    end
    
    return status
end


"""
    measurePos(md::MultiDevice,n::Int; dt::Real=0.)

Measure IDS positions of each device in multidevice `md` `n` times, return dict of mean and
standard deviation of the distribution. Enforce delay `dt` between each measurement.
"""
function measurePos(md::MultiDevice,n::Int; dt::Real=0.)
    data = Dict{Int,Tuple{Float64,Float64}}()

    for i in eachindex(md)
        data[i] = measurePos(md[i].ids,n; dt=dt)
    end
    
    return data
end

