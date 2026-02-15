<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null ||
            !"user".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Notifications | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
    --panel-color: #dcdaff;
    --accent: #8b95ff;
    --text-dark: #000000;
    --text-secondary: #333333;
    --shadow-sm: 0 4px 12px rgba(0,0,0,0.12);
    --shadow-md: 0 8px 24px rgba(0,0,0,0.18);
    --shadow-lg: 0 12px 36px rgba(0,0,0,0.22);
}

/* Reset */
* { margin:0; padding:0; box-sizing:border-box; }
body {
    font-family: 'Inter', sans-serif;
    background-color: #ffffff;
    color: var(--text-dark);
    display: flex;
    min-height: 100vh;
}

/* Top Navbar */
.topbar {
    position: fixed;
    top:0; left:0; right:0;
    height:76px;
    background-color: var(--panel-color);
    border-bottom: 1px solid rgba(0,0,0,0.1);
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 30px;
    z-index: 200;
    box-shadow: var(--shadow-md);
}
.topbar .logo { font-size: 1.5em; font-weight: 700; color: var(--accent); }
.topbar .panel-name { font-weight: 600; flex:1; text-align:center; color: var(--text-dark); }
.topbar-actions {
    display: flex;
    gap: 15px;
    align-items: center;
}

.topbar .home-btn {
    padding: 0.6rem 1.2rem;
    background: linear-gradient(135deg, #10b981, #059669);
    border: none;
    color: #fff;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    box-shadow: var(--shadow-sm);
    text-decoration: none;
    transition: all 0.2s;
}
.topbar .home-btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}

.topbar .logout-btn {
    padding: 0.6rem 1.2rem;
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
    border: none;
    color: #fff;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    box-shadow: var(--shadow-sm);
    text-decoration: none;
    transition: all 0.2s;
}
.topbar .logout-btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}

/* Sidebar */
.sidebar {
    width: 240px;
    background-color: var(--panel-color);
    height: 100vh;
    position: fixed;
    top:0;
    left:0;
    padding-top: 96px;
    box-shadow: var(--shadow-md);
    overflow-y: auto;
    z-index: 100;
}
.sidebar h3 { padding: 0 20px 12px; font-size: 0.85em; color: var(--text-dark); text-transform: uppercase; }
.sidebar ul { list-style:none; }
.sidebar a {
    display:block;
    padding:12px 20px;
    text-decoration:none;
    color: var(--text-dark);
    font-weight:500;
    border-left:3px solid transparent;
    border-radius:0 8px 8px 0;
    margin-bottom:4px;
    transition: all 0.2s;
}
.sidebar a:hover, .sidebar a.active {
    background-color: #f0f0ff;
    border-left-color: var(--accent);
}

/* Main Content */
.container {
    flex:1;
    margin-left:240px;
    margin-top:83px;
    padding:30px;
}
.container h2 {
    font-size:1.6em;
    margin-bottom:20px;
    color: #000000;
}

/* Notification Cards */
.notification-card {
    background: #fff;
    padding: 20px;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    margin-bottom: 15px;
    display: flex;
    align-items: center;
    gap: 15px;
    transition: all 0.2s;
}

.notification-card:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
}

.notification-icon {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    color: white;
    font-size: 1.2em;
}

