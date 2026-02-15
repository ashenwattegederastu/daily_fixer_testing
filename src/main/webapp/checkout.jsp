<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.dailyfixer.model.CartItem" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.model.User" %>

<% 
    // Check if user is logged in
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        // Store the intended destination for redirect after login
        String redirectUrl = request.getRequestURL().toString();
        if (request.getQueryString() != null) {
            redirectUrl += "?" + request.getQueryString();
        }
        session.setAttribute("redirectAfterLogin", redirectUrl);
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // First check if itemsToCheckout already exists in session (from previous page load)
Map<Integer, CartItem> itemsToCheckout = (Map<Integer, CartItem>) session.getAttribute("itemsToCheckout");

// If not in session, build from cart or Buy Now parameters
if (itemsToCheckout == null || itemsToCheckout.isEmpty()) {
    itemsToCheckout = new HashMap<>();
    
    // Get cart from session
    Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");

    if (cart != null && !cart.isEmpty()) {
        itemsToCheckout.putAll(cart);
    } else {
        String productIdParam = request.getParameter("productId");
        String quantityParam = request.getParameter("quantity");
        String variantIdParam = request.getParameter("variantId");

    if (productIdParam != null && quantityParam != null && !productIdParam.isEmpty()) {
        int productId = Integer.parseInt(productIdParam);
        int quantity = Integer.parseInt(quantityParam);
        Integer variantId = null;
        if (variantIdParam != null && !variantIdParam.isBlank()) {
            variantId = Integer.parseInt(variantIdParam);
        }

        ProductDAO dao = new ProductDAO();
        Product product = dao.getProductById(productId);
        if (product != null) {
            double price = product.getPrice();
            double originalPrice = product.getPrice();
            String variantColor = null;
            String variantSize = null;
            String variantPower = null;

            // If variant is selected, use variant price
            if (variantId != null) {
                try {
                    ProductVariantDAO variantDAO = new ProductVariantDAO();
                    ProductVariant variant = variantDAO.getVariantById(variantId);
                    if (variant != null && variant.getProductId() == productId) {
                        price = variant.getPrice().doubleValue();
                        originalPrice = price;
                        variantColor = variant.getColor();
                        variantSize = variant.getSize();
                        variantPower = variant.getPower();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            // Check for active discount
            double discountAmount = 0;
            String discountName = null;
            String discountType = null;
            double discountedPrice = price;

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
                e.printStackTrace();
            }

            CartItem item = new CartItem(
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
            int cartKey = variantId != null ? variantId : productId;
            itemsToCheckout.put(cartKey, item);
        }
    }
    }
}

// If no items, show message and return
if (itemsToCheckout == null || itemsToCheckout.isEmpty()) {
    String error = request.getParameter("error");
    String errorMessage = "";
    if ("empty_cart".equals(error)) {
        errorMessage = "Your cart is empty. Please add products to cart first.";
    } else if ("missing_fields".equals(error)) {
        errorMessage = "Please fill all required fields.";
    } else if ("database_error".equals(error)) {
        errorMessage = "Database error occurred. Please try again.";
    } else if ("server_error".equals(error)) {
        errorMessage = "Server error occurred. Please try again.";
    } else {
        errorMessage = "No products to checkout.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Checkout - Daily Fixer</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        .error-message { color: #e74c3c; margin: 20px 0; }
        a { color: #3498db; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h2>Checkout Error</h2>
    <p class="error-message"><%= errorMessage %></p>
    <a href="store_main.jsp">Back to Store</a>
</body>
</html>
<% 
    return; 
} 

// Store cart items in session for post-payment order
session.setAttribute("itemsToCheckout", itemsToCheckout); 
double total = 0; // Initialize total for order

// Get form data from session for repopulation (if redirected back with error)
String checkoutName = (String) session.getAttribute("checkout_name");
String checkoutPhone = (String) session.getAttribute("checkout_phone");
String checkoutEmail = (String) session.getAttribute("checkout_email");
String checkoutAddress = (String) session.getAttribute("checkout_address");
String checkoutCity = (String) session.getAttribute("checkout_city");
String checkoutProvince = (String) session.getAttribute("checkout_province");
String checkoutDistrict = (String) session.getAttribute("checkout_district");

// Clear session attributes after retrieving (so they don't persist)
if (checkoutName != null) session.removeAttribute("checkout_name");
if (checkoutPhone != null) session.removeAttribute("checkout_phone");
if (checkoutEmail != null) session.removeAttribute("checkout_email");
if (checkoutAddress != null) session.removeAttribute("checkout_address");
if (checkoutCity != null) session.removeAttribute("checkout_city");
if (checkoutProvince != null) session.removeAttribute("checkout_province");
if (checkoutDistrict != null) session.removeAttribute("checkout_district");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/checkout.css">
    <style>
/* Framework CSS Variables */
:root {
  --background: oklch(0.9940 0 0);
  --foreground: oklch(0 0 0);
  --card: oklch(0.9940 0 0);
  --card-foreground: oklch(0 0 0);
  --popover: oklch(0.9911 0 0);
  --popover-foreground: oklch(0 0 0);
  --primary: oklch(0.5393 0.2713 286.7462);
  --primary-foreground: oklch(1.0000 0 0);
  --secondary: oklch(0.9540 0.0063 255.4755);
  --secondary-foreground: oklch(0.1344 0 0);
  --muted: oklch(0.9702 0 0);
  --muted-foreground: oklch(0.4386 0 0);
  --accent: oklch(0.9393 0.0288 266.3680);
  --accent-foreground: oklch(0.5445 0.1903 259.4848);
  --destructive: oklch(0.6290 0.1902 23.0704);
  --destructive-foreground: oklch(1.0000 0 0);
  --border: oklch(0.9300 0.0094 286.2156);
  --input: oklch(0.9401 0 0);
  --ring: oklch(0 0 0);
  --chart-1: oklch(0.7459 0.1483 156.4499);
  --chart-2: oklch(0.5393 0.2713 286.7462);
  --chart-3: oklch(0.7336 0.1758 50.5517);
  --chart-4: oklch(0.5828 0.1809 259.7276);
  --chart-5: oklch(0.5590 0 0);
  --sidebar: oklch(0.9777 0.0051 247.8763);
  --sidebar-foreground: oklch(0 0 0);
  --sidebar-primary: oklch(0 0 0);
  --sidebar-primary-foreground: oklch(1.0000 0 0);
  --sidebar-accent: oklch(0.9401 0 0);
  --sidebar-accent-foreground: oklch(0 0 0);
  --sidebar-border: oklch(0.9401 0 0);
  --sidebar-ring: oklch(0 0 0);
  --font-sans: 'Plus Jakarta Sans', 'Inter', sans-serif;
  --font-serif: 'Lora', serif;
  --font-mono: 'IBM Plex Mono', monospace;
  --radius: 1.4rem;
  --shadow-x: 0px;
  --shadow-y: 2px;
  --shadow-blur: 3px;
  --shadow-spread: 0px;
  --shadow-opacity: 0.16;
  --shadow-color: hsl(0 0% 0%);
  --shadow-2xs: 0px 2px 3px 0px hsl(0 0% 0% / 0.08);
  --shadow-xs: 0px 2px 3px 0px hsl(0 0% 0% / 0.08);
  --shadow-sm: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 1px 2px -1px hsl(0 0% 0% / 0.16);
  --shadow: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 1px 2px -1px hsl(0 0% 0% / 0.16);
  --shadow-md: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 2px 4px -1px hsl(0 0% 0% / 0.16);
  --shadow-lg: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 4px 6px -1px hsl(0 0% 0% / 0.16);
  --shadow-xl: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 8px 10px -1px hsl(0 0% 0% / 0.16);
  --shadow-2xl: 0px 2px 3px 0px hsl(0 0% 0% / 0.40);
  --tracking-normal: -0.025em;
  --spacing: 0.27rem;
}

.dark {
  --background: oklch(0.2223 0.0060 271.1393);
  --foreground: oklch(0.9551 0 0);
  --card: oklch(0.2568 0.0076 274.6528);
  --card-foreground: oklch(0.9551 0 0);
  --popover: oklch(0.2568 0.0076 274.6528);
  --popover-foreground: oklch(0.9551 0 0);
  --primary: oklch(0.6132 0.2294 291.7437);
  --primary-foreground: oklch(1.0000 0 0);
  --secondary: oklch(0.2940 0.0130 272.9312);
  --secondary-foreground: oklch(0.9551 0 0);
  --muted: oklch(0.2940 0.0130 272.9312);
  --muted-foreground: oklch(0.7058 0 0);
  --accent: oklch(0.2795 0.0368 260.0310);
  --accent-foreground: oklch(0.7857 0.1153 246.6596);
  --destructive: oklch(0.7106 0.1661 22.2162);
  --destructive-foreground: oklch(1.0000 0 0);
  --border: oklch(0.3289 0.0092 268.3843);
  --input: oklch(0.3289 0.0092 268.3843);
  --ring: oklch(0.6132 0.2294 291.7437);
  --chart-1: oklch(0.8003 0.1821 151.7110);
  --chart-2: oklch(0.6132 0.2294 291.7437);
  --chart-3: oklch(0.8077 0.1035 19.5706);
  --chart-4: oklch(0.6691 0.1569 260.1063);
  --chart-5: oklch(0.7058 0 0);
  --sidebar: oklch(0.2011 0.0039 286.0396);
  --sidebar-foreground: oklch(0.9551 0 0);
  --sidebar-primary: oklch(0.6132 0.2294 291.7437);
  --sidebar-primary-foreground: oklch(1.0000 0 0);
  --sidebar-accent: oklch(0.2940 0.0130 272.9312);
  --sidebar-accent-foreground: oklch(0.6132 0.2294 291.7437);
  --sidebar-border: oklch(0.3289 0.0092 268.3843);
  --sidebar-ring: oklch(0.6132 0.2294 291.7437);
}

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);
  --color-popover: var(--popover);
  --color-popover-foreground: var(--popover-foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-secondary: var(--secondary);
  --color-secondary-foreground: var(--secondary-foreground);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-destructive: var(--destructive);
  --color-destructive-foreground: var(--destructive-foreground);
  --color-border: var(--border);
  --color-input: var(--input);
  --color-ring: var(--ring);
  --color-chart-1: var(--chart-1);
  --color-chart-2: var(--chart-2);
  --color-chart-3: var(--chart-3);
  --color-chart-4: var(--chart-4);
  --color-chart-5: var(--chart-5);
  --color-sidebar: var(--sidebar);
  --color-sidebar-foreground: var(--sidebar-foreground);
  --color-sidebar-primary: var(--sidebar-primary);
  --color-sidebar-primary-foreground: var(--sidebar-primary-foreground);
  --color-sidebar-accent: var(--sidebar-accent);
  --color-sidebar-accent-foreground: var(--sidebar-accent-foreground);
  --color-sidebar-border: var(--sidebar-border);
  --color-sidebar-ring: var(--sidebar-ring);

  --font-sans: var(--font-sans);
  --font-mono: var(--font-mono);
  --font-serif: var(--font-serif);

  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);

  --shadow-2xs: var(--shadow-2xs);
  --shadow-xs: var(--shadow-xs);
  --shadow-sm: var(--shadow-sm);
  --shadow: var(--shadow);
  --shadow-md: var(--shadow-md);
  --shadow-lg: var(--shadow-lg);
  --shadow-xl: var(--shadow-xl);
  --shadow-2xl: var(--shadow-2xl);

  --tracking-tighter: calc(var(--tracking-normal) - 0.05em);
  --tracking-tight: calc(var(--tracking-normal) - 0.025em);
  --tracking-normal: var(--tracking-normal);
  --tracking-wide: calc(var(--tracking-normal) + 0.025em);
  --tracking-wider: calc(var(--tracking-normal) + 0.05em);
  --tracking-widest: calc(var(--tracking-normal) + 0.1em);
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--font-sans);
  background-color: var(--background);
  color: var(--foreground);
  letter-spacing: var(--tracking-normal);
  transition: background-color 0.3s ease, color 0.3s ease;
  min-height: 100vh;
}

/* Dark Mode Toggle Button */
.theme-toggle {
  padding: 0.5rem 1rem;
  background: var(--secondary);
  border: 1px solid var(--border);
  color: var(--secondary-foreground);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 500;
  font-size: 0.85rem;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  margin-right: 10px;
}

.theme-toggle:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

/* Public Navigation Styles */
nav.public-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  background-color: rgba(255, 255, 255, 0.1);
  border-bottom: 1px solid rgba(139, 125, 216, 0.2);
  transition: all 0.3s ease;
}

.dark nav.public-nav {
  background-color: rgba(34, 35, 48, 0.1);
  border-bottom: 1px solid rgba(139, 125, 216, 0.2);
}

nav.public-nav.scrolled {
  background-color: rgba(255, 255, 255, 0.15);
  box-shadow: var(--shadow-md);
}

.dark nav.public-nav.scrolled {
  background-color: rgba(34, 35, 48, 0.15);
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

nav.public-nav .logo {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary);
  text-decoration: none;
}

.nav-links {
  display: flex;
  gap: 2rem;
  list-style: none;
  align-items: center;
}

.nav-links a {
  text-decoration: none;
  color: var(--foreground);
  font-size: 0.95rem;
  font-weight: 500;
  transition: color 0.3s ease;
  position: relative;
}

.nav-links a:hover {
  color: var(--primary);
}

.nav-links a::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 0;
  width: 0;
  height: 2px;
  background: var(--primary);
  transition: width 0.3s ease;
}

