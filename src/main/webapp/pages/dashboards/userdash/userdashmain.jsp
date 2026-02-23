<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>

            <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                !"user".equalsIgnoreCase(user.getRole().trim())) { response.sendRedirect(request.getContextPath()
                + "/pages/shared/login.jsp" ); return; } %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>User Dashboard | Daily Fixer</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                </head>

                <body style="margin: 0; padding: 0;">
                    <jsp:include page="sidebar.jsp" />

                    <main class="dashboard-container">
                        <!-- Add standard max-width wrapper if needed -->
                        <div style="max-width: 1200px; margin: 0 auto; width: 100%;">
                            <header class="dashboard-header">
                                <div class="header-content">
                                    <h1>Welcome back, ${sessionScope.currentUser.firstName}! 👋</h1>
                                </div>
                            </header>

                            <div class="stats-container">
                                <div class="stat-card">
                                    <p class="number">3</p>
                                    <p>Active Bookings</p>
                                </div>
                                <div class="stat-card">
                                    <p class="number">5</p>
                                    <p>Total Purchases</p>
                                </div>
                                <div class="stat-card">
                                    <p class="number">2</p>
                                    <p>Pending Deliveries</p>
                                </div>
                            </div>

                            <!-- User Stats -->
                            <div class="user-stats">
                                <h3>User Activity</h3>
                                <div class="stats-grid">
                                    <div class="info-box">
                                        <p><strong>Total Bookings:</strong> 12</p>
                                    </div>
                                    <div class="info-box">
                                        <p><strong>Completed Services:</strong> 8</p>
                                    </div>
                                    <div class="info-box">
                                        <p><strong>Total Spent:</strong> $450</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </main>

                    <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

                </body>

                </html>