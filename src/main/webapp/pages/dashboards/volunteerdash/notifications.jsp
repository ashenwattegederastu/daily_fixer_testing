<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
  User currentUser = (User) session.getAttribute("currentUser");
  if (currentUser == null || !"volunteer".equalsIgnoreCase(currentUser.getRole())) {
    response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
    return;
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Notifications | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
    --panel-color: #dcdaff;
    --accent: #8b95ff;
    --text-dark: #000000;
    --text-secondary: #333333;
    --shadow-sm: 0 4px 12px rgba(0,0,0,0.12);
    --shadow-md: 0 8px 24px rgba(0,0,0,0.18);
    --shadow-lg: 0 12px 36px rgba(0,0,0,0.22);
}

/* Reset */
* { margin:0; padding:0; box-sizing:border-box; }
body {
    font-family: 'Inter', sans-serif;
    background-color: #ffffff;
    color: var(--text-dark);
    display: flex;
    min-height: 100vh;
}

/* Top Navbar */
.topbar {
    position: fixed;
    top:0; left:0; right:0;
    height:76px;
    background-color: var(--panel-color);
    border-bottom: 1px solid rgba(0,0,0,0.1);
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 30px;
    z-index: 200;
    box-shadow: var(--shadow-md);
}
.topbar .logo { font-size: 1.5em; font-weight: 700; color: var(--accent); }
.topbar .panel-name { font-weight: 600; flex:1; text-align:center; color: var(--text-dark); }
.topbar .logout-btn {
    padding: 0.6rem 1.2rem;
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
    border: none;
    color: #fff;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    box-shadow: var(--shadow-sm);
    text-decoration: none;
}
.topbar .logout-btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}

/* Sidebar */
.sidebar {
    width: 240px;
    background-color: var(--panel-color);
    height: 100vh;
    position: fixed;
    top:0;
    left:0;
    padding-top: 96px;
    box-shadow: var(--shadow-md);
    overflow-y: auto;
    z-index: 100;
}
.sidebar h3 { padding: 0 20px 12px; font-size: 0.85em; color: var(--text-dark); text-transform: uppercase; }
.sidebar ul { list-style:none; }
.sidebar a {
    display:block;
    padding:12px 20px;
    text-decoration:none;
    color: var(--text-dark);
    font-weight:500;
    border-left:3px solid transparent;
    border-radius:0 8px 8px 0;
    margin-bottom:4px;
    transition: all 0.2s;
}
.sidebar a:hover, .sidebar a.active {
    background-color: #f0f0ff;
    border-left-color: var(--accent);
}

/* Main Content */
.container {
    flex:1;
    margin-left:240px;
    margin-top:83px;
    padding:30px;
}
.container h2 {
    font-size:1.6em;
    margin-bottom:20px;
    color: #000000;
}

/* Notification Cards */
.notification-container {
    display: grid;
    grid-template-columns: 1fr;
    gap: 15px;
    margin-top: 20px;
}

.notification-card {
    background: #fff;
    border-radius: 12px;
    padding: 20px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    transition: transform 0.2s ease;
    position: relative;
}

.notification-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.notification-card.unread {
    border-left: 4px solid var(--accent);
    background: #f8f9ff;
}

.notification-card.read {
    opacity: 0.7;
}

.notification-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
}

.notification-title {
    font-weight: 600;
    font-size: 1.1em;
    color: var(--text-dark);
}

.notification-time {
    font-size: 0.9em;
    color: var(--text-secondary);
}

.notification-body {
    color: var(--text-secondary);
    line-height: 1.5;
    margin-bottom: 15px;
}

.notification-type {
    display: inline-block;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 0.8em;
    font-weight: 500;
    text-transform: uppercase;
}

.notification-type.comment {
    background: #e3f2fd;
    color: #1976d2;
}

.notification-type.deletion {
    background: #ffebee;
    color: #d32f2f;
}

.notification-type.rating {
    background: #f3e5f5;
    color: #7b1fa2;
}

.notification-type.system {
    background: #e8f5e8;
    color: #388e3c;
}

.notification-actions {
    display: flex;
    gap: 10px;
    margin-top: 15px;
}

.notification-btn {
    padding: 6px 12px;
    border-radius: 6px;
    color: white;
    font-weight: 500;
    text-decoration: none;
    transition: all 0.2s;
    font-size: 0.9em;
}

.notification-btn.primary {
    background: var(--accent);
}
.notification-btn.primary:hover {
    background: #7a85e6;
    transform: translateY(-1px);
}

.notification-btn.secondary {
    background: #6c757d;
}
.notification-btn.secondary:hover {
    background: #5a6268;
    transform: translateY(-1px);
}

