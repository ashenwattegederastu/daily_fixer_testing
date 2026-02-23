<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>

<%!
    // Helper method to convert color name to hex code
    private String getColorCode(String colorName) {
        if (colorName == null) return "#cccccc";
        String color = colorName.toLowerCase().trim();
        switch (color) {
            case "red": return "#ff0000";
            case "blue": return "#0000ff";
            case "green": return "#00ff00";
            case "yellow": return "#ffff00";
            case "black": return "#000000";
            case "white": return "#ffffff";
            case "gray": case "grey": return "#808080";
            case "orange": return "#ffa500";
            case "purple": return "#800080";
            case "pink": return "#ffc0cb";
            case "brown": return "#a52a2a";
            case "navy": return "#000080";
            case "teal": return "#008080";
            case "cyan": return "#00ffff";
            case "magenta": return "#ff00ff";
            case "lime": return "#00ff00";
            case "maroon": return "#800000";
            case "olive": return "#808000";
            case "silver": return "#c0c0c0";
            case "gold": return "#ffd700";
            default: 
                // Try to parse as hex color if it starts with #
                if (color.startsWith("#") && color.length() == 7) {
                    return color;
                }
                // Default gray for unknown colors
                return "#cccccc";
        }
    }
%>

<%
    // Check if user is logged in
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
    
    String productIdParam = request.getParameter("productId");
    Product product = null;
    List<ProductVariant> variants = null;
    boolean hasVariants = false;

    if (productIdParam != null && !productIdParam.isEmpty()) {
        int productId = Integer.parseInt(productIdParam);
        ProductDAO dao = new ProductDAO();
        product = dao.getProductById(productId);
        
        if (product != null) {
            ProductVariantDAO variantDAO = new ProductVariantDAO();
            try {
                variants = variantDAO.getVariantsByProductId(productId);
                hasVariants = variants != null && !variants.isEmpty();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    if (product == null) {
%>
<p>Product not found</p>
<a href="store_main.jsp">Back</a>
<%
        return;
    }

    boolean outOfStock = product.getQuantity() <= 0;
    if (hasVariants) {
        // Check if all variants are out of stock
        boolean allOutOfStock = true;
        for (ProductVariant v : variants) {
            if (v.getQuantity() > 0) {
                allOutOfStock = false;
                break;
            }
        }
        outOfStock = allOutOfStock;
    }
    
    // Extract unique option values for dropdowns
    Set<String> colors = new HashSet<>();
    Set<String> sizes = new HashSet<>();
    Set<String> powers = new HashSet<>();
    if (hasVariants) {
        for (ProductVariant v : variants) {
            if (v.getColor() != null && !v.getColor().trim().isEmpty()) {
                colors.add(v.getColor());
            }
            if (v.getSize() != null && !v.getSize().trim().isEmpty()) {
                sizes.add(v.getSize());
            }
            if (v.getPower() != null && !v.getPower().trim().isEmpty()) {
                powers.add(v.getPower());
            }
        }
    }
%>



<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title><%= product.getName() %></title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/product_details.css">
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
        .variant-btn {
            padding: 10px 16px;
            border: 2px solid #ddd;
            border-radius: 8px;
            background-color: white;
            color: #333;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            min-width: 60px;
        }
        
        .variant-btn:hover {
            border-color: #8b95ff;
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(139, 149, 255, 0.2);
        }
        
        .variant-btn.active {
            border: 2px solid #8b95ff !important;
            background-color: #f0f0ff !important;
            color: #8b95ff !important;
            font-weight: 600 !important;
        }
        
        /* Force default styles for non-active buttons */
        button.variant-btn:not(.active) {
            border: 2px solid #ddd !important;
            background-color: white !important;
            color: #333 !important;
            font-weight: 500 !important;
        }
        
        .color-btn .color-indicator {
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
        }
        
        .color-btn.active .color-indicator {
            box-shadow: 0 0 0 2px #8b95ff, 0 1px 3px rgba(0,0,0,0.3);
        }
        
        .price-container {
            margin-bottom: 15px;
        }
        
        .price-details {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 8px;
        }
        
        .original-price {
            text-decoration: line-through;
            color: #999;
            font-size: 1.2em;
        }
        
        .discount-badge {
            background: linear-gradient(135deg, #ff4d4f, #ff7875);
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: 600;
        }
    </style>
</head>
<body>

<!-- Floating Cart -->
<jsp:include page="fragment_cart.jsp"/>

<!-- Navbar -->
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
            <% if (isLoggedIn) { %>
                <form action="<%=request.getContextPath()%>/logout" method="post" style="margin: 0; display: inline;">
                    <button type="submit" class="btn-logout">Logout</button>
                </form>
            <% } else { %>
                <a href="<%=request.getContextPath()%>/login.jsp" class="btn-login">Login</a>
                <a href="<%=request.getContextPath()%>/registerUser.jsp" class="btn-signup">Sign Up</a>
            <% } %>
        </div>
    </div>
</nav>

<!-- Product Container -->
<div class="product-container">

    <!-- Left Image Section -->
    <div class="image-section">
        <div class="main-image">
            <img src="data:image/jpeg;base64,<%=product.getImageBase64()%>"
                 alt="<%=product.getName()%>">
        </div>
    </div>

    <!-- Right Details Section -->
    <div class="details-section">

        <p id="stockStatus" class="stock" style="color:<%= outOfStock ? "red" : "green" %>;">
            <%= outOfStock ? "Out of Stock" : "In Stock: " + (hasVariants ? "" : product.getQuantity()) %>
        </p>

        <h1 class="title"><%= product.getName() %></h1>
        <%
            // Check for active discount
            Discount activeDiscount = null;
            double displayPrice = product.getPrice().doubleValue();
            double originalPrice = product.getPrice().doubleValue();
            double discountAmount = 0;
            
            // For products with variants, if main price is 0.00, use first variant's price
            if (hasVariants && variants != null && !variants.isEmpty() && product.getPrice().doubleValue() == 0.00) {
                ProductVariant firstVariant = variants.get(0);
                if (firstVariant != null && firstVariant.getPrice() != null) {
                    originalPrice = firstVariant.getPrice().doubleValue();
                    displayPrice = originalPrice;
                    
                    // Check for discount on the first variant
                    try {
                        DiscountDAO discountDAO = new DiscountDAO();
                        activeDiscount = discountDAO.getActiveDiscountForVariant(firstVariant.getVariantId());
                        if (activeDiscount != null && activeDiscount.isValid()) {
                            displayPrice = activeDiscount.calculateDiscountedPrice(originalPrice);
                            discountAmount = originalPrice - displayPrice;
                        } else {
                            // Also check for product-level discount
                            activeDiscount = discountDAO.getActiveDiscountForProduct(product.getProductId());
                            if (activeDiscount != null && activeDiscount.isValid()) {
                                displayPrice = activeDiscount.calculateDiscountedPrice(originalPrice);
                                discountAmount = originalPrice - displayPrice;
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            } else {
                // For products without variants or with non-zero main price
                try {
                    DiscountDAO discountDAO = new DiscountDAO();
                    activeDiscount = discountDAO.getActiveDiscountForProduct(product.getProductId());
                    if (activeDiscount != null && activeDiscount.isValid()) {
                        originalPrice = product.getPrice().doubleValue();
                        displayPrice = activeDiscount.calculateDiscountedPrice(originalPrice);
                        discountAmount = originalPrice - displayPrice;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        %>
        <div class="price-container">
            <h2 class="price">
                Rs <span id="priceValue"><%= String.format("%.2f", displayPrice) %></span>
            </h2>
            <div class="price-details" id="priceDetails" style="<%= (activeDiscount != null && activeDiscount.isValid()) ? "" : "display: none;" %>">
                <span class="original-price" id="originalPrice">Rs <%= String.format("%.2f", originalPrice) %></span>
                <span class="discount-badge" id="discountBadge">
                    <% if (activeDiscount != null && activeDiscount.isValid()) { %>
                        <% if ("PERCENTAGE".equalsIgnoreCase(activeDiscount.getDiscountType())) { %>
                            <%= activeDiscount.getDiscountValue() %>% OFF
                        <% } else { %>
                            Rs <%= activeDiscount.getDiscountValue() %> OFF
                        <% } %>
                    <% } %>
                </span>
            </div>
        </div>

        <!-- Variant Selection -->
        <% if (hasVariants) { %>
        <div class="variant-selection" style="margin: 20px 0;">
            <% if (!colors.isEmpty()) { %>
            <div class="variant-option" style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 10px; font-weight: 600; font-size: 0.95em;">Color:</label>
                <div class="variant-buttons" id="colorButtons" style="display: flex; flex-wrap: wrap; gap: 10px;">
                    <% for (String color : colors) { %>
                    <button type="button" 
                            class="variant-btn color-btn" 
                            data-value="<%= color %>"
                            data-option="color"
                            style="position: relative; min-width: 80px;">
                        <span class="color-indicator" style="display: inline-block; width: 20px; height: 20px; border-radius: 50%; margin-right: 6px; vertical-align: middle; border: 1px solid #ccc; background-color: <%= getColorCode(color) %>;"></span>
                        <span><%= color %></span>
                    </button>
                    <% } %>
                </div>
            </div>
            <% } %>
            
            <% if (!sizes.isEmpty()) { %>
            <div class="variant-option" style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 10px; font-weight: 600; font-size: 0.95em;">Size:</label>
                <div class="variant-buttons" id="sizeButtons" style="display: flex; flex-wrap: wrap; gap: 10px;">
                    <% for (String size : sizes) { %>
                    <button type="button" 
                            class="variant-btn size-btn" 
                            data-value="<%= size %>"
                            data-option="size"
                            style="min-width: 60px;">
                        <%= size %>
                    </button>
                    <% } %>
                </div>
            </div>
            <% } %>
            
            <% if (!powers.isEmpty()) { %>
            <div class="variant-option" style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 10px; font-weight: 600; font-size: 0.95em;">Power:</label>
                <div class="variant-buttons" id="powerButtons" style="display: flex; flex-wrap: wrap; gap: 10px;">
                    <% for (String power : powers) { %>
                    <button type="button" 
                            class="variant-btn power-btn" 
                            data-value="<%= power %>"
                            data-option="power"
                            style="min-width: 80px;">
                        <%= power %>
                    </button>
                    <% } %>
                </div>
            </div>
            <% } %>
            
            <input type="hidden" id="selectedVariantId" value="">
            <input type="hidden" id="selectedColor" value="">
            <input type="hidden" id="selectedSize" value="">
            <input type="hidden" id="selectedPower" value="">
        </div>
        <% } %>

        <!-- Quantity + Buttons -->
        <div class="quantity-control">

            <button class="qty-btn" id="minusBtn" <%= outOfStock ? "disabled" : "" %>>-</button>

            <input type="number"
                   id="qty"
                   class="qty"
                   value="1"
                   min="1"
                   max="<%=hasVariants ? "" : product.getQuantity()%>"
                <%= outOfStock ? "disabled" : "" %>>

            <button class="qty-btn" id="plusBtn" <%= outOfStock ? "disabled" : "" %>>+</button>
        </div>

        <div class="buttons">
            <% if (!isLoggedIn) { 
                // Build redirect URL for login
                String currentPageUrl = request.getRequestURI();
                if (request.getQueryString() != null && !request.getQueryString().isEmpty()) {
                    currentPageUrl += "?" + request.getQueryString();
                }
                String loginUrl = request.getContextPath() + "/login.jsp?redirect=" + java.net.URLEncoder.encode(currentPageUrl, "UTF-8");
            %>
                <div style="background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 15px; margin-bottom: 15px; text-align: center;">
                    <p style="color: #856404; margin: 0; font-weight: 500;">
                        Please <a href="<%= loginUrl %>" style="color: #8b7dd8; text-decoration: underline; font-weight: 600;">login</a> to purchase products or write reviews
                    </p>
                </div>
            <% } %>
            <button class="add-to-cart"
                    id="addBtn"
                    data-product-id="<%=product.getProductId()%>"
                    <%= (outOfStock || !isLoggedIn) ? "disabled" : "" %>>
                Add to Cart
            </button>

            <button class="buy-now"
                    id="buyNowBtn"
                    data-product-id="<%=product.getProductId()%>"
                    <%= (outOfStock || !isLoggedIn) ? "disabled" : "" %>>
                Buy Now
            </button>

        </div>

        <!-- Description -->
        <div class="product-description">
            <h3>Product Description</h3>
            <p><%= product.getDescription() %></p>
        </div>

    </div>
</div>

<!-- Reviews Section - Full Width -->
<div class="reviews-section-container" style="max-width: 1100px; margin: 40px auto; padding: 0 40px; width: 100%; box-sizing: border-box;">
    <div class="reviews-section" style="padding-top: 30px; border-top: 2px solid #e0e0e0; width: 100%;">
        <h3 style="margin-bottom: 20px; text-align: left;">Customer Reviews</h3>
        
        <!-- Average Rating Display -->
        <div id="ratingSummary" style="margin-bottom: 30px; padding: 20px; background-color: #f8f9fa; border-radius: 10px; width: 100%; box-sizing: border-box;">
            <div style="display: flex; align-items: center; gap: 15px;">
                <div style="font-size: 3em; font-weight: bold; color: #8b7dd8;" id="avgRatingDisplay">0.0</div>
                <div>
                    <div id="avgStarsDisplay" style="font-size: 1.5em; color: #fbbf24; margin-bottom: 5px; font-family: Arial, sans-serif;">☆☆☆☆☆</div>
                    <div style="color: #666;" id="reviewCountDisplay">0 reviews</div>
                </div>
            </div>
        </div>

        <!-- Add Review Form (only for logged-in users) -->
        <% if (isLoggedIn) { %>
        <div class="add-review-section" style="margin-bottom: 40px; padding: 25px; background-color: #fff; border: 1px solid #e0e0e0; border-radius: 10px; width: 100%; box-sizing: border-box;">
                <h4 style="margin-bottom: 15px;">Write a Review</h4>
                <form id="reviewForm">
                    <input type="hidden" name="productId" value="<%=product.getProductId()%>">
                    
                    <div style="margin-bottom: 20px;">
                        <label style="display: block; margin-bottom: 10px; font-weight: 600;">Your Rating (Click on stars to rate)</label>
                        <div class="star-rating-input" style="display: flex; align-items: center; gap: 10px;">
                            <div class="stars" id="ratingStars" style="font-size: 2em; cursor: pointer; user-select: none; font-family: Arial, sans-serif;">
                                <span class="star" data-rating="1" style="color: #d1d5db;">☆</span>
                                <span class="star" data-rating="2" style="color: #d1d5db;">☆</span>
                                <span class="star" data-rating="3" style="color: #d1d5db;">☆</span>
                                <span class="star" data-rating="4" style="color: #d1d5db;">☆</span>
                                <span class="star" data-rating="5" style="color: #d1d5db;">☆</span>
                            </div>
                            <input type="hidden" id="ratingValue" name="rating" value="" required>
                            <span id="ratingText" style="color: #666; font-weight: 600;">Click stars to rate</span>
                        </div>
                    </div>

                    <div style="margin-bottom: 20px;">
                        <label for="reviewComment" style="display: block; margin-bottom: 10px; font-weight: 600;">Your Review</label>
                        <textarea id="reviewComment" name="comment" rows="4" 
                                  style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-family: inherit; font-size: 0.95em;"
                                  placeholder="Share your experience with this product..." required></textarea>
                    </div>

                    <button type="submit" style="padding: 12px 30px; background: linear-gradient(135deg, #8b7dd8, #7ba3d4); color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 1em;">
                        Submit Review
                    </button>
                    <div id="reviewMessage" style="margin-top: 10px;"></div>
                </form>
            </div>
        <% } else { %>
        <!-- Login message removed - shown above with purchase message -->
        <% } %>

        <!-- Reviews List -->
        <div id="reviewsList" style="margin-top: 30px; width: 100%;">
            <h4 style="margin-bottom: 20px; text-align: left;">All Reviews</h4>
            <div id="reviewsContainer" style="width: 100%;">
                <!-- Reviews will be loaded here via JavaScript -->
                <p style="color: #999; text-align: center; padding: 20px;">Loading reviews...</p>
            </div>
        </div>
        </div>
    </div>
</div>

    <script>
    const contextPath = "<%=request.getContextPath()%>";
    const hasVariants = <%= hasVariants %>;
    const baseStock = <%= product.getQuantity() %>;
    const basePrice = <%= originalPrice %>;
    const baseDisplayPrice = <%= displayPrice %>;

    // Variant data from server
    const variants = [
        <% if (hasVariants) {
               DiscountDAO discountDAO = new DiscountDAO();
               for (int i = 0; i < variants.size(); i++) {
                   ProductVariant v = variants.get(i);
                   Discount variantDiscount = null;
                   Discount productDiscount = null;
                   try {
                       variantDiscount = discountDAO.getActiveDiscountForVariant(v.getVariantId());
                       if (variantDiscount == null || !variantDiscount.isValid()) {
                           productDiscount = discountDAO.getActiveDiscountForProduct(product.getProductId());
                       }
                   } catch (Exception e) {
                       e.printStackTrace();
                   }
                   Discount variantActiveDiscount = (variantDiscount != null && variantDiscount.isValid()) ? variantDiscount : 
                                           ((productDiscount != null && productDiscount.isValid()) ? productDiscount : null);
                   double variantPrice = v.getPrice().doubleValue();
                   double variantDisplayPrice = variantPrice;
                   if (variantActiveDiscount != null && variantActiveDiscount.isValid()) {
                       variantDisplayPrice = variantActiveDiscount.calculateDiscountedPrice(variantPrice);
                   }
        %>{
            id: <%= v.getVariantId() %>,
            color: "<%= v.getColor() != null ? v.getColor() : "" %>",
            size: "<%= v.getSize() != null ? v.getSize() : "" %>",
            power: "<%= v.getPower() != null ? v.getPower() : "" %>",
            price: <%= variantPrice %>,
            displayPrice: <%= variantDisplayPrice %>,
            quantity: <%= v.getQuantity() %>,
            discount: <% if (variantActiveDiscount != null && variantActiveDiscount.isValid()) { 
                String discountName = variantActiveDiscount.getDiscountName() != null ? variantActiveDiscount.getDiscountName() : "";
                discountName = discountName.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
            %>{
                name: "<%= discountName %>",
                type: "<%= variantActiveDiscount.getDiscountType() != null ? variantActiveDiscount.getDiscountType() : "" %>",
                value: <%= variantActiveDiscount.getDiscountValue() != null ? variantActiveDiscount.getDiscountValue() : 0 %>,
                isValid: true
            }<% } else { %>null<% } %>
        }<%= (i < variants.size() - 1) ? "," : "" %>
        <%   }
           } %>
    ];

    const btn = document.getElementById("addBtn");
    const qty = document.getElementById("qty");
    const minusBtn = document.getElementById("minusBtn");
    const plusBtn = document.getElementById("plusBtn");
    const priceValueEl = document.getElementById("priceValue");
    const stockStatusEl = document.getElementById("stockStatus");
    const selectedVariantIdEl = document.getElementById("selectedVariantId");
    const selectedColorEl = document.getElementById("selectedColor");
    const selectedSizeEl = document.getElementById("selectedSize");
    const selectedPowerEl = document.getElementById("selectedPower");
    const priceDetailsEl = document.getElementById("priceDetails");
    const originalPriceEl = document.getElementById("originalPrice");
    const discountBadgeEl = document.getElementById("discountBadge");

    let currentStock = baseStock;
    let currentPrice = baseDisplayPrice;
    let currentOriginalPrice = basePrice;

    // Function to get selected values from hidden inputs
    function getSelectedValues() {
        return {
            color: selectedColorEl ? selectedColorEl.value : "",
            size: selectedSizeEl ? selectedSizeEl.value : "",
            power: selectedPowerEl ? selectedPowerEl.value : ""
        };
    }

    // Function to find matching variant
    function findMatchingVariant() {
        if (!hasVariants) return null;

        const selected = getSelectedValues();
        const selectedColor = selected.color;
        const selectedSize = selected.size;
        const selectedPower = selected.power;

        // Find variant that matches all selected options
        for (const variant of variants) {
            const colorMatch = !selectedColor || variant.color === selectedColor || variant.color === "";
            const sizeMatch = !selectedSize || variant.size === selectedSize || variant.size === "";
            const powerMatch = !selectedPower || variant.power === selectedPower || variant.power === "";

            // Check if this variant matches the selected combination
            if (colorMatch && sizeMatch && powerMatch) {
                // Verify exact match for non-empty selections
                if ((!selectedColor || variant.color === selectedColor) &&
                    (!selectedSize || variant.size === selectedSize) &&
                    (!selectedPower || variant.power === selectedPower)) {
                    return variant;
                }
            }
        }
        return null;
    }

    // Function to update UI based on selected variant
    function updateVariantSelection() {
        if (!hasVariants) {
            currentStock = baseStock;
            currentPrice = basePrice;
            return;
        }

        const variant = findMatchingVariant();

        if (variant) {
            currentOriginalPrice = variant.price;
            currentStock = variant.quantity;
            
            // Check if variant has discount
            if (variant.discount && variant.discount.isValid) {
                currentPrice = variant.displayPrice;
                // Show discount details
                if (priceDetailsEl) priceDetailsEl.style.display = "flex";
                if (originalPriceEl) originalPriceEl.textContent = "Rs " + currentOriginalPrice.toFixed(2);
                if (discountBadgeEl) {
                    if (variant.discount.type === "PERCENTAGE") {
                        discountBadgeEl.textContent = variant.discount.value + "% OFF";
                    } else {
                        discountBadgeEl.textContent = "Rs " + variant.discount.value + " OFF";
                    }
                }
            } else {
                currentPrice = currentOriginalPrice;
                // Hide discount details
                if (priceDetailsEl) priceDetailsEl.style.display = "none";
            }
            
            if (priceValueEl) priceValueEl.textContent = currentPrice.toFixed(2);
            if (selectedVariantIdEl) selectedVariantIdEl.value = variant.id;

            if (currentStock > 0) {
                if (stockStatusEl) {
                    stockStatusEl.textContent = "In Stock: " + currentStock;
                    stockStatusEl.style.color = "green";
                }
                if (btn) btn.disabled = false;
                if (buyNowBtn) buyNowBtn.disabled = false;
                if (minusBtn) minusBtn.disabled = false;
                if (plusBtn) plusBtn.disabled = false;
                if (qty) {
                    qty.disabled = false;
                    qty.max = currentStock;
                    if (parseInt(qty.value) > currentStock) {
                        qty.value = currentStock;
                    }
                }
            } else {
                if (stockStatusEl) {
                    stockStatusEl.textContent = "Out of Stock";
                    stockStatusEl.style.color = "red";
                }
                if (btn) btn.disabled = true;
                if (buyNowBtn) buyNowBtn.disabled = true;
                if (minusBtn) minusBtn.disabled = true;
                if (plusBtn) plusBtn.disabled = true;
                if (qty) qty.disabled = true;
            }
        } else {
            // No matching variant found - check if all options are selected
            const selected = getSelectedValues();
            const hasColor = selected.color;
            const hasSize = selected.size;
            const hasPower = selected.power;
            
            // If at least one option is selected but no match, show message
            if (hasColor || hasSize || hasPower) {
                if (stockStatusEl) {
                    stockStatusEl.textContent = "Please select a valid combination";
                    stockStatusEl.style.color = "orange";
                }
                if (btn) btn.disabled = true;
                if (buyNowBtn) buyNowBtn.disabled = true;
                if (selectedVariantIdEl) selectedVariantIdEl.value = "";
            } else {
                // No options selected yet - show base product info
                currentOriginalPrice = basePrice;
                currentPrice = baseDisplayPrice;
                currentStock = baseStock;
                
                // Check if base product has discount (from initial page load)
                <% if (activeDiscount != null && activeDiscount.isValid()) { %>
                    if (priceDetailsEl) priceDetailsEl.style.display = "flex";
                    if (originalPriceEl) originalPriceEl.textContent = "Rs " + currentOriginalPrice.toFixed(2);
                    if (discountBadgeEl) {
                        <% if ("PERCENTAGE".equalsIgnoreCase(activeDiscount.getDiscountType())) { %>
                            discountBadgeEl.textContent = "<%= activeDiscount.getDiscountValue() %>% OFF";
                        <% } else { %>
                            discountBadgeEl.textContent = "Rs <%= activeDiscount.getDiscountValue() %> OFF";
                        <% } %>
                    }
                <% } else { %>
                    if (priceDetailsEl) priceDetailsEl.style.display = "none";
                <% } %>
                
                if (priceValueEl) priceValueEl.textContent = currentPrice.toFixed(2);
                if (stockStatusEl) {
                    stockStatusEl.textContent = baseStock > 0 ? "In Stock: " + baseStock : "Out of Stock";
                    stockStatusEl.style.color = baseStock > 0 ? "green" : "red";
                }
                if (btn) btn.disabled = baseStock <= 0;
                if (buyNowBtn) buyNowBtn.disabled = baseStock <= 0;
                if (selectedVariantIdEl) selectedVariantIdEl.value = "";
            }
        }
    }

    // Function to handle variant button clicks
    function handleVariantButtonClick(clickedButton, optionType) {
        const value = clickedButton.getAttribute("data-value");
        const hiddenInput = document.getElementById("selected" + optionType.charAt(0).toUpperCase() + optionType.slice(1));
        
        // IMPORTANT: Check if button is already active BEFORE removing classes
        const wasAlreadyActive = clickedButton.classList.contains("active");
        
        // Get all buttons of this type using class selector (more reliable)
        let selector = "";
        if (optionType === "color") {
            selector = "button.color-btn";
        } else if (optionType === "size") {
            selector = "button.size-btn";
        } else if (optionType === "power") {
            selector = "button.power-btn";
        }
        
        const allButtons = document.querySelectorAll(selector);
        
        // First, deselect ALL buttons of this type (visual reset)
        allButtons.forEach(btn => {
            // Remove active class - CSS will handle the styling
            btn.classList.remove("active");
            // Clear any inline styles that might override CSS (except min-width and position which we keep)
            const minWidth = btn.style.minWidth;
            const position = btn.style.position;
            btn.style.cssText = ""; // Clear all inline styles
            if (minWidth) btn.style.minWidth = minWidth; // Restore min-width
            if (position) btn.style.position = position; // Restore position
        });
        
        // Now decide whether to select the clicked button or leave it deselected
        if (!wasAlreadyActive) {
            // Button was NOT selected, so select it now
            clickedButton.classList.add("active");
            if (hiddenInput) hiddenInput.value = value;
        } else {
            // Button WAS already selected, so we deselected it (toggle off)
            // Active class already removed above, just clear the hidden input
            if (hiddenInput) hiddenInput.value = "";
        }
        
        // Update price and stock based on new selection
        updateVariantSelection();
    }

    // Function to attach event listeners to variant buttons
    function attachVariantButtonListeners() {
        // Get all variant buttons
        const colorButtons = document.querySelectorAll("button.color-btn");
        const sizeButtons = document.querySelectorAll("button.size-btn");
        const powerButtons = document.querySelectorAll("button.power-btn");
        
        // Attach listeners to color buttons
        colorButtons.forEach(button => {
            // Remove any existing onclick handler
            button.onclick = null;
            // Add new onclick handler
            button.addEventListener("click", function(e) {
                e.preventDefault();
                e.stopPropagation();
                handleVariantButtonClick(this, "color");
            });
        });
        
        // Attach listeners to size buttons
        sizeButtons.forEach(button => {
            button.onclick = null;
            button.addEventListener("click", function(e) {
                e.preventDefault();
                e.stopPropagation();
                handleVariantButtonClick(this, "size");
            });
        });
        
        // Attach listeners to power buttons
        powerButtons.forEach(button => {
            button.onclick = null;
            button.addEventListener("click", function(e) {
                e.preventDefault();
                e.stopPropagation();
                handleVariantButtonClick(this, "power");
            });
        });
    }

    // Wait for DOM to be fully ready, then attach listeners
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(attachVariantButtonListeners, 100);
        });
    } else {
        setTimeout(attachVariantButtonListeners, 100);
    }

    // Quantity increment/decrement
    if (minusBtn && plusBtn) {
        minusBtn.onclick = () => {
            let v = parseInt(qty.value);
            if (v > 1) qty.value = v - 1;
        };

        plusBtn.onclick = () => {
            let v = parseInt(qty.value);
            const maxStock = hasVariants ? currentStock : baseStock;
            if (v < maxStock) qty.value = v + 1;
        };
    }

    // Add to Cart
    if (btn) {
        btn.addEventListener("click", () => {
            <% if (!isLoggedIn) { %>
                // Store current page path and query to redirect back after login
                const currentPath = window.location.pathname + window.location.search;
                alert("Please login before purchasing products");
                // Pass redirect URL as parameter (relative path)
                const loginUrl = "<%=request.getContextPath()%>/login.jsp?redirect=" + encodeURIComponent(currentPath);
                console.log("Redirecting to login with URL: " + loginUrl);
                window.location.href = loginUrl;
                return;
            <% } %>
            
            const variantId = selectedVariantIdEl ? selectedVariantIdEl.value : "";
            
            if (hasVariants && !variantId) {
                alert("Please select color, size, and power options");
                return;
            }

            if (currentStock <= 0) {
                alert("Product is out of stock");
                return;
            }

            const quantity = parseInt(qty.value);
            if (!quantity || quantity < 1) {
                alert("Invalid quantity");
                return;
            }

            if (quantity > currentStock) {
                alert("Requested quantity exceeds available stock");
                return;
            }

            const params = new URLSearchParams();
            params.append("productId", btn.dataset.productId);
            params.append("quantity", quantity);
            if (variantId) {
                params.append("variantId", variantId);
            }

            fetch(contextPath + "/addToCart", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: params.toString()
            })
                .then(res => res.json())
                .then(data => {
                    if (data.error) {
                        alert(data.error);
                        return;
                    }

                    const cartCount = document.querySelector(".cart-count");
                    if (cartCount) cartCount.innerText = data.cartCount;

                    alert("Product added to cart");
                })
                .catch(() => alert("Server error"));
        });
    }

    // Buy Now Button
    const buyNowBtn = document.getElementById("buyNowBtn");
    const qtyInput = document.getElementById("qty");

    if (buyNowBtn) {
        buyNowBtn.addEventListener("click", () => {
            <% if (!isLoggedIn) { %>
                // Store current page path and query to redirect back after login
                const currentPath = window.location.pathname + window.location.search;
                alert("Please login before purchasing products");
                // Pass redirect URL as parameter (relative path)
                const loginUrl = "<%=request.getContextPath()%>/login.jsp?redirect=" + encodeURIComponent(currentPath);
                console.log("Redirecting to login with URL: " + loginUrl);
                window.location.href = loginUrl;
                return;
            <% } %>
            
            const productId = buyNowBtn.getAttribute("data-product-id");
            const quantity = qtyInput ? parseInt(qtyInput.value) : 1;
            const variantId = selectedVariantIdEl ? selectedVariantIdEl.value : "";

            if (hasVariants && !variantId) {
                alert("Please select color, size, and power options");
                return;
            }

            if (!productId) {
                alert("Product ID missing!");
                return;
            }

            if (!quantity || quantity < 1) {
                alert("Invalid quantity!");
                return;
            }

            if (quantity > currentStock) {
                alert("Requested quantity exceeds available stock");
                return;
            }

            let url = "checkout.jsp?productId=" + productId + "&quantity=" + quantity;
            if (variantId) {
                url += "&variantId=" + variantId;
            }
            window.location.href = url;
        });
    }

    // Auto-select first variant on page load if variants exist
    function autoSelectFirstVariant() {
        if (!hasVariants || variants.length === 0) return;
        
        // Get the first variant
        const firstVariant = variants[0];
        
        // Select the buttons for this variant - use CSS classes only
        if (firstVariant.color && firstVariant.color !== "") {
            const colorBtn = document.querySelector(`.color-btn[data-value="${firstVariant.color}"]`);
            if (colorBtn && selectedColorEl) {
                colorBtn.classList.add("active");
                selectedColorEl.value = firstVariant.color;
            }
        }
        
        if (firstVariant.size && firstVariant.size !== "") {
            const sizeBtn = document.querySelector(`.size-btn[data-value="${firstVariant.size}"]`);
            if (sizeBtn && selectedSizeEl) {
                sizeBtn.classList.add("active");
                selectedSizeEl.value = firstVariant.size;
            }
        }
        
        if (firstVariant.power && firstVariant.power !== "") {
            const powerBtn = document.querySelector(`.power-btn[data-value="${firstVariant.power}"]`);
            if (powerBtn && selectedPowerEl) {
                powerBtn.classList.add("active");
                selectedPowerEl.value = firstVariant.power;
            }
        }
        
        // Update the UI with the first variant's data
        updateVariantSelection();
    }

    // Initialize variant selection on page load
    if (hasVariants) {
        autoSelectFirstVariant();
    } else {
        updateVariantSelection();
    }

    // ========== REVIEW SYSTEM ==========
    (function() {
        try {
            const productId = <%= product.getProductId() %>;
            const contextPath = "<%=request.getContextPath()%>";

            // Star rating input functionality
            const ratingStars = document.querySelectorAll('#ratingStars .star');
            const ratingValue = document.getElementById('ratingValue');
            const ratingText = document.getElementById('ratingText');
            let selectedRating = 0;

            function highlightStars(rating) {
                const filledStar = '\u2605'; // ★ Unicode filled star
                const emptyStar = '\u2606'; // ☆ Unicode empty star
                
                ratingStars.forEach((star, index) => {
                    if (index < rating) {
                        star.textContent = filledStar;
                        star.style.color = '#fbbf24';
                    } else {
                        star.textContent = emptyStar;
                        star.style.color = '#d1d5db';
                    }
                });
            }

            if (ratingStars.length > 0) {
                // Initialize with all empty stars (0 rating)
                highlightStars(0);
                
                ratingStars.forEach((star, index) => {
                    star.addEventListener('mouseenter', () => {
                        highlightStars(index + 1);
                    });

                    star.addEventListener('click', () => {
                        selectedRating = index + 1;
                        if (ratingValue) ratingValue.value = selectedRating;
                        if (ratingText) {
                            ratingText.textContent = selectedRating + ' out of 5 stars';
                        }
                        highlightStars(selectedRating);
                    });
                });

                const ratingStarsContainer = document.getElementById('ratingStars');
                if (ratingStarsContainer) {
                    ratingStarsContainer.addEventListener('mouseleave', () => {
                        highlightStars(selectedRating);
                    });
                }
            }

            function escapeHtml(text) {
                if (!text) return '';
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            }

            function updateRatingSummary(avgRating, reviewCount) {
                try {
                    const avgRatingDisplay = document.getElementById('avgRatingDisplay');
                    const reviewCountDisplay = document.getElementById('reviewCountDisplay');
                    const avgStarsDisplay = document.getElementById('avgStarsDisplay');
                    
                    const rating = parseFloat(avgRating) || 0;
                    const count = parseInt(reviewCount) || 0;
                    
                    if (avgRatingDisplay) {
                        avgRatingDisplay.textContent = rating.toFixed(1);
                    }
                    if (reviewCountDisplay) {
                        reviewCountDisplay.textContent = count + (count === 1 ? ' review' : ' reviews');
                    }
                    
                    if (avgStarsDisplay) {
                        const filledStar = '\u2605'; // ★ Unicode filled star
                        const emptyStar = '\u2606'; // ☆ Unicode empty star
                        const fullStars = Math.floor(rating);
                        const hasHalfStar = (rating % 1) >= 0.5;
                        let starsHtml = '';
                        
                        for (let i = 0; i < 5; i++) {
                            if (i < fullStars) {
                                starsHtml += filledStar;
                            } else if (i === fullStars && hasHalfStar) {
                                starsHtml += filledStar; // Show as full for simplicity
                            } else {
                                starsHtml += emptyStar;
                            }
                        }
                        avgStarsDisplay.textContent = starsHtml;
                        avgStarsDisplay.style.color = '#fbbf24';
                    }
                } catch (err) {
                    console.error('Error updating rating summary:', err);
                }
            }

            function displayReviews(reviews) {
                try {
                    const container = document.getElementById('reviewsContainer');
                    if (!container) {
                        console.error('reviewsContainer not found');
                        return;
                    }
                    
                    if (!reviews || reviews.length === 0) {
                        container.innerHTML = '<p style="color: #999; text-align: center; padding: 20px;">No reviews yet. Be the first to review!</p>';
                        return;
                    }

                    let html = '';
                    reviews.forEach(review => {
                        try {
                            let dateStr = 'Recently';
                            if (review.createdAt) {
                                try {
                                    const date = new Date(review.createdAt);
                                    if (!isNaN(date.getTime())) {
                                        dateStr = date.toLocaleDateString('en-US', {
                                            year: 'numeric',
                                            month: 'long',
                                            day: 'numeric'
                                        });
                                    }
                                } catch (dateErr) {
                                    console.warn('Date parsing error:', dateErr);
                                }
                            }
                            
                            const filledStar = '\u2605'; // ★ Unicode filled star
                            const emptyStar = '\u2606'; // ☆ Unicode empty star
                            let starsHtml = '';
                            const rating = parseInt(review.rating) || 0;
                            for (let i = 0; i < 5; i++) {
                                if (i < rating) {
                                    starsHtml += filledStar;
                                } else {
                                    starsHtml += emptyStar;
                                }
                            }

                            const username = escapeHtml(review.username || 'Anonymous');
                            const comment = escapeHtml(review.comment || '');

                            html += '<div style="padding: 20px; margin-bottom: 20px; background-color: #fff; border: 1px solid #e0e0e0; border-radius: 10px; width: 100%; box-sizing: border-box;">';
                            html += '<div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 10px;">';
                            html += '<div style="flex: 1;">';
                            html += '<strong style="font-size: 1.1em;">' + username + '</strong>';
                            html += '<div style="color: #fbbf24; font-size: 1.2em; margin-top: 5px;">' + starsHtml + '</div>';
                            html += '</div>';
                            html += '<span style="color: #999; font-size: 0.9em; margin-left: 15px;">' + dateStr + '</span>';
                            html += '</div>';
                            html += '<p style="color: #333; line-height: 1.6; margin: 0; text-align: left;">' + comment + '</p>';
                            html += '</div>';
                        } catch (reviewErr) {
                            console.error('Error processing review:', reviewErr, review);
                        }
                    });
                    
                    container.innerHTML = html;
                } catch (err) {
                    console.error('Error in displayReviews:', err);
                    const container = document.getElementById('reviewsContainer');
                    if (container) {
                        container.innerHTML = '<p style="color: #e74c3c; text-align: center; padding: 20px;">Error loading reviews. Please refresh the page.</p>';
                    }
                }
            }

            function loadReviews() {
                try {
                    fetch(contextPath + '/productReview?productId=' + productId)
                        .then(res => {
                            if (!res.ok) {
                                throw new Error('HTTP error! status: ' + res.status);
                            }
                            return res.text();
                        })
                        .then(text => {
                            try {
                                let data;
                                try {
                                    data = JSON.parse(text);
                                } catch (e) {
                                    console.error('Error parsing JSON:', e, 'Response:', text);
                                    throw new Error('Invalid response from server');
                                }
                                
                                if (data.success) {
                                    try {
                                        const avgRating = parseFloat(data.avgRating) || 0;
                                        const reviewCount = parseInt(data.reviewCount) || 0;
                                        updateRatingSummary(avgRating, reviewCount);
                                        displayReviews(data.reviews || []);
                                    } catch (updateErr) {
                                        console.error('Error updating review display:', updateErr);
                                    }
                                } else {
                                    const container = document.getElementById('reviewsContainer');
                                    if (container) {
                                        container.innerHTML = '<p style="color: #999; text-align: center; padding: 20px;">No reviews yet. Be the first to review!</p>';
                                    }
                                }
                            } catch (err) {
                                console.error('Error processing review data:', err);
                                const container = document.getElementById('reviewsContainer');
                                if (container) {
                                    container.innerHTML = '<p style="color: #999; text-align: center; padding: 20px;">Error loading reviews. Please try again.</p>';
                                }
                            }
                        })
                        .catch(err => {
                            console.error('Error loading reviews:', err);
                            const container = document.getElementById('reviewsContainer');
                            if (container) {
                                container.innerHTML = '<p style="color: #999; text-align: center; padding: 20px;">No reviews yet. Be the first to review!</p>';
                            }
                        });
                } catch (err) {
                    console.error('Error in loadReviews:', err);
                }
            }

            // Handle review form submission
            const reviewForm = document.getElementById('reviewForm');
            if (reviewForm) {
                reviewForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    
                    try {
                        const formData = new FormData(reviewForm);
                        const rating = formData.get('rating');
                        
                        // Validate that rating is selected
                        if (!rating || rating === '' || parseInt(rating) < 1 || parseInt(rating) > 5) {
                            const messageDiv = document.getElementById('reviewMessage');
                            if (messageDiv) {
                                messageDiv.innerHTML = '<p style="color: #e74c3c;">Please select a rating (1-5 stars) before submitting.</p>';
                            }
                            return;
                        }
                        
                        const params = new URLSearchParams();
                        params.append('productId', formData.get('productId'));
                        params.append('rating', rating);
                        params.append('comment', formData.get('comment'));

                        const messageDiv = document.getElementById('reviewMessage');
                        if (messageDiv) messageDiv.innerHTML = '<p style="color: #666;">Submitting review...</p>';

                        console.log('Submitting review with params:', params.toString());
                        
                        fetch(contextPath + '/productReview', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: params.toString()
                        })
                        .then(res => {
                            console.log('Response status:', res.status);
                            if (!res.ok) {
                                throw new Error('HTTP error! status: ' + res.status);
                            }
                            return res.text();
                        })
                        .then(text => {
                            console.log('Response text:', text);
                            try {
                                let data;
                                try {
                                    data = JSON.parse(text);
                                } catch (e) {
                                    console.error('Error parsing JSON:', e, 'Response:', text);
                                    throw new Error('Invalid response from server');
                                }
                                
                                if (data.success) {
                                    if (messageDiv) messageDiv.innerHTML = '<p style="color: #4caf50;">✓ Review submitted successfully!</p>';
                                    
                                    // Reset form
                                    try {
                                        reviewForm.reset();
                                        selectedRating = 0;
                                        if (ratingValue) ratingValue.value = '';
                                        if (ratingText) ratingText.textContent = 'Click stars to rate';
                                        highlightStars(0);
                                    } catch (resetErr) {
                                        console.warn('Error resetting form:', resetErr);
                                    }
                                    
                                    // Reload reviews after a short delay
                                    setTimeout(() => {
                                        try {
                                            loadReviews();
                                            if (messageDiv) {
                                                messageDiv.innerHTML = '';
                                            }
                                        } catch (loadErr) {
                                            console.error('Error reloading reviews:', loadErr);
                                            if (messageDiv) {
                                                messageDiv.innerHTML = '<p style="color: #ff9800;">Review saved, but error loading updated reviews. Please refresh the page.</p>';
                                            }
                                        }
                                    }, 1000);
                                } else {
                                    if (messageDiv) {
                                        const errorMsg = data.error || 'Error submitting review';
                                        messageDiv.innerHTML = '<p style="color: #e74c3c;">' + escapeHtml(errorMsg) + '</p>';
                                    }
                                }
                            } catch (parseErr) {
                                console.error('Error processing response:', parseErr);
                                if (messageDiv) {
                                    messageDiv.innerHTML = '<p style="color: #e74c3c;">Error processing server response. Please try again.</p>';
                                }
                            }
                        })
                        .catch(err => {
                            console.error('Error submitting review:', err);
                            if (messageDiv) {
                                messageDiv.innerHTML = '<p style="color: #e74c3c;">Error submitting review: ' + escapeHtml(err.message) + '. Please try again.</p>';
                            }
                        });
                    } catch (err) {
                        console.error('Error in form submission handler:', err);
                        const messageDiv = document.getElementById('reviewMessage');
                        if (messageDiv) {
                            messageDiv.innerHTML = '<p style="color: #e74c3c;">An error occurred. Please try again.</p>';
                        }
                    }
                });
            }

            // Load reviews when page loads
            loadReviews();
        } catch (error) {
            console.error('Error initializing review system:', error);
            // Don't prevent page from loading if review system fails
        }
    })();
</script>

<style>
    .star-rating-input .star {
        transition: all 0.2s;
        display: inline-block;
        font-family: Arial, sans-serif;
        font-size: 1em;
        line-height: 1;
    }
    .star-rating-input .star:hover {
        transform: scale(1.2);
    }
    #avgStarsDisplay {
        font-family: Arial, sans-serif;
        line-height: 1;
        letter-spacing: 2px;
    }
    .reviews-section .star {
        font-family: Arial, sans-serif;
        line-height: 1;
    }
</style>

<script>
    // Navbar scroll effect
    const navbar = document.querySelector('.public-nav');
    if (navbar) {
        window.addEventListener('scroll', function() {
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });
    }
</script>
<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

</body>
</html>
