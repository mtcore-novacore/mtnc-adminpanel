ESXBridge = {}

function ESXBridge.Init()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        return true
    end
    return false
end

function ESXBridge.GetPlayer(src)
    if not ESX then return nil end
    return ESX.GetPlayerFromId(src)
end
