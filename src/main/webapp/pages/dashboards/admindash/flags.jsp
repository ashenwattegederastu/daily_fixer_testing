<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null ||
            !"admin".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flags Management | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/pages/dashboards/admindash/admin-theme.css">
</head>

<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Admin Panel</div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/admindashmain.jsp"> Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/users"> User Management</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/flags.jsp" class="active"> Flags</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/transactions.jsp"> Transactions</a></li>
    </ul>
</aside>

<main class="main-content">
    <div class="dashboard-header">
        <h1>Flags Management</h1>
        <p>Review and manage system flags and reports</p>
    </div>

    <!-- Quick Stats -->
    <div class="stats-container">
        <div class="stat-card">
            <div class="number">8</div>
            <p>Pending Flags</p>
        </div>
<%--        <div class="stat-card">--%>
<%--            <div class="number">3</div>--%>
<%--            <p>High Priority</p>--%>
<%--        </div>--%>
        <div class="stat-card">
            <div class="number">15</div>
            <p>Resolved This Week</p>
        </div>
        <div class="stat-card">
            <div class="number">2</div>
            <p>Dismissed Today</p>
        </div>
    </div>

    <!-- Search and Filter -->
    <div class="search-container">
        <input type="text" class="search-input" placeholder="Search flags by ID, user, or description..." id="flagSearch">
<%--        <select class="filter-select" id="priorityFilter">--%>
<%--            <option value="">All Priorities</option>--%>
<%--            <option value="high">High Priority</option>--%>
<%--            <option value="medium">Medium Priority</option>--%>
<%--            <option value="low">Low Priority</option>--%>
<%--        </select>--%>
        <select class="filter-select" id="statusFilter">
            <option value="">All Status</option>
            <option value="pending">Pending</option>
            <option value="resolved">Resolved</option>
            <option value="dismissed">Dismissed</option>
        </select>
    </div>

    <!-- Flags Table -->
    <div class="section">
        <h2>All Flags</h2>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Flag ID</th>
                        <th>Type</th>
                        <th>Description</th>
                        <th>Reporter</th>
<%--                        <th>Priority</th>--%>
                        <th>Status</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>FLG-001</td>
                        <td>Inappropriate Content</td>
                        <td>User posted offensive content in comments</td>
                        <td>Sarah Johnson</td>
<%--                        <td><span class="priority-high">High</span></td>--%>
                        <td><span class="status-pending">Pending</span></td>
                        <td>2024-01-28</td>
                        <td>
                            <a href="#" class="action-btn btn-view">View</a>
                            <a href="#" class="action-btn btn-resolve">Resolve</a>
                            <a href="#" class="action-btn btn-dismiss">Dismiss</a>
                        </td>
                    </tr>
                    <tr>
                        <td>FLG-002</td>
                        <td>Spam</td>
                        <td>Multiple duplicate posts detected</td>
                        <td>System</td>
<%--                        <td><span class="priority-medium">Medium</span></td>--%>
                        <td><span class="status-pending">Pending</span></td>
                        <td>2024-01-28</td>
                        <td>
                            <a href="#" class="action-btn btn-view">View</a>
                            <a href="#" class="action-btn btn-resolve">Resolve</a>
                            <a href="#" class="action-btn btn-dismiss">Dismiss</a>
                        </td>
                    </tr>
                    <tr>
                        <td>FLG-003</td>
                        <td>Technical Issue</td>
                        <td>Payment processing error reported</td>
                        <td>Mike Wilson</td>
<%--                        <td><span class="priority-high">High</span></td>--%>
                        <td><span class="status-resolved">Resolved</span></td>
                        <td>2024-01-27</td>
                        <td>
                            <a href="#" class="action-btn btn-view">View</a>
                        </td>
                    </tr>
                    <tr>
                        <td>FLG-004</td>
                        <td>User Behavior</td>
                        <td>Harassment complaint</td>
                        <td>Emily Davis</td>
<%--                        <td><span class="priority-medium">Medium</span></td>--%>
                        <td><span class="status-pending">Pending</span></td>
                        <td>2024-01-26</td>
                        <td>
                            <a href="#" class="action-btn btn-view">View</a>
                            <a href="#" class="action-btn btn-resolve">Resolve</a>
                            <a href="#" class="action-btn btn-dismiss">Dismiss</a>
                        </td>
                    </tr>
                    <tr>
                        <td>FLG-005</td>
                        <td>System Bug</td>
                        <td>Login page not loading properly</td>
                        <td>David Brown</td>
<%--                        <td><span class="priority-low">Low</span></td>--%>
                        <td><span class="status-dismissed">Dismissed</span></td>
                        <td>2024-01-25</td>
                        <td>
                            <a href="#" class="action-btn btn-view">View</a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</main>

<script>
    // Search functionality
    document.getElementById('flagSearch').addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();
        const rows = document.querySelectorAll('tbody tr');
        
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            if (text.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });

    // Priority filter functionality
    document.getElementById('priorityFilter').addEventListener('change', function() {
        const selectedPriority = this.value.toLowerCase();
        const rows = document.querySelectorAll('tbody tr');
        
        rows.forEach(row => {
            const priorityCell = row.cells[4].textContent.toLowerCase();
            if (selectedPriority === '' || priorityCell.includes(selectedPriority)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });

    // Status filter functionality
    document.getElementById('statusFilter').addEventListener('change', function() {
        const selectedStatus = this.value.toLowerCase();
        const rows = document.querySelectorAll('tbody tr');
        
        rows.forEach(row => {
            const statusCell = row.cells[5].textContent.toLowerCase();
            if (selectedStatus === '' || statusCell.includes(selectedStatus)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
</script>

<script src="${pageContext.request.contextPath}/pages/dashboards/admindash/dark-mode.js"></script>

</body>
</html>
