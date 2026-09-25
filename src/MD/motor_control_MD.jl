


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
        mcTargetP(md[i],md[i].target.p0,:m;
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
