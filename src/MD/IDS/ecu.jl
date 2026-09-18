


"""
    enableECU(sd::SingleDevice)

Enable IDS environmental control unit (duh) for single device `sd`.
"""
function enableECU(sd::SingleDevice)
    enableECU(sd.ids); return
end

"""
    enableECU(md::MultiDevice)

Enable IDS environmental control unit (duh) of all devices in multidevice `md`.
"""
function enableECU(md::MultiDevice)
    for device in md
        enableECU(device)
    end; return
end

"""
    disableECU(sd::SingleDevice)

Disable IDS environmental control unit (duh) for single device `sd`.
"""
function disableECU(sd::SingleDevice)
    disableECU(sd.ids); return
end

"""
    disableECU(md::MultiDevice)

Disable IDS environmental control unit (duh) of all devices in multidevice `md`.
"""
function disableECU(md::MultiDevice)
    for device in md
        disableECU(device)
    end; return
end



"""
    getECUEnabled(sd::SingleDevice)

Return if IDS environmental control unit is enabled (duh) for single device `sd`.
"""
function getECUEnabled(sd::SingleDevice)
    return getECUEnabled(sd.ids)
end

"""
    getECUEnabled(md::MultiDevice)

Return if IDS environmental control unit is enabled (duh) for all devices in multidevice `md`.
"""
function getECUEnabled(md::MultiDevice)
    enabled = true

    for i in eachindex(md)
        enabled_ = getECUEnabled(md[i]); enabled *= enabled_
        if !enabled_; println("ECU not enabled for device $i."); end
    end

    return enabled
end



"""
    getECUConnected(sd::SingleDevice)

Return if IDS environmental control unit is connected (duh) for single device `sd`.
"""
function getECUConnected(sd::SingleDevice)
    return getECUConnected(sd.ids)
end

"""
    getECUConnected(md::MultiDevice)

Return if IDS environmental control unit is connected (duh) for all devices in multidevice `md`.
"""
function getECUConnected(md::MultiDevice)
    connected = true

    for i in eachindex(md)
        connected_ = getECUConnected(md.ids); connected *= connected_
        if !connected_; println("ECU not connected for device $i."); end
    end

    return connected
end



"""
    getHumidityInPercent(sd::SingleDevice)

Return ECU measured humidity in percent of single device `sd`.
"""
function getHumidity(sd::SingleDevice)
    return getHumidity(sd.ids)
end

"""
    getHumidityInPercent(md::MultiDevice)

Return ECU measured humidity in percent of all devices in multidevice `md`.
"""
function getHumidity(md::MultiDevice)
    return Dict(i=>getHumidity(md[i]) for i in eachindex(md))
end



"""
    getPressure(sd::SingleDevice)

Return ECU measured pressure in hPa of single device `sd`.
"""
function getPressure(sd::SingleDevice)
    return getPressure(sd.ids)
end

"""
    getPressure(md::MultiDevice)

Return ECU measured pressure in hPa of all devices in multidevice `md`.
"""
function getPressure(md::MultiDevice)
    return Dict(i=>getPressure(md[i]) for i in eachindex(md))
end



"""
    getTemperature(sd::SingleDevice)

Return ECU measured temperature in °C of single device `sd`.
"""
function getTemperature(sd::SingleDevice)
    return getTemperature(sd.ids)
end

"""
    getTemperature(md::MultiDevice)

Return ECU measured temperature in °C of all devices in multidevice `md`.
"""
function getTemperature(md::MultiDevice)
    return Dict(i=>getTemperature(md[i]) for i in eachindex(md))
end



"""
    getRefractiveIndex(sd::SingleDevice)

Return ECU calculated refractive index of single device `sd`.
"""
function getRefractiveIndex(sd::SingleDevice)
    return getRefractiveIndex(sd.ids)
end

"""
    getRefractiveIndex(md::MultiDevice)

Return ECU calculated refractive index of all devices in multidevice `md`.
"""
function getRefractiveIndex(md::MultiDevice)
    return Dict(i=>getRefractiveIndex(md[i]) for i in eachindex(md))
end



"""
    getRefractiveIndexForCompensation(sd::SingleDevice,axis::Int)

Return IDS refractive index used for compensation (check IDS manual).
"""
function getRefractiveIndexForCompensation(sd::SingleDevice,axis::Int)
    return getRefractiveIndexForCompensation(sd.ids,axis)
end

"""
    getRefractiveIndexForCompensation(md::MultiDevice,axis::Int)

Return IDS refractive index used for compensation (check IDS manual).
"""
function getRefractiveIndexForCompensation(md::MultiDevice,axis::Int)
    return Dict(i=>getRefractiveIndexForCompensation(md[i],axis) for i in eachindex(md))
end
