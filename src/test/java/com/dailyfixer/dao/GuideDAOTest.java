package com.dailyfixer.dao;

import com.dailyfixer.model.Guide;
import com.dailyfixer.model.GuideStep;
import com.dailyfixer.model.User;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for GuideDAO using H2 in-memory database.
 */
class GuideDAOTest {

    private GuideDAOTestHelper guideDAO;
    private UserDAOTestHelper userDAO;

    @BeforeEach
    void setUp() throws Exception {
        guideDAO = new GuideDAOTestHelper();
        userDAO = new UserDAOTestHelper();
        TestDBConnection.clearAllTables();
    }

    @Test
    @DisplayName("Add guide with requirements and steps successfully")
    void testAddGuide() throws Exception {
        // Arrange
        User user = createTestUser(1, "volunteer1", "Vol", "Unteer");
        userDAO.saveUser(user);

        Guide guide = createTestGuide("How to Fix a Leaky Faucet", 1, "volunteer");
        List<String> requirements = Arrays.asList("Wrench", "Plumber's tape", "Replacement washer");
        List<GuideStep> steps = createTestSteps();

        // Act
        int guideId = guideDAO.addGuide(guide, requirements, steps);

        // Assert
        assertTrue(guideId > 0, "Guide should be created with valid ID");
    }

    @Test
    @DisplayName("Add guide without requirements")
    void testAddGuideWithoutRequirements() throws Exception {
        // Arrange
        User user = createTestUser(1, "volunteer1", "Vol", "Unteer");
        userDAO.saveUser(user);

        Guide guide = createTestGuide("Simple Repair Guide", 1, "volunteer");
        List<GuideStep> steps = createTestSteps();

        // Act
        int guideId = guideDAO.addGuide(guide, null, steps);

        // Assert
        assertTrue(guideId > 0);
        Guide retrieved = guideDAO.getGuideById(guideId);
        assertNotNull(retrieved);
        assertTrue(retrieved.getRequirements() == null || retrieved.getRequirements().isEmpty());
    }

    @Test
    @DisplayName("Get guide by ID retrieves all details")
    void testGetGuideById() throws Exception {
        // Arrange
        User user = createTestUser(1, "volunteer1", "John", "Smith");
        userDAO.saveUser(user);

        Guide guide = createTestGuide("Test Guide", 1, "volunteer");
        List<String> requirements = Arrays.asList("Tool1", "Tool2");
        List<GuideStep> steps = createTestSteps();

        int guideId = guideDAO.addGuide(guide, requirements, steps);

        // Act
        Guide retrieved = guideDAO.getGuideById(guideId);

        // Assert
        assertNotNull(retrieved);
        assertEquals("Test Guide", retrieved.getTitle());
        assertEquals("John Smith", retrieved.getCreatorName());
        assertEquals(2, retrieved.getRequirements().size());
        assertEquals(2, retrieved.getSteps().size());
        assertEquals("Step 1", retrieved.getSteps().get(0).getStepTitle());
    }

    @Test
    @DisplayName("Get guide by ID returns null for non-existent guide")
    void testGetGuideByIdNotFound() throws Exception {
        // Act
        Guide retrieved = guideDAO.getGuideById(9999);

        // Assert
        assertNull(retrieved, "Non-existent guide should return null");
    }

    @Test
    @DisplayName("Get all guides returns all guides with creator names")
    void testGetAllGuides() throws Exception {
        // Arrange
        User user1 = createTestUser(1, "vol1", "Alice", "Wonder");
        User user2 = createTestUser(2, "vol2", "Bob", "Builder");
        userDAO.saveUser(user1);
        userDAO.saveUser(user2);

        Guide guide1 = createTestGuide("Guide 1", 1, "volunteer");
        Guide guide2 = createTestGuide("Guide 2", 2, "volunteer");
        guideDAO.addGuide(guide1, Arrays.asList("Req1"), createTestSteps());
        guideDAO.addGuide(guide2, Arrays.asList("Req2"), createTestSteps());

        // Act
        List<Guide> guides = guideDAO.getAllGuides();

        // Assert
        assertEquals(2, guides.size());
        assertTrue(guides.stream().anyMatch(g -> g.getCreatorName().equals("Alice Wonder")));
        assertTrue(guides.stream().anyMatch(g -> g.getCreatorName().equals("Bob Builder")));
    }

