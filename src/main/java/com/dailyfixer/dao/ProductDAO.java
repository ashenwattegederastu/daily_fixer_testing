package com.dailyfixer.dao;

import java.sql.*;
import java.util.*;

import com.dailyfixer.model.Product;
import com.dailyfixer.util.DBConnection;

public class ProductDAO {

    public void addProduct(Product p) throws Exception {
        String sql = "INSERT INTO products (name, type, quantity, quantity_unit, price, image, store_username, description, store_id, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getType());
            ps.setDouble(3, p.getQuantity());
            ps.setString(4, p.getQuantityUnit());
            ps.setDouble(5, p.getPrice());
            ps.setBytes(6, p.getImage());
            ps.setString(7, p.getStoreUsername());
            ps.setString(8, p.getDescription());
            if (p.getStoreId() > 0) {
                ps.setInt(9, p.getStoreId());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            ps.setBoolean(10, p.isActive());
            ps.executeUpdate();

            // Get generated product ID
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    p.setProductId(rs.getInt(1));
                }
            }
        }
    }

    public int addProductAndReturnId(Product p) throws Exception {
        addProduct(p);
        return p.getProductId();
    }

    public List<Product> getAllProducts(String storeUsername) throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE store_username=? AND is_active = TRUE";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, storeUsername);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        }
        return list;
    }

    public List<Product> getAllProductsAdmin() throws Exception {
        List<Product> list = new ArrayList<>();
        // Query to fetch product details along with variation stats
        String sql = "SELECT p.*, " +
                "COUNT(pv.variant_id) as variant_count, " +
                "MIN(pv.price) as min_var_price, " +
                "MAX(pv.price) as max_var_price, " +
                "SUM(pv.quantity) as total_var_qty " +
                "FROM products p " +
                "LEFT JOIN product_variants pv ON p.product_id = pv.product_id " +
                "GROUP BY p.product_id " +
                "ORDER BY p.product_id DESC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = mapProduct(rs);

                // Populate variation data
                int variantCount = rs.getInt("variant_count");
                if (variantCount > 0) {
                    p.setHasVariants(true);
                    p.setMinPrice(rs.getDouble("min_var_price"));
                    p.setMaxPrice(rs.getDouble("max_var_price"));
                    p.setVariantQuantity(rs.getInt("total_var_qty"));
                } else {
                    p.setHasVariants(false);
                }

                list.add(p);
            }
        }
        return list;
    }

    public Product getProductById(int id) throws Exception {
        String sql = "SELECT * FROM products WHERE product_id=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapProduct(rs);
            }
        }
        return null;
    }

    public void updateProduct(Product p) throws Exception {
        String sql = "UPDATE products SET name=?, type=?, quantity=?, quantity_unit=?, price=?, image=?, description=? WHERE product_id=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getType());
            ps.setDouble(3, p.getQuantity());
            ps.setString(4, p.getQuantityUnit());
            ps.setDouble(5, p.getPrice());
            ps.setBytes(6, p.getImage());
            ps.setString(7, p.getDescription());
            ps.setInt(8, p.getProductId());
            ps.executeUpdate();
        }
    }

    /**
     * Reduce product quantity by the specified amount.
     * Returns false if insufficient stock.
     */
    public boolean reduceProductQuantity(int productId, int quantityToReduce) {
        String sql = "UPDATE products SET quantity = quantity - ? WHERE product_id = ? AND quantity >= ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantityToReduce);
            ps.setInt(2, productId);
            ps.setInt(3, quantityToReduce);
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("Reduced stock for product ID " + productId + " by " + quantityToReduce);
                return true;
            }
            System.out.println("Insufficient stock for product ID " + productId);
            return false;
        } catch (Exception e) {
            System.err.println("Error reducing product quantity: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public void deleteProduct(int id) throws Exception {
        String sql = "DELETE FROM products WHERE product_id=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public List<Product> getProductsByCategory(String category) throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, s.store_id FROM products p " +
                "LEFT JOIN users u ON p.store_username = u.username " +
                "LEFT JOIN stores s ON u.user_id = s.user_id " +
                "WHERE LOWER(p.type) = LOWER(?) AND p.is_active = TRUE";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        }
        return list;
    }

    public List<Product> getProductsByCategoryPaged(String category, int page, int pageSize) throws Exception {
        List<Product> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT p.*, s.store_id FROM products p " +
                "LEFT JOIN users u ON p.store_username = u.username " +
                "LEFT JOIN stores s ON u.user_id = s.user_id " +
                "WHERE LOWER(p.type) = LOWER(?) AND p.is_active = TRUE " +
                "LIMIT ? OFFSET ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, category);
            ps.setInt(2, pageSize);
            ps.setInt(3, offset);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        }
        return list;
    }

    public List<Product> searchProducts(String searchTerm, String sortBy, Double minPrice, Double maxPrice) throws Exception {
        List<Product> list = new ArrayList<>();
        String cleanTerm = searchTerm != null ? searchTerm.trim().toLowerCase() : "";

        StringBuilder sql = new StringBuilder(
                "SELECT p.*, s.store_id FROM products p " +
                "LEFT JOIN users u ON p.store_username = u.username " +
                "LEFT JOIN stores s ON u.user_id = s.user_id " +
                "WHERE p.is_active = TRUE");

        if (!cleanTerm.isEmpty()) {
            sql.append(" AND (LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ?)");
        }
        if (minPrice != null) sql.append(" AND p.price >= ?");
        if (maxPrice != null) sql.append(" AND p.price <= ?");

        if ("price_asc".equals(sortBy)) sql.append(" ORDER BY p.price ASC");
        else if ("price_desc".equals(sortBy)) sql.append(" ORDER BY p.price DESC");
        else sql.append(" ORDER BY p.name ASC");

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (!cleanTerm.isEmpty()) {
                String pattern = "%" + cleanTerm + "%";
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
            }
            if (minPrice != null) ps.setDouble(idx++, minPrice);
            if (maxPrice != null) ps.setDouble(idx++, maxPrice);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        }
        return list;
    }

    /**
     * Flexible search products by name and description (case-insensitive, partial
     * match)
     * 
     * Features:
     * - Partial word matches: "dril" matches "drill", "cut" matches "cutting"
     * - Multiple words: "power drill" matches products with "power" OR "drill" in
     * name/description
     * - Searches in both product name and description fields
     * - Smart ranking:
     * 1. Exact match (highest priority)
     * 2. Starts with search term
     * 3. Contains search term
     * 4. Individual word matches
     * 5. Description matches (lower priority)
     * 
     * Examples:
     * - "dril" will find "Drill Machine", "Power Drill", etc.
     * - "cut tool" will find "Cutting Tools", "Glass Cutter", etc.
     * - "paint" will find products with "paint" in name or description
     */
    public List<Product> searchProductsByName(String searchTerm) throws Exception {
        List<Product> list = new ArrayList<>();

        // Clean and prepare search term
        String cleanTerm = searchTerm.trim().toLowerCase();
        if (cleanTerm.isEmpty()) {
            return list;
        }

        // Split into individual words for flexible matching
        String[] words = cleanTerm.split("\\s+");

        // Build flexible search query
        // Search in both name and description, match any word
        StringBuilder whereClause = new StringBuilder("(");
        for (int i = 0; i < words.length; i++) {
            if (i > 0)
                whereClause.append(" OR ");
            whereClause.append("(LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ?)");
        }
        whereClause.append(")");

        // Build ranking ORDER BY clause for better relevance
        // Priority: 1. Exact match, 2. Starts with, 3. Contains, 4. Word matches
        StringBuilder orderClause = new StringBuilder(
                "ORDER BY " +
                        "CASE WHEN LOWER(p.name) = LOWER(?) THEN 1 " +
                        "WHEN LOWER(p.name) LIKE ? THEN 2 " +
                        "WHEN LOWER(p.name) LIKE ? THEN 3 ");

        // Add word-based ranking
        for (int i = 0; i < words.length; i++) {
            orderClause.append("WHEN LOWER(p.name) LIKE ? THEN ").append(4 + i).append(" ");
        }
        orderClause.append("ELSE ").append(100 + words.length).append(" END, ");
        orderClause.append("CASE WHEN LOWER(p.description) LIKE ? THEN 1 ELSE 2 END, ");
        orderClause.append("p.name");

        String sql = "SELECT p.*, s.store_id FROM products p " +
                "LEFT JOIN users u ON p.store_username = u.username " +
                "LEFT JOIN stores s ON u.user_id = s.user_id " +
                "WHERE " + whereClause.toString() + " AND p.is_active = TRUE " +
                orderClause.toString();

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            int paramIndex = 1;

            // Set WHERE clause parameters (for each word, check name and description)
            for (String word : words) {
                String wordPattern = "%" + word + "%";
                ps.setString(paramIndex++, wordPattern); // name LIKE
                ps.setString(paramIndex++, wordPattern); // description LIKE
            }

            // Set ORDER BY parameters
            // Exact match
            ps.setString(paramIndex++, cleanTerm);
            // Starts with
            ps.setString(paramIndex++, cleanTerm + "%");
            // Contains
            ps.setString(paramIndex++, "%" + cleanTerm + "%");

            // Word-based ranking
            for (String word : words) {
                ps.setString(paramIndex++, "%" + word + "%");
            }

            // Description ranking
            ps.setString(paramIndex++, "%" + cleanTerm + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        }
        return list;
    }

    /**
     * Check if a category exists (case-insensitive)
     */
    public boolean categoryExists(String category) throws Exception {
        String sql = "SELECT COUNT(*) FROM products WHERE LOWER(type) = LOWER(?) LIMIT 1";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    /**
     * Get all unique categories
     */
    public List<String> getAllCategories() throws Exception {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT type FROM products WHERE type IS NOT NULL ORDER BY type";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                categories.add(rs.getString("type"));
            }
        }
        return categories;
    }

    /**
     * Get related products (products in the same category as the given product)
     */
    public List<Product> getRelatedProducts(int productId, String category, int limit) throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, s.store_id FROM products p " +
                "LEFT JOIN users u ON p.store_username = u.username " +
                "LEFT JOIN stores s ON u.user_id = s.user_id " +
                "WHERE p.type = ? AND p.product_id != ? AND p.is_active = TRUE " +
                "LIMIT ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, category);
            ps.setInt(2, productId);
            ps.setInt(3, limit);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        }
        return list;
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setName(rs.getString("name"));
        p.setType(rs.getString("type"));
        p.setQuantity(rs.getInt("quantity"));
        p.setQuantityUnit(rs.getString("quantity_unit"));
        p.setPrice(rs.getDouble("price"));
        p.setImage(rs.getBytes("image"));
        p.setStoreUsername(rs.getString("store_username"));
        p.setDescription(rs.getString("description"));
        try { p.setStoreId(rs.getInt("store_id")); } catch (SQLException ignored) {}
        try { p.setActive(rs.getBoolean("is_active")); } catch (SQLException ignored) {}
        try { p.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException ignored) {}
        try { p.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignored) {}
        return p;
    }

}