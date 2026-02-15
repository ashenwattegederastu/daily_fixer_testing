<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Completed Orders | Daily Fixer</title>
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

/* Stats Cards */
.stats-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}
.stat-card {
    background: #fff;
    padding: 20px;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    text-align: center;
    border: 1px solid rgba(0,0,0,0.1);
}
.stat-card .number {
    font-size: 2em;
    font-weight: 700;
    color: var(--accent);
    margin-bottom: 8px;
}
.stat-card p {
    color: var(--text-secondary);
    font-weight: 500;
}

/* Table Styles */
table {
    width:100%;
    border-collapse: collapse;
    background: #fff;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
}
thead { 
    background-color: var(--panel-color); 
}
th, td {
    padding:15px 12px;
    text-align:left;
    border-bottom:1px solid rgba(0,0,0,0.1);
}
th {
    font-weight: 600;
    color: var(--text-dark);
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
td {
    color: var(--text-secondary);
    font-weight: 500;
}
tbody tr:hover { 
    background-color:#f9f9f9; 
    transform: scale(1.01);
    transition: all 0.2s;
}

/* Status Badge */
.status-badge {
    display: inline-block;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.status-completed {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: white;
}

/* Action Buttons */
.btn { 
    padding:8px 16px; 
    border:none; 
    border-radius:8px; 
    cursor:pointer; 
    font-weight:600; 
    margin-right:8px; 
    font-size: 0.85rem;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-block;
}
.view-btn { 
    background: linear-gradient(135deg, var(--accent), #7ba3d4); 
    color:#fff; 
}
.receipt-btn { 
    background: linear-gradient(135deg, #6c757d, #495057); 
    color:#fff; 
}
.btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-sm);
    opacity: 0.9;
}

/* Filter Section */
.filter-section {
    background: #fff;
    padding: 20px;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    margin-bottom: 20px;
}
.filter-section h3 {
    margin-bottom: 15px;
    color: var(--text-dark);
    font-size: 1.1em;
}
.filter-controls {
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
    align-items: center;
}
.filter-controls select, .filter-controls input {
    padding: 8px 12px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-family: 'Inter', sans-serif;
    font-size: 0.9rem;
}
.filter-controls button {
    padding: 8px 16px;
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
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
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/completedOrders.jsp" class="active">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Completed Orders</h2>
    
    <!-- Stats Cards -->
    <div class="stats-container">
        <div class="stat-card">
            <p class="number">24</p>
            <p>Total Completed</p>
        </div>
        <div class="stat-card">
            <p class="number">18</p>
            <p>This Month</p>
        </div>
        <div class="stat-card">
            <p class="number">6</p>
            <p>This Week</p>
        </div>
        <div class="stat-card">
            <p class="number">4.8</p>
            <p>Avg Rating</p>
        </div>
    </div>

    <!-- Filter Section -->
    <div class="filter-section">
        <h3>Filter Orders</h3>
        <div class="filter-controls">
            <select>
                <option>All Time</option>
                <option>This Week</option>
                <option>This Month</option>
                <option>Last 3 Months</option>
            </select>
            <select>
                <option>All Customers</option>
                <option>Kamal Silva</option>
                <option>Amal Bandara</option>
                <option>Priya Fernando</option>
            </select>
            <input type="date" placeholder="From Date">
            <input type="date" placeholder="To Date">
            <button onclick="applyFilters()">Apply Filters</button>
        </div>
    </div>
    
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Pickup Location</th>
                <th>Delivery Location</th>
                <th>Completed Time</th>
                <th>Delivery Time</th>
                <th>Rating</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>ORD-101</td>
                <td>Kamal Silva</td>
                <td>MyStore, Pettah</td>
                <td>123 Main Street, Colombo</td>
                <td>2025-01-14 02:30 PM</td>
                <td>45 min</td>
                <td>⭐⭐⭐⭐⭐ (5.0)</td>
                <td>
                    <a href="#" class="btn view-btn">View Details</a>
                    <a href="#" class="btn receipt-btn">Receipt</a>
                </td>
            </tr>
            <tr>
                <td>ORD-102</td>
                <td>Amal Bandara</td>
                <td>Handy Store, Dehiwala</td>
                <td>45 Lili Road, Colombo</td>
                <td>2025-01-14 01:15 PM</td>
                <td>38 min</td>
                <td>⭐⭐⭐⭐ (4.0)</td>
                <td>
                    <a href="#" class="btn view-btn">View Details</a>
                    <a href="#" class="btn receipt-btn">Receipt</a>
                </td>
            </tr>
            <tr>
                <td>ORD-103</td>
                <td>Priya Fernando</td>
                <td>Tech Hub, Kandy</td>
                <td>78 Temple Road, Kandy</td>
                <td>2025-01-13 04:20 PM</td>
                <td>52 min</td>
                <td>⭐⭐⭐⭐⭐ (5.0)</td>
                <td>
                    <a href="#" class="btn view-btn">View Details</a>
                    <a href="#" class="btn receipt-btn">Receipt</a>
                </td>
            </tr>
            <tr>
                <td>ORD-104</td>
                <td>Raj Perera</td>
                <td>Hardware Plus, Negombo</td>
                <td>12 Beach Road, Negombo</td>
                <td>2025-01-13 03:45 PM</td>
                <td>41 min</td>
                <td>⭐⭐⭐⭐ (4.5)</td>
                <td>
                    <a href="#" class="btn view-btn">View Details</a>
                    <a href="#" class="btn receipt-btn">Receipt</a>
                </td>
            </tr>
            <tr>
                <td>ORD-105</td>
                <td>Samantha Jayasuriya</td>
                <td>ElectroMart, Galle</td>
                <td>89 Church Street, Galle</td>
                <td>2025-01-12 05:10 PM</td>
                <td>67 min</td>
                <td>⭐⭐⭐⭐⭐ (5.0)</td>
                <td>
                    <a href="#" class="btn view-btn">View Details</a>
                    <a href="#" class="btn receipt-btn">Receipt</a>
                </td>
            </tr>
            <tr>
                <td>ORD-106</td>
                <td>Nimal Wickramasinghe</td>
                <td>Tool Center, Kurunegala</td>
                <td>34 Main Street, Kurunegala</td>
                <td>2025-01-12 11:30 AM</td>
                <td>29 min</td>
                <td>⭐⭐⭐⭐ (4.0)</td>
                <td>
                    <a href="#" class="btn view-btn">View Details</a>
                    <a href="#" class="btn receipt-btn">Receipt</a>
                </td>
            </tr>
        </tbody>
    </table>
</main>

<script>
function applyFilters() {
    alert('Filters applied! (This is a demo - filters would be implemented with backend integration)');
}
</script>

</body>
</html>