.nav-links a:hover::after {
  width: 100%;
}

.nav-buttons {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.btn-login, .btn-logout {
  padding: 0.6rem 1.2rem;
  background: transparent;
  border: 1.5px solid var(--primary);
  color: var(--primary);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  font-size: 0.9rem;
  text-decoration: none;
  display: inline-block;
}

.btn-login:hover, .btn-logout:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

.btn-signup {
  padding: 0.6rem 1.2rem;
  background: var(--primary);
  border: none;
  color: var(--primary-foreground);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  font-size: 0.9rem;
  box-shadow: var(--shadow-sm);
  text-decoration: none;
  display: inline-block;
}

.btn-signup:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  opacity: 0.9;
}

/* Responsive */
@media (max-width: 768px) {
  .nav-links {
    gap: 1rem;
    font-size: 0.85rem;
  }

  .nav-container {
    padding: 1rem;
  }
}
    </style>
</head>

<body>

    <nav class="public-nav">
        <div class="nav-container">
            <a href="<%=request.getContextPath()%>/index.jsp" class="logo">Daily Fixer</a>
            <ul class="nav-links">
                <li><a href="diagnostic.jsp">Diagnostic Tool</a></li>
                <li><a href="listguides.jsp">Repair Guides</a></li>
                <li><a href="findtech.jsp">Technicians</a></li>
                <li><a href="store_main.jsp">Store</a></li>
            </ul>
            <div class="nav-buttons">
                <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
                <% if (currentUser != null) { %>
                    <form action="<%=request.getContextPath()%>/logout" method="post" style="margin: 0; display: inline;">
                        <button type="submit" class="btn-logout">Logout</button>
                    </form>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- Entire form wraps shipping + order summary -->
    <form method="post" action="redirectToPayment">

        <div class="checkout-container">
            <!-- Left: Shipping Details -->
            <div class="shipping">
                <h2>Shipping Details</h2>
                <% String error = request.getParameter("error"); 
                   if (error != null) { %>
                    <div style="background-color: #fee; color: #c33; padding: 10px; margin-bottom: 15px; border-radius: 5px; border: 1px solid #fcc;">
                        <% if ("missing_fields".equals(error)) { %>
                            Please fill all required fields.
                        <% } else if ("empty_cart".equals(error)) { %>
                            Your cart is empty. Please add products to cart first.
                        <% } else if ("database_error".equals(error)) { %>
                            Database error occurred. Please try again. If the problem persists, contact support.
                        <% } else if ("server_error".equals(error)) { %>
                            Server error occurred. Please try again.
                        <% } else if ("invalid_email".equals(error)) { %>
                            Please enter a valid email address.
                        <% } else { %>
                            An error occurred. Please try again.
                        <% } %>
                    </div>
                <% } %>
                <label>Name</label>
                <input type="text" name="name" value="<%= checkoutName != null ? checkoutName : "" %>" required>

                <label>Phone</label>
                <input type="text" name="phone" value="<%= checkoutPhone != null ? checkoutPhone : "" %>" required>

                <label>Email</label>
                <input type="email" name="email" value="<%= (String) session.getAttribute("checkout_email") != null ? (String) session.getAttribute("checkout_email") : "" %>" required>

                <!-- Location selection: type address or pick on map -->
                <label>Delivery Location</label>
                <input type="text" id="map-search-input" placeholder="Type your location or select on map">

                <!-- Map where user can click to set location -->
                <div id="checkout-map" style="width: 100%; height: 260px; margin: 10px 0; border-radius: 10px; overflow: hidden;"></div>

                <p style="font-size: 12px; color: #777; margin-top: 4px;">
                    You can <strong>type your address</strong> to search, or <strong>click on the map</strong> to set your exact location.
                </p>

                <!-- Hidden fields to submit coordinates with the order -->
                <input type="hidden" id="latitude" name="latitude">
                <input type="hidden" id="longitude" name="longitude">

                <label>Address</label>
                <input type="text" id="address-input" name="address" value="<%= checkoutAddress != null ? checkoutAddress : "" %>" required>

                <div class="address-row">
                    <div>
                        <label>Province</label>
                        <select name="province" required>
                            <option value="">Select Province</option>
                            <option value="Western" <%= "Western".equals(checkoutProvince) ? "selected" : "" %>>Western</option>
                            <option value="Central" <%= "Central".equals(checkoutProvince) ? "selected" : "" %>>Central</option>
                            <option value="Southern" <%= "Southern".equals(checkoutProvince) ? "selected" : "" %>>Southern</option>
                            <option value="Eastern" <%= "Eastern".equals(checkoutProvince) ? "selected" : "" %>>Eastern</option>
                            <option value="Northern" <%= "Northern".equals(checkoutProvince) ? "selected" : "" %>>Northern</option>
                            <option value="North-Western" <%= "North-Western".equals(checkoutProvince) ? "selected" : "" %>>North-Western</option>
                            <option value="North-Central" <%= "North-Central".equals(checkoutProvince) ? "selected" : "" %>>North-Central</option>
                            <option value="Sabaragamuwa" <%= "Sabaragamuwa".equals(checkoutProvince) ? "selected" : "" %>>Sabaragamuwa</option>
                            <option value="Uva" <%= "Uva".equals(checkoutProvince) ? "selected" : "" %>>Uva</option>
                        </select>
                    </div>
                    <div>
                        <label>District</label>
                        <select name="district" required>
                            <option value="">Select District</option>
                            <option value="Colombo" <%= "Colombo".equals(checkoutDistrict) ? "selected" : "" %>>Colombo</option>
                            <option value="Gampaha" <%= "Gampaha".equals(checkoutDistrict) ? "selected" : "" %>>Gampaha</option>
                            <option value="Kalutara" <%= "Kalutara".equals(checkoutDistrict) ? "selected" : "" %>>Kalutara</option>
                            <option value="Kandy" <%= "Kandy".equals(checkoutDistrict) ? "selected" : "" %>>Kandy</option>
                            <option value="Matale" <%= "Matale".equals(checkoutDistrict) ? "selected" : "" %>>Matale</option>
                            <option value="Nuwara Eliya" <%= "Nuwara Eliya".equals(checkoutDistrict) ? "selected" : "" %>>Nuwara Eliya</option>
                            <option value="Galle" <%= "Galle".equals(checkoutDistrict) ? "selected" : "" %>>Galle</option>
                            <option value="Matara" <%= "Matara".equals(checkoutDistrict) ? "selected" : "" %>>Matara</option>
                            <option value="Hambantota" <%= "Hambantota".equals(checkoutDistrict) ? "selected" : "" %>>Hambantota</option>
                            <option value="Jaffna" <%= "Jaffna".equals(checkoutDistrict) ? "selected" : "" %>>Jaffna</option>
                            <option value="Kilinochchi" <%= "Kilinochchi".equals(checkoutDistrict) ? "selected" : "" %>>Kilinochchi</option>
                            <option value="Mannar" <%= "Mannar".equals(checkoutDistrict) ? "selected" : "" %>>Mannar</option>
                            <option value="Mullaitivu" <%= "Mullaitivu".equals(checkoutDistrict) ? "selected" : "" %>>Mullaitivu</option>
                            <option value="Vavuniya" <%= "Vavuniya".equals(checkoutDistrict) ? "selected" : "" %>>Vavuniya</option>
                            <option value="Trincomalee" <%= "Trincomalee".equals(checkoutDistrict) ? "selected" : "" %>>Trincomalee</option>
                            <option value="Batticaloa" <%= "Batticaloa".equals(checkoutDistrict) ? "selected" : "" %>>Batticaloa</option>
                            <option value="Ampara" <%= "Ampara".equals(checkoutDistrict) ? "selected" : "" %>>Ampara</option>
                            <option value="Kurunegala" <%= "Kurunegala".equals(checkoutDistrict) ? "selected" : "" %>>Kurunegala</option>
                            <option value="Puttalam" <%= "Puttalam".equals(checkoutDistrict) ? "selected" : "" %>>Puttalam</option>
                            <option value="Anuradhapura" <%= "Anuradhapura".equals(checkoutDistrict) ? "selected" : "" %>>Anuradhapura</option>
                            <option value="Polonnaruwa" <%= "Polonnaruwa".equals(checkoutDistrict) ? "selected" : "" %>>Polonnaruwa</option>
                            <option value="Badulla" <%= "Badulla".equals(checkoutDistrict) ? "selected" : "" %>>Badulla</option>
                            <option value="Monaragala" <%= "Monaragala".equals(checkoutDistrict) ? "selected" : "" %>>Monaragala</option>
                            <option value="Ratnapura" <%= "Ratnapura".equals(checkoutDistrict) ? "selected" : "" %>>Ratnapura</option>
                            <option value="Kegalle" <%= "Kegalle".equals(checkoutDistrict) ? "selected" : "" %>>Kegalle</option>
                        </select>
                    </div>
                    <div>
                        <label>City</label>
                        <input type="text" name="city" value="<%= checkoutCity != null ? checkoutCity : "" %>" required>
                    </div>
                </div>
            </div>

            <!-- Right: Order Summary -->
            <div class="order-summary">
                <h2>Order Summary</h2>

                <% 
                double totalDiscount = 0; 
                for (CartItem item : itemsToCheckout.values()) { 
                    double itemSubtotal = item.getQuantity() * item.getPrice(); 
                    double itemOriginalSubtotal = item.getQuantity() * item.getOriginalPrice(); 
                    if (item.getDiscountAmount() > 0) {
                        totalDiscount += item.getTotalDiscount();
                    }
                    total += itemOriginalSubtotal;
                %>
                    <div class="checkout-item">
                        <img src="data:image/jpeg;base64,<%=item.getImageBase64()%>" alt="<%=item.getName()%>" width="100">
                        <div class="item-details">
                            <p><strong><%=item.getName()%></strong></p>
                            <% if (item.getVariantId() != null) { %>
                                <p style="font-size: 0.9em; color: #666;">
                                    <% if (item.getVariantColor() != null && !item.getVariantColor().isEmpty()) { %>
                                        Color: <%=item.getVariantColor()%>
                                    <% } %>
                                    <% if (item.getVariantSize() != null && !item.getVariantSize().isEmpty()) { %>
                                        <% if (item.getVariantColor() != null && !item.getVariantColor().isEmpty()) { %> | <% } %>
                                        Size: <%=item.getVariantSize()%>
                                    <% } %>
                                    <% if (item.getVariantPower() != null && !item.getVariantPower().isEmpty()) { %>
                                        <% if ((item.getVariantColor() != null && !item.getVariantColor().isEmpty()) || 
                                              (item.getVariantSize() != null && !item.getVariantSize().isEmpty())) { %> | <% } %>
                                        Power: <%=item.getVariantPower()%>
                                    <% } %>
                                </p>
                            <% } %>
                            <p>Qty: <%=item.getQuantity()%></p>
                            <p>
                                <% if (item.getOriginalPrice() > item.getPrice() && item.getDiscountAmount() > 0) { %>
                                    <span style="text-decoration: line-through; color: #999; margin-right: 10px;">
                                        Price: Rs <%=String.format("%.2f", item.getOriginalPrice())%>
                                    </span>
                                    <span style="color: #4caf50; font-weight: 600;">
                                        Price: Rs <%=String.format("%.2f", item.getPrice())%>
                                    </span>
                                <% } else { %>
                                    Price: Rs <%=String.format("%.2f", item.getPrice())%>
                                <% } %>
                            </p>
                            <p>
                                Subtotal: Rs <%=String.format("%.2f", itemSubtotal)%>
                                <% if (item.getDiscountAmount() > 0) { %>
                                    <br><span style="color: #4caf50; font-size: 0.9em;">
                                        Discount: -Rs <%=String.format("%.2f", item.getTotalDiscount())%>
                                        <% if (item.getDiscountName() != null) { %>
                                            (<%=item.getDiscountName()%>)
                                        <% } %>
                                    </span>
                                <% } %>
                            </p>
                        </div>
                    </div>
                <% } %>

                <div class="totals">
                    <div>Subtotal <span>Rs <%=String.format("%.2f", total)%></span></div>
                    <div style="<%= totalDiscount > 0 ? "color: #4caf50;" : "" %>">
                        Discount
                        <span style="<%= totalDiscount > 0 ? "color: #4caf50;" : "" %>">
                            <% if (totalDiscount > 0) { %>-<% } %>Rs <%=String.format("%.2f", totalDiscount)%>
                        </span>
                    </div>
                    <div>Shipping <span>Rs 0.00</span></div>
                    <div class="total">Total <span>Rs <%=String.format("%.2f", total - totalDiscount)%></span></div>
                </div>

                <!-- Place Order button -->
                <button type="submit" class="place-order">Place Order</button>
            </div>
        </div>
    </form>

    <!-- Google Maps for checkout location selection -->
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyA8zSes6UGbYKIHNzCp3tny5RgccFruILI&libraries=places&callback=initCheckoutMap" async defer></script>

    <script>
        let checkoutMap;
        let checkoutMarker;
        let checkoutGeocoder;
        let checkoutAutocomplete;
        let selectedLat = null;
        let selectedLng = null;

        function initCheckoutMap() {
            const mapDiv = document.getElementById('checkout-map');
            if (!mapDiv) return;

            const sriLanka = { lat: 7.8731, lng: 80.7718 };

            checkoutMap = new google.maps.Map(mapDiv, {
                center: sriLanka,
                zoom: 8,
                mapTypeControl: false,
                streetViewControl: false,
                fullscreenControl: true
            });

            checkoutGeocoder = new google.maps.Geocoder();

            checkoutMarker = new google.maps.Marker({
                map: checkoutMap,
                draggable: true,
                visible: false,
                animation: google.maps.Animation.DROP
            });

            checkoutMap.addListener('click', (e) => {
                setCheckoutLocation(e.latLng.lat(), e.latLng.lng());
                reverseGeocodeCheckout(e.latLng);
            });

            checkoutMarker.addListener('dragend', (e) => {
                setCheckoutLocation(e.latLng.lat(), e.latLng.lng());
                reverseGeocodeCheckout(e.latLng);
            });

            const searchInput = document.getElementById('map-search-input');
            if (searchInput) {
                checkoutAutocomplete = new google.maps.places.Autocomplete(searchInput, {
                    componentRestrictions: { country: 'lk' },
                    fields: ['geometry', 'formatted_address', 'name']
                });

                checkoutAutocomplete.addListener('place_changed', () => {
                    const place = checkoutAutocomplete.getPlace();
                    if (place.geometry && place.geometry.location) {
                        const lat = place.geometry.location.lat();
                        const lng = place.geometry.location.lng();
                        setCheckoutLocation(lat, lng);
                        checkoutMap.setCenter(place.geometry.location);
                        checkoutMap.setZoom(15);

                        const addressInput = document.getElementById('address-input');
                        if (addressInput) {
                            addressInput.value = place.formatted_address || place.name || addressInput.value;
                        }
                    } else {
                        alert('Please select a valid location from the suggestions.');
                    }
                });
            }
        }

        function setCheckoutLocation(lat, lng) {
            selectedLat = lat;
            selectedLng = lng;

            const latInput = document.getElementById('latitude');
            const lngInput = document.getElementById('longitude');
            if (latInput) latInput.value = lat;
            if (lngInput) lngInput.value = lng;

            const pos = new google.maps.LatLng(lat, lng);
            checkoutMarker.setPosition(pos);
            checkoutMarker.setVisible(true);
        }

        function reverseGeocodeCheckout(latLng) {
            if (!checkoutGeocoder) return;
            checkoutGeocoder.geocode({ location: latLng }, (results, status) => {
                if (status === 'OK' && results[0]) {
                    const addressInput = document.getElementById('address-input');
                    if (addressInput) {
                        addressInput.value = results[0].formatted_address;
                    }
                }
            });
        }
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
</body>

</html>
