<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - DailyFixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
</head>
<body>

<div class="login-container">
    <div style="position: fixed; top: 20px; right: 20px; z-index: 1000;">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode"><fmt:message key="theme.dark"/></button>
    </div>
    <div class="login-card">
        <!-- Added logo/branding section -->
        <div class="login-header">
            <h1 class="login-title"><fmt:message key="auth.dailyfixer"/></h1>
            <p class="login-subtitle"><fmt:message key="auth.welcome_back"/></p>
        </div>

        <!-- Improved message styling with better visual hierarchy -->
        <% String success = (String) session.getAttribute("successMsg");
            if (success != null) { %>
        <div class="alert alert-success"><%= success %></div>
        <% session.removeAttribute("successMsg"); } %>

        <% String loginError = (String) request.getAttribute("loginError");
            if (loginError != null) { %>
        <div class="alert alert-error"><%= loginError %></div>
        <% } %>

        <form method="post" action="login" class="login-form">
            <div class="form-group">
                <label for="username" class="form-label"><fmt:message key="auth.username"/></label>
                <input
                        type="text"
                        id="username"
                        name="username"
                        class="form-input"
                        placeholder="Enter your username"
                        required>
            </div>

            <div class="form-group">
                <label for="password" class="form-label"><fmt:message key="auth.password"/></label>
                <input
                        type="password"
                        id="password"
                        name="password"
                        class="form-input"
                        placeholder="Enter your password"
                        required>
            </div>

            <!-- Improved button styling -->
            <button type="submit" class="login-btn"><fmt:message key="auth.sign_in"/></button>
        </form>

        <!-- Better organized footer links with improved styling -->
        <div class="login-footer">
            <p class="footer-text">
                <fmt:message key="auth.no_account"/>
                <a href="${pageContext.request.contextPath}/preliminarySignup.jsp" class="footer-link"><fmt:message key="auth.create_one"/></a>
            </p>
            <p class="footer-text">
                <a href="${pageContext.request.contextPath}/forgot_password.jsp" class="footer-link"><fmt:message key="auth.forgot_password"/></a>
            </p>
            <p class="footer-text">
                <a href="${pageContext.request.contextPath}/index.jsp" class="footer-link-secondary"><fmt:message key="auth.back_home"/></a>
            </p>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>

</body>
</html>
