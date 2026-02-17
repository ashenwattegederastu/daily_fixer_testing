package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/bookings/requests")
public class BookingRequestsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
            
            BookingDAO bookingDAO = new BookingDAO();
            List<Booking> requests = bookingDAO.getBookingsByTechnicianAndStatus(currentUser.getUserId(), "REQUESTED");
            
            request.setAttribute("bookingRequests", requests);
            request.getRequestDispatcher("/pages/dashboards/techniciandash/booking-requests.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading booking requests: " + e.getMessage());
        }
    }
}
