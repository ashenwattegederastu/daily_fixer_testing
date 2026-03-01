<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "technician".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Technician Dashboard | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
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

.driver-stats {
    background: var(--card);
    padding: 25px;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-lg);
    border: 1px solid var(--border);
    margin-bottom: 30px;
}
.driver-stats h3 {
    margin-bottom: 20px;
    color: var(--foreground);
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
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo"><fmt:message key="app.name"/></div>
    <div class="panel-name"><fmt:message key="tech.panel"/></div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode"><fmt:message key="theme.dark"/></button>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><fmt:message key="common.logout"/></a>
    </div>
</header>

<aside class="sidebar">
    <h3><fmt:message key="sidebar.navigation"/></h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/techniciandashmain.jsp" class="active"><fmt:message key="tech.dashboard"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/bookings.jsp"><fmt:message key="tech.bookings"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/serviceListings.jsp"><fmt:message key="tech.service_listings"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/acceptedBookings.jsp"><fmt:message key="tech.accepted_bookings"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/completedBookings.jsp"><fmt:message key="tech.completed_bookings"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/myProfile.jsp"><fmt:message key="tech.my_profile"/></a></li>
    </ul>
<div class="sidebar-actions" style="padding: 15px;">
    <a href="?lang=${sessionScope.sessionLocale.language == 'si' ? 'en' : 'si'}"
       class="action-btn lang-toggle" style="display:block; text-align:center; padding:8px; background:var(--primary); color:var(--primary-foreground); border-radius:var(--radius-md); text-decoration:none; font-weight:600;">
       <fmt:message key="nav.lang_switch"/>
    </a>
</div>
</aside>

<main class="container">
    <h2><fmt:message key="tech.dashboard"/></h2>
    
    <div class="stats-container">
        <div class="stat-card">
            <p class="number">12</p>
            <p><fmt:message key="tech.pending_bookings"/></p>
        </div>
        <div class="stat-card">
            <p class="number">8</p>
            <p><fmt:message key="tech.active_services"/></p>
        </div>
        <div class="stat-card is_new_cell">
            <p class="number">4.8</p>
            <p><fmt:message key="tech.avg_rating"/></p>
        </div>
        <div class="stat-card">
            <p class="number">45</p>
            <p><fmt:message key="tech.completed_jobs"/></p>
        </div>
    </div>

    <div class="driver-stats">
        <h3><fmt:message key="tech.performance"/></h3>
        <div class="stats-grid">
            <div class="info-box">
                <p><strong><fmt:message key="tech.total_services"/></strong> 45 completed</p>
            </div>
            <div class="info-box">
                <p><strong>Average Rating:</strong> 4.8/5.0</p>
            </div>
            <div class="info-box">
                <p><strong><fmt:message key="tech.this_month"/></strong> 8 services completed</p>
            </div>
            <div class="info-box">
                <p><strong><fmt:message key="tech.response_time"/></strong> 2.3 hours average</p>
            </div>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

</body>
</html>

