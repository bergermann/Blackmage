

"""
    enableECU(md::MultiDevice,req::Dict)

Enable IDS environmental control unit (duh) of all devices in multidevice `md`.
"""
function enableECU(md::MultiDevice,req::Dict)
    for i in eachindex(md.ids)
        enableECU(md.ids[i],req)
    end; return
end

"""
    disableECU(md::MultiDevice,req::Dict)

Disable IDS environmental control unit (duh) of all devices in multidevice `md`.
"""
function disableECU(md::MultiDevice,req::Dict)
    for i in eachindex(md.ids)
        disableECU(md.ids[i],req)
    end; return
end



"""
    getECUEnabled(device::D,req::Dict)

Return if IDS environmental control unit is enabled (duh).
"""
function getECUEnabled(device::D,req::Dict)
    return request(device,req,:ecu,"getEnabled")[2]
end



"""
    getECUConnected(device::D,req::Dict)

Return if IDS environmental control unit is connected (duh).
"""
function getECUConnected(device::D,req::Dict)
    return request(device,req,:ecu,"getConnected")[2]
end



"""
    getHumidityInPercent(device::D,req::Dict)

Return ECU measured humidity in percent.
"""
function getHumidity(device::D,req::Dict)
    return request(device,req,:ecu,"getHumidityInPercent")[2]
end

"""
    getPressure(device::D,req::Dict)

Return ECU measured pressure in hPa.
"""
function getPressure(device::D,req::Dict)
    return request(device,req,:ecu,"getPressureInHPa")[2]
end

"""
    getTemperature(device::D,req::Dict)

Return ECU measured temperature in °C.
"""
function getTemperature(device::D,req::Dict)
    return request(device,req,:ecu,"getTemperatureInDegrees")[2]
end

"""
    getRefractiveIndex(device::D,req::Dict)

Return ECU calculated refractive index.
"""
function getRefractiveIndex(device::D,req::Dict)
    return request(device,req,:ecu,"getRefractiveIndex")[2]
end

"""
    getRefractiveIndexCompensationMode(device::D,req::Dict,axis::Int)

Return IDS refractive index compensation mode (idk either, check IDS manual).
"""
function getRefractiveIndexCompensationMode(device::D,req::Dict,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,req,:ecu,"getRefractiveIndexCompensationMode";
    #     params=[axis-1])[2]
    return request(device,req,:ecu,"getRefractiveIndexCompensationMode";
        params=[-1])[2]
end

"""
    getRefractiveIndexForCompensation(device::D,req::Dict,axis::Int)

Return IDS refractive index used for compensation (check IDS manual).
"""
function getRefractiveIndexForCompensation(device::D,req::Dict,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,req,:ecu,"getRefractiveIndexForCompensation";
    #     params=[axis-1])[2]
    return request(device,req,:ecu,"getRefractiveIndexForCompensation";
        params=[-1])[2]
end

"""
    setRefractiveIndexCompensationMode(device::D,req::Dict,axis::Int,mode::Int)

Set IDS refractive index compensation mode (idk either, check IDS manual).
"""
function setRefractiveIndexCompensationMode(device::D,req::Dict,axis::Int,mode::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."
    @assert 0 <= mode <= 2 "Mode needs to be 0, 1 or 2 (see manual)."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,req,:ecu,"setRefractiveIndexCompensationMode";
    #     params=[axis-1,mode])[2]
    return request(device,req,:ecu,"setRefractiveIndexCompensationMode";
        params=[-1,mode])[2]
end
