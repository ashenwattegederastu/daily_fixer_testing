package com.dailyfixer.dao;

import com.dailyfixer.model.BookingCancellation;
import com.dailyfixer.util.DBConnection;

import java.sql.*;

public class BookingCancellationDAO {

    public void createCancellation(BookingCancellation cancellation) throws Exception {
        String sql = "INSERT INTO booking_cancellations (booking_id, cancelled_by, cancellation_reason) " +
                     "VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cancellation.getBookingId());
            stmt.setInt(2, cancellation.getCancelledBy());
            stmt.setString(3, cancellation.getCancellationReason());

            stmt.executeUpdate();
        }
    }

    public BookingCancellation getCancellationByBookingId(int bookingId) throws Exception {
        String sql = "SELECT * FROM booking_cancellations WHERE booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCancellation(rs);
                }
            }
        }
        return null;
    }

    private BookingCancellation mapResultSetToCancellation(ResultSet rs) throws SQLException {
        BookingCancellation cancellation = new BookingCancellation();
        cancellation.setCancellationId(rs.getInt("cancellation_id"));
        cancellation.setBookingId(rs.getInt("booking_id"));
        cancellation.setCancelledBy(rs.getInt("cancelled_by"));
        cancellation.setCancellationReason(rs.getString("cancellation_reason"));
        cancellation.setCancelledAt(rs.getTimestamp("cancelled_at"));
        return cancellation;
    }
}
