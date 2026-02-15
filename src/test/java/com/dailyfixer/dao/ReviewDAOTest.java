package com.dailyfixer.dao;

import com.dailyfixer.model.Review;
import com.dailyfixer.model.User;
import com.dailyfixer.model.Product;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for ReviewDAO using H2 in-memory database.
 */
class ReviewDAOTest {

    private ReviewDAOTestHelper reviewDAO;
    private UserDAOTestHelper userDAO;
    private ProductDAOTestHelper productDAO;
    private int testUserId;
    private int testProductId;

    @BeforeEach
    void setUp() throws Exception {
        reviewDAO = new ReviewDAOTestHelper();
        userDAO = new UserDAOTestHelper();
        productDAO = new ProductDAOTestHelper();
        TestDBConnection.clearAllTables();

        // Create test user
        User user = new User();
        user.setFirstName("Test");
        user.setLastName("Reviewer");
        user.setUsername("reviewer");
        user.setEmail("reviewer@test.com");
        user.setPassword("password");
        user.setPhoneNumber("1234567890");
        user.setCity("Test City");
        user.setRole("user");
        testUserId = userDAO.saveUser(user);

        // Create test product
        Product product = new Product();
        product.setName("Test Product");
        product.setType("Test");
        product.setQuantity(10);
        product.setQuantityUnit("pieces");
        product.setPrice(99.99);
        product.setStoreUsername("teststore");
        product.setStoreId(1);
        productDAO.addProduct(product);
        testProductId = product.getProductId();
    }

    @Test
    @DisplayName("Should add review and return generated ID")
    void testAddReview() throws Exception {
        // Arrange
        Review review = new Review();
        review.setProductId(testProductId);
        review.setUserId(testUserId);
        review.setRating(5);
        review.setComment("Excellent product!");

        // Act
        reviewDAO.addReview(review);

        // Assert
        assertTrue(review.getReviewId() > 0, "Review ID should be generated");
    }

    @Test
    @DisplayName("Should retrieve reviews by product ID")
    void testGetReviewsByProductId() throws Exception {
        // Arrange
        Review review1 = new Review();
        review1.setProductId(testProductId);
        review1.setUserId(testUserId);
        review1.setRating(5);
        review1.setComment("Great product!");
        reviewDAO.addReview(review1);

        Review review2 = new Review();
        review2.setProductId(testProductId);
        review2.setUserId(testUserId);
        review2.setRating(4);
        review2.setComment("Good value for money");
        reviewDAO.addReview(review2);

        // Act
        List<Review> reviews = reviewDAO.getReviewsByProductId(testProductId);

        // Assert
        assertEquals(2, reviews.size());
        assertTrue(reviews.stream().anyMatch(r -> r.getRating() == 5));
        assertTrue(reviews.stream().anyMatch(r -> r.getRating() == 4));
    }

    @Test
    @DisplayName("Should return empty list for product with no reviews")
    void testGetReviewsByProductId_NoReviews() throws Exception {
        // Act
        List<Review> reviews = reviewDAO.getReviewsByProductId(9999);

        // Assert
        assertNotNull(reviews);
        assertEquals(0, reviews.size());
    }

    @Test
    @DisplayName("Should calculate average rating correctly")
    void testGetAverageRating() throws Exception {
        // Arrange
        Review review1 = new Review();
        review1.setProductId(testProductId);
        review1.setUserId(testUserId);
        review1.setRating(5);
        review1.setComment("Perfect!");
        reviewDAO.addReview(review1);

        Review review2 = new Review();
        review2.setProductId(testProductId);
        review2.setUserId(testUserId);
        review2.setRating(3);
        review2.setComment("Average");
        reviewDAO.addReview(review2);

        Review review3 = new Review();
        review3.setProductId(testProductId);
        review3.setUserId(testUserId);
        review3.setRating(4);
        review3.setComment("Good");
        reviewDAO.addReview(review3);

        // Act
        double avgRating = reviewDAO.getAverageRating(testProductId);

        // Assert
        assertEquals(4.0, avgRating, 0.01, "Average rating should be 4.0");
    }

    @Test
    @DisplayName("Should return 0.0 for product with no reviews")
    void testGetAverageRating_NoReviews() throws Exception {
        // Act
        double avgRating = reviewDAO.getAverageRating(9999);

        // Assert
        assertEquals(0.0, avgRating, 0.01);
    }

