package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/technician/bookings/completed")
public class TechnicianCompletedBookingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");

            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
                return;
            }

            BookingDAO bookingDAO = new BookingDAO();
            int techId = currentUser.getUserId();

            // Fetch both TECHNICIAN_COMPLETED (awaiting user confirm) and FULLY_COMPLETED
            List<Booking> techCompleted = bookingDAO.getBookingsByTechnicianAndStatus(techId, "TECHNICIAN_COMPLETED");
            List<Booking> fullyCompleted = bookingDAO.getBookingsByTechnicianAndStatus(techId, "FULLY_COMPLETED");

            List<Booking> allCompleted = new ArrayList<>();
            allCompleted.addAll(techCompleted);
            allCompleted.addAll(fullyCompleted);

            request.setAttribute("completedBookings", allCompleted);
            request.getRequestDispatcher("/pages/dashboards/techniciandash/completedBookings.jsp").forward(request,
                    response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error loading completed bookings: " + e.getMessage());
        }
    }
}
