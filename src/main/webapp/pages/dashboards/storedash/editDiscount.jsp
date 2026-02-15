<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"store".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String discountIdStr = request.getParameter("discountId");
    if (discountIdStr == null || discountIdStr.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/ListDiscountsServlet");
        return;
    }

    String storeUsername = user.getUsername();
    Discount discount = null;
    List<Integer> linkedProductIds = null;
    List<Integer> linkedVariantIds = null;
    List<Product> products = null;
    
    try {
        DiscountDAO discountDAO = new DiscountDAO();
        discount = discountDAO.getDiscountById(Integer.parseInt(discountIdStr));
        
        if (discount == null || !discount.getStoreUsername().equals(storeUsername)) {
            response.sendRedirect(request.getContextPath() + "/ListDiscountsServlet");
            return;
        }
        
        linkedProductIds = discountDAO.getProductIdsForDiscount(discount.getDiscountId());
        linkedVariantIds = discountDAO.getVariantIdsForDiscount(discount.getDiscountId());
        
        ProductDAO productDAO = new ProductDAO();
        products = productDAO.getAllProducts(storeUsername);
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/ListDiscountsServlet");
        return;
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Discount | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>
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
  display: flex;
}

/* Top Navbar */
.topbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 76px;
  background-color: var(--sidebar);
  border-bottom: 1px solid var(--border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 30px;
  z-index: 200;
  box-shadow: var(--shadow-md);
  transition: background-color 0.3s ease, border-color 0.3s ease;
}

.topbar .logo {
  font-size: 1.5em;
  font-weight: 700;
  color: var(--primary);
  text-decoration: none;
}

.topbar .panel-name {
  font-weight: 600;
  flex: 1;
  text-align: center;
  color: var(--foreground);
}

.topbar .logout-btn {
  padding: 0.6rem 1.2rem;
  background: var(--primary);
  border: none;
  color: var(--primary-foreground);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
}

.topbar .logout-btn:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  opacity: 0.9;
}

/* Sidebar */
.sidebar {
  width: 240px;
  background-color: var(--sidebar);
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  padding-top: 96px;
  box-shadow: var(--shadow-md);
  overflow-y: auto;
  z-index: 100;
  border-right: 1px solid var(--sidebar-border);
  transition: background-color 0.3s ease, border-color 0.3s ease;
}

.sidebar h3 {
  padding: 0 20px 12px;
  font-size: 0.85em;
  color: var(--sidebar-foreground);
  text-transform: uppercase;
  font-weight: 600;
}

.sidebar ul {
  list-style: none;
}

.sidebar a {
  display: block;
  padding: 12px 20px;
  text-decoration: none;
  color: var(--sidebar-foreground);
  font-weight: 500;
  border-left: 3px solid transparent;
  border-radius: 0 var(--radius-md) var(--radius-md) 0;
  margin-bottom: 4px;
  transition: all 0.2s;
}

.sidebar a:hover,
.sidebar a.active {
  background-color: var(--sidebar-accent);
  color: var(--sidebar-accent-foreground);
  border-left-color: var(--sidebar-primary);
}

/* Main Content */
.main-content,
.container {
  flex: 1;
  margin-left: 240px;
  margin-top: 83px;
  padding: 30px;
  background-color: var(--background);
  transition: background-color 0.3s ease;
  display: flex;
  justify-content: center;
  align-items: flex-start;
}

body.dashboard-layout {
  display: flex;
  min-height: 100vh;
}

/* Form Styles */
.form-container,
.form-card {
  background-color: var(--card);
  color: var(--card-foreground);
  border-radius: var(--radius-lg);
  padding: 30px;
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--border);
  max-width: 800px;
  margin: 0 auto;
  width: 100%;
}

.form-card h2 {
  color: var(--primary);
  text-align: center;
  margin-bottom: 25px;
  font-size: 1.5em;
}

.form-group {
  margin-bottom: 20px;
}

.form-card label,
.form-group label {
  display: block;
  font-weight: 600;
  color: var(--foreground);
  margin-top: 15px;
  margin-bottom: 5px;
}

