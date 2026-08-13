QBCoreBridge = {}

function QBCoreBridge.Init()
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        return true
    end
    return false
end

function QBCoreBridge.GetPlayer(src)
    if not QBCore then return nil end
    return QBCore.Functions.GetPlayer(src)
end
