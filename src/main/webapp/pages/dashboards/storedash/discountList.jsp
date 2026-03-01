<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"store".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Discount> discounts = (List<Discount>) request.getAttribute("discounts");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Discount Management | Daily Fixer</title>
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
}

body.dashboard-layout {
  display: flex;
  min-height: 100vh;
}

.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.top-bar h2 {
  font-size: 1.6em;
  color: var(--foreground);
}

.btn-add {
  background: var(--primary);
  color: var(--primary-foreground);
  padding: 10px 20px;
  border-radius: var(--radius-md);
  text-decoration: none;
  font-weight: 600;
  box-shadow: var(--shadow-sm);
  transition: all 0.3s ease;
}

.btn-add:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  opacity: 0.9;
}

/* Table Styles */
.table-container {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  background-color: var(--card);
  color: var(--card-foreground);
  box-shadow: var(--shadow-lg);
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--border);
  transition: background-color 0.3s ease, border-color 0.3s ease;
}

table th,
table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid var(--border);
  transition: border-color 0.3s ease;
}

table th {
  background-color: var(--muted);
  color: var(--foreground);
  font-weight: 600;
}

table tr:hover {
  background-color: var(--accent);
  color: var(--accent-foreground);
}

.badge {
  padding: 4px 12px;
  border-radius: var(--radius-md);
  font-size: 0.85em;
  font-weight: 600;
}

.badge-active {
  background-color: oklch(0.6290 0.1902 156.4499);
  color: white;
}

.badge-inactive {
  background-color: var(--destructive);
  color: var(--destructive-foreground);
}

.badge-expired {
  background-color: oklch(0.7336 0.1758 50.5517);
  color: white;
}

.btn-delete {
  background: var(--destructive);
  color: var(--destructive-foreground);
  padding: 6px 12px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 500;
  font-size: 0.9em;
  transition: all 0.2s;
}

