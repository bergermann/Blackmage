
export getHumidityM, setHumidityM
export getPressureM, setPressureM
export getTemperatureM, setTemperatureM
export getRefractiveIndexM, setRefractiveIndexM



"""
    getHumidityM(device::D,req::Dict,axis::Int)

Return manually set ECU humidity in percent.
"""
function getHumidityM(device::D,req::Dict,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,req,:ecum,"getHumidityInPercent";
    #     params=[axis-1])[2]
    return request(device,req,:ecum,"getHumidityInPercent";
        params=[-1])[2]
end

"""
    setHumidityM(device::D,req::Dict,axis::Int,humidity::Float64)

Manually set ECU humidity in percent.
"""
function setHumidityM(device::D,req::Dict,axis::Int,humidity::Float64)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # request(device,req,:ecum,"setHumidityInPercent";
    #     params=[axis-1,humidity]); return
    request(device,req,:ecum,"setHumidityInPercent";
        params=[-1,humidity]); return
end



"""
    getPressureM(device::D,req::Dict,axis::Int)

Return manually set ECU pressure in hPa.
"""
function getPressureM(device::D,req::Dict,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,req,:ecum,"getPressureInHPa";
    #     params=[axis-1])[2]
    return request(device,req,:ecum,"getPressureInHPa";
        params=[-1])[2]
end

"""
    setPressureM(device::D,req::Dict,axis::Int,pressure::Float64)

Manually set ECU pressure in hPa.
"""
function setPressureM(device::D,req::Dict,axis::Int,pressure::Float64)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # request(device,req,:ecum,"setPressureInHPa";
    #     params=[axis-1,pressure]); return
    request(device,req,:ecum,"setPressureInHPa";
        params=[-1,pressure]); return
end



"""
    getTemperatureM(device::D,req::Dict,axis::Int)

Return manually set ECU temperature in °C.
"""
function getTemperatureM(device::D,req::Dict,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,req,:ecum,"getTemperatureInDegrees";
    #     params=[axis-1])[2]
    return request(device,req,:ecum,"getTemperatureInDegrees";
        params=[-1])[2]
end

"""
    setTemperatureM(device::D,req::Dict,axis::Int,temp::Float64)

Manually set ECU temperature in °C.
"""
function setTemperatureM(device::D,req::Dict,axis::Int,temp::Float64)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # request(device,req,:ecum,"setPressureInHPa";
    #     params=[axis-1,temp]); return
    request(device,req,:ecum,"setPressureInHPa";
        params=[-1,temp]); return
end



"""
    getRefractiveIndexM(device::D,req::Dict,axis::Int)

Return manually set ECU refractive index.
"""
function getRefractiveIndexM(device::D,req::Dict,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,req,:ecum,"getRefractiveIndex";
    #     params=[axis-1])[2]
    return request(device,req,:ecum,"getRefractiveIndex";
        params=[-1])[2]
end

"""
    setRefractiveIndexM(device::D,req::Dict,axis::Int,index::Float64)

Manually set ECU refractive index.
"""
function setRefractiveIndexM(device::D,req::Dict,axis::Int,index::Float64)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # request(device,req,:ecum,"setRefractiveIndex";
    #     params=[axis-1,index]); return
    request(device,req,:ecum,"setRefractiveIndex";
        params=[-1,index]); return
end

