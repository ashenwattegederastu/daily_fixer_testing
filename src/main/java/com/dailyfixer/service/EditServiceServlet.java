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

@WebServlet("/EditServiceServlet")
@MultipartConfig(maxFileSize = 16177215)
public class EditServiceServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            User currentUser = (User) request.getSession().getAttribute("currentUser");
            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            int serviceId = Integer.parseInt(request.getParameter("id"));
            Service s = new ServiceDAO().getServiceById(serviceId);
            if (s == null) {
                response.getWriter().println("Service not found!");
                return;
            }

            request.setAttribute("service", s);
            request.getRequestDispatcher("/pages/dashboards/techniciandash/editService.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            Service s = new ServiceDAO().getServiceById(serviceId);
            if (s == null) {
                response.getWriter().println("Service not found!");
                return;
            }

            s.setServiceName(request.getParameter("serviceName"));
            s.setCategory(request.getParameter("category"));
            s.setPricingType(request.getParameter("pricingType"));
            s.setFixedRate(request.getParameter("fixedRate") == null || request.getParameter("fixedRate").isEmpty() ? 0 : Double.parseDouble(request.getParameter("fixedRate")));
            s.setHourlyRate(request.getParameter("hourlyRate") == null || request.getParameter("hourlyRate").isEmpty() ? 0 : Double.parseDouble(request.getParameter("hourlyRate")));
            s.setInspectionCharge(Double.parseDouble(request.getParameter("inspectionCharge")));
            s.setTransportCharge(Double.parseDouble(request.getParameter("transportCharge")));
            s.setAvailableDates(request.getParameter("availableDates"));

            Part imagePart = request.getPart("serviceImage");
            if (imagePart != null && imagePart.getSize() > 0) {
                InputStream is = imagePart.getInputStream();
                s.setServiceImage(is.readAllBytes());
                s.setImageType(imagePart.getContentType());
            }

            new ServiceDAO().updateService(s);
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/techniciandash/serviceListings.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
