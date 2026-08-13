-- ============================================================
-- MTNC AUDIT LOGGING SYSTEM (NO SECRETS RECORDED)
-- ============================================================
Audit = Audit or {}

function Audit.Log(action, staffSrc, targetSrc, details)
    local staffName = staffSrc and (staffSrc == 0 and 'CONSOLE' or GetPlayerName(staffSrc)) or 'SYSTEM'
    local targetName = targetSrc and GetPlayerName(targetSrc) or 'N/A'
    local entry = string.format("[%s] ACTION: %s | STAFF: %s (%s) | TARGET: %s (%s) | DETAILS: %s",
        os.date('%Y-%m-%d %H:%M:%S'),
        action or 'UNKNOWN',
        staffName, tostring(staffSrc),
        targetName, tostring(targetSrc),
        json.encode(details or {})
    )
    print("^3[MTNC AUDIT]^7 " .. entry)
    SaveResourceFile(GetCurrentResourceName(), "data/system/audit.log", entry .. "\n", -1)
end
