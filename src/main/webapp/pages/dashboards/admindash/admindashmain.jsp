<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />

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
                        <div class="logo"><fmt:message key="app.name"/></div>
                        <div class="panel-name"><fmt:message key="admin.panel"/> </div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()"
                                aria-label="Toggle dark mode"><fmt:message key="theme.dark"/></button>
                            <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><fmt:message key="common.logout"/></a>
                        </div>
                    </header>

                    <aside class="sidebar">
                        <h3><fmt:message key="sidebar.navigation"/></h3>
                        <ul>
                            <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/admindashmain.jsp"
                                    class="active"><fmt:message key="admin.dashboard"/></a></li>
                            <li><a href="${pageContext.request.contextPath}/admin/users"><fmt:message key="admin.user_management"/></a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/flags.jsp">
                                    Flags</a></li>
                            <li><a
                                    href="${pageContext.request.contextPath}/pages/dashboards/admindash/transactions.jsp">
                                    Transactions</a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/guides/admin-list.jsp"><fmt:message key="admin.manage_guides"/></a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/diagnostic-trees.jsp">
                                    Diagnostic Trees</a></li>
                        </ul>
<div class="sidebar-actions" style="padding: 15px;">
    <a href="?lang=${sessionScope.sessionLocale.language == 'si' ? 'en' : 'si'}"
       class="action-btn lang-toggle" style="display:block; text-align:center; padding:8px; background:var(--primary); color:var(--primary-foreground); border-radius:var(--radius-md); text-decoration:none; font-weight:600;">
       <fmt:message key="nav.lang_switch"/>
    </a>
</div>
                    </aside>

                    <main class="main-content">
                        <div class="dashboard-header">
                            <h1><fmt:message key="admin.dashboard"/></h1>
                            <p><fmt:message key="admin.quick_overview"/></p>
                        </div>

                        <!-- Quick Stats -->
                        <div class="stats-container">
                            <div class="stat-card">
                                <div class="number">30</div>
                                <p><fmt:message key="admin.total_visits"/></p>
                            </div>
                            <div class="stat-card">
                                <div class="number">45</div>
                                <p><fmt:message key="admin.transactions_24"/></p>
                            </div>




                            <div class="stat-card">
                                <div class="number">120</div>
                                <p><fmt:message key="admin.total_users"/></p>
                            </div>
                            <%-- <div class="stat-card">--%>
                                <%-- <div class="number">35
                        </div>--%>
                        <%-- <p>Technicians</p>--%>
                            <%-- </div>--%>

                                </div>

                                <!-- Quick Links -->
                                <div class="section">
                                    <h2><fmt:message key="admin.quick_links"/></h2>
                                    <div class="stats-container">
                                        <div class="stat-card">
                                            <p><fmt:message key="admin.view_users"/></p>
                                        </div>
                                        <div class="stat-card">
                                            <p><fmt:message key="admin.view_transactions"/></p>
                                        </div>
                                        <div class="stat-card">
                                            <p><fmt:message key="admin.flags"/></p>
                                        </div>

                                    </div>
                                </div>

                    </main>

                    <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

                </body>

                </html>