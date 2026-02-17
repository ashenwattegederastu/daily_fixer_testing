package com.dailyfixer.servlet.chat;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.ChatDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.ChatConversation;
import com.dailyfixer.model.ChatMessage;
import com.dailyfixer.model.User;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/GetMessagesServlet")
public class GetMessagesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
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

            ChatDAO chatDAO = new ChatDAO();
            ChatConversation conversation = chatDAO.getConversationByBookingId(bookingId);
            
            List<ChatMessage> messages = new ArrayList<>();
            if (conversation != null) {
                messages = chatDAO.getMessagesByConversationId(conversation.getConversationId());
                chatDAO.markMessagesAsRead(conversation.getConversationId(), user.getUserId());
            }

            Gson gson = new Gson();
            String json = gson.toJson(messages);
            out.write("{\"success\": true, \"messages\": " + json + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
