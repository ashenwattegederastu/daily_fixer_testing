<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Review" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Get the currently logged-in user from session
    User user = (User) session.getAttribute("currentUser");

    // Redirect to login if no user or role is set
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Check role: allow only admin or store
    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get reviews from request attribute (set by servlet)
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    
    if (reviews == null) {
        reviews = new java.util.ArrayList<>();
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    
    // Calculate statistics
    int totalReviews = reviews.size();
    double avgRating = 0.0;
    int[] ratingCounts = new int[6]; // 0-5 stars
    
    if (totalReviews > 0) {
        int totalRating = 0;
        for (Review review : reviews) {
            int rating = review.getRating();
            totalRating += rating;
            if (rating >= 0 && rating <= 5) {
                ratingCounts[rating]++;
            }
        }
        avgRating = (double) totalRating / totalReviews;
    }
    
    // Load product data for modal (get unique product IDs from reviews)
    Set<Integer> productIds = new HashSet<>();
    for (Review review : reviews) {
        productIds.add(review.getProductId());
    }
    
    ProductDAO productDAO = new ProductDAO();
    ProductVariantDAO variantDAO = new ProductVariantDAO();
    DiscountDAO discountDAO = new DiscountDAO();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Customer Reviews | Daily Fixer</title>
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
  padding: 0;
  margin: 0;
}

.sidebar li {
  margin: 0;
  padding: 0;
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
  line-height: 1.5;
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

/* Stats Cards */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: var(--card);
  padding: 20px;
  border-radius: var(--radius-lg);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-lg);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-xl);
}

.stat-card h3 {
  font-size: 0.9rem;
  color: var(--muted-foreground);
  margin: 0 0 10px 0;
  font-weight: 500;
}

.stat-card .stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--primary);
  margin: 0;
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

table tbody tr:last-child td {
  border-bottom: none;
}

/* Rating Stars */
.rating-stars {
  display: inline-flex;
  align-items: center;
  gap: 2px;
}

.star {
  font-size: 1.2em;
  color: oklch(0.7336 0.1758 50.5517);
  transition: color 0.3s ease;
}

.star.empty {
  color: var(--muted-foreground);
  opacity: 0.3;
}

/* Product Link */
.product-link {
  color: var(--primary);
  text-decoration: none;
  font-weight: 600;
  transition: color 0.2s ease;
}

.product-link:hover {
  color: var(--primary);
  text-decoration: underline;
  opacity: 0.8;
}

/* Comment Cell */
.comment-cell {
  max-width: 400px;
  word-wrap: break-word;
  line-height: 1.5;
  color: var(--muted-foreground);
}

/* Customer Name */
.customer-name {
  font-weight: 500;
  color: var(--foreground);
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: var(--muted-foreground);
}

.empty-state h3 {
  font-size: 1.5em;
  margin-bottom: 10px;
  color: var(--foreground);
}

.empty-state p {
  font-size: 1rem;
}

/* View Product Button */
.btn-view {
  background: var(--primary);
  color: var(--primary-foreground);
  padding: 6px 12px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 500;
  font-size: 0.85rem;
  text-decoration: none;
  display: inline-block;
  transition: all 0.2s;
}

.btn-view:hover {
  opacity: 0.8;
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

/* Product Details Modal */
.product-details-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.7);
  backdrop-filter: blur(4px);
  justify-content: center;
  align-items: center;
  z-index: 600;
  overflow-y: auto;
  padding: 20px;
}

.product-details-modal .modal-content {
  background: var(--card);
  color: var(--card-foreground);
  padding: 0;
  border-radius: var(--radius-lg);
  max-width: 1000px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: var(--shadow-2xl);
  position: relative;
  border: 1px solid var(--border);
}

