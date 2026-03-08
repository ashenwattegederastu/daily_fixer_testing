<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.DeliveryAssignment" %>
<%@ page import="com.dailyfixer.dao.DeliveryAssignmentDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
        return;
    }

    DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    List<DeliveryAssignment> acceptedOrders = assignmentDAO.getByDriver(user.getUserId(), "ACCEPTED");
    SimpleDateFormat dtFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Accepted Orders | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
.container {
    flex: 1;
    margin-left: 240px;
    margin-top: 83px;
    padding: 30px;
    background-color: var(--background);
}
.container h2 {
    font-size: 1.6em;
    margin-bottom: 20px;
    color: var(--foreground);
}

table {
    width: 100%;
    border-collapse: collapse;
    background: var(--card);
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
}
thead { background-color: var(--muted); }
th, td {
    padding: 15px 12px;
    text-align: left;
    border-bottom: 1px solid var(--border);
}
th {
    font-weight: 600;
    color: var(--foreground);
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
td {
    color: var(--muted-foreground);
    font-weight: 500;
}
tbody tr:hover { background-color: var(--muted); }

.btn {
    padding: 8px 16px;
    border: none;
    border-radius: var(--radius-md);
    cursor: pointer;
    font-weight: 600;
    margin-right: 8px;
    font-size: 0.85rem;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-block;
}
.complete-btn {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: #fff;
}
.btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-sm);
    opacity: 0.9;
}
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Accepted Orders</h2>

    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Pickup</th>
                <th>Dropoff</th>
                <th>Delivery Fee</th>
                <th>Accepted At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% if (acceptedOrders.isEmpty()) { %>
            <tr>
                <td colspan="7" style="text-align:center; padding:40px; color: var(--muted-foreground);">
                    No active deliveries. Accept a delivery from the Delivery Requests page.
                </td>
            </tr>
            <% } else {
                for (DeliveryAssignment a : acceptedOrders) {
                    String customerName = a.getCustomerName() != null ? a.getCustomerName() : "—";
                    String pickup       = a.getPickupAddress() != null ? a.getPickupAddress() : a.getStoreName();
                    String dropoff      = a.getDeliveryAddress() != null ? a.getDeliveryAddress() : "—";
                    String feeStr       = a.getDeliveryFeeEarned() != null
                                          ? String.format("LKR %.2f", a.getDeliveryFeeEarned()) : "LKR 0.00";
                    String acceptedAt   = a.getAssignedAt() != null ? dtFmt.format(a.getAssignedAt()) : "—";
            %>
            <tr id="row-<%= a.getAssignmentId() %>">
                <td><%= a.getOrderId() %></td>
                <td><%= customerName %></td>
                <td><%= pickup %></td>
                <td style="max-width: 180px; word-break: break-word;"><%= dropoff %></td>
                <td><strong><%= feeStr %></strong></td>
                <td><%= acceptedAt %></td>
                <td>
                    <button class="btn complete-btn"
                            onclick="completeDelivery(<%= a.getAssignmentId() %>, this)">
                        Mark Delivered
                    </button>
                </td>
            </tr>
            <% } } %>
        </tbody>
    </table>
</main>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';

    function completeDelivery(assignmentId, btn) {
        if (!confirm('Confirm delivery completed?')) return;
        btn.disabled = true;
        btn.textContent = 'Updating...';

        fetch(CONTEXT_PATH + '/driver/markDelivered', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'assignmentId=' + assignmentId
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                const row = document.getElementById('row-' + assignmentId);
                if (row) {
                    row.style.opacity = '0.4';
                    row.style.textDecoration = 'line-through';
                    btn.textContent = 'Delivered';
                    btn.style.background = '#6c757d';
                    setTimeout(() => row.remove(), 1000);
                }
            } else {
                alert(data.message || 'Failed to mark as delivered.');
                btn.disabled = false;
                btn.textContent = 'Mark Delivered';
            }
        })
        .catch(err => {
            alert('Error: ' + err.message);
            btn.disabled = false;
            btn.textContent = 'Mark Delivered';
        });
    }
</script>

</body>
</html>
