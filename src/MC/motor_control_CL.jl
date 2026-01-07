


"""
    mcEnableFCM(device::TCPSocket;
        stepsize::Int=100,
        tol::Int=300,
        maxdist::Int=5000,
        freqmaster::Int=50,
        freqslave::Int=70)

Activate flexdrive control module. Relative motor
`stepsize` is given in percent, target tolerance `tol` and maximum allowed distance `maxdist`
between master and slaves is in IDS interferometer units. Master motor will move with
`freqmaster`, slave motors move with varying `0 - freqslave` to match the master speed.
"""
function mcEnableFCM(device::TCPSocket;
        stepsize::Int=100,
        tol::Int=300,
        maxdist::Int=5000,
        freqmaster::Int=50,
        freqslave::Int=70)

    @assert freqmaster > 0 "Master frequency freq must be positive"
    @assert freqslave > 0 "Slave frequency freq must be positive"
    if freqmaster > freqslave; @warn "Master frequency is larger than slave frequency."; end
    @assert 1 <= stepsize <= 100 "Stepsize must be between 0 and 1."
    @assert tol > 0 "Error tolerance must be non-negative."
    @assert maxdist > 0 "Maximum distance must be non-negative."

    slot = mcModuleSlot(device,"FCM1"); if length(slot) == 0
        throw(ErrorException("No FCM1 module found."))
    elseif length(slot) > 1
        throw(ErrorException("Multiple FCM1 modules found."))
    end; s = slot[1]

    println("Status: ",
        mcRequest(device,"CEN $s $freqmaster $freqslave $stepsize $tol $maxdist 1"))

    return
end

"""
    mcDisableFCM(device::TCPSocket)

Deactivate flexdrive control module and put motors back into direct input mode.
"""
function mcDisableFCM(device::TCPSocket)
    try
        slot = mcModuleSlot(device,"FCM1")

        @assert length(slot) > 0 "No FCM1 found to stop!"

        for s in slot
            println("Status: ",mcRequest(device,"CST $s"))
        end
    catch e
        println("Error encountered while attempting to stop FCM:")
        display(e)
    end

    return
end

"""
    mcMotorToEXT(device::TCPSocket,addr::Int,frequency::Int,temperature::Int)

Set motor at `addr` with maximum movement `frequency` at operating `temperature`.
"""
function mcMotorToEXT(device::TCPSocket,addr::Int,frequency::Int,temperature::Int)
    println("Status stage $addr: ",
        mcRequest(device,"EXT $addr $temperature MM1 $frequency 1"))

    return
end

"""
    mcSetupFCM(device::TCPSocket;
        master::Int=1,
        stepsize::Int=100,
        tol::Int=300,
        maxdist::Int=5000,
        freqmaster::Int=50,
        freqslave::Int=70,
        temp::Int=300)

Put motors into external drive mode and activate flexdrive control module. Relative motor
`stepsize` is given in percent, target tolerance `tol` and maximum allowed distance `maxdist`
between master and slaves is in IDS interferometer units. Master motor will move with
`freqmaster`, slave motors move with varying `0 - freqslave` to match the master speed.
Motor operation temperature `temp` in Kelvin is limited to 4 K - 300 K.
"""
function mcSetupFCM(device::TCPSocket;
        master::Int=1,
        stepsize::Int=100,
        tol::Int=300,
        maxdist::Int=5000,
        freqmaster::Int=50,
        freqslave::Int=70,
        temp::Int=300)

    @assert 1 <= master <= 3 "Master must be 1, 2 or 3."
    @assert freqslave > 0 "Slave frequency freq must be positive"
    if freqmaster > freqslave; @warn "Master frequency is larger than slave frequency."; end
    @assert 1 <= stepsize <= 100 "Stepsize must be between 0 and 1."
    @assert 4 <= temp <= 300 "Environment temperature [K] must be between 4 and 300."
    @assert tol > 0 "Error tolerance must be non-negative."
    @assert maxdist > 0 "Maximum distance must be non-negative."

    for i in 1:3
        mcMotorToEXT(device,i,i==master ? freqmaster : freqslave,temp)
    end

    mcEnableFCM(device; stepsize=stepsize,tol=tol,maxdist=maxdist,
        freqmaster=freqmaster,freqslave=freqslave)

    return
end

