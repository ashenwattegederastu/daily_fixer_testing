package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/CompleteBookingServlet")
public class CompleteBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null || !"technician".equalsIgnoreCase(user.getRole())) {
            out.write("{\"success\": false, \"message\": \"Unauthorized access\"}");
            return;
        }

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            
            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null) {
                out.write("{\"success\": false, \"message\": \"Booking not found\"}");
                return;
            }
            
            if (booking.getTechnicianId() != user.getUserId()) {
                out.write("{\"success\": false, \"message\": \"Unauthorized\"}");
                return;
            }
            
            if (booking.getStatus() != Booking.BookingStatus.ACCEPTED) {
                out.write("{\"success\": false, \"message\": \"Only accepted bookings can be marked as complete\"}");
                return;
            }

            bookingDAO.updateBookingStatus(bookingId, Booking.BookingStatus.TECHNICIAN_COMPLETED);

            out.write("{\"success\": true, \"message\": \"Booking marked as complete. Waiting for customer confirmation.\"}");

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
