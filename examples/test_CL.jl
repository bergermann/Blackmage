
using Blackmage, JLD2

# use julias help mode to read information of each function

# connect to devices, insert respective IP and port number
#  MC -> motor control
# IDS -> Interferometric Displacement Sensor
# IDS web interface can be opened by putting the IP adress into any browser
device_mc = connect(ip"",0)     # motors
device_ids = connect(ip"",0)    # interferometers

# run this to close connection
close(device_mc); close(device_ids)

# set all motors to external drive mode
# maxdist and target tolerance are given in IDS units
mcSetupFCM(device_mc;
    master=1,
    stepsize=100,
    tol=300,
    maxdist=5000,
    freqmaster=50,
    freqslave=70,
    temp=300)

# stop all motors and set them back to direct drive mode
mcStopAll(device_mc)

# set target distance for all three motors
# this needs to be done once ideally at the positions where interferometers were initialized
# distance can not go lower than 4_500_000 IDS units, therefore ideally initialize IDS
# as close to backplate as possilbe
mcTargetFCM(device_mc,0,:cm)

# after initialization freely set target positions
mcTargetFCM(device_mc,1,:cm)

# block program until target is reached
mcWaitForTarget(device_mc)



# example procedure to test positioning reliability

d = Displacement(100_000)       # record IDS measurement here
d_DL = Displacement(100_000)    # record internal MC position here
d.t0 = d_DL.t0 = now()          # synchronize timestamps

record!(d,device_ids,10*60)

d_m = zeros(3,20)               # repeatedly measure position after each step
d_s = zeros(3,20)               # with uncertainties

for i in 1:10
    println("Iter $i")

    mcTargetFCM(device_mc,1,:cm)    
    mcWaitForTarget(device_mc,d_DL) # record internal positions while moving
    sleep(1)

    stop_record!(d)                 # stop main recording to do precision measurement

    sleep(1)

    d_m[:,2i-1], d_s[:,2i-1] = measurePos(device_ids,100)
    record!(d,device_ids,30)

    sleep(1)

    mcTargetFCM(device_mc,2,:cm)
    mcWaitForTarget(device_mc,d_DL)
    sleep(1)

    stop_record!(d)

    sleep(1)

    d_m[:,2i], d_s[:,2i] = measurePos(device_ids,100)
    record!(d,device_ids,30)

    sleep(1)
end



# plot and safe plots and data

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

P = [p1,p2,p3,p4]


f = "data2"
for i in eachindex(P)
    if isfile("$f.jld2")
        @warn "Plot file already exists."
    else
        savefig(P[i],"plots/$(f)_$i.svg")
    end
end

if !isfile("$f.jld2"); @save f d d_DL d_m d_s; else; @warn "File already exists."; end

