package com.dailyfixer.dao;

import com.dailyfixer.model.Booking;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    public int createBooking(Booking booking) throws Exception {
        String sql = "INSERT INTO bookings (user_id, technician_id, service_id, booking_date, booking_time, " +
                     "phone_number, problem_description, location_address, location_latitude, location_longitude, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, booking.getUserId());
            stmt.setInt(2, booking.getTechnicianId());
            stmt.setInt(3, booking.getServiceId());
            stmt.setDate(4, booking.getBookingDate());
            stmt.setTime(5, booking.getBookingTime());
            stmt.setString(6, booking.getPhoneNumber());
            stmt.setString(7, booking.getProblemDescription());
            stmt.setString(8, booking.getLocationAddress());
            stmt.setBigDecimal(9, booking.getLocationLatitude());
            stmt.setBigDecimal(10, booking.getLocationLongitude());
            stmt.setString(11, booking.getStatus().name());

            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public Booking getBookingById(int bookingId) throws Exception {
        String sql = "SELECT b.*, " +
                     "u.first_name as user_first_name, u.last_name as user_last_name, " +
                     "t.first_name as tech_first_name, t.last_name as tech_last_name, " +
                     "s.service_name " +
                     "FROM bookings b " +
                     "JOIN users u ON b.user_id = u.user_id " +
                     "JOIN users t ON b.technician_id = t.user_id " +
                     "JOIN services s ON b.service_id = s.service_id " +
                     "WHERE b.booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBooking(rs);
                }
            }
        }
        return null;
    }

    public List<Booking> getBookingsByTechnicianId(int technicianId, Booking.BookingStatus status) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT b.*, " +
            "u.first_name as user_first_name, u.last_name as user_last_name, " +
            "t.first_name as tech_first_name, t.last_name as tech_last_name, " +
            "s.service_name " +
            "FROM bookings b " +
            "JOIN users u ON b.user_id = u.user_id " +
            "JOIN users t ON b.technician_id = t.user_id " +
            "JOIN services s ON b.service_id = s.service_id " +
            "WHERE b.technician_id = ?"
        );

        if (status != null) {
            sql.append(" AND b.status = ?");
        }
        sql.append(" ORDER BY b.booking_date DESC, b.booking_time DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            stmt.setInt(1, technicianId);
            if (status != null) {
                stmt.setString(2, status.name());
            }

            return executeQueryAndMapBookings(stmt);
        }
    }

    public List<Booking> getBookingsByUserId(int userId, Booking.BookingStatus status) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT b.*, " +
            "u.first_name as user_first_name, u.last_name as user_last_name, " +
            "t.first_name as tech_first_name, t.last_name as tech_last_name, " +
            "s.service_name " +
            "FROM bookings b " +
            "JOIN users u ON b.user_id = u.user_id " +
            "JOIN users t ON b.technician_id = t.user_id " +
            "JOIN services s ON b.service_id = s.service_id " +
            "WHERE b.user_id = ?"
        );

        if (status != null) {
            sql.append(" AND b.status = ?");
        }
        sql.append(" ORDER BY b.booking_date DESC, b.booking_time DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            stmt.setInt(1, userId);
            if (status != null) {
                stmt.setString(2, status.name());
            }

            return executeQueryAndMapBookings(stmt);
        }
    }

    public List<Booking> getBookingsByTechnicianIdAndDate(int technicianId, Date date) throws Exception {
        String sql = "SELECT b.*, " +
                     "u.first_name as user_first_name, u.last_name as user_last_name, " +
                     "t.first_name as tech_first_name, t.last_name as tech_last_name, " +
                     "s.service_name " +
                     "FROM bookings b " +
                     "JOIN users u ON b.user_id = u.user_id " +
                     "JOIN users t ON b.technician_id = t.user_id " +
                     "JOIN services s ON b.service_id = s.service_id " +
                     "WHERE b.technician_id = ? AND b.booking_date = ? " +
                     "AND b.status IN ('ACCEPTED', 'TECHNICIAN_COMPLETED') " +
                     "ORDER BY b.booking_time";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, technicianId);
            stmt.setDate(2, date);

            return executeQueryAndMapBookings(stmt);
        }
    }

    public void updateBookingStatus(int bookingId, Booking.BookingStatus status) throws Exception {
        String sql = "UPDATE bookings SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status.name());
            stmt.setInt(2, bookingId);

            stmt.executeUpdate();
        }
    }

    public int countPendingBookings(int technicianId) throws Exception {
        String sql = "SELECT COUNT(*) FROM bookings WHERE technician_id = ? AND status = 'REQUESTED'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, technicianId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private List<Booking> executeQueryAndMapBookings(PreparedStatement stmt) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                bookings.add(mapResultSetToBooking(rs));
            }
        }
        return bookings;
    }

    private Booking mapResultSetToBooking(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setBookingId(rs.getInt("booking_id"));
        booking.setUserId(rs.getInt("user_id"));
        booking.setTechnicianId(rs.getInt("technician_id"));
        booking.setServiceId(rs.getInt("service_id"));
        booking.setBookingDate(rs.getDate("booking_date"));
        booking.setBookingTime(rs.getTime("booking_time"));
        booking.setPhoneNumber(rs.getString("phone_number"));
        booking.setProblemDescription(rs.getString("problem_description"));
        booking.setLocationAddress(rs.getString("location_address"));
        booking.setLocationLatitude(rs.getBigDecimal("location_latitude"));
        booking.setLocationLongitude(rs.getBigDecimal("location_longitude"));
        booking.setStatus(Booking.BookingStatus.valueOf(rs.getString("status")));
        booking.setCreatedAt(rs.getTimestamp("created_at"));
        booking.setUpdatedAt(rs.getTimestamp("updated_at"));

        booking.setUserName(rs.getString("user_first_name") + " " + rs.getString("user_last_name"));
        booking.setTechnicianName(rs.getString("tech_first_name") + " " + rs.getString("tech_last_name"));
        booking.setServiceName(rs.getString("service_name"));

        return booking;
    }
}
