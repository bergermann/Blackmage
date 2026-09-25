
"""
    mcZeroHard(md::MultiDevice; interval::Real=0.1,timeout::Real=600,aligned::Bool=true,
        dir::Int=0,repush::Bool=false,pushsteps::Int=10,boosterlength::Real=1.0)

Push all devices in `md` against hardpoint in direction `dir`, starting with the closest.
Checks for stalling, see [`checkStalling`](@ref). If `repush`, push all devices at once for
`pushsteps` steps against hardpoint. If `aligned`, use motor aligned movement to push, else
drive all motors independently. Does not reset axes.
"""
function mcZeroHard(md::MultiDevice; interval::Real=0.1,timeout::Real=600,aligned::Bool=true,
        dir::Int=0,repush::Bool=false,pushsteps::Int=10,boosterlength::Real=1.0)

    @assert pushsteps >= 0 "Amount of repush steps needs to be larger than 0."

    rev = dir==1

    d0 = getAbsPos(md)
    timeout = Millisecond(isinf(timeout) ? typemax(Int) : round(Int,timeout*1000))

    devices = sort!(collect(keys(md)); by=i->d0[i][md[i].settings.master],rev=rev)

    for i in devices
        if md.interrupt[]; return; end

        if aligned
            mcTarget(md[i],d0[i][md[i].settings.master]-boosterlength*((-1)^rev))
        else
            mcMove(md[i],[1,2,3],0,0)
        end

        stalling = false; t0 = now()
        
        while !stalling && now()-t0 < timeout
            if md.interrupt[]; break; end
            
            stalling = checkStalling(md[i],interval)
        end

        mcStopAllMotors(md[i])
    end

    if md.interrupt[]; return; end

    if repush; for i in devices; mcMove(md[i],[1,2,3],dir,pushsteps); end; end

    return rev, devices
end



"""
    mcZeroSoft(md::MultiDevice,offset::Matrix{<:Real}; doublepass::Bool=true,kwargs...)

Perform hard zeroing (see [`mcZeroHard`](@ref)), then adjust each motor of each device in
multidevice `md` by its respective offset value. kwargs are passed to mcZeroHard.
Does not reset axes.

Offset matrix format:
d1m1 d2m1 d3m1 d4m1
d1m2 d2m2 d3m2 d4m2 ...
d1m3 d2m3 d3m3 d4m3
"""
function mcZeroSoft(md::MultiDevice,offset::Matrix{<:Real}; doublepass::Bool=true,kwargs...)
    @assert size(offset) == (3,length(md)) "Offset matrix needs to be size 3 x length(md)."
    
    rev, devices = mcZeroHard(md; kwargs...); sleep(1)
    
    if md.interrupt[]; return; end
    mcWaitForTarget(sd); sleep(1)

    d = getRelPos(md)

    for i in reverse(devices); for axis in 1:3
        if md.interrupt[]; return; end

        mcTargetP(md[i],axis,d[i][axis]*units[:pm]+offset[axis,i]*((-1)^rev),:m;
            maxsteps=10,maxiter=20,forcewait=false)
    end; end

    if doublepass; for i in reverse(devices); for axis in 1:3
        if md.interrupt[]; return; end

        mcTargetP(md[i],axis,d[i][axis]*units[:pm]+offset[axis,i]*((-1)^rev),:m;
            maxsteps=10,maxiter=20,forcewait=false)
    end; end; end

    return
end
