package com.dailyfixer.dao;

import com.dailyfixer.model.Discount;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for DiscountDAO using H2 in-memory database.
 */
class DiscountDAOTest {

    private DiscountDAOTestHelper discountDAO;

    @BeforeEach
    void setUp() throws Exception {
        discountDAO = new DiscountDAOTestHelper();
        TestDBConnection.clearAllTables();
    }

    @Test
    @DisplayName("Should add discount and return generated ID")
    void testAddDiscount() throws Exception {
        // Arrange
        Discount discount = new Discount();
        discount.setDiscountName("Summer Sale");
        discount.setDiscountType("PERCENTAGE");
        discount.setDiscountValue(new BigDecimal("20.00"));
        discount.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        discount.setEndDate(Timestamp.valueOf(LocalDateTime.now().plusDays(30)));
        discount.setStoreUsername("mystore");
        discount.setActive(true);

        // Act
        int discountId = discountDAO.addDiscount(discount);

        // Assert
        assertTrue(discountId > 0, "Discount ID should be generated");
    }

    @Test
    @DisplayName("Should retrieve discount by ID")
    void testGetDiscountById() throws Exception {
        // Arrange
        Discount discount = new Discount();
        discount.setDiscountName("Black Friday");
        discount.setDiscountType("FIXED");
        discount.setDiscountValue(new BigDecimal("50.00"));
        discount.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        discount.setEndDate(Timestamp.valueOf(LocalDateTime.now().plusDays(7)));
        discount.setStoreUsername("electronics");
        discount.setActive(true);
        int discountId = discountDAO.addDiscount(discount);

        // Act
        Discount retrieved = discountDAO.getDiscountById(discountId);

        // Assert
        assertNotNull(retrieved);
        assertEquals(discountId, retrieved.getDiscountId());
        assertEquals("Black Friday", retrieved.getDiscountName());
        assertEquals("FIXED", retrieved.getDiscountType());
        assertEquals(new BigDecimal("50.00"), retrieved.getDiscountValue());
        assertEquals("electronics", retrieved.getStoreUsername());
        assertTrue(retrieved.isActive());
    }

    @Test
    @DisplayName("Should return null for non-existent discount ID")
    void testGetDiscountById_NotFound() throws Exception {
        // Act
        Discount discount = discountDAO.getDiscountById(9999);

        // Assert
        assertNull(discount);
    }

    @Test
    @DisplayName("Should retrieve all discounts for a store")
    void testGetAllDiscounts() throws Exception {
        // Arrange
        Discount discount1 = new Discount();
        discount1.setDiscountName("New Year Sale");
        discount1.setDiscountType("PERCENTAGE");
        discount1.setDiscountValue(new BigDecimal("15.00"));
        discount1.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        discount1.setEndDate(Timestamp.valueOf(LocalDateTime.now().plusDays(10)));
        discount1.setStoreUsername("fashionstore");
        discount1.setActive(true);
        discountDAO.addDiscount(discount1);

        Discount discount2 = new Discount();
        discount2.setDiscountName("Clearance Sale");
        discount2.setDiscountType("PERCENTAGE");
        discount2.setDiscountValue(new BigDecimal("30.00"));
        discount2.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        discount2.setEndDate(Timestamp.valueOf(LocalDateTime.now().plusDays(5)));
        discount2.setStoreUsername("fashionstore");
        discount2.setActive(true);
        discountDAO.addDiscount(discount2);

        // Act
        List<Discount> discounts = discountDAO.getAllDiscounts("fashionstore");

        // Assert
        assertEquals(2, discounts.size());
        assertTrue(discounts.stream().anyMatch(d -> d.getDiscountName().equals("New Year Sale")));
        assertTrue(discounts.stream().anyMatch(d -> d.getDiscountName().equals("Clearance Sale")));
    }

    @Test
    @DisplayName("Should return empty list for store with no discounts")
    void testGetAllDiscounts_EmptyStore() throws Exception {
        // Act
        List<Discount> discounts = discountDAO.getAllDiscounts("emptystore");

        // Assert
        assertNotNull(discounts);
        assertEquals(0, discounts.size());
    }

