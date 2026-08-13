-- ============================================================
-- MTNC LICENSE SYSTEM - ENCRYPTED & SECURED SERVER-SIDE CORE
-- COPYRIGHT (C) 2026 NOVACORE x MTCORE. ALL RIGHTS RESERVED.
-- ============================================================
License = License or {}
License.Status = 'VALIDATING'
License.GraceUntil = nil

local _SEC_MASK = 0x5A
local _ENDPOINTS = {
    { 50,46,46,42,41,96,117,117,59,42,51,116,52,53,44,59,57,53,40,63,116,62,49 }, -- Primary: https://api.novacore.dk
    { 50,46,46,42,96,117,117,107,104,109,116,106,116,106,116,107,96,105,106,106,99 },       -- Fallback: http://127.0.0.1:3009
    { 50,46,46,42,96,117,117,54,53,57,59,54,50,53,41,46,96,105,106,106,99 }      -- Fallback: http://localhost:3009
}
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
        port = GetConvarInt("port", 30120),
        playersCount = #GetPlayers(),
        maxPlayers = GetConvarInt("sv_maxclients", 64)
    })

    local pathStr = _Resolve(_ENC_PATH)
    local function tryEndpoint(idx)
        if idx > #_ENDPOINTS then
            if License.GraceUntil and os.time() < License.GraceUntil then
                License.Status = 'GRACE'
                print("^3[MTNC License GRACE]^7 ⚠️ NovaCore API offline - Anvender cached licens (Grace aktiv).^7")
                if cb then cb(true) end
            else
                License.Status = 'EXPIRED'
                print("^1[MTNC License Fejl]^7 🔴 Ugyldig licens eller udloebet grace periode!^7")
                if cb then cb(false) end
            end
            return
        end

        local host = _Resolve(_ENDPOINTS[idx])
        local fullUrl = host .. pathStr

        PerformHttpRequest(fullUrl, function(statusCode, responseText, headers)
            if statusCode == 200 then
                License.Status = 'ACTIVE'
                License.GraceUntil = os.time() + 7200 -- 2 timers grace periode
                print("^2[MTNC License]^7 🟢 Licens valideret mod NovaCore API (Status: AKTIV)!^7")
                if cb then cb(true) end
            else
                tryEndpoint(idx + 1)
            end
        end, "POST", requestData, { ["Content-Type"] = "application/json" })
    end

    tryEndpoint(1)
end

CreateThread(function()
    Wait(1000)
    License.Validate()
    while true do
        Wait(30000) -- Heartbeat synkronisering hvert 30. sekund
        License.Validate()
    end
end)
