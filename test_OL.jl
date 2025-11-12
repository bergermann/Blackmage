
using Blackmage, Plots



device_mc = connect(ip"",0)
device_ids = connect(ip"",0)

close(device_mc); close(device_ids)



mcMove(device_mc,1,1,0)
# mcMove(device_mc,2,0,200)
mcMove(device_mc,3,1,0)

mcMove.(device_mc,[1,2,3],0,0);

mcStop.(device_mc,[1,2,3])


startMeasurement(device_ids,req)

d = Displacement(100_000);
record!(d,device_ids,1_000)
stop_record!(d)

mcMove.(device_mc,[1,2,3],1,0);
mcMove.(device_mc,[1,2,3],0,0);

mcStop.(device_mc,[1,2,3])



p1, p2, p3 = plot(d);

savefig(p1,"plots/d1.svg")
savefig(p2,"plots/d2.svg")
savefig(p3,"plots/d3.svg")

f = "data2.jld2"; if !isfile(f); @save f d; else; @warn "File already exists."; end

@load "data1.jld2"