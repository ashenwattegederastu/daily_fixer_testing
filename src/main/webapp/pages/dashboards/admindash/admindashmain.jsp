<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>

            <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                !"admin".equalsIgnoreCase(user.getRole().trim())) { response.sendRedirect(request.getContextPath()
                + "/pages/shared/login.jsp" ); return; } %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Admin Dashboard | Daily Fixer</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                    <style>
                        /* Main content offset for new sidebar */
                        .main-content {
                            flex: 1;
                            margin-left: 240px;
                            margin-top: 83px;
                            padding: 40px 30px;
                        }

                        @media (max-width: 900px) {
                            .main-content {
                                margin-left: 0 !important;
                                margin-top: 60px !important;
                                padding-top: 40px !important;
                            }
                        }
                    </style>
                </head>

                <body>

                    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

                    <main class="main-content">
                        <div class="dashboard-header">
                            <h1>Dashboard</h1>
                            <p>Quick System Overview</p>
                        </div>

                        <!-- Quick Stats -->
                        <div class="stats-container">
                            <div class="stat-card">
                                <div class="number">30</div>
                                <p>Total site visits within last 24 hrs</p>
                            </div>
                            <div class="stat-card">
                                <div class="number">45</div>
                                <p>Transactions in the last 24 hrs</p>
                            </div>




                            <div class="stat-card">
                                <div class="number">120</div>
                                <p>Total Users</p>
                            </div>
                            <%-- <div class="stat-card">--%>
                                <%-- <div class="number">35
                        </div>--%>
                        <%-- <p>Technicians</p>--%>
                            <%-- </div>--%>

                                </div>

                                <!-- Quick Links -->
                                <div class="section">
                                    <h2>Quick Links</h2>
                                    <div class="stats-container">
                                        <div class="stat-card">
                                            <p>View Users</p>
                                        </div>
                                        <div class="stat-card">
                                            <p>View Transactions</p>
                                        </div>
                                        <div class="stat-card">
                                            <p>Flags</p>
                                        </div>

                                    </div>
                                </div>

                    </main>

                    <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

                </body>

                </html>