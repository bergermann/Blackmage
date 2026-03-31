# using Pkg; Pkg.add(url="https://github.com/bergermann/Blackmage")
using Pkg; Pkg.update("Blackmage")

using Blackmage, JLD2



mc_ips =    [
    ip"192.168.2.2",
    ip"192.168.2.4",
    # ip"192.168.2.3",
]

ids_ips =   [
    ip"192.168.2.7",
    ip"192.168.2.5",
    # ip"192.168.2.6",
]

md = MultiDevice(mc_ips,ids_ips)
md[1].settings.ess = (15e-6,15e-6,15e-6); md[1].settings.mrss = (10,10,10)
md[2].settings.ess = (10e-6,10e-6,10e-6); md[2].settings.mrss = (10,10,10)

Blackmage.open_status(md)
open(md)
close(md)

getMeasurementEnabled(md,req)
startMeasurement(md,req)
stopMeasurement(md,req)

getAxesDisplacement(md,req)
resetAxes(md,req)

mcStopAll(md)
mcSetupFCM(md)

mcTargetFCM(md,[0.0,0.0],:mm)
mcTargetP(md,[0,0],:mm)

mcSetupFCM(md)
mcTargetFCM(md,[0,0],:mm); mcWaitForTarget(md); sleep(1)
mcTargetP(md,[0,0],:mm)

mcTargetFCM(md[2].mc,0.0,:mm)
mcTargetP(md[2].mc,md[2].ids,0,:mm; ess=(10e-6,20e-6,20e-6),mrss=(5,5,5),maxiter=20)
# mcTargetP(md[2].mc,md[2].ids,1,0,:mm; ess=20e-6,mrss=15)
mcMove(md[2].mc,1,1,10)

p0 = getAxesDisplacement(md,req)
mcMove.(md[2].mc,[1,2,3],1,100)
p1 = getAxesDisplacement(md,req)




n = 100
x1 = [0,0]
x2 = [1,1]
unit = :mm

p1  = zeros(3,2,n)             # repeatedly measure position after each step
p1p = zeros(3,2,n)             # repeatedly measure position after each step
p2  = zeros(3,2,n)             # repeatedly measure position after each step
p2p = zeros(3,2,n)             # repeatedly measure position after each step



mcSetupFCM(md)
mcTargetFCM(md,(x1+x2)/2,unit); mcWaitForTarget(md); sleep(1)

@time for i in 1:n
    println("Iter $(i)/$n")

    mcTargetFCM(md,x1,unit); mcWaitForTarget(md); sleep(1) # reset positions
    d1 = getAxesDisplacement(md,req)
    
    mcTargetP(md,x1,unit; maxsteps=20,maxiter=30); sleep(1)
    d1p = getAxesDisplacement(md,req)
    
     p1[:,1,i] = d1[1];   p1[:,2,i] = d1[2]; 
    p1p[:,1,i] = d1p[1]; p1p[:,2,i] = d1p[2]; 

    mcReSetupFCM(md)
    mcTargetFCM(md,x2,unit); mcWaitForTarget(md); sleep(1) # reset positions
    d2 = getAxesDisplacement(md,req)
    
    mcTargetP(md,x2,unit; maxsteps=20,maxiter=30); sleep(1)
    d2p = getAxesDisplacement(md,req)
    
     p2[:,1,i] = d2[1];   p2[:,2,i] = d2[2]; 
    p2p[:,1,i] = d2p[1]; p2p[:,2,i] = d2p[2]; 

    mcReSetupFCM(md)
end

@save "positioning data 48.jld2" p1 p1p p2 p2p





# example procedure to test precision corrections

RSS = [100,90,80,70,60,50,40,30,20,10,9,8,7,6,5,4,3,2,1]  # relative step size values to test
# RSS = [100,90]  # relative step size values to test
nsteps = 10                             # move n steps at once
dir = 1                                 # direction to test for

d_m1 = zeros(3,length(RSS))            # repeatedly measure position after each step
d_m2 = zeros(3,length(RSS))            # repeatedly measure position after each step

disc = 1

@time for i in eachindex(RSS)
    println("RSS $(RSS[i])")

    for axis in 1:3
        mcSetupFCM(md)
        mcTargetFCM(md[disc].mc,0,:mm); mcWaitForTarget(md[disc].mc); sleep(1)
        d_m1[axis,i] = measurePos(md[disc].ids,10)[axis]; sleep(1)
        
        mcMove.(md[disc].mc,[axis],dir,nsteps; rss=RSS[i]); sleep(2)
        d_m2[axis,i] = measurePos(md[disc].ids,10)[axis]; sleep(1)
    end
end

mcStopAll(md)

p1 = plot(RSS,(d_m[:,2:2:end]-d_m[:,1:2:ebd])'./1e12/1e-3; seriestype=:scatter,
    xlabel="RSS",ylabel="Δx [mm]")

P = [p1]

f = "RSS1"
for i in eachindex(P)
    if isfile("$f.jld2")
        @warn "Plot file already exists."
    else
        savefig(P[i],"plots/$(f)_$i.svg")
    end
end

f_ = "$f.jld2"; if !isfile(f_); @save f_ d d_DL d_m d_s; else; @warn "File already exists."; end
