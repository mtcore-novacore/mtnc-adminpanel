Config = Config or {}

-- ============================================================
-- INTEGRATION SETTINGS
-- ============================================================
-- Auto-detection is enabled by default. If auto-detection fails,
-- the adapter falls back safely without crashing.

Config.Integrations = {
    Framework = 'auto', -- 'auto', 'qbcore', 'qbox', 'esx', 'vrp', or 'standalone'
    Phone = 'lb-phone',  -- 'lb-phone', 'qb-phone', 'qs-smartphone', or 'standalone'
    Housing = 'auto',    -- 'auto', 'qb-housing', 'esx_property', 'loaf_housing', 'none'
    Vehicles = 'auto',   -- 'auto', 'qb-garages', 'cd_garage', 'jg-advancedgarages', 'esx_garage'
    Multijob = 'auto'    -- 'auto', 'qb-multijob', 'ps-multijob', 'esx_multijob', 'standalone'
}