.form-card input,
.form-card select,
.form-card textarea,
.form-group input[type="text"],
.form-group input[type="file"],
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 10px 15px;
  border: 2px solid var(--border);
  border-radius: var(--radius-md);
  font-size: 0.9rem;
  background-color: var(--input);
  color: var(--foreground);
  transition: border-color 0.2s, background-color 0.3s ease, color 0.3s ease;
  font-family: var(--font-sans);
  margin-bottom: 5px;
}

.form-card input:focus,
.form-card select:focus,
.form-card textarea:focus,
.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--ring);
}

.form-card button,
.btn-primary {
  background: var(--primary);
  color: var(--primary-foreground);
  width: 100%;
  padding: 12px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  margin-top: 20px;
  font-weight: 600;
  font-size: 1em;
  box-shadow: var(--shadow-sm);
  transition: all 0.3s ease;
}

.form-card button:hover,
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  opacity: 0.9;
}

.back-btn,
.btn-secondary {
  background: var(--secondary);
  color: var(--secondary-foreground);
  padding: 10px 20px;
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  cursor: pointer;
  text-decoration: none;
  display: inline-block;
  margin-top: 15px;
  text-align: center;
  font-weight: 500;
  box-shadow: var(--shadow-sm);
  transition: all 0.3s ease;
  width: 100%;
}

