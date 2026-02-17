package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.ChatDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.ChatConversation;
import com.dailyfixer.model.User;
import com.google.gson.JsonObject;
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
        JsonObject jsonResponse = new JsonObject();
        
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null || !"technician".equalsIgnoreCase(user.getRole())) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Unauthorized access");
            out.write(jsonResponse.toString());
            return;
        }

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            
            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Booking not found");
                out.write(jsonResponse.toString());
                return;
            }
            
            if (booking.getTechnicianId() != user.getUserId()) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Unauthorized");
                out.write(jsonResponse.toString());
                return;
            }
            
            if (booking.getStatus() != Booking.BookingStatus.REQUESTED) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Booking cannot be accepted");
                out.write(jsonResponse.toString());
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

            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("message", "Booking accepted successfully");
            out.write(jsonResponse.toString());

        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "An error occurred while processing your request");
            out.write(jsonResponse.toString());
        }
    }
}