.btn-delete:hover {
  opacity: 0.8;
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

.btn-edit {
  background: oklch(0.7336 0.1758 50.5517);
  color: white;
  padding: 6px 12px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 500;
  font-size: 0.9em;
  text-decoration: none;
  display: inline-block;
  transition: all 0.2s;
}

.btn-edit:hover {
  opacity: 0.8;
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

.value-display {
  font-weight: 600;
  color: var(--primary);
}

.applied-to-cell {
  max-width: 300px;
  word-wrap: break-word;
}

.product-tag {
  display: inline-block;
  background: var(--secondary);
  padding: 4px 10px;
  border-radius: var(--radius-md);
  margin: 2px;
  font-size: 0.85em;
  border: 1px solid var(--border);
  color: var(--secondary-foreground);
}

.variant-tag {
  display: inline-block;
  background: var(--muted);
  padding: 4px 10px;
  border-radius: var(--radius-md);
  margin: 2px;
  font-size: 0.85em;
  border: 1px solid var(--border);
  color: var(--foreground);
}
</style>
</head>
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo"><fmt:message key="app.name"/></div>
    <div class="panel-name"><fmt:message key="store.panel"/></div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><fmt:message key="common.logout"/></a>
</header>

<aside class="sidebar">
    <h3><fmt:message key="sidebar.navigation"/></h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp"><fmt:message key="store.dashboard"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp"><fmt:message key="store.orders"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp"><fmt:message key="store.up_for_delivery"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp"><fmt:message key="store.completed_orders"/></a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet"><fmt:message key="store.catalogue"/></a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet" class="active"><fmt:message key="store.discounts"/></a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet"><fmt:message key="store.customer_reviews"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp"><fmt:message key="store.profile"/></a></li>
    </ul>
<div class="sidebar-actions" style="padding: 15px;">
    <a href="?lang=${sessionScope.sessionLocale.language == 'si' ? 'en' : 'si'}"
       class="action-btn lang-toggle" style="display:block; text-align:center; padding:8px; background:var(--primary); color:var(--primary-foreground); border-radius:var(--radius-md); text-decoration:none; font-weight:600;">
       <fmt:message key="nav.lang_switch"/>
    </a>
</div>
</aside>

<main class="container">
    <div class="top-bar">
        <h2><fmt:message key="store.discounts.title"/></h2>
        <a class="btn-add" href="${pageContext.request.contextPath}/pages/dashboards/storedash/addDiscount.jsp">+ Create Discount</a>
    </div>

    <table>
        <thead>
            <tr>
                <th>Name</th>
                <th>Type</th>
                <th>Value</th>
                <th>Applied To</th>
                <th><fmt:message key="store.discounts.start"/></th>
                <th><fmt:message key="store.discounts.end"/></th>
                <th>Status</th>
                <th><fmt:message key="store.discounts.actions"/></th>
            </tr>
        </thead>
        <tbody>
            <% if (discounts == null || discounts.isEmpty()) { %>
            <tr>
                <td colspan="8" style="text-align: center; padding: 40px; color: var(--text-secondary);">
                    No discounts created yet. <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/addDiscount.jsp" style="color: var(--accent);">Create one now</a>
                </td>
            </tr>
            <% } else { 
                DiscountDAO discountDAO = new DiscountDAO();
                ProductDAO productDAO = new ProductDAO();
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                
                for (Discount discount : discounts) {
                    long currentTime = System.currentTimeMillis();
                    boolean isExpired = discount.getEndDate() != null && currentTime > discount.getEndDate().getTime();
                    boolean isActive = discount.isActive() && !isExpired;
                    boolean isValid = discount.isValid();
                    
                    // Get linked products and variants
                    List<Integer> productIds = null;
                    List<Integer> variantIds = null;
                    List<String> productNames = new java.util.ArrayList<>();
                    List<String> variantNames = new java.util.ArrayList<>();
                    
                    try {
                        productIds = discountDAO.getProductIdsForDiscount(discount.getDiscountId());
                        variantIds = discountDAO.getVariantIdsForDiscount(discount.getDiscountId());
                        
                        // Get product names
                        for (Integer productId : productIds) {
                            try {
                                Product product = productDAO.getProductById(productId);
                                if (product != null) {
                                    productNames.add(product.getName());
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                        
                        // Get variant details
                        for (Integer variantId : variantIds) {
                            try {
                                ProductVariant variant = variantDAO.getVariantById(variantId);
                                if (variant != null) {
                                    Product parentProduct = productDAO.getProductById(variant.getProductId());
                                    String variantInfo = (parentProduct != null ? parentProduct.getName() : "Product") + " - ";
                                    if (variant.getColor() != null && !variant.getColor().isEmpty()) {
                                        variantInfo += "Color: " + variant.getColor();
                                    }
                                    if (variant.getSize() != null && !variant.getSize().isEmpty()) {
                                        variantInfo += (variantInfo.endsWith(" - ") ? "" : ", ") + "Size: " + variant.getSize();
                                    }
                                    if (variant.getPower() != null && !variant.getPower().isEmpty()) {
                                        variantInfo += (variantInfo.endsWith(" - ") ? "" : ", ") + "Power: " + variant.getPower();
                                    }
                                    variantNames.add(variantInfo);
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
                <tr>
                    <td><strong><%= discount.getDiscountName() %></strong></td>
                    <td><%= discount.getDiscountType() %></td>
                    <td class="value-display">
                        <% if ("PERCENTAGE".equalsIgnoreCase(discount.getDiscountType())) { %>
                            <%= discount.getDiscountValue() %>%
                        <% } else { %>
                            Rs <%= discount.getDiscountValue() %>
                        <% } %>
                    </td>
                    <td class="applied-to-cell">
                        <% if (productNames.isEmpty() && variantNames.isEmpty()) { %>
                            <span style="color: #999; font-style: italic;">No products/variants assigned</span>
                        <% } else { %>
                            <div style="display: flex; flex-wrap: wrap; gap: 6px;">
                                <% for (int i = 0; i < productNames.size(); i++) { %>
                                    <span class="product-tag"><%= productNames.get(i) %></span>
                                <% } %>
                                <% for (int i = 0; i < variantNames.size(); i++) { %>
                                    <span class="variant-tag"><%= variantNames.get(i) %></span>
                                <% } %>
                            </div>
                        <% } %>
                    </td>
                    <td><%= discount.getStartDate() != null ? dateFormat.format(discount.getStartDate()) : "Immediate" %></td>
                    <td><%= discount.getEndDate() != null ? dateFormat.format(discount.getEndDate()) : "No expiry" %></td>
                    <td>
                        <% if (isExpired) { %>
                            <span class="badge badge-expired">Expired</span>
                        <% } else if (isValid) { %>
                            <span class="badge badge-active">Active</span>
                        <% } else { %>
                            <span class="badge badge-inactive">Inactive</span>
                        <% } %>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/editDiscount.jsp?discountId=<%= discount.getDiscountId() %>" 
                           class="btn-edit">
                            Edit
                        </a>
                        <form method="post" action="${pageContext.request.contextPath}/DeleteDiscountServlet" style="display: inline;">
                            <input type="hidden" name="discountId" value="<%= discount.getDiscountId() %>">
                            <button type="submit" class="btn-delete" onclick="return confirm('Are you sure you want to delete this discount?');">Delete</button>
                        </form>
                    </td>
                </tr>
                <% } %>
            <% } %>
        </tbody>
    </table>
</main>

</body>
</html>
