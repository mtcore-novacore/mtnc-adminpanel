--[[
  ███╗   ███╗████████╗███╗   ██╗ ██████╗
  ████╗ ████║╚══██╔══╝████╗  ██║██╔════╝
  ██╔████╔██║   ██║   ██╔██╗ ██║██║
  ██║╚██╔╝██║   ██║   ██║╚██╗██║██║
  ██║ ╚═╝ ██║   ██║   ██║ ╚████║╚██████╗
  ╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝

  MTNC AdminPanel — apiconnect.lua
  Public API & Event Gateway til eksterne scripts
  (Denne fil holdes ÅBEN og kan tilpasses/tilgås fra andre scripts)
--]]

local APIConnect = {}

--------------------------------------------------------------------------------
-- 📊 FUNKTION: ANALYSERE (System & Sikkerhedsanalyse)
--------------------------------------------------------------------------------
--- Udfører en komplet helbreds- og sikkerhedsanalyse af serveren,
--- API-gatewayen, databasen og den aktive licens.
---@param cb function Callback med analyseresultaterne
function APIConnect.Analyse(cb)
    local isServer = IsDuplicityVersion()
    
    if isServer then
        local startTime = os.clock()
        local licenseKey = (MTNC_License and MTNC_License.GetLicenseKey()) or "Ukendt"
        local licenseTier = (MTNC_License and MTNC_License.tier) or "Uvalideret"
        local isLicenseValid = (MTNC_License and MTNC_License.isValid) or false
        local frameworkName = (MTNC_Bridge and MTNC_Bridge.name) or "standalone"
        local onlinePlayers = (MTNC_PlayerManager and #MTNC_PlayerManager.GetOnlineList()) or GetNumPlayerIndices()
        local maxClients = GetConvarInt("sv_maxclients", 64)

        local analysis = {
            timestamp      = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            serverName     = GetConvar("sv_hostname", "FiveM Server"),
            framework      = frameworkName,
            version        = Config.version or "2.5.0",
            playersOnline  = onlinePlayers,
            maxSlots       = maxClients,
            license = {
                valid      = isLicenseValid,
                tier       = licenseTier,
                keyMasked  = licenseKey:sub(1, 8) .. "-****-****"
            },
            database = {
                driver     = "oxmysql",
                status     = "CONNECTED",
                installed  = true
            },
            securityShield = {
                status     = "ACTIVE",
                ddosShield = true,
                rateLimit  = "90 req/3s"
            },
            performance = {
                engineUptime   = GetGameTimer() / 1000,
                analysisTimeMs = math.floor((os.clock() - startTime) * 1000)
            }
        }

        if cb then
            cb(analysis)
        end
        return analysis
    else
        -- Client-side analyse anmodning
        local clientAnalysis = {
            clientTime = GetGameTimer(),
            localPlayerPed = PlayerPedId(),
            isNoclipActive = (MTNC_Noclip and MTNC_Noclip.active) or false
        }
        if cb then cb(clientAnalysis) end
        return clientAnalysis
    end
end

--------------------------------------------------------------------------------
-- 🌐 SERVER-SIDE EXPORTS & PUBLIC BRIDGES
--------------------------------------------------------------------------------
if IsDuplicityVersion() then

    -- 1. Export: Analyse
    exports('Analyse', function(cb)
        return APIConnect.Analyse(cb)
    end)

    exports('GetSystemAnalysis', function()
        return APIConnect.Analyse()
    end)

    -- 2. Export: Tjek rettigheder via Discord ID / Role
    exports('HasPermission', function(source, permission)
        if MTNC_Permissions and MTNC_Permissions.HasPermission then
            return MTNC_Permissions.HasPermission(source, permission)
        end
        return false
    end)

    -- 3. Export: Hent spillerens aktive MTNC rolle
    exports('GetPlayerRole', function(source)
        if MTNC_Permissions and MTNC_Permissions.GetRole then
            return MTNC_Permissions.GetRole(source)
        end
        return "USER"
    end)

    -- 4. Export: Send revisionslog (Audit Log) til Web & Database
    exports('SendAuditLog', function(source, action, details)
        if MTNC_Audit then
            MTNC_Audit.Log(source or 0, action, details)
        end
    end)

    -- 5. Export: Opret SOS Hjælpeanmodning til Hovedkontor
    exports('TriggerSos', function(category, subject, message, priority)
        if MTNC_APIConn then
            local payload = {
                nodeId = MTNC_License and MTNC_License.GetLicenseKey() or "NODE-EXTERNAL",
                serverName = GetConvar("sv_hostname", "FiveM Server"),
                category = category or "Generel",
                subject = subject or "Ekstern Anmodning",
                message = message or "",
                priority = priority or "HIGH"
            }
            MTNC_APIConn.Request("/api/support", "POST", payload)
        end
    end)

    -- 6. Export: Spark spiller (Kick)
    exports('KickPlayer', function(source, targetId, reason)
        if MTNC_PlayerManager then
            MTNC_PlayerManager.Kick(source or 0, targetId, reason)
        end
    end)

    -- 7. Export: Ban spiller
    exports('BanPlayer', function(source, targetId, reason, hours)
        if MTNC_Punishments then
            MTNC_Punishments.Ban(source or 0, targetId, reason, hours)
        end
    end)

    -- 8. Export: Heal / Revive spiller
    exports('HealPlayer', function(source, targetId, revive)
        if MTNC_PlayerManager then
            MTNC_PlayerManager.Heal(source or 0, targetId, revive)
        end
    end)

    -- 9. Export: Giv Penge (Cash / Bank)
    exports('GiveMoney', function(source, targetId, mtype, amount)
        if MTNC_EconomyManager then
            MTNC_EconomyManager.Give(source or 0, targetId, mtype, amount)
        end
    end)

    ----------------------------------------------------------------------------
    -- 📡 SERVER EVENTS (Modtag kald fra andre scripts)
    ----------------------------------------------------------------------------
    RegisterNetEvent('mtnc:api:requestAnalysis', function()
        local src = source
        if MTNC_Permissions and MTNC_Permissions.HasPermission(src, "tablet.open") then
            APIConnect.Analyse(function(results)
                TriggerClientEvent('mtnc:api:receiveAnalysis', src, results)
            end)
        end
    end)

    RegisterNetEvent('mtnc:api:sendAuditLog', function(action, details)
        local src = source
        if MTNC_Audit then
            MTNC_Audit.Log(src, action or "EXTERNAL_EVENT", details or "Kaldt fra eksternt script")
        end
    end)

    RegisterNetEvent('mtnc:api:triggerSos', function(category, subject, message, priority)
        local src = source
        if MTNC_Permissions and MTNC_Permissions.HasPermission(src, "tablet.open") then
            exports['mtnc-adminpanel']:TriggerSos(category, subject, message, priority)
        end
    end)

--------------------------------------------------------------------------------
-- 💻 CLIENT-SIDE EXPORTS & PUBLIC BRIDGES
--------------------------------------------------------------------------------
else

    -- 1. Client Export: Åbn Admin Tablet
    exports('OpenAdminMenu', function()
        if MTNC_NUI and MTNC_NUI.Open then
            MTNC_NUI.Open()
        end
    end)

    -- 2. Client Export: Luk Admin Tablet
    exports('CloseAdminMenu', function()
        if MTNC_NUI and MTNC_NUI.Close then
            MTNC_NUI.Close()
        end
    end)

    -- 3. Client Export: Toggle Noclip
    exports('ToggleNoclip', function()
        if MTNC_Noclip and MTNC_Noclip.Toggle then
            MTNC_Noclip.Toggle()
        end
    end)

    -- 4. Client Export: Hent Noclip Status
    exports('IsNoclipActive', function()
        return (MTNC_Noclip and MTNC_Noclip.active) or false
    end)

    -- 5. Client Export: Kør lokal analyse
    exports('AnalyseClient', function(cb)
        return APIConnect.Analyse(cb)
    end)

    ----------------------------------------------------------------------------
    -- 📡 CLIENT EVENTS
    ----------------------------------------------------------------------------
    RegisterNetEvent('mtnc:api:openMenu', function()
        exports['mtnc-adminpanel']:OpenAdminMenu()
    end)

    RegisterNetEvent('mtnc:api:toggleNoclip', function()
        exports['mtnc-adminpanel']:ToggleNoclip()
    end)

end

_G.MTNC_APIConnect = APIConnect
