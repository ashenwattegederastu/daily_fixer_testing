package com.dailyfixer.servlet;

import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * CheckoutServlet - Handles customer form submission from checkout page.
 * Creates an order in the database and redirects to PayHere payment.
 *
 * URL: /checkout
 * Method: POST
 */
@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        System.out.println("CheckoutServlet initialized");
    }

    /**
     * Handle POST request from checkout form.
     * Creates order and redirects to PayHereServlet.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== CheckoutServlet: Processing checkout ===");

        try {
            // Get form parameters
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String city = request.getParameter("city");
            String product = request.getParameter("product");
            String amountStr = request.getParameter("amount");

            // Log received data
            System.out.println("Customer: " + firstName + " " + lastName);
            System.out.println("Email: " + email);
            System.out.println("Product: " + product);
            System.out.println("Amount: " + amountStr);

            // Validate required fields
            if (isEmpty(firstName) || isEmpty(lastName) || isEmpty(email) ||
                    isEmpty(phone) || isEmpty(address) || isEmpty(city) ||
                    isEmpty(product) || isEmpty(amountStr)) {

                System.err.println("Missing required fields");
                response.sendRedirect("checkout.html?error=missing_fields");
                return;
            }

            // Parse amount
            BigDecimal amount;
            try {
                amount = new BigDecimal(amountStr.replace(",", ""));
            } catch (NumberFormatException e) {
                System.err.println("Invalid amount format: " + amountStr);
                response.sendRedirect("checkout.html?error=invalid_amount");
                return;
            }

            // Generate unique order ID (UUID-based, shortened for readability)
            String orderId = generateOrderId();
            System.out.println("Generated Order ID: " + orderId);

            // Create Order object
            Order order = new Order(orderId, firstName, lastName, email,
                    phone, address, city, product, amount);

            // Set buyer_id if user is logged in
            User currentUser = (User) request.getSession().getAttribute("currentUser");
            if (currentUser != null) {
                order.setBuyerId(currentUser.getUserId());
                System.out.println("Order linked to user ID: " + currentUser.getUserId());
            } else {
                System.out.println("Guest checkout - no buyer_id set");
            }

            // Save order to database
            boolean saved = orderDAO.createOrder(order);
            if (!saved) {
                System.err.println("Failed to save order to database");
                response.sendRedirect("checkout.html?error=database_error");
                return;
            }

            System.out.println("Order saved successfully: " + orderId);

            // Store order in session for PayHere servlet
            request.getSession().setAttribute("currentOrder", order);

            // Redirect to PayHere servlet for payment processing
            response.sendRedirect("payhere?order_id=" + orderId);

        } catch (Exception e) {
            System.err.println("Error processing checkout: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("checkout.html?error=server_error");
        }
    }

    /**
     * Generate a unique order ID.
     * Format: DF-XXXXXXXX (8 character hex)
     */
    private String generateOrderId() {
        String uuid = UUID.randomUUID().toString().replace("-", "");
        return "DF-" + uuid.substring(0, 8).toUpperCase();
    }

    /**
     * Check if a string is null or empty.
     */
    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to checkout page
        response.sendRedirect("checkout.html");
    }
}
