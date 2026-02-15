package com.dailyfixer.diagnostic.dao;

import com.dailyfixer.diagnostic.model.TreeRating;
import com.dailyfixer.model.User;
import com.dailyfixer.dao.UserDAOTestHelper;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for TreeRatingDAO using H2 in-memory database.
 */
class TreeRatingDAOTest {

    private TreeRatingDAOTestHelper ratingDAO;
    private UserDAOTestHelper userDAO;
    private int testUserId;
    private static final int TEST_TREE_ID = 1;

    @BeforeEach
    void setUp() throws Exception {
        ratingDAO = new TreeRatingDAOTestHelper();
        userDAO = new UserDAOTestHelper();
        TestDBConnection.clearAllTables();

        User user = new User();
        user.setFirstName("Test");
        user.setLastName("User");
        user.setUsername("testuser");
        user.setEmail("test@test.com");
        user.setPassword("password");
        user.setPhoneNumber("1234567890");
        user.setCity("City");
        user.setRole("user");
        testUserId = userDAO.saveUser(user);
    }

    @Test
    @DisplayName("Should add rating")
    void testAddRating() throws Exception {
        TreeRating rating = new TreeRating();
        rating.setTreeId(TEST_TREE_ID);
        rating.setUserId(testUserId);
        rating.setRating(5);
        rating.setFeedback("Great!");
        
        boolean result = ratingDAO.addOrUpdateRating(rating);
        
        assertTrue(result);
        assertEquals(5, ratingDAO.getUserRating(TEST_TREE_ID, testUserId).getRating());
    }

    @Test
    @DisplayName("Should update existing rating")
    void testUpdateRating() throws Exception {
        TreeRating rating = new TreeRating();
        rating.setTreeId(TEST_TREE_ID);
        rating.setUserId(testUserId);
        rating.setRating(3);
        ratingDAO.addOrUpdateRating(rating);
        
        rating.setRating(5);
        ratingDAO.addOrUpdateRating(rating);
        
        assertEquals(5, ratingDAO.getUserRating(TEST_TREE_ID, testUserId).getRating());
    }

    @Test
    @DisplayName("Should calculate average rating")
    void testGetAverageRating() throws Exception {
        User u2 = new User();
        u2.setFirstName("U2");
        u2.setLastName("Test");
        u2.setUsername("user2");
        u2.setEmail("u2@test.com");
        u2.setPassword("password");
        u2.setPhoneNumber("9876543210");
        u2.setCity("City");
        u2.setRole("user");
        int u2Id = userDAO.saveUser(u2);
        
        TreeRating r1 = new TreeRating();
        r1.setTreeId(TEST_TREE_ID);
        r1.setUserId(testUserId);
        r1.setRating(5);
        ratingDAO.addOrUpdateRating(r1);
        
        TreeRating r2 = new TreeRating();
        r2.setTreeId(TEST_TREE_ID);
        r2.setUserId(u2Id);
        r2.setRating(3);
        ratingDAO.addOrUpdateRating(r2);
        
        double avg = ratingDAO.getAverageRating(TEST_TREE_ID);
        assertEquals(4.0, avg, 0.01);
    }

    @Test
    @DisplayName("Should get rating count")
    void testGetRatingCount() throws Exception {
        TreeRating rating = new TreeRating();
        rating.setTreeId(TEST_TREE_ID);
        rating.setUserId(testUserId);
        rating.setRating(4);
        ratingDAO.addOrUpdateRating(rating);
        
        int count = ratingDAO.getRatingCount(TEST_TREE_ID);
        assertEquals(1, count);
    }

    @Test
    @DisplayName("Should get rating distribution")
    void testGetRatingDistribution() throws Exception {
        User u2 = new User();
        u2.setFirstName("U2");
        u2.setLastName("Test");
        u2.setUsername("user2");
        u2.setEmail("u2@test.com");
        u2.setPassword("password");
        u2.setPhoneNumber("9876543210");
        u2.setCity("City");
        u2.setRole("user");
        int u2Id = userDAO.saveUser(u2);
        
        TreeRating r1 = new TreeRating();
        r1.setTreeId(TEST_TREE_ID);
        r1.setUserId(testUserId);
        r1.setRating(5);
        ratingDAO.addOrUpdateRating(r1);
        
        TreeRating r2 = new TreeRating();
        r2.setTreeId(TEST_TREE_ID);
        r2.setUserId(u2Id);
        r2.setRating(5);
        ratingDAO.addOrUpdateRating(r2);
        
        int[] dist = ratingDAO.getRatingDistribution(TEST_TREE_ID);
        assertEquals(2, dist[4]); // Two 5-star ratings
    }

    @Test
    @DisplayName("Should delete rating")
    void testDeleteRating() throws Exception {
        TreeRating rating = new TreeRating();
        rating.setTreeId(TEST_TREE_ID);
        rating.setUserId(testUserId);
        rating.setRating(4);
        ratingDAO.addOrUpdateRating(rating);
        
        boolean deleted = ratingDAO.deleteRating(TEST_TREE_ID, testUserId);
        
        assertTrue(deleted);
        assertNull(ratingDAO.getUserRating(TEST_TREE_ID, testUserId));
    }

    @Test
    @DisplayName("Should get ratings with usernames")
    void testGetRatingsForTree() throws Exception {
        TreeRating rating = new TreeRating();
        rating.setTreeId(TEST_TREE_ID);
        rating.setUserId(testUserId);
        rating.setRating(5);
        ratingDAO.addOrUpdateRating(rating);
        
        List<TreeRating> ratings = ratingDAO.getRatingsForTree(TEST_TREE_ID);
        assertEquals(1, ratings.size());
        assertEquals("testuser", ratings.get(0).getUsername());
    }
}
