
export mcMove, mcStop, mcStopAllMotors


"""
    mcMove(device::TCPSocket,addr::Int,dir::Int,steps::Int;
        freq::Int=50,
        rss::Int=100,
        temp::Int=300,
        stage::String="MM1",
        df::Real=1.0)

Move motor `addr` of `device` in direction `dir` (0 or 1) for `steps`. If step number is set
to 0, motor moves until it receives a stop signal! `freq` is the step frequency, should not
be higher than 70. Use relative step size `rss` to reduce step size in percent (to be tested).
Set operating temperature `temp` in Kelvin. `stage` is the stage type, `df` the drive factor
(don't change either without Christoph's approval).
"""
function mcMove(device::TCPSocket,addr::Int,dir::Int,steps::Int;
        freq::Int=50,
        rss::Int=100,
        temp::Int=300,
        stage::String="MM1",
        df::Real=1.0)
    
    @assert 1 <= addr <= 3 "Motor address must be 1, 2 or 3."
    @assert dir == 0 || dir == 1 "Direction dir must be 1 or 2."
    @assert 100 >= freq > 0 "Movement frequency freq must be positive, smaller than 100."
    @assert 0 <= steps <= 50000 "Steps must be non-negative, maximum 50_000."
    @assert 1 <= rss <= 100 "Relative step size rss needs to between 1 and 100."
    @assert 4 <= temp <= 300 "Environment temperature [K] needs to between 4 and 300."
    @assert 0.1 <= df <= 3.0 "Drive factor df needs to be between 0.1 and 3.0."

    steps == 0 && @warn "Unlimited movement started, use stop command to interrupt."

    println("Status stage $addr: ",
        mcRequest(device,"MOV $addr $dir $freq $rss $steps $temp $stage $df"))

    return
end

"""
    mcStop(device::TCPSocket,addr::Int)

Stop motor `addr` of `device`.
"""
function mcStop(device::TCPSocket,addr::Int)
    @assert 1 <= addr <= 3 "Motor address must be 1, 2 or 3."
    
    println("Status stage $addr: ",mcRequest(device,"STP $addr"))

    return
end

"""
    mcStopAllMotors(device::TCPSocket)

Stop all motors of `device`.
"""
function mcStopAllMotors(device::TCPSocket)
    for i in 1:3
        try
            mcStop(device,i)
        catch e
            println("Error encountered while attempting to stop motor $i:")
            display(e)
        end
    end

    return
end
