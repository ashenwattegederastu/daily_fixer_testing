package com.dailyfixer.dao;

import com.dailyfixer.model.GuideCategory;
import com.dailyfixer.model.GuideSubCategory;
import com.dailyfixer.util.TestDBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Test version of GuideCategoryDAO that uses H2 in-memory database.
 */
public class GuideCategoryDAOTestHelper {

    public List<GuideCategory> getAllCategories() {
        List<GuideCategory> categories = new ArrayList<>();
        String sql = "SELECT category_id, name, created_at FROM guide_categories ORDER BY name";

        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                GuideCategory cat = new GuideCategory();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setName(rs.getString("name"));
                cat.setCreatedAt(rs.getTimestamp("created_at"));
                categories.add(cat);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return categories;
    }

    public List<GuideSubCategory> getSubCategoriesByCategoryId(int categoryId) {
        List<GuideSubCategory> subCategories = new ArrayList<>();
        String sql = "SELECT sub_category_id, category_id, name, created_at " +
                "FROM guide_sub_categories WHERE category_id = ? ORDER BY name";

        try (Connection conn = TestDBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, categoryId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    GuideSubCategory sub = new GuideSubCategory();
                    sub.setSubCategoryId(rs.getInt("sub_category_id"));
                    sub.setCategoryId(rs.getInt("category_id"));
                    sub.setName(rs.getString("name"));
                    sub.setCreatedAt(rs.getTimestamp("created_at"));
                    subCategories.add(sub);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return subCategories;
    }

    public int addCategory(String name) {
        String sql = "INSERT INTO guide_categories (name) VALUES (?)";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, name);
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public int addSubCategory(int categoryId, String name) {
        String sql = "INSERT INTO guide_sub_categories (category_id, name) VALUES (?, ?)";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, categoryId);
            stmt.setString(2, name);
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public GuideCategory getCategoryById(int categoryId) {
        String sql = "SELECT category_id, name, created_at FROM guide_categories WHERE category_id = ?";
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, categoryId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    GuideCategory cat = new GuideCategory();
                    cat.setCategoryId(rs.getInt("category_id"));
                    cat.setName(rs.getString("name"));
                    cat.setCreatedAt(rs.getTimestamp("created_at"));
                    return cat;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
