

"""
    enableECU(md::MultiDevice,req::Dict)

Enable IDS environmental control unit (duh) of all devices in multidevice `md`.
"""
function enableECU(md::MultiDevice,req::Dict)
    for i in eachindex(md)
        enableECU(md[i].ids,req)
    end; return
end

"""
    disableECU(md::MultiDevice,req::Dict)

Disable IDS environmental control unit (duh) of all devices in multidevice `md`.
"""
function disableECU(md::MultiDevice,req::Dict)
    for i in eachindex(md)
        disableECU(md[i].ids,req)
    end; return
end



"""
    getECUEnabled(md::MultiDevice,req::Dict)

Return if IDS environmental control unit is enabled (duh) for all devices in multidevice `md`.
"""
function getECUEnabled(md::MultiDevice,req::Dict)
    enabled = true

    for i in eachindex(md)
        enabled_ = getECUEnabled(md[i].ids,req); enabled *= enabled_
        if !enabled_; println("ECU not enabled for device $i."); end
    end

    return enabled
end



"""
    getECUConnected(md::MultiDevice,req::Dict)

Return if IDS environmental control unit is connected (duh) for all devices in multidevice `md`.
"""
function getECUConnected(md::MultiDevice,req::Dict)
    connected = true

    for i in eachindex(md)
        connected_ = getECUConnected(md[i].ids,req); connected *= connected_
        if !connected_; println("ECU not connected for device $i."); end
    end

    return connected
end



"""
    getHumidityInPercent(md::MultiDevice,req::Dict)

Return ECU measured humidity in percent of all devices in multidevice `md`.
"""
function getHumidity(md::MultiDevice,req::Dict)
    return Dict(i=>getHumidity(md[i].ids,req) for i in eachindex(md))
end

"""
    getPressure(md::MultiDevice,req::Dict)

Return ECU measured pressure in hPa of all devices in multidevice `md`.
"""
function getPressure(md::MultiDevice,req::Dict)
    return Dict(i=>getPressure(md[i].ids,req) for i in eachindex(md))
end

"""
    getTemperature(md::MultiDevice,req::Dict)

Return ECU measured temperature in °C of all devices in multidevice `md`.
"""
function getTemperature(md::MultiDevice,req::Dict)
    return Dict(i=>getTemperature(md[i].ids,req) for i in eachindex(md))
end

"""
    getRefractiveIndex(md::MultiDevice,req::Dict)

Return ECU calculated refractive index of all devices in multidevice `md`.
"""
function getRefractiveIndex(md::MultiDevice,req::Dict)
    return Dict(i=>getRefractiveIndex(md[i].ids,req) for i in eachindex(md))
end

"""
    getRefractiveIndexForCompensation(md::MultiDevice,req::Dict,axis::Int)

Return IDS refractive index used for compensation (check IDS manual).
"""
function getRefractiveIndexForCompensation(md::MultiDevice,req::Dict,axis::Int)
    return Dict(i=>getRefractiveIndexForCompensation(md[i].ids,req,axis)
        for i in eachindex(md))
end
