


"""
    tilt2pos(xtilt::Real,ytilt::Real; α::Real=0, r::Real=0.15)

Return necessary motor shifts to achieve kartesian tilts `xtilt` and 'ytilt' (in degrees).
`α` is the structural angle of the respective motor 1 (in degrees). Radius `r` (in m) denotes
distance of interferometers from central axis.
"""
function tilt2pos(xtilt::Real,ytilt::Real; α::Real=0,r::Real=0.15)
    !(0 <= α <= 360) && @warn "Angle α not between 0° and 360°, double check!"

    α = deg2rad(α)
    δ, θ = kart2cyl(xtilt,ytilt)

    return tilt2pos_(δ,θ,0.,α,r), tilt2pos_(δ,θ,2π/3,α,r), tilt2pos_(δ,θ,4π/3,α,r)
end

"""
    tilt2pos_(δ::Real,θ::Real,dα::Real,α::Real=0,r::Real=0.15)

Return single motor shift to achieve kartesian tilts `δ` and 'θ' (in rad). `dα`is the
additional angle with respect to motor 1 (in rad). `α` is the structural angle of the
respective motor 1 (in rad). Radius `r` (in m) denotes distance of interferometers
from central axis.
"""
function tilt2pos_(δ::Real,θ::Real,dα::Real,α::Real=0,r::Real=0.15)
    x_ = cos(α+dα); y_ = sin(α+dα)

    x =  x_*cos(δ)*cos(θ) + y_*cos(δ)*sin(θ)
    y = -x_*sin(θ)        + y_*cos(θ) 
    z = -x_*sin(δ)*cos(θ) - y_*sin(δ)*sin(θ)

    return z*r/sqrt(x^2+y^2)
end



"""
    pos2tilt(z::Union{Vector{<:Real},NTuple{3}}; α::Real=0, r::Real=0.15)

Return position of disc center and kartesian tilts (in degrees) for motor positions `z`
(in m). `α` is the structural angle of the respective motor 1 (in degres). Radius `r`
(in m) denotes distance of interferometers from central axis.
"""
function pos2tilt(z::Union{Vector{<:Real},NTuple{3}}; α::Real=0,r::Real=0.15)
    @assert length(z) == 3 "Exactly three values required in z."

    α = deg2rad(α)
    z0 = sum(z)/3

    n1 =   r*((z[2]-z0)*sin(α)      - (z[1]-z0)*sin(α+2π/3))
    n2 =   r*((z[1]-z0)*cos(α+2π/3) - (z[2]-z0)*cos(α))
    n3 = r^2*(cos(α)*sin(α+2π/3)    - sin(α)*cos(α+2π/3))
    n_ = sqrt(n1^2+n2^2+n3^2)

    return z0, rad2deg(asin(n1/n_)), rad2deg(asin(n2/n_))
end

"""
    kart2cyl(xtilt::Real,ytilt::Real)

Convert kartesian tilts `xtilt`, `ytilt` (in degrees) to cylindrical tilts (in rad).
"""
function kart2cyl(xtilt::Real,ytilt::Real)
    x = sin(deg2rad(xtilt)); y = sin(deg2rad(ytilt))

    return asin(sqrt(x^2+y^2)), atan(y,x)
end

"""
    cyl2kart(δ::Real,θ::Real)

Convert cylindrical tilts `δ` `θ` (in rad) to kartesian tilts (in degrees).
"""
function cyl2kart(δ::Real,θ::Real)
    return rad2deg(asin(sin(δ)*cos(θ))), rad2deg(asin(sin(δ)*sin(θ)))
end



