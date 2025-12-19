


"""
    mcVersion(device::TCPSocket)

Return firmware string for motor controller device.
"""
function mcVersion(device::TCPSocket)
    return mcRequest(device,"/VER")
end

"""
    mcMods(device::TCPSocket)

Return installed module list string for motor controller device.
"""
function mcMods(device::TCPSocket)
    return mcRequest(device,"/MODLIST")
end

"""
    mcModuleSlot(device::TCPSocket,mod::String)

Return slot(s) of module `mod` for motor controller device.
"""
function mcModuleSlot(device::TCPSocket,mod::String)
    mods = split(mcMods(device),',')

    return findall(isequal(mod),mods)
end

"""
    mcStages(device::TCPSocket)

Return string listing stages compatible with installed modules for motor controller device.
"""
function mcStages(device::TCPSocket)
    return mcRequest(device,"/STAGES")
end



"""
    mcGetIP(device::TCPSocket)

Get IP address configuration of motor controller device (duh).
"""
function mcGetIP(device::TCPSocket)
    return mcRequest(device,"/IPR")
end

"""
    formatIP(str::AbstractString)

Format IP string of motor controller device.
"""
function formatIP(str::AbstractString)
    s = split(str,',')

    println("Mode:    ",s[1])
    println("IP:      ",s[2])
    println("Subnet:  ",s[3])
    println("Gateway: ",s[4])
    println("MAC:     ",s[5])

    return
end

"""
    mcSetIP(device::TCPSocket; 
        mode::String="",
        ip::String="0.0.0.0",
        subnet::String="0.0.0.0",
        gateway::String="0.0.0.0")

Set new IP configuration. WARNING: If you lose these settings/set them wrong, the device
might be lost to ethernet and needs to be reset via USB/factoryreset.

WARNING: Not yet primed, does not change IP yet (reread manual and uncomment the actual
change command to prime).
"""
function mcSetIP(device::TCPSocket; 
        mode::String="",
        ip::String="0.0.0.0",
        subnet::String="0.0.0.0",
        gateway::String="0.0.0.0")

    old = mcGetIP(device); old_ = split(old,',')
    mode_old    = old_[1]
    ip_old      = old_[2]
    subnet_old  = old_[3]
    gateway_old = old_[4]
    mac_old     = old_[end]

    if mode == ""
        @warn "No mode given, using current mode: $mode_old"
        mode = mode_old
    end

    if ip == "0.0.0.0"
        @warn "No IP given, using current IP: $ip_old"
        ip = ip_old
    end

    if subnet == "0.0.0.0"
        @warn "No Subnet Mask given, using current Mask: $subnet_old"
        subnet = subnet_old
    end

    if gateway == "0.0.0.0"
        @warn "No Gateway given, using current Gateway: $subnet_old"
        gateway = gateway_old
    end

    new = lowercase(mode)*","*ip*","*subnet*","*gateway*","*mac_old

    println("Confirm change of IP address from\n")
    formatIP(old)
    println("\nto\n")
    formatIP(new)

    println("\nType yes to confirm:")
    confirm = readline()

    if confirm == "yes"
        println("Changing IP")

        @warn "IPS function not yet primed. Not changing IP."
        # println("Status: ",mcRequest(device,"/IPS $(uppercase(mode)) $ip $subnet $gateway"))
    else
        println("IP change aborted.")
    end

    return
end



"""
    mcGetBaudrate(device::TCPSocket)

Get current baudrate of motor controller device (duh) (no clue what that means).
"""
function mcGetBaudrate(device::TCPSocket)
    return mcRequest(device,"/GBR")
end

"""
    mcSetBaudrate(device::TCPSocket,rate::Int; interface::String="USB")

Set baudrate of motor controller device (duh) (no clue what that means). `Interface`` is
either \"USB\" or \"RS422\".
"""
function mcSetBaudrate(device::TCPSocket,rate::Int; interface::String="USB")
    @assert rate>0 "rate must be non-zero."
    @assert interface=="USB" || interface=="RS422" "Interface must be USB or RS422."

    println("Status: ",mcRequest(device,"/SBR $interface $rate"))

    return
end




