package com.dailyfixer.servlet;

import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = Integer.parseInt(request.getParameter("userId"));
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String phoneNumber = request.getParameter("phoneNumber");
        String city = request.getParameter("city");

        UserDAO userDAO = new UserDAO();
        boolean updated = userDAO.updateUserInfo(userId, firstName, lastName, phoneNumber, city);

        if (updated) {
            // Update session
            User updatedUser = userDAO.getUserById(userId);
            request.getSession().setAttribute("currentUser", updatedUser);
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/userdash/myProfile.jsp");
        } else {
            response.getWriter().println("<script>alert('Update failed. Try again.');history.back();</script>");
        }
    }
}
