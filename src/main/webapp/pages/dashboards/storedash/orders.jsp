<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.dao.OrderDAO" %>
<%@ page import="com.dailyfixer.model.Order" %>
<%@ page import="com.dailyfixer.model.OrderItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
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

    // Fetch paid orders from database for this store only (excluding DELIVERED orders)
    OrderDAO orderDAO = new OrderDAO();
    String storeUsername = user.getUsername(); // Get logged-in store's username
    
    // Get orders filtered by store
    List<Order> allOrders = orderDAO.getOrdersByStatusAndStore("PAID", storeUsername);
    
    // Filter out DELIVERED orders (they should be in completedorders.jsp)
    List<Order> orders = new ArrayList<>();
    if (allOrders != null) {
        for (Order order : allOrders) {
            String status = order.getStatus() != null ? order.getStatus().trim().toUpperCase() : "";
            if (!"DELIVERED".equals(status)) {
                orders.add(order);
            }
        }
    }
    
    // Debug logging
    System.out.println("Orders.jsp: Fetched " + (orders != null ? orders.size() : 0) + " orders with status PAID for store: " + storeUsername);
    if (orders != null && !orders.isEmpty()) {
        for (Order o : orders) {
            System.out.println("  - Order ID: " + o.getOrderId() + ", Status: " + o.getStatus() + ", Customer: " + o.getFirstName() + ", Products: " + o.getProductName());
        }
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>


<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Orders | Daily Fixer</title>
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

.container h2 {
  font-size: 1.6em;
  margin-bottom: 20px;
  color: var(--foreground);
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
  position: relative;
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

td .status {
  display: inline-block;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  margin-right: 8px;
}

.status.pending { background-color: oklch(0.7336 0.1758 50.5517); }
.status.processing { background-color: var(--primary); }
.status.out-delivery { background-color: oklch(0.5828 0.1809 259.7276); }
.status.delivered { background-color: oklch(0.6290 0.1902 156.4499); }

/* Action Buttons */
.action-btn,
.btn {
  padding: 6px 12px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 500;
  transition: all 0.2s;
  text-decoration: none;
  display: inline-block;
  margin: 2px;
  white-space: nowrap;
}

.btn-view,
.view-btn {
  background-color: var(--primary);
  color: var(--primary-foreground);
}

.btn-update,
.update-btn {
  background-color: var(--primary);
  color: var(--primary-foreground);
}

.btn-delivery,
.delivery-btn {
  background-color: var(--destructive);
  color: var(--destructive-foreground);
}

.btn:hover {
  opacity: 0.8;
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

/* Status Options */
.status-options {
  display: none;
  position: absolute;
  background: var(--card);
  color: var(--card-foreground);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-lg);
  z-index: 1000;
  margin-top: 5px;
  min-width: 150px;
  padding: 5px 0;
}

.status-options button {
  display: block;
  width: 100%;
  padding: 8px 12px;
  border: none;
  background: none;
  text-align: left;
  cursor: pointer;
  font-size: 0.85em;
  color: var(--foreground);
  transition: background-color 0.2s ease;
}

.status-options button:hover {
  background-color: var(--accent);
  color: var(--accent-foreground);
}

/* Modal */
.vehicle-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.6);
  justify-content: center;
  align-items: center;
  z-index: 500;
}

.vehicle-modal .modal-content {
  background: var(--card);
  color: var(--card-foreground);
  padding: 30px;
  border-radius: var(--radius-lg);
  max-width: 400px;
  width: 90%;
  text-align: center;
  box-shadow: var(--shadow-xl);
  border: 1px solid var(--border);
  position: relative;
}

.vehicle-modal h3 {
  color: var(--primary);
  margin-bottom: 20px;
}

.vehicle-modal .vehicle-options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
  margin-bottom: 20px;
}

