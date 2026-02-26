<%@ taglib uri="jakarta.tags.core" prefix="c" %>
    <%@ page import="com.dailyfixer.model.User" %>

        <% User currentUser=(User) session.getAttribute("currentUser"); String firstName=currentUser !=null &&
            currentUser.getFirstName() !=null ? currentUser.getFirstName() : "Technician" ; String lastName=currentUser
            !=null && currentUser.getLastName() !=null ? currentUser.getLastName() : "" ; String username=currentUser
            !=null && currentUser.getUsername() !=null ? currentUser.getUsername() : "tech" ; String
            avatarLetter=firstName.length()> 0 ? firstName.substring(0, 1).toUpperCase() : "T";
            %>
            <link
                    rel="stylesheet"
                    type="text/css"
                    href="${pageContext.request.contextPath}/assets/icons/regular/style.css"
            />
            <link
                    rel="stylesheet"
                    type="text/css"
                    href="${pageContext.request.contextPath}/assets/icons/fill/style.css"
            />
            <style>
                /* Fix HTML/Body height for dashboard */
                html,
                body {
                    height: 100%;
                    margin: 0;
                    padding: 0;
                    background-color: var(--background);
                }

                /* Unified Sidebar styles */
                .sidebar {
                    position: fixed;
                    top: 0;
                    left: 0;
                    bottom: 0;
                    width: 260px;
                    background: var(--card);
                    display: flex;
                    flex-direction: column;
                    box-shadow: var(--shadow-md);
                    z-index: 1000;
                    border-right: 1px solid var(--border);
                    padding: 0 !important;
                    /* Override framework.css 96px top padding */
                    height: 100%;
                }

                .sidebar-header {
                    padding: 24px 20px 16px;
                    border-bottom: 1px solid var(--border);
                    flex-shrink: 0;
                }

                .sidebar-header .logo {
                    font-size: 1.5em;
                    font-weight: 700;
                    color: var(--primary);
                    margin-bottom: 4px;
                }

                .sidebar-header .panel-name {
                    font-size: 0.8em;
                    font-weight: 600;
                    color: var(--muted-foreground);
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                }

                .sidebar-nav {
                    flex: 1;
                    overflow-y: auto;
                    padding: 24px 0;
                    min-height: 0;
                    /* CRITICAL: Allows flex child to shrink and scroll properly */
                }

                .sidebar-nav h3 {
                    padding: 0 20px;
                    margin-bottom: 15px;
                    font-size: 0.85em;
                    color: var(--muted-foreground);
                    text-transform: uppercase;
                    letter-spacing: 1px;
                }

                .sidebar-nav ul {
                    list-style: none;
                    padding: 0;
                    margin: 0;
                }

                .sidebar-nav ul li {
                    margin-bottom: 5px;
                }

                .sidebar-nav ul li a {
                    display: flex;
                    padding: 12px 20px;
                    color: var(--foreground);
                    text-decoration: none;
                    font-weight: 500;
                    transition: all 0.2s;
                    border-left: 3px solid transparent;
                    gap: 10px;
                }

                /* Icon sizing */
                .sidebar-nav ul li a i.ph{
                    font-size: 20px;
                    line-height: 1;
                }

                .sidebar-nav ul li a:hover {
                    background: var(--accent);
                    border-left-color: var(--primary);
                }

                .sidebar-nav ul li a.active {
                    background: var(--accent);
                    border-left-color: var(--primary);
                    font-weight: 600;
                }

                .sidebar-footer {
                    padding: 20px;
                    border-top: 1px solid var(--border);
                    background: var(--card);
                    flex-shrink: 0;
                }

                .user-profile-widget {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    margin-bottom: 15px;
                    padding-bottom: 15px;
                    border-bottom: 1px solid var(--border);
                }

                .user-avatar {
                    width: 40px;
                    height: 40px;
                    border-radius: 50%;
                    background: var(--primary);
                    color: white;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-weight: 600;
                    font-size: 1.1em;
                    flex-shrink: 0;
                }

                .user-info {
                    overflow: hidden;
                }

                .user-name {
                    font-weight: 600;
                    color: var(--foreground);
                    white-space: nowrap;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    font-size: 0.95em;
                    line-height: 1.2;
                }

                .user-handle {
                    font-size: 0.8em;
                    color: var(--muted-foreground);
                    margin-top: 2px;
                }

                .sidebar-actions {
                    display: flex;
                    flex-direction: column;
                    gap: 8px;
                }

                .action-btn {
                    width: 100%;
                    padding: 10px;
                    border-radius: var(--radius-md);
                    border: 1px solid var(--border);
                    background: transparent;
                    color: var(--foreground);
                    font-weight: 600;
                    cursor: pointer;
                    transition: all 0.2s;
                    text-align: center;
                    text-decoration: none;
                    font-size: 0.9em;
                    display: block;
                    box-sizing: border-box;
                }

                .action-btn:hover {
                    background: var(--accent);
                }

                .logout-btn {
                    background: #fef2f2;
                    color: #dc2626;
                    border-color: #fca5a5;
                }

                .logout-btn:hover {
                    background: #fee2e2;
                }

                .dark-mode .logout-btn {
                    background: rgba(220, 38, 38, 0.1);
                    border-color: rgba(220, 38, 38, 0.3);
                    color: #f87171;
                }

                .dark-mode .logout-btn:hover {
                    background: rgba(220, 38, 38, 0.2);
                }

                /* Override old dashboard layout container */
                .dashboard-container {
                    margin-left: 260px !important;
                    margin-top: 0 !important;
                    padding: 30px;
                    background-color: transparent !important;
                    min-height: 100vh;
                }
            </style>

            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo">Daily Fixer</div>
                    <div class="panel-name">Technician View</div>
                </div>

                <div class="sidebar-nav">
                    <h3>Navigation</h3>
                    <ul>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/techniciandashmain.jsp" id="nav-dashboard">
                                <i class="ph ph-presentation-chart"></i>
                                Dashboard
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/serviceListings.jsp" id="nav-services">
                                <i class="ph ph-wrench"></i>
                                Service Listings
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/availability" id="nav-availability">
                                <i class="ph ph-calendar-dots"></i>
                                Set Availability
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/bookings/requests" id="nav-requests">
                                <i class="ph ph-envelope"></i>
                                Booking Requests
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/bookings/calendar" id="nav-calendar">
                                <i class="ph ph-clipboard-text"></i>
                                My Bookings
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/technician/bookings/completed" id="nav-completed">
                                <i class="ph ph-check-square-offset"></i>
                                Completed Bookings
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/chats" id="nav-chats">
                                <i class="ph ph-chats-circle"></i>
                                Chats
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/technicianProfile.jsp" id="nav-profile">
                                <i class="ph ph-user"></i>
                                My Profile
                            </a>
                        </li>
                    </ul>
                </div>

                <div class="sidebar-footer">
                    <div class="user-profile-widget">
                        <div class="user-avatar">
                            <%= avatarLetter %>
                        </div>
                        <div class="user-info">
                            <div class="user-name">
                                <%= firstName %>
                                    <%= lastName %>
                            </div>
                            <div class="user-handle">@<%= username %>
                            </div>
                        </div>
                    </div>

                    <div class="sidebar-actions">
                        <button id="theme-toggle-btn" class="action-btn theme-toggle" onclick="toggleTheme()"
                            aria-label="Toggle dark mode">🌙 Theme Setup</button>
                        <a href="${pageContext.request.contextPath}/logout" class="action-btn logout-btn">
                            <i class="ph ph-sign-out"></i>
                            Log Out
                        </a>
                    </div>
                </div>
            </aside>

            <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

            <script>
                // Highlight active navigation item based on current URL
                document.addEventListener('DOMContentLoaded', function () {
                    const currentPath = window.location.pathname;
                    const navLinks = document.querySelectorAll('.sidebar-nav ul li a');

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
                    } else if (currentPath.includes('/technician/bookings/completed')) {
                        document.getElementById('nav-completed')?.classList.add('active');
                    } else if (currentPath.includes('/chats')) {
                        document.getElementById('nav-chats')?.classList.add('active');
                    }
                });
            </script>