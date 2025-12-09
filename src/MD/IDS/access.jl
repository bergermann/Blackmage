
"""
    getLockStatus(device::D,req::Dict)

Get status of IDS system lock (duh).
"""
function getLockStatus(device::D,req::Dict)
    r = request(device,req,:access,"getLockStatus")

    return r[2], r[3]
end

"""
    grantAccess(device::D,req::Dict,password::String)

Grant IDS system access on correct `password` entry.
"""
function grantAccess(device::D,req::Dict,password::String)
    request(device,req,:access,"grantAccess"; params=[password]); return
end

"""
    lock(device::D,req::Dict,password::String)

Lock IDS system with a `password`.
"""
function lock(device::D,req::Dict,password::String)
    request(device,req,:access,"lock"; params=[password]); return
end
