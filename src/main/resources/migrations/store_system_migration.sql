-- Store System Migration Script
-- Fixes all issues identified in the code review

-- 1. Add store_id FK to products table
ALTER TABLE products 
  ADD COLUMN IF NOT EXISTS store_id INT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Backfill store_id from store_username
UPDATE products p
  JOIN users u ON p.store_username = u.username
  JOIN stores s ON u.user_id = s.user_id
SET p.store_id = s.store_id
WHERE p.store_id IS NULL;

ALTER TABLE products
  ADD CONSTRAINT IF NOT EXISTS fk_products_store FOREIGN KEY (store_id) REFERENCES stores(store_id) ON DELETE SET NULL;

-- 2. Add store_id and separate name columns to orders table
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS store_id INT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS first_name VARCHAR(100) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS last_name VARCHAR(100) DEFAULT NULL;

-- Backfill store_id from store_username
UPDATE orders o
  JOIN users u ON o.store_username = u.username
  JOIN stores s ON u.user_id = s.user_id
SET o.store_id = s.store_id
WHERE o.store_id IS NULL;

-- Backfill first_name/last_name from customer_name
UPDATE orders SET
  first_name = TRIM(SUBSTRING_INDEX(customer_name, ' ', 1)),
  last_name = TRIM(SUBSTRING(customer_name, INSTR(customer_name, ' ') + 1))
WHERE first_name IS NULL AND customer_name IS NOT NULL AND INSTR(customer_name, ' ') > 0;

UPDATE orders SET first_name = customer_name WHERE first_name IS NULL AND customer_name IS NOT NULL;

ALTER TABLE orders
  ADD CONSTRAINT IF NOT EXISTS fk_orders_store FOREIGN KEY (store_id) REFERENCES stores(store_id) ON DELETE SET NULL;

-- 3. Add store_id to discounts table
ALTER TABLE discounts
  ADD COLUMN IF NOT EXISTS store_id INT DEFAULT NULL;

UPDATE discounts d
  JOIN users u ON d.store_username = u.username
  JOIN stores s ON u.user_id = s.user_id
SET d.store_id = s.store_id
WHERE d.store_id IS NULL;

ALTER TABLE discounts
  ADD CONSTRAINT IF NOT EXISTS fk_discounts_store FOREIGN KEY (store_id) REFERENCES stores(store_id) ON DELETE CASCADE;

-- 4. Create drivers table
CREATE TABLE IF NOT EXISTS drivers (
  driver_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  license_number VARCHAR(50),
  license_pic LONGBLOB,
  service_area VARCHAR(255),
  real_pic LONGBLOB,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 5. Create delivery_assignments table
CREATE TABLE IF NOT EXISTS delivery_assignments (
  assignment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id VARCHAR(50) NOT NULL,
  driver_id INT NOT NULL,
  store_id INT NOT NULL,
  vehicle_type VARCHAR(50),
  status ENUM('ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED') DEFAULT 'ASSIGNED',
  notes TEXT,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  picked_up_at TIMESTAMP NULL,
  delivered_at TIMESTAMP NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (driver_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (store_id) REFERENCES stores(store_id) ON DELETE CASCADE
);

-- 6. Add discount_products and discount_variants tables if not exist
CREATE TABLE IF NOT EXISTS discount_products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  discount_id INT NOT NULL,
  product_id INT NOT NULL,
  UNIQUE KEY uq_discount_product (discount_id, product_id),
  FOREIGN KEY (discount_id) REFERENCES discounts(discount_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS discount_variants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  discount_id INT NOT NULL,
  variant_id INT NOT NULL,
  UNIQUE KEY uq_discount_variant (discount_id, variant_id),
  FOREIGN KEY (discount_id) REFERENCES discounts(discount_id) ON DELETE CASCADE,
  FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id) ON DELETE CASCADE
);
