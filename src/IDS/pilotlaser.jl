
"""
    enablePL(device::D)

Enable IDS pilot laser (duh).
"""
function enablePL(device::D)
    request(device,:pilot,"enable"); return
end

"""
    disablePL(device::D)

Disable IDS pilot laser (duh).
"""
function disablePL(device::D)
    request(device,:pilot,"disable"); return
end

"""
    getPLEnabled(device::D)

Return if IDS pilot laser is enabled (duh).
"""
function getPLEnabled(device::D)
    return request(device,:pilot,"getEnabled")[2]
end

"""
    enablePL(device::D,minutes::Real; interval::Real=1)

Enable IDS pilot laser for set amount of `minutes`. Check every `interval` seconds.
"""
function enablePL(device::D,minutes::Real; interval::Real=1)
    T = minutes*60*1e3

    @assert minutes > 0 "Activation time in minutes must be non-negative."

    @info "Activating pilot laser for $(round(Int,minutes)) minutes.
        Interrupt with ctrl+C."

    t0 = now()
    t = Millisecond(0)

    try 
        while t.value < T
            if getPLEnabled(device)
                sleep(interval)
            else
                enablePL(device)
            end
            t = now()-t0
        end
    catch e
        if !(e isa InterruptException)
            throw(e)
        end
    end

    @info "Deactivating pilot laser."

    disablePL(device)

    return
end