


"""
    mcStopAllMotors(md::MultiDevice)

Stop all motors of all devices in multidevice `md`.
"""
function mcStopAllMotors(md::MultiDevice)
    for i in eachindex(md)
        mcStopAllMotors_(md[i],i)
    end

    return
end



"""
    mcEnableFCM(md::MultiDevice)

Activate flexdrive control module for each device in multidevice `md`. Use internally saved
settings of each device.
"""
function mcEnableFCM(md::MultiDevice)
    for device in md
        mcEnableFCM(device)
    end

    return
end

"""
    mcDisableFCM(md::MultiDevice)

Deactivate flexdrive control modules of all devices in multidevice `md`.
"""
function mcDisableFCM(md::MultiDevice)
    for device in md
        mcDisableFCM(device)
    end

    return
end

"""
    mcSetupFCM(md::MultiDevice)

Put motors into external drive mode and activate flexdrive control module for all devices in
multidevice `md`. Use internally saved settings of each device.
"""
function mcSetupFCM(md::MultiDevice)
    for device in md
        mcSetupFCM(device)
    end

    return
end

"""
    mcReSetupFCM(md::MultiDevice)

Put motors back into external drive mode while flexdrive module is still active for all
devices in multidevice `md`. Use e.g. after having used a direct drive command while in
flexdrive mode, to perform another flexdrive command. See [`mcSetupFCM`](@ref). Use
internally saved settings of each device. Use internally saved settings of each device.
"""
function mcReSetupFCM(md::MultiDevice)
    for device in md
        mcReSetupFCM(device)
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
        mcStopAll_(md[i],i)
    end

    return
end



"""
    mcTargetFCM(md::MultiDevice,target::Vector{<:Real},unit::Symbol=:m)

Set distance `target` value in metric `unit` from relative zero position for every device
in multidevice `md`. `target` vector assumes same ordering as multidevice ordering.
Moves motors if modules and motors are activated. Updates internal target.
"""
function mcTargetFCM(md::MultiDevice,target::Vector{<:Real},unit::Symbol=:m)
    @assert length(target) == length(md) "Target vector length mismatches multidevice length."

    idx = 1
    for i in sort!(collect(keys(md)))
        mcTargetFCM(md[i],target[idx],unit); idx += 1
    end

    return
end

"""
    mcTargetFCM(md::MultiDevice,target::Dict{Int,<:Real},unit::Symbol=:m)

Set distance `target` value in metric `unit` from relative zero position for every device
in multidevice `md`. Moves motors if modules and motors are activated.
Updates internal targets.
"""
function mcTargetFCM(md::MultiDevice,target::Dict{Int,<:Real},unit::Symbol=:m)
    @assert all(k->haskey(md,k),keys(target)) "Key mismatch between device and target dicts."

    for i in eachindex(md.devices)
        mcTargetFCM(md[i],target[i],unit)
    end

    return
end

"""
    mcTargetFCM(md::MultiDevice)

Set distance targets to internal values for every device in
multidevice `md`. Moves motors if modules and motors are activated.
"""
function mcTargetFCM(md::MultiDevice)
    for device in md
        mcTargetFCM(device)
    end
    
    return
end



"""
    mcTargetP(md::MultiDevice,target::Vector{Float64},unit::Symbol=:m;
        maxsteps::Int=md.settings.psettings.maxsteps,
        maxiter::Int=md.settings.psettings.maxiter,
        correctess::Bool=md.settings.psettings.correctess,
        doublepass::Bool=md.settings.psettings.doublepass)

Non-flexdriven sub-step precision corrections after target acquisition. Correct all motors
of all devices in multidevice `md`, in ascending order. Does NOT update internal targets.
"""
function mcTargetP(md::MultiDevice,target::Vector{Float64},unit::Symbol=:m;
        maxsteps::Int=md.settings.psettings.maxsteps,
        maxiter::Int=md.settings.psettings.maxiter,
        correctess::Bool=md.settings.psettings.correctess,
        doublepass::Bool=md.settings.psettings.doublepass)
    
    idx = 1

    for i in sort!(collect(keys(md)))
        mcTargetP(md[i],target[idx],unit;
            ess=md[i].settings.ess,mrss=md[i].settings.mrss,
            maxsteps=maxsteps,maxiter=maxiter,correctess=correctess,doublepass=doublepass)
            idx += 1
    end

    return
end

