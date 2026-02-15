package com.dailyfixer.service;

import com.dailyfixer.dao.ServiceDAO;
import com.dailyfixer.model.Service;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;

@WebServlet("/AddServiceServlet")
@MultipartConfig(maxFileSize = 16177215) // 16 MB
public class AddServiceServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");

            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect("login.jsp");
                return;
            }

            // Get parameters with null checks
            String serviceName = request.getParameter("serviceName");
            String category = request.getParameter("category");
            String pricingType = request.getParameter("pricingType");
            String fixedRateStr = request.getParameter("fixedRate");
            String hourlyRateStr = request.getParameter("hourlyRate");
            String inspectionChargeStr = request.getParameter("inspectionCharge");
            String transportChargeStr = request.getParameter("transportCharge");
            String availableDates = request.getParameter("availableDates");

            if (serviceName == null || serviceName.trim().isEmpty() ||
                    category == null || category.trim().isEmpty() ||
                    pricingType == null || pricingType.trim().isEmpty()) {
                throw new ServletException("Service Name, Category, and Pricing Type are required.");
            }

            Service s = new Service();
            s.setTechnicianId(currentUser.getUserId());
            s.setServiceName(serviceName.trim());
            s.setCategory(category.trim());
            s.setPricingType(pricingType.trim().toLowerCase());
            s.setAvailableDates(availableDates != null ? availableDates.trim() : "");

            // Convert numbers safely
            s.setFixedRate((fixedRateStr == null || fixedRateStr.isEmpty()) ? 0 : Double.parseDouble(fixedRateStr));
            s.setHourlyRate((hourlyRateStr == null || hourlyRateStr.isEmpty()) ? 0 : Double.parseDouble(hourlyRateStr));
            s.setInspectionCharge((inspectionChargeStr == null || inspectionChargeStr.isEmpty()) ? 0 : Double.parseDouble(inspectionChargeStr));
            s.setTransportCharge((transportChargeStr == null || transportChargeStr.isEmpty()) ? 0 : Double.parseDouble(transportChargeStr));

            // Handle image upload
            Part imagePart = request.getPart("serviceImage");
            if (imagePart != null && imagePart.getSize() > 0) {
                InputStream is = imagePart.getInputStream();
                byte[] bytes = is.readAllBytes();
                s.setServiceImage(bytes);
                s.setImageType(imagePart.getContentType());
            }

            new ServiceDAO().addService(s);
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/techniciandash/serviceListings.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
