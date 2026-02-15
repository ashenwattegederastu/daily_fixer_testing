package com.dailyfixer.dao;

import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for StoreDAO using H2 in-memory database.
 */
class StoreDAOTest {

    private StoreDAOTestHelper storeDAO;
    private UserDAOTestHelper userDAO;
    private int storeOwnerId;

    @BeforeEach
    void setUp() throws Exception {
        storeDAO = new StoreDAOTestHelper();
        userDAO = new UserDAOTestHelper();
        TestDBConnection.clearAllTables();

        // Create a store owner user for testing
        User owner = new User();
        owner.setFirstName("Store");
        owner.setLastName("Owner");
        owner.setUsername("storeowner1");
        owner.setEmail("owner@store.com");
        owner.setPassword("password");
        owner.setPhoneNumber("0771234567");
        owner.setCity("Colombo");
        owner.setRole("store_owner");
        storeOwnerId = userDAO.saveUser(owner);
    }

    @Test
    @DisplayName("Should add store successfully")
    void testAddStore() {
        // Arrange
        Store store = new Store();
        store.setUserId(storeOwnerId);
        store.setStoreName("ABC Hardware Store");
        store.setStoreAddress("123 Main Street");
        store.setStoreCity("Colombo");
        store.setStoreType("Hardware");
        store.setLatitude(6.9271);
        store.setLongitude(79.8612);

        // Act
        boolean result = storeDAO.addStore(store);

        // Assert
        assertTrue(result, "Store should be added successfully");
        assertTrue(store.getStoreId() > 0, "Store ID should be generated");
    }

    @Test
    @DisplayName("Should retrieve store by ID")
    void testGetStoreById() {
        // Arrange
        Store store = new Store();
        store.setUserId(storeOwnerId);
        store.setStoreName("XYZ Auto Parts");
        store.setStoreAddress("456 Park Avenue");
        store.setStoreCity("Kandy");
        store.setStoreType("Auto Parts");
        store.setLatitude(7.2906);
        store.setLongitude(80.6337);
        storeDAO.addStore(store);
        int storeId = store.getStoreId();

        // Act
        Store retrievedStore = storeDAO.getStoreById(storeId);

        // Assert
        assertNotNull(retrievedStore);
        assertEquals(storeId, retrievedStore.getStoreId());
        assertEquals("XYZ Auto Parts", retrievedStore.getStoreName());
        assertEquals("456 Park Avenue", retrievedStore.getStoreAddress());
        assertEquals("Kandy", retrievedStore.getStoreCity());
        assertEquals("Auto Parts", retrievedStore.getStoreType());
        assertEquals(7.2906, retrievedStore.getLatitude(), 0.0001);
        assertEquals(80.6337, retrievedStore.getLongitude(), 0.0001);
        assertEquals(storeOwnerId, retrievedStore.getUserId());
    }

    @Test
    @DisplayName("Should return null for non-existent store ID")
    void testGetStoreById_NotFound() {
        // Act
        Store store = storeDAO.getStoreById(9999);

        // Assert
        assertNull(store);
    }

    @Test
    @DisplayName("Should update store coordinates")
    void testUpdateStoreCoordinates() {
        // Arrange
        Store store = new Store();
        store.setUserId(storeOwnerId);
        store.setStoreName("Test Store");
        store.setStoreAddress("Test Address");
        store.setStoreCity("Galle");
        store.setStoreType("General");
        store.setLatitude(6.0535);
        store.setLongitude(80.2210);
        storeDAO.addStore(store);
        int storeId = store.getStoreId();

        // Act
        double newLat = 6.9550;
        double newLng = 79.8500;
        boolean result = storeDAO.updateStoreCoordinates(storeId, newLat, newLng);

        // Assert
        assertTrue(result);
        Store updatedStore = storeDAO.getStoreById(storeId);
        assertEquals(newLat, updatedStore.getLatitude(), 0.0001);
        assertEquals(newLng, updatedStore.getLongitude(), 0.0001);
    }

    @Test
    @DisplayName("Should handle multiple stores for different owners")
    void testMultipleStores() {
        // Arrange - Create another store owner
        User owner2 = new User();
        owner2.setFirstName("Second");
        owner2.setLastName("Owner");
        owner2.setUsername("storeowner2");
        owner2.setEmail("owner2@store.com");
        owner2.setPassword("password");
        owner2.setPhoneNumber("0779876543");
        owner2.setCity("Kandy");
        owner2.setRole("store_owner");
        int owner2Id = userDAO.saveUser(owner2);

        // Add stores for both owners
        Store store1 = new Store();
        store1.setUserId(storeOwnerId);
        store1.setStoreName("Owner 1 Store");
        store1.setStoreAddress("Address 1");
        store1.setStoreCity("Colombo");
        store1.setStoreType("Type1");
        store1.setLatitude(6.9271);
        store1.setLongitude(79.8612);
        storeDAO.addStore(store1);

        Store store2 = new Store();
        store2.setUserId(owner2Id);
        store2.setStoreName("Owner 2 Store");
        store2.setStoreAddress("Address 2");
        store2.setStoreCity("Kandy");
        store2.setStoreType("Type2");
        store2.setLatitude(7.2906);
        store2.setLongitude(80.6337);
        storeDAO.addStore(store2);

        // Act & Assert
        Store retrieved1 = storeDAO.getStoreById(store1.getStoreId());
        Store retrieved2 = storeDAO.getStoreById(store2.getStoreId());

        assertNotNull(retrieved1);
        assertNotNull(retrieved2);
        assertEquals(storeOwnerId, retrieved1.getUserId());
        assertEquals(owner2Id, retrieved2.getUserId());
        assertEquals("Owner 1 Store", retrieved1.getStoreName());
        assertEquals("Owner 2 Store", retrieved2.getStoreName());
    }

    @Test
    @DisplayName("Should handle store with zero coordinates")
    void testStoreWithZeroCoordinates() {
        // Arrange
        Store store = new Store();
        store.setUserId(storeOwnerId);
        store.setStoreName("Store Without GPS");
        store.setStoreAddress("Some Address");
        store.setStoreCity("Colombo");
        store.setStoreType("General");
        store.setLatitude(0.0);
        store.setLongitude(0.0);

        // Act
        boolean result = storeDAO.addStore(store);

        // Assert
        assertTrue(result);
        Store retrieved = storeDAO.getStoreById(store.getStoreId());
        assertNotNull(retrieved);
        assertEquals(0.0, retrieved.getLatitude(), 0.0001);
        assertEquals(0.0, retrieved.getLongitude(), 0.0001);
    }

    @Test
    @DisplayName("Should not update coordinates for non-existent store")
    void testUpdateCoordinates_StoreNotFound() {
        // Act
        boolean result = storeDAO.updateStoreCoordinates(9999, 6.9271, 79.8612);

        // Assert
        assertFalse(result);
    }
}
