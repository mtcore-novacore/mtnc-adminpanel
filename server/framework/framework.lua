Framework = {}
Framework.Type = "STANDALONE"

function Framework.Detect()
    if Config.framework ~= "auto" then
        Framework.Type = string.upper(Config.framework)
        return Framework.Type
    end

    if GetResourceState('qb-core') == 'started' then
        Framework.Type = "QBCORE"
    elseif GetResourceState('qbx_core') == 'started' then
        Framework.Type = "QBOX"
    elseif GetResourceState('es_extended') == 'started' then
        Framework.Type = "ESX"
    elseif GetResourceState('vrp') == 'started' then
        Framework.Type = "VRP"
    else
        Framework.Type = "STANDALONE"
    end

    return Framework.Type
end
