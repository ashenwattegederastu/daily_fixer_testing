package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.ServiceCategoryDAO;
import com.dailyfixer.dao.ServiceDAO;
import com.dailyfixer.model.Service;
import com.dailyfixer.model.ServiceCategory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/services")
public class ServiceListingServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            ServiceDAO serviceDAO = new ServiceDAO();
            ServiceCategoryDAO categoryDAO = new ServiceCategoryDAO();
            
            // Get all services
            List<Service> services = serviceDAO.getAllServices();
            
            // Get all categories for filter
            List<ServiceCategory> categories = categoryDAO.getAllCategories();
            
            // Get filter parameters
            String categoryFilter = request.getParameter("category");
            String searchQuery = request.getParameter("search");
            
            // Apply filters
            if (categoryFilter != null && !categoryFilter.isEmpty()) {
                services = services.stream()
                    .filter(s -> categoryFilter.equalsIgnoreCase(s.getCategory()))
                    .toList();
            }
            
            if (searchQuery != null && !searchQuery.isEmpty()) {
                String query = searchQuery.toLowerCase();
                services = services.stream()
                    .filter(s -> s.getServiceName().toLowerCase().contains(query) ||
                               (s.getDescription() != null && s.getDescription().toLowerCase().contains(query)))
                    .toList();
            }
            
            request.setAttribute("services", services);
            request.setAttribute("categories", categories);
            request.setAttribute("selectedCategory", categoryFilter);
            request.setAttribute("searchQuery", searchQuery);
            
            request.getRequestDispatcher("/pages/services/service-listing.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading services: " + e.getMessage());
        }
    }
}
