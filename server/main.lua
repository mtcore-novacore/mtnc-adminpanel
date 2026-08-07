--[[
  ███╗   ███╗████████╗███╗   ██╗ ██████╗
  ████╗ ████║╚══██╔══╝████╗  ██║██╔════╝
  ██╔████╔██║   ██║   ██╔██╗ ██║██║
  ██║╚██╔╝██║   ██║   ██║╚██╗██║██║
  ██║ ╚═╝ ██║   ██║   ██║ ╚████║╚██████╗
  ╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝

  MTNC Admin Panel — FiveM Server Engine v2.5.0
  Modular Multi-Port & DDoS Shield Connected
--]]

local _API_HOST = "https://api.novacore.dk"
local _LOCAL_FALLBACK_HOST = "http://127.0.0.1:3009"
local _ADMIN_PANEL_DOMAIN = "https://adminpanel.novacore.dk"
local _API_BEARER = "Bearer token-admin-secret-2026"

local isLicenseValid = false
local currentServerId = nil
local adminPanelUrl = nil

-- ── DEDIKERET SERVER-SIDE HANDSHAKE FUNKTION ────────────
function RequestServerData(action, payload, cb)
    local endpointMap = {
        validateLicense = "/api/license/validate",
        registerServer  = "/api/servers/register",
        syncPlayers     = "/api/servers/players",
        supportRequest  = "/api/support/request",
        auditLog        = "/api/logs",
        metrics         = "/api/metrics",
        ddosStatus      = "/api/ddos/status",
    }

    local path = endpointMap[action] or ("/api/" .. action)
    local url  = _API_HOST .. path
    local postBody = payload and json.encode(payload) or "{}"
    local timestamp = os.time()

    local headers = {
        ["Content-Type"]        = "application/json",
        ["Authorization"]       = _API_BEARER,
        ["X-MTNC-Node-Action"]  = action,
        ["X-MTNC-Timestamp"]    = tostring(timestamp),
        ["X-MTNC-License"]      = _G.LicenseKey or Config.licenseKey or "",
    }

    PerformHttpRequest(
        url,
        function(statusCode, responseText, _)
            if statusCode >= 200 and statusCode < 300 and responseText then
                local data = json.decode(responseText)
                if cb then cb(true, data, statusCode) end
            else
                -- Fallback to local host if tunnel is in local dev mode
                PerformHttpRequest(
                    _LOCAL_FALLBACK_HOST .. path,
                    function(fallbackCode, fallbackText, _)
                        if fallbackCode >= 200 and fallbackCode < 300 and fallbackText then
                            local data = json.decode(fallbackText)
                            if cb then cb(true, data, fallbackCode) end
                        else
                            if cb then cb(false, nil, statusCode or fallbackCode) end
                        end
                    end,
                    payload and "POST" or "GET",
                    postBody,
                    headers
                )
            end
        end,
        payload and "POST" or "GET",
        postBody,
        headers
    )
end

_G.RequestServerData = RequestServerData

-- ── VALIDER LICENS OG REGISTRER SERVER NODE ───────────
local function validateAndRegisterServer(cb)
    local key = _G.LicenseKey or Config.licenseKey or ""

    if key == "" then
        print("^1[MTNC-ADMIN] ❌ INGEN LICENSNØGLE FUNDET I LICENSEKEY.LUA!^7")
        isLicenseValid = false
        if cb then cb(false) end
        return
    end

    RequestServerData("validateLicense", { licenseKey = key }, function(success, data, code)
        if success and data and data.valid then
            isLicenseValid = true

            local serverName = GetConvar("sv_hostname", "FiveM Main Server")
            RequestServerData("registerServer", {
                licenseKey = key,
                name       = serverName,
                ip         = "127.0.0.1",
                port       = GetConvarInt("port", 30120),
                maxPlayers = GetConvarInt("sv_maxclients", 64),
            }, function(regOk, regData)
                if regOk and regData and regData.server then
                    currentServerId = regData.server.id
                    adminPanelUrl   = string.format("%s/%s", _ADMIN_PANEL_DOMAIN, currentServerId)

                    print("^2=========================================================^7")
                    print(string.format("^2[MTNC-ADMIN] ✅ SERVER NODE ANALYSERET OG FORBUNDET!^7"))
                    print(string.format("^2[MTNC-ADMIN] 🌐 DEDIKERET ADMIN PANEL:^7 ^3%s^7", adminPanelUrl))
                    print(string.format("^2[MTNC-ADMIN] 🔑 LICENS TIER: %s | KUNDE: %s^7", data.license.tier, data.license.issuedTo))
                    print(string.format("^2[MTNC-ADMIN] 🛡️ DDOS SHIELD: AKTIVT & OVERVÅGER^7"))
                    print("^2=========================================================^7")
                end
            end)

            if cb then cb(true) end
        else
            isLicenseValid = false
            print(string.format("^1[MTNC-ADMIN] ❌ LICENS AFVIST: %s (HTTP %d)^7", data and data.reason or "Ugyldig", code or 0))
            if cb then cb(false) end
        end
    end)
