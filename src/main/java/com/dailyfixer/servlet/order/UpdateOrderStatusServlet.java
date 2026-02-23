package com.dailyfixer.servlet.order;

import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * UpdateOrderStatusServlet - Handles AJAX requests to update order status.
 *
 * Enforces valid status transitions and checks that the requesting store user
 * actually owns the order (§8.1, §9.1).
 *
 * URL: /UpdateOrderStatusServlet
 * Method: POST
 * Parameters: orderId, status
 */
@WebServlet("/UpdateOrderStatusServlet")
public class UpdateOrderStatusServlet extends HttpServlet {

    /** Valid forward transitions for each status. */
    private static final Map<String, List<String>> VALID_TRANSITIONS;
    static {
        Map<String, List<String>> m = new HashMap<>();
        m.put("PENDING",          Arrays.asList("PAID", "CANCELLED"));
        m.put("PAID",             Arrays.asList("PROCESSING", "CANCELLED"));
        m.put("PROCESSING",       Collections.singletonList("OUT_FOR_DELIVERY"));
        m.put("OUT_FOR_DELIVERY", Collections.singletonList("DELIVERED"));
        m.put("DELIVERED",        Collections.emptyList());
        m.put("CANCELLED",        Collections.emptyList());
        VALID_TRANSITIONS = Collections.unmodifiableMap(m);
    }

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // Authorization: only store users may change order status (§9.1)
            User currentUser = (User) request.getSession().getAttribute("currentUser");
            if (currentUser == null || !"store".equalsIgnoreCase(currentUser.getRole())) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
                return;
            }

            String orderId = request.getParameter("orderId");
            String status  = request.getParameter("status");

            if (orderId == null || orderId.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Order ID is required\"}");
                return;
            }

            if (status == null || status.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Status is required\"}");
                return;
            }

            String newStatus = status.trim().toUpperCase();

            // Fetch the existing order
            Order order = orderDAO.findOrderById(orderId);
            if (order == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Order not found\"}");
                return;
            }

            // Ownership check: store_username must match logged-in user (§9.1)
            if (!currentUser.getUsername().equals(order.getStoreUsername())) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"success\":false,\"message\":\"You do not own this order\"}");
                return;
            }

            // Validate the transition (§8.1)
            String currentStatus = order.getStatus() != null ? order.getStatus().toUpperCase() : "";
            List<String> allowed = VALID_TRANSITIONS.getOrDefault(currentStatus, Collections.emptyList());
            if (!allowed.contains(newStatus)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Invalid transition from " +
                        currentStatus + " to " + newStatus + "\"}");
                return;
            }

            boolean updated = orderDAO.updateStatus(orderId, newStatus);
            if (updated) {
                out.print("{\"success\":true,\"message\":\"Status updated to " + newStatus + "\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Failed to update order status\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Server error\"}");
        } finally {
            out.close();
        }
    }
}