.product-details-modal .modal-header {
  background: var(--primary);
  color: var(--primary-foreground);
  padding: 25px 30px;
  border-radius: var(--radius-lg) var(--radius-lg) 0 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.product-details-modal .modal-header h3 {
  margin: 0;
  font-size: 1.6em;
  font-weight: 700;
  color: var(--primary-foreground);
}

.product-details-modal .close-btn {
  color: var(--primary-foreground);
  font-size: 1.8em;
  background: rgba(255,255,255,0.2);
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  cursor: pointer;
  border: none;
}

.product-details-modal .close-btn:hover {
  background: rgba(255,255,255,0.3);
  transform: rotate(90deg);
}

.product-details-modal .modal-body {
  padding: 30px;
}

.product-details-grid {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 40px;
  margin-bottom: 40px;
  align-items: start;
}

.product-image-section {
  position: sticky;
  top: 20px;
}

.product-image-section img {
  width: 100%;
  height: auto;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  border: 3px solid var(--card);
}

.product-info-section {
  background: var(--card);
  padding: 25px;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  border: 1px solid var(--border);
}

.product-info-section h4 {
  color: var(--primary);
  margin-top: 0;
  margin-bottom: 20px;
  font-size: 1.3em;
  padding-bottom: 10px;
  border-bottom: 2px solid var(--border);
}

.info-row {
  display: flex;
  margin-bottom: 18px;
  padding-bottom: 18px;
  border-bottom: 1px solid var(--border);
  align-items: flex-start;
}

.info-row:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.info-label {
  font-weight: 600;
  color: var(--muted-foreground);
  width: 140px;
  flex-shrink: 0;
  font-size: 0.95em;
}

.info-value {
  color: var(--foreground);
  flex: 1;
  line-height: 1.6;
  word-wrap: break-word;
}

.variants-section {
  margin-top: 30px;
  padding: 25px;
  background: var(--card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  border: 1px solid var(--border);
}

.variants-section h4 {
  color: var(--primary);
  margin-top: 0;
  margin-bottom: 20px;
  font-size: 1.3em;
  padding-bottom: 10px;
  border-bottom: 2px solid var(--border);
}

.product-details-modal .variants-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  margin-top: 15px;
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--border);
  background: var(--card);
  box-shadow: var(--shadow-sm);
}

.product-details-modal .variants-table thead {
  background: var(--primary);
}

.product-details-modal .variants-table th {
  padding: 16px 12px;
  text-align: left;
  font-weight: 600;
  color: var(--primary-foreground);
  font-size: 0.85em;
  text-transform: uppercase;
  letter-spacing: 0.8px;
  border-right: 1px solid rgba(255,255,255,0.2);
  white-space: nowrap;
}

.product-details-modal .variants-table th:last-child {
  border-right: none;
}

.product-details-modal .variants-table td {
  padding: 16px 12px;
  border-bottom: 1px solid var(--border);
  font-size: 0.9em;
  color: var(--foreground);
  vertical-align: middle;
}

.product-details-modal .variants-table tbody tr:last-child td {
  border-bottom: none;
}

.product-details-modal .variants-table tbody tr:nth-child(even) {
  background-color: var(--muted);
}

.product-details-modal .variants-table tbody tr:hover {
  background-color: var(--accent);
  color: var(--accent-foreground);
  transform: translateX(4px);
  box-shadow: -4px 0 0 var(--primary);
}

.variant-attribute {
  display: inline-block;
  padding: 6px 14px;
  background: var(--secondary);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  font-weight: 500;
  color: var(--secondary-foreground);
  font-size: 0.9em;
  box-shadow: var(--shadow-xs);
  white-space: nowrap;
  text-align: center;
  min-width: 60px;
}

.variant-price {
  font-weight: 600;
  color: var(--foreground);
  display: block;
  line-height: 1.4;
}

.variant-price.original {
  text-decoration: line-through;
  color: var(--muted-foreground);
  font-size: 0.85em;
  margin-bottom: 2px;
}

.variant-price.discounted {
  color: oklch(0.6290 0.1902 156.4499);
  font-size: 1em;
}

.discount-badge {
  background: var(--destructive);
  color: var(--destructive-foreground);
  padding: 6px 14px;
  border-radius: var(--radius-md);
  font-size: 0.85em;
  font-weight: 600;
  display: inline-block;
  box-shadow: var(--shadow-sm);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.no-variants {
  color: var(--muted-foreground);
  font-style: italic;
  padding: 40px 20px;
  text-align: center;
  background: var(--muted);
  border-radius: var(--radius-md);
  border: 2px dashed var(--border);
}

.status-badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: var(--radius-md);
  font-size: 0.85em;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  box-shadow: var(--shadow-xs);
}

