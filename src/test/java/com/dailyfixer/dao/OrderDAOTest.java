package com.dailyfixer.dao;

import com.dailyfixer.model.Order;
import com.dailyfixer.model.OrderItem;
import com.dailyfixer.model.ProductSales;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for OrderDAO using H2 in-memory database.
 */
class OrderDAOTest {

    private OrderDAO orderDAO;

    @BeforeEach
    void setUp() throws Exception {
        orderDAO = new TestOrderDAO();
        TestDBConnection.clearAllTables();
    }

    @Test
    @DisplayName("Create order successfully")
    void testCreateOrder() throws Exception {
        // Arrange
        Order order = new Order();
        order.setOrderId("ORD001");
        order.setFirstName("John");
        order.setLastName("Doe");
        order.setEmail("john.doe@example.com");
        order.setPhone("0771234567");
        order.setAddress("123 Main St");
        order.setCity("Colombo");
        order.setProductName("Test Product");
        order.setAmount(new BigDecimal("1500.00"));
        order.setCurrency("LKR");
        order.setStatus("PENDING");
        order.setStoreUsername("teststore");
        order.setBuyerId(1);

        // Act
        boolean result = orderDAO.createOrder(order);

        // Assert
        assertTrue(result, "Order should be created successfully");

        Order retrieved = orderDAO.findOrderById("ORD001");
        assertNotNull(retrieved);
        assertEquals("John", retrieved.getFirstName());
        assertEquals("Doe", retrieved.getLastName());
        assertEquals("john.doe@example.com", retrieved.getEmail());
        assertEquals("PENDING", retrieved.getStatus());
    }

    @Test
    @DisplayName("Find order by ID returns correct order")
    void testFindOrderById() throws Exception {
        // Arrange
        Order order = createTestOrder("ORD002", "Jane", "Smith", "jane@example.com", "PAID");
        orderDAO.createOrder(order);

        // Act
        Order found = orderDAO.findOrderById("ORD002");

        // Assert
        assertNotNull(found);
        assertEquals("ORD002", found.getOrderId());
        assertEquals("Jane", found.getFirstName());
        assertEquals("Smith", found.getLastName());
        assertEquals("PAID", found.getStatus());
    }

    @Test
    @DisplayName("Find non-existent order returns null")
    void testFindOrderByIdNotFound() throws Exception {
        // Act
        Order found = orderDAO.findOrderById("NONEXISTENT");

        // Assert
        assertNull(found, "Non-existent order should return null");
    }

    @Test
    @DisplayName("Update order status successfully")
    void testUpdateOrderStatus() throws Exception {
        // Arrange
        Order order = createTestOrder("ORD003", "Bob", "Builder", "bob@example.com", "PENDING");
        orderDAO.createOrder(order);

        // Act
        boolean result = orderDAO.updateOrderStatus("ORD003", "PAID", "PAYHERE123");

        // Assert
        assertTrue(result);
        Order updated = orderDAO.findOrderById("ORD003");
        assertEquals("PAID", updated.getStatus());
        assertEquals("PAYHERE123", updated.getPayherePaymentId());
    }

    @Test
    @DisplayName("Update status only without payment ID")
    void testUpdateStatusOnly() throws Exception {
        // Arrange
        Order order = createTestOrder("ORD004", "Alice", "Wonder", "alice@example.com", "PENDING");
        orderDAO.createOrder(order);

        // Act
        boolean result = orderDAO.updateStatus("ORD004", "PROCESSING");

        // Assert
        assertTrue(result);
        Order updated = orderDAO.findOrderById("ORD004");
        assertEquals("PROCESSING", updated.getStatus());
    }

    @Test
    @DisplayName("Get orders by status returns matching orders")
    void testGetOrdersByStatus() throws Exception {
        // Arrange
        orderDAO.createOrder(createTestOrder("ORD005", "User1", "Last1", "user1@example.com", "PAID"));
        orderDAO.createOrder(createTestOrder("ORD006", "User2", "Last2", "user2@example.com", "PAID"));
        orderDAO.createOrder(createTestOrder("ORD007", "User3", "Last3", "user3@example.com", "PENDING"));

        // Act
        List<Order> paidOrders = orderDAO.getOrdersByStatus("PAID");

        // Assert
        assertEquals(2, paidOrders.size());
        assertTrue(paidOrders.stream().allMatch(o -> "PAID".equals(o.getStatus())));
    }

