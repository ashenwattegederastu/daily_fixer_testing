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

/**
 * CancelOrderServlet - Allows a buyer or store owner to cancel a PENDING order.
 *
 * A buyer can cancel their own order.
 * A store owner can cancel an order that belongs to their store.
 *
 * URL: /cancelOrder
 * Method: POST
 * Parameters: orderId
 */
@WebServlet("/cancelOrder")
public class CancelOrderServlet extends HttpServlet {

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
            User currentUser = (User) request.getSession().getAttribute("currentUser");
            if (currentUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\":false,\"message\":\"Not logged in\"}");
                return;
            }

            String orderId = request.getParameter("orderId");
            if (orderId == null || orderId.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Order ID is required\"}");
                return;
            }

            Order order = orderDAO.findOrderById(orderId);
            if (order == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Order not found\"}");
                return;
            }

            // Only the buyer or the store owner may cancel
            boolean isBuyer = order.getBuyerId() != null &&
                    order.getBuyerId().equals(currentUser.getUserId());
            boolean isStoreOwner = currentUser.getUsername().equals(order.getStoreUsername());

            if (!isBuyer && !isStoreOwner) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"success\":false,\"message\":\"You are not allowed to cancel this order\"}");
                return;
            }

            // Only PENDING or PAID orders can be cancelled
            String currentStatus = order.getStatus() != null ? order.getStatus().toUpperCase() : "";
            if (!"PENDING".equals(currentStatus) && !"PAID".equals(currentStatus)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Order cannot be cancelled in status: " +
                        currentStatus + "\"}");
                return;
            }

            boolean updated = orderDAO.updateStatus(orderId, "CANCELLED");
            if (updated) {
                out.print("{\"success\":true,\"message\":\"Order cancelled successfully\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Failed to cancel order\"}");
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
