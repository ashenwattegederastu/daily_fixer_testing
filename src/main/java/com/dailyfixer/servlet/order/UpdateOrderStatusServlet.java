package com.dailyfixer.servlet.order;

import com.dailyfixer.dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * UpdateOrderStatusServlet - Handles AJAX requests to update order status.
 * 
 * URL: /UpdateOrderStatusServlet
 * Method: POST
 * Parameters: orderId, status
 */
@WebServlet("/UpdateOrderStatusServlet")
public class UpdateOrderStatusServlet extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        System.out.println("UpdateOrderStatusServlet initialized");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String orderId = request.getParameter("orderId");
            String status = request.getParameter("status");

            // Validate parameters
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

            // Validate status value
            String statusUpper = status.trim().toUpperCase();
            if (!isValidStatus(statusUpper)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Invalid status: " + status + "\"}");
                return;
            }

            // Update order status in database
            boolean updated = orderDAO.updateStatus(orderId, statusUpper);

            if (updated) {
                System.out.println("Order status updated: " + orderId + " -> " + statusUpper);
                out.print("{\"success\":true,\"message\":\"Status updated successfully\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Failed to update order status\"}");
            }

        } catch (Exception e) {
            System.err.println("Error updating order status: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Server error: " + e.getMessage() + "\"}");
        } finally {
            out.close();
        }
    }

    /**
     * Validate if the status is one of the allowed values.
     */
    private boolean isValidStatus(String status) {
        return "PENDING".equals(status) ||
               "PROCESSING".equals(status) ||
               "OUT_FOR_DELIVERY".equals(status) ||
               "DELIVERED".equals(status) ||
               "PAID".equals(status) ||
               "CANCELLED".equals(status) ||
               "FAILED".equals(status);
    }
}
