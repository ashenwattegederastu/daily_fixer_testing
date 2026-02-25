package com.dailyfixer.servlet.cart;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.model.CartItem;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;
import com.dailyfixer.model.Discount;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/addToCart")
public class CartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        // Check if user is logged in
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            out.print("{\"error\":\"Please login before purchasing products\"}");
            return;
        }

        Map<String, CartItem> cart;
        Object obj = session.getAttribute("cart");

        if (obj instanceof Map<?, ?>) {
            @SuppressWarnings("unchecked")
            Map<String, CartItem> tempCart = (Map<String, CartItem>) obj;
            cart = tempCart;
        } else {
            cart = new HashMap<>();
        }

        try {
            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");
            String variantIdStr = request.getParameter("variantId");

            if (productIdStr == null || quantityStr == null ||
                    productIdStr.isBlank() || quantityStr.isBlank()) {
                out.print("{\"error\":\"Invalid request\"}");
                return;
            }

            int productId = Integer.parseInt(productIdStr);
            int quantity = Integer.parseInt(quantityStr);
            Integer variantId = null;
            if (variantIdStr != null && !variantIdStr.isBlank()) {
                variantId = Integer.parseInt(variantIdStr);
            }

            ProductDAO dao = new ProductDAO();
            Product product = dao.getProductById(productId);

            if (product == null) {
                out.print("{\"error\":\"Product not found\"}");
                return;
            }

            double price = product.getPrice();
            int stock = product.getQuantity();
            String variantColor = null;
            String variantSize = null;
            String variantPower = null;

            // If variant is selected, use variant price and stock
            if (variantId != null) {
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                ProductVariant variant = variantDAO.getVariantById(variantId);
                
                if (variant == null || variant.getProductId() != productId) {
                    out.print("{\"error\":\"Invalid variant\"}");
                    return;
                }

                price = variant.getPrice().doubleValue();
                stock = variant.getQuantity();
                variantColor = variant.getColor();
                variantSize = variant.getSize();
                variantPower = variant.getPower();
            }

            // Stock check
            if (stock <= 0) {
                out.print("{\"error\":\"Product is out of stock\"}");
                return;
            }

            if (quantity > stock) {
                out.print("{\"error\":\"Requested quantity exceeds stock\"}");
                return;
            }

            // Use string key for cart: "V-{variantId}" or "P-{productId}"
            String cartKey = variantId != null ? "V-" + variantId : "P-" + productId;

            // Check for active discount
            double originalPrice = price;
            double discountedPrice = price;
            double discountAmount = 0;
            String discountName = null;
            String discountType = null;
            
            try {
                DiscountDAO discountDAO = new DiscountDAO();
                Discount discount = null;
                
                if (variantId != null) {
                    // First check for variant-specific discount
                    discount = discountDAO.getActiveDiscountForVariant(variantId);
                    // If no variant discount, check for product-level discount
                    if (discount == null || !discount.isValid()) {
                        discount = discountDAO.getActiveDiscountForProduct(productId);
                    }
                } else {
                    discount = discountDAO.getActiveDiscountForProduct(productId);
                }
                
                if (discount != null && discount.isValid()) {
                    originalPrice = price;
                    discountedPrice = discount.calculateDiscountedPrice(price);
                    discountAmount = originalPrice - discountedPrice;
                    discountName = discount.getDiscountName();
                    discountType = discount.getDiscountType();
                }
            } catch (Exception e) {
                // If discount check fails, use original price
                e.printStackTrace();
            }

            CartItem item = cart.get(cartKey);

            if (item == null) {
                item = new CartItem(
                        product.getProductId(),
                        product.getName(),
                        discountedPrice,
                        originalPrice,
                        quantity,
                        product.getImageBase64(),
                        variantId,
                        variantColor,
                        variantSize,
                        variantPower,
                        discountAmount,
                        discountName,
                        discountType
                );
                cart.put(cartKey, item);
            } else {
                int newQty = item.getQuantity() + quantity;
                item.setQuantity(Math.min(newQty, stock));
                // Update discount info if it changed
                if (discountName != null) {
                    item.setOriginalPrice(originalPrice);
                    item.setPrice(discountedPrice);
                    item.setDiscountAmount(discountAmount);
                    item.setDiscountName(discountName);
                    item.setDiscountType(discountType);
                }
            }

            session.setAttribute("cart", cart);

            int cartCount = cart.values()
                    .stream()
                    .mapToInt(CartItem::getQuantity)
                    .sum();

            out.print("{\"cartCount\":" + cartCount + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
}