.mark-all-read {
    display: inline-block;
    margin-bottom: 20px;
    padding: 10px 20px;
    background: var(--accent);
    color: white;
    font-weight: 500;
    border-radius: 8px;
    text-decoration: none;
    transition: all 0.2s;
    box-shadow: var(--shadow-sm);
}

.mark-all-read:hover {
    background: #7a85e6;
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.empty-state {
    text-align: center;
    padding: 40px;
    color: var(--text-secondary);
    font-size: 1.1em;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Volunteer Panel</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/volunteerdashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/myguides.jsp">My Guides</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/guideComments.jsp">Guide Comments</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/notifications.jsp" class="active">Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/addGuide.jsp">Add Guide</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Notifications</h2>
    <a href="#" class="mark-all-read" onclick="markAllAsRead()">Mark All as Read</a>

    <div class="notification-container">
        <!-- New Comment Notification -->
        <div class="notification-card unread">
            <div class="notification-header">
                <div class="notification-title">
                    <span class="notification-type comment">Comment</span>
                    New Comment on "How to Fix a Leaky Faucet"
                </div>
                <div class="notification-time">2 hours ago</div>
            </div>
            <div class="notification-body">
                John Doe left a comment on your guide: "This was really helpful! Thank you for the detailed steps."
            </div>
            <div class="notification-actions">
                <a href="${pageContext.request.contextPath}/ViewGuideCommentsServlet?guideId=1" class="notification-btn primary">View Comments</a>
                <a href="#" class="notification-btn secondary" onclick="markAsRead(this)">Mark as Read</a>
            </div>
        </div>

        <!-- Guide Deletion Notification -->
        <div class="notification-card unread">
            <div class="notification-header">
                <div class="notification-title">
                    <span class="notification-type deletion">Deletion</span>
                    Guide Removed by Admin
                </div>
                <div class="notification-time">1 day ago</div>
            </div>
            <div class="notification-body">
                Your guide "Quick Home Repairs" has been removed by an administrator for violating community guidelines.
            </div>
            <div class="notification-actions">
                <a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/myguides.jsp" class="notification-btn primary">View My Guides</a>
                <a href="#" class="notification-btn secondary" onclick="markAsRead(this)">Mark as Read</a>
            </div>
        </div>

        <!-- Rating Notification -->
        <div class="notification-card read">
            <div class="notification-header">
                <div class="notification-title">
                    <span class="notification-type rating">Rating</span>
                    New Rating Received
                </div>
                <div class="notification-time">3 days ago</div>
            </div>
            <div class="notification-body">
                Sarah Johnson rated your guide "DIY Painting Tips" 5 stars and left a positive review.
            </div>
            <div class="notification-actions">
                <a href="${pageContext.request.contextPath}/ViewGuideServlet?id=3" class="notification-btn primary">View Guide</a>
            </div>
        </div>

        <!-- System Notification -->
        <div class="notification-card read">
            <div class="notification-header">
                <div class="notification-title">
                    <span class="notification-type system">System</span>
                    Welcome to Daily Fixer!
                </div>
                <div class="notification-time">1 week ago</div>
            </div>
            <div class="notification-body">
                Thank you for joining Daily Fixer as a volunteer! Start creating helpful guides to assist users with their daily repair needs.
            </div>
            <div class="notification-actions">
                <a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/addGuide.jsp" class="notification-btn primary">Create Guide</a>
            </div>
        </div>

        <!-- Another Comment Notification -->
        <div class="notification-card read">
            <div class="notification-header">
                <div class="notification-title">
                    <span class="notification-type comment">Comment</span>
                    New Comment on "Garden Maintenance Guide"
                </div>
                <div class="notification-time">1 week ago</div>
            </div>
            <div class="notification-body">
                Mike Wilson asked a question about your guide: "What type of fertilizer do you recommend for roses?"
            </div>
            <div class="notification-actions">
                <a href="${pageContext.request.contextPath}/ViewGuideCommentsServlet?guideId=2" class="notification-btn primary">Reply to Comment</a>
            </div>
        </div>
    </div>
</main>

<script>
function markAsRead(element) {
    const card = element.closest('.notification-card');
    card.classList.remove('unread');
    card.classList.add('read');
    element.style.display = 'none';
}

function markAllAsRead() {
    const unreadCards = document.querySelectorAll('.notification-card.unread');
    unreadCards.forEach(card => {
        card.classList.remove('unread');
        card.classList.add('read');
        const markReadBtn = card.querySelector('.notification-btn.secondary');
        if (markReadBtn) {
            markReadBtn.style.display = 'none';
        }
    });
}
</script>

</body>
</html>
