<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null || !"user".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
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

/* Profile Card */
.profile-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    padding: 30px;
    margin-bottom: 30px;
}

.profile-header {
    display: flex;
    align-items: center;
    gap: 20px;
    margin-bottom: 30px;
    padding-bottom: 20px;
    border-bottom: 2px solid var(--panel-color);
}

.profile-image {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    border: 4px solid var(--accent);
    object-fit: cover;
    box-shadow: var(--shadow-sm);
}

.profile-info h3 {
    font-size: 1.8em;
    margin-bottom: 5px;
    color: var(--text-dark);
}

.profile-info .role {
    color: var(--accent);
    font-weight: 600;
    font-size: 1.1em;
}

.profile-info .member-since {
    color: var(--text-secondary);
    font-size: 0.9em;
    margin-top: 5px;
}

/* Profile Details Table */
.profile-details {
    background: var(--panel-color);
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
}

.profile-details h4 {
    font-size: 1.2em;
    margin-bottom: 15px;
    color: var(--text-dark);
    border-bottom: 1px solid rgba(0,0,0,0.1);
    padding-bottom: 10px;
}

.details-table {
    width: 100%;
    border-collapse: collapse;
}

.details-table th,
.details-table td {
    padding: 12px 15px;
    text-align: left;
    border-bottom: 1px solid rgba(0,0,0,0.1);
}

.details-table th {
    width: 30%;
    font-weight: 600;
    color: var(--text-dark);
    background: rgba(255,255,255,0.5);
}

.details-table td {
    color: var(--text-secondary);
    font-weight: 500;
}

/* Action Buttons */
.profile-actions {
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
}

.btn {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9em;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-block;
}

.btn-reset {
    background: linear-gradient(135deg, #ef4444, #dc2626);
    color: #ffffff;
}

.btn-reset:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.btn-edit {
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
    color: #ffffff;
}

.btn-edit:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.btn-settings {
    background: linear-gradient(135deg, #10b981, #059669);
    color: #ffffff;
}

.btn-settings:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

/* Stats Section */
.stats-section {
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    padding: 25px;
    margin-bottom: 30px;
}

.stats-section h4 {
    font-size: 1.2em;
    margin-bottom: 20px;
    color: var(--text-dark);
    border-bottom: 2px solid var(--panel-color);
    padding-bottom: 10px;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
}

.stat-item {
    background: var(--panel-color);
    padding: 15px;
    border-radius: 8px;
    text-align: center;
    border-left: 4px solid var(--accent);
}

.stat-item .number {
    font-size: 1.8em;
    font-weight: 700;
    color: var(--accent);
    margin-bottom: 5px;
}

.stat-item .label {
    color: var(--text-secondary);
    font-size: 0.9em;
    font-weight: 500;
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
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/notifications.jsp">Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myBookings.jsp">My Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myPurchases.jsp">My Purchases</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myProfile.jsp" class="active">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>My Profile</h2>
    
    <div class="profile-card">
        <div class="profile-header">
            <img src="${pageContext.request.contextPath}/assets/images/default-profile.png" alt="Profile Picture" class="profile-image">
            <div class="profile-info">
                <h3>${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</h3>
                <div class="role">${sessionScope.currentUser.role}</div>
                <div class="member-since">Member since January 2024</div>
            </div>
        </div>

        <div class="profile-details">
            <h4>Account Information</h4>
            <table class="details-table">
                <tr>
                    <th>User ID:</th>
                    <td>${sessionScope.currentUser.userId}</td>
                </tr>
                <tr>
                    <th>First Name:</th>
                    <td>${sessionScope.currentUser.firstName}</td>
                </tr>
                <tr>
                    <th>Last Name:</th>
                    <td>${sessionScope.currentUser.lastName}</td>
                </tr>
                <tr>
                    <th>Username:</th>
                    <td>${sessionScope.currentUser.username}</td>
                </tr>
                <tr>
                    <th>Email:</th>
                    <td>${sessionScope.currentUser.email}</td>
                </tr>
                <tr>
                    <th>Phone:</th>
                    <td>${sessionScope.currentUser.phoneNumber}</td>
                </tr>
                <tr>
                    <th>City:</th>
                    <td>${sessionScope.currentUser.city}</td>
                </tr>
                <tr>
                    <th>Role:</th>
                    <td>${sessionScope.currentUser.role}</td>
                </tr>
            </table>
        </div>

        <div class="profile-actions">
            <form action="${pageContext.request.contextPath}/resetPassword.jsp" method="get">
                <button type="submit" class="btn btn-reset">Reset Password</button>
            </form>
            <form action="${pageContext.request.contextPath}/editProfile.jsp" method="get">
                <button type="submit" class="btn btn-edit">Edit Profile</button>
            </form>
            <a href="#" class="btn btn-settings">Account Settings</a>
        </div>
    </div>

    <div class="stats-section">
        <h4>Account Statistics</h4>
        <div class="stats-grid">
            <div class="stat-item">
                <div class="number">12</div>
                <div class="label">Total Bookings</div>
            </div>
            <div class="stat-item">
                <div class="number">8</div>
                <div class="label">Completed Services</div>
            </div>
            <div class="stat-item">
                <div class="number">15</div>
                <div class="label">Total Purchases</div>
            </div>
            <div class="stat-item">
                <div class="number">$450</div>
                <div class="label">Total Spent</div>
            </div>
        </div>
    </div>
</main>

</body>
</html>
