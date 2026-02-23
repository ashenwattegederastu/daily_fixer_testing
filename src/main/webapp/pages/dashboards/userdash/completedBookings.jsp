<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
                <%@ page import="com.dailyfixer.model.User" %>

                    <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                        !"user".equalsIgnoreCase(user.getRole().trim())) {
                        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp" ); return; } %>
                        <!DOCTYPE html>
                        <html lang="en">

                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>Completed Bookings | Daily Fixer</title>
                            <link
                                href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                                rel="stylesheet">
                            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                        </head>

                        <body class="dashboard-layout">
                            <jsp:include page="sidebar.jsp" />

                            <main class="dashboard-container">
                                <header class="dashboard-header">
                                    <h1>Completed Bookings</h1>
                                    <p>Review your past successful service requests</p>
                                </header>

                                <div class="section">
                                    <div class="table-container">
                                        <c:choose>
                                            <c:when test="${empty completedBookings}">
                                                <div class="empty-state">
                                                    <h3>No Completed Bookings</h3>
                                                    <p>Your finished bookings will appear here.</p>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
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
                                                        <c:forEach var="b" items="${completedBookings}">
                                                            <tr>
                                                                <td><strong>${b.serviceName}</strong><br><small>${b.problemDescription}</small>
                                                                </td>
                                                                <td>${b.technicianName}</td>
                                                                <td>
                                                                    <fmt:formatDate value="${b.bookingDate}"
                                                                        pattern="MMM dd, yyyy" /><br>
                                                                    <fmt:formatDate value="${b.bookingTime}"
                                                                        pattern="hh:mm a" type="time" />
                                                                </td>
                                                                <td>${b.locationAddress}</td>
                                                                <td><span class="status-badge"
                                                                        style="background: #dbeafe; color: #1e40af;">Completed</span>
                                                                </td>
                                                                <td>
                                                                    <div class="action-buttons">
                                                                        <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/writeReview.jsp?item=${b.bookingId}"
                                                                            class="btn-secondary"
                                                                            style="padding: 4px 10px; font-size: 0.8em;">Review</a>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </main>

                            <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
                        </body>

                        </html>