end

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("^3[MTNC-ADMIN] Læser licensekey.lua og forbinder til NovaCore Gateway...^7")
    validateAndRegisterServer()
end)

-- ── SEND SOS HJÆLPEANMODNING TIL SUPERADMIN ────────────
RegisterCommand("sos", function(src, args, raw)
    local msg = table.concat(args, " ")
    if msg == "" then
        print("^1Brug: /sos [beskrivelse af hvad der driller]^7")
        return
    end

    local sender = (src > 0) and GetPlayerName(src) or "Server Console"
    RequestServerData("supportRequest", {
        nodeId         = currentServerId or "node_fivem_server",
        serverName     = GetConvar("sv_hostname", "FiveM Node"),
        senderUsername = sender,
        category       = "FiveM In-Game SOS",
        priority       = "🚨 KRITISK SOS",
        subject        = "Hjælp anmodet via in-game /sos",
        message        = msg,
    }, function(ok, data)
        if ok then
            print(string.format("^2[MTNC-ADMIN] 🚨 SOS anmodning sendt direkte til SuperAdmin på MTCore! (ID: %s)^7", data.ticket and data.ticket.id or "-"))
        else
            print("^1[MTNC-ADMIN] Kunne ikke sende SOS anmodning til MTCore.^7")
        end
    end)
end, true)

-- ── PERIODISK SYNKRONISERING AF LIVE SPILLERE ──────────
CreateThread(function()
    while true do
        Wait(15000)
        if isLicenseValid and currentServerId then
            local players = {}
            for _, pid in ipairs(GetPlayers()) do
                table.insert(players, {
                    id   = pid,
                    name = GetPlayerName(pid),
                    ping = GetPlayerPing(pid),
                })
            end

            RequestServerData("syncPlayers", {
                serverId = currentServerId,
                count    = #players,
                players  = players,
            })
        end
    end
end)

-- ── PERMISSION CHECK ──────────────────────────────────
local function hasAccess(src)
    if not isLicenseValid then return false end
    if Config.permissions and Config.permissions.allowAll then return true end

    -- Ace permissions
    if IsPlayerAceAllowed(tostring(src), Config.permissions.acePermission or "mtnc.admin") then
        return true
    end

    -- Framework check (ESX / QBCore)
    if Config.framework == "esx" and GetResourceState("es_extended") == "started" then
        local xPlayer = exports["es_extended"]:getPlayerFromId(src)
        if xPlayer then
            local group = xPlayer.getGroup and xPlayer.getGroup() or nil
            for _, allowed in ipairs(Config.permissions.esxGroups or {}) do
                if group == allowed then return true end
            end
        end
    end

    return false
end

-- ── ÅBN ADMIN NUI MENU ────────────────────────────────
RegisterNetEvent("mtnc:server:requestOpen", function()
    local src = source
    if hasAccess(src) then
        TriggerClientEvent("mtnc:client:openMenu", src, {
            serverName = GetConvar("sv_hostname", "FiveM Node"),
            panelUrl   = adminPanelUrl or _ADMIN_PANEL_DOMAIN,
            nodeId     = currentServerId,
        })
    else
        TriggerClientEvent("chat:addMessage", src, {
            color = { 255, 50, 50 },
            args  = { "MTNC", "Du har ikke tilladelse til at åbne admin panelet." }
        })
    end
end)
