VRPBridge = {}

function VRPBridge.Init()
    return GetResourceState('vrp') == 'started'
end
