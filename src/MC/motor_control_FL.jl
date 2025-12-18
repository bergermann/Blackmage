
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
        mcMoveDirect(device_mc,device_ids,target,unit)
    end

    # mcTargetP(device_mc,device_ids,target,unit; maxsteps=min(100,stallsteps))

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
        interval::Real=0.1,targettol::Int=100,ess::NTuple{3,Float64}=(1.5e-6,1.5e-6,1.5e-6),
        timeout::Real=Inf)

    @assert timeout > 0 "Timeout time must be positive."

    ess = @. abs(ess)/1e-12
    t = round(Int,target*units[unit]/1e-12)
    d0 = getAxesDisplacement(device_ids,req); dt = d0-t

    if any(@. abs(dt) < ess*targettol); return; end
    if !(all(x->x>0,dt) || all(x->x<0,dt)); return; end

    dir = Int(dt[1]>0)
    
    timeout = Millisecond(isinf(timeout) ? typemax(Int) : round(Int,timeout*1000))
    t0 = now()

    mcMove(device_mc,[1,2,3],dir,0)

    while now()-t0 < timeout
        sleep(interval)

        d = getAxesDisplacement(device_ids,req)

        if any(@. ((-1)^dir)*(d-t) < ess*targettol); break; end
    end

    mcStopAllMotors(device_mc)

    return
end