    @Test
    @DisplayName("Get guides by creator filters correctly")
    void testGetGuidesByCreator() throws Exception {
        // Arrange
        User user1 = createTestUser(1, "vol1", "Alice", "Wonder");
        User user2 = createTestUser(2, "vol2", "Bob", "Builder");
        userDAO.saveUser(user1);
        userDAO.saveUser(user2);

        Guide guide1 = createTestGuide("Alice's Guide 1", 1, "volunteer");
        Guide guide2 = createTestGuide("Alice's Guide 2", 1, "volunteer");
        Guide guide3 = createTestGuide("Bob's Guide", 2, "volunteer");
        guideDAO.addGuide(guide1, Arrays.asList("Req1"), createTestSteps());
        guideDAO.addGuide(guide2, Arrays.asList("Req2"), createTestSteps());
        guideDAO.addGuide(guide3, Arrays.asList("Req3"), createTestSteps());

        // Act
        List<Guide> aliceGuides = guideDAO.getGuidesByCreator(1);

        // Assert
        assertEquals(2, aliceGuides.size());
        assertTrue(aliceGuides.stream().allMatch(g -> g.getCreatedBy() == 1));
        assertTrue(aliceGuides.stream().allMatch(g -> g.getCreatorName().equals("Alice Wonder")));
    }

    @Test
    @DisplayName("Search guides by keyword")
    void testSearchGuidesByKeyword() throws Exception {
        // Arrange
        User user = createTestUser(1, "vol1", "Vol", "Unteer");
        userDAO.saveUser(user);

        Guide guide1 = createTestGuide("Fix Leaky Faucet", 1, "volunteer");
        Guide guide2 = createTestGuide("Repair Broken Door", 1, "volunteer");
        Guide guide3 = createTestGuide("Replace Faucet Valve", 1, "volunteer");
        guideDAO.addGuide(guide1, null, createTestSteps());
        guideDAO.addGuide(guide2, null, createTestSteps());
        guideDAO.addGuide(guide3, null, createTestSteps());

        // Act
        List<Guide> faucetGuides = guideDAO.searchGuides("Faucet", null, null);

        // Assert
        assertEquals(2, faucetGuides.size());
        assertTrue(faucetGuides.stream().allMatch(g -> g.getTitle().contains("Faucet")));
    }

    @Test
    @DisplayName("Search guides by main category")
    void testSearchGuidesByMainCategory() throws Exception {
        // Arrange
        User user = createTestUser(1, "vol1", "Vol", "Unteer");
        userDAO.saveUser(user);

        Guide guide1 = createTestGuide("Plumbing Guide", 1, "volunteer");
        guide1.setMainCategory("Plumbing");
        Guide guide2 = createTestGuide("Electrical Guide", 1, "volunteer");
        guide2.setMainCategory("Electrical");
        guideDAO.addGuide(guide1, null, createTestSteps());
        guideDAO.addGuide(guide2, null, createTestSteps());

        // Act
        List<Guide> plumbingGuides = guideDAO.searchGuides(null, "Plumbing", null);

        // Assert
        assertEquals(1, plumbingGuides.size());
        assertEquals("Plumbing Guide", plumbingGuides.get(0).getTitle());
    }

    @Test
    @DisplayName("Search guides by sub category")
    void testSearchGuidesBySubCategory() throws Exception {
        // Arrange
        User user = createTestUser(1, "vol1", "Vol", "Unteer");
        userDAO.saveUser(user);

        Guide guide1 = createTestGuide("Faucet Repair", 1, "volunteer");
        guide1.setMainCategory("Plumbing");
        guide1.setSubCategory("Faucets");
        Guide guide2 = createTestGuide("Drain Cleaning", 1, "volunteer");
        guide2.setMainCategory("Plumbing");
        guide2.setSubCategory("Drains");
        guideDAO.addGuide(guide1, null, createTestSteps());
        guideDAO.addGuide(guide2, null, createTestSteps());

        // Act
        List<Guide> faucetGuides = guideDAO.searchGuides(null, null, "Faucets");

        // Assert
        assertEquals(1, faucetGuides.size());
        assertEquals("Faucet Repair", faucetGuides.get(0).getTitle());
    }

    @Test
    @DisplayName("Search guides with combined filters")
    void testSearchGuidesWithCombinedFilters() throws Exception {
        // Arrange
        User user = createTestUser(1, "vol1", "Vol", "Unteer");
        userDAO.saveUser(user);

        Guide guide1 = createTestGuide("Fix Leaky Kitchen Faucet", 1, "volunteer");
        guide1.setMainCategory("Plumbing");
        guide1.setSubCategory("Faucets");

        Guide guide2 = createTestGuide("Fix Bathroom Faucet", 1, "volunteer");
        guide2.setMainCategory("Plumbing");
        guide2.setSubCategory("Faucets");

        Guide guide3 = createTestGuide("Clean Kitchen Drain", 1, "volunteer");
        guide3.setMainCategory("Plumbing");
        guide3.setSubCategory("Drains");

        guideDAO.addGuide(guide1, null, createTestSteps());
        guideDAO.addGuide(guide2, null, createTestSteps());
        guideDAO.addGuide(guide3, null, createTestSteps());

        // Act
        List<Guide> kitchenFaucetGuides = guideDAO.searchGuides("Kitchen", "Plumbing", "Faucets");

        // Assert
        assertEquals(1, kitchenFaucetGuides.size());
        assertEquals("Fix Leaky Kitchen Faucet", kitchenFaucetGuides.get(0).getTitle());
    }

