package com.dailyfixer.dao;

import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.util.DBConnection;
import com.dailyfixer.util.DeliveryFeeCalculator;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for delivery_assignments table.
 *
 * Race-condition safety for acceptAssignment():
 *   UPDATE delivery_assignments
 *     SET status='ACCEPTED', driver_id=?, assigned_at=NOW()
 *   WHERE assignment_id=? AND status='PENDING'
 *
 * MySQL InnoDB serialises concurrent UPDATEs on the same row via row-level locking.
 * The first writer gets rowsAffected=1 (SUCCESS); every subsequent writer gets 0
 * (ALREADY_TAKEN) because the WHERE status='PENDING' predicate no longer matches.
 * No explicit transaction or optimistic-lock version column is needed.
 */
public class DeliveryAssignmentDAO {

    /** Result of an acceptAssignment() call. */
    public enum AcceptResult { SUCCESS, ALREADY_TAKEN, ERROR }

    // ── SQL constants ─────────────────────────────────────────────────────────

    private static final String INSERT =
        "INSERT INTO delivery_assignments " +
        "(order_id, store_id, required_vehicle_type, delivery_fee_earned, " +
        " pickup_address, delivery_address, delivery_lat, delivery_lng, status) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";

    private static final String SELECT_BY_ORDER =
        "SELECT da.*, s.store_name, s.latitude AS store_lat, s.longitude AS store_lng " +
        "FROM delivery_assignments da " +
        "JOIN stores s ON da.store_id = s.store_id " +
        "WHERE da.order_id = ?";

    /**
     * Fetches all PENDING, unassigned assignments matching any of the given vehicle types.
     * The 10 km radius filter is applied in Java after fetching (store coords come via JOIN).
     */
    private static final String SELECT_PENDING_BASE =
        "SELECT da.*, " +
        "       s.store_name, s.latitude AS store_lat, s.longitude AS store_lng, " +
        "       s.store_address AS pickup_addr_join, " +
        "       o.first_name, o.last_name " +
        "FROM delivery_assignments da " +
        "JOIN stores s ON da.store_id = s.store_id " +
        "JOIN orders o ON da.order_id  = o.order_id " +
        "WHERE da.status = 'PENDING' AND da.driver_id IS NULL " +
        "AND da.required_vehicle_type IN ";   // caller appends (?,?,...) dynamically

    /** Atomic accept — the heart of the race-condition guard. */
    private static final String ACCEPT =
        "UPDATE delivery_assignments " +
        "SET status='ACCEPTED', driver_id=?, assigned_at=NOW() " +
        "WHERE assignment_id=? AND status='PENDING'";

    private static final String MARK_DELIVERED =
        "UPDATE delivery_assignments " +
        "SET status='DELIVERED', completed_at=NOW() " +
        "WHERE assignment_id=? AND driver_id=? AND status='ACCEPTED'";

    private static final String CANCEL =
        "UPDATE delivery_assignments SET status='CANCELLED' " +
        "WHERE assignment_id=? AND status IN ('PENDING','ACCEPTED')";

    private static final String SELECT_BY_DRIVER =
        "SELECT da.*, s.store_name, s.latitude AS store_lat, s.longitude AS store_lng, " +
        "       o.first_name, o.last_name " +
        "FROM delivery_assignments da " +
        "JOIN stores s ON da.store_id = s.store_id " +
        "JOIN orders o ON da.order_id = o.order_id " +
        "WHERE da.driver_id = ? AND da.status = ? " +
        "ORDER BY da.created_at DESC";

    private static final String SELECT_BY_STORE =
        "SELECT da.*, " +
        "       CONCAT(u.first_name,' ',u.last_name) AS driver_name_join, " +
        "       o.first_name, o.last_name " +
        "FROM delivery_assignments da " +
        "JOIN orders o ON da.order_id = o.order_id " +
        "LEFT JOIN users u ON da.driver_id = u.user_id " +
        "WHERE da.store_id = ? " +
        "ORDER BY da.created_at DESC";

