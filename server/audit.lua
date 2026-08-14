-- ============================================================
-- MTNC AUDIT LOGGING SYSTEM (DATABASE BACKED + IN-GAME VIEWER)
-- ============================================================
Audit = Audit or {}

function Audit.Log(action, staffSrc, targetSrc, details)
    local staffName = staffSrc and (staffSrc == 0 and 'CONSOLE' or GetPlayerName(staffSrc)) or 'SYSTEM'
    local staffId = staffSrc or 0
    local targetId = targetSrc or 0
    local detailsJson = json.encode(details or {})

    -- Print to console
    local entry = string.format("[%s] ACTION: %s | STAFF: %s (%s) | TARGET: %s | DETAILS: %s",
        os.date('%Y-%m-%d %H:%M:%S'),
        action or 'UNKNOWN',
        staffName, tostring(staffId),
        tostring(targetId),
        detailsJson
    )
    print("^3[MTNC AUDIT]^7 " .. entry)

    -- Save to Database
    DB.Query([[
        INSERT INTO mtnc_audit_logs (staff_id, staff_name, target_id, action, details)
        VALUES (?, ?, ?, ?, ?)
    ]], { staffId, staffName, targetId, action or 'UNKNOWN', detailsJson })
end

RegisterNetEvent('mtnc:server:getAuditLogs', function()
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    local logs = DB.Query('SELECT * FROM mtnc_audit_logs ORDER BY id DESC LIMIT 150') or {}
    TriggerClientEvent('mtnc:client:receiveAuditLogs', src, logs)
end)

RegisterNetEvent('mtnc:server:clearAuditLogs', function()
    local src = source
    if Permissions.GetPlayerRole(src) ~= 'superadmin' then
        TriggerClientEvent('mtnc:client:notify', src, '❌ Kun Høj Staff (Superadmin) kan rydde revisionsloggen!', 'error')
        return
    end

    DB.Query('TRUNCATE TABLE mtnc_audit_logs')
    TriggerClientEvent('mtnc:client:notify', src, '🧹 Revisionsloggen (Audit) er ryddet!', 'info')
    
    local logs = DB.Query('SELECT * FROM mtnc_audit_logs ORDER BY id DESC LIMIT 150') or {}
    TriggerClientEvent('mtnc:client:receiveAuditLogs', src, logs)
end)