.status-badge.in-stock {
  background: oklch(0.6290 0.1902 156.4499);
  color: white;
}

.status-badge.out-of-stock {
  background: var(--destructive);
  color: var(--destructive-foreground);
}

@media (max-width: 768px) {
  .product-details-grid {
    grid-template-columns: 1fr;
    gap: 25px;
  }
  
  .product-image-section {
    position: relative;
    text-align: center;
  }
  
  .product-image-section img {
    max-width: 250px;
  }
  
  .product-details-modal .modal-content {
    max-width: 95%;
    margin: 10px;
  }
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
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet" class="active">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <div class="top-bar">
        <h2>Customer Reviews</h2>
    </div>

    <!-- Statistics Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <h3>Total Reviews</h3>
            <div class="stat-value"><%= totalReviews %></div>
        </div>
        <div class="stat-card">
            <h3>Average Rating</h3>
            <div class="stat-value"><%= totalReviews > 0 ? String.format("%.1f", avgRating) : "N/A" %></div>
        </div>
        <div class="stat-card">
            <h3>5 Star Reviews</h3>
            <div class="stat-value"><%= ratingCounts[5] %></div>
        </div>
        <div class="stat-card">
            <h3>4 Star Reviews</h3>
            <div class="stat-value"><%= ratingCounts[4] %></div>
        </div>
    </div>

    <!-- Reviews Table -->
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Customer</th>
                    <th>Rating</th>
                    <th>Comment</th>
                    <th>Date</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% if (reviews == null || reviews.isEmpty()) { %>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px; color: var(--muted-foreground);">
                        No reviews yet. Reviews will appear here once customers submit them.
                    </td>
                </tr>
                <% } else { 
                    for (Review review : reviews) {
                        String productName = review.getProductName() != null ? review.getProductName() : "Product #" + review.getProductId();
                        String customerName = review.getUsername() != null ? review.getUsername() : "Anonymous";
                        int rating = review.getRating();
                        String ratingClass = "star-" + rating;
                        String comment = review.getComment() != null && !review.getComment().trim().isEmpty() 
                            ? review.getComment() : "No comment provided";
                %>
                <tr>
                    <td>
                        <strong><%= productName %></strong>
                    </td>
                    <td>
                        <span class="customer-name"><%= customerName %></span>
                    </td>
                    <td>
                        <div class="rating-stars">
                            <% 
                                for (int i = 1; i <= 5; i++) {
                                    if (i <= rating) {
                            %>
                                <span class="star">★</span>
                            <% } else { %>
                                <span class="star empty">★</span>
                            <% } 
                                } %>
                        </div>
                    </td>
                    <td class="comment-cell">
                        <%= comment.length() > 100 ? comment.substring(0, 100) + "..." : comment %>
                    </td>
                    <td>
                        <%= review.getCreatedAt() != null ? dateFormat.format(review.getCreatedAt()) : "N/A" %>
                    </td>
                    <td>
                        <button class="btn-view" onclick="viewProductDetails(<%= review.getProductId() %>)">
                            View Product
                        </button>
                    </td>
                </tr>
                <% } 
                } %>
            </tbody>
        </table>
    </div>
</main>

<!-- Product Details Modal -->
<div id="productDetailsModal" class="product-details-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalProductName">Product Details</h3>
            <button class="close-btn" onclick="closeProductDetailsModal()">&times;</button>
        </div>
        <div class="modal-body">
            <div class="product-details-grid">
                <div class="product-image-section">
                    <img id="modalProductImage" src="" alt="Product Image">
                </div>
                <div class="product-info-section">
                    <h4>Product Information</h4>
                    <div class="info-row">
                        <span class="info-label">Name:</span>
                        <span class="info-value" id="modalName"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Type:</span>
                        <span class="info-value" id="modalType"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Description:</span>
                        <span class="info-value" id="modalDescription"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Price Range:</span>
                        <span class="info-value" id="modalBasePrice" style="font-weight: 600; color: oklch(0.5393 0.2713 286.7462);"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Total Stock:</span>
                        <span class="info-value" id="modalBaseStock" style="font-weight: 600; color: oklch(0.5393 0.2713 286.7462);"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Unit:</span>
                        <span class="info-value" id="modalUnit"></span>
                    </div>
                </div>
            </div>
            <div class="variants-section">
                <h4>Product Variants</h4>
                <div id="modalVariantsContainer"></div>
            </div>
        </div>
    </div>
</div>

<script>
let productData = {};

// Load product data for all products in reviews
<% 
    for (Integer productId : productIds) {
        try {
            Product product = productDAO.getProductById(productId);
            if (product != null) {
                List<ProductVariant> variants = variantDAO.getVariantsByProductId(productId);
%>
productData[<%=productId%>] = {
    id: <%=product.getProductId()%>,
    name: "<%=product.getName() != null ? product.getName().replace("\"", "\\\"").replace("\n", "\\n") : ""%>",
    type: "<%=product.getType() != null ? product.getType() : ""%>",
    description: "<%=product.getDescription() != null ? product.getDescription().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r") : ""%>",
    price: <%=product.getPrice()%>,
    quantity: <%=product.getQuantity()%>,
    unit: "<%=product.getQuantityUnit() != null ? product.getQuantityUnit() : ""%>",
    image: "<%=product.getImage() != null ? "data:image/jpeg;base64," + java.util.Base64.getEncoder().encodeToString(product.getImage()) : ""%>",
    variants: [
        <% if (variants != null && !variants.isEmpty()) {
            for (int i = 0; i < variants.size(); i++) {
                ProductVariant v = variants.get(i);
                Discount variantDiscount = null;
                Discount productDiscount = null;
                try {
                    variantDiscount = discountDAO.getActiveDiscountForVariant(v.getVariantId());
                    if (variantDiscount == null || !variantDiscount.isValid()) {
                        productDiscount = discountDAO.getActiveDiscountForProduct(productId);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                Discount activeDiscount = (variantDiscount != null && variantDiscount.isValid()) ? variantDiscount : 
                                        ((productDiscount != null && productDiscount.isValid()) ? productDiscount : null);
                double variantPrice = v.getPrice() != null ? v.getPrice().doubleValue() : 0.0;
                double variantDisplayPrice = variantPrice;
                if (activeDiscount != null && activeDiscount.isValid()) {
                    variantDisplayPrice = activeDiscount.calculateDiscountedPrice(variantPrice);
                }
        %>{
            id: <%=v.getVariantId()%>,
            color: "<%=v.getColor() != null ? v.getColor().replace("\"", "\\\"") : ""%>",
            size: "<%=v.getSize() != null ? v.getSize().replace("\"", "\\\"") : ""%>",
            power: "<%=v.getPower() != null ? v.getPower().replace("\"", "\\\"") : ""%>",
            price: <%=variantPrice%>,
            displayPrice: <%=variantDisplayPrice%>,
            quantity: <%=v.getQuantity()%>,
            discount: <% if (activeDiscount != null && activeDiscount.isValid()) { %>{
                name: "<%=activeDiscount.getDiscountName() != null ? activeDiscount.getDiscountName().replace("\"", "\\\"").replace("\n", "\\n") : ""%>",
                type: "<%=activeDiscount.getDiscountType() != null ? activeDiscount.getDiscountType() : ""%>",
                value: <%=activeDiscount.getDiscountValue() != null ? activeDiscount.getDiscountValue() : 0%>
            }<% } else { %>null<% } %>
        }<%= (i < variants.size() - 1) ? "," : "" %>
        <%   }
           } %>
    ]
};
<%          }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

