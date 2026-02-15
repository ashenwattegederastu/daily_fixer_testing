<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>

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

/* Table Styles */
table {
    width:100%;
    border-collapse: collapse;
    box-shadow: var(--shadow-sm);
    background: white;
    border-radius: 12px;
    overflow: hidden;
    border: 1px solid rgba(0,0,0,0.1);
}
thead { background-color: var(--panel-color); }
th, td {
    padding:12px 10px;
    text-align:left;
    border-bottom:1px solid #ddd;
}
tbody tr:hover { background-color:#f9f9f9; }

td .status {
    display:inline-block;
    width:14px;
    height:14px;
    border-radius:50%;
    margin-right: 8px;
}
.status.delivered { background-color: #27ae60; }

/* Buttons */
.btn { 
    padding:6px 12px; 
    border:none; 
    border-radius:8px; 
    cursor:pointer; 
    font-weight:500; 
    margin-right:5px;
    font-size: 0.85em;
}
.view-btn { background:#20255b; color:#fff; }
.receipt-btn { background: var(--accent); color:#fff; }
.review-btn { background: #f39c12; color:#fff; }

.btn:hover {
    opacity: 0.9;
    transform: translateY(-1px);
}

/* Rating Stars */
.rating {
    color: #f39c12;
    font-size: 0.9em;
}

/* Delivery Date */
.delivery-date {
    color: var(--text-secondary);
    font-size: 0.85em;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp" class="active">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Completed Orders</h2>
    
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Order Date</th>
                <th>Delivery Date</th>
                <th>Status</th>
                <th>Rating</th>
                <th>Total</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>002</td>
                <td>Amal Bandara</td>
                <td>2025-07-06</td>
                <td class="delivery-date">2025-07-08</td>
                <td><span class="status delivered"></span>Delivered</td>
                <td class="rating">★★★★★ (5.0)</td>
                <td>LKR 350</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn receipt-btn">Download Receipt</button>
                    <button class="btn review-btn">View Review</button>
                </td>
            </tr>
            <tr>
                <td>007</td>
                <td>Lakshmi Fernando</td>
                <td>2025-07-15</td>
                <td class="delivery-date">2025-07-17</td>
                <td><span class="status delivered"></span>Delivered</td>
                <td class="rating">★★★★☆ (4.0)</td>
                <td>LKR 1,250</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn receipt-btn">Download Receipt</button>
                    <button class="btn review-btn">View Review</button>
                </td>
            </tr>
            <tr>
                <td>008</td>
                <td>Ravi Jayawardena</td>
                <td>2025-07-12</td>
                <td class="delivery-date">2025-07-14</td>
                <td><span class="status delivered"></span>Delivered</td>
                <td class="rating">★★★★★ (5.0)</td>
                <td>LKR 2,100</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn receipt-btn">Download Receipt</button>
                    <button class="btn review-btn">View Review</button>
                </td>
            </tr>
            <tr>
                <td>009</td>
                <td>Nisha Wickramasinghe</td>
                <td>2025-07-10</td>
                <td class="delivery-date">2025-07-12</td>
                <td><span class="status delivered"></span>Delivered</td>
                <td class="rating">★★★★☆ (4.5)</td>
                <td>LKR 750</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn receipt-btn">Download Receipt</button>
                    <button class="btn review-btn">View Review</button>
                </td>
            </tr>
            <tr>
                <td>010</td>
                <td>Kumar Perera</td>
                <td>2025-07-08</td>
                <td class="delivery-date">2025-07-10</td>
                <td><span class="status delivered"></span>Delivered</td>
                <td class="rating">★★★★★ (5.0)</td>
                <td>LKR 3,500</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn receipt-btn">Download Receipt</button>
                    <button class="btn review-btn">View Review</button>
                </td>
            </tr>
        </tbody>
    </table>
</main>

</body>
</html>
