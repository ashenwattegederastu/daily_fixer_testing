<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String role = user.getRole().trim().toLowerCase();
    if (!("technician".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Profile | Daily Fixer</title>
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

.profile-container {
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    max-width: 800px;
    margin: 0 auto;
}

.profile-header {
    display: flex;
    align-items: center;
    margin-bottom: 30px;
    padding-bottom: 20px;
    border-bottom: 1px solid #eee;
}

.profile-avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: var(--accent);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 2em;
    font-weight: bold;
    margin-right: 20px;
}

.profile-info h3 {
    margin-bottom: 5px;
    color: var(--text-dark);
}
.profile-info p {
    color: var(--text-secondary);
    margin-bottom: 5px;
}

.profile-details {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
}

.detail-section {
    background: #f8f9ff;
    padding: 20px;
    border-radius: 8px;
    border-left: 4px solid var(--accent);
}

.detail-section h4 {
    margin-bottom: 15px;
    color: var(--text-dark);
}

.detail-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    padding-bottom: 8px;
    border-bottom: 1px solid #e9ecef;
}

.detail-item:last-child {
    border-bottom: none;
    margin-bottom: 0;
}

.detail-label {
    font-weight: 600;
    color: var(--text-secondary);
}

.detail-value {
    color: var(--text-dark);
}

.edit-btn {
    display: inline-block;
    margin-top: 20px;
    padding: 12px 24px;
    background: var(--accent);
    color: white;
    text-decoration: none;
    border-radius: 8px;
    font-weight: 600;
    box-shadow: var(--shadow-sm);
    transition: all 0.2s;
}

.edit-btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Technician Dashboard</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/techniciandashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/bookings.jsp">Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/serviceListings.jsp">Service Listings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/acceptedBookings.jsp">Accepted Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/completedBookings.jsp">Completed Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/myProfile.jsp" class="active">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>My Profile</h2>
    
    <div class="profile-container">
        <div class="profile-header">
            <div class="profile-avatar">
                <%= user.getUsername().substring(0, 1).toUpperCase() %>
            </div>
            <div class="profile-info">
                <h3><%= user.getUsername() %></h3>
                <p>Technician</p>
<%--                <p>Member since: <%= user.getCreatedAt() != null ? user.getCreatedAt() : "N/A" %></p>--%>
            </div>
        </div>
        
        <div class="profile-details">
            <div class="detail-section">
                <h4>Personal Information</h4>
                <div class="detail-item">
                    <span class="detail-label">Username:</span>
                    <span class="detail-value"><%= user.getUsername() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Email:</span>
                    <span class="detail-value"><%= user.getEmail() != null ? user.getEmail() : "Not provided" %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Role:</span>
                    <span class="detail-value"><%= user.getRole() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">User ID:</span>
                    <span class="detail-value"><%= user.getUserId() %></span>
                </div>
            </div>
            
            <div class="detail-section">
                <h4>Professional Stats</h4>
                <div class="detail-item">
                    <span class="detail-label">Total Services:</span>
                    <span class="detail-value">45 completed</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Average Rating:</span>
                    <span class="detail-value">4.8/5.0</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Response Time:</span>
                    <span class="detail-value">2.3 hours</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Active Services:</span>
                    <span class="detail-value">8 listings</span>
                </div>
            </div>
        </div>
        
        <a href="#" class="edit-btn">Edit Profile</a>
    </div>
</main>

</body>
</html>
