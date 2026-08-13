QBoxBridge = {}

function QBoxBridge.Init()
    return GetResourceState('qbx_core') == 'started'
end
