
"""
    getLockStatus(device::D)

Get status of IDS system lock (duh).
"""
function getLockStatus(device::D)
    r = request(device,:access,"getLockStatus")

    return r[2], r[3]
end

"""
    grantAccess(device::D,password::String)

Grant IDS system access on correct `password` entry.
"""
function grantAccess(device::D,password::String)
    request(device,:access,"grantAccess"; params=[password]); return
end

# this should not be named `lock` due to conflict with ReentrantLocks `lock`
"""
    lock_(device::D,password::String)

Lock IDS system with a `password`.
"""
function lock_(device::D,password::String)
    request(device,:access,"lock"; params=[password]); return
end
