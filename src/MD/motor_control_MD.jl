


"""
    mcStopAllMotors(md::MultiDevice)

Stop all motors of all devices in multidevice `md`.
"""
function mcStopAllMotors(md::MultiDevice)
    for device in md
        mcStopAllMotors(device)
    end

    return
end



"""
    mcEnableFCM(md::MultiDevice)

Activate flexdrive control module for each device in multidevice `md`.
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
multidevice `md`.
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
flexdrive mode, to perform another flexdrive command. See [`mcSetupFCM`](@ref).
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
    for device in md
        mcStopAll(device)
    end

    return
end



"""
    mcTargetFCM(md::MultiDevice,target::Vector{<:Real},unit::Symbol)

Set distance `target` value in metric `unit` from relative zero position for every device
in multidevice `md`. `target` vector assumes same ordering as multidevice ordering.
"""
function mcTargetFCM(md::MultiDevice,target::Vector{<:Real},unit::Symbol)
    @assert length(target) == length(md) "Target vector length mismatches multidevice length."

    idx = 1
    for i in sort!(collect(keys(md.devices)))
        mcTargetFCM(md[i],target[idx],unit); idx += 1
    end

    return
end

"""
    mcTargetFCM(md::MultiDevice,target::Dict{Int,<:Real},unit::Symbol)

Set distance `target` value in metric `unit` from relative zero position for every device
in multidevice `md`.
"""
function mcTargetFCM(md::MultiDevice,target::Dict{Int,<:Real},unit::Symbol)
    @assert all(k->haskey(md,k),keys(target)) "Key mismatch between device and target dicts."

    for i in eachindex(md.devices)
        mcTargetFCM(md[i],target[i],unit)
    end

    return
end



"""
    mcTargetP(md::MultiDevice,target::Vector{<:Real},unit::Symbol;
        maxsteps::Int=10,maxiter::Int=10,correctess::Bool=false,doublepass::Bool=true)

Non-flexdriven sub-step precision corrections after target acquisition. Correct all motors
of all devices in multidevice `md`, in ascending order.
"""
function mcTargetP(md::MultiDevice,target::Vector{<:Real},unit::Symbol)
    mds = md.settings.psettings; idx = 1

    for i in sort!(collect(keys(md.devices)))
        mcTargetP(md[i],target[idx],unit;
            ess=md[i].settings.ess,mrss=md[i].settings.mrss,
            maxsteps=mds.maxsteps,maxiter=mds.maxiter,
            correctess=mds.correctess,doublepass=mds.doublepass); idx += 1
    end

    return
end



"""
    mcTarget()


"""
function mcTarget(md::MultiDevice,target::Vector{<:Real},unit::Symbol)
    

    return
end

function mcTarget(md::MultiDevice,target::Dict{Int,<:Real},unit::Symbol)
    

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

Movement state of all flexdrive modules in multidevice `md`. Returns dict with active states,
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
    mcZero(md::MultiDevice; interval::Real=0.1,stalltol::Real=0.05,
        timeout::Real=60,dir::Int=0,repush::Bool=false,pushsteps::Int=10)

Push all devices in `md` against hardpoint in direction `dir`, starting with the closest.
Checks for stalling, see [`checkStalling`](@ref). If `repush`, push all devices at once for
`pushsteps` steps against hardpoint.
"""
function mcZero(md::MultiDevice; interval::Real=0.1,stalltol::Real=0.05,
        timeout::Real=60,dir::Int=0,repush::Bool=false,pushsteps::Int=10)

    @assert pushsteps >= 0 "Amount of repush steps needs to be larger than 0."

    d0 = getPos(md,req)
    timeout = Millisecond(isinf(timeout) ? typemax(Int) : round(Int,timeout*1000))

    for i in sort!(collect(keys(md.devices));
            by=x->d0[x][md[x].settings.master],rev=dir==1)
        
        mcMove.(md[i].mc,[1,2,3],dir,0)

        ds = md[i].settings

        ss = round(Int,abs(ds.ess[ds.master]*ds.freq.master*stalltol)/1e-12)
        stalling = false; t0 = now()
        
        while !stalling && now()-t0 < timeout
            stalling = checkStalling(md[i].ids,ds.master,interval,ss)
        end

        mcStop.(md[i].mc,[1,2,3])
    end

    if repush; for i in sort!(collect(keys(md.devices));
            by=x->d0[x][md[x].settings.master],rev=dir==1)
        
        mcMove.(md[i].mc,[1,2,3],dir,pushsteps)
    end; end

    return
end


