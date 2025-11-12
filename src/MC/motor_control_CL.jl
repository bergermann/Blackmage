
export mcEnableFCM, mcDisableFCM, mcSetupFCM, mcStopAll
export mcTargetFCM, mcWaitForTarget, mcStatusFCM, mcTargetP
export measurePos



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
    mcTargetP(device::TCPSocket,target::Real,unit::Symbol)

Non-flexdriven motor control for sub-step precision corrections after target acquisition.

[NYI]
"""
function mcTargetP(device::TCPSocket,target::Real,unit::Symbol)
    throw(ErrorException("Not yet implemented."))

    return
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

