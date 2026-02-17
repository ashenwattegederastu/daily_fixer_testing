<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Booking" %>
<%@ page import="com.dailyfixer.dao.BookingDAO" %>
<%@ page import="java.util.List" %>

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
    
    BookingDAO bookingDAO = new BookingDAO();
    List<Booking> pendingBookings = bookingDAO.getBookingsByTechnicianId(user.getUserId(), Booking.BookingStatus.REQUESTED);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bookings | Daily Fixer</title>
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
}
thead { background-color: var(--panel-color); }
th, td {
    padding:12px 10px;
    text-align:left;
    border-bottom:1px solid #ddd;
}
tbody tr:hover { background-color:#f9f9f9; }

/* Buttons */
.btn { 
    padding:8px 16px; 
    border:none; 
    border-radius:8px; 
    cursor:pointer; 
    font-weight:500; 
    margin-right:5px;
    text-decoration: none;
    display: inline-block;
    transition: all 0.2s;
    font-size: 14px;
}
.accept-btn { 
    background: #28a745; 
    color:#fff; 
}
.deny-btn { 
    background: #dc3545; 
    color:#fff; 
}
.btn:hover {
    transform: translateY(-1px);
    opacity: 0.9;
}

/* Modal */
.denial-modal {
  display:none;
  position:fixed;
  top:0; left:0;
  width:100%; height:100%;
  background: rgba(0,0,0,0.6);
  justify-content:center; align-items:center;
  z-index:500;
}
.denial-modal .modal-content {
  background:#fff;
  padding:30px;
  border-radius:12px;
  max-width:500px;
  width:90%;
  position:relative;
}
.denial-modal .close-btn {
  position:absolute;
  top:15px;
  right:20px;
  font-size:1.5em;
  font-weight:bold;
  cursor:pointer;
  color: #999;
}
.denial-modal h3 {
  margin-bottom: 15px;
  color: var(--text-dark);
}
.denial-modal textarea {
  width: 100%;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #ddd;
  margin-bottom: 20px;
  font-family: inherit;
  resize: vertical;
  min-height: 100px;
}
.denial-modal .modal-buttons {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}
.denial-modal .btn {
  margin: 0;
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
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/techniciandashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/bookings.jsp" class="active">Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/serviceListings.jsp">Service Listings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/setAvailability.jsp">Set Availability</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/acceptedBookings.jsp">Accepted Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/completedBookings.jsp">Completed Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Pending Bookings</h2>
    
    <table>
        <thead>
            <tr>
                <th>Booking ID</th>
                <th>Service Name</th>
                <th>Customer Name</th>
                <th>Preferred Date</th>
                <th>Issue Description</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% if (pendingBookings.isEmpty()) { %>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px; color: #666;">
                        No pending booking requests at the moment.
                    </td>
                </tr>
            <% } else {
                for (Booking booking : pendingBookings) { %>
                <tr>
                    <td><%= booking.getBookingId() %></td>
                    <td><%= booking.getServiceName() %></td>
                    <td><%= booking.getUserName() %></td>
                    <td><%= booking.getBookingDate() %> <%= booking.getBookingTime() %></td>
                    <td><%= booking.getProblemDescription() != null ? booking.getProblemDescription() : "-" %></td>
                    <td>
                        <button class="btn accept-btn" onclick="acceptBooking(<%= booking.getBookingId() %>)">Accept</button>
                        <button class="btn deny-btn" onclick="showDenialModal(<%= booking.getBookingId() %>)">Deny</button>
                    </td>
                </tr>
            <% } } %>
        </tbody>
    </table>
</main>

<!-- Rejection Modal -->
<div id="denialModal" class="denial-modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeDenialModal()">&times;</span>
        <h3>Reject Booking</h3>
        <p>Please provide a reason for rejecting this booking request.</p>
        <textarea id="denialReason" placeholder="Enter reason for rejection..."></textarea>
        <div class="modal-buttons">
            <button class="btn" onclick="closeDenialModal()" style="background: #6c757d;">Cancel</button>
            <button class="btn deny-btn" onclick="submitDenial()">Submit Rejection</button>
        </div>
    </div>
</div>

<script>
let currentBookingId = null;

function acceptBooking(bookingId) {
    if (confirm('Are you sure you want to accept this booking?')) {
        // Send AJAX request to accept booking
        fetch('${pageContext.request.contextPath}/AcceptBookingServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'bookingId=' + bookingId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Booking accepted successfully!');
                location.reload();
            } else {
                alert('Error accepting booking: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error accepting booking');
        });
    }
}

function showDenialModal(bookingId) {
    currentBookingId = bookingId;
    document.getElementById('denialModal').style.display = 'flex';
}

function closeDenialModal() {
    document.getElementById('denialModal').style.display = 'none';
    document.getElementById('denialReason').value = '';
    currentBookingId = null;
}

function submitDenial() {
    const reason = document.getElementById('denialReason').value.trim();
    
    if (!reason) {
        alert('Please provide a reason for rejection.');
        return;
    }
    
    if (confirm('Are you sure you want to reject this booking?')) {
        fetch('${pageContext.request.contextPath}/RejectBookingServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'bookingId=' + currentBookingId + '&reason=' + encodeURIComponent(reason)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Booking rejected successfully!');
                closeDenialModal();
                location.reload();
            } else {
                alert('Error rejecting booking: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error rejecting booking');
        });
    }
}

// Close modal on outside click
document.getElementById('denialModal').addEventListener('click', e => {
    if(e.target === document.getElementById('denialModal')) {
        closeDenialModal();
    }
});
</script>

</body>
</html>
