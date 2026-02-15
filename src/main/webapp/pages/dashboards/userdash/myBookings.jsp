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
<title>My Bookings | Daily Fixer</title>
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

/* Booking Table */
.booking-table {
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    overflow: hidden;
    margin-bottom: 30px;
}

.booking-table table {
    width: 100%;
    border-collapse: collapse;
}

.booking-table th {
    background: var(--panel-color);
    padding: 15px 20px;
    text-align: left;
    font-weight: 600;
    color: var(--text-dark);
    border-bottom: 2px solid var(--accent);
}

.booking-table td {
    padding: 15px 20px;
    border-bottom: 1px solid rgba(0,0,0,0.1);
    vertical-align: middle;
}

.booking-table tr:hover {
    background: #f8f9ff;
}

/* Status Badges */
.status-badge {
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 0.8em;
    font-weight: 600;
    text-transform: uppercase;
}

.status-pending {
    background: #fef3c7;
    color: #92400e;
}

.status-accepted {
    background: #d1fae5;
    color: #065f46;
}

.status-denied {
    background: #fee2e2;
    color: #991b1b;
}

.status-completed {
    background: #dbeafe;
    color: #1e40af;
}

/* Action Buttons */
.action-buttons {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
}

.btn {
    padding: 6px 12px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 500;
    font-size: 0.8em;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-block;
}

.btn-message {
    background: #3b82f6;
    color: #ffffff;
}

.btn-message:hover {
    background: #2563eb;
}

.btn-details {
    background: #10b981;
    color: #ffffff;
}

.btn-details:hover {
    background: #059669;
}

.btn-cancel {
    background: #ef4444;
    color: #ffffff;
}

.btn-cancel:hover {
    background: #dc2626;
}

.btn-review {
    background: #8b5cf6;
    color: #ffffff;
}

.btn-review:hover {
    background: #7c3aed;
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

/* Dialog Box */
.dialog-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    justify-content: center;
    align-items: center;
    z-index: 1000;
}

.dialog-box {
    background: #ffffff;
    border-radius: 12px;
    padding: 30px;
    text-align: center;
    color: var(--text-dark);
    border: 1px solid rgba(0,0,0,0.1);
    width: 350px;
    box-shadow: var(--shadow-lg);
}

.dialog-box p {
    margin-bottom: 20px;
    font-size: 1em;
}

.dialog-box button {
    margin: 0 10px;
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.2s;
}

.dialog-box .confirm {
    background: #ef4444;
    color: #ffffff;
}

.dialog-box .confirm:hover {
    background: #dc2626;
}

.dialog-box .cancel {
    background: var(--panel-color);
    color: var(--text-dark);
}

.dialog-box .cancel:hover {
    background: #f0f0ff;
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
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myBookings.jsp" class="active">My Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myPurchases.jsp">My Purchases</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>My Bookings</h2>
    
    <div class="section-header">Active Bookings</div>
    
    <div class="booking-table">
        <table>
            <thead>
                <tr>
                    <th>Service</th>
                    <th>Technician</th>
                    <th>Date & Time</th>
                    <th>Address</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Electrical Repair</strong><br><small>Faulty Wiring</small></td>
                    <td>John Silva</td>
                    <td>Oct 25, 2025<br>10:30 AM</td>
                    <td>124 Main Street<br>Colombo 07</td>
                    <td><span class="status-badge status-accepted">Accepted</span></td>
                    <td>
                        <div class="action-buttons">
                            <a href="${pageContext.request.contextPath}/pages/chat.jsp?tech=JohnSilva" class="btn btn-message">Message</a>
                            <a href="#" class="btn btn-details">Details</a>
                            <a href="#" class="btn btn-cancel" onclick="showDialog()">Cancel</a>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td><strong>Plumbing Service</strong><br><small>Leaking Pipe</small></td>
                    <td>Nuwan Perera</td>
                    <td>Oct 28, 2025<br>2:00 PM</td>
                    <td>56 Lake Road<br>Kandy</td>
                    <td><span class="status-badge status-pending">Pending</span></td>
                    <td>
                        <div class="action-buttons">
                            <a href="${pageContext.request.contextPath}/pages/chat.jsp?tech=NuwanPerera" class="btn btn-message">Message</a>
                            <a href="#" class="btn btn-details">Details</a>
                            <a href="#" class="btn btn-cancel" onclick="showDialog()">Cancel</a>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="section-header">Completed Bookings</div>
    
    <div class="booking-table">
        <table>
            <thead>
                <tr>
                    <th>Service</th>
                    <th>Technician</th>
                    <th>Date & Time</th>
                    <th>Duration</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>AC Repair</strong><br><small>Cooling Issue</small></td>
                    <td>Kusal Jayawardena</td>
                    <td>Oct 10, 2025<br>11:00 AM</td>
                    <td>2 hours</td>
                    <td><span class="status-badge status-completed">Completed</span></td>
                    <td>
                        <div class="action-buttons">
                            <a href="${pageContext.request.contextPath}/pages/chat.jsp?tech=KusalJayawardena" class="btn btn-message">Message</a>
                            <a href="#" class="btn btn-details">Details</a>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/writeReview.jsp?item=ACRepair" class="btn btn-review">Review</a>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td><strong>Appliance Repair</strong><br><small>Washing Machine</small></td>
                    <td>Rajesh Kumar</td>
                    <td>Sep 15, 2025<br>3:00 PM</td>
                    <td>1.5 hours</td>
                    <td><span class="status-badge status-completed">Completed</span></td>
                    <td>
                        <div class="action-buttons">
                            <a href="${pageContext.request.contextPath}/pages/chat.jsp?tech=RajeshKumar" class="btn btn-message">Message</a>
                            <a href="#" class="btn btn-details">Details</a>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/writeReview.jsp?item=ApplianceRepair" class="btn btn-review">Review</a>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="section-header">Cancelled Bookings</div>
    
    <div class="booking-table">
        <table>
            <thead>
                <tr>
                    <th>Service</th>
                    <th>Technician</th>
                    <th>Date & Time</th>
                    <th>Reason</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Electrical Repair</strong><br><small>Power Outage</small></td>
                    <td>Mike Johnson</td>
                    <td>Sep 5, 2025<br>9:00 AM</td>
                    <td>Technician unavailable</td>
                    <td><span class="status-badge status-denied">Cancelled</span></td>
                    <td>
                        <div class="action-buttons">
                            <a href="#" class="btn btn-details">Details</a>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</main>

<!-- Cancel Confirmation Dialog -->
<div class="dialog-overlay" id="cancelDialog">
    <div class="dialog-box">
        <p>Are you sure you want to cancel this booking?</p>
        <button class="confirm" onclick="confirmCancel()">Yes, Cancel</button>
        <button class="cancel" onclick="closeDialog()">No</button>
    </div>
</div>

<script>
function showDialog() {
    document.getElementById('cancelDialog').style.display = 'flex';
}

function closeDialog() {
    document.getElementById('cancelDialog').style.display = 'none';
}

function confirmCancel() {
    closeDialog();
    alert("Your booking has been canceled.");
}
</script>

</body>
</html>
