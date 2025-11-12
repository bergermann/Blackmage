
using Blackmage, Plots



device_mc = connect(ip"",0)
device_ids = connect(ip"",0)

close(device_mc); close(device_ids)



# mcMove.(device_mc,[1,2,3],0,0)
# mcStop.(device_mc,[1,2,3])

mcSetupFCM(device_mc;
    master=1,
    stepsize=100,
    tol=300,
    maxdist=5000,
    freqmaster=50,
    freqslave=70,
    temp=300)

mcStatusFCM(device_mc)

# mcDisableFCM(device_mc)
mcStopAll(device_mc)

mcTargetFCM(device_mc,0,:cm)
mcTargetFCM(device_mc,1,:cm)
mcTargetFCM(device_mc,2,:cm)

mcWaitForTarget(device_mc)

# metric2ids(0,:nm)


d = Displacement(100_000)
d_DL = Displacement(100_000)
d.t0 = d_DL.t0 = now()

record!(d,device_ids,1_000)

d_m = zeros(3,20)
d_s = zeros(3,20)

for i in 1:10
    println("Iter $i")
    mcTargetFCM(device_mc,1,:cm)
    mcWaitForTarget(device_mc,d_DL)
    # mcWaitForTarget(device_mc)
    sleep(1)

    stop_record!(d)

    sleep(1)

    d_m[:,2i-1], d_s[:,2i-1] = measurePos(device_ids,100)
    record!(d,device_ids,30)

    sleep(1)

    mcTargetFCM(device_mc,2,:cm)
    mcWaitForTarget(device_mc,d_DL)
    # mcWaitForTarget(device_mc)
    sleep(1)

    stop_record!(d)

    sleep(1)

    d_m[:,2i], d_s[:,2i] = measurePos(device_ids,100)
    record!(d,device_ids,30)

    sleep(1)
end

f = "data4.jld2"; if !isfile(f); @save f d d_DL d_m d_s; else; @warn "File already exists."; end

y = collect(1:div(size(d_m,2),2))


p1 = plot(d_m[1,1:2:end]/1e12/1e-3,y; seriestype=:scatter,
    xlabel="Displacement [mm]",ylabel="Iterations",label="Motor 1")
plot!(d_m[2,1:2:end]/1e12/1e-3,y.+1; xerror=d_s[2,1:2:end]/1e12/1e-3,seriestype=:scatter,label="Motor 2")
plot!(d_m[3,1:2:end]/1e12/1e-3,y.+2; xerror=d_s[3,1:2:end]/1e12/1e-3,seriestype=:scatter,label="Motor 3")


p2 = plot(d_m[1,2:2:end]/1e12/1e-3,y; seriestype=:scatter,
    xlabel="Displacement [mm]",ylabel="Iterations",label="Motor 1")
plot!(d_m[2,2:2:end]/1e12/1e-3,y.+1; xerror=d_s[2,2:2:end]/1e12/1e-3,seriestype=:scatter,label="Motor 2")
plot!(d_m[3,2:2:end]/1e12/1e-3,y.+2; xerror=d_s[3,2:2:end]/1e12/1e-3,seriestype=:scatter,label="Motor 3")

p3 = histogram(d_m[1,1:2:end]/1e12/1e-3; bins=50,xlabel="Displacement [mm]")
p4 = histogram(d_m[1,2:2:end]/1e12/1e-3; bins=50,xlabel="Displacement [mm]")


savefig(p1,"plots/f1.svg")
savefig(p2,"plots/f2.svg")
savefig(p3,"plots/f3.svg")
savefig(p4,"plots/f4.svg")