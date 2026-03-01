<%@ taglib uri="jakarta.tags.core" prefix="c" %>
    <%@ page session="true" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />


        <link
            href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
            rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">

        <!-- Navigation -->
        <nav id="navbar" class="public-nav">
            <div class="nav-container">
                <div class="hamburger" id="hamburger-btn">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
                <a href="${pageContext.request.contextPath}/index.jsp" class="logo"><fmt:message key="app.name"/></a>



                <ul class="nav-links" id="nav-links">
                    <li><a href="${pageContext.request.contextPath}/pages/diagnostic/diagnostic-browse.jsp"><fmt:message key="nav.diagnostic"/></a></li>
                    <li><a href="${pageContext.request.contextPath}/guides"><fmt:message key="nav.guides"/></a></li>
                    <li><a href="${pageContext.request.contextPath}/findtech.jsp"><fmt:message key="nav.book_tech"/></a></li>
                    <li><a href="${pageContext.request.contextPath}/store_main.jsp"><fmt:message key="nav.store"/></a></li>
                </ul>

                <!-- Dynamic Login/Logout -->
                <div class="nav-buttons">
                    <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()"
                        aria-label="Toggle dark mode"><fmt:message key="theme.dark"/></button>
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser}">
                            <!-- User is logged in -->
                            <a href="${pageContext.request.contextPath}/pages/dashboards/${sessionScope.currentUser.role}dash/${sessionScope.currentUser.role}dashmain.jsp"
                                class="btn-login">
                                <fmt:message key="nav.hi"/>, ${sessionScope.currentUser.firstName}
                            </a>
                            <a href="${pageContext.request.contextPath}/logout" class="btn-logout"><fmt:message key="nav.logout"/></a>
                        </c:when>
                        <c:otherwise>
                            <!-- Guest -->
                            <a href="${pageContext.request.contextPath}/login.jsp" class="btn-login"><fmt:message key="nav.login"/></a>
                            <a href="${pageContext.request.contextPath}/preliminarySignup.jsp" class="btn-signup"><fmt:message key="nav.signup"/></a>
                        </c:otherwise>
                    </c:choose>
                    <a href="?lang=${empty sessionScope.sessionLocale or sessionScope.sessionLocale.language == 'en' ? 'si' : 'en'}"
                       class="action-btn lang-toggle">
                       <fmt:message key="nav.lang_switch"/>
                    </a>
                </div>
            </div>
        </nav>

        <script>
            // Navbar scroll effect
            const navbar = document.getElementById('navbar');
            window.addEventListener('scroll', () => {
                if (window.scrollY > 50) {
                    navbar.classList.add('scrolled');
                } else {
                    navbar.classList.remove('scrolled');
                }
            });

            // Mobile Menu Toggle
            const hamburger = document.getElementById('hamburger-btn');
            const navLinks = document.getElementById('nav-links');

            hamburger.addEventListener('click', () => {
                navLinks.classList.toggle('active');
                hamburger.classList.toggle('active');
            });
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>