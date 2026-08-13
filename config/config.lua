Config = Config or {}

-- ============================================================
-- MTNC TABLET OS CONFIGURATION
-- ============================================================
Config.Version = '3.0.1'
Config.Locale = 'da' -- 'da' or 'en'

-- Keybinds & Tablet Controls
Config.OpenKey = 'F10'           -- Default Open Tablet Key
Config.OpenCommand = 'tablet'    -- Command to toggle tablet
Config.AdminCommand = 'admin'    -- Quick command for staff to jump to Admin app
Config.UseAnimation = true       -- Play tablet prop & holding animation
Config.TabletProp = 'prop_cs_tablet' -- In-game prop model

-- Performance & Diagnostics
Config.Debug = false
Config.MaxReportsPerUser = 3
Config.PhonePinResetCooldown = 1800 -- 30 minutes in seconds

-- Sound Effects (NUI audio feedback)
Config.Sounds = {
    open = true,
    close = true,
    click = true,
    notification = true,
    cameraShutter = true
}

-- Default Desktop Wallpaper
Config.DefaultWallpaper = 'gradient_dark'
