package com.dailyfixer.servlet.driver;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/deliveryAssignment")
public class DeliveryAssignmentServlet extends HttpServlet {

    private DeliveryAssignmentDAO assignmentDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        assignmentDAO = new DeliveryAssignmentDAO();
    }

    /** GET: list assignments for logged-in driver */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || !"driver".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            String filter = request.getParameter("filter");
            List<DeliveryAssignment> assignments = assignmentDAO.getAssignmentsByDriver(currentUser.getUserId());
            request.setAttribute("assignments", assignments);
            request.setAttribute("filter", filter);
            request.getRequestDispatcher("/pages/dashboards/driverdash/deliveryrequests.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/deliveryrequests.jsp?error=load_failed");
        }
    }

    /** POST: update assignment status */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || !"driver".equals(currentUser.getRole())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        try {
            String action = request.getParameter("action");
            String assignmentIdStr = request.getParameter("assignmentId");

            if (assignmentIdStr == null || assignmentIdStr.isBlank()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Missing assignmentId\"}");
                return;
            }

            int assignmentId = Integer.parseInt(assignmentIdStr);
            String newStatus = null;

            if ("pickup".equals(action)) newStatus = "PICKED_UP";
            else if ("deliver".equals(action)) newStatus = "DELIVERED";
            else if ("fail".equals(action)) newStatus = "FAILED";

            if (newStatus == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Invalid action\"}");
                return;
            }

            boolean updated = assignmentDAO.updateStatus(assignmentId, newStatus);
            if (updated) {
                out.print("{\"success\":true,\"status\":\"" + newStatus + "\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Update failed\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Server error\"}");
        }
    }
}
