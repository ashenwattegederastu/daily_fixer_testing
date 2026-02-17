<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    // Correctly get the user from session
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
                <th>Date</th>
                <th>Vehicle Type</th>
                <th>Driver</th>
                <th>Status</th>
                <th>Total</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>001</td>
                <td>Kamal Silva</td>
                <td>2025-07-20</td>
                <td><span class="vehicle-badge vehicle-bike">Bike</span></td>
                <td>Rajesh Kumar</td>
                <td><span class="status out-delivery"></span>Out for Delivery</td>
                <td>LKR 1,100</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn track-btn">Track Order</button>
                    <button class="btn update-btn">Update Status</button>
                </td>
            </tr>
            <tr>
                <td>003</td>
                <td>Nimal Perera</td>
                <td>2025-07-19</td>
                <td><span class="vehicle-badge vehicle-van">Van</span></td>
                <td>Suresh Fernando</td>
                <td><span class="status out-delivery"></span>Out for Delivery</td>
                <td>LKR 2,500</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn track-btn">Track Order</button>
                    <button class="btn update-btn">Update Status</button>
                </td>
            </tr>
            <tr>
                <td>004</td>
                <td>Priya Jayawardena</td>
                <td>2025-07-21</td>
                <td><span class="vehicle-badge vehicle-threewheel">Three Wheel</span></td>
                <td>Anil Perera</td>
                <td><span class="status out-delivery"></span>Out for Delivery</td>
                <td>LKR 850</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn track-btn">Track Order</button>
                    <button class="btn update-btn">Update Status</button>
                </td>
            </tr>
            <tr>
                <td>005</td>
                <td>Dinesh Wickramasinghe</td>
                <td>2025-07-21</td>
                <td><span class="vehicle-badge vehicle-lorry">Lorry</span></td>
                <td>Chaminda Silva</td>
                <td><span class="status out-delivery"></span>Out for Delivery</td>
                <td>LKR 4,200</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn track-btn">Track Order</button>
                    <button class="btn update-btn">Update Status</button>
                </td>
            </tr>
            <tr>
                <td>006</td>
                <td>Sanduni Rathnayake</td>
                <td>2025-07-22</td>
                <td><span class="vehicle-badge vehicle-bike">Bike</span></td>
                <td>Nuwan Bandara</td>
                <td><span class="status out-delivery"></span>Out for Delivery</td>
                <td>LKR 1,800</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn track-btn">Track Order</button>
                    <button class="btn update-btn">Update Status</button>
                </td>
            </tr>
        </tbody>
    </table>
</main>

<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
</body>
</html>
