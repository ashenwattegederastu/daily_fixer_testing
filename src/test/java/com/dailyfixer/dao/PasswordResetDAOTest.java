package com.dailyfixer.dao;

import com.dailyfixer.model.PasswordResetToken;
import com.dailyfixer.model.User;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for PasswordResetDAO using H2 in-memory database.
 */
class PasswordResetDAOTest {

    private PasswordResetDAOTestHelper passwordResetDAO;
    private UserDAOTestHelper userDAO;
    private int testUserId;

    @BeforeEach
    void setUp() throws Exception {
        passwordResetDAO = new PasswordResetDAOTestHelper();
        userDAO = new UserDAOTestHelper();
        TestDBConnection.clearAllTables();

        // Create test user
        User user = new User();
        user.setFirstName("Test");
        user.setLastName("User");
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPassword("password");
        user.setPhoneNumber("1234567890");
        user.setCity("Test City");
        user.setRole("user");
        testUserId = userDAO.saveUser(user);
    }

    @Test
    @DisplayName("Should save password reset token")
    void testSaveToken() throws Exception {
        // Arrange
        String token = UUID.randomUUID().toString();
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusHours(1));

        // Act
        passwordResetDAO.saveToken(testUserId, token, expiry);

        // Assert
        PasswordResetToken retrieved = passwordResetDAO.getToken(token);
        assertNotNull(retrieved);
        assertEquals(token, retrieved.getToken());
        assertEquals(testUserId, retrieved.getUserId());
    }

    @Test
    @DisplayName("Should retrieve token by token string")
    void testGetToken() throws Exception {
        // Arrange
        String token = UUID.randomUUID().toString();
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusHours(1));
        passwordResetDAO.saveToken(testUserId, token, expiry);

        // Act
        PasswordResetToken retrieved = passwordResetDAO.getToken(token);

        // Assert
        assertNotNull(retrieved);
        assertEquals(token, retrieved.getToken());
        assertEquals(testUserId, retrieved.getUserId());
        assertFalse(retrieved.isUsed(), "New token should not be marked as used");
        assertNotNull(retrieved.getExpiry());
    }

    @Test
    @DisplayName("Should return null for non-existent token")
    void testGetToken_NotFound() throws Exception {
        // Act
        PasswordResetToken token = passwordResetDAO.getToken("non-existent-token");

        // Assert
        assertNull(token);
    }

    @Test
    @DisplayName("Should mark token as used")
    void testMarkTokenAsUsed() throws Exception {
        // Arrange
        String token = UUID.randomUUID().toString();
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusHours(1));
        passwordResetDAO.saveToken(testUserId, token, expiry);

        // Act
        passwordResetDAO.markTokenAsUsed(token);

        // Assert
        PasswordResetToken retrieved = passwordResetDAO.getToken(token);
        assertTrue(retrieved.isUsed(), "Token should be marked as used");
    }

    @Test
    @DisplayName("Should handle expired token")
    void testExpiredToken() throws Exception {
        // Arrange
        String token = UUID.randomUUID().toString();
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().minusHours(1)); // Already expired
        passwordResetDAO.saveToken(testUserId, token, expiry);

        // Act
        PasswordResetToken retrieved = passwordResetDAO.getToken(token);

        // Assert
        assertNotNull(retrieved);
        assertTrue(retrieved.getExpiry().before(new Timestamp(System.currentTimeMillis())),
                "Token should be expired");
    }

    @Test
    @DisplayName("Should handle future expiry token")
    void testFutureExpiryToken() throws Exception {
        // Arrange
        String token = UUID.randomUUID().toString();
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusDays(1));
        passwordResetDAO.saveToken(testUserId, token, expiry);

        // Act
        PasswordResetToken retrieved = passwordResetDAO.getToken(token);

        // Assert
        assertNotNull(retrieved);
        assertTrue(retrieved.getExpiry().after(new Timestamp(System.currentTimeMillis())),
                "Token should not be expired");
    }

    @Test
    @DisplayName("Should handle multiple tokens for same user")
    void testMultipleTokensForSameUser() throws Exception {
        // Arrange
        String token1 = UUID.randomUUID().toString();
        String token2 = UUID.randomUUID().toString();
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusHours(1));
        
        passwordResetDAO.saveToken(testUserId, token1, expiry);
        passwordResetDAO.saveToken(testUserId, token2, expiry);

        // Act
        PasswordResetToken retrieved1 = passwordResetDAO.getToken(token1);
        PasswordResetToken retrieved2 = passwordResetDAO.getToken(token2);

        // Assert
        assertNotNull(retrieved1);
        assertNotNull(retrieved2);
        assertEquals(testUserId, retrieved1.getUserId());
        assertEquals(testUserId, retrieved2.getUserId());
        assertNotEquals(token1, token2);
    }

    @Test
    @DisplayName("Should handle tokens for different users")
    void testTokensForDifferentUsers() throws Exception {
        // Arrange
        User user2 = new User();
        user2.setFirstName("Another");
        user2.setLastName("User");
        user2.setUsername("anotheruser");
        user2.setEmail("another@example.com");
        user2.setPassword("password");
        user2.setPhoneNumber("9876543210");
        user2.setCity("Another City");
        user2.setRole("user");
        int user2Id = userDAO.saveUser(user2);

        String token1 = UUID.randomUUID().toString();
        String token2 = UUID.randomUUID().toString();
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusHours(1));
        
        passwordResetDAO.saveToken(testUserId, token1, expiry);
        passwordResetDAO.saveToken(user2Id, token2, expiry);

        // Act
        PasswordResetToken retrieved1 = passwordResetDAO.getToken(token1);
        PasswordResetToken retrieved2 = passwordResetDAO.getToken(token2);

        // Assert
        assertNotNull(retrieved1);
        assertNotNull(retrieved2);
        assertEquals(testUserId, retrieved1.getUserId());
        assertEquals(user2Id, retrieved2.getUserId());
    }

    @Test
    @DisplayName("Should not mark non-existent token as used")
    void testMarkNonExistentTokenAsUsed() throws Exception {
        // Act & Assert - Should not throw exception
        assertDoesNotThrow(() -> passwordResetDAO.markTokenAsUsed("non-existent-token"));
    }

    @Test
    @DisplayName("Should handle UUID format tokens")
    void testUUIDFormatTokens() throws Exception {
        // Arrange
        String token = UUID.randomUUID().toString();
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusHours(1));

        // Act
        passwordResetDAO.saveToken(testUserId, token, expiry);
        PasswordResetToken retrieved = passwordResetDAO.getToken(token);

        // Assert
        assertNotNull(retrieved);
        assertEquals(36, token.length(), "UUID should be 36 characters");
        assertTrue(token.contains("-"), "UUID should contain hyphens");
    }

    @Test
    @DisplayName("Should handle token workflow: create, use, verify")
    void testCompleteTokenWorkflow() throws Exception {
        // Step 1: Create token
        String token = UUID.randomUUID().toString();
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusHours(1));
        passwordResetDAO.saveToken(testUserId, token, expiry);

        // Step 2: Verify token exists and not used
        PasswordResetToken retrieved = passwordResetDAO.getToken(token);
        assertNotNull(retrieved);
        assertFalse(retrieved.isUsed());

        // Step 3: Mark as used
        passwordResetDAO.markTokenAsUsed(token);

        // Step 4: Verify token is now used
        PasswordResetToken usedToken = passwordResetDAO.getToken(token);
        assertNotNull(usedToken);
        assertTrue(usedToken.isUsed());
    }

    @Test
    @DisplayName("Should preserve expiry timestamp accurately")
    void testExpiryTimestampPrecision() throws Exception {
        // Arrange
        String token = UUID.randomUUID().toString();
        LocalDateTime futureTime = LocalDateTime.now().plusHours(2).plusMinutes(30);
        Timestamp expiry = Timestamp.valueOf(futureTime);

        // Act
        passwordResetDAO.saveToken(testUserId, token, expiry);
        PasswordResetToken retrieved = passwordResetDAO.getToken(token);

        // Assert
        assertNotNull(retrieved.getExpiry());
        // Allow small difference due to database precision
        long diff = Math.abs(retrieved.getExpiry().getTime() - expiry.getTime());
        assertTrue(diff < 1000, "Expiry should be preserved within 1 second accuracy");
    }
}
