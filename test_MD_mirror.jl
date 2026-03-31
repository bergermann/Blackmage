
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

mcMove.(md[1].mc,[1,2,3],0,0)
mcMove.(md[2].mc,[1,2,3],0,0)
mcMove.(md[3].mc,[1,2,3],0,0)

resetAxes(md,req)

mcSetupFCM(md[3].mc)
mcTargetFCM(md[3].mc,100,:mm)
mcTargetP(md[3],100,:mm)


mcSetupFCM(md[2].mc)
mcTargetFCM(md[2].mc,0,:mm)










