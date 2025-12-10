
"""
    enablePL(device::D,req::Dict)

Enable IDS pilot laser (duh).
"""
function enablePL(device::D,req::Dict)
    request(device,req,:pilot,"enable"); return
end

"""
    disablePL(device::D,req::Dict)

Disable IDS pilot laser (duh).
"""
function disablePL(device::D,req::Dict)
    request(device,req,:pilot,"disable"); return
end

"""
    getPLEnabled(device::D,req::Dict)

Return if IDS pilot laser is enabled (duh).
"""
function getPLEnabled(device::D,req::Dict)
    return request(device,req,:pilot,"getEnabled")[2]
end

"""
    enablePL(device::D,req::Dict,minutes::Real; interval::Real=1)

Enable IDS pilot laser for set amount of `minutes`. Check every `interval` seconds.
"""
function enablePL(device::D,req::Dict,minutes::Real; interval::Real=1)
    T = minutes*60*1e3

    @assert minutes > 0 "Activation time in minutes must be non-negative."

    @info "Activating pilot laser for $(round(Int,minutes)) minutes.
        Interrupt with ctrl+C."

    t0 = now()
    t = Millisecond(0)

    try 
        while t.value < T
            if getPLEnabled(device,req)
                sleep(interval)
            else
                enablePL(device,req)
            end
            t = now()-t0
        end
    catch e
        if !(e isa InterruptException)
            throw(e)
        end
    end

    @info "Deactivating pilot laser."

    disablePL(device,req)

    return
end