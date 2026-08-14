-- ============================================================
-- MTNC PHONE SECURITY & PIN RESET REQUESTS
-- ============================================================
PhoneSecurity = PhoneSecurity or {}

local pendingRequests = {}
local userCooldowns = {}

RegisterNetEvent('mtnc:server:requestPinReset', function(reason)
    local src = source
    if not Security.RateLimit(src) then return end

    local now = os.time()
    if userCooldowns[src] and (now - userCooldowns[src]) < Config.PhonePinResetCooldown then
        TriggerClientEvent('mtnc:client:toast', src, '⚠️ Du har allerede en aktiv anmodning eller cooldown.', 'warning')
        return
    end

    local phone = PhoneAdapter.GetPhoneNumber(src) or ('+45 ' .. tostring(math.random(10000000, 99999999)))
    local reqId = #pendingRequests + 1

    local req = {
        id = reqId,
        src = src,
        name = FrameworkAdapter.GetCharacterName(src),
        phone = phone,
        reason = reason or 'Glemt PIN-kode',
        status = 'PENDING',
        time = os.date('%H:%M')
    }

    table.insert(pendingRequests, 1, req)
    userCooldowns[src] = now

    TriggerClientEvent('mtnc:client:toast', src, '🟢 Din anmodning om PIN-nulstilling er sendt til Staff!', 'success')
    Audit.Log('PHONE_PIN_REQUEST', src, nil, { reason = reason, phone = phone })
end)

RegisterNetEvent('mtnc:server:getPinRequests', function()
    local src = source
    if not Permissions.HasPermission(src, 'admin.phone.pin_reset') then return end
    TriggerClientEvent('mtnc:client:receivePinRequests', src, pendingRequests)
end)

RegisterNetEvent('mtnc:server:handlePinRequest', function(reqId, approve)
    local src = source
    if not Permissions.HasPermission(src, 'admin.phone.pin_reset') then return end

    for _, r in ipairs(pendingRequests) do
        if r.id == reqId and r.status == 'PENDING' then
            r.status = approve and 'APPROVED' or 'DENIED'
            if approve then
                PhoneAdapter.ResetPin(r.src)
                TriggerClientEvent('mtnc:client:toast', r.src, '🔐 Din telefon PIN-kode er blevet nulstillet af Staff.', 'success')
                Audit.Log('PHONE_PIN_APPROVED', src, r.src, { reqId = reqId })
            else
                TriggerClientEvent('mtnc:client:toast', r.src, '❌ Din anmodning om PIN-nulstilling blev afvist.', 'error')
                Audit.Log('PHONE_PIN_DENIED', src, r.src, { reqId = reqId })
            end
            break
        end
    end

    TriggerClientEvent('mtnc:client:receivePinRequests', src, pendingRequests)
end)