.back-btn:hover,
.btn-secondary:hover {
  background: var(--accent);
  color: var(--accent-foreground);
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.product-selection {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  padding: 10px;
  margin-top: 10px;
  background: var(--muted);
}

.product-checkbox {
  display: flex;
  align-items: center;
  padding: 8px;
  margin-bottom: 5px;
  border-radius: var(--radius-sm);
  transition: background-color 0.2s ease;
}

.product-checkbox:hover {
  background-color: var(--accent);
  color: var(--accent-foreground);
}

.product-checkbox input[type="checkbox"] {
  width: auto;
  margin-right: 10px;
  margin-bottom: 0;
}

.error-message,
.error-msg {
  background-color: var(--destructive);
  color: var(--destructive-foreground);
  padding: 15px;
  border-radius: var(--radius-md);
  margin-bottom: 20px;
  font-size: 0.85em;
  margin-top: 5px;
}

.discount-value-container {
  display: flex;
  gap: 10px;
  align-items: center;
}

.discount-value-container input {
  flex: 1;
}

.discount-value-container span {
  font-weight: 600;
  color: var(--muted-foreground);
}

.checkbox-group {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 10px;
}

.checkbox-group input[type="checkbox"] {
  width: auto;
}
</style>
</head>
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet" class="active">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <div class="form-card">
        <h2>Edit Discount</h2>
        
        <% if (request.getAttribute("error") != null) { %>
        <div class="error-msg"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/EditDiscountServlet" method="post">
            <input type="hidden" name="discountId" value="<%= discount.getDiscountId() %>">

            <label for="discountName">Discount Name *</label>
            <input type="text" name="discountName" value="<%= discount.getDiscountName() %>" placeholder="e.g., Summer Sale, 20% Off" required>

            <label for="discountType">Discount Type *</label>
            <select name="discountType" id="discountType" required onchange="updateDiscountValueLabel()">
                <option value="">-- Select Type --</option>
                <option value="PERCENTAGE" <%= "PERCENTAGE".equals(discount.getDiscountType()) ? "selected" : "" %>>Percentage (%)</option>
                <option value="FIXED" <%= "FIXED".equals(discount.getDiscountType()) ? "selected" : "" %>>Fixed Amount (Rs)</option>
            </select>

            <label for="discountValue">Discount Value *</label>
            <div class="discount-value-container">
                <input type="number" name="discountValue" id="discountValue" step="0.01" min="0" value="<%= discount.getDiscountValue() %>" placeholder="Enter value" required>
                <span id="discountValueLabel"><%= "PERCENTAGE".equals(discount.getDiscountType()) ? "%" : "Rs" %></span>
            </div>

            <label for="startDate">Start Date (Optional)</label>
            <input type="datetime-local" name="startDate" id="startDate" 
                   value="<%= discount.getStartDate() != null ? dateFormat.format(discount.getStartDate()) : "" %>">

            <label for="endDate">End Date (Optional)</label>
            <input type="datetime-local" name="endDate" id="endDate" 
                   value="<%= discount.getEndDate() != null ? dateFormat.format(discount.getEndDate()) : "" %>">

            <div class="checkbox-group">
                <input type="checkbox" name="isActive" id="isActive" value="true" <%= discount.isActive() ? "checked" : "" %>>
                <label for="isActive" style="margin: 0; font-weight: normal; cursor: pointer;">Active</label>
            </div>

            <label>Select Products to Apply Discount *</label>
            <div class="product-selection">
                <% if (products == null || products.isEmpty()) { %>
                    <p style="color: var(--text-secondary); padding: 10px;">No products available.</p>
                <% } else { 
                    ProductVariantDAO variantDAO = new ProductVariantDAO();
                    for (Product product : products) { 
                        boolean isSelected = linkedProductIds != null && linkedProductIds.contains(product.getProductId());
                        String priceDisplay = "";
                        try {
                            List<ProductVariant> variants = variantDAO.getVariantsByProductId(product.getProductId());
                            if (variants != null && !variants.isEmpty() && product.getPrice() == 0.00) {
                                // Calculate price range from variants
                                double minPrice = Double.MAX_VALUE;
                                double maxPrice = 0.0;
                                boolean hasValidPrice = false;
                                
                                for (ProductVariant v : variants) {
                                    if (v.getPrice() != null) {
                                        double vPrice = v.getPrice().doubleValue();
                                        if (vPrice > 0) {
                                            hasValidPrice = true;
                                            if (vPrice < minPrice) minPrice = vPrice;
                                            if (vPrice > maxPrice) maxPrice = vPrice;
                                        }
                                    }
                                }
                                
                                if (hasValidPrice) {
                                    if (minPrice == maxPrice) {
                                        priceDisplay = String.format("Rs %.2f", minPrice);
                                    } else {
                                        priceDisplay = String.format("Rs %.2f - Rs %.2f", minPrice, maxPrice);
                                    }
                                } else {
                                    priceDisplay = "Rs 0.00";
                                }
                            } else {
                                priceDisplay = String.format("Rs %.2f", product.getPrice());
                            }
                        } catch (Exception e) {
                            priceDisplay = String.format("Rs %.2f", product.getPrice());
                        }
                    %>
                    <div class="product-checkbox">
                        <input type="checkbox" name="productIds" value="<%= product.getProductId() %>" id="product_<%= product.getProductId() %>" <%= isSelected ? "checked" : "" %>>
                        <label for="product_<%= product.getProductId() %>" style="margin: 0; font-weight: normal; cursor: pointer;">
                            <%= product.getName() %> - <%= priceDisplay %>
                        </label>
                    </div>
                    <% } %>
                <% } %>
            </div>
            <small style="color: var(--text-secondary); display: block; margin-top: 5px;">
                Select at least one product to apply the discount
            </small>

            <button type="submit">Update Discount</button>
            <a href="${pageContext.request.contextPath}/ListDiscountsServlet" class="back-btn" style="width: 100%; text-align: center; display: block;">Cancel</a>
        </form>
    </div>
</main>

<script>
function updateDiscountValueLabel() {
    const discountType = document.getElementById('discountType').value;
    const label = document.getElementById('discountValueLabel');
    
    if (discountType === 'PERCENTAGE') {
        label.textContent = '%';
        document.getElementById('discountValue').setAttribute('max', '100');
    } else if (discountType === 'FIXED') {
        label.textContent = 'Rs';
        document.getElementById('discountValue').removeAttribute('max');
    } else {
        label.textContent = '-';
    }
}

// Initialize label on page load
updateDiscountValueLabel();

// Validate form before submission
document.querySelector('form').addEventListener('submit', function(e) {
    const productCheckboxes = document.querySelectorAll('input[name="productIds"]:checked');
    if (productCheckboxes.length === 0) {
        e.preventDefault();
        alert('Please select at least one product to apply the discount.');
        return false;
    }
    
    const discountType = document.getElementById('discountType').value;
    const discountValue = parseFloat(document.getElementById('discountValue').value);
    
    if (discountType === 'PERCENTAGE' && (discountValue <= 0 || discountValue > 100)) {
        e.preventDefault();
        alert('Percentage discount must be between 1 and 100.');
        return false;
    }
    
    if (discountType === 'FIXED' && discountValue <= 0) {
        e.preventDefault();
        alert('Fixed discount amount must be greater than 0.');
        return false;
    }
    
    return true;
});
</script>

</body>
</html>
