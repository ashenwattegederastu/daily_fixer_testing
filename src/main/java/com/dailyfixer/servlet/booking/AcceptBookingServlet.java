package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.ChatDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.ChatConversation;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/AcceptBookingServlet")
public class AcceptBookingServlet extends HttpServlet {

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
            
            if (booking.getStatus() != Booking.BookingStatus.REQUESTED) {
                out.write("{\"success\": false, \"message\": \"Booking cannot be accepted\"}");
                return;
            }

            bookingDAO.updateBookingStatus(bookingId, Booking.BookingStatus.ACCEPTED);

            ChatDAO chatDAO = new ChatDAO();
            ChatConversation existingConv = chatDAO.getConversationByBookingId(bookingId);
            if (existingConv == null) {
                ChatConversation conversation = new ChatConversation();
                conversation.setBookingId(bookingId);
                conversation.setUserId(booking.getUserId());
                conversation.setTechnicianId(booking.getTechnicianId());
                chatDAO.createConversation(conversation);
            }

            out.write("{\"success\": true, \"message\": \"Booking accepted successfully\"}");

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
