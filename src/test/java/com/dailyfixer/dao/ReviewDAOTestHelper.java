package com.dailyfixer.dao;

import com.dailyfixer.model.Review;
import com.dailyfixer.util.TestDBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Test version of ReviewDAO that uses H2 in-memory database.
 */
public class ReviewDAOTestHelper {

    public void addReview(Review review) throws Exception {
        String sql = "INSERT INTO product_reviews (product_id, user_id, rating, comment, created_at) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, review.getProductId());
            ps.setInt(2, review.getUserId());
            ps.setInt(3, review.getRating());
            ps.setString(4, review.getComment());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    review.setReviewId(rs.getInt(1));
                }
            }
        }
    }

    public List<Review> getReviewsByProductId(int productId) throws Exception {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT r.*, u.username " +
                     "FROM product_reviews r " +
                     "LEFT JOIN users u ON r.user_id = u.user_id " +
                     "WHERE r.product_id = ? " +
                     "ORDER BY r.created_at DESC";
        
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review review = new Review();
                    review.setReviewId(rs.getInt("review_id"));
                    review.setProductId(rs.getInt("product_id"));
                    review.setUserId(rs.getInt("user_id"));
                    review.setUsername(rs.getString("username"));
                    review.setRating(rs.getInt("rating"));
                    review.setComment(rs.getString("comment"));
                    review.setCreatedAt(rs.getTimestamp("created_at"));
                    reviews.add(review);
                }
            }
        }
        return reviews;
    }

    public double getAverageRating(int productId) throws Exception {
        String sql = "SELECT AVG(rating) as avg_rating FROM product_reviews WHERE product_id = ?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double avg = rs.getDouble("avg_rating");
                    return rs.wasNull() ? 0.0 : avg;
                }
            }
        }
        return 0.0;
    }

    public int getReviewCount(int productId) throws Exception {
        String sql = "SELECT COUNT(*) as count FROM product_reviews WHERE product_id = ?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        return 0;
    }

    public void deleteReview(int reviewId) throws Exception {
        String sql = "DELETE FROM product_reviews WHERE review_id = ?";
        try (Connection con = TestDBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.executeUpdate();
        }
    }
}
