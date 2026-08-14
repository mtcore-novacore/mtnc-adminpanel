-- ============================================================
-- MTNC ADMIN TABLET v3.0.2 - MASTER DATABASE SCHEMA
-- COPYRIGHT (C) 2026 NOVACORE x MTCORE (MrWolfDk & MrGuld)
-- ============================================================

-- 1. MTNC Staff Medlemmer & Rettigheder
CREATE TABLE IF NOT EXISTS `mtnc_staff_members` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(100) NOT NULL COMMENT 'license, discord eller citizenid',
  `name` VARCHAR(100) NOT NULL DEFAULT 'Staff Medlem',
  `rank` VARCHAR(50) NOT NULL DEFAULT 'moderator' COMMENT 'superadmin, admin, moderator, support',
  `added_by` VARCHAR(100) DEFAULT 'System',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. MTNC Revisionslog (Audit Trail)
CREATE TABLE IF NOT EXISTS `mtnc_audit_logs` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `staff_id` INT(11) DEFAULT 0,
  `staff_name` VARCHAR(100) DEFAULT 'Staff',
  `target_id` INT(11) DEFAULT 0,
  `action` VARCHAR(50) NOT NULL,
  `details` LONGTEXT DEFAULT NULL,
  `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. MTNC Rapporter & Sager
CREATE TABLE IF NOT EXISTS `mtnc_reports` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `sender_id` INT(11) NOT NULL,
  `sender_name` VARCHAR(100) NOT NULL,
  `type` VARCHAR(50) NOT NULL DEFAULT 'Hjælp',
  `message` TEXT NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'open' COMMENT 'open, claimed, resolved',
  `claimed_by` VARCHAR(100) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. MTNC Telefon PIN Nulstillingskø (LB Phone)
CREATE TABLE IF NOT EXISTS `mtnc_phone_pin_requests` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `src` INT(11) NOT NULL,
  `citizenid` VARCHAR(50) NOT NULL,
  `phone_number` VARCHAR(20) DEFAULT NULL,
  `reason` TEXT DEFAULT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending, approved, rejected',
  `reviewed_by` VARCHAR(100) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. MTNC Billeder & Snapshot Galleri
CREATE TABLE IF NOT EXISTS `mtnc_photos` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `image_url` LONGTEXT NOT NULL,
  `location` VARCHAR(100) DEFAULT 'Los Santos',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. MTNC Bans & Udelukkelser
CREATE TABLE IF NOT EXISTS `mtnc_bans` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `license` VARCHAR(100) NOT NULL,
  `discord` VARCHAR(100) DEFAULT NULL,
  `name` VARCHAR(100) DEFAULT 'Spiller',
  `reason` TEXT NOT NULL,
  `banned_by` VARCHAR(100) NOT NULL,
  `expire_at` TIMESTAMP NULL DEFAULT NULL,
  `permanent` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. MTNC Advarsler (Warnings)
CREATE TABLE IF NOT EXISTS `mtnc_warnings` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `license` VARCHAR(100) DEFAULT NULL,
  `reason` TEXT NOT NULL,
  `warned_by` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Standard Multijob Kompatibilitet (user_jobs)
CREATE TABLE IF NOT EXISTS `user_jobs` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `job` VARCHAR(50) NOT NULL,
  `job_label` VARCHAR(50) DEFAULT NULL,
  `grade` INT(11) NOT NULL DEFAULT 0,
  `grade_label` VARCHAR(50) DEFAULT 'Medarbejder',
  `salary` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Indsæt Ejer / Hovedadministrator som standard
INSERT INTO `mtnc_staff_members` (`identifier`, `name`, `rank`, `added_by`)
VALUES 
  ('fivem:4866650', 'MrWolf_dk', 'superadmin', 'System Master'),
  ('discord:737367235315630132', 'MrWolf_dk', 'superadmin', 'System Master')
ON DUPLICATE KEY UPDATE `rank` = 'superadmin';
