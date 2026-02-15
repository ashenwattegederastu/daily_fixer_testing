<%@ page import="java.util.Map" %>
<%@ page import="com.dailyfixer.model.CartItem" %>

<head>
    <style>
        .floating-cart {
            position: fixed;
            top: 20px;
            right: 30px;
            z-index: 1100;
        }

        .floating-cart img {
            width: 35px;
            height: 35px;
            transition: transform 0.3s ease;
        }

        .floating-cart img:hover {
            transform: scale(1.1);
        }

        .cart-count {
            position: absolute;
            top: -6px;
            right: -10px;
            background-color: #ffd166;
            color: #333;
            font-size: 13px;
            font-weight: bold;
            padding: 2px 6px;
            border-radius: 50%;
        }
    </style>
</head>

<%
    // Get cart from session
    Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
    if(cart == null){
        cart = new java.util.HashMap<>();
        session.setAttribute("cart", cart);
    }

    int count = 0;
    for(CartItem ci : cart.values()) count += ci.getQuantity();
%>

<div class="floating-cart">
    <!-- Use context path to fix links -->
    <a href="<%= request.getContextPath() %>/Cart.jsp">
        <img src="<%= request.getContextPath() %>/assets/images/icons/shopping-cart.png" alt="Cart">
        <span class="cart-count"><%= count %></span>
    </a>
</div>
