package com.dailyfixer.dao;

import com.dailyfixer.model.Product;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for ProductDAO using H2 in-memory database.
 */
class ProductDAOTest {

    private ProductDAOTestHelper productDAO;

    @BeforeEach
    void setUp() throws Exception {
        productDAO = new ProductDAOTestHelper();
        TestDBConnection.clearAllTables();
    }

    @Test
    @DisplayName("Should add product and return generated ID")
    void testAddProduct() throws Exception {
        // Arrange
        Product product = new Product();
        product.setName("Hammer");
        product.setType("Tool");
        product.setQuantity(50);
        product.setQuantityUnit("pieces");
        product.setPrice(15.99);
        product.setStoreUsername("toolstore");
        product.setDescription("Heavy duty hammer");
        product.setStoreId(1);

        // Act
        productDAO.addProduct(product);

        // Assert
        assertTrue(product.getProductId() > 0, "Product ID should be generated");
    }

    @Test
    @DisplayName("Should retrieve product by ID")
    void testGetProductById() throws Exception {
        // Arrange
        Product product = new Product();
        product.setName("Screwdriver");
        product.setType("Tool");
        product.setQuantity(100);
        product.setQuantityUnit("pieces");
        product.setPrice(8.50);
        product.setStoreUsername("toolstore");
        product.setDescription("Phillips screwdriver");
        product.setStoreId(1);
        productDAO.addProduct(product);
        int productId = product.getProductId();

        // Act
        Product retrieved = productDAO.getProductById(productId);

        // Assert
        assertNotNull(retrieved);
        assertEquals(productId, retrieved.getProductId());
        assertEquals("Screwdriver", retrieved.getName());
        assertEquals("Tool", retrieved.getType());
        assertEquals(100, retrieved.getQuantity());
        assertEquals("pieces", retrieved.getQuantityUnit());
        assertEquals(new java.math.BigDecimal("8.50"), retrieved.getPrice());
        assertEquals("toolstore", retrieved.getStoreUsername());
        assertEquals("Phillips screwdriver", retrieved.getDescription());
    }

    @Test
    @DisplayName("Should return null for non-existent product ID")
    void testGetProductById_NotFound() throws Exception {
        // Act
        Product product = productDAO.getProductById(9999);

        // Assert
        assertNull(product);
    }

    @Test
    @DisplayName("Should retrieve all products for a store")
    void testGetAllProducts() throws Exception {
        // Arrange
        Product product1 = new Product();
        product1.setName("Drill");
        product1.setType("Power Tool");
        product1.setQuantity(20);
        product1.setQuantityUnit("pieces");
        product1.setPrice(89.99);
        product1.setStoreUsername("powertools");
        product1.setDescription("Electric drill");
        product1.setStoreId(2);
        productDAO.addProduct(product1);

        Product product2 = new Product();
        product2.setName("Saw");
        product2.setType("Power Tool");
        product2.setQuantity(15);
        product2.setQuantityUnit("pieces");
        product2.setPrice(120.00);
        product2.setStoreUsername("powertools");
        product2.setDescription("Circular saw");
        product2.setStoreId(2);
        productDAO.addProduct(product2);

        // Act
        List<Product> products = productDAO.getAllProducts("powertools");

        // Assert
        assertEquals(2, products.size());
        assertTrue(products.stream().anyMatch(p -> p.getName().equals("Drill")));
        assertTrue(products.stream().anyMatch(p -> p.getName().equals("Saw")));
    }

    @Test
    @DisplayName("Should return empty list for store with no products")
    void testGetAllProducts_EmptyStore() throws Exception {
        // Act
        List<Product> products = productDAO.getAllProducts("emptystore");

        // Assert
        assertNotNull(products);
        assertEquals(0, products.size());
    }

