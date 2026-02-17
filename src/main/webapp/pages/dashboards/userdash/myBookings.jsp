<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Booking" %>
<%@ page import="com.dailyfixer.dao.BookingDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>

<%
  User user = (User) session.getAttribute("currentUser");
  if (user == null || user.getRole() == null || !"user".equalsIgnoreCase(user.getRole().trim())) {
    response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
    return;
  }
  
  BookingDAO bookingDAO = new BookingDAO();
  List<Booking> allBookings = bookingDAO.getBookingsByUserId(user.getUserId(), null);
  
  List<Booking> activeBookings = allBookings.stream()
      .filter(b -> b.getStatus() == Booking.BookingStatus.REQUESTED || 
                   b.getStatus() == Booking.BookingStatus.ACCEPTED ||
                   b.getStatus() == Booking.BookingStatus.TECHNICIAN_COMPLETED)
      .collect(Collectors.toList());
  
  List<Booking> completedBookings = allBookings.stream()
      .filter(b -> b.getStatus() == Booking.BookingStatus.FULLY_COMPLETED)
      .collect(Collectors.toList());
  
  List<Booking> cancelledBookings = allBookings.stream()
      .filter(b -> b.getStatus() == Booking.BookingStatus.CANCELLED || 
                   b.getStatus() == Booking.BookingStatus.REJECTED)
      .collect(Collectors.toList());
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
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/userdashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/notifications.jsp">Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/searchServices.jsp">Find Services</a></li>
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
                <% if (activeBookings.isEmpty()) { %>
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px; color: #666;">
                            No active bookings. <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/searchServices.jsp">Find services</a> to book.
                        </td>
                    </tr>
                <% } else {
                    for (Booking booking : activeBookings) { 
                        String statusClass = "";
                        String statusText = "";
                        switch (booking.getStatus()) {
                            case REQUESTED:
                                statusClass = "status-pending";
                                statusText = "Pending";
                                break;
                            case ACCEPTED:
                                statusClass = "status-accepted";
                                statusText = "Accepted";
                                break;
                            case TECHNICIAN_COMPLETED:
                                statusClass = "status-accepted";
                                statusText = "Awaiting Confirmation";
                                break;
                        }
                %>
                <tr>
                    <td><strong><%= booking.getServiceName() %></strong><br><small><%= booking.getProblemDescription() != null ? booking.getProblemDescription().substring(0, Math.min(50, booking.getProblemDescription().length())) + "..." : "-" %></small></td>
                    <td><%= booking.getTechnicianName() %></td>
                    <td><%= booking.getBookingDate() %><br><%= booking.getBookingTime() %></td>
                    <td><%= booking.getLocationAddress() != null ? booking.getLocationAddress().substring(0, Math.min(40, booking.getLocationAddress().length())) + "..." : "-" %></td>
                    <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
                    <td>
                        <div class="action-buttons">
                            <% if (booking.getStatus() == Booking.BookingStatus.ACCEPTED || booking.getStatus() == Booking.BookingStatus.TECHNICIAN_COMPLETED) { %>
                                <button class="btn btn-message" onclick="alert('Chat feature coming soon!')">Message</button>
                            <% } %>
                            <% if (booking.getStatus() == Booking.BookingStatus.TECHNICIAN_COMPLETED) { %>
                                <button class="btn btn-details" onclick="confirmCompletion(<%= booking.getBookingId() %>)">Confirm Complete</button>
                            <% } %>
                            <% if (booking.getStatus() != Booking.BookingStatus.TECHNICIAN_COMPLETED) { %>
                                <button class="btn btn-cancel" onclick="showCancelDialog(<%= booking.getBookingId() %>)">Cancel</button>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <% } } %>
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
                <% if (completedBookings.isEmpty()) { %>
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px; color: #666;">
                            No completed bookings yet.
                        </td>
                    </tr>
                <% } else {
                    for (Booking booking : completedBookings) { %>
                <tr>
                    <td><strong><%= booking.getServiceName() %></strong><br><small><%= booking.getProblemDescription() != null ? booking.getProblemDescription().substring(0, Math.min(50, booking.getProblemDescription().length())) + "..." : "-" %></small></td>
                    <td><%= booking.getTechnicianName() %></td>
                    <td><%= booking.getBookingDate() %><br><%= booking.getBookingTime() %></td>
                    <td>-</td>
                    <td><span class="status-badge status-completed">Completed</span></td>
                    <td>
                        <div class="action-buttons">
                            <button class="btn btn-message" onclick="alert('Chat feature coming soon!')">Message</button>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/writeReview.jsp?bookingId=<%= booking.getBookingId() %>" class="btn btn-review">Review</a>
                        </div>
                    </td>
                </tr>
                <% } } %>
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
                <% if (cancelledBookings.isEmpty()) { %>
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px; color: #666;">
                            No cancelled bookings.
                        </td>
                    </tr>
                <% } else {
                    for (Booking booking : cancelledBookings) { 
                        String statusText = booking.getStatus() == Booking.BookingStatus.REJECTED ? "Rejected" : "Cancelled";
                %>
                <tr>
                    <td><strong><%= booking.getServiceName() %></strong><br><small><%= booking.getProblemDescription() != null ? booking.getProblemDescription().substring(0, Math.min(50, booking.getProblemDescription().length())) + "..." : "-" %></small></td>
                    <td><%= booking.getTechnicianName() %></td>
                    <td><%= booking.getBookingDate() %><br><%= booking.getBookingTime() %></td>
                    <td>-</td>
                    <td><span class="status-badge status-denied"><%= statusText %></span></td>
                    <td>
                        <div class="action-buttons">
                            <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/searchServices.jsp" class="btn btn-details">Book Again</a>
                        </div>
                    </td>
                </tr>
                <% } } %>
            </tbody>
        </table>
    </div>
</main>

<!-- Cancel Confirmation Dialog -->
<div class="dialog-overlay" id="cancelDialog">
    <div class="dialog-box">
        <h3 style="margin-bottom: 15px;">Cancel Booking</h3>
        <p>Please provide a reason for cancelling:</p>
        <textarea id="cancelReason" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; margin: 15px 0; min-height: 100px;" placeholder="Enter cancellation reason..."></textarea>
        <button class="confirm" onclick="confirmCancel()">Confirm Cancellation</button>
        <button class="cancel" onclick="closeDialog()">Go Back</button>
    </div>
</div>

<script>
let currentBookingId = null;

function showCancelDialog(bookingId) {
    currentBookingId = bookingId;
    document.getElementById('cancelDialog').style.display = 'flex';
}

function closeDialog() {
    currentBookingId = null;
    document.getElementById('cancelDialog').style.display = 'none';
    document.getElementById('cancelReason').value = '';
}

function confirmCancel() {
    const reason = document.getElementById('cancelReason').value.trim();
    
    if (!reason) {
        alert('Please provide a reason for cancellation.');
        return;
    }
    
    fetch('${pageContext.request.contextPath}/CancelBookingServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'bookingId=' + currentBookingId + '&reason=' + encodeURIComponent(reason)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Booking cancelled successfully!');
            closeDialog();
            location.reload();
        } else {
            alert('Error cancelling booking: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error cancelling booking');
    });
}

function confirmCompletion(bookingId) {
    if (confirm('Please confirm that the service has been completed to your satisfaction.')) {
        fetch('${pageContext.request.contextPath}/ConfirmCompletionServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'bookingId=' + bookingId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Thank you for confirming! The booking is now complete.');
                location.reload();
            } else {
                alert('Error: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error confirming completion');
        });
    }
}
</script>

</body>
</html>
