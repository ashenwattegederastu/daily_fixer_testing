<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ page import="com.dailyfixer.model.User" %>

                <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                    !"technician".equalsIgnoreCase(user.getRole().trim())) {
                    response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp" ); return; } %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Completed Bookings | Technician | Daily Fixer</title>
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
                                <p>View your past completed service jobs</p>
                            </header>

                            <c:if test="${param.confirmed}">
                                <div
                                    style="padding: 1rem; border-radius: 8px; margin-bottom: 1rem; background: #d1fae5; color: #065f46; font-weight: 500;">
                                    Booking confirmed by the customer!
                                </div>
                            </c:if>

                            <div class="section">
                                <div class="table-container">
                                    <c:choose>
                                        <c:when test="${empty completedBookings}">
                                            <div class="empty-state">
                                                <h3>No Completed Bookings</h3>
                                                <p>Your finished jobs will appear here once they are completed.</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <table>
                                                <thead>
                                                    <tr>
                                                        <th>Service</th>
                                                        <th>Customer</th>
                                                        <th>Date & Time</th>
                                                        <th>Address</th>
                                                        <th>Status</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="b" items="${completedBookings}">
                                                        <tr>
                                                            <td>
                                                                <strong>${b.serviceName}</strong><br>
                                                                <small>${b.problemDescription}</small>
                                                            </td>
                                                            <td>${b.userName}</td>
                                                            <td>
                                                                <fmt:formatDate value="${b.bookingDate}"
                                                                    pattern="MMM dd, yyyy" /><br>
                                                                <fmt:formatDate value="${b.bookingTime}"
                                                                    pattern="hh:mm a" type="time" />
                                                            </td>
                                                            <td>${b.locationAddress}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${b.status eq 'FULLY_COMPLETED'}">
                                                                        <span class="status-badge"
                                                                            style="background: #d1fae5; color: #065f46;">Fully
                                                                            Completed</span>
                                                                    </c:when>
                                                                    <c:when
                                                                        test="${b.status eq 'TECHNICIAN_COMPLETED'}">
                                                                        <span class="status-badge"
                                                                            style="background: #e0e7ff; color: #3730a3;">Awaiting
                                                                            User Confirm</span>
                                                                    </c:when>
                                                                </c:choose>
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