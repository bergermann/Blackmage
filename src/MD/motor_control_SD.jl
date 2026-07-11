


"""
    mcStopAllMotors(sd::SingleDevice)

Stop all motors of single device `sd`.
"""
function mcStopAllMotors(sd::SingleDevice)
    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    mcStopAllMotors(sd.mc)

    return
end



"""
    mcEnableFCM(sd::SingleDevice)

Activate flexdrive control module of single device `sd`.
"""
function mcEnableFCM(sd::SingleDevice)
    if sd.stateFCM == FCM_OFF; sd.stateFCM = FCM_SEMI; end

    ds = sd.settings
    mcEnableFCM(sd.mc;
        tol=ds.flextol,maxdist=ds.flexdist,
        freqmaster=ds.freq.master,freqslave=ds.freq.slave)

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
    mcSetupFCM(sd::SingleDevice)

Put motors into external drive mode and activate flexdrive control module for single device
`sd`.
"""
function mcSetupFCM(sd::SingleDevice)
    ds = sd.settings
    sd.stateFCM = FCM_ON

    mcSetupFCM(sd.mc;
        master=ds.master,
        tol=ds.flextol,maxdist=ds.flexdist,
        freqmaster=ds.freq.master,freqslave=ds.freq.slave,temp=ds.temp)

    return
end

"""
    mcReSetupFCM(sd::SingleDevice)

Put motors back into external drive mode and activate flexdrive control module for single
device `sd`. Use e.g. after having used a direct drive command while in flexdrive mode, to
perform another flexdrive command. See [`mcSetupFCM`](@ref).
"""
function mcReSetupFCM(sd::SingleDevice)
    ds = sd.settings
    sd.stateFCM = FCM_ON

    mcReSetupFCM(sd.mc;
        master=ds.master,
        tol=ds.flextol,maxdist=ds.flexdist,
        freqmaster=ds.freq.master,freqslave=ds.freq.slave,temp=ds.temp)

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



"""
    mcTargetFCM(sd::SingleDevice,target::Real,unit::Symbol)

Set distance `target` value in metric `unit` from relative zero position for single device
`sd`.
"""
function mcTargetFCM(sd::SingleDevice,target::Real,unit::Symbol)
    update!(sd.target,target*units[unit])
    
    mcTargetFCM(sd.mc,target,unit)

    return
end



"""
    mcTargetP(sd::SingleDevice,target::Real,unit::Symbol;
        ess=sd.settings.ess,mrss=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,correctess::Bool=false,doublepass::Bool=true)

Non-flexdriven sub-step precision corrections after target acquisition. Correct all motors
of single device `sd`.
"""
function mcTargetP(sd::SingleDevice,target::Real,unit::Symbol;
        ess=sd.settings.ess,mrss=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,
        correctess::Bool=false,doublepass::Bool=true)

    mcTargetP(sd.mc,sd.ids,target,unit;
        ess=ess,mrss=mrss,
        maxsteps=maxsteps,maxiter=maxiter,
        correctess=correctess,doublepass=doublepass)

    return
end

"""
    mcTargetP(sd::SingleDevice,target::Real,unit::Symbol;
        ess=sd.settings.ess,mrss=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,correctess::Bool=false,doublepass::Bool=true)

Non-flexdriven sub-step precision corrections after target acquisition. Correct all motors
of single device `sd`.
"""
function mcTargetP(sd::SingleDevice;
        ess=sd.settings.ess,mrss=sd.settings.mrss,
        maxsteps::Int=10,maxiter::Int=10,
        correctess::Bool=false,doublepass::Bool=true)

    mcTargetP(sd.mc,sd.ids,sd.target.p0,:m;
        ess=ess,mrss=mrss,
        maxsteps=maxsteps,maxiter=maxiter,
        correctess=correctess,doublepass=doublepass)

    return
end



function mcTarget(sd::SingleDevice,target::Real,unit::Symbol; correct::Bool=true)
    if sd.stateFCM == FCM_OFF
        mcSetupFCM(sd)
    elseif sd.stateFCM == FCM_SEMI
        mcReSetupFCM(sd)
    end

    mcTargetFCM(sd,target,unit)
    
    if correct
        mcTargetP(sd)
    end

    return
end