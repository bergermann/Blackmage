# using Pkg; Pkg.add(url="https://github.com/bergermann/Blackmage")
# using Pkg; Pkg.update("Blackmage")

using Blackmage, JLD2

mc_ips = [
    ip"192.168.2.1",
    ip"192.168.2.2",
    ip"192.168.2.3",
]

ids_ips = [
    ip"192.168.3.1",
    ip"192.168.3.2",
    ip"192.168.3.4",
]



md = MultiDevice(mc_ips,ids_ips)

Blackmage.open_status(md)
isopen(md)

open(md)
close(md)



getMeasurementEnabled(md)
startMeasurement(md)
stopMeasurement(md)



getRelPos(md)
resetAxes(md)

mcStopAll(md)

mcTarget(md,[0.0,0.0,0.0],:mm)

mcTarget(md[3],1,:mm)

mcMove(md[1],[1,2,3],1,10)
