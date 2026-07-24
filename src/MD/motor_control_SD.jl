


"""
    mcMove(sd::SingleDevice,addr::Int,dir::Int,steps::Int;
        freq::Int=50,
        rss::Int=100,
        temp::Int=sd.settings.temp,
        stage::String="MM1",
        df::Real=1.0)

Single device version of [`mcMove`](@ref).
"""
function mcMove(sd::SingleDevice,addr::Int,dir::Int,steps::Int;
        freq::Int=50,
        rss::Int=100,
        temp::Int=sd.settings.temp,
        stage::String="MM1",
        df::Real=1.0)
    
    @assert 1 <= addr <= 3 "Motor address must be 1, 2 or 3."
    @assert dir == 0 || dir == 1 "Direction dir must be 1 or 2."
    @assert 0 < freq <= 100 "Movement frequency freq must be positive, smaller than 100."
    @assert 0 <= steps <= 50000 "Steps must be non-negative, maximum 50_000."
    @assert 1 <= rss <= 100 "Relative step size rss needs to be between 1 and 100."
    @assert 4 <= temp <= 300 "Environment temperature [K] needs to be between 4 and 300."
    @assert 0.1 <= df <= 3.0 "Drive factor df needs to be between 0.1 and 3.0."

    steps == 0 && @warn "Unlimited movement started, use stop command to interrupt."

    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    println("Status stage $addr: ",
        mcRequest(sd.mc,"MOV $addr $dir $freq $rss $steps $temp $stage $df"))

    return
end

mcMove(sd::SingleDevice,addr::AbstractVector{<:Int},dir::Int,steps::Int; kwargs...) =
    mcMove.(sd,addr,dir,steps; kwargs...)



"""
    mcStop(sd::SingleDevice,addr::Int)

Single device version of [`mcStop`](@ref).
"""
function mcStop(sd::SingleDevice,addr::Int)
    @assert 1 <= addr <= 3 "Motor address must be 1, 2 or 3."
    
    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    println("Status stage $addr: ",mcRequest(sd.mc,"STP $addr"))

    return
end

mcStop(sd::SingleDevice,addr::AbstractVector{<:Int}) = mcStop.(sd,addr)



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
    mcStopAllMotors_(device,idx)

    return
end



"""
    mcTargetFCM(sd::SingleDevice,target::Real,unit::Symbol)

Set distance `target` value in metric `unit` from relative zero position for single device
`sd`. Moves motors if module and motors are activated. Updates internal target.
"""
function mcTargetFCM(sd::SingleDevice,target::Real,unit::Symbol)
    update!(sd.target,target*units[unit])
    
    mcTargetFCM(sd.mc,target,unit)

    return
end

"""
    mcTargetFCM(sd::SingleDevice,target::Real)

Set distance `target` value meters from relative zero position for single device `sd`.
Moves motors if modules and motors are activated.
"""

mcTargetFCM(sd::SingleDevice,target::Real) = mcTargetFCM(sd,target,:m)
"""
    mcTargetFCM(sd::SingleDevice)

Set distance target to internal value for single device `sd`.
Moves motors if modules and motors are activated.
"""
mcTargetFCM(sd::SingleDevice) = mcTargetFCM(sd,sd.target.p0,:m)



"""
    mcTargetP(sd::SingleDevice,target::Real,unit::Symbol;
        ess=sd.settings.ess,mrss=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,correctess::Bool=false,doublepass::Bool=true)

Non-flexdriven sub-step precision corrections after target acquisition. Correct all motors
of single device `sd`. Does NOT update internal target.
"""
function mcTargetP(sd::SingleDevice,target::Real,unit::Symbol;
        ess=sd.settings.ess,mrss=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,
        correctess::Bool=false,doublepass::Bool=true,forcewait::Bool=true)

    if forcewait; mcWaitForTarget(sd); sleep(0.1); end
    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    mcTargetP(sd.mc,sd.ids,target,unit;
        ess=ess,mrss=mrss,
        maxsteps=maxsteps,maxiter=maxiter,
        correctess=correctess,doublepass=doublepass)

    return
end

"""
    mcTargetP(sd::SingleDevice,target::Real; kwargs...)

Non-flexdriven sub-step precision corrections after target (in meter) acquisition. Correct all motors
of single device `sd`.
"""
mcTargetP(sd::SingleDevice,target::Real; kwargs...) = mcTargetP(sd,target,:m,kwargs...)

"""
    mcTargetP(sd::SingleDevice; kwargs...)

Non-flexdriven sub-step precision corrections after target acquisition. Correct all motors
of single device `sd`. Use internal target value.
"""
mcTargetP(sd::SingleDevice; kwargs...) = mcTargetP(sd,sd.target.p0,:m,kwargs...)

# """
#     mcTargetP(sd::SingleDevice,target::Real,unit::Symbol;
#         ess=sd.settings.ess,mrss=sd.settings.mrss,
#         maxsteps::Int=10,maxiter::Int=10,correctess::Bool=false,doublepass::Bool=true)

# Non-flexdriven sub-step precision corrections after target acquisition. Correct all motors
# of single device `sd`.
# """
# function mcTargetP(sd::SingleDevice;
#         ess=sd.settings.ess,mrss=sd.settings.mrss,
#         maxsteps::Int=10,maxiter::Int=10,
#         correctess::Bool=false,doublepass::Bool=true)

#     if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

#     mcTargetP(sd.mc,sd.ids,sd.target.p0,:m;
#         ess=ess,mrss=mrss,
#         maxsteps=maxsteps,maxiter=maxiter,
#         correctess=correctess,doublepass=doublepass)

#     return
# end



"""
    mcTarget(sd::SingleDevice,target::Real,unit::Symbol)

Setup flexdrive module if necessary and set `target` in metric `unit` for
single device `sd`. Updates internal target.
"""
function mcTarget(sd::SingleDevice,target::Real,unit::Symbol)
    if sd.stateFCM == FCM_OFF
        mcSetupFCM(sd)
    elseif sd.stateFCM == FCM_SEMI
        mcReSetupFCM(sd)
    end

    mcTargetFCM(sd,target,unit)

    return
end

"""
    mcTarget(sd::SingleDevice,target::Real)

Setup flexdrive module if necessary and set `target` in meters for
single device `sd`. Updates internal target.
"""
mcTarget(sd::SingleDevice,target::Real) = mcTarget(sd,target,:m)

"""
    mcTarget(sd::SingleDevice)

Setup flexdrive module if necessary and use internal distance target value for
single device `sd`
"""
mcTarget(sd::SingleDevice) = mcTarget(sd,sd.target.p0,:m)



"""
    mcWaitForTarget(sd::SingleDevice; interval::Real=0.1)

Wait for flexdrive command to reach its target, check every `interval` seconds.
"""
function mcWaitForTarget(sd::SingleDevice; interval::Real=0.1)
    @assert interval >= 0 "Interval needs to be non-negative."

    mcWaitForTarget(sd.mc; interval=interval)

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