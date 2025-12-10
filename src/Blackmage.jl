
__precompile__(true)

"""
    Blackmage

Control interface for combined Attocube IDS system and JPE CADM4/FCM2 motor controllers.
"""
module Blackmage

using Sockets, Dates, JSON, Statistics, Plots
export now, connect

include("socketing.jl")
include("IDS/IDS.jl")
include("MC/MC.jl")

include("MD/MC/motor_control.jl")

end