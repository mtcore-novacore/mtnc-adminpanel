PunishmentsManager = {}

function PunishmentsManager.Ban(targetId, reason, duration, author)
    local id = CoreUtils.GetPlayerIdentifier(targetId, "steam") or tostring(targetId)
    DropPlayer(tostring(targetId), ("Banned: %s"):format(reason))
    return true
end
