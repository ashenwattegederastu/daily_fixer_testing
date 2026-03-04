package com.dailyfixer.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Test-specific database connection utility that uses H2 in-memory database.
 * This mimics the production DBConnection but points to H2 instead of MySQL.
 */
public class TestDBConnection {

        private static final String URL = "jdbc:h2:mem:dailyfixer_test;DB_CLOSE_DELAY=-1;MODE=MySQL";
        private static final String USER = "sa";
        private static final String PASS = "";

        private static final AtomicBoolean schemaInitialized = new AtomicBoolean(false);

        /**
         * Get a connection to the H2 test database.
         * Initializes the schema on first call.
         */
        public static Connection getConnection() throws SQLException, ClassNotFoundException {
                Class.forName("org.h2.Driver");
                Connection conn = DriverManager.getConnection(URL, USER, PASS);

                // Initialize schema on first connection (thread-safe)
                if (schemaInitialized.compareAndSet(false, true)) {
                        initializeSchema(conn);
                }

                return conn;
        }

        /**
         * Initialize the test database schema.
         * Creates tables needed for tests.
         */
        private static void initializeSchema(Connection conn) throws SQLException {
                try (Statement stmt = conn.createStatement()) {
                        // Users table
                        stmt.execute("CREATE TABLE IF NOT EXISTS users (" +
                                        "user_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "first_name VARCHAR(100), " +
                                        "last_name VARCHAR(100), " +
                                        "username VARCHAR(50) UNIQUE NOT NULL, " +
                                        "email VARCHAR(100) UNIQUE NOT NULL, " +
                                        "password VARCHAR(255) NOT NULL, " +
                                        "phone_number VARCHAR(20), " +
                                        "city VARCHAR(100), " +
                                        "role VARCHAR(20) DEFAULT 'user', " +
                                        "status VARCHAR(20) DEFAULT 'active'" +
                                        ")");

                        // Services table
                        stmt.execute("CREATE TABLE IF NOT EXISTS services (" +
                                        "service_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "technician_id INT NOT NULL, " +
                                        "service_name VARCHAR(200) NOT NULL, " +
                                        "description TEXT, " +
                                        "category VARCHAR(100), " +
                                        "pricing_type VARCHAR(50), " +
                                        "fixed_rate DECIMAL(10,2), " +
                                        "hourly_rate DECIMAL(10,2), " +
                                        "inspection_charge DECIMAL(10,2), " +
                                        "transport_charge DECIMAL(10,2), " +
                                        "available_dates TEXT, " +
                                        "service_image BLOB, " +
                                        "image_type VARCHAR(50)" +
                                        ")");

                        // Stores table
                        stmt.execute("CREATE TABLE IF NOT EXISTS stores (" +
                                        "store_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "user_id INT NOT NULL, " +
                                        "store_name VARCHAR(200) NOT NULL, " +
                                        "store_address TEXT, " +
                                        "store_city VARCHAR(100), " +
                                        "store_type VARCHAR(50), " +
                                        "latitude DOUBLE, " +
                                        "longitude DOUBLE" +
                                        ")");

                        // Products table
                        stmt.execute("CREATE TABLE IF NOT EXISTS products (" +
                                        "product_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "store_id INT, " +
                                        "name VARCHAR(200) NOT NULL, " +
                                        "type VARCHAR(100), " +
                                        "quantity INT, " +
                                        "quantity_unit VARCHAR(20), " +
                                        "price DECIMAL(10,2), " +
                                        "image BLOB, " +
                                        "store_username VARCHAR(50), " +
                                        "description TEXT" +
                                        ")");

                        // Discounts table
                        stmt.execute("CREATE TABLE IF NOT EXISTS discounts (" +
                                        "discount_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "discount_name VARCHAR(200), " +
                                        "discount_type VARCHAR(50), " +
                                        "discount_value DECIMAL(10,2), " +
                                        "start_date TIMESTAMP, " +
                                        "end_date TIMESTAMP, " +
                                        "store_username VARCHAR(50), " +
                                        "is_active BOOLEAN DEFAULT true" +
                                        ")");

                        // Reviews table
                        stmt.execute("CREATE TABLE IF NOT EXISTS product_reviews (" +
                                        "review_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "product_id INT NOT NULL, " +
                                        "user_id INT NOT NULL, " +
                                        "rating INT NOT NULL, " +
                                        "comment TEXT, " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");

                        // Vehicles table
                        stmt.execute("CREATE TABLE IF NOT EXISTS vehicles (" +
                                        "id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "driver_id INT NOT NULL, " +
                                        "vehicle_type VARCHAR(50), " +
                                        "brand VARCHAR(100), " +
                                        "model VARCHAR(100), " +
                                        "plate_number VARCHAR(20), " +
                                        "picture BLOB, " +
                                        "fare_first_km DECIMAL(10,2), " +
                                        "fare_next_km DECIMAL(10,2)" +
                                        ")");

                        // Password reset tokens table
                        stmt.execute("CREATE TABLE IF NOT EXISTS password_reset_tokens (" +
                                        "id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "user_id INT NOT NULL, " +
                                        "token VARCHAR(255) NOT NULL UNIQUE, " +
                                        "expiry TIMESTAMP NOT NULL, " +
                                        "used BOOLEAN DEFAULT false" +
                                        ")");

                        // Guide categories table
                        stmt.execute("CREATE TABLE IF NOT EXISTS guide_categories (" +
                                        "category_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "name VARCHAR(200) NOT NULL, " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");

                        // Guide sub-categories table
                        stmt.execute("CREATE TABLE IF NOT EXISTS guide_sub_categories (" +
                                        "sub_category_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "category_id INT NOT NULL, " +
                                        "name VARCHAR(200) NOT NULL, " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");

                        // Guides table
                        stmt.execute("CREATE TABLE IF NOT EXISTS guides (" +
                                        "guide_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "title VARCHAR(255) NOT NULL, " +
                                        "main_image_path VARCHAR(500), " +
                                        "main_category VARCHAR(100), " +
                                        "sub_category VARCHAR(100), " +
                                        "youtube_url VARCHAR(500), " +
                                        "created_by INT NOT NULL, " +
                                        "created_role VARCHAR(50), " +
                                        "view_count INT DEFAULT 0, " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");

                        // Guide requirements table
                        stmt.execute("CREATE TABLE IF NOT EXISTS guide_requirements (" +
                                        "req_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "guide_id INT NOT NULL, " +
                                        "requirement TEXT NOT NULL" +
                                        ")");

                        // Guide steps table
                        stmt.execute("CREATE TABLE IF NOT EXISTS guide_steps (" +
                                        "step_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "guide_id INT NOT NULL, " +
                                        "step_order INT NOT NULL, " +
                                        "step_title VARCHAR(255), " +
                                        "step_body TEXT" +
                                        ")");

                        // Guide step images table
                        stmt.execute("CREATE TABLE IF NOT EXISTS guide_step_images (" +
                                        "image_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "step_id INT NOT NULL, " +
                                        "image_path VARCHAR(500)" +
                                        ")");

                        // Guide comments table
                        stmt.execute("CREATE TABLE IF NOT EXISTS guide_comments (" +
                                        "comment_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "guide_id INT NOT NULL, " +
                                        "user_id INT NOT NULL, " +
                                        "comment TEXT, " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");

                        // Guide ratings table
                        stmt.execute("CREATE TABLE IF NOT EXISTS guide_ratings (" +
                                        "rating_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "guide_id INT NOT NULL, " +
                                        "user_id INT NOT NULL, " +
                                        "rating VARCHAR(10) NOT NULL, " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                                        "UNIQUE(guide_id, user_id)" +
                                        ")");

                        // Diagnostic categories table (hierarchical)
                        stmt.execute("CREATE TABLE IF NOT EXISTS diagnostic_categories (" +
                                        "category_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "name VARCHAR(200) NOT NULL, " +
                                        "parent_id INT, " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");

                        // Diagnostic trees table
                        stmt.execute("CREATE TABLE IF NOT EXISTS diagnostic_trees (" +
                                        "tree_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "title VARCHAR(255) NOT NULL, " +
                                        "description TEXT, " +
                                        "category_id INT NOT NULL, " +
                                        "creator_id INT NOT NULL, " +
                                        "status VARCHAR(50) DEFAULT 'draft', " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");

                        // Diagnostic nodes table
                        stmt.execute("CREATE TABLE IF NOT EXISTS diagnostic_nodes (" +
                                        "node_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "tree_id INT NOT NULL, " +
                                        "question TEXT NOT NULL, " +
                                        "is_solution BOOLEAN DEFAULT false, " +
                                        "solution_text TEXT, " +
                                        "parent_node_id INT, " +
                                        "parent_answer VARCHAR(255)" +
                                        ")");

                        // Diagnostic tree ratings table
                        stmt.execute("CREATE TABLE IF NOT EXISTS diagnostic_ratings (" +
                                        "rating_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "tree_id INT NOT NULL, " +
                                        "user_id INT NOT NULL, " +
                                        "rating INT NOT NULL, " +
                                        "feedback TEXT, " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                                        "UNIQUE(tree_id, user_id)" +
                                        ")");

                        // Orders table
                        stmt.execute("CREATE TABLE IF NOT EXISTS orders (" +
                                        "order_id VARCHAR(100) PRIMARY KEY, " +
                                        "customer_name VARCHAR(200), " +
                                        "first_name VARCHAR(100), " +
                                        "last_name VARCHAR(100), " +
                                        "email VARCHAR(100), " +
                                        "phone VARCHAR(20), " +
                                        "address TEXT, " +
                                        "city VARCHAR(100), " +
                                        "total_amount DECIMAL(10,2), " +
                                        "currency VARCHAR(10) DEFAULT 'LKR', " +
                                        "status VARCHAR(50) DEFAULT 'PENDING', " +
                                        "payhere_payment_id VARCHAR(100), " +
                                        "store_username VARCHAR(50), " +
                                        "store_id INT, " +
                                        "product_name VARCHAR(255), " +
                                        "buyer_id INT, " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");

                        // Order items table
                        stmt.execute("CREATE TABLE IF NOT EXISTS order_items (" +
                                        "id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "order_id VARCHAR(100) NOT NULL, " +
                                        "store_id INT NOT NULL, " +
                                        "product_id INT NOT NULL, " +
                                        "variant_id INT, " +
                                        "product_name VARCHAR(255) NOT NULL, " +
                                        "quantity INT NOT NULL, " +
                                        "unit_price DECIMAL(10,2) NOT NULL, " +
                                        "total_price DECIMAL(10,2) NOT NULL, " +
                                        "status VARCHAR(50) DEFAULT 'PENDING', " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");

                        // Store orders table
                        stmt.execute("CREATE TABLE IF NOT EXISTS store_orders (" +
                                        "store_order_id INT AUTO_INCREMENT PRIMARY KEY, " +
                                        "order_id VARCHAR(100) NOT NULL, " +
                                        "store_id INT NOT NULL, " +
                                        "store_total DECIMAL(10,2), " +
                                        "commission DECIMAL(10,2) DEFAULT 0.00, " +
                                        "payable_amount DECIMAL(10,2), " +
                                        "status VARCHAR(50) DEFAULT 'PENDING', " +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                                        ")");
                        ;
                }
        }

        /**
         * Clear all data from tables for test isolation.
         */
        public static void clearAllTables() throws SQLException, ClassNotFoundException {
                try (Connection conn = getConnection();
                                Statement stmt = conn.createStatement()) {
                        stmt.execute("SET REFERENTIAL_INTEGRITY FALSE");
                        stmt.execute("TRUNCATE TABLE users");
                        stmt.execute("TRUNCATE TABLE services");
                        stmt.execute("TRUNCATE TABLE stores");
                        stmt.execute("TRUNCATE TABLE products");
                        stmt.execute("TRUNCATE TABLE discounts");
                        stmt.execute("TRUNCATE TABLE product_reviews");
                        stmt.execute("TRUNCATE TABLE vehicles");
                        stmt.execute("TRUNCATE TABLE password_reset_tokens");
                        stmt.execute("TRUNCATE TABLE guide_categories");
                        stmt.execute("TRUNCATE TABLE guide_sub_categories");
                        stmt.execute("TRUNCATE TABLE guides");
                        stmt.execute("TRUNCATE TABLE guide_requirements");
                        stmt.execute("TRUNCATE TABLE guide_steps");
                        stmt.execute("TRUNCATE TABLE guide_step_images");
                        stmt.execute("TRUNCATE TABLE guide_comments");
                        stmt.execute("TRUNCATE TABLE guide_ratings");
                        stmt.execute("TRUNCATE TABLE diagnostic_categories");
                        stmt.execute("TRUNCATE TABLE diagnostic_trees");
                        stmt.execute("TRUNCATE TABLE diagnostic_nodes");
                        stmt.execute("TRUNCATE TABLE diagnostic_ratings");
                        stmt.execute("TRUNCATE TABLE order_items");
                        stmt.execute("TRUNCATE TABLE store_orders");
                        stmt.execute("TRUNCATE TABLE orders");
                        stmt.execute("SET REFERENTIAL_INTEGRITY TRUE");
                }
        }

        /**
         * Reset the schema initialization flag for testing purposes.
         */
        public static void resetSchemaFlag() {
                schemaInitialized.set(false);
        }
}
