
export mcEnableFCM, mcDisableFCM, mcSetupFCM, mcStopAll
export mcTargetFCM, mcWaitForTarget, mcStatusFCM, mcTargetP
export measurePos



"""
    mcEnableFCM(md::MultiDevice;
        stepsize::Int=100,
        tol::Int=300,
        maxdist::Int=5000,
        freqmaster::Int=50,
        freqslave::Int=70)

Activate flexdrive control module for each device in multidevice `md`.
"""
function mcEnableFCM(md::MultiDevice;
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

    for i in eachindex(md.mc)
        mcEnableFCM(md.mc[i];
            stepsize=stepsize,tol=tol,maxdist=maxdist,
            freqmaster=freqmaster,freqslave=freqslave)
    end

    return
end

"""
    mcDisableFCM(md::MultiDevice)

Deactivate flexdrive control modules of all devices in multidevice `md`.
"""
function mcDisableFCM(md::MultiDevice)
    for i in eachindex(md.mc)
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
function mcSetupFCM(md::MultiDevice;
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

    for i in eachindex(md.mc)
        mcSetupFCM(md.mc[i];
            master=md.master[i],
            stepsize=stepsize,
            tol=tol,
            maxdist=maxdist,
            freqmaster=freqmaster,
            freqslave=freqslave,
            temp=temp)
    end

    return
end



"""
    mcStopAll(md::MultiDevice)

Stop all motors and flexdrive commands, disable flexdrive module and put motors back into
direct drive mode for all devices in multidevice `md`.
"""
function mcStopAll(md::MultiDevice)
    for i in eachindex(md.mc)
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

    for i in eachindex(md.mc)
        mcWaitForTarget(md.mc[i]; interval=interval)
    end

    return
end

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
function mcTargetP(device::TCPSocket,addr::Int,target::Real,unit::Symbol;
        ess::Float64=15e-6,mrss::Int=10,maxsteps::Int=10,maxiter::Int=10,
        correctess::Bool=true)
        
    throw(ErrorException("Not yet implemented."))

    @assert 1 <= addr <= 3 "Motor address must be 1, 2 or 3."
    @assert 10 <= mrss <= 100 "Minimum relative stepsize mrss need to be between 10 and 100."
    @assert abs(ess) >= 1e-6 "Estimated full step size ess should be larger than 1 µm."
    @assert maxsteps > 0 "maxsteps needs to be positive."
    @assert maxiter > 0 "maxiter needs to be positive."
    
    ess = round(Int,abs(ess)/1e-12)

    d0 = getAxisDisplacement(device,req,addr)
    t = round(Int,target*units[unit]/1e-12)
    dt = abs(t-d0)

    nsteps = 1; rss = 100

    i = 1

    while i <= maxiter
        i += 1

        dir = Int(t > d0)

        if dt > ess
            nsteps = min(div(dt,ess),maxsteps); rss = 100

            mcMove(device,addr,dir,nsteps)
        else
            nsteps = 1; rss = div(100*dt,ess)

            if rss < mrss/2; break; else; rss = max(rss,mrss); end

            mcMove(device,addr,dir,1; rss=rss)
        end

        d1 = getAxisDisplacement(device,req,addr)

        if correctess; ess = round(Int,abs(d1-d0)/nsteps); end
        dt = abs(t-d1); d0 = d1

        if 2*dt < ess*mrss/100; break; end
    end

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

