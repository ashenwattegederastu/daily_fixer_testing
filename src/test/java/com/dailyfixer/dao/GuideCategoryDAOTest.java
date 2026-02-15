package com.dailyfixer.dao;

import com.dailyfixer.model.GuideCategory;
import com.dailyfixer.model.GuideSubCategory;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for GuideCategoryDAO using H2 in-memory database.
 */
class GuideCategoryDAOTest {

    private GuideCategoryDAOTestHelper categoryDAO;

    @BeforeEach
    void setUp() throws Exception {
        categoryDAO = new GuideCategoryDAOTestHelper();
        TestDBConnection.clearAllTables();
    }

    @Test
    @DisplayName("Should add and retrieve main category")
    void testAddCategory() {
        // Arrange & Act
        int categoryId = categoryDAO.addCategory("Electronics Repair");

        // Assert
        assertTrue(categoryId > 0, "Category ID should be generated");
        GuideCategory retrieved = categoryDAO.getCategoryById(categoryId);
        assertNotNull(retrieved);
        assertEquals("Electronics Repair", retrieved.getName());
    }

    @Test
    @DisplayName("Should retrieve all categories ordered by name")
    void testGetAllCategories() {
        // Arrange
        categoryDAO.addCategory("Plumbing");
        categoryDAO.addCategory("Automotive");
        categoryDAO.addCategory("Electrical");

        // Act
        List<GuideCategory> categories = categoryDAO.getAllCategories();

        // Assert
        assertEquals(3, categories.size());
        // Should be ordered alphabetically
        assertEquals("Automotive", categories.get(0).getName());
        assertEquals("Electrical", categories.get(1).getName());
        assertEquals("Plumbing", categories.get(2).getName());
    }

    @Test
    @DisplayName("Should add and retrieve sub-category")
    void testAddSubCategory() {
        // Arrange
        int categoryId = categoryDAO.addCategory("Home Repair");

        // Act
        int subCategoryId = categoryDAO.addSubCategory(categoryId, "Kitchen");

        // Assert
        assertTrue(subCategoryId > 0, "Sub-category ID should be generated");
    }

    @Test
    @DisplayName("Should retrieve sub-categories by category ID")
    void testGetSubCategoriesByCategoryId() {
        // Arrange
        int categoryId = categoryDAO.addCategory("Vehicle Repair");
        categoryDAO.addSubCategory(categoryId, "Engine");
        categoryDAO.addSubCategory(categoryId, "Brakes");
        categoryDAO.addSubCategory(categoryId, "Transmission");

        // Act
        List<GuideSubCategory> subCategories = categoryDAO.getSubCategoriesByCategoryId(categoryId);

        // Assert
        assertEquals(3, subCategories.size());
        // Should be ordered alphabetically
        assertEquals("Brakes", subCategories.get(0).getName());
        assertEquals("Engine", subCategories.get(1).getName());
        assertEquals("Transmission", subCategories.get(2).getName());
    }

    @Test
    @DisplayName("Should return empty list for category with no sub-categories")
    void testGetSubCategoriesByCategoryId_Empty() {
        // Arrange
        int categoryId = categoryDAO.addCategory("Empty Category");

        // Act
        List<GuideSubCategory> subCategories = categoryDAO.getSubCategoriesByCategoryId(categoryId);

        // Assert
        assertNotNull(subCategories);
        assertEquals(0, subCategories.size());
    }

    @Test
    @DisplayName("Should return empty list when no categories exist")
    void testGetAllCategories_Empty() {
        // Act
        List<GuideCategory> categories = categoryDAO.getAllCategories();

        // Assert
        assertNotNull(categories);
        assertEquals(0, categories.size());
    }

    @Test
    @DisplayName("Should handle multiple sub-categories across different main categories")
    void testMultipleSubCategories() {
        // Arrange
        int cat1 = categoryDAO.addCategory("Category 1");
        int cat2 = categoryDAO.addCategory("Category 2");
        
        categoryDAO.addSubCategory(cat1, "Sub 1-A");
        categoryDAO.addSubCategory(cat1, "Sub 1-B");
        categoryDAO.addSubCategory(cat2, "Sub 2-A");
        categoryDAO.addSubCategory(cat2, "Sub 2-B");

        // Act
        List<GuideSubCategory> cat1Subs = categoryDAO.getSubCategoriesByCategoryId(cat1);
        List<GuideSubCategory> cat2Subs = categoryDAO.getSubCategoriesByCategoryId(cat2);

        // Assert
        assertEquals(2, cat1Subs.size());
        assertEquals(2, cat2Subs.size());
        
        assertTrue(cat1Subs.stream().allMatch(s -> s.getCategoryId() == cat1));
        assertTrue(cat2Subs.stream().allMatch(s -> s.getCategoryId() == cat2));
    }

    @Test
    @DisplayName("Should return null for non-existent category ID")
    void testGetCategoryById_NotFound() {
        // Act
        GuideCategory category = categoryDAO.getCategoryById(9999);

        // Assert
        assertNull(category);
    }

    @Test
    @DisplayName("Should preserve timestamps on category creation")
    void testCategoryTimestamp() {
        // Arrange & Act
        int categoryId = categoryDAO.addCategory("Timestamped Category");
        GuideCategory retrieved = categoryDAO.getCategoryById(categoryId);

        // Assert
        assertNotNull(retrieved.getCreatedAt());
    }

    @Test
    @DisplayName("Should preserve timestamps on sub-category creation")
    void testSubCategoryTimestamp() {
        // Arrange
        int categoryId = categoryDAO.addCategory("Main Category");
        int subCategoryId = categoryDAO.addSubCategory(categoryId, "Sub Category");

        // Act
        List<GuideSubCategory> subCategories = categoryDAO.getSubCategoriesByCategoryId(categoryId);

        // Assert
        assertEquals(1, subCategories.size());
        assertNotNull(subCategories.get(0).getCreatedAt());
    }
}
