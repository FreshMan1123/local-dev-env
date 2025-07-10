-- --------------------------------------------------------------------------
-- 自动化初始化脚本 (插入基础数据)
-- 此文件将在 01_schema.sql 之后按字母顺序执行。
-- --------------------------------------------------------------------------

USE `init`;

-- 插入一些模拟用户数据
INSERT INTO `users` (`username`, `email`) VALUES
('alice', 'alice@example.com'),
('bob', 'bob@example.com'),
('charlie', 'charlie@example.com');

-- 插入一些模拟产品数据
INSERT INTO `products` (`name`, `description`, `price`, `stock`) VALUES
('Laptop', 'A powerful and lightweight laptop for professionals.', 1200.00, 50),
('Smartphone', 'The latest smartphone with an amazing camera.', 800.00, 150),
('Wireless Headphones', 'Noise-cancelling headphones with superior sound quality.', 250.00, 300),
('Smart Watch', 'Track your fitness and stay connected.', 350.00, 200); 