.vehicle-modal .vehicle-btn {
  padding: 12px;
  border: 2px solid var(--border);
  border-radius: var(--radius-md);
  background: var(--card);
  color: var(--foreground);
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.vehicle-modal .vehicle-btn:hover {
  border-color: var(--primary);
  background: var(--accent);
  color: var(--accent-foreground);
}

.vehicle-modal .vehicle-btn.selected {
  border-color: var(--primary);
  background: var(--muted);
}

.vehicle-modal .modal-buttons {
  display: flex;
  gap: 10px;
  justify-content: center;
}

.vehicle-modal .modal-btn {
  padding: 10px 20px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
}

.vehicle-modal .confirm-btn {
  background: var(--primary);
  color: var(--primary-foreground);
}

.vehicle-modal .confirm-btn:hover {
  opacity: 0.8;
}

.vehicle-modal .cancel-btn {
  background: var(--secondary);
  color: var(--secondary-foreground);
  border: 1px solid var(--border);
}

.vehicle-modal .cancel-btn:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

.close-btn {
  position: absolute;
  top: 15px;
  right: 20px;
  font-size: 1.5em;
  font-weight: bold;
  cursor: pointer;
  color: var(--muted-foreground);
  transition: color 0.2s ease;
}

.close-btn:hover {
  color: var(--foreground);
}

/* Order Details Modal */
.order-details-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  justify-content: center;
  align-items: center;
}

.order-details-modal.active {
  display: flex;
}

.order-details-content {
  background: var(--card);
  color: var(--card-foreground);
  border-radius: var(--radius-lg);
  padding: 30px;
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: var(--shadow-2xl);
  position: relative;
  border: 1px solid var(--border);
}

.order-details-content h3 {
  color: var(--primary);
  margin-bottom: 20px;
  font-size: 1.5em;
  border-bottom: 2px solid var(--border);
  padding-bottom: 10px;
}

.order-details-content .detail-section {
  margin-bottom: 20px;
}

.order-details-content .detail-section h4 {
  color: var(--foreground);
  font-size: 0.9em;
  font-weight: 600;
  margin-bottom: 5px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--muted-foreground);
}

.order-details-content .detail-section p {
  color: var(--foreground);
  font-size: 1em;
  margin: 0;
  padding: 8px 0;
  word-wrap: break-word;
}

.order-details-content .detail-row {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 15px;
  padding: 10px 0;
  border-bottom: 1px solid var(--border);
}

.order-details-content .detail-row:last-child {
  border-bottom: none;
}

.order-details-content .detail-label {
  font-weight: 600;
  color: var(--muted-foreground);
}

.order-details-content .detail-value {
  color: var(--foreground);
}

.order-details-content .close-order-modal {
  position: absolute;
  top: 15px;
  right: 20px;
  font-size: 1.5em;
  font-weight: bold;
  cursor: pointer;
  color: var(--muted-foreground);
  background: none;
  border: none;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color 0.2s ease;
}

