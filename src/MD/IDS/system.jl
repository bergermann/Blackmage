
function getCurrentMode(device::D,req::Dict)
    return request(device,req,:system,"getCurrentMode")[2]
end

function getDeviceType(device::D,req::Dict)
    return request(device,req,:system,"getDeviceType")[2]
end




"""
    resetAxes(device::TCPSocket,req::Dict)

Re-zero relative values of all IDS axes at their current positions.
"""
function resetAxes(device::D,req::Dict)
    request(device,req,:system,"resetAxes"); return
end

"""
    getMasterAxis(device::TCPSocket,req::Dict)

Return current IDS master axis.
"""
function getMasterAxis(device::D,req::Dict)
    return request(device,req,:axis,"getMasterAxis")[2]
end

"""
    setMasterAxis(device::TCPSocket,req::Dict)

Set current IDS master axis.
"""
function setMasterAxis(device::D,req::Dict,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    request(device,req,:axis,"setMasterAxis"; params=[axis-1])
    request(device,req,:axis,"apply") # necessary?
    
    return
end


"""
    getPassMode(device::D,req::Dict)

Get IDS pass mode (duh).
"""
function getPassMode(device::D,req::Dict)
    return request(device,req,:axis,"getPassMode")[2]
end

"""
    setPassMode(device::D,req::Dict,mode::Int)

Set IDS pass mode, 0 = single, 1 = dual.
"""
function setPassMode(device::D,req::Dict,mode::Int)
    @assert mode == 0 || mode == 1 "Mode must be 0 or 1."

    request(device,req,:axis,"setPassMode"; params=[mode])
    request(device,req,:axis,"apply") # necessary?
    
    return
end