"""
    mcReSetupFCM(device::TCPSocket;
        master::Int=1,
        stepsize::Int=100,
        tol::Int=300,
        maxdist::Int=5000,
        freqmaster::Int=50,
        freqslave::Int=70,
        temp::Int=300)

Put motors back into external drive mode while flexdrive module is still active. Use e.g.
after having used a direct drive command while in flexdrive mode, to perform another
flexdrive command. See [`mcSetupFCM`](@ref).
"""
function mcReSetupFCM(device::TCPSocket;
        master::Int=1,
        stepsize::Int=100,
        tol::Int=300,
        maxdist::Int=5000,
        freqmaster::Int=50,
        freqslave::Int=70,
        temp::Int=300)

    @assert 1 <= master <= 3 "Master must be 1, 2 or 3."
    @assert freqslave > 0 "Slave frequency freq must be positive"
    if freqmaster > freqslave; @warn "Master frequency is larger than slave frequency."; end
    @assert 1 <= stepsize <= 100 "Stepsize must be between 0 and 1."
    @assert 4 <= temp <= 300 "Environment temperature [K] must be between 4 and 300."
    @assert tol > 0 "Error tolerance must be non-negative."
    @assert maxdist > 0 "Maximum distance must be non-negative."

    for i in 1:3
        mcMotorToEXT(device,i,i==master ? freqmaster : freqslave,temp)
    end

    return
end


"""
    mcStopAll(device::TCPSocket)

Stop all motors and flexdrive commands, disable flexdrive module and put motors back into
direct drive mode.
"""
function mcStopAll(device::TCPSocket)
    mcDisableFCM(device)
    mcStopAllMotors(device)

    return
end



"""
    mcTargetFCM(device::TCPSocket,target::Real,unit::Symbol)

Set distance `target` value in metric `unit` from relative zero position.
"""
function mcTargetFCM(device::TCPSocket,target::Real,unit::Symbol)
    target = metric2ids(target,unit)

    mcTargetFCM_(device,target)

    return
end

"""
    mcTargetFCM_(device::TCPSocket,target::Int)

Set distance `target` value in interferometer units from relative zero position.
"""
function mcTargetFCM_(device::TCPSocket,target::Int)
    slot = mcModuleSlot(device,"FCM1"); if length(slot) == 0
        throw(ErrorException("No FCM1 module found."))
    elseif length(slot) > 1
        throw(ErrorException("Multiple FCM1 modules found."))
    end; s = slot[1]
    
    println("Status: ",mcRequest(device,"CSP $s $target"))

    return
end



"""
    mcWaitForTarget(device::TCPSocket; interval::Real=0.1)

Wait for flexdrive command to reach its target, check every `interval` seconds.
"""
function mcWaitForTarget(device::TCPSocket; interval::Real=0.1)
    @assert interval >= 0 "Interval needs to be non-negative."

    target = false

    while !target
        active, status, _ = mcStatusFCM(device)

        # if !active; throw(InterruptException()); end

        target = all(status)

        sleep(interval)
    end

    return
end

"""
    mcWaitForTarget(device::TCPSocket,d::Displacement; interval::Real=0.1)

Wait for flexdrive command to reach its target, check every `interval` seconds. Write
position data given by flexdrive module to container `d`.
"""
function mcWaitForTarget(device::TCPSocket,d::Displacement; interval::Real=0.1)
    @assert interval >= 0 "Interval needs to be non-negative."

    target = false

    while !target
        d.idx = d.idx%d.n+1
        
        active, status, pos = mcStatusFCM(device)

        # if !active; throw(InterruptException()); end
        
        d.dX[:,d.idx] .= pos
        d.dT[d.idx] = (now()-d.t0).value

        target = all(status)

        sleep(interval)
    end

    return
end

const mcWait = mcWaitForTarget

"""
    mcStatusFCM(device::TCPSocket)

Movement state of flexdrive module. Returns active state, target reached state for each
axis and FCM internal motor position in interferometer units (not necessarily equal to 
IDS position).
"""
function mcStatusFCM(device::TCPSocket)
    slot = mcModuleSlot(device,"FCM1"); if length(slot) == 0
        throw(ErrorException("No FCM1 module found."))
    elseif length(slot) > 1
        throw(ErrorException("Multiple FCM1 modules found."))
    end; s = slot[1]  

    status = parse.(Int,split(mcRequest(device,"CGS $s"),','))
    
    return Bool(status[1]), Bool.(status[2:4]), status[5:7]
end


