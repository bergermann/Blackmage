
__precompile__(true)

"""
    Blackmage

Control interface for combined Attocube IDS system and JPE CADM4/FCM2 motor controllers.
"""
module Blackmage

using Sockets, Dates, JSON, Statistics, Plots
export now, connect, @ip_str

include("socketing.jl")
include("IDS/IDS.jl")
include("MC/MC.jl")
include("multidevice.jl")

end