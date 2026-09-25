

function getCurrentMode(device::D)
    return request(device,:system,"getCurrentMode")[2]
end

function getDeviceType(device::D)
    return request(device,:system,"getDeviceType")[2]
end



"""
    getSystemError(device::D)

Return IDS error if one is present.
"""
function getSystemError(device::D)
    return request(device,:system,"getSystemError")[1]
end

"""
    resetError(device::D)

Attempt to reset IDS error if one is present.
"""
function resetError(device::D)
    return request(device,:system,"resetError"; params=["FALSE"])[1]
end



"""
    getInitMode(device::D)

Get IDS initialization mode of `device` (duh).
"""
function getInitMode(device::D)
    return request(device,:system,"getInitMode")[2]
end

"""
    setInitMode(device::D,mode::Int)

Set IDS initialization mode of `device`. `mode` must be 0 or 1.
"""
function setInitMode(device::D,mode::Int)
    @assert mode == 0 || mode == 1 "Init mode must be 0 or 1."

    request(device,:system,"setInitMode"; params=[mode]); return
end


"""
    resetAxes(device::TCPSocket)

Re-zero relative values of all IDS axes at their current positions.
"""
function resetAxes(device::D)
    request(device,:system,"resetAxes"); return
end

"""
    resetAxis(device::TCPSocket,axis::Int)

Re-zero relative value of IDS `axis` at it's current position.
"""
function resetAxis(device::D,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    request(device,:system,"resetAxes"; params=[axis-1]); return
end

"""
    getMasterAxis(device::TCPSocket)

Return current IDS master axis.
"""
function getMasterAxis(device::D)
    return request(device,:axis,"getMasterAxis")[2]
end

"""
    setMasterAxis(device::TCPSocket,axis)

Set current IDS master `axis`.
"""
function setMasterAxis(device::D,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    request(device,:axis,"setMasterAxis"; params=[axis-1])
    request(device,:axis,"apply") # necessary?
    
    return
end



"""
    getPassMode(device::D)

Get IDS pass mode (duh).
"""
function getPassMode(device::D)
    return request(device,:axis,"getPassMode")[2]
end

"""
    setPassMode(device::D,mode::Int)

Set IDS pass mode, 0 = single, 1 = dual.
"""
function setPassMode(device::D,mode::Int)
    @assert mode == 0 || mode == 1 "Mode must be 0 or 1."

    request(device,:axis,"setPassMode"; params=[mode])
    request(device,:axis,"apply") # necessary?
    
    return
end



