package com.dailyfixer.servlet.order;

import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.CartItem;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.OrderItem;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * CheckoutServlet - Handles customer form submission from checkout page.
 *
 * Creates per-store orders with order_items, validates stock before committing,
 * and redirects to PayHere payment for the first order.
 *
 * URL: /checkout
 * Method: POST
 */
@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    private ProductVariantDAO variantDAO;
    private StoreDAO storeDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        productDAO = new ProductDAO();
        variantDAO = new ProductVariantDAO();
        storeDAO = new StoreDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String firstName = request.getParameter("firstName");
            String lastName  = request.getParameter("lastName");
            String email     = request.getParameter("email");
            String phone     = request.getParameter("phone");
            String address   = request.getParameter("address");
            String city      = request.getParameter("city");
            String product   = request.getParameter("product");
            String amountStr = request.getParameter("amount");

            if (isEmpty(firstName) || isEmpty(lastName) || isEmpty(email) ||
                    isEmpty(phone) || isEmpty(address) || isEmpty(city) ||
                    isEmpty(product) || isEmpty(amountStr)) {
                response.sendRedirect("checkout.html?error=missing_fields");
                return;
            }

            BigDecimal amount;
            try {
                amount = new BigDecimal(amountStr.replace(",", ""));
            } catch (NumberFormatException e) {
                response.sendRedirect("checkout.html?error=invalid_amount");
                return;
            }

            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");

            // Retrieve items queued for checkout (§3.4)
            @SuppressWarnings("unchecked")
            Map<String, CartItem> itemsToCheckout =
                    (Map<String, CartItem>) session.getAttribute("itemsToCheckout");

            if (itemsToCheckout == null || itemsToCheckout.isEmpty()) {
                response.sendRedirect("checkout.html?error=empty_cart");
                return;
            }

            // Validate stock for every item before creating any order (§3.5)
            for (CartItem item : itemsToCheckout.values()) {
                int available;
                try {
                    if (item.getVariantId() != null) {
                        available = variantDAO.getVariantById(item.getVariantId()).getQuantity();
                    } else {
                        available = productDAO.getProductById(item.getProductId()).getQuantity();
                    }
                } catch (Exception e) {
                    response.sendRedirect("checkout.html?error=stock_check_failed");
                    return;
                }
                if (available < item.getQuantity()) {
                    response.sendRedirect("checkout.html?error=insufficient_stock&product=" +
                            item.getName().replace(" ", "+"));
                    return;
                }
            }

            // Group items by store for per-store orders (§4.1 Option A)
            Map<Integer, List<CartItem>> byStore = groupByStore(itemsToCheckout);

            String firstOrderId = null;
            Order firstOrder = null;

            for (Map.Entry<Integer, List<CartItem>> entry : byStore.entrySet()) {
                int storeId = entry.getKey();
                List<CartItem> storeItems = entry.getValue();

                // Calculate per-store total
                BigDecimal storeTotal = BigDecimal.ZERO;
                StringBuilder productNames = new StringBuilder();
                for (CartItem item : storeItems) {
                    storeTotal = storeTotal.add(
                            BigDecimal.valueOf(item.getPrice()).multiply(BigDecimal.valueOf(item.getQuantity())));
                    if (productNames.length() > 0) productNames.append(", ");
                    productNames.append(item.getName());
                }

                String orderId = generateOrderId();
                Order order = new Order(orderId, firstName, lastName, email,
                        phone, address, city, productNames.toString(), storeTotal);

                // Resolve store username from storeId
                Store store = storeDAO.getStoreById(storeId);
                if (store != null) {
                    String username = resolveStoreUsername(store.getUserId());
                    order.setStoreUsername(username);
                }
                if (currentUser != null) {
                    order.setBuyerId(currentUser.getUserId());
                }

                boolean saved = orderDAO.createOrder(order);
                if (!saved) {
                    response.sendRedirect("checkout.html?error=database_error");
                    return;
                }

                // Create order_items (§3.4)
                for (CartItem item : storeItems) {
                    BigDecimal unitPrice = BigDecimal.valueOf(item.getPrice());
                    BigDecimal totalPrice = unitPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
                    OrderItem oi = new OrderItem(
                            orderId, storeId,
                            item.getProductId(), item.getVariantId(),
                            item.getName(),
                            item.getQuantity(),
                            unitPrice, totalPrice);
                    orderDAO.createOrderItem(oi);
                }

                if (firstOrderId == null) {
                    firstOrderId = orderId;
                    firstOrder = order;
                }
            }

            // Clear cart and itemsToCheckout after successful order creation
            session.removeAttribute("cart");
            session.removeAttribute("itemsToCheckout");
            session.setAttribute("currentOrder", firstOrder);

            response.sendRedirect("payhere?order_id=" + firstOrderId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("checkout.html?error=server_error");
        }
    }

    /**
     * Group cart items by their storeId.
     * Items with storeId == 0 (unknown store) are placed in a catch-all group.
     */
    private Map<Integer, List<CartItem>> groupByStore(Map<String, CartItem> items) {
        Map<Integer, List<CartItem>> map = new LinkedHashMap<>();
        for (CartItem item : items.values()) {
            int sid = item.getStoreId(); // 0 if unknown
            map.computeIfAbsent(sid, k -> new ArrayList<>()).add(item);
        }
        return map;
    }

    /** Resolve a store owner's username from user_id (used for order.store_username). */
    private String resolveStoreUsername(int userId) {
        try {
            java.sql.Connection conn = com.dailyfixer.util.DBConnection.getConnection();
            try (java.sql.PreparedStatement ps =
                    conn.prepareStatement("SELECT username FROM users WHERE user_id = ?")) {
                ps.setInt(1, userId);
                java.sql.ResultSet rs = ps.executeQuery();
                if (rs.next()) return rs.getString("username");
            } finally {
                conn.close();
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    private String generateOrderId() {
        String uuid = UUID.randomUUID().toString().replace("-", "");
        return "DF-" + uuid.substring(0, 8).toUpperCase();
    }

    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("checkout.html");
    }
}

