<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="java.sql.*, com.dailyfixer.util.DBConnection" %>

<%
  User user = (User) session.getAttribute("currentUser");
  if (user == null || user.getRole() == null || !"admin".equalsIgnoreCase(user.getRole().trim())) {
    response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
    return;
  }

  // Fetch total registered users
  int totalUsers = 0;
  try (Connection conn = DBConnection.getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS count FROM users");
       ResultSet rs = ps.executeQuery()) {
    if (rs.next()) {
      totalUsers = rs.getInt("count");
    }
  } catch (Exception e) {
    e.printStackTrace();
  }

  // Mock site visits
  int siteVisitsToday = 5;
  int siteVisitsMonth = 23;
%>

<html>
<head>
  <title>Admin Dashboard - Daily Fixer</title>

  <style>
    /* Background */
    body {
      margin: 0;
      font-family: 'Inter', sans-serif;
      background: linear-gradient(135deg, #1e3c72, #2a5298);
      min-height: 100vh;
      color: #fff;
      overflow-x: hidden;
    }

    /* Navbar */
    .navbar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 15px 40px;
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(12px);
      border-bottom: 1px solid rgba(255, 255, 255, 0.2);
    }

    .navbar .logo {
      font-size: 1.8em;
      font-weight: 700;
      color: #fff;
    }

    .nav-links {
      list-style: none;
      display: flex;
      gap: 20px;
    }

    .nav-links a {
      color: #fff;
      text-decoration: none;
      font-weight: 500;
      transition: color 0.3s ease;
    }

    .nav-links a:hover {
      color: #b2f5ea;
    }

    /* Subnav */
    .subnav {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px 40px;
      background: rgba(255, 255, 255, 0.08);
      backdrop-filter: blur(8px);
    }

    .subnav .store-name {
      font-weight: bold;
      font-size: 1.1em;
    }

    .subnav ul {
      list-style: none;
      display: flex;
      gap: 25px;
    }

    .subnav ul li a {
      color: #fff;
      text-decoration: none;
      font-weight: 500;
    }

    .subnav ul li a.active,
    .subnav ul li a:hover {
      color: #90cdf4;
      border-bottom: 2px solid #90cdf4;
      padding-bottom: 3px;
    }

    /* Main Container */
    .container {
      display: flex;
      justify-content: center;
      margin-top: 50px;
      padding: 20px;
    }

    .dashboard {
      width: 85%;
      background: rgba(255, 255, 255, 0.15);
      backdrop-filter: blur(18px);
      border-radius: 20px;
      padding: 40px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.25);
    }

    .dashboard h2 {
      font-size: 2em;
      margin-bottom: 5px;
      color: #fff;
    }

    .subtitle {
      color: #cfe0ff;
      font-size: 1.1em;
      margin-bottom: 30px;
    }

    /* Stats Cards */
    .stats-container {
      display: flex;
      gap: 20px;
      flex-wrap: wrap;
    }

    .stat-card {
      flex: 1;
      min-width: 200px;
      background: rgba(255, 255, 255, 0.12);
      border-radius: 15px;
      padding: 20px;
      text-align: center;
      border: 1px solid rgba(255, 255, 255, 0.2);
      transition: transform 0.3s ease, background 0.3s ease;
    }

    .stat-card:hover {
      transform: translateY(-5px);
      background: rgba(255, 255, 255, 0.2);
    }

    .stat-card .number {
      font-size: 2em;
      font-weight: bold;
      color: #b2f5ea;
    }

    /* Admin Stats Section */
    .admin-stats {
      margin-top: 40px;
    }

    .admin-stats h3 {
      margin-bottom: 20px;
      color: #fff;
      font-size: 1.5em;
    }

    .stats-grid {
      display: flex;
      gap: 20px;
      flex-wrap: wrap;
    }

    .info-box {
      flex: 1;
      min-width: 200px;
      background: rgba(255, 255, 255, 0.12);
      border-radius: 15px;
      padding: 15px 20px;
      border: 1px solid rgba(255, 255, 255, 0.2);
      transition: background 0.3s ease;
    }

    .info-box:hover {
      background: rgba(255, 255, 255, 0.2);
    }

    /* Scrollbar hidden */
    ::-webkit-scrollbar {
      display: none;
    }
  </style>
</head>
<body>

<header>
  <nav class="navbar">
    <div class="logo">Daily Fixer</div>
    <ul class="nav-links">
      <li><a href="${pageContext.request.contextPath}">Home</a></li>
      <li><a href="${pageContext.request.contextPath}/LogoutServlet">Log Out</a></li>
    </ul>
  </nav>

  <nav class="subnav">
    <div class="store-name">Administrator Panel</div>
    <ul>
      <li><a href="#" class="active">Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/users">User Management</a>
      </li>
      <li><a href="#">Reports/Flags</a></li>
      <li><a href="#">Profile</a></li>
    </ul>
  </nav>
</header>

<div class="container">
  <main class="dashboard">
    <h2>Dashboard</h2>
    <p class="subtitle">Site Performance Index</p>

    <div class="stats-container">
      <div class="stat-card">
        <p class="number"><%= siteVisitsToday %></p>
        <p>Site Visits Today</p>
      </div>
      <div class="stat-card">
        <p class="number"><%= siteVisitsMonth %></p>
        <p>Site Visits This Month</p>
      </div>
      <div class="stat-card">
        <p class="number"><%= totalUsers %></p>
        <p>Total Registered Users</p>
      </div>
    </div>

    <div class="admin-stats">
      <h3>Site Analytics</h3>
      <div class="stats-grid">
        <div class="info-box">
          <p><strong>Total Deliveries:</strong> 342</p>
        </div>
        <div class="info-box">
          <p><strong>Average Driver Rating:</strong> 4.9/5</p>
        </div>
        <div class="info-box">
          <p><strong>Pending Reports:</strong> 7</p>
        </div>
      </div>
    </div>
  </main>
</div>

</body>
</html>