.order-details-content .close-order-modal:hover {
  color: var(--primary);
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
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp" class="active">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Orders</h2>
    
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Status</th>
                <th>Total</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% if (orders == null || orders.isEmpty()) { %>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 30px; color: #666;">
                        No paid orders found. Orders will appear here after successful payment.
                    </td>
                </tr>
            <% } else { 
                int orderIndex = 1;
                for (Order order : orders) {
                    String orderId = order.getOrderId();
                    String customerName = order.getFirstName() + (order.getLastName() != null && !order.getLastName().isEmpty() ? " " + order.getLastName() : "");
                    String orderDate = order.getCreatedAt() != null ? dateFormat.format(order.getCreatedAt()) : "N/A";
                    // Get actual status from order, default to PENDING if not set
                    String dbStatus = order.getStatus() != null ? order.getStatus().trim().toUpperCase() : "PENDING";
                    String displayStatus = "Pending";
                    String statusClass = "pending";
                    
                    // Map database status to display status and CSS class
                    if ("PENDING".equals(dbStatus)) {
                        displayStatus = "Pending";
                        statusClass = "pending";
                    } else if ("PROCESSING".equals(dbStatus)) {
                        displayStatus = "Processing";
                        statusClass = "processing";
                    } else if ("OUT_FOR_DELIVERY".equals(dbStatus) || "OUT FOR DELIVERY".equals(dbStatus)) {
                        displayStatus = "Out for Delivery";
                        statusClass = "out-delivery";
                    } else if ("DELIVERED".equals(dbStatus)) {
                        displayStatus = "Delivered";
                        statusClass = "delivered";
                    } else if ("PAID".equals(dbStatus)) {
                        // If status is PAID, show as Pending (initial state for store)
                        displayStatus = "Pending";
                        statusClass = "pending";
                    }
                    
                    String totalAmount = String.format("LKR %.2f", order.getAmount());
                    // Escape single quotes for JavaScript
                    String escapedCustomerName = customerName.replace("'", "\\'");
                    String escapedAddress = (order.getAddress() != null ? order.getAddress() : "").replace("'", "\\'");
                    String escapedCity = (order.getCity() != null ? order.getCity() : "").replace("'", "\\'");
                    String escapedPhone = (order.getPhone() != null ? order.getPhone() : "").replace("'", "\\'");
                    String escapedEmail = (order.getEmail() != null ? order.getEmail() : "").replace("'", "\\'");
                    
                    // Get order items for this order
                    List<OrderItem> orderItems = orderDAO.getOrderItemsByOrderId(orderId);
                    // Build JSON string for order items
                    StringBuilder orderItemsJson = new StringBuilder();
                    if (orderItems != null && !orderItems.isEmpty()) {
                        orderItemsJson.append("[");
                        for (int i = 0; i < orderItems.size(); i++) {
                            OrderItem item = orderItems.get(i);
                            if (i > 0) orderItemsJson.append(",");
                            orderItemsJson.append("{");
                            // Escape JSON string properly
                            String productNameEscaped = item.getProductName() != null ? 
                                item.getProductName()
                                    .replace("\\", "\\\\")
                                    .replace("\"", "\\\"")
                                    .replace("\n", "\\n")
                                    .replace("\r", "\\r")
                                    .replace("\t", "\\t") : "";
                            orderItemsJson.append("\"productName\":\"").append(productNameEscaped).append("\",");
                            orderItemsJson.append("\"quantity\":").append(item.getQuantity()).append(",");
                            orderItemsJson.append("\"unitPrice\":").append(item.getUnitPrice()).append(",");
                            orderItemsJson.append("\"totalPrice\":").append(item.getTotalPrice());
                            orderItemsJson.append("}");
                        }
                        orderItemsJson.append("]");
                    } else {
                        orderItemsJson.append("[]");
                    }
                    String orderItemsJsonStr = orderItemsJson.toString();
            %>
                <tr>
                    <td><%= orderId %></td>
                    <td><%= customerName %></td>
                    <td><%= orderDate %></td>
                    <td id="status-<%= orderIndex %>"><span class="status <%= statusClass %>"></span><%= displayStatus %></td>
                    <td><%= totalAmount %></td>
                    <td>
                        <button class="btn view-btn" 
                                data-order-id="<%= orderId %>"
                                data-customer-name="<%= escapedCustomerName %>"
                                data-total="<%= totalAmount %>"
                                data-address="<%= escapedAddress %>"
                                data-city="<%= escapedCity %>"
                                data-phone="<%= escapedPhone %>"
                                data-email="<%= escapedEmail %>"
                                data-order-date="<%= orderDate %>"
                                data-order-items='<%= orderItemsJsonStr %>'
                                onclick="showOrderDetailsModalFromButton(this)">View Details</button>
                        <button class="btn update-btn" onclick="toggleStatusOptions(this, <%= orderIndex %>)">Update Status</button>
                        <div class="status-options" id="status-options-<%= orderIndex %>">
                            <button onclick="changeStatus(this, 'PENDING', '<%= orderId %>', <%= orderIndex %>)">Pending</button>
                            <button onclick="changeStatus(this, 'PROCESSING', '<%= orderId %>', <%= orderIndex %>)">Processing</button>
                            <button onclick="changeStatus(this, 'OUT_FOR_DELIVERY', '<%= orderId %>', <%= orderIndex %>)">Out for Delivery</button>
                            <button onclick="changeStatus(this, 'DELIVERED', '<%= orderId %>', <%= orderIndex %>)">Delivered</button>
                        </div>
                        <button class="btn delivery-btn" onclick="showVehicleModal('<%= orderId %>')">Ready to Deliver</button>
                    </td>
                </tr>
            <% 
                    orderIndex++;
                }
            } %>
        </tbody>
    </table>
</main>

<!-- Order Details Modal -->
<div id="orderDetailsModal" class="order-details-modal">
    <div class="order-details-content">
        <button class="close-order-modal" onclick="closeOrderDetailsModal()">&times;</button>
        <h3>Order Details</h3>
        
        <div class="detail-section">
            <div class="detail-row">
                <span class="detail-label">Order ID:</span>
                <span class="detail-value" id="modal-order-id">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Order Date:</span>
                <span class="detail-value" id="modal-order-date">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Customer Name:</span>
                <span class="detail-value" id="modal-customer-name">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Phone:</span>
                <span class="detail-value" id="modal-phone">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Email:</span>
                <span class="detail-value" id="modal-email">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Address:</span>
                <span class="detail-value" id="modal-address">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">City:</span>
                <span class="detail-value" id="modal-city">-</span>
            </div>
            <div class="detail-row" style="flex-direction: column; align-items: flex-start;">
                <span class="detail-label" style="margin-bottom: 10px;">Products:</span>
                <div id="modal-products" style="width: 100%; display: flex; flex-direction: column; gap: 8px;">
                    <span>-</span>
                </div>
            </div>
            <div class="detail-row">
                <span class="detail-label">Total Amount:</span>
                <span class="detail-value" id="modal-total" style="font-weight: 600; color: oklch(0.5393 0.2713 286.7462); font-size: 1.1em;">-</span>
            </div>
        </div>
    </div>
</div>

<!-- Vehicle Selection Modal -->
<div id="vehicleModal" class="vehicle-modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeVehicleModal()">&times;</span>
        <h3>Select Delivery Vehicle</h3>
        <p>Choose the type of vehicle needed for delivery:</p>
        
        <div class="vehicle-options">
            <button class="vehicle-btn" onclick="selectVehicle('bike')">Bike</button>
            <button class="vehicle-btn" onclick="selectVehicle('threewheel')">Three Wheel</button>
            <button class="vehicle-btn" onclick="selectVehicle('van')">Van</button>
            <button class="vehicle-btn" onclick="selectVehicle('lorry')">Lorry</button>
        </div>
        
        <div class="modal-buttons">
            <button class="modal-btn confirm-btn" onclick="confirmDelivery()">Confirm</button>
            <button class="modal-btn cancel-btn" onclick="closeVehicleModal()">Cancel</button>
        </div>
    </div>
</div>

<script>
let selectedOrderId = '';
let selectedVehicle = '';

function toggleStatusOptions(btn, orderIndex) {
    // Close all other status option dropdowns first
    document.querySelectorAll('.status-options').forEach(div => {
        if (div.id !== 'status-options-' + orderIndex) {
            div.style.display = 'none';
        }
    });
    
    const optionsDiv = document.getElementById('status-options-' + orderIndex);
    if (optionsDiv) {
        const isVisible = optionsDiv.style.display === 'block';
        optionsDiv.style.display = isVisible ? 'none' : 'block';
    }
}

function showOrderDetailsModalFromButton(button) {
    // Get data from button attributes
    const orderId = button.getAttribute('data-order-id') || '-';
    const customerName = button.getAttribute('data-customer-name') || '-';
    const total = button.getAttribute('data-total') || '-';
    const address = button.getAttribute('data-address') || '-';
    const city = button.getAttribute('data-city') || '-';
    const phone = button.getAttribute('data-phone') || '-';
    const email = button.getAttribute('data-email') || '-';
    const orderDate = button.getAttribute('data-order-date') || '-';
    const orderItemsJson = button.getAttribute('data-order-items') || '[]';
    
    // Parse order items JSON
    let orderItems = [];
    try {
        orderItems = JSON.parse(orderItemsJson);
    } catch (e) {
        console.error('Error parsing order items JSON:', e);
        orderItems = [];
    }
    
    // Populate modal with order details
    document.getElementById('modal-order-id').textContent = orderId;
    document.getElementById('modal-order-date').textContent = orderDate;
    document.getElementById('modal-customer-name').textContent = customerName;
    document.getElementById('modal-phone').textContent = phone;
    document.getElementById('modal-email').textContent = email;
    document.getElementById('modal-address').textContent = address;
    document.getElementById('modal-city').textContent = city;
    
    // Display order items with variant information
    const productsContainer = document.getElementById('modal-products');
    if (orderItems && Array.isArray(orderItems) && orderItems.length > 0) {
        let html = '';
        orderItems.forEach(item => {
            html += '<div style="padding: 8px; background: #f9f9f9; border-radius: 6px; border-left: 3px solid var(--accent); margin-bottom: 8px;">';
            html += '<div style="font-weight: 600; color: var(--text-dark);">' + escapeHtml(item.productName || '-') + '</div>';
            html += '<div style="font-size: 0.9em; color: var(--text-secondary); margin-top: 4px;">';
            html += 'Quantity: ' + (item.quantity || 0) + ' × LKR ' + parseFloat(item.unitPrice || 0).toFixed(2) + ' = LKR ' + parseFloat(item.totalPrice || 0).toFixed(2);
            html += '</div>';
            html += '</div>';
        });
        productsContainer.innerHTML = html;
    } else {
        productsContainer.innerHTML = '<span>-</span>';
    }
    
    document.getElementById('modal-total').textContent = total;
    
    // Show modal
    document.getElementById('orderDetailsModal').classList.add('active');
}

// Keep the old function for backward compatibility
function showOrderDetailsModal(orderId, customerName, total, address, city, phone, email, orderDate, orderItems) {
    // Populate modal with order details
    document.getElementById('modal-order-id').textContent = orderId || '-';
    document.getElementById('modal-order-date').textContent = orderDate || '-';
    document.getElementById('modal-customer-name').textContent = customerName || '-';
    document.getElementById('modal-phone').textContent = phone || '-';
    document.getElementById('modal-email').textContent = email || '-';
    document.getElementById('modal-address').textContent = address || '-';
    document.getElementById('modal-city').textContent = city || '-';
    
    // Display order items with variant information
    const productsContainer = document.getElementById('modal-products');
    if (orderItems && Array.isArray(orderItems) && orderItems.length > 0) {
        let html = '';
        orderItems.forEach(item => {
            html += '<div style="padding: 8px; background: #f9f9f9; border-radius: 6px; border-left: 3px solid var(--accent); margin-bottom: 8px;">';
            html += '<div style="font-weight: 600; color: var(--text-dark);">' + escapeHtml(item.productName || '-') + '</div>';
            html += '<div style="font-size: 0.9em; color: var(--text-secondary); margin-top: 4px;">';
            html += 'Quantity: ' + (item.quantity || 0) + ' × LKR ' + parseFloat(item.unitPrice || 0).toFixed(2) + ' = LKR ' + parseFloat(item.totalPrice || 0).toFixed(2);
            html += '</div>';
            html += '</div>';
        });
        productsContainer.innerHTML = html;
    } else {
        productsContainer.innerHTML = '<span>-</span>';
    }
    
    document.getElementById('modal-total').textContent = total || '-';
    
    // Show modal
    document.getElementById('orderDetailsModal').classList.add('active');
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function closeOrderDetailsModal() {
    document.getElementById('orderDetailsModal').classList.remove('active');
}

// Close modal on outside click
document.getElementById('orderDetailsModal').addEventListener('click', e => {
    if(e.target.id === 'orderDetailsModal') {
        closeOrderDetailsModal();
    }
});

function changeStatus(button, newStatus, orderId, orderIndex) {
    console.log('changeStatus called:', { newStatus, orderId, orderIndex });
    
    // Map status codes to display text and CSS classes
    const statusMap = {
        'PENDING': { text: 'Pending', cssClass: 'pending' },
        'PROCESSING': { text: 'Processing', cssClass: 'processing' },
        'OUT_FOR_DELIVERY': { text: 'Out for Delivery', cssClass: 'out-delivery' },
        'DELIVERED': { text: 'Delivered', cssClass: 'delivered' }
    };
    
    const statusInfo = statusMap[newStatus] || { text: newStatus, cssClass: 'pending' };
    const statusCell = document.getElementById('status-' + orderIndex);
    
    if (!statusCell) {
        console.error('Status cell not found for orderIndex:', orderIndex);
        alert('Error: Could not find status cell');
        return;
    }
    
    // Update status visually immediately
    statusCell.innerHTML = '<span class="status ' + statusInfo.cssClass + '"></span> ' + statusInfo.text;
    
    // Hide status options dropdown
    const dropdown = button.parentElement;
    if (dropdown) {
        dropdown.style.display = "none";
    }
    
    // Update order status in database via AJAX
    const contextPath = '<%= request.getContextPath() %>';
    const url = contextPath + '/UpdateOrderStatusServlet';
    console.log('Updating status via:', url);
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'orderId=' + encodeURIComponent(orderId) + '&status=' + encodeURIComponent(newStatus)
    })
    .then(response => {
        console.log('Response status:', response.status);
        if (!response.ok) {
            throw new Error('HTTP error! status: ' + response.status);
        }
        return response.json();
    })
    .then(data => {
        console.log('Response data:', data);
        if (data.success) {
            console.log('Order ' + orderId + ' status updated to ' + newStatus);
            // If status is DELIVERED, reload page after a short delay to move order to completed
            if (newStatus === 'DELIVERED') {
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            }
        } else {
            console.error('Failed to update status:', data.message);
            alert('Failed to update order status: ' + (data.message || 'Unknown error'));
            window.location.reload();
        }
    })
    .catch(error => {
        console.error('Error updating status:', error);
        alert('Error updating order status: ' + error.message + '. Please try again.');
        window.location.reload();
    });
}

function showVehicleModal(orderId) {
    selectedOrderId = orderId;
    document.getElementById('vehicleModal').style.display = 'flex';
}

function closeVehicleModal() {
    document.getElementById('vehicleModal').style.display = 'none';
    selectedVehicle = '';
    // Reset vehicle button selections
    document.querySelectorAll('.vehicle-btn').forEach(btn => {
        btn.classList.remove('selected');
    });
}

function selectVehicle(vehicle) {
    selectedVehicle = vehicle;
    // Reset all buttons
    document.querySelectorAll('.vehicle-btn').forEach(btn => {
        btn.classList.remove('selected');
    });
    // Select clicked button
    event.target.classList.add('selected');
}

function confirmDelivery() {
    if (selectedVehicle) {
        alert(`Order ${selectedOrderId} is ready for delivery using ${selectedVehicle}. Driver will be notified.`);
        closeVehicleModal();
    } else {
        alert('Please select a delivery vehicle type.');
    }
}

// Close modal on outside click
document.getElementById('vehicleModal').addEventListener('click', e => {
    if(e.target.id === 'vehicleModal') {
        closeVehicleModal();
    }
});
</script>

</body>
</html>
