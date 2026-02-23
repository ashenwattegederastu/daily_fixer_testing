<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Chats - Daily Fixer</title>
            <link
                href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
        </head>

        <body style="margin: 0; padding: 0; font-family: 'Inter', sans-serif;">
            <c:choose>
                <c:when test="${sessionScope.currentUser.role == 'technician'}">
                    <jsp:include page="../dashboards/techniciandash/sidebar.jsp" />
                </c:when>
                <c:otherwise>
                    <jsp:include page="../dashboards/userdash/sidebar.jsp" />
                </c:otherwise>
            </c:choose>

            <main class="dashboard-container">
                <div style="max-width: 1200px; margin: 0 auto; width: 100%;">
                    <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem; color: var(--foreground);">My
                        Chats</h1>

                    <c:if test="${empty chats}">
                        <div
                            style="text-align: center; padding: 3rem; background: var(--card); border-radius: var(--radius);">
                            <p style="font-size: 1.125rem; color: var(--muted-foreground);">No chats available.</p>
                        </div>
                    </c:if>

                    <div style="display: grid; gap: 1rem;">
                        <c:forEach var="chat" items="${chats}">
                            <a href="${pageContext.request.contextPath}/chats/view?chatId=${chat.chatId}"
                                style="background: var(--card); border-radius: var(--radius); padding: 1.5rem; box-shadow: var(--shadow-sm); border: 1px solid var(--border); text-decoration: none; display: block; transition: all 0.2s;">
                                <div
                                    style="display: grid; grid-template-columns: 1fr auto; gap: 1rem; align-items: center;">
                                    <div>
                                        <h3
                                            style="font-size: 1.125rem; font-weight: 600; margin-bottom: 0.25rem; color: var(--foreground);">
                                            <c:choose>
                                                <c:when test="${sessionScope.currentUser.role == 'technician'}">
                                                    ${chat.userName}
                                                </c:when>
                                                <c:otherwise>
                                                    ${chat.technicianName}
                                                </c:otherwise>
                                            </c:choose>
                                        </h3>
                                        <p
                                            style="color: var(--muted-foreground); font-size: 0.875rem; margin-bottom: 0.5rem;">
                                            ${chat.serviceName}</p>
                                        <c:if test="${not empty chat.lastMessage}">
                                            <p
                                                style="color: var(--muted-foreground); font-size: 0.875rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                ${chat.lastMessage}
                                            </p>
                                        </c:if>
                                    </div>
                                    <div style="text-align: right;">
                                        <c:if test="${chat.unreadCount > 0}">
                                            <span
                                                style="display: inline-block; background: var(--destructive); color: var(--destructive-foreground); padding: 0.25rem 0.5rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;">
                                                ${chat.unreadCount}
                                            </span>
                                        </c:if>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </main>
        </body>

        </html>