    @Test
    @DisplayName("Should update discount successfully")
    void testUpdateDiscount() throws Exception {
        // Arrange
        Discount discount = new Discount();
        discount.setDiscountName("Flash Sale");
        discount.setDiscountType("PERCENTAGE");
        discount.setDiscountValue(new BigDecimal("25.00"));
        discount.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        discount.setEndDate(Timestamp.valueOf(LocalDateTime.now().plusDays(2)));
        discount.setStoreUsername("techstore");
        discount.setActive(true);
        int discountId = discountDAO.addDiscount(discount);

        // Act
        discount.setDiscountId(discountId);
        discount.setDiscountName("Updated Flash Sale");
        discount.setDiscountValue(new BigDecimal("35.00"));
        discount.setActive(false);
        boolean updated = discountDAO.updateDiscount(discount);

        // Assert
        assertTrue(updated);
        Discount retrieved = discountDAO.getDiscountById(discountId);
        assertEquals("Updated Flash Sale", retrieved.getDiscountName());
        assertEquals(new BigDecimal("35.00"), retrieved.getDiscountValue());
        assertFalse(retrieved.isActive());
    }

    @Test
    @DisplayName("Should delete discount successfully")
    void testDeleteDiscount() throws Exception {
        // Arrange
        Discount discount = new Discount();
        discount.setDiscountName("Expired Sale");
        discount.setDiscountType("FIXED");
        discount.setDiscountValue(new BigDecimal("10.00"));
        discount.setStartDate(Timestamp.valueOf(LocalDateTime.now().minusDays(10)));
        discount.setEndDate(Timestamp.valueOf(LocalDateTime.now().minusDays(5)));
        discount.setStoreUsername("oldstore");
        discount.setActive(false);
        int discountId = discountDAO.addDiscount(discount);

        // Act
        boolean deleted = discountDAO.deleteDiscount(discountId);

        // Assert
        assertTrue(deleted);
        Discount retrieved = discountDAO.getDiscountById(discountId);
        assertNull(retrieved);
    }

    @Test
    @DisplayName("Should handle percentage discount correctly")
    void testPercentageDiscount() throws Exception {
        // Arrange
        Discount discount = new Discount();
        discount.setDiscountName("50% Off");
        discount.setDiscountType("PERCENTAGE");
        discount.setDiscountValue(new BigDecimal("50.00"));
        discount.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        discount.setEndDate(Timestamp.valueOf(LocalDateTime.now().plusDays(15)));
        discount.setStoreUsername("megastore");
        discount.setActive(true);

        // Act
        int discountId = discountDAO.addDiscount(discount);
        Discount retrieved = discountDAO.getDiscountById(discountId);

        // Assert
        assertEquals("PERCENTAGE", retrieved.getDiscountType());
        assertEquals(new BigDecimal("50.00"), retrieved.getDiscountValue());
    }

    @Test
    @DisplayName("Should handle fixed discount correctly")
    void testFixedDiscount() throws Exception {
        // Arrange
        Discount discount = new Discount();
        discount.setDiscountName("$100 Off");
        discount.setDiscountType("FIXED");
        discount.setDiscountValue(new BigDecimal("100.00"));
        discount.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        discount.setEndDate(Timestamp.valueOf(LocalDateTime.now().plusDays(20)));
        discount.setStoreUsername("premiumstore");
        discount.setActive(true);

        // Act
        int discountId = discountDAO.addDiscount(discount);
        Discount retrieved = discountDAO.getDiscountById(discountId);

        // Assert
        assertEquals("FIXED", retrieved.getDiscountType());
        assertEquals(new BigDecimal("100.00"), retrieved.getDiscountValue());
    }

    @Test
    @DisplayName("Should isolate discounts between different stores")
    void testStoreIsolation() throws Exception {
        // Arrange
        Discount store1Discount = new Discount();
        store1Discount.setDiscountName("Store1 Discount");
        store1Discount.setDiscountType("PERCENTAGE");
        store1Discount.setDiscountValue(new BigDecimal("10.00"));
        store1Discount.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        store1Discount.setEndDate(Timestamp.valueOf(LocalDateTime.now().plusDays(10)));
        store1Discount.setStoreUsername("store1");
        store1Discount.setActive(true);
        discountDAO.addDiscount(store1Discount);

        Discount store2Discount = new Discount();
        store2Discount.setDiscountName("Store2 Discount");
        store2Discount.setDiscountType("FIXED");
        store2Discount.setDiscountValue(new BigDecimal("20.00"));
        store2Discount.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        store2Discount.setEndDate(Timestamp.valueOf(LocalDateTime.now().plusDays(10)));
        store2Discount.setStoreUsername("store2");
        store2Discount.setActive(true);
        discountDAO.addDiscount(store2Discount);

        // Act
        List<Discount> store1Discounts = discountDAO.getAllDiscounts("store1");
        List<Discount> store2Discounts = discountDAO.getAllDiscounts("store2");

        // Assert
        assertEquals(1, store1Discounts.size());
        assertEquals(1, store2Discounts.size());
        assertEquals("Store1 Discount", store1Discounts.get(0).getDiscountName());
        assertEquals("Store2 Discount", store2Discounts.get(0).getDiscountName());
    }
}