"""
    mcTargetP(device_mc::TCPSocket,device_ids::TCPSocket,addr::Int,target::Real,unit::Symbol;
        ess::Float64=15e-6,mrss::Int=10,maxsteps::Int=10,maxiter::Int=10,
        correctess::Bool=false)

Non-flexdriven motor control for sub-step precision corrections after target acquisition.

[NYI]
"""
function mcTargetP(device_mc::TCPSocket,device_ids::TCPSocket,addr::Int,target::Real,unit::Symbol;
        ess::Float64=15e-6,mrss::Int=10,maxsteps::Int=10,maxiter::Int=10,
        correctess::Bool=false)
        
    # throw(ErrorException("Not yet implemented."))

    @assert 1 <= addr <= 3 "Motor address must be 1, 2 or 3."
    @assert 1 <= mrss <= 100 "Minimum relative stepsize mrss need to be between 10 and 100."
    @assert abs(ess) >= 1e-6 "Estimated full step size ess should be larger than 1 µm."
    @assert maxsteps > 0 "maxsteps needs to be positive."
    @assert maxiter > 0 "maxiter needs to be positive."
    
    ess = round(Int,abs(ess)/1e-12)

    d0 = getAxisDisplacement(device_ids,req,addr)
    t = round(Int,target*units[unit]/1e-12)
    dt = abs(d0-t)

    for i in 1:maxiter
        # println("Iter: $i")
        # println("Distance to target:  $(dt/1e12/1e-6) µm")
        # println("Estimated step size: $(ess/1e12/1e-6) µm")
        
        dir = Int(t > d0)
        
        if dt >= ess
            nsteps = min(div(dt,ess),maxsteps); rss = 100
        else
            nsteps = 1; rss = div(100*dt,ess)

            # if rss < mrss/2; break; else; rss = max(rss,mrss); end
            rss = max(rss,mrss)
        end

        # println("nsteps: $nsteps, rss: $rss")

        mcMove(device_mc,addr,dir,nsteps; rss=rss); sleep(0.1+1.5*nsteps/50)

        d1 = getAxisDisplacement(device_ids,req,addr)
        
        # println("Distance to target:  $((d1-t)/1e12/1e-6) µm\n")

        if correctess; ess = round(Int,abs(d1-d0)/nsteps*rss/100); end
        dt = abs(d1-t); d0 = d1

        if 2*dt < ess*mrss/100; break; end
    end

    return
end

function mcTargetP(device_mc::TCPSocket,device_ids::TCPSocket,target::Real,unit::Symbol;
        ess::NTuple{3,Float64}=(15e-6,15e-6,15e-6),mrss::NTuple{3,Int}=(10,10,10),
        maxsteps::Int=10,maxiter::Int=10,
        correctess::Bool=false,doublepass::Bool=true)

    for axis in 1:3
        mcTargetP(device_mc,device_ids,axis,target,unit;
            ess=ess[axis],mrss=mrss[axis],
            maxsteps=maxsteps,maxiter=maxiter,
            correctess=correctess)
    end

    if doublepass; for axis in 1:3
        mcTargetP(device_mc,device_ids,axis,target,unit;
            ess=ess[axis],mrss=mrss[axis],
            maxsteps=maxsteps,maxiter=maxiter,
            correctess=correctess)
    end; end

    return
end

function mcTargetP_abs(device_mc::TCPSocket,device_ids::TCPSocket,addr::Int,target::Real,unit::Symbol;
        ess::Float64=15e-6,mrss::Int=10,maxsteps::Int=10,maxiter::Int=10,
        correctess::Bool=false)
        
    # throw(ErrorException("Not yet implemented."))

    @assert 1 <= addr <= 3 "Motor address must be 1, 2 or 3."
    @assert 1 <= mrss <= 100 "Minimum relative stepsize mrss need to be between 10 and 100."
    @assert abs(ess) >= 1e-6 "Estimated full step size ess should be larger than 1 µm."
    @assert maxsteps > 0 "maxsteps needs to be positive."
    @assert maxiter > 0 "maxiter needs to be positive."
    
    ess = round(Int,abs(ess)/1e-12)

    d0 = getAbsolutePosition(device_ids,req,addr)
    t = round(Int,target*units[unit]/1e-12)
    dt = abs(d0-t)

    for i in 1:maxiter
        dir = Int(t > d0)
        
        # println("Iter: $i")
        # println("Distance to target:  $(dt/1e12/1e-6) µm")
        # println("Estimated step size: $(ess/1e12/1e-6) µm")

        if dt > ess
            nsteps = min(div(dt,ess),maxsteps); rss = 100
        else
            nsteps = 1; rss = div(100*dt,ess)

            if rss < mrss/2; break; else; rss = max(rss,mrss); end
        end

        # println("nsteps: $nsteps, rss: $rss")

        mcMove(device_mc,addr,dir,nsteps; rss=rss); sleep(0.1+1.5*nsteps/50)

        d1 = getAbsolutePosition(device_ids,req,addr)
        
        # println("Distance to target:  $((d1-t)/1e12/1e-6) µm\n")

        if correctess; ess = round(Int,abs(d1-d0)/nsteps*rss/100); end
        dt = abs(d1-t); d0 = d1

        if 2*dt < ess*mrss/100; break; end
    end

    return
