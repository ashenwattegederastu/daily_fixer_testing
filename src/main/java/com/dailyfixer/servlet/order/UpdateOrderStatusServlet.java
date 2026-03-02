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
 * Enforces authorization (only the owning store or admin may update) and
 * validates that status transitions follow the correct workflow.
 *
 * URL: /UpdateOrderStatusServlet
 * Method: POST
 * Parameters: orderId, status
 */
@WebServlet("/UpdateOrderStatusServlet")
public class UpdateOrderStatusServlet extends HttpServlet {

    /** Allowed status transitions: key = current status, value = permitted next statuses. */
    private static final Map<String, List<String>> VALID_TRANSITIONS;
    static {
        Map<String, List<String>> t = new HashMap<>();
        t.put("PENDING",          Arrays.asList("PAID", "PROCESSING", "CANCELLED"));
        t.put("PAID",             Arrays.asList("PROCESSING", "CANCELLED"));
        t.put("PROCESSING",       Arrays.asList("OUT_FOR_DELIVERY", "CANCELLED"));
        t.put("OUT_FOR_DELIVERY", Arrays.asList("DELIVERED", "FAILED"));
        t.put("DELIVERED",        Collections.emptyList());
        t.put("CANCELLED",        Collections.emptyList());
        t.put("FAILED",           Arrays.asList("PROCESSING"));
        VALID_TRANSITIONS = Collections.unmodifiableMap(t);
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
            String orderId = request.getParameter("orderId");
            String status  = request.getParameter("status");

            if (isEmpty(orderId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Order ID is required\"}");
                return;
            }
            if (isEmpty(status)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Status is required\"}");
                return;
            }

            String statusUpper = status.trim().toUpperCase();
            if (!VALID_TRANSITIONS.containsKey(statusUpper)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Invalid status: " + statusUpper + "\"}");
                return;
            }

            // Load order to check ownership and current status
            Order order = orderDAO.findOrderById(orderId.trim());
            if (order == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Order not found\"}");
                return;
            }

            // Authorization: only the owning store or an admin may change status
            User user = (User) request.getSession().getAttribute("currentUser");
            if (user == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\":false,\"message\":\"Not authenticated\"}");
                return;
            }
            String role = user.getRole() != null ? user.getRole().trim().toLowerCase() : "";
            if (!"admin".equals(role)) {
                if (!"store".equals(role) || !user.getUsername().equals(order.getStoreUsername())) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"success\":false,\"message\":\"Not authorized to update this order\"}");
                    return;
                }
            }

            // Validate transition
            String currentStatus = order.getStatus() != null ? order.getStatus().trim().toUpperCase() : "PENDING";
            List<String> allowed = VALID_TRANSITIONS.getOrDefault(currentStatus, Collections.emptyList());
            if (!allowed.contains(statusUpper)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Cannot transition from " +
                        currentStatus + " to " + statusUpper + "\"}");
                return;
            }

            boolean updated = orderDAO.updateStatus(orderId.trim(), statusUpper);
            if (updated) {
                out.print("{\"success\":true,\"message\":\"Status updated successfully\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Failed to update order status\"}");
            }

        } catch (Exception e) {
            System.err.println("Error updating order status: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Server error: " +
                    e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            out.close();
        }
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}

