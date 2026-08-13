-- ============================================================
-- MTNC GITHUB UPDATE ANALYZER
-- ============================================================
Updates = Updates or {}

function Updates.Check()
    local repo = "mtcore-novacore/mtnc-adminpanel"
    local localVersion = Config.Version or "3.0.1"

    PerformHttpRequest("https://api.github.com/repos/" .. repo .. "/releases/latest", function(statusCode, responseText, headers)
        if statusCode == 200 then
            local data = json.decode(responseText)
            local latestTag = data.tag_name or data.name or localVersion
            local isNewer = latestTag ~= localVersion

            Updates.Latest = {
                installed = localVersion,
                latest = latestTag,
                hasUpdate = isNewer,
                body = data.body or "Ny opdatering tilgængelig på GitHub."
            }
        else
            Updates.Latest = {
                installed = localVersion,
                latest = localVersion,
                hasUpdate = false,
                body = "Systemet er fuldt opdateret til version " .. localVersion
            }
        end
    end, "GET", "", { ["User-Agent"] = "MTNC-AdminTablet-v3.0.1" })
end

CreateThread(function()
    Wait(5000)
    Updates.Check()
end)

RegisterNetEvent('mtnc:server:getUpdates', function()
    local src = source
    TriggerClientEvent('mtnc:client:receiveUpdates', src, Updates.Latest or {
        installed = Config.Version,
        latest = Config.Version,
        hasUpdate = false
    })
end)
