


"""
    mcMove(sd::SingleDevice,axis::Int,dir::Int,steps::Int;
        freq::Int=50,
        rss::Int=100,
        temp::Int=sd.settings.temp,
        stage::String="MM1",
        df::Real=1.0)

Single device version of [`mcMove`](@ref).
"""
function mcMove(sd::SingleDevice,axis::Int,dir::Int,steps::Int;
        freq::Int=50,
        rss::Int=100,
        temp::Int=sd.settings.temp,
        stage::String="MM1",
        df::Real=1.0)
    
    @assert 1 <= axis <= 3 "Motor axis must be 1, 2 or 3."
    @assert dir == 0 || dir == 1 "Direction dir must be 1 or 2."
    @assert 0 < freq <= 100 "Movement frequency freq must be positive, smaller than 100."
    @assert 0 <= steps <= 50000 "Steps must be non-negative, maximum 50_000."
    @assert 1 <= rss <= 100 "Relative step size rss needs to be between 1 and 100."
    @assert 4 <= temp <= 300 "Environment temperature [K] needs to be between 4 and 300."
    @assert 0.1 <= df <= 3.0 "Drive factor df needs to be between 0.1 and 3.0."

    steps == 0 && @warn "Unlimited movement started, use stop command to interrupt."

    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    println("Status stage $axis: ",
        mcRequest(sd.mc,"MOV $axis $dir $freq $rss $steps $temp $stage $df"))

    return
end

function mcMove(sd::SingleDevice,axes::AbstractVector{<:Integer},dir::Int,steps::Int;
        kwargs...)

    for axis in axes
        mcMove(sd,axis,dir,steps; kwargs...)
    end
    
    return
end


"""
    mcStop(sd::SingleDevice,axis::Int)

Single device version of [`mcStop`](@ref).
"""
function mcStop(sd::SingleDevice,axis::Int)
    @assert 1 <= axis <= 3 "Motor axis must be 1, 2 or 3."
    
    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    println("Status stage $axis: ",mcRequest(sd.mc,"STP $axis"))

    return
end

mcStop(sd::SingleDevice,axis::AbstractVector{<:Int}) = mcStop.(sd,axis)



"""
    mcStopAllMotors(sd::SingleDevice)

Single device version of [`mcStopAllMotors`](@ref).
"""
function mcStopAllMotors(sd::SingleDevice)
    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    mcStopAllMotors(sd.mc)

    return
end

function mcStopAllMotors_(sd::SingleDevice,idx::Int)
    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    for i in 1:3
        try
            mcStop(sd.mc,i)
        catch e
            println("Error encountered while attempting to stop motor $i, device $idx:")
            display(e)

            sd.stateFCM = FCM_OFF
        end
    end

    return
end




"""
    mcEnableFCM(sd::SingleDevice;
        tol::Int=sd.settings.flextol,maxdist::Int=sd.settings.maxdist,
        freqmaster::Int=ds.settings.freq.master,freqslave::Int=ds..settings.freq.slave)

Activate flexdrive control module of single device `sd`. Uses internally saved settings
unless overriden.
"""
function mcEnableFCM(sd::SingleDevice;
        tol::Int=sd.settings.flextol,maxdist::Int=sd.settings.maxdist,
        freqmaster::Int=ds.freq.master,freqslave::Int=ds.freq.slave)

    if sd.stateFCM == FCM_OFF; sd.stateFCM = FCM_SEMI; end

    mcEnableFCM(sd.mc;
        tol=tol,maxdist=maxdist,freqmaster=freqmaster,freqslave=freqslave)

    return
end

"""
    mcDisableFCM(sd::SingleDevice)

Deactivate flexdrive control modules of single device `sd`.
"""
function mcDisableFCM(sd::SingleDevice)
    sd.stateFCM = FCM_OFF
    mcDisableFCM(sd.mc)

    return
end

"""
    mcSetupFCM(sd::SingleDevice;
        master::Int=sd.settings.master,
        tol::Int=sd.settings.flextol,maxdist::Int=sd.settings.flexdist,
        freqmaster::Int=sd.settings.freq.master,freqslave::Int=sd.settings.freq.slave,
        temp::Int=sd.settings.temp)

Put motors into external drive mode and activate flexdrive control module for single device
`sd`. Uses internally saved settings unless overriden.
"""
function mcSetupFCM(sd::SingleDevice;
        master::Int=sd.settings.master,
        tol::Int=sd.settings.flextol,maxdist::Int=sd.settings.flexdist,
        freqmaster::Int=sd.settings.freq.master,freqslave::Int=sd.settings.freq.slave,
        temp::Int=sd.settings.temp)

    sd.stateFCM = FCM_ON

    mcSetupFCM(sd.mc;
        master=master,tol=tol,maxdist=maxdist,
        freqmaster=freqmaster,freqslave=freqslave,temp=temp)

    return
end

"""
    mcReSetupFCM(sd::SingleDevice;
        master::Int=sd.settings.master,
        tol::Int=sd.settings.flextol,maxdist::Int=sd.settings.flexdist,
        freqmaster::Int=sd.settings.freq.master,freqslave::Int=sd.settings.freq.slave,
        temp::Int=sd.settings.temp)

Put motors back into external drive mode and activate flexdrive control module for single
device `sd`. Use e.g. after having used a direct drive command while in flexdrive mode, to
perform another flexdrive command. See [`mcSetupFCM`](@ref). Uses internally saved settings
unless overriden.
"""
function mcReSetupFCM(sd::SingleDevice;
        master::Int=sd.settings.master,
        tol::Int=sd.settings.flextol,maxdist::Int=sd.settings.flexdist,
        freqmaster::Int=sd.settings.freq.master,freqslave::Int=sd.settings.freq.slave,
        temp::Int=sd.settings.temp)

    sd.stateFCM = FCM_ON

    mcReSetupFCM(sd.mc;
        master=master,tol=tol,maxdist=maxdist,
        freqmaster=freqmaster,freqslave=freqslave,temp=temp)

    return
