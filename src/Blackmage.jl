
__precompile__(true)

"""
    Blackmage

Control interface for combined Attocube IDS system and JPE CADM4/FCM2 motor controllers.
"""
module Blackmage

export units

using Sockets, Dates, JSON, Statistics, Plots
export connect, TCPSocket, now, @ip_str

include("socketing.jl")
include("IDS/IDS.jl")
include("MC/MC.jl")
include("multidevice.jl")

end

# to fix:
# exports
# targetP doc