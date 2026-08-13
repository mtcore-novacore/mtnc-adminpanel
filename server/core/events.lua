--[[
  MTNC AdminPanel V3 — Open Custom Events & Exports Gateway
  Denne fil er 100% ÅBEN (escrow_ignore).
  Du kan frit tilføje dine egne custom server events, exports fra 3. parts skripter,
  triggers og integrationer her uden at påvirke licens- eller sikkerhedssystemet.
--]]

Events = {}

-- ── DINE CUSTOM EVENTS & EXPORTS LÆGGES NEDENFOR ──

RegisterNetEvent("mtnc:customServerEvent", function(data)
    local src = source
    print(("[MTNC-CUSTOM] Event modtaget fra spiller %s"):format(GetPlayerName(src)))
end)

exports('CustomMTNCAction', function(action, data)
    print(("[MTNC-EXPORT] Custom action udført: %s"):format(tostring(action)))
    return true
end)