    @Test
    @DisplayName("Should update product successfully")
    void testUpdateProduct() throws Exception {
        // Arrange
        Product product = new Product();
        product.setName("Wrench");
        product.setType("Tool");
        product.setQuantity(30);
        product.setQuantityUnit("pieces");
        product.setPrice(12.99);
        product.setStoreUsername("toolstore");
        product.setDescription("Adjustable wrench");
        product.setStoreId(1);
        productDAO.addProduct(product);
        int productId = product.getProductId();

        // Act
        product.setName("Torque Wrench");
        product.setPrice(29.99);
        product.setQuantity(20);
        product.setDescription("Professional torque wrench");
        productDAO.updateProduct(product);

        // Assert
        Product updated = productDAO.getProductById(productId);
        assertEquals("Torque Wrench", updated.getName());
        assertEquals(new java.math.BigDecimal("29.99"), updated.getPrice());
        assertEquals(20, updated.getQuantity());
        assertEquals("Professional torque wrench", updated.getDescription());
    }

    @Test
    @DisplayName("Should delete product successfully")
    void testDeleteProduct() throws Exception {
        // Arrange
        Product product = new Product();
        product.setName("Pliers");
        product.setType("Tool");
        product.setQuantity(40);
        product.setQuantityUnit("pieces");
        product.setPrice(9.99);
        product.setStoreUsername("toolstore");
        product.setDescription("Needle nose pliers");
        product.setStoreId(1);
        productDAO.addProduct(product);
        int productId = product.getProductId();

        // Act
        productDAO.deleteProduct(productId);

        // Assert
        Product deleted = productDAO.getProductById(productId);
        assertNull(deleted);
    }

    @Test
    @DisplayName("Should handle product with image data")
    void testProductWithImage() throws Exception {
        // Arrange
        byte[] imageData = "fake-image-data".getBytes();
        Product product = new Product();
        product.setName("Premium Drill");
        product.setType("Power Tool");
        product.setQuantity(10);
        product.setQuantityUnit("pieces");
        product.setPrice(199.99);
        product.setStoreUsername("premiumtools");
        product.setDescription("High-end drill");
        product.setImage(imageData);
        product.setStoreId(3);

        // Act
        productDAO.addProduct(product);
        Product retrieved = productDAO.getProductById(product.getProductId());

        // Assert
        assertNotNull(retrieved.getImage());
        assertArrayEquals(imageData, retrieved.getImage());
    }

    @Test
    @DisplayName("Should isolate products between different stores")
    void testStoreIsolation() throws Exception {
        // Arrange
        Product store1Product = new Product();
        store1Product.setName("Store1 Product");
        store1Product.setType("Type1");
        store1Product.setQuantity(10);
        store1Product.setQuantityUnit("pieces");
        store1Product.setPrice(10.00);
        store1Product.setStoreUsername("store1");
        store1Product.setStoreId(1);
        productDAO.addProduct(store1Product);

        Product store2Product = new Product();
        store2Product.setName("Store2 Product");
        store2Product.setType("Type2");
        store2Product.setQuantity(20);
        store2Product.setQuantityUnit("pieces");
        store2Product.setPrice(20.00);
        store2Product.setStoreUsername("store2");
        store2Product.setStoreId(2);
        productDAO.addProduct(store2Product);

        // Act
        List<Product> store1Products = productDAO.getAllProducts("store1");
        List<Product> store2Products = productDAO.getAllProducts("store2");

        // Assert
        assertEquals(1, store1Products.size());
        assertEquals(1, store2Products.size());
        assertEquals("Store1 Product", store1Products.get(0).getName());
        assertEquals("Store2 Product", store2Products.get(0).getName());
    }

    @Test
    @DisplayName("Should handle addProductAndReturnId correctly")
    void testAddProductAndReturnId() throws Exception {
        // Arrange
        Product product = new Product();
        product.setName("Test Product");
        product.setType("Test Type");
        product.setQuantity(5);
        product.setQuantityUnit("pieces");
        product.setPrice(5.00);
        product.setStoreUsername("teststore");
        product.setStoreId(1);

        // Act
        int returnedId = productDAO.addProductAndReturnId(product);

        // Assert
        assertTrue(returnedId > 0);
        assertEquals(returnedId, product.getProductId());
        
        // Verify product exists
        Product retrieved = productDAO.getProductById(returnedId);
        assertNotNull(retrieved);
        assertEquals("Test Product", retrieved.getName());
    }
}
