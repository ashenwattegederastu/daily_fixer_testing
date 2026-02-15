package com.dailyfixer.user;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.model.Product;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Base64;
import java.util.List;

@WebServlet("/products")
public class CategoryProductServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String category = request.getParameter("category");

        try {
            List<Product> products =
                    new ProductDAO().getProductsByCategory(category);



            request.setAttribute("products", products);
            request.setAttribute("category", category);

            request.getRequestDispatcher("/category_products.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
