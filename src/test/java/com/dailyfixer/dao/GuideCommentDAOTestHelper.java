package com.dailyfixer.dao;

import com.dailyfixer.model.GuideComment;
import com.dailyfixer.util.TestDBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Test version of GuideCommentDAO that uses H2 in-memory database.
 */
public class GuideCommentDAOTestHelper {

    public int addComment(int guideId, int userId, String comment) {
        String sql = "INSERT INTO guide_comments (guide_id, user_id, comment) VALUES (?, ?, ?)";

        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            ps.setString(3, comment);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<GuideComment> getCommentsByGuide(int guideId) {
        List<GuideComment> comments = new ArrayList<>();
        String sql = "SELECT c.*, u.username, u.first_name FROM guide_comments c " +
                "JOIN users u ON c.user_id = u.user_id " +
                "WHERE c.guide_id = ? ORDER BY c.created_at DESC";

        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GuideComment comment = new GuideComment();
                    comment.setCommentId(rs.getInt("comment_id"));
                    comment.setGuideId(rs.getInt("guide_id"));
                    comment.setUserId(rs.getInt("user_id"));
                    comment.setComment(rs.getString("comment"));
                    comment.setCreatedAt(rs.getTimestamp("created_at"));
                    comment.setUsername(rs.getString("username"));
                    comment.setUserFirstName(rs.getString("first_name"));
                    comments.add(comment);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return comments;
    }

    public int getCommentCount(int guideId) {
        String sql = "SELECT COUNT(*) FROM guide_comments WHERE guide_id = ?";
        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean deleteComment(int commentId) {
        String sql = "DELETE FROM guide_comments WHERE comment_id = ?";
        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