    @Test
    @DisplayName("Get orders by status and store filters correctly")
    void testGetOrdersByStatusAndStore() throws Exception {
        // Arrange
        Order order1 = createTestOrder("ORD008", "User1", "Last1", "user1@example.com", "PAID");
        order1.setStoreUsername("store1");
        orderDAO.createOrder(order1);

        Order order2 = createTestOrder("ORD009", "User2", "Last2", "user2@example.com", "PAID");
        order2.setStoreUsername("store1");
        orderDAO.createOrder(order2);

        Order order3 = createTestOrder("ORD010", "User3", "Last3", "user3@example.com", "PAID");
        order3.setStoreUsername("store2");
        orderDAO.createOrder(order3);

        // Act
        List<Order> store1Orders = orderDAO.getOrdersByStatusAndStore("PAID", "store1");

        // Assert
        assertEquals(2, store1Orders.size());
        assertTrue(store1Orders.stream().allMatch(o -> "store1".equals(o.getStoreUsername())));
    }

    @Test
    @DisplayName("Get all orders by store returns valid statuses only")
    void testGetAllOrdersByStore() throws Exception {
        // Arrange
        Order order1 = createTestOrder("ORD011", "User1", "Last1", "user1@example.com", "PAID");
        order1.setStoreUsername("store1");
        orderDAO.createOrder(order1);

        Order order2 = createTestOrder("ORD012", "User2", "Last2", "user2@example.com", "PENDING");
        order2.setStoreUsername("store1");
        orderDAO.createOrder(order2);

        Order order3 = createTestOrder("ORD013", "User3", "Last3", "user3@example.com", "CANCELLED");
        order3.setStoreUsername("store1");
        orderDAO.createOrder(order3);

        // Act
        List<Order> orders = orderDAO.getAllOrdersByStore("store1");

        // Assert
        assertEquals(2, orders.size(), "Should only return orders with valid statuses (PAID, PENDING, etc.)");
        assertTrue(orders.stream().noneMatch(o -> "CANCELLED".equals(o.getStatus())));
    }

    @Test
    @DisplayName("Get orders by buyer ID returns user's orders")
    void testGetOrdersByBuyerId() throws Exception {
        // Arrange
        Order order1 = createTestOrder("ORD014", "Buyer1", "Last1", "buyer1@example.com", "PAID");
        order1.setBuyerId(100);
        orderDAO.createOrder(order1);

        Order order2 = createTestOrder("ORD015", "Buyer1", "Last1", "buyer1@example.com", "PENDING");
        order2.setBuyerId(100);
        orderDAO.createOrder(order2);

        Order order3 = createTestOrder("ORD016", "Buyer2", "Last2", "buyer2@example.com", "PAID");
        order3.setBuyerId(200);
        orderDAO.createOrder(order3);

        // Act
        List<Order> buyer100Orders = orderDAO.getOrdersByBuyerId(100);

        // Assert
        assertEquals(2, buyer100Orders.size());
        assertTrue(buyer100Orders.stream().allMatch(o -> o.getBuyerId() == 100));
    }

    @Test
    @DisplayName("Create order item successfully")
    void testCreateOrderItem() throws Exception {
        // Arrange
        Order order = createTestOrder("ORD017", "Customer", "One", "customer@example.com", "PENDING");
        orderDAO.createOrder(order);

        OrderItem item = new OrderItem();
        item.setOrderId("ORD017");
        item.setStoreId(1);
        item.setProductId(10);
        item.setProductName("Widget");
        item.setQuantity(2);
        item.setUnitPrice(new BigDecimal("50.00"));
        item.setTotalPrice(new BigDecimal("100.00"));
        item.setStatus("PENDING");

        // Act
        boolean result = orderDAO.createOrderItem(item);

        // Assert
        assertTrue(result);
        List<OrderItem> items = orderDAO.getOrderItemsByOrderId("ORD017");
        assertEquals(1, items.size());
        assertEquals("Widget", items.get(0).getProductName());
        assertEquals(2, items.get(0).getQuantity());
    }

    @Test
    @DisplayName("Get order items by order ID returns all items")
    void testGetOrderItemsByOrderId() throws Exception {
        // Arrange
        Order order = createTestOrder("ORD018", "Customer", "Two", "customer2@example.com", "PENDING");
        orderDAO.createOrder(order);

        OrderItem item1 = createTestOrderItem("ORD018", 1, 10, "Product A", 1, "50.00");
        OrderItem item2 = createTestOrderItem("ORD018", 1, 11, "Product B", 2, "30.00");
        orderDAO.createOrderItem(item1);
        orderDAO.createOrderItem(item2);

        // Act
        List<OrderItem> items = orderDAO.getOrderItemsByOrderId("ORD018");

        // Assert
        assertEquals(2, items.size());
    }

