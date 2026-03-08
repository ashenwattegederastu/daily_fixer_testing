package com.dailyfixer.servlet.driver;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * POST /driver/markDelivered
 * Marks an ACCEPTED delivery assignment as DELIVERED.
 * The driver_id guard ensures a driver can only mark their own assignments.
 */
@WebServlet(name = "MarkDeliveredServlet", urlPatterns = {"/driver/markDelivered"})
public class MarkDeliveredServlet extends HttpServlet {

    private final DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !"driver".equalsIgnoreCase(user.getRole())) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String assignmentIdStr = req.getParameter("assignmentId");
        if (assignmentIdStr == null || assignmentIdStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing assignmentId\"}");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            boolean ok = assignmentDAO.markDelivered(assignmentId, user.getUserId());

            if (ok) {
                resp.getWriter().write("{\"success\":true}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Could not mark as delivered. Assignment may not belong to you or is not in ACCEPTED state.\"}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid assignmentId\"}");
        }
    }
}
