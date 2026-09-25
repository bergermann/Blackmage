
"""
    getSystemError(sd::SingleDevice)

Return IDS error if one is present on single device `sd`.
"""
function getSystemError(sd::SingleDevice)
    return getSystemError(sd.ids)
end

"""
    resetError(sd::SingleDevice)

Attempt to reset IDS error if one is present on single device `sd`.
"""
function resetError(sd::SingleDevice)
    return resetError(sd.ids)
end



"""
    resetAxes(sd::SingleDevice)

Re-zero relative values of all IDS axes at their current positions for single device `sd`.
"""
function resetAxes(sd::SingleDevice)
    resetAxes(sd.ids); return
end

"""
    resetAxes(md::MultiDevice)

Re-zero relative values of all IDS axes at their current positions for all devices in
multidevice `md`.
"""
function resetAxes(md::MultiDevice)
    for device in md
        resetAxes(device)
    end; return
end



"""
    getMasterAxis(sd::SingleDevice)

Return current IDS master axis of single device `sd`.
"""
function getMasterAxis(sd::SingleDevice)
    return getMasterAxis(sd.ids)
end

"""
    setMasterAxis(sd::SingleDevice,axis)

Set IDS master `axis` of single device `sd`.
"""
function setMasterAxis(sd::SingleDevice,axis::Int)
    setMasterAxis(sd.ids,axis); return
end