    @Test
    @DisplayName("Get order items by store and status filters correctly")
    void testGetOrderItemsByStoreAndStatus() throws Exception {
        // Arrange
        Order order1 = createTestOrder("ORD019", "Customer", "Three", "customer3@example.com", "PAID");
        order1.setStoreUsername("store1");
        orderDAO.createOrder(order1);

        Order order2 = createTestOrder("ORD020", "Customer", "Four", "customer4@example.com", "PENDING");
        order2.setStoreUsername("store1");
        orderDAO.createOrder(order2);

        OrderItem item1 = createTestOrderItem("ORD019", 1, 10, "Product A", 1, "50.00");
        OrderItem item2 = createTestOrderItem("ORD020", 1, 11, "Product B", 2, "30.00");
        orderDAO.createOrderItem(item1);
        orderDAO.createOrderItem(item2);

        // Act
        List<OrderItem> paidItems = orderDAO.getOrderItemsByStoreAndStatus(1, "PAID");

        // Assert
        assertEquals(1, paidItems.size());
        assertEquals("Product A", paidItems.get(0).getProductName());
    }

    @Test
    @DisplayName("Get product sales by store aggregates correctly")
    void testGetProductSalesByStore() throws Exception {
        // Arrange
        Order order1 = createTestOrder("ORD021", "Customer", "Five", "customer5@example.com", "PAID");
        order1.setStoreUsername("store1");
        orderDAO.createOrder(order1);

        Order order2 = createTestOrder("ORD022", "Customer", "Six", "customer6@example.com", "PAID");
        order2.setStoreUsername("store1");
        orderDAO.createOrder(order2);

        OrderItem item1 = createTestOrderItem("ORD021", 1, 10, "Widget", 5, "10.00");
        OrderItem item2 = createTestOrderItem("ORD022", 1, 10, "Widget", 3, "10.00");
        OrderItem item3 = createTestOrderItem("ORD021", 1, 11, "Gadget", 2, "20.00");
        orderDAO.createOrderItem(item1);
        orderDAO.createOrderItem(item2);
        orderDAO.createOrderItem(item3);

        // Act
        List<ProductSales> sales = orderDAO.getProductSalesByStore("store1");

        // Assert
        assertEquals(2, sales.size());

        // Widget should have total quantity of 8 (5 + 3)
        ProductSales widgetSales = sales.stream()
                .filter(s -> s.getProductName().equals("Widget"))
                .findFirst()
                .orElse(null);
        assertNotNull(widgetSales);
        assertEquals(8, widgetSales.getQuantitySold());
    }

    @Test
    @DisplayName("Empty results when no orders exist")
    void testEmptyResults() throws Exception {
        // Act & Assert
        assertEquals(0, orderDAO.getOrdersByStatus("PAID").size());
        assertEquals(0, orderDAO.getOrdersByBuyerId(999).size());
        assertEquals(0, orderDAO.getAllOrdersByStore("nonexistent").size());
    }

    // Helper methods

    private Order createTestOrder(String orderId, String firstName, String lastName, String email, String status) {
        Order order = new Order();
        order.setOrderId(orderId);
        order.setFirstName(firstName);
        order.setLastName(lastName);
        order.setEmail(email);
        order.setPhone("0771234567");
        order.setAddress("123 Test St");
        order.setCity("Colombo");
        order.setProductName("Test Product");
        order.setAmount(new BigDecimal("100.00"));
        order.setCurrency("LKR");
        order.setStatus(status);
        order.setStoreUsername("teststore");
        order.setBuyerId(1);
        return order;
    }

    private OrderItem createTestOrderItem(String orderId, int storeId, int productId,
            String productName, int quantity, String unitPrice) {
        OrderItem item = new OrderItem();
        item.setOrderId(orderId);
        item.setStoreId(storeId);
        item.setProductId(productId);
        item.setProductName(productName);
        item.setQuantity(quantity);
        item.setUnitPrice(new BigDecimal(unitPrice));
        item.setTotalPrice(new BigDecimal(unitPrice).multiply(new BigDecimal(quantity)));
        item.setStatus("PENDING");
        return item;
    }
}
