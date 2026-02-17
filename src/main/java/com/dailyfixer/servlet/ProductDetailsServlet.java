package com.dailyfixer.servlet;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;
import com.dailyfixer.model.Discount;
import com.dailyfixer.dto.ProductDetailsData;
import com.dailyfixer.dto.ProductDetailsData.VariantData;
import com.dailyfixer.dto.ProductDetailsData.DiscountData;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.*;

/**
 * Servlet to prepare product details data for the product_details.jsp page.
 * Handles all backend logic including discount calculations, variant processing, and stock checks.
 */
@WebServlet("/productDetails")
public class ProductDetailsServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String productIdParam = request.getParameter("productId");
        
        if (productIdParam == null || productIdParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Product ID is required");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdParam);
            ProductDetailsData productData = prepareProductDetails(productId);
            
            if (productData == null || productData.getProduct() == null) {
                request.setAttribute("errorMessage", "Product not found");
                request.getRequestDispatcher("/product_details.jsp").forward(request, response);
                return;
            }
            
            // Set all data as request attributes
            request.setAttribute("productData", productData);
            request.getRequestDispatcher("/product_details.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading product details");
        }
    }
    
    /**
     * Prepares all product details data including variants, discounts, and pricing.
     */
    private ProductDetailsData prepareProductDetails(int productId) throws Exception {
        ProductDAO productDAO = new ProductDAO();
        Product product = productDAO.getProductById(productId);
        
        if (product == null) {
            return null;
        }
        
        ProductDetailsData data = new ProductDetailsData();
        data.setProduct(product);
        
        // Load variants
        ProductVariantDAO variantDAO = new ProductVariantDAO();
        List<ProductVariant> variants = variantDAO.getVariantsByProductId(productId);
        boolean hasVariants = variants != null && !variants.isEmpty();
        data.setHasVariants(hasVariants);
        
        // Process variants and calculate pricing
        if (hasVariants) {
            processVariants(data, product, variants);
        } else {
            processSimpleProduct(data, product);
        }
        
        return data;
    }
    
    /**
     * Process product with variants
     */
    private void processVariants(ProductDetailsData data, Product product, 
                                 List<ProductVariant> variants) throws Exception {
        DiscountDAO discountDAO = new DiscountDAO();
        List<VariantData> variantDataList = new ArrayList<>();
        
        Set<String> colors = new HashSet<>();
        Set<String> sizes = new HashSet<>();
        Set<String> powers = new HashSet<>();
        
        boolean allOutOfStock = true;
        
        for (ProductVariant variant : variants) {
            // Collect unique option values
            if (variant.getColor() != null && !variant.getColor().trim().isEmpty()) {
                colors.add(variant.getColor());
            }
            if (variant.getSize() != null && !variant.getSize().trim().isEmpty()) {
                sizes.add(variant.getSize());
            }
            if (variant.getPower() != null && !variant.getPower().trim().isEmpty()) {
                powers.add(variant.getPower());
            }
            
            // Check stock
            if (variant.getQuantity() > 0) {
                allOutOfStock = false;
            }
            
            // Process variant pricing
            VariantData vData = new VariantData();
            vData.setId(variant.getVariantId());
            vData.setColor(variant.getColor() != null ? variant.getColor() : "");
            vData.setSize(variant.getSize() != null ? variant.getSize() : "");
            vData.setPower(variant.getPower() != null ? variant.getPower() : "");
            vData.setQuantity(variant.getQuantity());
            
            double variantPrice = variant.getPrice().doubleValue();
            vData.setPrice(variantPrice);
            
            // Calculate discount for variant
            Discount variantDiscount = discountDAO.getActiveDiscountForVariant(variant.getVariantId());
            Discount productDiscount = null;
            
            if (variantDiscount == null || !variantDiscount.isValid()) {
                productDiscount = discountDAO.getActiveDiscountForProduct(product.getProductId());
            }
            
            Discount activeDiscount = (variantDiscount != null && variantDiscount.isValid()) 
                ? variantDiscount 
                : ((productDiscount != null && productDiscount.isValid()) ? productDiscount : null);
            
            if (activeDiscount != null && activeDiscount.isValid()) {
                double discountedPrice = activeDiscount.calculateDiscountedPrice(variantPrice);
                vData.setDisplayPrice(discountedPrice);
                vData.setDiscount(new DiscountData(activeDiscount));
            } else {
                vData.setDisplayPrice(variantPrice);
                vData.setDiscount(null);
            }
            
            variantDataList.add(vData);
        }
        
        data.setVariants(variantDataList);
        data.setColors(colors);
        data.setSizes(sizes);
        data.setPowers(powers);
        data.setOutOfStock(allOutOfStock);
        
        // Set base product pricing (for initial display)
        double basePrice = product.getPrice();
        data.setOriginalPrice(basePrice);
        
        DiscountDAO discountDAO = new DiscountDAO();
        Discount baseDiscount = discountDAO.getActiveDiscountForProduct(product.getProductId());
        
        if (baseDiscount != null && baseDiscount.isValid()) {
            data.setDisplayPrice(baseDiscount.calculateDiscountedPrice(basePrice));
            data.setActiveDiscount(baseDiscount);
        } else {
            data.setDisplayPrice(basePrice);
            data.setActiveDiscount(null);
        }
    }
    
    /**
     * Process simple product without variants
     */
    private void processSimpleProduct(ProductDetailsData data, Product product) throws Exception {
        double basePrice = product.getPrice();
        data.setOriginalPrice(basePrice);
        data.setOutOfStock(product.getQuantity() <= 0);
        
        DiscountDAO discountDAO = new DiscountDAO();
        Discount discount = discountDAO.getActiveDiscountForProduct(product.getProductId());
        
        if (discount != null && discount.isValid()) {
            data.setDisplayPrice(discount.calculateDiscountedPrice(basePrice));
            data.setActiveDiscount(discount);
        } else {
            data.setDisplayPrice(basePrice);
            data.setActiveDiscount(null);
        }
        
        // Set empty collections
        data.setColors(new HashSet<>());
        data.setSizes(new HashSet<>());
        data.setPowers(new HashSet<>());
        data.setVariants(new ArrayList<>());
    }
}