    // ── Public methods ────────────────────────────────────────────────────────

    /**
     * Persists a new delivery assignment (status=PENDING, no driver yet).
     * Called by the store servlet when the store accepts an order.
     */
    public boolean createAssignment(DeliveryAssignment da) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, da.getOrderId());
            stmt.setInt(2, da.getStoreId());
            stmt.setString(3, da.getRequiredVehicleType());
            stmt.setBigDecimal(4, da.getDeliveryFeeEarned());
            stmt.setString(5, da.getPickupAddress());
            stmt.setString(6, da.getDeliveryAddress());
            if (da.getDeliveryLat() != null) stmt.setDouble(7, da.getDeliveryLat());
            else stmt.setNull(7, Types.DECIMAL);
            if (da.getDeliveryLng() != null) stmt.setDouble(8, da.getDeliveryLng());
            else stmt.setNull(8, Types.DECIMAL);

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) da.setAssignmentId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.createAssignment: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Returns the assignment for the given order, or null if none exists yet.
     */
    public DeliveryAssignment getByOrderId(String orderId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_ORDER)) {

            stmt.setString(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    DeliveryAssignment da = mapRow(rs);
                    da.setStoreName(rs.getString("store_name"));
                    da.setStoreLat(rs.getDouble("store_lat"));
                    da.setStoreLng(rs.getDouble("store_lng"));
                    return da;
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getByOrderId: " + e.getMessage());
        }
        return null;
    }

    /**
     * Returns PENDING assignments within radiusKm of (driverLat, driverLng)
     * whose required_vehicle_type is one of vehicleTypes.
     *
     * The haversine distance check runs in Java after a DB fetch filtered only
     * by vehicle type and PENDING status, keeping the SQL simple and portable.
     */
    public List<DeliveryAssignment> getPendingNearby(double driverLat, double driverLng,
                                                      List<String> vehicleTypes,
                                                      double radiusKm) {
        List<DeliveryAssignment> result = new ArrayList<>();
        if (vehicleTypes == null || vehicleTypes.isEmpty()) return result;

        // Build: WHERE ... AND required_vehicle_type IN (?,?,...)
        StringBuilder inClause = new StringBuilder("(");
        for (int i = 0; i < vehicleTypes.size(); i++) {
            if (i > 0) inClause.append(",");
            inClause.append("?");
        }
        inClause.append(")");

        String sql = SELECT_PENDING_BASE + inClause;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            for (int i = 0; i < vehicleTypes.size(); i++) {
                stmt.setString(i + 1, vehicleTypes.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    double storeLat = rs.getDouble("store_lat");
                    double storeLng = rs.getDouble("store_lng");

                    // Apply 10 km radius filter
                    double dist = 0;
                    if (storeLat != 0 && storeLng != 0 && driverLat != 0 && driverLng != 0) {
                        dist = DeliveryFeeCalculator.haversineDistance(storeLat, storeLng, driverLat, driverLng);
                        if (dist > radiusKm) continue; // outside radius — skip
                    }

                    DeliveryAssignment da = mapRow(rs);
                    da.setStoreName(rs.getString("store_name"));
                    da.setStoreLat(storeLat);
                    da.setStoreLng(storeLng);
                    da.setDistanceKm(dist);
                    da.setCustomerName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    result.add(da);
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getPendingNearby: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Atomically claims a PENDING assignment for the given driver.
     *
     * Uses a single UPDATE with WHERE status='PENDING' as the guard.
     * MySQL's row-level locking ensures at most one concurrent caller
     * receives rowsAffected=1 for the same assignment_id.
     *
     * @return SUCCESS       – driver now owns this assignment
     *         ALREADY_TAKEN – another driver accepted first (rowsAffected=0)
     *         ERROR         – unexpected exception
     */
    public AcceptResult acceptAssignment(int assignmentId, int driverId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(ACCEPT)) {

            stmt.setInt(1, driverId);
            stmt.setInt(2, assignmentId);
            int rows = stmt.executeUpdate();
            return rows > 0 ? AcceptResult.SUCCESS : AcceptResult.ALREADY_TAKEN;

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.acceptAssignment: " + e.getMessage());
            e.printStackTrace();
            return AcceptResult.ERROR;
        }
    }

    /**
     * Marks an accepted assignment as DELIVERED.
     * Only succeeds if the assignment belongs to driverId and is in ACCEPTED status.
     */
    public boolean markDelivered(int assignmentId, int driverId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(MARK_DELIVERED)) {

            stmt.setInt(1, assignmentId);
            stmt.setInt(2, driverId);
            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.markDelivered: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cancels a PENDING or ACCEPTED assignment (e.g. store cancels order).
     */
    public boolean cancelAssignment(int assignmentId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(CANCEL)) {

            stmt.setInt(1, assignmentId);
            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.cancelAssignment: " + e.getMessage());
            return false;
        }
    }

    /**
     * Returns all assignments for a driver filtered by status.
     * Use "ACCEPTED" for active deliveries, "DELIVERED" for history.
     */
    public List<DeliveryAssignment> getByDriver(int driverId, String status) {
        List<DeliveryAssignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_DRIVER)) {

            stmt.setInt(1, driverId);
            stmt.setString(2, status);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DeliveryAssignment da = mapRow(rs);
                    da.setStoreName(rs.getString("store_name"));
                    da.setStoreLat(rs.getDouble("store_lat"));
                    da.setStoreLng(rs.getDouble("store_lng"));
                    String fn = rs.getString("first_name");
                    String ln = rs.getString("last_name");
                    if (fn != null) da.setCustomerName(fn + (ln != null ? " " + ln : ""));
                    list.add(da);
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getByDriver: " + e.getMessage());
        }
        return list;
    }

    /**
     * Returns all assignments for a store (all statuses), newest first.
     */
    public List<DeliveryAssignment> getByStore(int storeId) {
        List<DeliveryAssignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_STORE)) {

            stmt.setInt(1, storeId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DeliveryAssignment da = mapRow(rs);
                    da.setCustomerName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    String driverName = rs.getString("driver_name_join");
                    da.setDriverName(driverName != null ? driverName : "Unassigned");
                    list.add(da);
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getByStore: " + e.getMessage());
        }
        return list;
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private DeliveryAssignment mapRow(ResultSet rs) throws SQLException {
        DeliveryAssignment da = new DeliveryAssignment();
        da.setAssignmentId(rs.getInt("assignment_id"));
        da.setOrderId(rs.getString("order_id"));
        da.setStoreId(rs.getInt("store_id"));

        int driverId = rs.getInt("driver_id");
        da.setDriverId(rs.wasNull() ? null : driverId);

        da.setRequiredVehicleType(rs.getString("required_vehicle_type"));
        da.setDeliveryFeeEarned(rs.getBigDecimal("delivery_fee_earned"));
        da.setPickupAddress(rs.getString("pickup_address"));
        da.setDeliveryAddress(rs.getString("delivery_address"));

        double lat = rs.getDouble("delivery_lat");
        da.setDeliveryLat(rs.wasNull() ? null : lat);
        double lng = rs.getDouble("delivery_lng");
        da.setDeliveryLng(rs.wasNull() ? null : lng);

        da.setStatus(rs.getString("status"));
        da.setAssignedAt(rs.getTimestamp("assigned_at"));
        da.setCompletedAt(rs.getTimestamp("completed_at"));

        int payoutId = rs.getInt("driver_payout_id");
        da.setDriverPayoutId(rs.wasNull() ? null : payoutId);

        da.setCreatedAt(rs.getTimestamp("created_at"));
        return da;
    }
}
