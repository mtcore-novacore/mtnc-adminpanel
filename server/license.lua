-- ============================================================
-- MTNC LICENSE SYSTEM - ENCRYPTED & SECURED SERVER-SIDE CORE
-- COPYRIGHT (C) 2026 NOVACORE x MTCORE. ALL RIGHTS RESERVED.
-- ============================================================
License = License or {}
License.Status = 'VALIDATING'
License.GraceUntil = nil

local _SEC_MASK = 0x5A
local _ENDPOINT = { 50,46,46,42,41,96,117,117,59,42,51,116,52,53,44,59,57,53,40,63,116,62,49 } -- https://api.novacore.dk (Cloud HTTPS)
local _ENC_PATH = { 117,59,42,51,117,41,63,40,44,63,40,41 }

local function _Resolve(bytes)
    local chars = {}
    for i = 1, #bytes do
        chars[i] = string.char(bytes[i] ~ _SEC_MASK)
    end
    return table.concat(chars)
end

function License.Validate(cb)
    local key = MTNC_LICENSE_KEY
    if not key or key == "" then
        License.Status = 'INVALID'
        print("^1[MTNC License]^7 ❌ Ingen licensnoegle konfigureret i licensekey.lua!^7")
        if cb then cb(false) end
        return
    end

    local serverName = GetConvar("sv_hostname", "FiveM Server")
    local requestData = json.encode({
        licenseKey = key,
        name = serverName,
        playersCount = #GetPlayers(),
        maxPlayers = GetConvarInt("sv_maxclients", 64)
    })

    local fullUrl = _Resolve(_ENDPOINT) .. _Resolve(_ENC_PATH)

    PerformHttpRequest(fullUrl, function(statusCode, responseText, headers)
        if statusCode == 200 then
            License.Status = 'ACTIVE'
            License.GraceUntil = os.time() + 7200 -- 2 timers grace periode
            if not _G.MTNC_LICENSE_ANNOUNCED then
                _G.MTNC_LICENSE_ANNOUNCED = true
                print("^2[MTNC License]^7 🟢 Licens valideret mod NovaCore Cloud (Status: AKTIV)!^7")
            end
            if cb then cb(true) end
        else
            if License.GraceUntil and os.time() < License.GraceUntil then
                License.Status = 'GRACE'
                if not _G.MTNC_GRACE_ANNOUNCED then
                    _G.MTNC_GRACE_ANNOUNCED = true
                    print("^3[MTNC License GRACE]^7 ⚠️ NovaCore Cloud offline - Anvender cached licens (Grace aktiv).^7")
                end
                if cb then cb(true) end
            else
                License.Status = 'EXPIRED'
                print("^1[MTNC License Fejl]^7 🔴 Ugyldig licens eller udloebet grace periode!^7")
                if cb then cb(false) end
            end
        end
    end, "POST", requestData, { ["Content-Type"] = "application/json" })
end

CreateThread(function()
    Wait(1000)
    License.Validate()
    while true do
        Wait(120000) -- Lydløs baggrunds-heartbeat hvert 2. minut
        License.Validate()
    end
end)
