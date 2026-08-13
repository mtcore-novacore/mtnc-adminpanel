Config = Config or {}

-- ============================================================
-- STAFF ROLES & PERMISSIONS
-- ============================================================
Config.StaffRoles = {
    ['superadmin'] = {
        label = 'Høj Staff (Ledelse / Ejer)',
        level = 100,
        permissions = {
            'admin.access',
            'admin.players.view',
            'admin.players.kick',
            'admin.players.warn',
            'admin.players.ban',
            'admin.players.freeze',
            'admin.players.teleport',
            'admin.players.spectate',
            'admin.reports.manage',
            'admin.phone.pin_reset',
            'admin.vehicles.spawn',
            'admin.vehicles.delete',
            'admin.world.weather',
            'admin.world.time',
            'admin.server.resources',
            'admin.audit.view',
            'admin.diagnostics.view'
        }
    },
    ['admin'] = {
        label = 'Administrator',
        level = 80,
        permissions = {
            'admin.access',
            'admin.players.view',
            'admin.players.kick',
            'admin.players.warn',
            'admin.players.freeze',
            'admin.players.teleport',
            'admin.players.spectate',
            'admin.reports.manage',
            'admin.phone.pin_reset',
            'admin.vehicles.spawn',
            'admin.world.weather',
            'admin.audit.view'
        }
    },
    ['moderator'] = {
        label = 'Moderator / Support',
        level = 50,
        permissions = {
            'admin.access',
            'admin.players.view',
            'admin.players.kick',
            'admin.players.warn',
            'admin.players.freeze',
            'admin.players.teleport',
            'admin.reports.manage'
        }
    }
}
