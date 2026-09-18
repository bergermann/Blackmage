
"""
    enableECU(device::D)

Enable IDS environmental control unit (duh).
"""
function enableECU(device::D)
    request(device,:ecu,"enable"); return
end

"""
    disableECU(device::D)

Disable IDS environmental control unit (duh).
"""
function disableECU(device::D)
    request(device,:ecu,"disable"); return
end



"""
    getECUEnabled(device::D)

Return if IDS environmental control unit is enabled (duh).
"""
function getECUEnabled(device::D)
    return request(device,:ecu,"getEnabled")[2]
end



"""
    getECUConnected(device::D)

Return if IDS environmental control unit is connected (duh).
"""
function getECUConnected(device::D)
    return request(device,:ecu,"getConnected")[2]
end



"""
    getHumidityInPercent(device::D)

Return ECU measured humidity in percent.
"""
function getHumidity(device::D)
    return request(device,:ecu,"getHumidityInPercent")[2]
end

"""
    getPressure(device::D)

Return ECU measured pressure in hPa.
"""
function getPressure(device::D)
    return request(device,:ecu,"getPressureInHPa")[2]
end

"""
    getTemperature(device::D)

Return ECU measured temperature in °C.
"""
function getTemperature(device::D)
    return request(device,:ecu,"getTemperatureInDegrees")[2]
end

"""
    getRefractiveIndex(device::D)

Return ECU calculated refractive index.
"""
function getRefractiveIndex(device::D)
    return request(device,:ecu,"getRefractiveIndex")[2]
end

"""
    getRefractiveIndexCompensationMode(device::D,axis::Int)

Return IDS refractive index compensation mode (idk either, check IDS manual).
"""
function getRefractiveIndexCompensationMode(device::D,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,:ecu,"getRefractiveIndexCompensationMode";
    #     params=[axis-1])[2]
    return request(device,:ecu,"getRefractiveIndexCompensationMode";
        params=[-1])[2]
end

"""
    getRefractiveIndexForCompensation(device::D,axis::Int)

Return IDS refractive index used for compensation (check IDS manual).
"""
function getRefractiveIndexForCompensation(device::D,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,:ecu,"getRefractiveIndexForCompensation";
    #     params=[axis-1])[2]
    return request(device,:ecu,"getRefractiveIndexForCompensation";
        params=[-1])[2]
end

"""
    setRefractiveIndexCompensationMode(device::D,axis::Int,mode::Int)

Set IDS refractive index compensation mode (idk either, check IDS manual).
"""
function setRefractiveIndexCompensationMode(device::D,axis::Int,mode::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."
    @assert 0 <= mode <= 2 "Mode needs to be 0, 1 or 2 (see manual)."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,:ecu,"setRefractiveIndexCompensationMode";
    #     params=[axis-1,mode])[2]
    return request(device,:ecu,"setRefractiveIndexCompensationMode";
        params=[-1,mode])[2]
end
