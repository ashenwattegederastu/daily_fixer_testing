package com.dailyfixer.dao;

import com.dailyfixer.model.Guide;
import com.dailyfixer.model.GuideStep;
import com.dailyfixer.util.TestDBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Test helper for GuideDAO that uses H2 in-memory database.
 */
public class GuideDAOTestHelper {

    public int addGuide(Guide guide, List<String> requirements, List<GuideStep> steps) throws Exception {
        String guideSQL = "INSERT INTO guides (title, main_image_path, main_category, sub_category, youtube_url, created_by, created_role) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String reqSQL = "INSERT INTO guide_requirements (guide_id, requirement) VALUES (?, ?)";
        String stepSQL = "INSERT INTO guide_steps (guide_id, step_order, step_title, step_body) VALUES (?, ?, ?, ?)";
        String imageSQL = "INSERT INTO guide_step_images (step_id, image_path) VALUES (?, ?)";

        try (Connection conn = TestDBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // Insert guide
            int guideId;
            try (PreparedStatement ps = conn.prepareStatement(guideSQL, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, guide.getTitle());
                ps.setString(2, guide.getMainImagePath());
                ps.setString(3, guide.getMainCategory());
                ps.setString(4, guide.getSubCategory());
                ps.setString(5, guide.getYoutubeUrl());
                ps.setInt(6, guide.getCreatedBy());
                ps.setString(7, guide.getCreatedRole());
                ps.executeUpdate();

                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    guideId = rs.getInt(1);
                } else {
                    conn.rollback();
                    return -1;
                }
            }

            // Insert requirements
            if (requirements != null && !requirements.isEmpty()) {
                try (PreparedStatement psReq = conn.prepareStatement(reqSQL)) {
                    for (String req : requirements) {
                        if (req != null && !req.trim().isEmpty()) {
                            psReq.setInt(1, guideId);
                            psReq.setString(2, req.trim());
                            psReq.addBatch();
                        }
                    }
                    psReq.executeBatch();
                }
            }

            // Insert steps and their images
            if (steps != null && !steps.isEmpty()) {
                try (PreparedStatement psStep = conn.prepareStatement(stepSQL, Statement.RETURN_GENERATED_KEYS)) {
                    for (int i = 0; i < steps.size(); i++) {
                        GuideStep step = steps.get(i);
                        psStep.setInt(1, guideId);
                        psStep.setInt(2, i + 1); // step_order
                        psStep.setString(3, step.getStepTitle());
                        psStep.setString(4, step.getStepBody());
                        psStep.executeUpdate();

                        ResultSet rsStep = psStep.getGeneratedKeys();
                        if (rsStep.next()) {
                            int stepId = rsStep.getInt(1);

                            // Insert step images
                            if (step.getImagePaths() != null && !step.getImagePaths().isEmpty()) {
                                try (PreparedStatement psImg = conn.prepareStatement(imageSQL)) {
                                    for (String imgPath : step.getImagePaths()) {
                                        if (imgPath != null && !imgPath.isEmpty()) {
                                            psImg.setInt(1, stepId);
                                            psImg.setString(2, imgPath);
                                            psImg.addBatch();
                                        }
                                    }
                                    psImg.executeBatch();
                                }
                            }
                        }
                    }
                }
            }

            conn.commit();
            return guideId;

        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    public List<Guide> getAllGuides() throws Exception {
        List<Guide> list = new ArrayList<>();
        String sql = "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                "JOIN users u ON g.created_by = u.user_id " +
                "ORDER BY g.created_at DESC";

        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Guide g = mapGuideFromResultSet(rs);
                g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                list.add(g);
            }
        }
        return list;
    }

    public List<Guide> getGuidesByCreator(int userId) throws Exception {
        List<Guide> list = new ArrayList<>();
        String sql = "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                "JOIN users u ON g.created_by = u.user_id " +
                "WHERE g.created_by = ? ORDER BY g.created_at DESC";

        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Guide g = mapGuideFromResultSet(rs);
                    g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    list.add(g);
                }
            }
        }
        return list;
    }

    public List<Guide> searchGuides(String keyword, String mainCategory, String subCategory) throws Exception {
        List<Guide> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                        "JOIN users u ON g.created_by = u.user_id WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND g.title LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        if (mainCategory != null && !mainCategory.trim().isEmpty()) {
            sql.append(" AND g.main_category = ? ");
            params.add(mainCategory.trim());
        }
        if (subCategory != null && !subCategory.trim().isEmpty()) {
            sql.append(" AND g.sub_category = ? ");
            params.add(subCategory.trim());
        }

        sql.append(" ORDER BY g.created_at DESC");

        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Guide g = mapGuideFromResultSet(rs);
                    g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    list.add(g);
                }
            }
        }
        return list;
    }

    public Guide getGuideById(int guideId) throws Exception {
        Guide guide = null;

        try (Connection conn = TestDBConnection.getConnection()) {
            // Get guide main info
            String sql = "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                    "JOIN users u ON g.created_by = u.user_id WHERE g.guide_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, guideId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        guide = mapGuideFromResultSet(rs);
                        guide.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    }
                }
            }

            if (guide != null) {
                // Get requirements
                guide.setRequirements(getRequirementsByGuideId(conn, guideId));

                // Get steps with images
                guide.setSteps(getStepsByGuideId(conn, guideId));
            }
        }
        return guide;
    }

    public void incrementViewCount(int guideId) throws Exception {
        String sql = "UPDATE guides SET view_count = view_count + 1 WHERE guide_id = ?";
        
        try (Connection conn = TestDBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.executeUpdate();
        }
    }

    private List<String> getRequirementsByGuideId(Connection conn, int guideId) throws SQLException {
        List<String> requirements = new ArrayList<>();
        String sql = "SELECT requirement FROM guide_requirements WHERE guide_id = ? ORDER BY req_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requirements.add(rs.getString("requirement"));
                }
            }
        }
        return requirements;
    }

    private List<GuideStep> getStepsByGuideId(Connection conn, int guideId) throws SQLException {
        List<GuideStep> steps = new ArrayList<>();
        String sql = "SELECT * FROM guide_steps WHERE guide_id = ? ORDER BY step_order";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GuideStep step = new GuideStep();
                    step.setStepId(rs.getInt("step_id"));
                    step.setGuideId(rs.getInt("guide_id"));
                    step.setStepOrder(rs.getInt("step_order"));
                    step.setStepTitle(rs.getString("step_title"));
                    step.setStepBody(rs.getString("step_body"));

                    // Get step images
                    step.setImagePaths(getStepImages(conn, step.getStepId()));
                    steps.add(step);
                }
            }
        }
        return steps;
    }

    private List<String> getStepImages(Connection conn, int stepId) throws SQLException {
        List<String> images = new ArrayList<>();
        String sql = "SELECT image_path FROM guide_step_images WHERE step_id = ? ORDER BY image_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, stepId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    images.add(rs.getString("image_path"));
                }
            }
        }
        return images;
    }

    private Guide mapGuideFromResultSet(ResultSet rs) throws SQLException {
        Guide guide = new Guide();
        guide.setGuideId(rs.getInt("guide_id"));
        guide.setTitle(rs.getString("title"));
        guide.setMainImagePath(rs.getString("main_image_path"));
        guide.setMainCategory(rs.getString("main_category"));
        guide.setSubCategory(rs.getString("sub_category"));
        guide.setYoutubeUrl(rs.getString("youtube_url"));
        guide.setCreatedBy(rs.getInt("created_by"));
        guide.setCreatedRole(rs.getString("created_role"));
        guide.setCreatedAt(rs.getTimestamp("created_at"));
        guide.setUpdatedAt(rs.getTimestamp("updated_at"));
        guide.setViewCount(rs.getInt("view_count"));
        return guide;
    }
}
