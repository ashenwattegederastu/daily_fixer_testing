package com.dailyfixer.dao;

import com.dailyfixer.model.User;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for GuideRatingDAO using H2 in-memory database.
 */
class GuideRatingDAOTest {

    private GuideRatingDAOTestHelper ratingDAO;
    private UserDAOTestHelper userDAO;
    private int testUserId;
    private static final int TEST_GUIDE_ID = 1;

    @BeforeEach
    void setUp() throws Exception {
        ratingDAO = new GuideRatingDAOTestHelper();
        userDAO = new UserDAOTestHelper();
        TestDBConnection.clearAllTables();

        // Create test user
        User user = new User();
        user.setFirstName("Rater");
        user.setLastName("Test");
        user.setUsername("rater");
        user.setEmail("rater@test.com");
        user.setPassword("password");
        user.setPhoneNumber("1234567890");
        user.setCity("Test City");
        user.setRole("user");
        testUserId = userDAO.saveUser(user);
    }

    @Test
    @DisplayName("Should add upvote rating")
    void testAddUpvoteRating() {
        // Act
        boolean result = ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "UP");

        // Assert
        assertTrue(result);
        String rating = ratingDAO.getUserRating(TEST_GUIDE_ID, testUserId);
        assertEquals("UP", rating);
    }

    @Test
    @DisplayName("Should add downvote rating")
    void testAddDownvoteRating() {
        // Act
        boolean result = ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "DOWN");

        // Assert
        assertTrue(result);
        String rating = ratingDAO.getUserRating(TEST_GUIDE_ID, testUserId);
        assertEquals("DOWN", rating);
    }

    @Test
    @DisplayName("Should update existing rating")
    void testUpdateRating() {
        // Arrange
        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "UP");

        // Act
        boolean result = ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "DOWN");

        // Assert
        assertTrue(result);
        String rating = ratingDAO.getUserRating(TEST_GUIDE_ID, testUserId);
        assertEquals("DOWN", rating);
    }

    @Test
    @DisplayName("Should return null for user with no rating")
    void testGetUserRating_NoRating() {
        // Act
        String rating = ratingDAO.getUserRating(TEST_GUIDE_ID, testUserId);

        // Assert
        assertNull(rating);
    }

    @Test
    @DisplayName("Should remove rating successfully")
    void testRemoveRating() {
        // Arrange
        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "UP");

        // Act
        boolean removed = ratingDAO.removeRating(TEST_GUIDE_ID, testUserId);

        // Assert
        assertTrue(removed);
        String rating = ratingDAO.getUserRating(TEST_GUIDE_ID, testUserId);
        assertNull(rating);
    }

    @Test
    @DisplayName("Should count up and down votes correctly")
    void testGetRatingCounts() throws Exception {
        // Arrange
        User user2 = new User();
        user2.setFirstName("User2");
        user2.setLastName("Test");
        user2.setUsername("user2");
        user2.setEmail("user2@test.com");
        user2.setPassword("password");
        user2.setPhoneNumber("9876543210");
        user2.setCity("Test City");
        user2.setRole("user");
        int user2Id = userDAO.saveUser(user2);

        User user3 = new User();
        user3.setFirstName("User3");
        user3.setLastName("Test");
        user3.setUsername("user3");
        user3.setEmail("user3@test.com");
        user3.setPassword("password");
        user3.setPhoneNumber("5555555555");
        user3.setCity("Test City");
        user3.setRole("user");
        int user3Id = userDAO.saveUser(user3);

        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "UP");
        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, user2Id, "UP");
        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, user3Id, "DOWN");

        // Act
        int[] counts = ratingDAO.getRatingCounts(TEST_GUIDE_ID);

        // Assert
        assertEquals(2, counts[0], "Should have 2 upvotes");
        assertEquals(1, counts[1], "Should have 1 downvote");
    }

    @Test
    @DisplayName("Should return zero counts for guide with no ratings")
    void testGetRatingCounts_Empty() {
        // Act
        int[] counts = ratingDAO.getRatingCounts(TEST_GUIDE_ID);

        // Assert
        assertEquals(0, counts[0]);
        assertEquals(0, counts[1]);
    }

    @Test
    @DisplayName("Should isolate ratings between different guides")
    void testGuideIsolation() {
        // Arrange
        int guide1 = 1;
        int guide2 = 2;
        ratingDAO.addOrUpdateRating(guide1, testUserId, "UP");
        ratingDAO.addOrUpdateRating(guide2, testUserId, "DOWN");

        // Act
        String guide1Rating = ratingDAO.getUserRating(guide1, testUserId);
        String guide2Rating = ratingDAO.getUserRating(guide2, testUserId);

        // Assert
        assertEquals("UP", guide1Rating);
        assertEquals("DOWN", guide2Rating);
    }

    @Test
    @DisplayName("Should enforce one rating per user per guide")
    void testUniqueRatingConstraint() {
        // Act - Add rating twice, should update not duplicate
        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "UP");
        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "UP");

        int[] counts = ratingDAO.getRatingCounts(TEST_GUIDE_ID);

        // Assert - Should only have one rating
        assertEquals(1, counts[0]);
        assertEquals(0, counts[1]);
    }

    @Test
    @DisplayName("Should allow changing vote from up to down and back")
    void testVoteToggle() {
        // Act & Assert - UP
        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "UP");
        assertEquals("UP", ratingDAO.getUserRating(TEST_GUIDE_ID, testUserId));

        // Act & Assert - DOWN
        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "DOWN");
        assertEquals("DOWN", ratingDAO.getUserRating(TEST_GUIDE_ID, testUserId));

        // Act & Assert - UP again
        ratingDAO.addOrUpdateRating(TEST_GUIDE_ID, testUserId, "UP");
        assertEquals("UP", ratingDAO.getUserRating(TEST_GUIDE_ID, testUserId));
    }
}
