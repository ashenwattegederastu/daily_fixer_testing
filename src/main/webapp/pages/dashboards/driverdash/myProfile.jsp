<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
  User user = (User) session.getAttribute("currentUser");
  if (user == null || user.getRole() == null || !"driver".equalsIgnoreCase(user.getRole().trim())) {
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

/* Profile Card */
.profile-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    overflow: hidden;
    margin-bottom: 20px;
}
.profile-image {
    background: var(--panel-color);
    padding: 30px;
    text-align: center;
    border-bottom: 1px solid rgba(0,0,0,0.1);
}
.profile-image img {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    object-fit: cover;
    border: 4px solid var(--accent);
    margin-bottom: 15px;
}
.profile-image h2 {
    font-size: 1.4em;
    margin-bottom: 5px;
    color: var(--text-dark);
}
.profile-image .role {
    color: var(--accent);
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.9em;
}

/* Profile Details */
.profile-details {
    padding: 30px;
}
.profile-details table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 25px;
}
.profile-details th, .profile-details td {
    padding: 12px 15px;
    text-align: left;
    border-bottom: 1px solid #eee;
}
.profile-details th {
    background: var(--panel-color);
    font-weight: 600;
    color: var(--text-dark);
    width: 30%;
}
.profile-details td {
    color: var(--text-secondary);
    font-weight: 500;
}

/* Profile Buttons */
.profile-buttons {
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
}
.profile-buttons .btn {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    text-decoration: none;
    display: inline-block;
    transition: all 0.2s;
    box-shadow: var(--shadow-sm);
}
.profile-buttons .btn.reset {
    background: linear-gradient(135deg, #dc3545, #c82333);
    color: #fff;
}
.profile-buttons .btn.edit {
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
    color: #fff;
}
.profile-buttons .btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Driver Panel</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/driverdashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/vehicleManagement.jsp">Vehicle Management</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/deliveryrequests.jsp">Delivery Requests</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/acceptedOrders.jsp">Accepted Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/completedOrders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/myProfile.jsp" class="active">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>My Profile</h2>
    
    <div class="profile-card">
        <div class="profile-image">
            <img src="${pageContext.request.contextPath}/assets/images/default-profile.png" alt="Profile Picture">
            <h2>${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</h2>
            <p class="role">(${sessionScope.currentUser.role})</p>
        </div>

        <div class="profile-details">
            <table>
                <tr><th>Driver ID:</th><td>${sessionScope.currentUser.userId}</td></tr>
                <tr><th>First Name:</th><td>${sessionScope.currentUser.firstName}</td></tr>
                <tr><th>Last Name:</th><td>${sessionScope.currentUser.lastName}</td></tr>
                <tr><th>Username:</th><td>${sessionScope.currentUser.username}</td></tr>
                <tr><th>Email:</th><td>${sessionScope.currentUser.email}</td></tr>
                <tr><th>Phone:</th><td>${sessionScope.currentUser.phoneNumber}</td></tr>
                <tr><th>City:</th><td>${sessionScope.currentUser.city}</td></tr>
                <tr><th>Role:</th><td>${sessionScope.currentUser.role}</td></tr>
            </table>

            <div class="profile-buttons">
                <form action="${pageContext.request.contextPath}/resetPassword.jsp" method="get">
                    <button type="submit" class="btn reset">Reset Password</button>
                </form>
                <form action="${pageContext.request.contextPath}/editProfile.jsp" method="get">
                    <button type="submit" class="btn edit">Edit Account Info</button>
                </form>
            </div>
        </div>
    </div>
</main>

</body>
</html>
