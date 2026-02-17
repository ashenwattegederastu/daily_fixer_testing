package com.dailyfixer.dao;

import com.dailyfixer.model.Order;
import com.dailyfixer.model.ProductSales;
import com.dailyfixer.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AdminDashboardDAO {

    public int getTotalRegisteredStores() {
        String sql = "SELECT COUNT(*) FROM stores";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalProductsListed() {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalSalesToday() {
        String sql = "SELECT COUNT(*) FROM orders WHERE DATE(created_at) = CURDATE() AND status = 'PAID'";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getTotalRevenueToday() {
        String sql = "SELECT SUM(total_amount) FROM orders WHERE DATE(created_at) = CURDATE() AND status = 'PAID'";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public double getTotalRevenueMonth() {
        String sql = "SELECT SUM(total_amount) FROM orders WHERE MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE()) AND status = 'PAID'";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public List<ProductSales> getBestSellingItems(int limit) {
        List<ProductSales> list = new ArrayList<>();
        String sql = "SELECT p.name, SUM(oi.quantity) as total_sold " +
                "FROM order_items oi " +
                "JOIN products p ON oi.product_id = p.product_id " +
                "JOIN orders o ON oi.order_id = o.order_id " +
                "WHERE o.status = 'PAID' " +
                "GROUP BY p.product_id, p.name " +
                "ORDER BY total_sold DESC " +
                "LIMIT ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductSales psales = new ProductSales();
                    psales.setProductName(rs.getString("name"));
                    psales.setQuantitySold(rs.getInt("total_sold"));
                    list.add(psales);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> getLatestTransactions(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders ORDER BY created_at DESC LIMIT ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> searchTransactions(String query) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE order_id LIKE ? OR customer_name LIKE ? OR email LIKE ? ORDER BY created_at DESC";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            String searchPattern = "%" + query + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getString("order_id"));

        // Split customer_name into first_name and last_name
        String customerName = rs.getString("customer_name");
        if (customerName != null && !customerName.isEmpty()) {
            String[] nameParts = customerName.trim().split("\\s+", 2);
            if (nameParts.length > 0) {
                order.setFirstName(nameParts[0]);
                order.setLastName(nameParts.length > 1 ? nameParts[1] : "");
            } else {
                order.setFirstName(customerName);
                order.setLastName("");
            }
        } else {
            order.setFirstName("");
            order.setLastName("");
        }

        order.setEmail(rs.getString("email"));
        order.setAmount(rs.getBigDecimal("total_amount"));
        order.setStatus(rs.getString("status"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setCurrency(rs.getString("currency")); // Added currency
        return order;
    }
}