"""
    mcTargetP(md::MultiDevice,target::Dict{Int,<:Real},unit::Symbol=:m;
        maxsteps::Int=md.settings.psettings.maxsteps,
        maxiter::Int=md.settings.psettings.maxiter,
        correctess::Bool=md.settings.psettings.correctess,
        doublepass::Bool=md.settings.psettings.doublepass)

Non-flexdriven sub-step precision corrections after target acquisition. Correct all motors
of all devices in multidevice `md`, in ascending order. Does NOT update internal targets.
"""
function mcTargetP(md::MultiDevice,target::Dict{Int,<:Real},unit::Symbol=:m;
        maxsteps::Int=md.settings.psettings.maxsteps,
        maxiter::Int=md.settings.psettings.maxiter,
        correctess::Bool=md.settings.psettings.correctess,
        doublepass::Bool=md.settings.psettings.doublepass)

    for i in sort!(collect(keys(md)))
        mcTargetP(md[i],target[i],unit;
            ess=md[i].settings.ess,mrss=md[i].settings.mrss,
            maxsteps=maxsteps,maxiter=maxiter,correctess=correctess,doublepass=doublepass)
    end

    return
end

"""
    mcTargetP(md::MultiDevice)

Non-flexdriven sub-step precision corrections after target acquisition. Correct all motors
of all devices in multidevice `md`, in ascending order. Does NOT update internal targets.
"""
function mcTargetP(md::MultiDevice;
        maxsteps::Int=md.settings.psettings.maxsteps,
        maxiter::Int=md.settings.psettings.maxiter,
        correctess::Bool=md.settings.psettings.correctess,
        doublepass::Bool=md.settings.psettings.doublepass)

    for i in sort!(collect(keys(md)))
        mcTargetP(md[i],md[i].target.p0,:p0;
            ess=md[i].settings.ess,mrss=md[i].settings.mrss,
            maxsteps=maxsteps,maxiter=maxiter,correctess=correctess,doublepass=doublepass)
    end

    return
end



"""
    mcTarget(md::MultiDevice,target::Vector{<:Real},unit::Symbol=:m)

Setup flexdrive modules and set distance `target` value in metric `unit` from relative zero
position for every device in multidevice `md`. `target` vector assumes same ordering as
multidevice ordering. Updates internal targets, sets `md.moving` to true (but does not
automatically disable it).
"""
function mcTarget(md::MultiDevice,target::Vector{<:Real},unit::Symbol=:m)
    @assert length(target) == length(md) "Target vector length mismatches multidevice length."

    for device in md
        if device.stateFCM == FCM_OFF
            mcSetupFCM(device)
        elseif device.stateFCM == FCM_SEMI
            mcReSetupFCM(device)
        end
    end
    
    md.moving[] = true
    
    idx = 1
    for i in sort!(collect(keys(md)))
        mcTargetFCM(md[i],target[idx],unit); idx += 1
    end

    return
end

"""
    mcTarget(md::MultiDevice,target::Dict{Int,<:Real},unit::Symbol=:m)

Setup flexdrive modules and set distance `target` value in metric `unit` from relative zero
position for every device in multidevice `md`. Updates internal targets, sets `md.moving` to
true (but does not automatically disable it).
"""
function mcTarget(md::MultiDevice,target::Dict{Int,<:Real},unit::Symbol=:m)
    @assert all(k->haskey(md,k),keys(target)) "Key mismatch between device and target dicts."

    for device in md
        if device.stateFCM == FCM_OFF
            mcSetupFCM(device)
        elseif device.stateFCM == FCM_SEMI
            mcReSetupFCM(device)
        end
    end

    md.moving[] = true
    
    for i in eachindex(md)
        mcTargetFCM(md[i],target[i],unit)
    end

    return
end

"""
    mcTarget(md::MultiDevice)

Setup flexdrive modules and use internal distance target values for every device in
multidevice `md`. Moves the motors, sets `md.moving` to true (but does not automatically
disable it).
"""
function mcTarget(md::MultiDevice)
    for device in md
        if device.stateFCM == FCM_OFF
            mcSetupFCM(device)
        elseif device.stateFCM == FCM_SEMI
            mcReSetupFCM(device)
        end 
    end
    
    md.moving[] = true

    for device in md
        mcTargetFCM(device)
    end

    return
end