function viewProductDetails(productId) {
    const product = productData[productId];
    if (!product) {
        alert('Product data not available');
        return;
    }
    
    // Calculate price range and total quantity from variants
    let priceRange = '';
    let totalQuantity = product.quantity;
    
    if (product.variants && product.variants.length > 0) {
        // Calculate price range from variants
        const prices = product.variants.map(v => v.price).filter(p => p > 0);
        const displayPrices = product.variants.map(v => v.displayPrice).filter(p => p > 0);
        
        if (prices.length > 0) {
            const minPrice = Math.min(...prices);
            const maxPrice = Math.max(...prices);
            const minDisplayPrice = Math.min(...displayPrices);
            const maxDisplayPrice = Math.max(...displayPrices);
            
            if (minPrice === maxPrice) {
                priceRange = 'Rs. ' + minPrice.toFixed(2);
            } else {
                priceRange = 'Rs. ' + minPrice.toFixed(2) + ' - Rs. ' + maxPrice.toFixed(2);
            }
        } else {
            priceRange = 'Rs. ' + product.price.toFixed(2);
        }
        
        // Calculate total quantity from all variants
        totalQuantity = product.variants.reduce((sum, v) => sum + (v.quantity || 0), 0);
    } else {
        priceRange = 'Rs. ' + product.price.toFixed(2);
    }
    
    // Populate basic info
    document.getElementById('modalProductName').textContent = product.name;
    document.getElementById('modalName').textContent = product.name;
    document.getElementById('modalType').textContent = product.type || 'N/A';
    document.getElementById('modalDescription').textContent = product.description || 'No description';
    document.getElementById('modalBasePrice').textContent = priceRange;
    document.getElementById('modalBaseStock').textContent = totalQuantity;
    document.getElementById('modalUnit').textContent = product.unit || 'units';
    
    // Set image
    const imgEl = document.getElementById('modalProductImage');
    if (product.image) {
        imgEl.src = product.image;
        imgEl.style.display = 'block';
    } else {
        imgEl.src = '${pageContext.request.contextPath}/assets/images/tools.png';
        imgEl.style.display = 'block';
    }
    
    // Populate variants
    const variantsContainer = document.getElementById('modalVariantsContainer');
    if (product.variants && product.variants.length > 0) {
        let html = '<table class="variants-table"><thead><tr>';
        html += '<th>Color</th><th>Size</th><th>Power</th><th>Price</th><th>Discount</th><th>Stock</th><th>Status</th>';
        html += '</tr></thead><tbody>';
        
        product.variants.forEach(variant => {
            html += '<tr>';
            
            // Color column
            html += '<td>';
            if (variant.color && variant.color.trim() !== '') {
                html += '<span class="variant-attribute">' + variant.color + '</span>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Size column
            html += '<td>';
            if (variant.size && variant.size.trim() !== '') {
                html += '<span class="variant-attribute">' + variant.size + '</span>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Power column
            html += '<td>';
            if (variant.power && variant.power.trim() !== '') {
                html += '<span class="variant-attribute">' + variant.power + '</span>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Price column
            html += '<td>';
            if (variant.discount && variant.displayPrice < variant.price) {
                html += '<span class="variant-price original">Rs. ' + variant.price.toFixed(2) + '</span>';
                html += '<br><span class="variant-price discounted">Rs. ' + variant.displayPrice.toFixed(2) + '</span>';
            } else {
                html += '<span class="variant-price">Rs. ' + variant.price.toFixed(2) + '</span>';
            }
            html += '</td>';
            
            // Discount column
            html += '<td>';
            if (variant.discount && variant.displayPrice < variant.price) {
                html += '<span class="discount-badge">';
                if (variant.discount.type === 'PERCENTAGE') {
                    html += variant.discount.value + '% OFF';
                } else {
                    html += 'Rs. ' + variant.discount.value + ' OFF';
                }
                html += '</span>';
                html += '<br><small style="color: #666; margin-top: 4px; display: block; font-size: 0.8em;">' + variant.discount.name + '</small>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Stock column
            html += '<td><strong style="font-size: 1.05em;">' + variant.quantity + '</strong></td>';
            
            // Status column
            html += '<td>';
            if (variant.quantity > 0) {
                html += '<span class="status-badge in-stock">In Stock</span>';
            } else {
                html += '<span class="status-badge out-of-stock">Out of Stock</span>';
            }
            html += '</td>';
            
            html += '</tr>';
        });
        
        html += '</tbody></table>';
        variantsContainer.innerHTML = html;
    } else {
        variantsContainer.innerHTML = '<p class="no-variants">No variants available for this product.</p>';
    }
    
    // Show modal
    document.getElementById('productDetailsModal').style.display = 'flex';
}

function closeProductDetailsModal() {
    document.getElementById('productDetailsModal').style.display = 'none';
}

// Close modal on outside click
document.getElementById('productDetailsModal').addEventListener('click', e => {
    if(e.target.id === 'productDetailsModal') {
        closeProductDetailsModal();
    }
});
</script>

</body>
</html>
