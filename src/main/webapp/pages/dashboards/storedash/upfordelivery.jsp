<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Store" %>
<%@ page import="com.dailyfixer.model.DeliveryAssignment" %>
<%@ page import="com.dailyfixer.dao.StoreDAO" %>
<%@ page import="com.dailyfixer.dao.DeliveryAssignmentDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");

    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get store for this user
    StoreDAO storeDAO = new StoreDAO();
    Store currentStore = storeDAO.getStoreByUsername(user.getUsername());
    int storeId = currentStore != null ? currentStore.getStoreId() : 0;

    // Load delivery assignments for this store
    DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    List<DeliveryAssignment> allAssignments = storeId > 0 ? assignmentDAO.getByStore(storeId) : new ArrayList<>();

    // Show active (PENDING / ACCEPTED) and recently cancelled (timed-out) assignments
    List<DeliveryAssignment> assignments = new ArrayList<>();
    for (DeliveryAssignment a : allAssignments) {
        String s = a.getStatus() != null ? a.getStatus().trim().toUpperCase() : "";
        if ("PENDING".equals(s) || "ACCEPTED".equals(s) || "CANCELLED".equals(s)) {
            assignments.add(a);
        }
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>


<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Up for Delivery | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-tables.css">

</head>
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp" class="active">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Orders Up for Delivery</h2>
    
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Dispatched</th>
                <th>Vehicle Type</th>
                <th>Driver</th>
                <th>Delivery Fee</th>
                <th>Status</th>
                <th>Delivery Address</th>
            </tr>
        </thead>
        <tbody>
            <% if (assignments.isEmpty()) { %>
                <tr>
                    <td colspan="8" style="text-align: center; padding: 30px; color: var(--muted-foreground);">
                        No orders currently awaiting or in delivery.
                    </td>
                </tr>
            <% } else {
                for (DeliveryAssignment a : assignments) {
                    String statusVal = a.getStatus() != null ? a.getStatus().trim().toUpperCase() : "PENDING";
                    String displayStatus;
                    String statusClass;
                    if ("ACCEPTED".equals(statusVal)) {
                        displayStatus = "Driver Assigned";
                        statusClass = "processing";
                    } else if ("CANCELLED".equals(statusVal)) {
                        displayStatus = "Timed Out – Refund Initiated";
                        statusClass = "cancelled";
                    } else {
                        displayStatus = "Awaiting Driver";
                        statusClass = "pending";
                    }
                    String driverName = a.getDriverName() != null && !a.getDriverName().isBlank()
                                        ? a.getDriverName() : "—";
                    String customerName = a.getCustomerName() != null && !a.getCustomerName().isBlank()
                                          ? a.getCustomerName() : "—";
                    String createdDate = a.getCreatedAt() != null ? dateFormat.format(a.getCreatedAt()) : "—";
                    String deliveryAddr = a.getDeliveryAddress() != null && !a.getDeliveryAddress().isBlank()
                                          ? a.getDeliveryAddress() : "—";
                    String feeStr = a.getDeliveryFeeEarned() != null
                                    ? String.format("LKR %.2f", a.getDeliveryFeeEarned()) : "LKR 0.00";
            %>
                <tr>
                    <td><%= a.getOrderId() %></td>
                    <td><%= customerName %></td>
                    <td><%= createdDate %></td>
                    <td><%= a.getRequiredVehicleType() %></td>
                    <td><%= driverName %></td>
                    <td><%= feeStr %></td>
                    <td><span class="status <%= statusClass %>"></span> <%= displayStatus %></td>
                    <td style="max-width: 200px; word-break: break-word;"><%= deliveryAddr %></td>
                </tr>
            <% } } %>
        </tbody>
    </table>
</main>

<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
</body>
</html>
