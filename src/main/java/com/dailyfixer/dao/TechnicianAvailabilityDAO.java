package com.dailyfixer.dao;

import com.dailyfixer.model.TechnicianAvailability;
import com.dailyfixer.util.DBConnection;

import java.sql.*;

public class TechnicianAvailabilityDAO {

    public void setAvailability(TechnicianAvailability availability) throws Exception {
        String sql = "INSERT INTO technician_availability (technician_id, availability_mode, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_time, end_time) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "availability_mode = VALUES(availability_mode), " +
                     "monday = VALUES(monday), " +
                     "tuesday = VALUES(tuesday), " +
                     "wednesday = VALUES(wednesday), " +
                     "thursday = VALUES(thursday), " +
                     "friday = VALUES(friday), " +
                     "saturday = VALUES(saturday), " +
                     "sunday = VALUES(sunday), " +
                     "start_time = VALUES(start_time), " +
                     "end_time = VALUES(end_time)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, availability.getTechnicianId());
            stmt.setString(2, availability.getAvailabilityMode());
            stmt.setBoolean(3, availability.isMonday());
            stmt.setBoolean(4, availability.isTuesday());
            stmt.setBoolean(5, availability.isWednesday());
            stmt.setBoolean(6, availability.isThursday());
            stmt.setBoolean(7, availability.isFriday());
            stmt.setBoolean(8, availability.isSaturday());
            stmt.setBoolean(9, availability.isSunday());
            stmt.setTime(10, availability.getStartTime());
            stmt.setTime(11, availability.getEndTime());

            stmt.executeUpdate();
        }
    }

    public TechnicianAvailability getAvailabilityByTechnicianId(int technicianId) throws Exception {
        String sql = "SELECT * FROM technician_availability WHERE technician_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, technicianId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAvailability(rs);
                }
            }
        }
        return null;
    }

    public boolean isAvailable(int technicianId, Date bookingDate, Time bookingTime) throws Exception {
        TechnicianAvailability availability = getAvailabilityByTechnicianId(technicianId);
        if (availability == null) {
            return false;
        }

        String dayOfWeek = getDayOfWeek(bookingDate);
        boolean isDayAvailable = false;

        switch (dayOfWeek) {
            case "MONDAY":
                isDayAvailable = availability.isMonday();
                break;
            case "TUESDAY":
                isDayAvailable = availability.isTuesday();
                break;
            case "WEDNESDAY":
                isDayAvailable = availability.isWednesday();
                break;
            case "THURSDAY":
                isDayAvailable = availability.isThursday();
                break;
            case "FRIDAY":
                isDayAvailable = availability.isFriday();
                break;
            case "SATURDAY":
                isDayAvailable = availability.isSaturday();
                break;
            case "SUNDAY":
                isDayAvailable = availability.isSunday();
                break;
        }

        if (!isDayAvailable) {
            return false;
        }

        Time startTime = availability.getStartTime();
        Time endTime = availability.getEndTime();

        return !bookingTime.before(startTime) && bookingTime.before(endTime);
    }

    private String getDayOfWeek(Date date) {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(date);
        int dayOfWeek = cal.get(java.util.Calendar.DAY_OF_WEEK);

        switch (dayOfWeek) {
            case java.util.Calendar.MONDAY:
                return "MONDAY";
            case java.util.Calendar.TUESDAY:
                return "TUESDAY";
            case java.util.Calendar.WEDNESDAY:
                return "WEDNESDAY";
            case java.util.Calendar.THURSDAY:
                return "THURSDAY";
            case java.util.Calendar.FRIDAY:
                return "FRIDAY";
            case java.util.Calendar.SATURDAY:
                return "SATURDAY";
            case java.util.Calendar.SUNDAY:
                return "SUNDAY";
            default:
                return "";
        }
    }

    private TechnicianAvailability mapResultSetToAvailability(ResultSet rs) throws SQLException {
        TechnicianAvailability availability = new TechnicianAvailability();
        availability.setAvailabilityId(rs.getInt("availability_id"));
        availability.setTechnicianId(rs.getInt("technician_id"));
        availability.setAvailabilityMode(rs.getString("availability_mode"));
        availability.setMonday(rs.getBoolean("monday"));
        availability.setTuesday(rs.getBoolean("tuesday"));
        availability.setWednesday(rs.getBoolean("wednesday"));
        availability.setThursday(rs.getBoolean("thursday"));
        availability.setFriday(rs.getBoolean("friday"));
        availability.setSaturday(rs.getBoolean("saturday"));
        availability.setSunday(rs.getBoolean("sunday"));
        availability.setStartTime(rs.getTime("start_time"));
        availability.setEndTime(rs.getTime("end_time"));
        availability.setCreatedAt(rs.getTimestamp("created_at"));
        availability.setUpdatedAt(rs.getTimestamp("updated_at"));
        return availability;
    }
}
