package com.dailyfixer.diagnostic.dao;

import com.dailyfixer.model.Category;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for diagnostic CategoryDAO using H2 in-memory database.
 */
class CategoryDAOTest {

    private CategoryDAOTestHelper categoryDAO;

    @BeforeEach
    void setUp() throws Exception {
        categoryDAO = new CategoryDAOTestHelper();
        TestDBConnection.clearAllTables();
    }

    @Test
    @DisplayName("Should create main category")
    void testCreateMainCategory() throws Exception {
        Category category = new Category();
        category.setName("Electronics");
        
        int id = categoryDAO.createCategory(category);
        
        assertTrue(id > 0);
        assertTrue(categoryDAO.getCategoryById(id).isMainCategory());
    }

    @Test
    @DisplayName("Should create sub-category")
    void testCreateSubCategory() throws Exception {
        Category main = new Category();
        main.setName("Appliances");
        int mainId = categoryDAO.createCategory(main);
        
        Category sub = new Category();
        sub.setName("Refrigerator");
        sub.setParentId(mainId);
        int subId = categoryDAO.createCategory(sub);
        
        assertTrue(subId > 0);
        Category retrieved = categoryDAO.getCategoryById(subId);
        assertFalse(retrieved.isMainCategory());
        assertEquals(mainId, retrieved.getParentId());
    }

    @Test
    @DisplayName("Should retrieve main categories")
    void testGetAllMainCategories() throws Exception {
        Category c1 = new Category();
        c1.setName("Cat1");
        categoryDAO.createCategory(c1);
        
        Category c2 = new Category();
        c2.setName("Cat2");
        categoryDAO.createCategory(c2);
        
        List<Category> categories = categoryDAO.getAllMainCategories();
        assertEquals(2, categories.size());
    }

    @Test
    @DisplayName("Should retrieve sub-categories by parent")
    void testGetSubCategories() throws Exception {
        Category main = new Category();
        main.setName("Main");
        int mainId = categoryDAO.createCategory(main);
        
        Category sub1 = new Category();
        sub1.setName("Sub1");
        sub1.setParentId(mainId);
        categoryDAO.createCategory(sub1);
        
        Category sub2 = new Category();
        sub2.setName("Sub2");
        sub2.setParentId(mainId);
        categoryDAO.createCategory(sub2);
        
        List<Category> subs = categoryDAO.getSubCategories(mainId);
        assertEquals(2, subs.size());
    }

    @Test
    @DisplayName("Should update category name")
    void testUpdateCategory() throws Exception {
        Category category = new Category();
        category.setName("Old Name");
        int id = categoryDAO.createCategory(category);
        
        boolean updated = categoryDAO.updateCategory(id, "New Name");
        
        assertTrue(updated);
        assertEquals("New Name", categoryDAO.getCategoryById(id).getName());
    }

    @Test
    @DisplayName("Should delete category")
    void testDeleteCategory() throws Exception {
        Category category = new Category();
        category.setName("ToDelete");
        int id = categoryDAO.createCategory(category);
        
        boolean deleted = categoryDAO.deleteCategory(id);
        
        assertTrue(deleted);
        assertNull(categoryDAO.getCategoryById(id));
    }
}
