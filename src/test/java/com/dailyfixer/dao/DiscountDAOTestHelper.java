package com.dailyfixer.dao;

import com.dailyfixer.model.Discount;
import com.dailyfixer.util.TestDBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Test version of DiscountDAO that uses H2 in-memory database.
 */
public class DiscountDAOTestHelper {

    public int addDiscount(Discount discount) throws Exception {
        String sql = "INSERT INTO discounts (discount_name, discount_type, discount_value, start_date, end_date, store_username, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, discount.getDiscountName());
            stmt.setString(2, discount.getDiscountType());
            stmt.setBigDecimal(3, discount.getDiscountValue());
            stmt.setTimestamp(4, discount.getStartDate());
            stmt.setTimestamp(5, discount.getEndDate());
            stmt.setString(6, discount.getStoreUsername());
            stmt.setBoolean(7, discount.isActive());
            
            stmt.executeUpdate();
            
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<Discount> getAllDiscounts(String storeUsername) throws Exception {
        List<Discount> discounts = new ArrayList<>();
        String sql = "SELECT * FROM discounts WHERE store_username = ? ORDER BY discount_id DESC";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, storeUsername);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    discounts.add(mapResultSetToDiscount(rs));
                }
            }
        }
        return discounts;
    }

    public Discount getDiscountById(int discountId) throws Exception {
        String sql = "SELECT * FROM discounts WHERE discount_id = ?";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, discountId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToDiscount(rs);
                }
            }
        }
        return null;
    }

    public boolean updateDiscount(Discount discount) throws Exception {
        String sql = "UPDATE discounts SET discount_name=?, discount_type=?, discount_value=?, start_date=?, end_date=?, is_active=? WHERE discount_id=?";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, discount.getDiscountName());
            stmt.setString(2, discount.getDiscountType());
            stmt.setBigDecimal(3, discount.getDiscountValue());
            stmt.setTimestamp(4, discount.getStartDate());
            stmt.setTimestamp(5, discount.getEndDate());
            stmt.setBoolean(6, discount.isActive());
            stmt.setInt(7, discount.getDiscountId());
            
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean deleteDiscount(int discountId) throws Exception {
        String sql = "DELETE FROM discounts WHERE discount_id = ?";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, discountId);
            return stmt.executeUpdate() > 0;
        }
    }

    private Discount mapResultSetToDiscount(ResultSet rs) throws SQLException {
        Discount discount = new Discount();
        discount.setDiscountId(rs.getInt("discount_id"));
        discount.setDiscountName(rs.getString("discount_name"));
        discount.setDiscountType(rs.getString("discount_type"));
        discount.setDiscountValue(rs.getBigDecimal("discount_value"));
        discount.setStartDate(rs.getTimestamp("start_date"));
        discount.setEndDate(rs.getTimestamp("end_date"));
        discount.setStoreUsername(rs.getString("store_username"));
        discount.setActive(rs.getBoolean("is_active"));
        return discount;
    }
}
