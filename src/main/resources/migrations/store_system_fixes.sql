-- =============================================================
-- Daily Fixer Store System — Migration Script
-- Applies all schema fixes from the issue analysis document.
-- Run against your existing df_test_t (or production) database.
-- Each block is idempotent where possible (uses IF NOT EXISTS /
-- column-existence checks via INFORMATION_SCHEMA).
-- =============================================================

-- ---------------------------------------------------------------
-- 1.1 Add store_id FK to products (replaces reliance on store_username)
-- ---------------------------------------------------------------
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'products'
      AND COLUMN_NAME  = 'store_id'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `store_id` INT NULL AFTER `store_username`',
    'SELECT ''products.store_id already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Backfill store_id from store_username via users -> stores join
UPDATE `products` p
    JOIN `users`  u ON p.store_username = u.username
    JOIN `stores` s ON u.user_id        = s.user_id
SET p.store_id = s.store_id
WHERE p.store_id IS NULL;

-- Add FK constraint (skip if it already exists)
SET @fk_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA   = DATABASE()
      AND TABLE_NAME     = 'products'
      AND CONSTRAINT_NAME = 'fk_products_store'
);
SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `products` ADD CONSTRAINT `fk_products_store` FOREIGN KEY (`store_id`) REFERENCES `stores`(`store_id`) ON DELETE SET NULL',
    'SELECT ''fk_products_store already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------
-- 1.2 Add store_id FK to orders (mirrors order_items.store_id)
-- ---------------------------------------------------------------
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'orders'
      AND COLUMN_NAME  = 'store_id'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `orders` ADD COLUMN `store_id` INT NULL AFTER `store_username`',
    'SELECT ''orders.store_id already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Backfill store_id from store_username
UPDATE `orders` o
    JOIN `users`  u ON o.store_username = u.username
    JOIN `stores` s ON u.user_id        = s.user_id
SET o.store_id = s.store_id
WHERE o.store_id IS NULL;

-- Add FK constraint
SET @fk_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA    = DATABASE()
      AND TABLE_NAME      = 'orders'
      AND CONSTRAINT_NAME = 'fk_orders_store'
);
SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `orders` ADD CONSTRAINT `fk_orders_store` FOREIGN KEY (`store_id`) REFERENCES `stores`(`store_id`) ON DELETE SET NULL',
    'SELECT ''fk_orders_store already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------
-- 1.3 Split customer_name into first_name + last_name in orders
-- ---------------------------------------------------------------
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'orders'
      AND COLUMN_NAME  = 'first_name'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `orders` ADD COLUMN `first_name` VARCHAR(100) NULL AFTER `customer_name`, ADD COLUMN `last_name` VARCHAR(100) NULL AFTER `first_name`',
    'SELECT ''orders.first_name already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Backfill first_name / last_name from customer_name
UPDATE `orders`
SET first_name = TRIM(SUBSTRING_INDEX(customer_name, ' ', 1)),
    last_name  = TRIM(SUBSTRING(customer_name, LOCATE(' ', customer_name) + 1))
WHERE first_name IS NULL AND customer_name IS NOT NULL AND LOCATE(' ', customer_name) > 0;

UPDATE `orders`
SET first_name = customer_name,
    last_name  = ''
WHERE first_name IS NULL AND customer_name IS NOT NULL;

-- ---------------------------------------------------------------
-- 2.3 Add is_active flag to products (draft/published support)
-- ---------------------------------------------------------------
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'products'
      AND COLUMN_NAME  = 'is_active'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `is_active` TINYINT(1) NOT NULL DEFAULT 1 AFTER `description`',
    'SELECT ''products.is_active already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------
-- 2.4 Add created_at / updated_at timestamps to products
-- ---------------------------------------------------------------
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'products'
      AND COLUMN_NAME  = 'created_at'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, ADD COLUMN `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP',
    'SELECT ''products timestamps already exist''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------
-- 2.6 product_categories table (replaces free-text type in products)
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `product_categories` (
    `category_id`   INT          NOT NULL AUTO_INCREMENT,
    `name`          VARCHAR(100) NOT NULL,
    `description`   TEXT,
    `created_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`category_id`),
    UNIQUE KEY `uq_category_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Seed existing categories from products table (case-normalised)
INSERT IGNORE INTO `product_categories` (`name`)
SELECT DISTINCT TRIM(type) FROM `products` WHERE type IS NOT NULL AND TRIM(type) != '';

-- ---------------------------------------------------------------
-- 5.1 Fix discounts: add store_id FK (mirrors products fix)
-- ---------------------------------------------------------------
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'discounts'
      AND COLUMN_NAME  = 'store_id'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `discounts` ADD COLUMN `store_id` INT NULL AFTER `store_username`',
    'SELECT ''discounts.store_id already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Backfill store_id
UPDATE `discounts` d
    JOIN `users`  u ON d.store_username = u.username
    JOIN `stores` s ON u.user_id        = s.user_id
SET d.store_id = s.store_id
WHERE d.store_id IS NULL;

-- Add FK constraint
SET @fk_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA    = DATABASE()
      AND TABLE_NAME      = 'discounts'
      AND CONSTRAINT_NAME = 'fk_discounts_store'
);
SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `discounts` ADD CONSTRAINT `fk_discounts_store` FOREIGN KEY (`store_id`) REFERENCES `stores`(`store_id`) ON DELETE CASCADE',
    'SELECT ''fk_discounts_store already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------
-- 6.1 delivery_assignments table (driver-order assignment system)
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `delivery_assignments` (
    `assignment_id` INT          NOT NULL AUTO_INCREMENT,
    `order_id`      VARCHAR(50)  NOT NULL,
    `driver_id`     INT          NOT NULL,
    `store_id`      INT          NOT NULL,
    `status`        ENUM('ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED')
                                 NOT NULL DEFAULT 'ASSIGNED',
    `assigned_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `delivered_at`  TIMESTAMP    NULL,
    PRIMARY KEY (`assignment_id`),
    CONSTRAINT `fk_da_order`  FOREIGN KEY (`order_id`)  REFERENCES `orders`(`order_id`)  ON DELETE CASCADE,
    CONSTRAINT `fk_da_driver` FOREIGN KEY (`driver_id`) REFERENCES `users`(`user_id`)    ON DELETE CASCADE,
    CONSTRAINT `fk_da_store`  FOREIGN KEY (`store_id`)  REFERENCES `stores`(`store_id`)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------
-- 6.2 drivers table (stores driver-specific info separate from vehicles)
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `drivers` (
    `driver_id`    INT          NOT NULL AUTO_INCREMENT,
    `user_id`      INT          NOT NULL,
    `license_pic`  LONGBLOB,
    `real_pic`     LONGBLOB,
    `service_area` VARCHAR(200),
    `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`driver_id`),
    UNIQUE KEY `uq_driver_user` (`user_id`),
    CONSTRAINT `fk_drivers_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------
-- End of migration
-- ---------------------------------------------------------------
