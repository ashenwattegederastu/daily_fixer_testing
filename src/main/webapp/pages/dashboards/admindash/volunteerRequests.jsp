<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>

            <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                !"admin".equalsIgnoreCase(user.getRole().trim())) { response.sendRedirect(request.getContextPath()
                + "/pages/shared/login.jsp" ); return; } %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <title>Volunteer Requests | Daily Fixer Admin</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet"
                        href="${pageContext.request.contextPath}/pages/dashboards/admindash/admin-theme.css">
                    <style>
                        .badge-count {
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            background: linear-gradient(135deg, #7c3aed, #a78bfa);
                            color: white;
                            font-size: 0.75rem;
                            font-weight: 700;
                            min-width: 22px;
                            height: 22px;
                            border-radius: 11px;
                            padding: 0 6px;
                            margin-left: 8px;
                        }

                        .status-badge {
                            padding: 4px 10px;
                            border-radius: 6px;
                            font-size: 0.8rem;
                            font-weight: 600;
                            text-transform: uppercase;
                        }

                        .status-PENDING {
                            background: #fef3c7;
                            color: #92400e;
                        }

                        .status-APPROVED {
                            background: #d1fae5;
                            color: #065f46;
                        }

                        .status-REJECTED {
                            background: #fee2e2;
                            color: #991b1b;
                        }

                        .expertise-tags {
                            display: flex;
                            flex-wrap: wrap;
                            gap: 4px;
                        }

                        .expertise-tag {
                            background: #ede9fe;
                            color: #6d28d9;
                            padding: 2px 8px;
                            border-radius: 4px;
                            font-size: 0.75rem;
                            font-weight: 600;
                        }

                        .alert-box {
                            padding: 12px 16px;
                            border-radius: 10px;
                            margin-bottom: 20px;
                            font-weight: 500;
                            font-size: 0.9rem;
                        }

                        .alert-success {
                            background: #d1fae5;
                            color: #065f46;
                            border: 1px solid #a7f3d0;
                        }

                        .alert-error {
                            background: #fee2e2;
                            color: #991b1b;
                            border: 1px solid #fca5a5;
                        }

                        .btn-review {
                            background: var(--primary);
                            color: var(--primary-foreground);
                            padding: 6px 14px;
                            border: none;
                            border-radius: 8px;
                            cursor: pointer;
                            font-weight: 600;
                            font-size: 0.85rem;
                            text-decoration: none;
                            display: inline-block;
                            transition: all 0.2s;
                        }

                        .btn-review:hover {
                            opacity: 0.9;
                            transform: translateY(-1px);
                        }
                    </style>
                </head>

                <body>

                    <header class="topbar">
                        <div class="logo">Daily Fixer</div>
                        <div class="panel-name">Admin Panel</div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()"
                                aria-label="Toggle dark mode">🌙 Dark</button>
                            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
                        </div>
                    </header>

                    <aside class="sidebar">
                        <h3>Navigation</h3>
                        <ul>
                            <li><a
                                    href="${pageContext.request.contextPath}/pages/dashboards/admindash/admindashmain.jsp">Dashboard</a>
                            </li>
                            <li><a href="${pageContext.request.contextPath}/admin/users">User Management</a></li>
                            <li><a href="${pageContext.request.contextPath}/admin/volunteer-requests"
                                    class="active">Volunteer Requests
                                    <c:if test="${pendingCount > 0}"><span class="badge-count">${pendingCount}</span>
                                    </c:if>
                                </a></li>
                            <li><a
                                    href="${pageContext.request.contextPath}/pages/dashboards/admindash/flags.jsp">Flags</a>
                            </li>
                            <li><a
                                    href="${pageContext.request.contextPath}/pages/dashboards/admindash/transactions.jsp">Transactions</a>
                            </li>
                        </ul>
                    </aside>

                    <main class="main-content">
                        <div class="dashboard-header">
                            <h1>Volunteer Requests</h1>
                            <p>Review and manage volunteer guide writer applications.</p>
                        </div>

                        <!-- Success / Error Messages -->
                        <c:if test="${param.success == 'approved'}">
                            <div class="alert-box alert-success">✅ Volunteer request has been approved. The user can now
                                log in.</div>
                        </c:if>
                        <c:if test="${param.success == 'rejected'}">
                            <div class="alert-box alert-success">Volunteer request has been rejected.</div>
                        </c:if>
                        <c:if test="${not empty param.error}">
                            <div class="alert-box alert-error">⚠️ An error occurred. Please try again.</div>
                        </c:if>

                        <!-- Filters -->
                        <div class="search-container">
                            <input type="text" id="requestSearch" class="search-input"
                                placeholder="Search by name, email, or expertise...">
                            <select id="statusFilter" class="filter-select" onchange="filterByStatus()">
                                <option value="">All Statuses</option>
                                <option value="PENDING" ${param.status=='PENDING' ? 'selected' : '' }>Pending</option>
                                <option value="APPROVED" ${param.status=='APPROVED' ? 'selected' : '' }>Approved
                                </option>
                                <option value="REJECTED" ${param.status=='REJECTED' ? 'selected' : '' }>Rejected
                                </option>
                            </select>
                        </div>

                        <!-- Table -->
                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Name</th>
                                        <th>Email</th>
                                        <th>Expertise</th>
                                        <th>Skill Level</th>
                                        <th>Experience</th>
                                        <th>Status</th>
                                        <th>Submitted</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="req" items="${volunteerRequests}">
                                        <tr>
                                            <td>${req.requestId}</td>
                                            <td><strong>${req.fullName}</strong></td>
                                            <td>${req.email}</td>
                                            <td>
                                                <div class="expertise-tags">
                                                    <c:forEach var="tag" items="${req.expertise.split(', ')}">
                                                        <span class="expertise-tag">${tag}</span>
                                                    </c:forEach>
                                                </div>
                                            </td>
                                            <td>${req.skillLevel}</td>
                                            <td>${req.experienceYears} yrs</td>
                                            <td><span class="status-badge status-${req.status}">${req.status}</span>
                                            </td>
                                            <td>${req.submittedDate}</td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/admin/volunteer-requests?id=${req.requestId}"
                                                    class="btn-review">
                                                    Review
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty volunteerRequests}">
                                        <tr>
                                            <td colspan="9"
                                                style="text-align:center;padding:40px;color:var(--muted-foreground);">No
                                                volunteer requests found.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </main>

                    <script>
                        // Search filter
                        document.getElementById('requestSearch').addEventListener('input', function () {
                            const term = this.value.toLowerCase();
                            const rows = document.querySelectorAll('tbody tr');
                            rows.forEach(row => {
                                row.style.display = row.textContent.toLowerCase().includes(term) ? '' : 'none';
                            });
                        });

                        function filterByStatus() {
                            const status = document.getElementById('statusFilter').value;
                            const url = new URL(window.location);
                            if (status) {
                                url.searchParams.set('status', status);
                            } else {
                                url.searchParams.delete('status');
                            }
                            window.location = url;
                        }
                    </script>

                    <script src="${pageContext.request.contextPath}/pages/dashboards/admindash/dark-mode.js"></script>

                </body>

                </html>