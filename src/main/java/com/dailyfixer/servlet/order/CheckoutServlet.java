package com.dailyfixer.servlet.order;

import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.CartItem;
import com.dailyfixer.model.Discount;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.OrderItem;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;
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
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * CheckoutServlet - Handles customer form submission from checkout page.
 * Creates per-store orders with order items, validates stock, and redirects to payment.
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
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        productDAO = new ProductDAO();
        variantDAO = new ProductVariantDAO();
        storeDAO = new StoreDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // Get form parameters
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String amountStr = request.getParameter("amount");

        // Validate required fields
        if (isEmpty(firstName) || isEmpty(lastName) || isEmpty(email) ||
                isEmpty(phone) || isEmpty(address) || isEmpty(city) || isEmpty(amountStr)) {
            response.sendRedirect("checkout.jsp?error=missing_fields");
            return;
        }

        // Get cart from session
        @SuppressWarnings("unchecked")
        Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            // Fall back to itemsToCheckout (Buy Now flow)
            @SuppressWarnings("unchecked")
            Map<String, CartItem> itemsToCheckout = (Map<String, CartItem>) session.getAttribute("itemsToCheckout");
            cart = itemsToCheckout;
        }

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("checkout.jsp?error=empty_cart");
            return;
        }

        // Validate stock and re-validate discounts for all items
        for (CartItem item : cart.values()) {
            try {
                int availableStock;
                if (item.getVariantId() != null) {
                    ProductVariant variant = variantDAO.getVariantById(item.getVariantId());
                    if (variant == null) {
                        response.sendRedirect("checkout.jsp?error=product_unavailable&product=" +
                                encodeParam(item.getName()));
                        return;
                    }
                    availableStock = variant.getQuantity();
                } else {
                    Product product = productDAO.getProductById(item.getProductId());
                    if (product == null) {
                        response.sendRedirect("checkout.jsp?error=product_unavailable&product=" +
                                encodeParam(item.getName()));
                        return;
                    }
                    availableStock = product.getQuantity();
                }
                if (availableStock < item.getQuantity()) {
                    response.sendRedirect("checkout.jsp?error=insufficient_stock&product=" +
                            encodeParam(item.getName()));
                    return;
                }
            } catch (Exception e) {
                System.err.println("Error validating stock for item " + item.getProductId() + ": " + e.getMessage());
                response.sendRedirect("checkout.jsp?error=server_error");
                return;
            }

            // Re-validate discount: if discount expired, reset to current non-discounted price
            if (item.getDiscountName() != null) {
                try {
                    DiscountDAO discountDAO = new DiscountDAO();
                    Discount discount = item.getVariantId() != null
                            ? discountDAO.getActiveDiscountForVariant(item.getVariantId())
                            : discountDAO.getActiveDiscountForProduct(item.getProductId());
                    if (discount == null || !discount.isValid()) {
                        // Discount expired — use original price
                        item.setPrice(item.getOriginalPrice());
                        item.setDiscountAmount(0);
                        item.setDiscountName(null);
                    }
                } catch (Exception e) {
                    System.err.println("Error re-validating discount: " + e.getMessage());
                }
            }
        }

        // Group cart items by storeId
        Map<Integer, List<CartItem>> itemsByStore = new LinkedHashMap<>();
        for (CartItem item : cart.values()) {
            int storeId = item.getStoreId();
            if (storeId == 0) {
                // Fallback: look up the store for this product
                try {
                    Product p = productDAO.getProductById(item.getProductId());
                    if (p != null) {
                        Store store = storeDAO.getStoreByUsername(p.getStoreUsername());
                        if (store != null) {
                            storeId = store.getStoreId();
                            item.setStoreId(storeId);
                            item.setStoreName(store.getStoreName());
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error looking up store for product " + item.getProductId());
                }
            }
            itemsByStore.computeIfAbsent(storeId, k -> new ArrayList<>()).add(item);
        }

        // Create one order per store
        List<String> allOrderIds = new ArrayList<>();
        String firstOrderId = null;

        for (Map.Entry<Integer, List<CartItem>> entry : itemsByStore.entrySet()) {
            int storeId = entry.getKey();
            List<CartItem> storeItems = entry.getValue();

            // Calculate total for this store's items
            BigDecimal storeTotal = BigDecimal.ZERO;
            for (CartItem item : storeItems) {
                storeTotal = storeTotal.add(
                        BigDecimal.valueOf(item.getPrice()).multiply(BigDecimal.valueOf(item.getQuantity())));
            }

            // Build product name summary
            String productNames = storeItems.stream().map(CartItem::getName).collect(Collectors.joining(", "));

            // Resolve store username
            String storeUsername = "";
            if (storeId > 0) {
                try {
                    Store store = storeDAO.getStoreById(storeId);
                    if (store != null) {
                        User storeUser = userDAO.getUserById(store.getUserId());
                        if (storeUser != null) storeUsername = storeUser.getUsername();
                    }
                } catch (Exception e) {
                    System.err.println("Error resolving store username for storeId " + storeId);
                }
            }

            String orderId = generateOrderId();
            Order order = new Order(orderId, firstName, lastName, email, phone, address, city,
                    productNames, storeTotal);
            order.setStoreId(storeId > 0 ? storeId : null);
            order.setStoreUsername(storeUsername);
            if (currentUser != null) order.setBuyerId(currentUser.getUserId());

            if (!orderDAO.createOrder(order)) {
                System.err.println("Failed to create order " + orderId);
                response.sendRedirect("checkout.jsp?error=database_error");
                return;
            }

            // Create an OrderItem record for each cart item
            for (CartItem item : storeItems) {
                BigDecimal unitPrice = BigDecimal.valueOf(item.getPrice());
                BigDecimal totalPrice = unitPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
                OrderItem oi = new OrderItem(orderId, storeId, item.getProductId(), item.getVariantId(),
                        item.getName(), item.getQuantity(), unitPrice, totalPrice);
                orderDAO.createOrderItem(oi);
            }

            allOrderIds.add(orderId);
            if (firstOrderId == null) firstOrderId = orderId;
        }

        // Store order info in session and clear cart
        session.setAttribute("allOrderIds", allOrderIds);
        session.setAttribute("cart", new HashMap<String, CartItem>());
        session.removeAttribute("itemsToCheckout");

        // Set first order for PayHere processing
        Order firstOrder = orderDAO.findOrderById(firstOrderId);
        session.setAttribute("currentOrder", firstOrder);

        response.sendRedirect("payhere?order_id=" + firstOrderId);
    }

    private String generateOrderId() {
        return "DF-" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
    }

    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    private String encodeParam(String value) {
        try {
            return java.net.URLEncoder.encode(value, "UTF-8");
        } catch (Exception e) {
            return value;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("checkout.jsp");
    }
}
