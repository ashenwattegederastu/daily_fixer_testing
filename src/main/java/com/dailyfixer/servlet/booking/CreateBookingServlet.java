package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.ServiceDAO;
import com.dailyfixer.dao.TechnicianAvailabilityDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.Service;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;

@WebServlet("/CreateBookingServlet")
public class CreateBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            String bookingDateStr = request.getParameter("bookingDate");
            String bookingTimeStr = request.getParameter("bookingTime");
            String phoneNumber = request.getParameter("phoneNumber");
            String problemDescription = request.getParameter("problemDescription");
            String locationAddress = request.getParameter("locationAddress");
            String latitudeStr = request.getParameter("latitude");
            String longitudeStr = request.getParameter("longitude");

            ServiceDAO serviceDAO = new ServiceDAO();
            Service service = serviceDAO.getServiceById(serviceId);
            
            if (service == null) {
                request.getSession().setAttribute("errorMessage", "Service not found.");
                response.sendRedirect(request.getContextPath() + "/pages/dashboards/userdash/searchServices.jsp");
                return;
            }

            Date bookingDate = Date.valueOf(bookingDateStr);
            Time bookingTime = Time.valueOf(bookingTimeStr + ":00");

            TechnicianAvailabilityDAO availabilityDAO = new TechnicianAvailabilityDAO();
            boolean isAvailable = availabilityDAO.isAvailable(service.getTechnicianId(), bookingDate, bookingTime);

            if (!isAvailable) {
                request.getSession().setAttribute("errorMessage", 
                    "Technician is not available at the selected date and time. Please choose another slot.");
                response.sendRedirect(request.getContextPath() + "/pages/dashboards/userdash/bookService.jsp?serviceId=" + serviceId);
                return;
            }

            Booking booking = new Booking();
            booking.setUserId(user.getUserId());
            booking.setTechnicianId(service.getTechnicianId());
            booking.setServiceId(serviceId);
            booking.setBookingDate(bookingDate);
            booking.setBookingTime(bookingTime);
            booking.setPhoneNumber(phoneNumber);
            booking.setProblemDescription(problemDescription);
            booking.setLocationAddress(locationAddress);
            
            if (latitudeStr != null && !latitudeStr.isEmpty()) {
                booking.setLocationLatitude(new BigDecimal(latitudeStr));
            }
            if (longitudeStr != null && !longitudeStr.isEmpty()) {
                booking.setLocationLongitude(new BigDecimal(longitudeStr));
            }
            
            booking.setStatus(Booking.BookingStatus.REQUESTED);

            BookingDAO bookingDAO = new BookingDAO();
            int bookingId = bookingDAO.createBooking(booking);

            if (bookingId > 0) {
                request.getSession().setAttribute("successMessage", 
                    "Booking request submitted successfully! The technician will review your request.");
                response.sendRedirect(request.getContextPath() + "/pages/dashboards/userdash/myBookings.jsp");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to create booking. Please try again.");
                response.sendRedirect(request.getContextPath() + "/pages/dashboards/userdash/bookService.jsp?serviceId=" + serviceId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Failed to create booking. Please try again or contact support.");
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/userdash/bookService.jsp?serviceId=" + request.getParameter("serviceId"));
        }
    }
}
