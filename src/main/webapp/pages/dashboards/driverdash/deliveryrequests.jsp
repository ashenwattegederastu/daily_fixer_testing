<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User, com.dailyfixer.model.DeliveryAssignment, com.dailyfixer.dao.DeliveryAssignmentDAO, java.util.List, java.util.ArrayList" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
        return;
    }

    List<DeliveryAssignment> pendingAssignments = new ArrayList<>();
    String loadError = null;
    try {
        DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
        List<DeliveryAssignment> all = assignmentDAO.getAssignmentsByDriver(user.getUserId());
        for (DeliveryAssignment da : all) {
            if ("ASSIGNED".equals(da.getStatus())) pendingAssignments.add(da);
        }
    } catch (Exception e) {
        loadError = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Delivery Requests | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
.container { flex:1; margin-left:240px; margin-top:83px; padding:30px; background-color: var(--background); }
.container h2 { font-size:1.6em; margin-bottom:20px; color: var(--foreground); }
.section-card { background: var(--card); padding:25px; border-radius:var(--radius-lg); box-shadow:var(--shadow-lg); border:1px solid var(--border); margin-bottom:30px; }
.section-card h3 { font-size:1.2em; margin-bottom:15px; color:var(--foreground); border-bottom:2px solid var(--border); padding-bottom:10px; }
.assignment-table { width:100%; border-collapse:collapse; }
.assignment-table th, .assignment-table td { padding:12px 15px; text-align:left; border-bottom:1px solid var(--border); font-size:0.9em; }
.assignment-table th { background:var(--muted); font-weight:600; color:var(--foreground); }
.assignment-table tr:hover { background:var(--muted); }
.badge { padding:4px 10px; border-radius:12px; font-size:0.8em; font-weight:600; }
.badge-assigned { background:#fff3cd; color:#856404; }
.btn-accept { padding:6px 14px; background:var(--primary); color:#fff; border:none; border-radius:var(--radius-md); cursor:pointer; font-size:0.85em; font-weight:600; }
.btn-accept:hover { opacity:0.9; }
.empty-msg { text-align:center; padding:40px; color:var(--muted-foreground); font-size:1em; }
.error-alert { background:#fee2e2; border:1px solid #fca5a5; color:#b91c1c; padding:12px 16px; border-radius:var(--radius-md); margin-bottom:20px; }
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Driver Panel</div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/driverdashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/vehicleManagement.jsp">Vehicle Management</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/deliveryrequests.jsp" class="active">Delivery Requests</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/acceptedOrders.jsp">Accepted Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/completedOrders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Delivery Requests</h2>

    <% if (loadError != null) { %>
    <div class="error-alert">Error loading assignments: <%= loadError %></div>
    <% } %>

    <div class="section-card">
        <h3>Pending Requests (<%= pendingAssignments.size() %>)</h3>
        <% if (pendingAssignments.isEmpty()) { %>
            <p class="empty-msg">No pending delivery requests at the moment.</p>
        <% } else { %>
        <table class="assignment-table">
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Store</th>
                    <th>Customer</th>
                    <th>Delivery Address</th>
                    <th>City</th>
                    <th>Vehicle Type</th>
                    <th>Assigned At</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% for (DeliveryAssignment da : pendingAssignments) { %>
                <tr>
                    <td><%= da.getOrderId() %></td>
                    <td><%= da.getStoreName() != null ? da.getStoreName() : "N/A" %></td>
                    <td><%= da.getCustomerName() != null ? da.getCustomerName() : "N/A" %></td>
                    <td><%= da.getDeliveryAddress() != null ? da.getDeliveryAddress() : "N/A" %></td>
                    <td><%= da.getDeliveryCity() != null ? da.getDeliveryCity() : "N/A" %></td>
                    <td><%= da.getVehicleType() != null ? da.getVehicleType() : "Any" %></td>
                    <td><%= da.getAssignedAt() != null ? da.getAssignedAt().toString().substring(0, 16) : "N/A" %></td>
                    <td><span class="badge badge-assigned"><%= da.getStatus() %></span></td>
                    <td>
                        <button class="btn-accept" onclick="acceptDelivery(<%= da.getAssignmentId() %>, this)">Accept</button>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </div>
</main>

<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
<script>
function acceptDelivery(assignmentId, btn) {
    if (!confirm('Accept this delivery?')) return;
    btn.disabled = true;
    fetch('${pageContext.request.contextPath}/deliveryAssignment', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=pickup&assignmentId=' + assignmentId
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            btn.closest('tr').remove();
            alert('Delivery accepted and marked as Picked Up!');
        } else {
            btn.disabled = false;
            alert('Error: ' + (data.message || 'Unknown error'));
        }
    })
    .catch(() => { btn.disabled = false; alert('Network error'); });
}
</script>
</body>
</html>
