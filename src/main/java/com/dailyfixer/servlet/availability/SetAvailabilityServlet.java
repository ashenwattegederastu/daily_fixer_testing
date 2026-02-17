package com.dailyfixer.servlet.availability;

import com.dailyfixer.dao.TechnicianAvailabilityDAO;
import com.dailyfixer.model.TechnicianAvailability;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Time;

@WebServlet("/SetAvailabilityServlet")
public class SetAvailabilityServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null || !"technician".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            String availabilityMode = request.getParameter("availabilityMode");
            String startTimeStr = request.getParameter("startTime");
            String endTimeStr = request.getParameter("endTime");

            TechnicianAvailability availability = new TechnicianAvailability();
            availability.setTechnicianId(user.getUserId());
            availability.setAvailabilityMode(availabilityMode);
            availability.setStartTime(Time.valueOf(startTimeStr + ":00"));
            availability.setEndTime(Time.valueOf(endTimeStr + ":00"));

            if ("CUSTOM".equals(availabilityMode)) {
                availability.setMonday(request.getParameter("monday") != null);
                availability.setTuesday(request.getParameter("tuesday") != null);
                availability.setWednesday(request.getParameter("wednesday") != null);
                availability.setThursday(request.getParameter("thursday") != null);
                availability.setFriday(request.getParameter("friday") != null);
                availability.setSaturday(request.getParameter("saturday") != null);
                availability.setSunday(request.getParameter("sunday") != null);
            } else if ("WEEKDAYS".equals(availabilityMode)) {
                availability.setMonday(true);
                availability.setTuesday(true);
                availability.setWednesday(true);
                availability.setThursday(true);
                availability.setFriday(true);
                availability.setSaturday(false);
                availability.setSunday(false);
            } else if ("WEEKENDS".equals(availabilityMode)) {
                availability.setMonday(false);
                availability.setTuesday(false);
                availability.setWednesday(false);
                availability.setThursday(false);
                availability.setFriday(false);
                availability.setSaturday(true);
                availability.setSunday(true);
            }

            TechnicianAvailabilityDAO availabilityDAO = new TechnicianAvailabilityDAO();
            availabilityDAO.setAvailability(availability);

            request.getSession().setAttribute("successMessage", "Availability settings updated successfully!");
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/techniciandash/setAvailability.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Failed to update availability: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/techniciandash/setAvailability.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