    @Test
    @DisplayName("Should count reviews correctly")
    void testGetReviewCount() throws Exception {
        // Arrange
        for (int i = 0; i < 5; i++) {
            Review review = new Review();
            review.setProductId(testProductId);
            review.setUserId(testUserId);
            review.setRating(4);
            review.setComment("Review " + i);
            reviewDAO.addReview(review);
        }

        // Act
        int count = reviewDAO.getReviewCount(testProductId);

        // Assert
        assertEquals(5, count);
    }

    @Test
    @DisplayName("Should return 0 count for product with no reviews")
    void testGetReviewCount_NoReviews() throws Exception {
        // Act
        int count = reviewDAO.getReviewCount(9999);

        // Assert
        assertEquals(0, count);
    }

    @Test
    @DisplayName("Should delete review successfully")
    void testDeleteReview() throws Exception {
        // Arrange
        Review review = new Review();
        review.setProductId(testProductId);
        review.setUserId(testUserId);
        review.setRating(3);
        review.setComment("To be deleted");
        reviewDAO.addReview(review);
        int reviewId = review.getReviewId();

        // Act
        reviewDAO.deleteReview(reviewId);

        // Assert
        List<Review> reviews = reviewDAO.getReviewsByProductId(testProductId);
        assertFalse(reviews.stream().anyMatch(r -> r.getReviewId() == reviewId));
    }

    @Test
    @DisplayName("Should include username in review")
    void testReviewWithUsername() throws Exception {
        // Arrange
        Review review = new Review();
        review.setProductId(testProductId);
        review.setUserId(testUserId);
        review.setRating(5);
        review.setComment("With username");
        reviewDAO.addReview(review);

        // Act
        List<Review> reviews = reviewDAO.getReviewsByProductId(testProductId);

        // Assert
        assertEquals(1, reviews.size());
        Review retrieved = reviews.get(0);
        assertEquals("reviewer", retrieved.getUsername());
    }

    @Test
    @DisplayName("Should handle multiple ratings correctly")
    void testMultipleRatings() throws Exception {
        // Arrange - Add reviews with different ratings
        int[] ratings = {1, 2, 3, 4, 5};
        for (int rating : ratings) {
            Review review = new Review();
            review.setProductId(testProductId);
            review.setUserId(testUserId);
            review.setRating(rating);
            review.setComment("Rating: " + rating);
            reviewDAO.addReview(review);
        }

        // Act
        double avgRating = reviewDAO.getAverageRating(testProductId);
        int count = reviewDAO.getReviewCount(testProductId);

        // Assert
        assertEquals(3.0, avgRating, 0.01, "Average of 1,2,3,4,5 should be 3.0");
        assertEquals(5, count);
    }

    @Test
    @DisplayName("Should handle long comments")
    void testLongComment() throws Exception {
        // Arrange
        String longComment = "This is a very long comment. ".repeat(50);
        Review review = new Review();
        review.setProductId(testProductId);
        review.setUserId(testUserId);
        review.setRating(4);
        review.setComment(longComment);

        // Act
        reviewDAO.addReview(review);
        List<Review> reviews = reviewDAO.getReviewsByProductId(testProductId);

        // Assert
        assertEquals(1, reviews.size());
        assertEquals(longComment, reviews.get(0).getComment());
    }

    @Test
    @DisplayName("Should handle reviews from multiple users")
    void testMultipleUsers() throws Exception {
        // Arrange - Create another user
        User user2 = new User();
        user2.setFirstName("Another");
        user2.setLastName("Reviewer");
        user2.setUsername("reviewer2");
        user2.setEmail("reviewer2@test.com");
        user2.setPassword("password");
        user2.setPhoneNumber("9876543210");
        user2.setCity("Test City");
        user2.setRole("user");
        int user2Id = userDAO.saveUser(user2);

        // Add reviews from both users
        Review review1 = new Review();
        review1.setProductId(testProductId);
        review1.setUserId(testUserId);
        review1.setRating(5);
        review1.setComment("User 1 review");
        reviewDAO.addReview(review1);

        Review review2 = new Review();
        review2.setProductId(testProductId);
        review2.setUserId(user2Id);
        review2.setRating(4);
        review2.setComment("User 2 review");
        reviewDAO.addReview(review2);

        // Act
        List<Review> reviews = reviewDAO.getReviewsByProductId(testProductId);

        // Assert
        assertEquals(2, reviews.size());
        assertTrue(reviews.stream().anyMatch(r -> r.getUsername().equals("reviewer")));
        assertTrue(reviews.stream().anyMatch(r -> r.getUsername().equals("reviewer2")));
    }
}
