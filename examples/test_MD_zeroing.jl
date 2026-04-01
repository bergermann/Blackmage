
using JLD2, Plots
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
stopMeasurement(md,req)



getAxesDisplacement(md,req)
resetAxes(md,req)

mcStopAll(md)

mcZero(md; timeout=10,repush=false,pushsteps=20)
resetAxes(md,req)

mcSetupFCM(md)
mcReSetupFCM(md)
mcTargetFCM(md,[0,0,0],:mm)
mcTargetFCM(md,[1,1,1],:mm)
mcTargetFCM(md,[1,2,3],:mm)



n = 50
x = [1,2,3]
unit = :mm

p = zeros(3,length(x),n)

mcSetupFCM(md)
mcTargetFCM(md,x,unit); mcWaitForTarget(md); sleep(1)
mcZero(md; timeout=10,repush=true,pushsteps=20)
resetAxes(md,req)

@time for i in 1:n
    println("Iter $(i)/$n")

    mcReSetupFCM(md)
    mcTargetFCM(md,x,unit); mcWaitForTarget(md); sleep(1)
    mcZero(md; timeout=10,repush=true,pushsteps=20); sleep(1)
    
    d = getAxesDisplacement(md,req)
    
    for j in eachindex(md)
        p[:,j,i] = d[j]
    end
end

@save "data/zeroing data.jld2" p
@load "data/zeroing data.jld2"

for i in axes(p,2)
    p1 = plot(; layout=(size(p,1),1));

    for j in axes(p,1)
        plot!(p1[j],p[j,i,:]/1e12/1e-6; seriestype=:histogram)
    end

    p2 = plot(p[:,i,:]'/1e12/1e-6)
    
    display(p1)
    display(p2)
end

