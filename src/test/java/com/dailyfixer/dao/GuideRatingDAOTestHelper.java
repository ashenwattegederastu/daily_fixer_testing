package com.dailyfixer.dao;

import com.dailyfixer.util.TestDBConnection;

import java.sql.*;

/**
 * Test version of GuideRatingDAO that uses H2 in-memory database.
 */
public class GuideRatingDAOTestHelper {

    public boolean addOrUpdateRating(int guideId, int userId, String rating) {
        // H2 doesn't support ON DUPLICATE KEY UPDATE, so we'll use MERGE
        String sql = "MERGE INTO guide_ratings (guide_id, user_id, rating) KEY(guide_id, user_id) VALUES (?, ?, ?)";

        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            ps.setString(3, rating);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public String getUserRating(int guideId, int userId) {
        String sql = "SELECT rating FROM guide_ratings WHERE guide_id = ? AND user_id = ?";
        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("rating");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean removeRating(int guideId, int userId) {
        String sql = "DELETE FROM guide_ratings WHERE guide_id = ? AND user_id = ?";
        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int[] getRatingCounts(int guideId) {
        String sql = "SELECT " +
                "SUM(CASE WHEN rating = 'UP' THEN 1 ELSE 0 END) AS up_count, " +
                "SUM(CASE WHEN rating = 'DOWN' THEN 1 ELSE 0 END) AS down_count " +
                "FROM guide_ratings WHERE guide_id = ?";
        
        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[] { rs.getInt("up_count"), rs.getInt("down_count") };
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new int[] { 0, 0 };
    }
}