"""
    mcWaitForTarget(md::MultiDevice; interval::Real=0.1)

Wait for flexdrive command to reach its target, check every `interval` seconds.
"""
function mcWaitForTarget(md::MultiDevice; interval::Real=0.1)
    @assert interval >= 0 "Interval needs to be non-negative."

    for device in md
        mcWaitForTarget(device; interval=interval)
    end

    md.moving[] = false

    return
end

const mcWait = mcWaitForTarget



"""
    mcStatusFCM(md::MultiDevice)

Movement state of all flexdrive modules in multidevice `md`. Returns dict with active states,
target reached states for each axis and FCM internal motor positions in interferometer units
(not necessarily equal to IDS position).
"""
function mcStatusFCM(md::MultiDevice)
    status = Dict{Int,Tuple{Bool},Vector{Bool},Vector{Int}}()

    for i in eachindex(md)
        status[i] = mcStatusFCM(md[i])
    end
    
    return status
end

"""
    mcStatusFCM!(md::MultiDevice,status::Dict{Int,Tuple{Bool,Vector{Bool},Vector{Int}}})

Overwrite existing multidevice `md` status dict.
"""
function mcStatusFCM!(md::MultiDevice,status::Dict{Int,Tuple{Bool,Vector{Bool},Vector{Int}}})
    for i in eachindex(md)
        status[i] = mcStatusFCM(md[i])
    end
    
    return status
end








"""
    mcZeroHard(md::MultiDevice; interval::Real=0.1,timeout::Real=600,aligned::Bool=true,
        dir::Int=0,repush::Bool=false,pushsteps::Int=10,boosterlength::Real=1.0)

Push all devices in `md` against hardpoint in direction `dir`, starting with the closest.
Checks for stalling, see [`checkStalling`](@ref). If `repush`, push all devices at once for
`pushsteps` steps against hardpoint. If `aligned`, use motor aligned movement to push, else
drive all motors independently.
"""
function mcZeroHard(md::MultiDevice; interval::Real=0.1,timeout::Real=600,aligned::Bool=true,
        dir::Int=0,repush::Bool=false,pushsteps::Int=10,boosterlength::Real=1.0)

    @assert pushsteps >= 0 "Amount of repush steps needs to be larger than 0."

    if md.interrupt[]; return; end

    rev = dir==1

    d0 = getAbsPos(md)
    timeout = Millisecond(isinf(timeout) ? typemax(Int) : round(Int,timeout*1000))

    devices = sort!(collect(keys(md)); by=i->d0[i][md[i].settings.master],rev=rev)

    for i in devices
        if md.interrupt[]; return; end

        if aligned
            mcTarget(md[i],d0[i][md[i].settings.master]-((-1)^rev)*boosterlength)
        else
            mcMove(md[i],[1,2,3],0,0)
        end

        stalling = false; t0 = now()
        
        while !stalling && now()-t0 < timeout
            if md.interrupt[]; return; end
            
            stalling = checkStalling(md[i],interval)
        end

        mcStopAllMotors(md[i])
    end

    if repush; for i in devices; mcMove(md[i],[1,2,3],dir,pushsteps); end; end

    return rev, devices
end



"""
    mcZeroSoft(md::MultiDevice; doublepass::Bool=true,offset::Matrix{<:Real},kwargs...)

Perform hard zeroing (see [`mcZeroHard`](@ref)), then adjust each motor of each device in
multidevice `md` by its respective offset value. kwargs are passed to mcZeroHard.
Does not reset axes.

Offset matrix format:
d1m1 d2m1 d3m1 d4m1
d1m2 d2m2 d3m2 d4m2 ...
d1m3 d2m3 d3m3 d4m3
"""
function mcZeroSoft(md::MultiDevice; doublepass::Bool=true,offset::Matrix{<:Real},kwargs...)
    @assert size(offset) == (3,length(md)) "Offset matrix needs to be size 3 x length(md)."
    
    rev, devices = mcZeroHard(md; kwargs...); sleep(1)
    
    if md.interrupt[]; return; end
    mcWaitForTarget(sd); sleep(1)

    d = getRelPos(md)

    for i in reverse(devices); for axis in 1:3
        mcTargetP(md[i],axis,d[i][axis]*units[:pm]+offset[axis,i],:m;
            maxsteps=10,maxiter=20,forcewait=false)
    end; end

    if doublepass; for i in reverse(devices); for axis in 1:3
        mcTargetP(md[i],axis,d[i][axis]*units[:pm]+offset[axis,i],:m;
            maxsteps=10,maxiter=20,forcewait=false)
    end; end; end

    return
end
