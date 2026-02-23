package com.dailyfixer.diagnostic.dao;

import com.dailyfixer.model.Category;
import com.dailyfixer.util.TestDBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Test version of CategoryDAO for diagnostic categories using H2 in-memory database.
 */
public class CategoryDAOTestHelper {

    public List<Category> getAllMainCategories() throws Exception {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM diagnostic_categories WHERE parent_id IS NULL ORDER BY name";

        try (Connection con = TestDBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(mapResultSetToCategory(rs));
            }
        }
        return categories;
    }

    public List<Category> getSubCategories(int parentId) throws Exception {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM diagnostic_categories WHERE parent_id = ? ORDER BY name";

        try (Connection con = TestDBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    categories.add(mapResultSetToCategory(rs));
                }
            }
        }
        return categories;
    }

    public Category getCategoryById(int categoryId) throws Exception {
        String sql = "SELECT * FROM diagnostic_categories WHERE category_id = ?";

        try (Connection con = TestDBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCategory(rs);
                }
            }
        }
        return null;
    }

    public int createCategory(Category category) throws Exception {
        String sql = "INSERT INTO diagnostic_categories (name, parent_id) VALUES (?, ?)";

        try (Connection con = TestDBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, category.getName());
            if (category.getParentId() != null) {
                ps.setInt(2, category.getParentId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    public boolean updateCategory(int categoryId, String newName) throws Exception {
        String sql = "UPDATE diagnostic_categories SET name = ? WHERE category_id = ?";

        try (Connection con = TestDBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newName);
            ps.setInt(2, categoryId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteCategory(int categoryId) throws Exception {
        String sql = "DELETE FROM diagnostic_categories WHERE category_id = ?";

        try (Connection con = TestDBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            return ps.executeUpdate() > 0;
        }
    }

    private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setCategoryId(rs.getInt("category_id"));
        category.setName(rs.getString("name"));
        Integer parentId = rs.getObject("parent_id", Integer.class);
        category.setParentId(parentId);
        category.setCreatedAt(rs.getTimestamp("created_at"));
        return category;
    }
}
