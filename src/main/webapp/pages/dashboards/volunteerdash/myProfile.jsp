<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />

            <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                !"volunteer".equalsIgnoreCase(user.getRole().trim())) { response.sendRedirect(request.getContextPath()
                + "/pages/shared/login.jsp" ); return; } %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>My Profile | Daily Fixer</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">

                    <style>
                        .container {
                            flex: 1;
                            margin-left: 240px;
                            margin-top: 83px;
                            padding: 30px;
                            background-color: var(--background);
                        }

                        .container h2 {
                            font-size: 1.6em;
                            margin-bottom: 20px;
                            color: var(--foreground);
                        }

                        /* Profile Specific Styles */
                        .profile-card {
                            background: var(--card);
                            border-radius: var(--radius-lg);
                            padding: 30px;
                            box-shadow: var(--shadow-sm);
                            border: 1px solid var(--border);
                            margin-top: 20px;
                        }

                        .profile-header {
                            display: flex;
                            align-items: center;
                            margin-bottom: 30px;
                            padding-bottom: 20px;
                            border-bottom: 1px solid var(--border);
                        }

                        .profile-image {
                            width: 80px;
                            height: 80px;
                            border-radius: 50%;
                            background: var(--muted);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin-right: 20px;
                            font-size: 2em;
                            color: var(--primary);
                            border: 2px solid var(--border);
                        }

                        .profile-info h3 {
                            font-size: 1.5em;
                            margin-bottom: 5px;
                            color: var(--foreground);
                        }

                        .profile-info .role {
                            color: var(--muted-foreground);
                            font-weight: 500;
                            text-transform: capitalize;
                            background: var(--secondary);
                            color: var(--secondary-foreground);
                            padding: 4px 12px;
                            border-radius: 20px;
                            font-size: 0.85em;
                            display: inline-block;
                        }

                        .profile-details {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                            gap: 20px;
                        }

                        .detail-section {
                            background: var(--muted);
                            padding: 20px;
                            border-radius: var(--radius-md);
                            border: 1px solid var(--border);
                        }

                        .detail-section h4 {
                            margin-bottom: 15px;
                            color: var(--primary);
                            font-size: 1.1em;
                            display: flex;
                            align-items: center;
                            gap: 8px;
                        }

                        .detail-row {
                            display: flex;
                            justify-content: space-between;
                            margin-bottom: 12px;
                            padding-bottom: 12px;
                            border-bottom: 1px solid var(--border);
                        }

                        .detail-row:last-child {
                            border-bottom: none;
                            margin-bottom: 0;
                            padding-bottom: 0;
                        }

                        .detail-label {
                            font-weight: 500;
                            color: var(--muted-foreground);
                        }

                        .detail-value {
                            color: var(--foreground);
                            font-weight: 600;
                        }

                        .profile-actions {
                            margin-top: 30px;
                            display: flex;
                            gap: 15px;
                            flex-wrap: wrap;
                            padding-top: 20px;
                            border-top: 1px solid var(--border);
                        }
                    </style>
                </head>

                <body>

                    <header class="topbar">
                        <div class="logo"><fmt:message key="app.name"/></div>
                        <div class="panel-name"><fmt:message key="volunteer.panel"/></div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()"
                                aria-label="Toggle dark mode"><fmt:message key="theme.dark"/></button>
                            <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><fmt:message key="common.logout"/></a>
                        </div>
                    </header>

                    <aside class="sidebar">
                        <h3><fmt:message key="sidebar.navigation"/></h3>
                        <ul>
                            <li><a
                                    href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/volunteerdashmain.jsp"><fmt:message key="volunteer.dashboard"/></a>
                            </li>
                            <li><a href="${pageContext.request.contextPath}/pages/guides/my-guides.jsp"><fmt:message key="volunteer.my_guides"/></a></li>
                            <li><a href="${pageContext.request.contextPath}/guides/create"><fmt:message key="volunteer.create_guide"/></a></li>
                            <li><a href="${pageContext.request.contextPath}/guides"><fmt:message key="volunteer.view_all_guides"/></a></li>
                            <li><a
                                    href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/guideComments.jsp"><fmt:message key="volunteer.guide_comments"/></a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/myProfile.jsp"
                                    class="active"><fmt:message key="volunteer.my_profile"/></a></li>
                        </ul>
<div class="sidebar-actions" style="padding: 15px;">
    <a href="?lang=${sessionScope.sessionLocale.language == 'si' ? 'en' : 'si'}"
       class="action-btn lang-toggle" style="display:block; text-align:center; padding:8px; background:var(--primary); color:var(--primary-foreground); border-radius:var(--radius-md); text-decoration:none; font-weight:600;">
       <fmt:message key="nav.lang_switch"/>
    </a>
</div>
                    </aside>

                    <main class="container">
                        <h2><fmt:message key="volunteer.my_profile"/></h2>
                        <p style="color: var(--muted-foreground); margin-bottom: 25px;">View and manage your volunteer
                            account information</p>

                        <div class="profile-card">
                            <div class="profile-header">
                                <div class="profile-image">
                                    👤
                                </div>
                                <div class="profile-info">
                                    <h3>${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</h3>
                                    <span class="role">${sessionScope.currentUser.role}</span>
                                </div>
                            </div>

                            <div class="profile-details">
                                <div class="detail-section">
                                    <h4>👤 Personal Information</h4>
                                    <div class="detail-row">
                                        <span class="detail-label">User ID</span>
                                        <span class="detail-value">#${sessionScope.currentUser.userId}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">First Name</span>
                                        <span class="detail-value">${sessionScope.currentUser.firstName}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Last Name</span>
                                        <span class="detail-value">${sessionScope.currentUser.lastName}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Username</span>
                                        <span class="detail-value">@${sessionScope.currentUser.username}</span>
                                    </div>
                                </div>

                                <div class="detail-section">
                                    <h4>📞 Contact Information</h4>
                                    <div class="detail-row">
                                        <span class="detail-label">Email</span>
                                        <span class="detail-value">${sessionScope.currentUser.email}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Phone</span>
                                        <span class="detail-value">${sessionScope.currentUser.phoneNumber}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">City</span>
                                        <span class="detail-value">${sessionScope.currentUser.city}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Status</span>
                                        <span class="detail-value" style="color: var(--primary);">Active</span>
                                    </div>
                                </div>
                            </div>

                            <div class="profile-actions">
                                <!-- Note: Linking to existing pages, maintaining original functionality -->
                                <form action="${pageContext.request.contextPath}/resetPassword.jsp" method="get"
                                    style="display: inline;">
                                    <button type="submit" class="btn-secondary">Reset Password</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/editProfile.jsp" method="get"
                                    style="display: inline;">
                                    <button type="submit" class="btn-primary">Edit Account Info</button>
                                </form>
                            </div>
                        </div>
                    </main>

                    <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

                </body>

                </html>