    @Test
    @DisplayName("Increment view count increases count")
    void testIncrementViewCount() throws Exception {
        // Arrange
        User user = createTestUser(1, "vol1", "Vol", "Unteer");
        userDAO.saveUser(user);

        Guide guide = createTestGuide("Popular Guide", 1, "volunteer");
        int guideId = guideDAO.addGuide(guide, null, createTestSteps());

        // Act
        guideDAO.incrementViewCount(guideId);
        guideDAO.incrementViewCount(guideId);
        guideDAO.incrementViewCount(guideId);

        // Assert
        Guide retrieved = guideDAO.getGuideById(guideId);
        assertEquals(3, retrieved.getViewCount());
    }

    @Test
    @DisplayName("Guide with multiple steps preserves order")
    void testGuideStepsOrdering() throws Exception {
        // Arrange
        User user = createTestUser(1, "vol1", "Vol", "Unteer");
        userDAO.saveUser(user);

        Guide guide = createTestGuide("Multi-step Guide", 1, "volunteer");
        
        List<GuideStep> steps = new ArrayList<>();
        for (int i = 1; i <= 5; i++) {
            GuideStep step = new GuideStep();
            step.setStepTitle("Step " + i);
            step.setStepBody("Body of step " + i);
            steps.add(step);
        }

        int guideId = guideDAO.addGuide(guide, null, steps);

        // Act
        Guide retrieved = guideDAO.getGuideById(guideId);

        // Assert
        assertNotNull(retrieved);
        assertEquals(5, retrieved.getSteps().size());
        for (int i = 0; i < 5; i++) {
            assertEquals("Step " + (i + 1), retrieved.getSteps().get(i).getStepTitle());
            assertEquals(i + 1, retrieved.getSteps().get(i).getStepOrder());
        }
    }

    @Test
    @DisplayName("Guide steps with images are retrieved correctly")
    void testGuideStepsWithImages() throws Exception {
        // Arrange
        User user = createTestUser(1, "vol1", "Vol", "Unteer");
        userDAO.saveUser(user);

        Guide guide = createTestGuide("Guide with Images", 1, "volunteer");
        
        GuideStep step1 = new GuideStep();
        step1.setStepTitle("Step 1");
        step1.setStepBody("Body 1");
        step1.setImagePaths(Arrays.asList("/img/step1-1.jpg", "/img/step1-2.jpg"));

        GuideStep step2 = new GuideStep();
        step2.setStepTitle("Step 2");
        step2.setStepBody("Body 2");
        step2.setImagePaths(Arrays.asList("/img/step2-1.jpg"));

        List<GuideStep> steps = Arrays.asList(step1, step2);
        int guideId = guideDAO.addGuide(guide, null, steps);

        // Act
        Guide retrieved = guideDAO.getGuideById(guideId);

        // Assert
        assertNotNull(retrieved);
        assertEquals(2, retrieved.getSteps().size());
        assertEquals(2, retrieved.getSteps().get(0).getImagePaths().size());
        assertEquals(1, retrieved.getSteps().get(1).getImagePaths().size());
        assertEquals("/img/step1-1.jpg", retrieved.getSteps().get(0).getImagePaths().get(0));
    }

    @Test
    @DisplayName("Empty results when no guides exist")
    void testEmptyResults() throws Exception {
        // Act & Assert
        assertEquals(0, guideDAO.getAllGuides().size());
        assertEquals(0, guideDAO.getGuidesByCreator(999).size());
        assertEquals(0, guideDAO.searchGuides("NonExistent", null, null).size());
    }

    // Helper methods

    private User createTestUser(int userId, String username, String firstName, String lastName) {
        User user = new User();
        user.setUserId(userId);
        user.setUsername(username);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(username + "@example.com");
        user.setPassword("hashedPassword123");
        user.setPhoneNumber("0771234567");
        user.setCity("Colombo");
        user.setRole("volunteer");
        user.setStatus("active");
        return user;
    }

    private Guide createTestGuide(String title, int createdBy, String role) {
        Guide guide = new Guide();
        guide.setTitle(title);
        guide.setMainImagePath("/images/guide-main.jpg");
        guide.setMainCategory("General");
        guide.setSubCategory("Repairs");
        guide.setYoutubeUrl("https://youtube.com/watch?v=test");
        guide.setCreatedBy(createdBy);
        guide.setCreatedRole(role);
        return guide;
    }

    private List<GuideStep> createTestSteps() {
        List<GuideStep> steps = new ArrayList<>();

        GuideStep step1 = new GuideStep();
        step1.setStepTitle("Step 1");
        step1.setStepBody("First step description");
        steps.add(step1);

        GuideStep step2 = new GuideStep();
        step2.setStepTitle("Step 2");
        step2.setStepBody("Second step description");
        steps.add(step2);

        return steps;
    }
}
