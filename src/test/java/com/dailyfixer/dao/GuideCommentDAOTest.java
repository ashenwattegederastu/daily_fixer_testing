package com.dailyfixer.dao;

import com.dailyfixer.model.GuideComment;
import com.dailyfixer.model.User;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for GuideCommentDAO using H2 in-memory database.
 */
class GuideCommentDAOTest {

    private GuideCommentDAOTestHelper commentDAO;
    private UserDAOTestHelper userDAO;
    private int testUserId;
    private static final int TEST_GUIDE_ID = 1;

    @BeforeEach
    void setUp() throws Exception {
        commentDAO = new GuideCommentDAOTestHelper();
        userDAO = new UserDAOTestHelper();
        TestDBConnection.clearAllTables();

        // Create test user
        User user = new User();
        user.setFirstName("Commenter");
        user.setLastName("Test");
        user.setUsername("commenter");
        user.setEmail("commenter@test.com");
        user.setPassword("password");
        user.setPhoneNumber("1234567890");
        user.setCity("Test City");
        user.setRole("user");
        testUserId = userDAO.saveUser(user);
    }

    @Test
    @DisplayName("Should add comment and return generated ID")
    void testAddComment() {
        // Act
        int commentId = commentDAO.addComment(TEST_GUIDE_ID, testUserId, "Great guide!");

        // Assert
        assertTrue(commentId > 0, "Comment ID should be generated");
    }

    @Test
    @DisplayName("Should retrieve comments by guide")
    void testGetCommentsByGuide() {
        // Arrange
        commentDAO.addComment(TEST_GUIDE_ID, testUserId, "First comment");
        commentDAO.addComment(TEST_GUIDE_ID, testUserId, "Second comment");

        // Act
        List<GuideComment> comments = commentDAO.getCommentsByGuide(TEST_GUIDE_ID);

        // Assert
        assertEquals(2, comments.size());
        assertEquals("commenter", comments.get(0).getUsername());
        assertEquals("Commenter", comments.get(0).getUserFirstName());
    }

    @Test
    @DisplayName("Should return empty list for guide with no comments")
    void testGetCommentsByGuide_Empty() {
        // Act
        List<GuideComment> comments = commentDAO.getCommentsByGuide(TEST_GUIDE_ID);

        // Assert
        assertNotNull(comments);
        assertEquals(0, comments.size());
    }

    @Test
    @DisplayName("Should count comments correctly")
    void testGetCommentCount() {
        // Arrange
        for (int i = 0; i < 5; i++) {
            commentDAO.addComment(TEST_GUIDE_ID, testUserId, "Comment " + i);
        }

        // Act
        int count = commentDAO.getCommentCount(TEST_GUIDE_ID);

        // Assert
        assertEquals(5, count);
    }

    @Test
    @DisplayName("Should delete comment successfully")
    void testDeleteComment() {
        // Arrange
        int commentId = commentDAO.addComment(TEST_GUIDE_ID, testUserId, "To be deleted");

        // Act
        boolean deleted = commentDAO.deleteComment(commentId);

        // Assert
        assertTrue(deleted);
        assertEquals(0, commentDAO.getCommentCount(TEST_GUIDE_ID));
    }

    @Test
    @DisplayName("Should handle long comments")
    void testLongComment() {
        // Arrange
        String longComment = "This is a very long comment. ".repeat(20);

        // Act
        int commentId = commentDAO.addComment(TEST_GUIDE_ID, testUserId, longComment);
        List<GuideComment> comments = commentDAO.getCommentsByGuide(TEST_GUIDE_ID);

        // Assert
        assertEquals(1, comments.size());
        assertEquals(longComment, comments.get(0).getComment());
    }

    @Test
    @DisplayName("Should isolate comments between different guides")
    void testGuideIsolation() {
        // Arrange
        int guide1 = 1;
        int guide2 = 2;
        commentDAO.addComment(guide1, testUserId, "Guide 1 comment");
        commentDAO.addComment(guide2, testUserId, "Guide 2 comment");

        // Act
        List<GuideComment> guide1Comments = commentDAO.getCommentsByGuide(guide1);
        List<GuideComment> guide2Comments = commentDAO.getCommentsByGuide(guide2);

        // Assert
        assertEquals(1, guide1Comments.size());
        assertEquals(1, guide2Comments.size());
        assertTrue(guide1Comments.get(0).getComment().contains("Guide 1"));
        assertTrue(guide2Comments.get(0).getComment().contains("Guide 2"));
    }

    @Test
    @DisplayName("Should handle multiple users commenting")
    void testMultipleUsers() throws Exception {
        // Arrange
        User user2 = new User();
        user2.setFirstName("Another");
        user2.setLastName("User");
        user2.setUsername("user2");
        user2.setEmail("user2@test.com");
        user2.setPassword("password");
        user2.setPhoneNumber("9876543210");
        user2.setCity("Test City");
        user2.setRole("user");
        int user2Id = userDAO.saveUser(user2);

        commentDAO.addComment(TEST_GUIDE_ID, testUserId, "User 1 comment");
        commentDAO.addComment(TEST_GUIDE_ID, user2Id, "User 2 comment");

        // Act
        List<GuideComment> comments = commentDAO.getCommentsByGuide(TEST_GUIDE_ID);

        // Assert
        assertEquals(2, comments.size());
        assertTrue(comments.stream().anyMatch(c -> c.getUsername().equals("commenter")));
        assertTrue(comments.stream().anyMatch(c -> c.getUsername().equals("user2")));
    }
}
