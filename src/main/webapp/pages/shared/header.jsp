<%@ taglib uri="jakarta.tags.core" prefix="c" %>
    <%@ page session="true" %>


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
                <a href="${pageContext.request.contextPath}/index.jsp" class="logo">Daily Fixer</a>



                <ul class="nav-links" id="nav-links">
                    <li><a href="${pageContext.request.contextPath}/pages/diagnostic/diagnostic-browse.jsp">Diagnostic
                            Tool</a></li>
                    <li><a href="${pageContext.request.contextPath}/guides">View Repair Guides</a></li>
                    <li><a href="${pageContext.request.contextPath}/findtech.jsp">Book a Technician</a></li>
                    <li><a href="${pageContext.request.contextPath}/store_main.jsp">Store</a></li>
                </ul>

                <!-- Dynamic Login/Logout -->
                <div class="nav-buttons">
                    <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()"
                        aria-label="Toggle dark mode">🌙 Dark</button>
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser}">
                            <!-- User is logged in -->
                            <a href="${pageContext.request.contextPath}/pages/dashboards/${sessionScope.currentUser.role}dash/${sessionScope.currentUser.role}dashmain.jsp"
                                class="btn-login">
                                Hi, ${sessionScope.currentUser.firstName}
                            </a>
                            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
                        </c:when>
                        <c:otherwise>
                            <!-- Guest -->
                            <a href="${pageContext.request.contextPath}/login.jsp" class="btn-login">Login</a>
                            <a href="${pageContext.request.contextPath}/preliminarySignup.jsp" class="btn-signup">Sign
                                Up</a>
                        </c:otherwise>
                    </c:choose>
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