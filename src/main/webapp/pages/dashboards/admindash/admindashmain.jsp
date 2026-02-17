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
                </head>

                <body>

                    <header class="topbar">
                        <div class="logo">Daily Fixer</div>
                        <div class="panel-name">Admin Panel </div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()"
                                aria-label="Toggle dark mode">🌙 Dark</button>
                            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
                        </div>
                    </header>

                    <aside class="sidebar">
                        <h3>Navigation</h3>
                        <ul>
                            <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/admindashmain.jsp"
                                    class="active"> Dashboard</a></li>
                            <li><a href="${pageContext.request.contextPath}/admin/store-dashboard"> Store Dashboard</a>
                            </li>
                            <li><a href="${pageContext.request.contextPath}/admin/products"> Manage Products</a></li>
                            <li><a href="${pageContext.request.contextPath}/admin/users"> User Management</a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/flags.jsp">
                                    Flags</a></li>
                            <li><a
                                    href="${pageContext.request.contextPath}/pages/dashboards/admindash/transactions.jsp">
                                    Transactions</a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/guides/admin-list.jsp"> Manage
                                    Guides</a></li>
                            <li><a
                                    href="${pageContext.request.contextPath}/pages/dashboards/admindash/diagnostic-trees.jsp">
                                    Diagnostic Trees</a></li>
                        </ul>
                    </aside>

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