package com.dailyfixer.servlet.order;

import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

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

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String orderId = request.getParameter("orderId");
        if (orderId == null || orderId.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/myPurchases.jsp?error=missing_order");
            return;
        }

        try {
            Order order = orderDAO.findOrderById(orderId);
            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/myPurchases.jsp?error=order_not_found");
                return;
            }

            // Only the buyer can cancel their own order
            if (order.getBuyerId() == null || !order.getBuyerId().equals(currentUser.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/myPurchases.jsp?error=unauthorized");
                return;
            }

            // Only PENDING or PAID orders can be cancelled
            String status = order.getStatus();
            if (!"PENDING".equalsIgnoreCase(status) && !"PAID".equalsIgnoreCase(status)) {
                response.sendRedirect(request.getContextPath() + "/myPurchases.jsp?error=cannot_cancel");
                return;
            }

            boolean updated = orderDAO.updateStatus(orderId, "CANCELLED");
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/myPurchases.jsp?success=cancelled");
            } else {
                response.sendRedirect(request.getContextPath() + "/myPurchases.jsp?error=cancel_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/myPurchases.jsp?error=server_error");
        }
    }
}
