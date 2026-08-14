-- ============================================================
-- MTNC ADAPTER - ESX
-- ============================================================
FrameworkAdapter = FrameworkAdapter or {}

local ESX = nil
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
end

function FrameworkAdapter.IsESX()
    return ESX ~= nil
end

function FrameworkAdapter.GetESXPlayer(src)
    if not ESX then return nil end
    return ESX.GetPlayerFromId(src)
end
