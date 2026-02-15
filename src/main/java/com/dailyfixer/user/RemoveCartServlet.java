package com.dailyfixer.user;

import com.dailyfixer.model.CartItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

@WebServlet("/removeFromCart")
public class RemoveCartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            String productIdStr = request.getParameter("productId");
            String variantIdStr = request.getParameter("variantId");
            String cartKeyStr = request.getParameter("cartKey");

            if (productIdStr == null || productIdStr.isEmpty()) {
                out.print("{\"error\":\"Missing productId\"}");
                return;
            }

            int productId = Integer.parseInt(productIdStr);

            HttpSession session = request.getSession();
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");

            if (cart == null || cart.isEmpty()) {
                out.print("{\"cartCount\":0}");
                return;
            }

            // Determine the cart key: use cartKey parameter if provided, otherwise use variantId if exists, else productId
            Integer cartKey;
            if (cartKeyStr != null && !cartKeyStr.isBlank()) {
                cartKey = Integer.parseInt(cartKeyStr);
            } else if (variantIdStr != null && !variantIdStr.isBlank()) {
                cartKey = Integer.parseInt(variantIdStr);
            } else {
                cartKey = productId;
            }

            if (cart.containsKey(cartKey)) {
                cart.remove(cartKey);
            }

            session.setAttribute("cart", cart);

            // Calculate updated cart count
            // Calculate updated cart count
            int cartCount = 0;
            if (cart != null) {
                for (CartItem ci : cart.values()) {
                     if (ci != null) {
                        cartCount += ci.getQuantity();
                     }
                }
            }

            out.print("{\"cartCount\":" + cartCount + "}");
        } catch (Exception e) {
            e.printStackTrace();
            String errorMessage = e.getMessage();
            if (errorMessage == null) {
                errorMessage = "Error: " + e.getClass().getSimpleName();
            }
            out.print("{\"error\":\"" + errorMessage.replace("\"", "\\\"") + "\"}");
        }
    }
}

