<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<style>
/* Sidebar styles */
.topbar {
    position: fixed;
    top:0; left:0; right:0;
    height:80px;
    background: var(--card);
    display:flex;
    align-items:center;
    justify-content:space-between;
    padding:0 30px;
    box-shadow: var(--shadow-sm);
    z-index:1000;
    border-bottom: 1px solid var(--border);
}
.topbar .logo {
    font-size:1.5em;
    font-weight:700;
    color: var(--primary);
}
.topbar .panel-name {
    font-weight:600;
    color: var(--foreground);
}
.topbar .logout-btn {
    background: var(--destructive);
    color: var(--destructive-foreground);
    padding:10px 20px;
    border-radius: var(--radius-md);
    text-decoration:none;
    font-weight:600;
}

.sidebar {
    position:fixed;
    top:80px; left:0; bottom:0;
    width:240px;
    background: var(--card);
    padding:20px 0;
    box-shadow: var(--shadow-sm);
    overflow-y:auto;
    border-right: 1px solid var(--border);
}
.sidebar h3 {
    padding:0 20px;
    margin-bottom:15px;
    font-size:0.9em;
    color: var(--muted-foreground);
    text-transform:uppercase;
    letter-spacing:1px;
}
.sidebar ul {
    list-style:none;
}
.sidebar ul li {
    margin-bottom:5px;
}
.sidebar ul li a {
    display:block;
    padding:12px 20px;
    color: var(--foreground);
    text-decoration:none;
    transition: all 0.2s;
    border-left: 3px solid transparent;
}
.sidebar ul li a:hover {
    background: var(--accent);
    border-left-color: var(--primary);
}
.sidebar ul li a.active {
    background: var(--accent);
    border-left-color: var(--primary);
    font-weight:600;
}

.dashboard-container {
    margin-left:240px;
    margin-top:80px;
    padding:30px;
    background-color: var(--background);
    min-height: calc(100vh - 80px);
}
</style>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Technician Dashboard</div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/techniciandashmain.jsp" id="nav-dashboard">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/availability" id="nav-availability">Set Availability</a></li>
        <li><a href="${pageContext.request.contextPath}/bookings/requests" id="nav-requests">Booking Requests</a></li>
        <li><a href="${pageContext.request.contextPath}/bookings/calendar" id="nav-calendar">My Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/chats" id="nav-chats">Chats</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/serviceListings.jsp" id="nav-services">Service Listings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/myProfile.jsp" id="nav-profile">My Profile</a></li>
    </ul>
</aside>

<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

<script>
// Highlight active navigation item based on current URL
document.addEventListener('DOMContentLoaded', function() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.sidebar ul li a');
    
    navLinks.forEach(link => {
        const linkPath = new URL(link.href).pathname;
        if (currentPath.includes(linkPath) || currentPath === linkPath) {
            link.classList.add('active');
        }
    });
    
    // Special handling for servlet paths
    if (currentPath.includes('/availability')) {
        document.getElementById('nav-availability')?.classList.add('active');
    } else if (currentPath.includes('/bookings/requests')) {
        document.getElementById('nav-requests')?.classList.add('active');
    } else if (currentPath.includes('/bookings/calendar')) {
        document.getElementById('nav-calendar')?.classList.add('active');
    } else if (currentPath.includes('/chats')) {
        document.getElementById('nav-chats')?.classList.add('active');
    }
});
</script>
