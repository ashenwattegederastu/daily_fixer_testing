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
<title>User Dashboard | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
.topbar-actions {
    display: flex;
    gap: 15px;
    align-items: center;
}

.topbar .home-btn {
    padding: 0.6rem 1.2rem;
    background: oklch(0.6290 0.1902 156.4499);
    border: none;
    color: white;
    border-radius: var(--radius-md);
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    text-decoration: none;
    display: inline-block;
    transition: all 0.3s ease;
}
.topbar .home-btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}

.container {
    flex:1;
    margin-left:240px;
    margin-top:83px;
    padding:30px;
    background-color: var(--background);
}

.container h2 {
    font-size:1.6em;
    margin-bottom:20px;
    color: var(--foreground);
}

.user-stats {
    background: var(--card);
    padding: 25px;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-lg);
    border: 1px solid var(--border);
    margin-bottom: 30px;
}
.user-stats h3 {
    font-size: 1.3em;
    margin-bottom: 20px;
    color: var(--foreground);
    border-bottom: 2px solid var(--border);
    padding-bottom: 10px;
}
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 15px;
}
.info-box {
    background: var(--muted);
    padding: 15px;
    border-radius: var(--radius-md);
    border-left: 4px solid var(--primary);
}
.info-box p {
    margin: 0;
    color: var(--foreground);
    font-weight: 500;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">User Panel</div>
    <div class="topbar-actions">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
        <a href="${pageContext.request.contextPath}" class="home-btn">Home</a>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
<%--    <h3>Navigation</h3>--%>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/userdashmain.jsp" class="active">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/notifications.jsp">Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myBookings.jsp">My Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myPurchases.jsp">My Purchases</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Dashboard</h2>
    
    <div class="stats-container">
        <div class="stat-card">
            <p class="number">3</p>
            <p>Active Bookings</p>
        </div>
        <div class="stat-card">
            <p class="number">5</p>
            <p>Total Purchases</p>
        </div>
        <div class="stat-card">
            <p class="number">2</p>
            <p>Pending Deliveries</p>
        </div>
    </div>

    <!-- User Stats -->
    <div class="user-stats">
        <h3>User Activity</h3>
        <div class="stats-grid">
            <div class="info-box">
                <p><strong>Total Bookings:</strong> 12</p>
            </div>
            <div class="info-box">
                <p><strong>Completed Services:</strong> 8</p>
            </div>
            <div class="info-box">
                <p><strong>Total Spent:</strong> $450</p>
            </div>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

</body>
</html>
