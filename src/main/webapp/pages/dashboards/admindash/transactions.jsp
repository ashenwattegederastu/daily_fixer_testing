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
    <title>Transactions Management | Daily Fixer</title>
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
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/flags.jsp"> Flags</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/transactions.jsp" class="active"> Transactions</a></li>
    </ul>
</aside>

<main class="main-content">
    <div class="dashboard-header">
        <h1>Transactions Management</h1>
        <p>Monitor and manage all financial transactions</p>
    </div>

    <!-- Quick Stats -->
    <div class="stats-container">
        <div class="stat-card">
            <div class="number">45</div>
            <p>Transactions Today</p>
        </div>
        <div class="stat-card">
            <div class="number">Rs.2,450</div>
            <p>Total Revenue Today</p>
        </div>

        <div class="stat-card">
            <div class="number">Rs.18,750</div>
            <p>Total Revenue This Month</p>
        </div>
<%--        <div class="stat-card">--%>
<%--            <div class="number">3</div>--%>
<%--            <p>Failed Transactions</p>--%>
<%--        </div>--%>
    </div>

    <!-- Search and Filter -->
    <div class="search-container">
<%--        <input type="text" class="search-input" placeholder="Search transactions by ID, user, or amount..." id="transactionSearch">--%>
<%--        <select class="filter-select" id="statusFilter">--%>
<%--            <option value="">All Status</option>--%>
<%--            <option value="completed">Completed</option>--%>
<%--            <option value="pending">Pending</option>--%>
<%--            <option value="failed">Failed</option>--%>
<%--            <option value="refunded">Refunded</option>--%>
<%--        </select>--%>
<%--        <select class="filter-select" id="typeFilter">--%>
<%--            <option value="">All Types</option>--%>
<%--            <option value="payment">Payment</option>--%>
<%--            <option value="refund">Refund</option>--%>
<%--            <option value="withdrawal">Withdrawal</option>--%>
<%--        </select>--%>
    </div>

    <!-- Transactions Table -->
    <div class="section">
        <h2>All Transactions</h2>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Transaction ID</th>
                        <th>User</th>
                        <th>Type</th>
                        <th>Amount</th>
<%--                        <th>Status</th>--%>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>TXN-001</td>
                        <td>John Smith</td>
                        <td>Payment</td>
                        <td class="amount positive">+Rs.150.00</td>
<%--                        <td><span class="status-completed">Completed</span></td>--%>
                        <td>2024-01-28 14:30</td>
                        <td>
                            <a href="#" class="action-btn btn-view">View</a>
<%--                            <a href="#" class="action-btn btn-refund">Refund</a>--%>
                        </td>
                    </tr>
                    <tr>
                        <td>TXN-002</td>
                        <td>Sarah Johnson</td>
                        <td>Payment</td>
                        <td class="amount positive">+Rs.75.50</td>
<%--                        <td><span class="status-pending">Pending</span></td>--%>
<%--                        <td><span class="status-completed">Completed</span></td>--%>
                        <td>2024-01-28 13:15</td>
                        <td>
                            <a href="#" class="action-btn btn-view">View</a>
<%--                            <a href="#" class="action-btn btn-cancel">Cancel</a>--%>
                        </td>
                    </tr>
<%--                    <tr>--%>
<%--                        <td>TXN-003</td>--%>
<%--                        <td>Mike Wilson</td>--%>
<%--                        <td>Refund</td>--%>
<%--                        <td class="amount negative">-$50.00</td>--%>
<%--                        <td><span class="status-completed">Completed</span></td>--%>
<%--                        <td>2024-01-28 12:45</td>--%>
<%--                        <td>--%>
<%--                            <a href="#" class="action-btn btn-view">View</a>--%>
<%--                        </td>--%>
<%--                    </tr>--%>
                    <tr>
                        <td>TXN-004</td>
                        <td>Emily Davis</td>
                        <td>Payment</td>
                        <td class="amount positive">+Rs.200.00</td>
<%--                        <td><span class="status-failed">Failed</span></td>--%>
<%--                        <td><span class="status-completed">Completed</span></td>--%>
                        <td>2024-01-28 11:20</td>
                        <td>
                            <a href="#" class="action-btn btn-view">View</a>
<%--                            <a href="#" class="action-btn btn-refund">Retry</a>--%>
                        </td>
                    </tr>
<%--                    <tr>--%>
<%--                        <td>TXN-005</td>--%>
<%--                        <td>David Brown</td>--%>
<%--                        <td>Withdrawal</td>--%>
<%--                        <td class="amount negative">-$300.00</td>--%>
<%--                        <td><span class="status-refunded">Refunded</span></td>--%>
<%--                        <td>2024-01-27 16:30</td>--%>
<%--                        <td>--%>
<%--                            <a href="#" class="action-btn btn-view">View</a>--%>
<%--                        </td>--%>
<%--                    </tr>--%>
                    <tr>
                        <td>TXN-006</td>
                        <td>Alice Cooper</td>
                        <td>Payment</td>
                        <td class="amount positive">+Rs.125.75</td>
<%--                        <td><span class="status-completed">Completed</span></td>--%>
                        <td>2024-01-27 15:10</td>
                        <td>
                            <a href="#" class="action-btn btn-view">View</a>
<%--                            <a href="#" class="action-btn btn-refund">Refund</a>--%>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</main>

<script>
    // Search functionality
    document.getElementById('transactionSearch').addEventListener('input', function() {
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

    // Status filter functionality
    document.getElementById('statusFilter').addEventListener('change', function() {
        const selectedStatus = this.value.toLowerCase();
        const rows = document.querySelectorAll('tbody tr');
        
        rows.forEach(row => {
            const statusCell = row.cells[4].textContent.toLowerCase();
            if (selectedStatus === '' || statusCell.includes(selectedStatus)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });

    // Type filter functionality
    document.getElementById('typeFilter').addEventListener('change', function() {
        const selectedType = this.value.toLowerCase();
        const rows = document.querySelectorAll('tbody tr');
        
        rows.forEach(row => {
            const typeCell = row.cells[2].textContent.toLowerCase();
            if (selectedType === '' || typeCell.includes(selectedType)) {
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
