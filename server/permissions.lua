-- ============================================================
-- MTNC PERMISSION SYSTEM (LIVE SERVER-SIDE VALIDATION)
-- ============================================================
Permissions = Permissions or {}

function Permissions.GetPlayerRole(src)
    if src == 0 then return 'superadmin' end
    
    if IsPlayerAceAllowed(src, 'command') or IsPlayerAceAllowed(src, 'admin') then
        return 'superadmin'
    end

    if FrameworkAdapter.IsQBCore() then
        local p = FrameworkAdapter.GetPlayer(src)
        if p and p.PlayerData and p.PlayerData.permissions then
            if p.PlayerData.permissions['god'] or p.PlayerData.permissions['admin'] then
                return 'superadmin'
            elseif p.PlayerData.permissions['mod'] then
                return 'moderator'
            end
        end
    end

    return 'user'
end

function Permissions.HasPermission(src, perm)
    if src == 0 then return true end
    local role = Permissions.GetPlayerRole(src)
    local roleConfig = Config.StaffRoles[role]
    if not roleConfig then return false end

    for _, p in ipairs(roleConfig.permissions) do
        if p == perm or p == 'admin.access' and perm == 'admin.access' then
            return true
        end
    end
    return false
end
