-- --------------------------------------------------------------------------
-- 自动化初始化脚本 (测试数据 - 功能开关)
-- 此脚本用于插入特定于测试场景的功能开关数据。
-- --------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS `test` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `test`;

-- 创建一个用于功能开关的示例表
CREATE TABLE IF NOT EXISTS `feature_flags` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL UNIQUE,
  `is_enabled` BOOLEAN NOT NULL DEFAULT FALSE,
  `description` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  
-- 插入一些模拟的功能开关
INSERT INTO `feature_flags` (`name`, `is_enabled`, `description`) VALUES
('new-dashboard', TRUE, 'Enables the new v2 dashboard for all users.'),
('dark-mode', FALSE, 'User-selectable dark mode theme.'),
('real-time-chat', TRUE, 'Enables the new real-time chat feature via WebSockets.'); 