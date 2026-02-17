package com.dailyfixer.servlet.chat;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.ChatDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.ChatConversation;
import com.dailyfixer.model.ChatMessage;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/SendMessageServlet")
public class SendMessageServlet extends HttpServlet {

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
            String messageText = request.getParameter("message");
            
            if (messageText == null || messageText.trim().isEmpty()) {
                out.write("{\"success\": false, \"message\": \"Message cannot be empty\"}");
                return;
            }

            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null) {
                out.write("{\"success\": false, \"message\": \"Booking not found\"}");
                return;
            }

            boolean isAuthorized = (booking.getUserId() == user.getUserId()) || 
                                   (booking.getTechnicianId() == user.getUserId());
            
            if (!isAuthorized) {
                out.write("{\"success\": false, \"message\": \"Unauthorized\"}");
                return;
            }

            if (booking.getStatus() != Booking.BookingStatus.ACCEPTED && 
                booking.getStatus() != Booking.BookingStatus.TECHNICIAN_COMPLETED) {
                out.write("{\"success\": false, \"message\": \"Chat is only available for accepted bookings\"}");
                return;
            }

            ChatDAO chatDAO = new ChatDAO();
            ChatConversation conversation = chatDAO.getConversationByBookingId(bookingId);
            
            if (conversation == null) {
                conversation = new ChatConversation();
                conversation.setBookingId(bookingId);
                conversation.setUserId(booking.getUserId());
                conversation.setTechnicianId(booking.getTechnicianId());
                int convId = chatDAO.createConversation(conversation);
                conversation.setConversationId(convId);
            }

            ChatMessage message = new ChatMessage();
            message.setConversationId(conversation.getConversationId());
            message.setSenderId(user.getUserId());
            message.setMessageText(messageText);

            int messageId = chatDAO.sendMessage(message);

            if (messageId > 0) {
                out.write("{\"success\": true, \"messageId\": " + messageId + "}");
            } else {
                out.write("{\"success\": false, \"message\": \"Failed to send message\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