end

function mcTargetP_abs(device_mc::TCPSocket,device_ids::TCPSocket,target::Real,unit::Symbol;
        ess::NTuple{3,Float64}=(15e-6,15e-6,15e-6),mrss::NTuple{3,Int}=(10,10,10),
        maxsteps::Int=10,maxiter::Int=10,
        correctess::Bool=false,doublepass::Bool=true)

    for axis in 1:3
        mcTargetP_abs(device_mc,device_ids,axis,target,unit;
            ess=ess[axis],mrss=mrss[axis],
            maxsteps=maxsteps,maxiter=maxiter,
            correctess=correctess)
    end

    if doublepass; for axis in 1:3
        mcTargetP_abs(device_mc,device_ids,axis,target,unit;
            ess=ess[axis],mrss=mrss[axis],
            maxsteps=maxsteps,maxiter=maxiter,
            correctess=correctess)
    end; end

    return
end



function autoAlign(device_mc::TCPSocket,device_ids::TCPSocket,target::Real,unit::Symbol;
        master::Int=1,nsteps::Int=250,
        mrss::NTuple{3,Int}=(10,10,10),ess::NTuple{3,Float64}=(15e-6,15e-6,15e-6))

    mcStopAll(device_mc)
    mcSetupFCM(device_mc; master=master)

    mcTargetFCM(device_mc,target,unit); mcWaitForTarget(device_mc); sleep(1)
    mcTargetP(device_mc,device_ids,target,unit; mrss=mrss,ess=ess,maxiter=10); sleep(1)

    p0 = getAxesDisplacement(device_ids,req); p1 = copy(p0); p2 = copy(p0)

    for axis in 1:3
        if axis==master; continue; end

        mcMove(device_mc,axis,0,nsteps); sleep(1+nsteps/50)

        p1[axis] = getAxisDisplacement(device_ids,req,axis)

        mcReSetupFCM(device_mc; master=master)    

        mcTargetFCM(device_mc,p0[1],:pm); mcWaitForTarget(device_mc); sleep(1)
        mcTargetP(device_mc,device_ids,p0[1],:pm; mrss=mrss,ess=ess,maxiter=10); sleep(1)
        
        mcMove(device_mc,axis,1,nsteps); sleep(1+nsteps/50)

        p2[axis] = getAxisDisplacement(device_ids,req,axis)
        
        mcReSetupFCM(device_mc; master=master)
        
        mcTargetFCM(device_mc,p0[1],:pm); mcWaitForTarget(device_mc); sleep(1)
        mcTargetP(device_mc,device_ids,p0[1],:pm; mrss=mrss,ess=ess,maxiter=10); sleep(1)
    end

    for axis in 1:3
        p = round(Int,(p1[axis]+p2[axis])/2)

        mcTargetP(device_mc,device_ids,axis,p,:pm; mrss=mrss[axis],ess=ess[axis],
            maxsteps=50,maxiter=10)
    end


    return p0, p1, p2
end

function autoAlign(device_mc::TCPSocket,device_ids::TCPSocket,target::Real,unit::Symbol,niter::Int;
            master::Int=1,nsteps::Union{Int,AbstractArray{Int}}=250,
            mrss::NTuple{3,Int}=(10,10,10),ess::NTuple{3,Float64}=(15e-6,15e-6,15e-6))

    @assert niter > 0 "Iteration number niter must be positive."

    if niter != length(nsteps); @warn "Iteration number doesn't match steps input!"; end

    for i in 1:niter
        nsteps_ = nsteps[min(i,length(nsteps))]

        autoAlign(device_mc,device_ids,target,unit;
            master=master,nsteps=nsteps_,mrss=mrss,ess=ess)

        resetAxes(device_ids,req)
    end
    
    return
end
