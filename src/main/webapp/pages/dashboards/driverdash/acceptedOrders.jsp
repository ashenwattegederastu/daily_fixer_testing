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
<title>Accepted Orders | Daily Fixer</title>
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
.status-accepted {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: white;
}
.status-pending {
    background: linear-gradient(135deg, #ffc107, #fd7e14);
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
.complete-btn { 
    background: linear-gradient(135deg, #28a745, #20c997); 
    color:#fff; 
}
.view-btn { 
    background: linear-gradient(135deg, var(--accent), #7ba3d4); 
    color:#fff; 
}
.btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-sm);
    opacity: 0.9;
}

/* Empty State */
.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: var(--text-secondary);
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
}
.empty-state h3 {
    margin-bottom: 10px;
    color: var(--text-dark);
}
.empty-state p {
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
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/acceptedOrders.jsp" class="active">Accepted Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/completedOrders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Accepted Orders</h2>
    
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Pickup Location</th>
                <th>Delivery Location</th>
                <th>Status</th>
                <th>Accepted Time</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>ORD-001</td>
                <td>Kamal Silva</td>
                <td>MyStore, Pettah</td>
                <td>123 Main Street, Colombo</td>
                <td><span class="status-badge status-accepted">Accepted</span></td>
                <td>2025-01-15 10:30 AM</td>
                <td>
                    <button class="btn complete-btn" onclick="completeOrder('ORD-001')">Complete Delivery</button>
                    <a href="#" class="btn view-btn">View Details</a>
                </td>
            </tr>
            <tr>
                <td>ORD-002</td>
                <td>Amal Bandara</td>
                <td>Handy Store, Dehiwala</td>
                <td>45 Lili Road, Colombo</td>
                <td><span class="status-badge status-accepted">Accepted</span></td>
                <td>2025-01-15 11:15 AM</td>
                <td>
                    <button class="btn complete-btn" onclick="completeOrder('ORD-002')">Complete Delivery</button>
                    <a href="#" class="btn view-btn">View Details</a>
                </td>
            </tr>
            <tr>
                <td>ORD-003</td>
                <td>Priya Fernando</td>
                <td>Tech Hub, Kandy</td>
                <td>78 Temple Road, Kandy</td>
                <td><span class="status-badge status-accepted">Accepted</span></td>
                <td>2025-01-15 12:00 PM</td>
                <td>
                    <button class="btn complete-btn" onclick="completeOrder('ORD-003')">Complete Delivery</button>
                    <a href="#" class="btn view-btn">View Details</a>
                </td>
            </tr>
            <tr>
                <td>ORD-004</td>
                <td>Raj Perera</td>
                <td>Hardware Plus, Negombo</td>
                <td>12 Beach Road, Negombo</td>
                <td><span class="status-badge status-accepted">Accepted</span></td>
                <td>2025-01-15 01:45 PM</td>
                <td>
                    <button class="btn complete-btn" onclick="completeOrder('ORD-004')">Complete Delivery</button>
                    <a href="#" class="btn view-btn">View Details</a>
                </td>
            </tr>
        </tbody>
    </table>
</main>

<script>
function completeOrder(orderId) {
    if (confirm('Are you sure you want to mark order ' + orderId + ' as completed?')) {
        // Here you would typically make an AJAX call to update the order status
        alert('Order ' + orderId + ' has been marked as completed!');
        
        // For demo purposes, remove the row from the table
        const row = event.target.closest('tr');
        row.style.opacity = '0.5';
        row.style.textDecoration = 'line-through';
        
        // Disable the complete button
        const completeBtn = row.querySelector('.complete-btn');
        completeBtn.textContent = 'Completed';
        completeBtn.style.background = '#6c757d';
        completeBtn.disabled = true;
    }
}
</script>

</body>
</html>
