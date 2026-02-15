package com.dailyfixer.dao;

import com.dailyfixer.model.Vehicle;
import com.dailyfixer.util.TestDBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Test version of VehicleDAO that uses H2 in-memory database.
 */
public class VehicleDAOTestHelper {

    public List<Vehicle> getVehiclesByDriver(int driverId) {
        List<Vehicle> list = new ArrayList<>();
        String sql = "SELECT * FROM vehicles WHERE driver_id=?";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, driverId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Vehicle v = mapResultSetToVehicle(rs);
                    list.add(v);
                }
            }

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching vehicles for driver " + driverId, e);
        }
        return list;
    }

    public boolean addVehicle(Vehicle v) {
        String sql = "INSERT INTO vehicles (driver_id, vehicle_type, brand, model, plate_number, picture, fare_first_km, fare_next_km) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, v.getDriverId());
            stmt.setString(2, v.getVehicleType());
            stmt.setString(3, v.getBrand());
            stmt.setString(4, v.getModel());
            stmt.setString(5, v.getPlateNumber());
            stmt.setBytes(6, v.getPicture());
            stmt.setDouble(7, v.getFareFirstKm());
            stmt.setDouble(8, v.getFareNextKm());

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        v.setId(rs.getInt(1));
                    }
                }
                return true;
            }

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error adding vehicle", e);
        }
        return false;
    }

    public boolean updateVehicle(Vehicle v) {
        String sql = "UPDATE vehicles SET vehicle_type=?, brand=?, model=?, plate_number=?, picture=?, fare_first_km=?, fare_next_km=? WHERE id=?";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, v.getVehicleType());
            stmt.setString(2, v.getBrand());
            stmt.setString(3, v.getModel());
            stmt.setString(4, v.getPlateNumber());
            stmt.setBytes(5, v.getPicture());
            stmt.setDouble(6, v.getFareFirstKm());
            stmt.setDouble(7, v.getFareNextKm());
            stmt.setInt(8, v.getId());

            return stmt.executeUpdate() > 0;

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error updating vehicle with ID " + v.getId(), e);
        }
    }

    public boolean deleteVehicle(int id) {
        String sql = "DELETE FROM vehicles WHERE id=?";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error deleting vehicle with ID " + id, e);
        }
    }

    public Vehicle getVehicleById(int id) {
        String sql = "SELECT * FROM vehicles WHERE id=?";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVehicle(rs);
                }
            }

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching vehicle with ID " + id, e);
        }
        return null;
    }

    private Vehicle mapResultSetToVehicle(ResultSet rs) throws SQLException {
        Vehicle v = new Vehicle();
        v.setId(rs.getInt("id"));
        v.setDriverId(rs.getInt("driver_id"));
        v.setVehicleType(rs.getString("vehicle_type"));
        v.setBrand(rs.getString("brand"));
        v.setModel(rs.getString("model"));
        v.setPlateNumber(rs.getString("plate_number"));
        v.setPicture(rs.getBytes("picture"));
        v.setFareFirstKm(rs.getDouble("fare_first_km"));
        v.setFareNextKm(rs.getDouble("fare_next_km"));
        return v;
    }
}
