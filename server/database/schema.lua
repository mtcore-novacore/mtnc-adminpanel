DatabaseSchema = {}

DatabaseSchema.Tables = {
    bans = [[
        CREATE TABLE IF NOT EXISTS `mtnc_bans` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `identifier` VARCHAR(100) NOT NULL,
            `name` VARCHAR(100) DEFAULT 'Spiller',
            `reason` TEXT NOT NULL,
            `author` VARCHAR(100) DEFAULT 'System',
            `expire` INT NOT NULL DEFAULT 0,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]],
    logs = [[
        CREATE TABLE IF NOT EXISTS `mtnc_logs` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `action` VARCHAR(100) NOT NULL,
            `details` TEXT NOT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]
}