.notification-icon.accepted {
    background: linear-gradient(135deg, #10b981, #059669);
}

.notification-icon.denied {
    background: linear-gradient(135deg, #ef4444, #dc2626);
}

.notification-icon.delivery {
    background: linear-gradient(135deg, #3b82f6, #2563eb);
}

.notification-icon.pending {
    background: linear-gradient(135deg, #f59e0b, #d97706);
}

.notification-content {
    flex: 1;
}

.notification-content h4 {
    margin: 0 0 5px 0;
    color: var(--text-dark);
    font-size: 1.1em;
}

.notification-content p {
    margin: 0;
    color: var(--text-secondary);
    font-size: 0.9em;
}

.notification-time {
    color: var(--text-secondary);
    font-size: 0.8em;
    font-weight: 500;
}

.notification-status {
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.8em;
    font-weight: 600;
    text-transform: uppercase;
}

.status-accepted {
    background: #d1fae5;
    color: #065f46;
}

.status-denied {
    background: #fee2e2;
    color: #991b1b;
}

.status-delivery {
    background: #dbeafe;
    color: #1e40af;
}

.status-pending {
    background: #fef3c7;
    color: #92400e;
}

/* Section Headers */
.section-header {
    font-size: 1.2em;
    font-weight: 600;
    color: var(--text-dark);
    margin: 30px 0 15px 0;
    padding-bottom: 10px;
    border-bottom: 2px solid var(--panel-color);
}

/* Empty State */
.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: var(--text-secondary);
}

.empty-state h3 {
    margin-bottom: 10px;
    color: var(--text-dark);
}

.empty-state p {
    font-size: 0.9em;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">User Panel</div>
    <div class="topbar-actions">
        <a href="${pageContext.request.contextPath}" class="home-btn">Home</a>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
<%--    <h3>Navigation</h3>--%>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/userdashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/notifications.jsp" class="active">Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myBookings.jsp">My Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myPurchases.jsp">My Purchases</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Notifications</h2>
    
    <div class="section-header">Recent Notifications</div>
    
    <!-- Booking Accepted Notification -->
    <div class="notification-card">
        <div class="notification-icon accepted">✓</div>
        <div class="notification-content">
            <h4>Booking Accepted</h4>
            <p>Your electrical repair booking for October 25, 2025 has been accepted by John Silva</p>
        </div>
        <div class="notification-time">2 hours ago</div>
        <div class="notification-status status-accepted">Accepted</div>
    </div>

    <!-- Delivery Update Notification -->
    <div class="notification-card">
        <div class="notification-icon delivery">🚚</div>
        <div class="notification-content">
            <h4>Out for Delivery</h4>
            <p>Your Heavy Duty Hammer order is now out for delivery. Expected arrival: 2-3 hours</p>
        </div>
        <div class="notification-time">4 hours ago</div>
        <div class="notification-status status-delivery">In Transit</div>
    </div>

    <!-- Booking Denied Notification -->
    <div class="notification-card">
        <div class="notification-icon denied">✗</div>
        <div class="notification-content">
            <h4>Booking Declined</h4>
            <p>Your plumbing service booking for October 28, 2025 has been declined due to scheduling conflict</p>
        </div>
        <div class="notification-time">1 day ago</div>
        <div class="notification-status status-denied">Declined</div>
    </div>

    <!-- Delivery Completed Notification -->
    <div class="notification-card">
        <div class="notification-icon accepted">📦</div>
        <div class="notification-content">
            <h4>Delivery Completed</h4>
            <p>Your Premium Paint Brush Set has been delivered successfully. Please rate your experience!</p>
        </div>
        <div class="notification-time">2 days ago</div>
        <div class="notification-status status-accepted">Delivered</div>
    </div>

    <!-- Booking Pending Notification -->
    <div class="notification-card">
        <div class="notification-icon pending">⏳</div>
        <div class="notification-content">
            <h4>Booking Under Review</h4>
            <p>Your AC repair booking is currently under review. We'll notify you once a technician is assigned</p>
        </div>
        <div class="notification-time">3 days ago</div>
        <div class="notification-status status-pending">Pending</div>
    </div>

    <div class="section-header">Earlier Notifications</div>
    
    <!-- Older notifications -->
    <div class="notification-card">
        <div class="notification-icon accepted">✓</div>
        <div class="notification-content">
            <h4>Service Completed</h4>
            <p>Your AC repair service has been completed successfully by Kusal Jayawardena</p>
        </div>
        <div class="notification-time">1 week ago</div>
        <div class="notification-status status-accepted">Completed</div>
    </div>

    <div class="notification-card">
        <div class="notification-icon delivery">📦</div>
        <div class="notification-content">
            <h4>Order Shipped</h4>
            <p>Your Cordless Drill Machine has been shipped and is on its way</p>
        </div>
        <div class="notification-time">1 week ago</div>
        <div class="notification-status status-delivery">Shipped</div>
    </div>

</main>

</body>
</html>
