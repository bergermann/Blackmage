


"""
    mcStopAllMotors(md::MultiDevice)

Stop all motors of all devices in multidevice `md`.
"""
function mcStopAllMotors(md::MultiDevice)
    for i in eachindex(md)
        mcStopAllMotors(md.mc[i])
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
    ds = md.settings
    
    for i in eachindex(md)
        mcEnableFCM(ds.mc[i];
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
        mcDisableFCM(md.mc[i])
    end

    return
end

"""
    mcSetupFCM(md::MultiDevice;
        master::Int=1,
        stepsize::Int=100,
        tol::Int=300,
        maxdist::Int=5000,
        freqmaster::Int=50,
        freqslave::Int=70,
        temp::Int=300)

Put motors into external drive mode and activate flexdrive control module for all devices in
multidevice `md`.
"""
function mcSetupFCM(md::MultiDevice;)
    ds = md.settings

    for i in eachindex(md)
        mcSetupFCM(md.mc[i];
            master=ds.master[i],
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
        mcStopAll(md.mc[i])
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
    for i in sort!(collect(keys(md.mc)))
        mcTargetFCM(md.mc[i],target[idx],unit); idx += 1
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
        mcWaitForTarget(md.mc[i]; interval=interval)
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
        status[i] = mcStatusFCM(md.mc[i])
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
        data[i] = measurePos(md.ids[i],n; dt=dt)
    end
    
    return data
end

