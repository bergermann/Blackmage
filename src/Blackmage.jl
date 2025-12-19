
__precompile__(true)

"""
    Blackmage

Control interface for combined Attocube IDS system and JPE CADM4/FCM2 motor controllers.
"""
module Blackmage

export units

using Sockets, Dates, JSON, Statistics, Plots
export connect, TCPSocket, now, @ip_str

export Displacement, req    # IDS

export getAlignmentEnabled, startAlignment, stopAlignment, getContrast  # adjustment

export enableECU, disableECU    # ECU
export getECUEnabled, getECUConnected
export getHumidity, getPressure, getTemperature, getRefractiveIndex

export getHumidityM, setHumidityM   # manual
export getPressureM, setPressureM
export getTemperatureM, setTemperatureM
export getRefractiveIndexM, setRefractiveIndexM

export getMeasurementEnabled, startMeasurement, stopMeasurement # measurement
export getAbsolutePosition, getAbsolutePositions
export getAxisDisplacement, getAxesDisplacement
export getReferencePosition, getReferencePositions
export getAxisSignalQuality, getAxesSignalQuality

export enablePL, disablePL  # pilot

export getCurrentMode, getDeviceType    # system
export getSystemError, resetError
export getInitMode, setInitMode
export resetAxis, resetAxes
export getMasterAxis, setMasterAxis
export getPassMode, setPassMode

export record!, stop_record!, measurePos    # record
export plot



export metric2ids   # MC
export mcVersion

export mcVersion, mcMods, mcModuleSlot, mcStages    # MC system
export mcGetIP, mcSetIP

export mcMove, mcStop, mcStopAllMotors  # MC OL

export mcEnableFCM, mcDisableFCM, mcSetupFCM, mcReSetupFCM, mcStopAll   # MC CL
export mcTargetFCM, mcWaitForTarget, mcStatusFCM, mcTargetP
export autoAlign

export mcTarget, mcMoveDirect   # MC FL



export MultiDevice  # multidevice



include("socketing.jl")
include("IDS/IDS.jl")
include("MC/MC.jl")
include("MD/multidevice.jl")

end

# to fix:
# targetP, targetP_abs, direct target doc
# add axes(device,axis) functions