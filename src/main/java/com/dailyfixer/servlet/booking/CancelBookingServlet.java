package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingCancellationDAO;
import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.BookingCancellation;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/CancelBookingServlet")
public class CancelBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null) {
            out.write("{\"success\": false, \"message\": \"Unauthorized access\"}");
            return;
        }

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            String reason = request.getParameter("reason");
            
            if (reason == null || reason.trim().isEmpty()) {
                out.write("{\"success\": false, \"message\": \"Cancellation reason is required\"}");
                return;
            }
            
            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null) {
                out.write("{\"success\": false, \"message\": \"Booking not found\"}");
                return;
            }
            
            boolean isAuthorized = (booking.getUserId() == user.getUserId() && "user".equalsIgnoreCase(user.getRole())) ||
                                   (booking.getTechnicianId() == user.getUserId() && "technician".equalsIgnoreCase(user.getRole()));
            
            if (!isAuthorized) {
                out.write("{\"success\": false, \"message\": \"Unauthorized\"}");
                return;
            }
            
            if (booking.getStatus() == Booking.BookingStatus.CANCELLED || 
                booking.getStatus() == Booking.BookingStatus.FULLY_COMPLETED) {
                out.write("{\"success\": false, \"message\": \"Booking cannot be cancelled\"}");
                return;
            }

            bookingDAO.updateBookingStatus(bookingId, Booking.BookingStatus.CANCELLED);

            BookingCancellation cancellation = new BookingCancellation();
            cancellation.setBookingId(bookingId);
            cancellation.setCancelledBy(user.getUserId());
            cancellation.setCancellationReason(reason);
            
            BookingCancellationDAO cancellationDAO = new BookingCancellationDAO();
            cancellationDAO.createCancellation(cancellation);

            out.write("{\"success\": true, \"message\": \"Booking cancelled successfully\"}");

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
