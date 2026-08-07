CREATE TABLE IF NOT EXISTS `mtnc_admin_logs` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `admin_name` VARCHAR(100) DEFAULT NULL,
  `admin_steam` VARCHAR(100) DEFAULT NULL,
  `action` VARCHAR(100) DEFAULT NULL,
  `target` VARCHAR(100) DEFAULT NULL,
  `message` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mtnc_admin_settings` (
  `key` VARCHAR(100) NOT NULL,
  `value` TEXT DEFAULT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mtnc_admin_roles` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `permissions` TEXT DEFAULT NULL,
  `is_default` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mtnc_admin_users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) DEFAULT NULL,
  `steam` VARCHAR(100) NOT NULL,
  `role` VARCHAR(100) NOT NULL DEFAULT 'moderator',
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `steam` (`steam`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `mtnc_admin_roles` (`name`, `permissions`, `is_default`) VALUES
  ('superadmin', '{"all":true}', 0),
  ('admin', '{"player":true,"vehicle":true,"world":true,"staff":true}', 0),
  ('moderator', '{"player":{"ban":false,"kick":true,"mute":true,"warn":true},"vehicle":false,"world":false,"staff":false}', 1)
ON DUPLICATE KEY UPDATE `permissions` = VALUES(`permissions`);

INSERT INTO `mtnc_admin_settings` (`key`, `value`) VALUES
  ('panel_title', 'NovaCore Admin Panel'),
  ('allow_steam_access', 'true')
ON DUPLICATE KEY UPDATE `value` = VALUES(`value`);
