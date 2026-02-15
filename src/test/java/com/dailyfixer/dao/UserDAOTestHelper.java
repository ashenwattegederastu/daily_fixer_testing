package com.dailyfixer.dao;

import com.dailyfixer.model.User;
import com.dailyfixer.util.TestDBConnection;

import java.sql.*;

/**
 * Test version of UserDAO that uses H2 in-memory database.
 * This is a copy of the production UserDAO but uses TestDBConnection.
 */
public class UserDAOTestHelper {

    public boolean isUsernameTaken(String username) throws Exception {
        String sql = "SELECT user_id FROM users WHERE username = ?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean isEmailTaken(String email) throws Exception {
        String sql = "SELECT user_id FROM users WHERE email = ?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public int saveUser(User user) {
        String sql = "INSERT INTO users (first_name, last_name, username, email, password, phone_number, city, role) VALUES (?,?,?,?,?,?,?,?)";
        int userId = -1;

        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getFirstName());
            ps.setString(2, user.getLastName());
            ps.setString(3, user.getUsername());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPassword());
            ps.setString(6, user.getPhoneNumber());
            ps.setString(7, user.getCity());
            ps.setString(8, user.getRole());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        userId = rs.getInt(1);
                        user.setUserId(userId);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            userId = -1;
        }

        return userId;
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setFirstName(rs.getString("first_name"));
                    u.setLastName(rs.getString("last_name"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setPassword(rs.getString("password"));
                    u.setPhoneNumber(rs.getString("phone_number"));
                    u.setCity(rs.getString("city"));
                    u.setRole(rs.getString("role"));
                    return u;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findByUsernameAndPassword(String username, String hashedPassword) throws Exception {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ? AND status = 'active'";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashedPassword);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setFirstName(rs.getString("first_name"));
                    u.setLastName(rs.getString("last_name"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setPhoneNumber(rs.getString("phone_number"));
                    u.setCity(rs.getString("city"));
                    u.setRole(rs.getString("role"));
                    return u;
                }
            }
        }
        return null;
    }
}
