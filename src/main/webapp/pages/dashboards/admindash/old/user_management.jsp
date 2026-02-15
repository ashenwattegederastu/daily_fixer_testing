<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>User Management - DailyFixer</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        table {
            width: 95%;
            margin: 30px auto;
            border-collapse: collapse;
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #0078D7;
            color: white;
        }
        tr:nth-child(even) {
            background: #f9f9f9;
        }
        button {
            padding: 6px 10px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: bold;
        }
        .suspend-btn {
            background-color: #e74c3c;
            color: white;
        }
        .activate-btn {
            background-color: #27ae60;
            color: white;
        }
        .status-active {
            color: green;
            font-weight: bold;
        }
        .status-suspended {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>
<h2 style="text-align:center;">User Management</h2>

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
        <th>Action</th>
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
                <span class="status-${user.status}">${user.status}</span>
            </td>
            <td>
                <form action="${pageContext.request.contextPath}/admin/toggleUserStatus" method="post" style="display:inline;">
                    <input type="hidden" name="userId" value="${user.userId}">
                    <input type="hidden" name="currentStatus" value="${user.status}">
                    <button type="submit"
                            class="${user.status == 'active' ? 'suspend-btn' : 'activate-btn'}">
                            ${user.status == 'active' ? 'Suspend' : 'Activate'}
                    </button>
                </form>
            </td>
        </tr>
    </c:forEach>
    </tbody>
</table>
</body>
</html>
