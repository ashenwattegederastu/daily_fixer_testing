<%@ taglib uri="jakarta.tags.core" prefix="c" %>
    <header class="topbar">
        <div class="logo">Daily Fixer</div>
        <div class="panel-name">User Panel</div>
        <div style="display: flex; align-items: center; gap: 10px;">
            <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙
                Dark</button>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn-secondary">Home</a>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
        </div>
    </header>
    <aside class="sidebar">
        <h3>Navigation</h3>
        <ul>
            <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/userdashmain.jsp"
                    id="nav-user-dashboard">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/notifications.jsp"
                    id="nav-user-notifications">Notifications</a></li>
            <li>
                <div
                    style="padding: 10px 15px; color: var(--muted-foreground); font-weight: 600; font-size: 0.9em; text-transform: uppercase; letter-spacing: 0.05em;">
                    Bookings</div>
                <ul style="margin-left: 10px; list-style: none; padding: 0;">
                    <li><a href="${pageContext.request.contextPath}/user/bookings/active"
                            id="nav-user-bookings-active">Active Bookings</a></li>
                    <li><a href="${pageContext.request.contextPath}/user/bookings/completed"
                            id="nav-user-bookings-completed">Completed Bookings</a></li>
                    <li><a href="${pageContext.request.contextPath}/user/bookings/cancelled"
                            id="nav-user-bookings-cancelled">Cancelled Bookings</a></li>
                </ul>
            </li>
            <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myPurchases.jsp"
                    id="nav-user-purchases">My Purchases</a></li>
            <li><a href="${pageContext.request.contextPath}/chats" id="nav-user-chats">Chats</a></li>
            <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myProfile.jsp"
                    id="nav-user-profile">My Profile</a></li>
        </ul>
    </aside>

    <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

    <script>
        // Highlight active navigation item based on current URL
        document.addEventListener('DOMContentLoaded', function () {
            const currentPath = window.location.pathname;
            const navLinks = document.querySelectorAll('.sidebar ul li a');

            navLinks.forEach(link => {
                const linkPath = new URL(link.href).pathname;
                if (currentPath.includes(linkPath) || currentPath === linkPath) {
                    link.classList.add('active');
                }
            });

            if (currentPath.includes('/chats')) {
                document.getElementById('nav-user-chats')?.classList.add('active');
            }
        });
    </script>