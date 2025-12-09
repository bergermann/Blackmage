
export getCurrentMode, getDeviceType
export getSystemError, resetError
export getInitMode, setInitMode
export resetAxis, resetAxes
export getMasterAxis, setMasterAxis
export getPassMode, setPassMode


function getCurrentMode(device::D,req::Dict)
    return request(device,req,:system,"getCurrentMode")[2]
end

function getDeviceType(device::D,req::Dict)
    return request(device,req,:system,"getDeviceType")[2]
end


"""
    getSystemError(device::D,req::Dict)

Return IDS if one is present.
"""
function getSystemError(device::D,req::Dict)
    return request(device,req,:system,"getSystemError")[1]
end

"""
    resetError(device::D,req::Dict)

Attempt to reset IDS error if one is present.
"""
function resetError(device::D,req::Dict)
    return request(device,req,:system,"resetError"; params=["FALSE"])[1]
end


function getInitMode(device::D,req::Dict)
    return request(device,req,:system,"getInitMode")[2]
end

function setInitMode(device::D,req::Dict,mode::Int)
    @assert mode == 0 || mode == 1 "Init mode must be 0 or 1."

    request(device,req,:system,"setInitMode"; params=[mode]); return
end


"""
    resetAxes(device::TCPSocket,req::Dict)

Re-zero relative values of all IDS axes at their current positions.
"""
function resetAxes(device::D,req::Dict)
    request(device,req,:system,"resetAxes"); return
end

"""
    resetAxis(device::TCPSocket,req::Dict,axis::Int)

Re-zero relative value of IDS `axis` at it's current position.
"""
function resetAxis(device::D,req::Dict,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    request(device,req,:system,"resetAxes"; params=[axis-1]); return
end

"""
    resetAxes(device::TCPSocket,req::Dict,axis::Int)

Re-zero relative value of IDS `axis` at it's current position.
"""
resetAxes(device::D,req::Dict,axis::Int) = resetAxis(device,req,axis)

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



