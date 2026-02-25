package com.dailyfixer.dao;

import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DeliveryAssignmentDAO {

    public boolean createAssignment(DeliveryAssignment assignment) throws Exception {
        String sql = "INSERT INTO delivery_assignments (order_id, driver_id, store_id, vehicle_type, status, notes) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, assignment.getOrderId());
            stmt.setInt(2, assignment.getDriverId());
            stmt.setInt(3, assignment.getStoreId());
            stmt.setString(4, assignment.getVehicleType());
            stmt.setString(5, assignment.getStatus() != null ? assignment.getStatus() : "ASSIGNED");
            stmt.setString(6, assignment.getNotes());
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) assignment.setAssignmentId(rs.getInt(1));
                }
                return true;
            }
        }
        return false;
    }

    public List<DeliveryAssignment> getAssignmentsByDriver(int driverId) throws Exception {
        List<DeliveryAssignment> list = new ArrayList<>();
        String sql = "SELECT da.*, o.customer_name, o.address AS delivery_address, o.city AS delivery_city, " +
                "s.store_name FROM delivery_assignments da " +
                "JOIN orders o ON da.order_id = o.order_id " +
                "LEFT JOIN stores s ON da.store_id = s.store_id " +
                "WHERE da.driver_id = ? ORDER BY da.assigned_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, driverId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(mapResultSet(rs));
        }
        return list;
    }

    public List<DeliveryAssignment> getPendingAssignments() throws Exception {
        List<DeliveryAssignment> list = new ArrayList<>();
        String sql = "SELECT da.*, o.customer_name, o.address AS delivery_address, o.city AS delivery_city, " +
                "s.store_name FROM delivery_assignments da " +
                "JOIN orders o ON da.order_id = o.order_id " +
                "LEFT JOIN stores s ON da.store_id = s.store_id " +
                "WHERE da.status = 'ASSIGNED' ORDER BY da.assigned_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(mapResultSet(rs));
        }
        return list;
    }

    public boolean updateStatus(int assignmentId, String status) throws Exception {
        String timestampCol = null;
        if ("PICKED_UP".equals(status)) timestampCol = "picked_up_at";
        else if ("DELIVERED".equals(status)) timestampCol = "delivered_at";

        String sql;
        if (timestampCol != null) {
            sql = "UPDATE delivery_assignments SET status = ?, " + timestampCol + " = CURRENT_TIMESTAMP WHERE assignment_id = ?";
        } else {
            sql = "UPDATE delivery_assignments SET status = ? WHERE assignment_id = ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, assignmentId);
            return stmt.executeUpdate() > 0;
        }
    }

    public DeliveryAssignment getAssignmentByOrderId(String orderId) throws Exception {
        String sql = "SELECT da.*, o.customer_name, o.address AS delivery_address, o.city AS delivery_city, " +
                "s.store_name FROM delivery_assignments da " +
                "JOIN orders o ON da.order_id = o.order_id " +
                "LEFT JOIN stores s ON da.store_id = s.store_id " +
                "WHERE da.order_id = ? ORDER BY da.assignment_id DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, orderId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return mapResultSet(rs);
        }
        return null;
    }

    public List<DeliveryAssignment> getAssignmentsByStore(int storeId) throws Exception {
        List<DeliveryAssignment> list = new ArrayList<>();
        String sql = "SELECT da.*, o.customer_name, o.address AS delivery_address, o.city AS delivery_city, " +
                "s.store_name FROM delivery_assignments da " +
                "JOIN orders o ON da.order_id = o.order_id " +
                "LEFT JOIN stores s ON da.store_id = s.store_id " +
                "WHERE da.store_id = ? ORDER BY da.assigned_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, storeId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(mapResultSet(rs));
        }
        return list;
    }

    private DeliveryAssignment mapResultSet(ResultSet rs) throws SQLException {
        DeliveryAssignment da = new DeliveryAssignment();
        da.setAssignmentId(rs.getInt("assignment_id"));
        da.setOrderId(rs.getString("order_id"));
        da.setDriverId(rs.getInt("driver_id"));
        da.setStoreId(rs.getInt("store_id"));
        da.setVehicleType(rs.getString("vehicle_type"));
        da.setStatus(rs.getString("status"));
        da.setNotes(rs.getString("notes"));
        da.setAssignedAt(rs.getTimestamp("assigned_at"));
        da.setPickedUpAt(rs.getTimestamp("picked_up_at"));
        da.setDeliveredAt(rs.getTimestamp("delivered_at"));
        try { da.setCustomerName(rs.getString("customer_name")); } catch (SQLException ignored) {}
        try { da.setDeliveryAddress(rs.getString("delivery_address")); } catch (SQLException ignored) {}
        try { da.setDeliveryCity(rs.getString("delivery_city")); } catch (SQLException ignored) {}
        try { da.setStoreName(rs.getString("store_name")); } catch (SQLException ignored) {}
        return da;
    }
}
