-- ──────────────────────────────────────────────────────
--  MTNC Admin Panel — Server Logs Proxy
--  Hent hændelses-logs direkte fra backend API :3009
--  og send til in-game NUI viewer
-- ──────────────────────────────────────────────────────

RegisterNetEvent("mtnc:requestLogs")
AddEventHandler("mtnc:requestLogs", function(data)
    local src = source
    if not _G.MTNCHasAccess(src) then return end

    local limit = data and data.limit or 50
    local api   = _G.MTNCInternalApi or { url = "http://127.0.0.1:3009", token = "token-admin-secret-2026" }

    PerformHttpRequest(
        string.format("%s/api/logs?limit=%d", api.url, limit),
        function(statusCode, responseText, _)
            if statusCode == 200 and responseText then
                local decoded = json.decode(responseText)
                if decoded and decoded.logs then
                    TriggerClientEvent("mtnc:logsResult", src, decoded.logs)
                end
            else
                if Config.general.debug then
                    print(("[mtnc-logs] Failed to fetch logs from API. Code: %d"):format(statusCode or 0))
                end
                TriggerClientEvent("mtnc:logsResult", src, {})
            end
        end,
        "GET",
        "",
        {
            ["Authorization"] = "Bearer " .. api.token,
            ["Content-Type"]  = "application/json"
        }
    )
end)
