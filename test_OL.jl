
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


# run motor 1 for 100 steps
# direction 0 = towards backplate, 1 = away from backplate (backplate is where cables/lasers are)
# mcMove(device, motor_id, direction, step number)
mcMove(device_mc,1,1,100)

# run motor 1 for infinite steps, requires manual stop command
# step number > 0: movement fixed amount of steps, step number = 0: infinite movement
mcMove(device_mc,1,1,0)
# stop motor 1
# mcStop(device, motor_id)
mcStop(device_mc,1)

# run motors 1, 2 and 3 at the same time for same step numbers and direction
# here: infinite movement, stop manually 
mcMove.(device_mc,[1,2,3],0,0);
# stop motors 1, 2 and 3
mcStop.(device_mc,[1,2,3])



# initialize IDS measurement, takes a few minutes, can be initialized from IDS web interface
# cannot be activated when IDS optics alignment mode is active (see web interface)
startMeasurement(device_ids,Blackmage.req)

# create container to write measurement data to, adds a timestamp for
# time reference of measurements
d = Displacement(100_000);

# start a passive recording of IDS displacement values for 600 seconds = 10 minutes
# stops automatically after this time or if an error (e.g. sensor block) occurs
record!(d,device_ids,10*60; nreset=0)
# stop said recording manually (duh)
stop_record!(d)


# example procedure to test full movement of range
# start by putting the motors as close to the backplate as possible

d = Displacement(100_000);
record!(d,device_ids,25*60; nreset=1)

# move motors away from stoppers a bit and drive them into stoppers again to normalize
# starting position
mcMove.(device_mc,[1,2,3],1,0); sleep(1); mcStop.(device_mc,[1,2,3]); sleep(1)
mcMove.(device_mc,[1,2,3],0,0); sleep(2); mcStop.(device_mc,[1,2,3]); sleep(1)

mcMove(device_mc,[1,2,3],1,0); 
sleep(600) # this should be enough time to travel full range
mcStop.(device_mc,[1,2,3]); sleep(1)

mcMove(device_mc,[1,2,3],0,0); 
sleep(600)
mcStop.(device_mc)


# display and safe plots and data
P = plot(d); display.(P)

f = "data1"
for i in eachindex(P)
    if isfile("$f.jld2")
        @warn "Plot file already exists."
    else
        savefig(P[i],"plots/$(f)_$i.svg")
    end
end

if !isfile("$f.jld2"); @save f d; else; @warn "File already exists."; end
