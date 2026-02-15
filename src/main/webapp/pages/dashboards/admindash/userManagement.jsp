<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null || !"admin".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Management | Daily Fixer</title>
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
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/admindashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/users" class="active">User Management</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/flags.jsp">Flags</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/transactions.jsp">Transactions</a></li>
    </ul>
</aside>

<main class="main-content">
    <div class="dashboard-header">
        <h1>User Management</h1>
        <p>Manage all platform users and their roles.</p>
    </div>

    <!-- Search + Filters -->
    <div class="search-container">
        <input type="text" id="userSearch" class="search-input" placeholder="Search users by name, email, or username...">
        <select id="roleFilter" class="filter-select">
            <option value="">All Roles</option>
            <option value="admin">Admin</option>
            <option value="technician">Technician</option>
            <option value="volunteer">Volunteer</option>
            <option value="driver">Driver</option>
            <option value="store">Store</option>
            <option value="user">User</option>
        </select>
        <select id="statusFilter" class="filter-select">
            <option value="">All Status</option>
            <option value="active">Active</option>
            <option value="suspended">Suspended</option>
        </select>
    </div>

    <div class="table-container">
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Username</th>
                <th>Email</th>
                <th>Phone</th>
                <th>City</th>
                <th>Role</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="user" items="${users}">
                <tr>
                    <td>${user.userId}</td>
                    <td>${user.firstName} ${user.lastName}</td>
                    <td>${user.username}</td>
                    <td>${user.email}</td>
                    <td>${user.phoneNumber}</td>
                    <td>${user.city}</td>
                    <td>${user.role}</td>
                    <td>
                        <span class="status-${user.status}">
                                ${user.status}
                        </span>
                    </td>
                    <td>
                        <form action="${pageContext.request.contextPath}/admin/toggleUserStatus" method="post" style="display:inline;">
                            <input type="hidden" name="userId" value="${user.userId}">
                            <input type="hidden" name="currentStatus" value="${user.status}">
                            <button type="submit" class="action-btn ${user.status == 'active' ? 'btn-suspend' : 'btn-activate'}">
                                    ${user.status == 'active' ? 'Suspend' : 'Activate'}
                            </button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</main>

<script>
    // Search and filter logic
    const searchInput = document.getElementById('userSearch');
    const roleFilter = document.getElementById('roleFilter');
    const statusFilter = document.getElementById('statusFilter');

    function filterTable() {
        const term = searchInput.value.toLowerCase();
        const role = roleFilter.value.toLowerCase();
        const status = statusFilter.value.toLowerCase();
        const rows = document.querySelectorAll('tbody tr');

        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            const roleText = row.cells[6].textContent.toLowerCase();
            const statusText = row.cells[7].textContent.toLowerCase();

            const matchesSearch = text.includes(term);
            const matchesRole = !role || roleText.includes(role);
            const matchesStatus = !status || statusText.includes(status);

            row.style.display = (matchesSearch && matchesRole && matchesStatus) ? '' : 'none';
        });
    }

    searchInput.addEventListener('input', filterTable);
    roleFilter.addEventListener('change', filterTable);
    statusFilter.addEventListener('change', filterTable);
</script>

<script src="${pageContext.request.contextPath}/pages/dashboards/admindash/dark-mode.js"></script>

</body>
</html>