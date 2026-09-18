


"""
    getHumidityM(device::D,axis::Int)

Return manually set ECU humidity in percent.
"""
function getHumidityM(device::D,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,:ecum,"getHumidityInPercent";
    #     params=[axis-1])[2]
    return request(device,:ecum,"getHumidityInPercent";
        params=[-1])[2]
end

"""
    setHumidityM(device::D,axis::Int,humidity::Float64)

Manually set ECU humidity in percent.
"""
function setHumidityM(device::D,axis::Int,humidity::Float64)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # request(device,:ecum,"setHumidityInPercent";
    #     params=[axis-1,humidity]); return
    request(device,:ecum,"setHumidityInPercent";
        params=[-1,humidity]); return
end



"""
    getPressureM(device::D,axis::Int)

Return manually set ECU pressure in hPa.
"""
function getPressureM(device::D,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,:ecum,"getPressureInHPa";
    #     params=[axis-1])[2]
    return request(device,:ecum,"getPressureInHPa";
        params=[-1])[2]
end

"""
    setPressureM(device::D,axis::Int,pressure::Float64)

Manually set ECU pressure in hPa.
"""
function setPressureM(device::D,axis::Int,pressure::Float64)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # request(device,:ecum,"setPressureInHPa";
    #     params=[axis-1,pressure]); return
    request(device,:ecum,"setPressureInHPa";
        params=[-1,pressure]); return
end



"""
    getTemperatureM(device::D,axis::Int)

Return manually set ECU temperature in °C.
"""
function getTemperatureM(device::D,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,:ecum,"getTemperatureInDegrees";
    #     params=[axis-1])[2]
    return request(device,:ecum,"getTemperatureInDegrees";
        params=[-1])[2]
end

"""
    setTemperatureM(device::D,axis::Int,temp::Float64)

Manually set ECU temperature in °C.
"""
function setTemperatureM(device::D,axis::Int,temp::Float64)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # request(device,:ecum,"setPressureInHPa";
    #     params=[axis-1,temp]); return
    request(device,:ecum,"setPressureInHPa";
        params=[-1,temp]); return
end



"""
    getRefractiveIndexM(device::D,axis::Int)

Return manually set ECU refractive index.
"""
function getRefractiveIndexM(device::D,axis::Int)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # return request(device,:ecum,"getRefractiveIndex";
    #     params=[axis-1])[2]
    return request(device,:ecum,"getRefractiveIndex";
        params=[-1])[2]
end

"""
    setRefractiveIndexM(device::D,axis::Int,index::Float64)

Manually set ECU refractive index.
"""
function setRefractiveIndexM(device::D,axis::Int,index::Float64)
    # @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."
    @assert axis == -1 "Only axis = -1 is supported in current version, subject to change."

    @warn "This function is subject to change from suppliers side.
        Check manual if only axis = -1 is still supported."
    
    # request(device,:ecum,"setRefractiveIndex";
    #     params=[axis-1,index]); return
    request(device,:ecum,"setRefractiveIndex";
        params=[-1,index]); return
end

