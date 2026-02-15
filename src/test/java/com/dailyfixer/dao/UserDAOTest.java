package com.dailyfixer.dao;

import com.dailyfixer.model.User;
import com.dailyfixer.util.HashUtil;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for UserDAO using H2 in-memory database.
 */
class UserDAOTest {

    private UserDAOTestHelper userDAO;

    @BeforeEach
    void setUp() throws Exception {
        userDAO = new UserDAOTestHelper();
        TestDBConnection.clearAllTables();
    }

    @Test
    @DisplayName("Should save user and return generated user ID")
    void testSaveUser() {
        // Arrange
        User user = new User();
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setUsername("johndoe");
        user.setEmail("john@example.com");
        user.setPassword("hashedPassword123");
        user.setPhoneNumber("1234567890");
        user.setCity("Colombo");
        user.setRole("user");

        // Act
        int userId = userDAO.saveUser(user);

        // Assert
        assertTrue(userId > 0, "User ID should be greater than 0");
        assertEquals(userId, user.getUserId(), "User object should have the generated ID");
    }

    @Test
    @DisplayName("Should retrieve user by ID")
    void testGetUserById() {
        // Arrange
        User user = new User();
        user.setFirstName("Jane");
        user.setLastName("Smith");
        user.setUsername("janesmith");
        user.setEmail("jane@example.com");
        user.setPassword("hashedPassword456");
        user.setPhoneNumber("9876543210");
        user.setCity("Kandy");
        user.setRole("user");
        int userId = userDAO.saveUser(user);

        // Act
        User retrievedUser = userDAO.getUserById(userId);

        // Assert
        assertNotNull(retrievedUser, "Retrieved user should not be null");
        assertEquals(userId, retrievedUser.getUserId());
        assertEquals("Jane", retrievedUser.getFirstName());
        assertEquals("Smith", retrievedUser.getLastName());
        assertEquals("janesmith", retrievedUser.getUsername());
        assertEquals("jane@example.com", retrievedUser.getEmail());
        assertEquals("Kandy", retrievedUser.getCity());
    }

    @Test
    @DisplayName("Should return null when user ID does not exist")
    void testGetUserById_NotFound() {
        // Act
        User user = userDAO.getUserById(9999);

        // Assert
        assertNull(user, "Should return null for non-existent user ID");
    }

    @Test
    @DisplayName("Should detect duplicate username")
    void testIsUsernameTaken() throws Exception {
        // Arrange
        User user = new User();
        user.setFirstName("Test");
        user.setLastName("User");
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPassword("password");
        user.setPhoneNumber("1234567890");
        user.setCity("Galle");
        user.setRole("user");
        userDAO.saveUser(user);

        // Act
        boolean isTaken = userDAO.isUsernameTaken("testuser");
        boolean isNotTaken = userDAO.isUsernameTaken("anotheruser");

        // Assert
        assertTrue(isTaken, "Username 'testuser' should be taken");
        assertFalse(isNotTaken, "Username 'anotheruser' should not be taken");
    }

    @Test
    @DisplayName("Should detect duplicate email")
    void testIsEmailTaken() throws Exception {
        // Arrange
        User user = new User();
        user.setFirstName("Test");
        user.setLastName("User");
        user.setUsername("testuser2");
        user.setEmail("duplicate@example.com");
        user.setPassword("password");
        user.setPhoneNumber("1234567890");
        user.setCity("Galle");
        user.setRole("user");
        userDAO.saveUser(user);

        // Act
        boolean isTaken = userDAO.isEmailTaken("duplicate@example.com");
        boolean isNotTaken = userDAO.isEmailTaken("newemail@example.com");

        // Assert
        assertTrue(isTaken, "Email 'duplicate@example.com' should be taken");
        assertFalse(isNotTaken, "Email 'newemail@example.com' should not be taken");
    }

    @Test
    @DisplayName("Should find user by username and password")
    void testFindByUsernameAndPassword() throws Exception {
        // Arrange
        String plainPassword = "myPassword123";
        String hashedPassword = HashUtil.sha256(plainPassword);

        User user = new User();
        user.setFirstName("Auth");
        user.setLastName("Test");
        user.setUsername("authuser");
        user.setEmail("auth@example.com");
        user.setPassword(hashedPassword);
        user.setPhoneNumber("1234567890");
        user.setCity("Colombo");
        user.setRole("user");
        user.setStatus("active");
        userDAO.saveUser(user);

        // Act
        User foundUser = userDAO.findByUsernameAndPassword("authuser", hashedPassword);

        // Assert
        assertNotNull(foundUser, "Should find user with correct credentials");
        assertEquals("authuser", foundUser.getUsername());
        assertEquals("auth@example.com", foundUser.getEmail());
    }

    @Test
    @DisplayName("Should not find user with wrong password")
    void testFindByUsernameAndPassword_WrongPassword() throws Exception {
        // Arrange
        User user = new User();
        user.setFirstName("Auth");
        user.setLastName("Test");
        user.setUsername("authuser2");
        user.setEmail("auth2@example.com");
        user.setPassword(HashUtil.sha256("correctPassword"));
        user.setPhoneNumber("1234567890");
        user.setCity("Colombo");
        user.setRole("user");
        user.setStatus("active");
        userDAO.saveUser(user);

        // Act
        User foundUser = userDAO.findByUsernameAndPassword("authuser2", HashUtil.sha256("wrongPassword"));

        // Assert
        assertNull(foundUser, "Should not find user with incorrect password");
    }

    @Test
    @DisplayName("Should handle multiple users correctly")
    void testMultipleUsers() {
        // Arrange & Act
        User user1 = new User();
        user1.setFirstName("User");
        user1.setLastName("One");
        user1.setUsername("user1");
        user1.setEmail("user1@example.com");
        user1.setPassword("pass1");
        user1.setPhoneNumber("1111111111");
        user1.setCity("City1");
        user1.setRole("user");
        int id1 = userDAO.saveUser(user1);

        User user2 = new User();
        user2.setFirstName("User");
        user2.setLastName("Two");
        user2.setUsername("user2");
        user2.setEmail("user2@example.com");
        user2.setPassword("pass2");
        user2.setPhoneNumber("2222222222");
        user2.setCity("City2");
        user2.setRole("technician");
        int id2 = userDAO.saveUser(user2);

        // Assert
        assertTrue(id1 > 0);
        assertTrue(id2 > 0);
        assertNotEquals(id1, id2, "Different users should have different IDs");

        User retrieved1 = userDAO.getUserById(id1);
        User retrieved2 = userDAO.getUserById(id2);

        assertEquals("user1", retrieved1.getUsername());
        assertEquals("user2", retrieved2.getUsername());
        assertEquals("user", retrieved1.getRole());
        assertEquals("technician", retrieved2.getRole());
    }
}
