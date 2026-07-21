


"""
    enableECU(sd::SingleDevice,req::Dict)

Enable IDS environmental control unit (duh) for single device `sd`.
"""
function enableECU(sd::SingleDevice,req::Dict)
    enableECU(sd.ids,req); return
end

"""
    enableECU(md::MultiDevice,req::Dict)

Enable IDS environmental control unit (duh) of all devices in multidevice `md`.
"""
function enableECU(md::MultiDevice,req::Dict)
    for device in md
        enableECU(device,req)
    end; return
end

"""
    disableECU(sd::SingleDevice,req::Dict)

Disable IDS environmental control unit (duh) for single device `sd`.
"""
function disableECU(sd::SingleDevice,req::Dict)
    disableECU(sd.ids,req); return
end

"""
    disableECU(md::MultiDevice,req::Dict)

Disable IDS environmental control unit (duh) of all devices in multidevice `md`.
"""
function disableECU(md::MultiDevice,req::Dict)
    for device in md
        disableECU(device,req)
    end; return
end



"""
    getECUEnabled(sd::SingleDevice,req::Dict)

Return if IDS environmental control unit is enabled (duh) for single device `sd`.
"""
function getECUEnabled(sd::SingleDevice,req::Dict)
    return getECUEnabled(sd.ids,req)
end

"""
    getECUEnabled(md::MultiDevice,req::Dict)

Return if IDS environmental control unit is enabled (duh) for all devices in multidevice `md`.
"""
function getECUEnabled(md::MultiDevice,req::Dict)
    enabled = true

    for i in eachindex(md)
        enabled_ = getECUEnabled(md[i],req); enabled *= enabled_
        if !enabled_; println("ECU not enabled for device $i."); end
    end

    return enabled
end



"""
    getECUConnected(sd::SingleDevice,req::Dict)

Return if IDS environmental control unit is connected (duh) for single device `sd`.
"""
function getECUConnected(sd::SingleDevice,req::Dict)
    return getECUConnected(sd.ids,req)
end

"""
    getECUConnected(md::MultiDevice,req::Dict)

Return if IDS environmental control unit is connected (duh) for all devices in multidevice `md`.
"""
function getECUConnected(md::MultiDevice,req::Dict)
    connected = true

    for i in eachindex(md)
        connected_ = getECUConnected(md[i],req); connected *= connected_
        if !connected_; println("ECU not connected for device $i."); end
    end

    return connected
end



"""
    getHumidityInPercent(sd::SingleDevice,req::Dict)

Return ECU measured humidity in percent of single device `sd`.
"""
function getHumidity(sd::SingleDevice,req::Dict)
    return getHumidity(sd.ids,req)
end

"""
    getHumidityInPercent(md::MultiDevice,req::Dict)

Return ECU measured humidity in percent of all devices in multidevice `md`.
"""
function getHumidity(md::MultiDevice,req::Dict)
    return Dict(i=>getHumidity(md[i],req) for i in eachindex(md))
end



"""
    getPressure(sd::SingleDevice,req::Dict)

Return ECU measured pressure in hPa of single device `sd`.
"""
function getPressure(sd::SingleDevice,req::Dict)
    return getPressure(sd.ids,req)
end

"""
    getPressure(md::MultiDevice,req::Dict)

Return ECU measured pressure in hPa of all devices in multidevice `md`.
"""
function getPressure(md::MultiDevice,req::Dict)
    return Dict(i=>getPressure(md[i],req) for i in eachindex(md))
end



"""
    getTemperature(sd::SingleDevice,req::Dict)

Return ECU measured temperature in °C of single device `sd`.
"""
function getTemperature(sd::SingleDevice,req::Dict)
    return getTemperature(sd.ids,req)
end

"""
    getTemperature(md::MultiDevice,req::Dict)

Return ECU measured temperature in °C of all devices in multidevice `md`.
"""
function getTemperature(md::MultiDevice,req::Dict)
    return Dict(i=>getTemperature(md[i],req) for i in eachindex(md))
end



"""
    getRefractiveIndex(sd::SingleDevice,req::Dict)

Return ECU calculated refractive index of single device `sd`.
"""
function getRefractiveIndex(sd::SingleDevice,req::Dict)
    return getRefractiveIndex(sd.ids,req)
end

"""
    getRefractiveIndex(md::MultiDevice,req::Dict)

Return ECU calculated refractive index of all devices in multidevice `md`.
"""
function getRefractiveIndex(md::MultiDevice,req::Dict)
    return Dict(i=>getRefractiveIndex(md[i],req) for i in eachindex(md))
end



"""
    getRefractiveIndexForCompensation(sd::SingleDevice,req::Dict,axis::Int)

Return IDS refractive index used for compensation (check IDS manual).
"""
function getRefractiveIndexForCompensation(sd::SingleDevice,req::Dict,axis::Int)
    return getRefractiveIndexForCompensation(sd.ids,req,axis)
end

"""
    getRefractiveIndexForCompensation(md::MultiDevice,req::Dict,axis::Int)

Return IDS refractive index used for compensation (check IDS manual).
"""
function getRefractiveIndexForCompensation(md::MultiDevice,req::Dict,axis::Int)
    return Dict(i=>getRefractiveIndexForCompensation(md[i],req,axis) for i in eachindex(md))
end
