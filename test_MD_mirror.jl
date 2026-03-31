
using Blackmage



mc_ips =    [
    ip"192.168.2.2",
    ip"192.168.2.4",
    ip"192.168.2.3",
]

ids_ips =   [
    ip"192.168.2.7",
    ip"192.168.2.5",
    ip"192.168.2.6",
]

md = MultiDevice(mc_ips,ids_ips)



getMeasurementEnabled(md,req)
# startMeasurement(md,req)
# stopMeasurement(md,req)



getAxesDisplacement(md,req)
resetAxes(md,req)

mcStopAll(md)
mcSetupFCM(md)

mcTargetFCM(md,[0,0,1],:mm)
# mcTargetP(md,[0,0,0],:mm)

mcSetupFCM(md)
mcTargetFCM(md,[0,0],:mm); mcWaitForTarget(md); sleep(1)
mcTargetP(md,[0,0],:mm)











mcStopAll(md)

mcSetupFCM(md)
# mcTargetFCM(md,[0,0],:mm); mcWaitForTarget(md); sleep(1)
# mcTargetP(md,[0,0],:mm)

mcTargetFCM(md,[0,0,0],:mm)
mcTargetP(  md,[0,0,0],:mm)

mcTargetFCM(md,[1,2,3],:mm)
mcTargetP(  md,[1,2,3],:mm)


function mcZero(md::MultiDevice; interval::Real=0.1,stalltol::Real=0.05,
        timeout::Real=60,dir::Int=0,repush::Bool=false,pushsteps::Int=10)

    @assert pushsteps >= 0 "Amount of repush steps needs to be larger than 0."

    d0 = getPos(md,req)
    timeout = Millisecond(isinf(timeout) ? typemax(Int) : round(Int,timeout*1000))

    for i in sort!(collect(keys); by=x->d0[x][md[x].settings.master])
        mcMove.(md[i].mc,[1,2,3],dir,0)

        ds = md[i].settings

        ss  = round(Int,abs(ds.ess[ds.master]*ds.freq.master*stalltol))
        stalling = false; t0 = now()
        
        while !stalling && now()-t0 < timeout
            stalling = checkStalling(md[i].ids,master,interval,ss)
        end

        mcStop.(md[i].mc)
    end

    if repush
        for i in sort!(collect(keys); by=x->d0[x][md[x].settings.master])
            mcMove.(md[i].mc,[1,2,3],dir,pushsteps)
        end
    end

    return
end

mcZero(md)


mcStopAll(md)

mcMove.(md[1].mc,[1,2,3],0,0)
mcMove.(md[2].mc,[1,2,3],0,0)
mcMove.(md[3].mc,[1,2,3],0,0)

resetAxes(md,req)

mcSetupFCM(md[3].mc)
mcTargetFCM(md[3].mc,100,:mm)
mcTargetP(md[3],100,:mm)


mcSetupFCM(md[2].mc)
mcTargetFCM(md[2].mc,0,:mm)










