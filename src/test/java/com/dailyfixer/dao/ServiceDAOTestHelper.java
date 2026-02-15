package com.dailyfixer.dao;

import com.dailyfixer.model.Service;
import com.dailyfixer.util.TestDBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Test version of ServiceDAO that uses H2 in-memory database.
 */
public class ServiceDAOTestHelper {

    public void addService(Service s) throws Exception {
        String sql = "INSERT INTO services (technician_id, service_name, description, category, pricing_type, fixed_rate, hourly_rate, inspection_charge, transport_charge, available_dates, service_image, image_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, s.getTechnicianId());
            ps.setString(2, s.getServiceName());
            ps.setString(3, s.getDescription());
            ps.setString(4, s.getCategory());
            ps.setString(5, s.getPricingType());
            ps.setObject(6, s.getFixedRate() == 0 ? null : s.getFixedRate());
            ps.setObject(7, s.getHourlyRate() == 0 ? null : s.getHourlyRate());
            ps.setObject(8, s.getInspectionCharge());
            ps.setObject(9, s.getTransportCharge());
            ps.setString(10, s.getAvailableDates());
            ps.setBytes(11, s.getServiceImage());
            ps.setString(12, s.getImageType());
            ps.executeUpdate();
        }
    }

    public Service getServiceById(int serviceId) throws Exception {
        String sql = "SELECT * FROM services WHERE service_id=?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Service s = new Service();
                    s.setServiceId(rs.getInt("service_id"));
                    s.setTechnicianId(rs.getInt("technician_id"));
                    s.setServiceName(rs.getString("service_name"));
                    s.setDescription(rs.getString("description"));
                    s.setCategory(rs.getString("category"));
                    s.setPricingType(rs.getString("pricing_type"));
                    s.setFixedRate(rs.getDouble("fixed_rate"));
                    s.setHourlyRate(rs.getDouble("hourly_rate"));
                    s.setInspectionCharge(rs.getDouble("inspection_charge"));
                    s.setTransportCharge(rs.getDouble("transport_charge"));
                    s.setAvailableDates(rs.getString("available_dates"));
                    s.setServiceImage(rs.getBytes("service_image"));
                    s.setImageType(rs.getString("image_type"));
                    return s;
                }
            }
        }
        return null;
    }

    public List<Service> getServicesByTechnician(int technicianId) throws Exception {
        List<Service> list = new ArrayList<>();
        String sql = "SELECT * FROM services WHERE technician_id=?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Service s = new Service();
                    s.setServiceId(rs.getInt("service_id"));
                    s.setTechnicianId(rs.getInt("technician_id"));
                    s.setServiceName(rs.getString("service_name"));
                    s.setDescription(rs.getString("description"));
                    s.setCategory(rs.getString("category"));
                    s.setPricingType(rs.getString("pricing_type"));
                    s.setFixedRate(rs.getDouble("fixed_rate"));
                    s.setHourlyRate(rs.getDouble("hourly_rate"));
                    s.setInspectionCharge(rs.getDouble("inspection_charge"));
                    s.setTransportCharge(rs.getDouble("transport_charge"));
                    s.setAvailableDates(rs.getString("available_dates"));
                    s.setImageType(rs.getString("image_type"));
                    list.add(s);
                }
            }
        }
        return list;
    }

    public void deleteService(int serviceId) throws Exception {
        String sql = "DELETE FROM services WHERE service_id = ?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, serviceId);
            ps.executeUpdate();
        }
    }
}
