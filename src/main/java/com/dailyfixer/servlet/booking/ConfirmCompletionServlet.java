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

@WebServlet("/ConfirmCompletionServlet")
public class ConfirmCompletionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
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
            
            if (booking.getUserId() != user.getUserId()) {
                out.write("{\"success\": false, \"message\": \"Unauthorized\"}");
                return;
            }
            
            if (booking.getStatus() != Booking.BookingStatus.TECHNICIAN_COMPLETED) {
                out.write("{\"success\": false, \"message\": \"Technician must complete the work first\"}");
                return;
            }

            bookingDAO.updateBookingStatus(bookingId, Booking.BookingStatus.FULLY_COMPLETED);

            out.write("{\"success\": true, \"message\": \"Booking confirmed as completed. Thank you!\"}");

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
