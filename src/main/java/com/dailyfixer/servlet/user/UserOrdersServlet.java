package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.OrderItem;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

/**
 * UserOrdersServlet - Handles fetching orders for the logged-in user.
 * Redirects to myPurchases.jsp with the user's orders.
 *
 * URL: /user/orders
 * Method: GET
 */
@WebServlet("/user/orders")
public class UserOrdersServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        productDAO = new ProductDAO();
        System.out.println("UserOrdersServlet initialized");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // Check if user is logged in
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
            return;
        }

        // Check if the user has the correct role
        String role = currentUser.getRole();
        if (role == null || !"user".equalsIgnoreCase(role.trim())) {
            response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
            return;
        }

        try {
            // Get orders for the logged-in user
            List<Order> orders = orderDAO.getOrdersByBuyerId(currentUser.getUserId());
            System.out.println("Found " + orders.size() + " orders for user ID: " + currentUser.getUserId());

            // Get order items for each order
            Map<String, List<OrderItem>> orderItemsMap = new HashMap<>();
            Map<Integer, Product> productsMap = new HashMap<>();

            for (Order order : orders) {
                List<OrderItem> items = orderDAO.getOrderItemsByOrderId(order.getOrderId());
                orderItemsMap.put(order.getOrderId(), items);

                // Fetch product details for each item to get images
                for (OrderItem item : items) {
                    if (!productsMap.containsKey(item.getProductId())) {
                        try {
                            Product product = productDAO.getProductById(item.getProductId());
                            if (product != null) {
                                productsMap.put(item.getProductId(), product);
                            }
                        } catch (Exception e) {
                            System.err
                                    .println("Could not fetch product " + item.getProductId() + ": " + e.getMessage());
                        }
                    }
                }
            }

            // Set attributes for the JSP
            request.setAttribute("orders", orders);
            request.setAttribute("orderItemsMap", orderItemsMap);
            request.setAttribute("productsMap", productsMap);

            // Forward to myPurchases.jsp
            request.getRequestDispatcher("/pages/dashboards/userdash/myPurchases.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error fetching user orders: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Failed to load orders");
            request.getRequestDispatcher("/pages/dashboards/userdash/myPurchases.jsp").forward(request, response);
        }
    }
}
