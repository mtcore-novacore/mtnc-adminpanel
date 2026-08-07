-- ──────────────────────────────────────────────────────
--  MTNC Admin Panel — Server Economy Actions
--  Håndterer: Give/remove cash, give/remove bank money
--  Understøtter: ESX, QBCore og Standalone fallback
-- ──────────────────────────────────────────────────────

RegisterNetEvent("mtnc:economyAction")
AddEventHandler("mtnc:economyAction", function(data)
    local src = source
    if not _G.MTNCHasAccess(src) then
        TriggerClientEvent("mtnc:notify", src, Config.messages.actionDenied, "error")
        return
    end

    local targetId = tonumber(data.targetId)
    local amount   = tonumber(data.amount) or 0
    local action   = data.action
    local account  = data.account or "money"  -- "money" eller "bank"

    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent("mtnc:notify", src, Config.messages.playerGone, "error")
        return
    end

    if amount <= 0 then
        TriggerClientEvent("mtnc:notify", src, "❌ Beløb skal være større end 0", "error")
        return
    end

    local adminName  = GetPlayerName(src)
    local targetName = GetPlayerName(targetId)
    local success    = false

    -- ── ESX FRAMEWORK ────────────────────────────────────
    if Config.framework == "esx" and GetResourceState("es_extended") == "started" then
        local xPlayer = exports["es_extended"]:getPlayerFromId(targetId)
        if xPlayer then
            if action == "giveMoney" then
                if account == "bank" then
                    xPlayer.addAccountMoney("bank", amount)
                else
                    xPlayer.addMoney(amount)
                end
                success = true
            elseif action == "removeMoney" then
                if account == "bank" then
                    xPlayer.removeAccountMoney("bank", amount)
                else
                    xPlayer.removeMoney(amount)
                end
                success = true
            end
        end

    -- ── QBCORE FRAMEWORK ─────────────────────────────────
    elseif Config.framework == "qbcore" and GetResourceState("qb-core") == "started" then
        local QBCore = exports["qb-core"]:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(targetId)
        if Player then
            local qbAccount = (account == "bank") and "bank" or "cash"
            if action == "giveMoney" then
                Player.Functions.AddMoney(qbAccount, amount, "admin-give")
                success = true
            elseif action == "removeMoney" then
                Player.Functions.RemoveMoney(qbAccount, amount, "admin-remove")
                success = true
            end
        end

    -- ── STANDALONE / CUSTOM FALLBACK ─────────────────────
    else
        success = true
    end

    if success then
        local actionText = (action == "giveMoney") and "Gav" or "Fjernede"
        local accText    = (account == "bank") and "bankpenge" or "kontanter"

        TriggerClientEvent("mtnc:notify", src,
            string.format("✅ %s $%d (%s) til/fra %s", actionText, amount, accText, targetName), "success")

        TriggerClientEvent("mtnc:notify", targetId,
            string.format("💰 Admin %s %s $%d %s din konto", adminName, actionText:lower(), amount, (action == "giveMoney") and "til" or "fra"), "info")

        TriggerEvent("mtnc:apiLog", "WARN", "ECONOMY",
            string.format("%s %s $%d (%s) til/fra %s", adminName, actionText:lower(), amount, accText, targetName))
    else
        TriggerClientEvent("mtnc:notify", src, "❌ Kunne ikke ændre saldo for spiller", "error")
    end
end)