end



"""
    mcStopAll(sd::SingleDevice)

Stop all motors and flexdrive commands, disable flexdrive module and put motors back into
direct drive mode for single device `sd`.
"""
function mcStopAll(sd::SingleDevice)
    sd.stateFCM = FCM_OFF
    mcStopAll(sd.mc)

    return
end

function mcStopAll_(sd::SingleDevice,idx::Int)
    sd.stateFCM = FCM_OFF
    
    mcDisableFCM(sd)
    mcStopAllMotors_(sd,idx)

    return
end



"""
    mcTargetFCM(sd::SingleDevice,target::Real=sd.target.p0,unit::Symbol,unit::Symbol=:m)

Set distance `target` value in metric `unit` from relative zero position for single device
`sd`. Moves motors if module and motors are activated. Updates internal target.
"""
function mcTargetFCM(sd::SingleDevice,target::Real=sd.target.p0,unit::Symbol=:m)
    update!(sd.target,target*units[unit])
    
    mcTargetFCM(sd.mc,target,unit)

    return
end



"""
    mcTargetP(sd::SingleDevice,target::Real=sd.target.p0,unit::Symbol=:m;
        ess::Float64=sd.settings.ess,mrss::Int=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,correctess::Bool=false,
        doublepass::Bool=true,forcewait::Bool=true
        offset::Vector{<:Real}=[0.,0.,0.])

Non-flexdriven sub-step precision corrections after `target` acquisition. Correct all motors
of single device `sd`. Does NOT update internal target.
"""
function mcTargetP(sd::SingleDevice,target::Real=sd.target.p0,unit::Symbol=:m;
        ess::Float64=sd.settings.ess,mrss::Int=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,correctess::Bool=false,
        doublepass::Bool=true,forcewait::Bool=true,
        offset::Vector{<:Real}=[0.,0.,0.])

    if sd.interrupt[]; return; end
    if forcewait; mcWaitForTarget(sd); sleep(0.1); end
    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    mcTargetP(sd.mc,sd.ids,target,unit;
        ess=ess,mrss=mrss,
        maxsteps=maxsteps,maxiter=maxiter,
        correctess=correctess,doublepass=doublepass,
        interrupt=sd.interrupt,offset=offset)

    return
end

"""
    mcTargetP(sd::SingleDevice,axis::Int,target::Real=sd.target.p0,unit::Symbol=:m;
        ess::Float64=sd.settings.ess,mrss::Int=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,correctess::Bool=false)

Non-flexdriven sub-step precision corrections after `target` acquisition. Correct single
`axis` of single device `sd`. Does NOT update internal target.
"""
function mcTargetP(sd::SingleDevice,axis::Int,target::Real=sd.target.p0,unit::Symbol=:m;
        ess::Float64=sd.settings.ess,mrss::Int=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,correctess::Bool=false,forcewait::Bool=true)

    if sd.interrupt[]; return; end
    if forcewait; mcWaitForTarget(sd); sleep(0.1); end
    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    mcTargetP(sd.mc,sd.ids,axis,target,unit;
        ess=ess,mrsst=mrss,
        maxsteps=maxsteps,maxiter=maxiter,
        correctess=correctess,interrupt=sd.interrupt)

    return
end



"""
    mcTarget(sd::SingleDevice,target::Real=sd.target.p0,unit::Symbol=:m)

Setup flexdrive module if necessary and set `target` in metric `unit` for
single device `sd`. Updates internal target.
"""
function mcTarget(sd::SingleDevice,target::Real=sd.target.p0,unit::Symbol=:m)
    if sd.stateFCM == FCM_OFF
        mcSetupFCM(sd)
    elseif sd.stateFCM == FCM_SEMI
        mcReSetupFCM(sd)
    end

    mcTargetFCM(sd,target,unit)

    return
end



"""
    mcWaitForTarget(sd::SingleDevice; interval::Real=0.1)

Wait for flexdrive command to reach its target, check every `interval` seconds.
"""
function mcWaitForTarget(sd::SingleDevice; interval::Real=0.1)
    @assert interval >= 0 "Interval needs to be non-negative."

    target = false
    
    while !target
        if sd.interrupt[]; mcStopAllMotors(sd); break; end

        active, status, _ = mcStatusFCM(sd)

        # if !active; throw(InterruptException()); end

        target = all(status)

        sleep(interval)
    end

    return
end



"""
    mcStatusFCM(sd::SingleDevice)

Movement state of flexdrive module of single device `sd`. Return active state,
target reached state for each axis and FCM internal motor positions in interferometer units
(not necessarily equal to IDS position).
"""
function mcStatusFCM(sd::SingleDevice)
    return mcStatusFCM(sd.mc)
end



"""
    checkStalling(sd::SingleDevice,interval::Real,stallspeed::Int=sd.settings.stallspeed)

Measures distance change on master axis of single device `sd` over time `interval`.
Compares against `stallspeed` threshold. 
"""
function checkStalling(sd::SingleDevice,interval::Real,stallspeed::Int=sd.settings.stallspeed)
    return checkStalling(sd.ids_ip,sd.settings.master,interval,stallspeed)
end
