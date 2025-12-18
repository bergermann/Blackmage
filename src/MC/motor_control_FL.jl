
export mcTarget, mcMoveDirect

function mcTarget(device_mc::TCPSocket,device_ids::TCPSocket,target::Real,unit::Symbol;
        master::Int=1,masterfreq::Int=50,masteress::Float64=15e-6,
        interval::Real=0.1,stalltime::Int=5,stalltol::Real=0.05,nstalltol::Int=5,
        stallsteps::Int=10,timeout::Real=Inf)

    @assert timeout > 0 "Timeout time must be positive."

    t = round(Int,target*units[unit]/1e-12)

    ess = abs(masteress)/1e-12
    ss  = round(Int,ess*masterfreq*stalltol)
    ess = round(Int,ess)

    println("Stall speed: $ss")
    println("Est step:    $ess")

    timeout =   Millisecond(isinf(  timeout) ? typemax(Int) : round(Int,  timeout*1000))
    stalltime = Millisecond(isinf(stalltime) ? typemax(Int) : round(Int,stalltime*1000))
    t0 = now()

    active = true; stalling = false; nstall = 0; override = false

    mcStopAll(device_mc)
    mcSetupFCM(device_mc)
    mcTargetFCM(device_mc,target,unit)

    while active && now()-t0 < timeout
        if !stalling
            active, status, _ = mcStatusFCM(device_mc)

            if status[master]; println("target reached"); mcWaitForTarget(device_mc); break; end

            stalling = checkStalling(device_ids,master,interval,ss); nstall *= stalling
        else
            ts = now()

            while now()-ts < stalltime && stalling
                stalling = checkStalling(device_ids,master,interval,ss)
            end

            if stalling
                println("stalled. attempting unstall.")

                mcStopAllMotors(device_mc); sleep(0.1)

                d = getAxisDisplacement(device_ids,req,master)
                dt = abs(d-t); dir = Int(t > d)
        
                if dt < stallsteps*ess; break; end

                mcMove.(device_mc,[1,2,3],dir,stallsteps); sleep(0.1+stallsteps/masterfreq)
                
                nstall += 1; if nstall > nstalltol; override = true; break; end

                println("reactivating target command")
                
                mcReSetupFCM(device_mc)
                mcTargetFCM(device_mc,target,unit)
            end
        end
    end

    if override
        @warn "Activating override mode."
        
        mcMoveDirect(device_mc,device_ids,target,unit)
    end

    mcTargetP(device_mc,device_ids,target,unit; maxsteps=min(100,stallsteps))

    return
end

function checkStalling(device_ids::TCPSocket,master::Int,interval::Real,ss::Int)
    p0 = getAxisDisplacement(device_ids,req,master)

    t0 = now(); sleep(interval)

    p1 = getAxisDisplacement(device_ids,req,master)

    speed = abs(1000*(p1-p0)/((now()-t0).value))

    speed < ss && println("stalling. speed: $speed vs. $ss")

    return speed < ss
end

function mcMoveDirect(device_mc::TCPSocket,device_ids::TCPSocket,target::Real,unit::Symbol;
        interval::Real=0.1,targettol::Int=10,ess::NTuple{3,Float64}=(15e-6,15e-6,15e-6),
        timeout::Real=Inf)

    @assert timeout > 0 "Timeout time must be positive."

    ess = @. abs(ess)/1e-12
    t = round(Int,target*units[unit]/1e-12)
    dt = getAxesDisplacement(device_ids,req).-t

    tnr = @. abs(dt) > ess*targettol    # target not reached

    if !any(tnr); println("target already reached"); return; end

    dir = @. Int(dt<0)
    axes = [1,2,3][tnr]
    
    timeout = Millisecond(isinf(timeout) ? typemax(Int) : round(Int,timeout*1000))
    t0 = now()

    for axis in axes
        mcMove(device_mc,axis,dir[axis],0)
    end

    while now()-t0 < timeout && any(tnr)
        sleep(interval)

        d = getAxesDisplacement(device_ids,req)

        for axis in axes
            if ((-1)^dir[axis])*(d[axis]-t) < ess[axis]*targettol
                mcStop(device_mc,axis); tnr[axis] = false
            end
        end
    end

    mcStopAllMotors(device_mc)

    return
end