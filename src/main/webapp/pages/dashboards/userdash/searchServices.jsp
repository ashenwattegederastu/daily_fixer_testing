<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Service" %>
<%@ page import="com.dailyfixer.dao.ServiceDAO" %>
<%@ page import="com.dailyfixer.dao.UserDAO" %>
<%@ page import="java.util.List" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    ServiceDAO serviceDAO = new ServiceDAO();
    UserDAO userDAO = new UserDAO();
    
    String searchQuery = request.getParameter("search");
    String categoryFilter = request.getParameter("category");
    
    List<Service> services;
    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
        services = serviceDAO.searchServices(searchQuery);
    } else {
        services = serviceDAO.getAllServices();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Find Services | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
    --panel-color: #dcdaff;
    --accent: #8b95ff;
    --text-dark: #000000;
    --shadow-sm: 0 4px 12px rgba(0,0,0,0.12);
    --shadow-md: 0 8px 24px rgba(0,0,0,0.18);
}

* { margin:0; padding:0; box-sizing:border-box; }

body {
    font-family: 'Inter', sans-serif;
    background-color: #f8f9fa;
    color: var(--text-dark);
    display: flex;
    min-height: 100vh;
}

.topbar {
    position: fixed;
    top:0; left:0; right:0;
    height:76px;
    background-color: var(--panel-color);
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 30px;
    z-index: 200;
    box-shadow: var(--shadow-md);
}

.topbar .logo { font-size: 1.5em; font-weight: 700; color: var(--accent); }
.topbar .panel-name { font-weight: 600; flex:1; text-align:center; }

.topbar-actions {
    display: flex;
    gap: 15px;
}

.topbar .home-btn, .topbar .logout-btn {
    padding: 0.6rem 1.2rem;
    border: none;
    color: #fff;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    text-decoration: none;
    transition: all 0.2s;
}

.topbar .home-btn {
    background: linear-gradient(135deg, #10b981, #059669);
}

.topbar .logout-btn {
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
}

.sidebar {
    width: 240px;
    background-color: var(--panel-color);
    height: 100vh;
    position: fixed;
    top:0; left:0;
    padding-top: 96px;
    box-shadow: var(--shadow-md);
    overflow-y: auto;
    z-index: 100;
}

.sidebar ul { list-style:none; }

.sidebar a {
    display:block;
    padding:12px 20px;
    text-decoration:none;
    color: var(--text-dark);
    font-weight:500;
    transition: all 0.2s;
}

.sidebar a:hover, .sidebar a.active {
    background-color: #f0f0ff;
    border-left: 3px solid var(--accent);
}

.container {
    flex:1;
    margin-left:240px;
    margin-top:83px;
    padding:30px;
}

.container h2 {
    font-size:1.8em;
    margin-bottom:10px;
}

.search-box {
    background: #fff;
    padding: 20px;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    margin-bottom: 30px;
}

.search-box form {
    display: flex;
    gap: 10px;
}

.search-box input {
    flex: 1;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 1em;
}

.search-box button {
    padding: 12px 30px;
    background: var(--accent);
    color: #fff;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
}

.services-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
}

.service-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    padding: 20px;
    transition: all 0.2s;
}

.service-card:hover {
    transform: translateY(-5px);
    box-shadow: var(--shadow-md);
}

.service-card h3 {
    color: var(--accent);
    margin-bottom: 10px;
}

.service-card .category {
    display: inline-block;
    background: #e9ecef;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.85em;
    margin-bottom: 10px;
}

.service-card .description {
    color: #666;
    font-size: 0.9em;
    margin-bottom: 15px;
    line-height: 1.5;
}

.service-card .pricing {
    font-weight: 600;
    color: var(--text-dark);
    margin-bottom: 15px;
}

.service-card .technician {
    font-size: 0.9em;
    color: #666;
    margin-bottom: 15px;
}

.btn-book {
    width: 100%;
    padding: 10px;
    background: linear-gradient(135deg, #10b981, #059669);
    color: #fff;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    display: block;
    text-align: center;
}

.btn-book:hover {
    opacity: 0.9;
}

.no-results {
    text-align: center;
    padding: 60px 20px;
    color: #666;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Find Services</div>
    <div class="topbar-actions">
        <a href="${pageContext.request.contextPath}" class="home-btn">Home</a>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/userdashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/notifications.jsp">Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/searchServices.jsp" class="active">Find Services</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myBookings.jsp">My Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myPurchases.jsp">My Purchases</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Find Technician Services</h2>
    <p style="color: #666; margin-bottom: 20px;">Search for services and book qualified technicians</p>
    
    <div class="search-box">
        <form action="${pageContext.request.contextPath}/pages/dashboards/userdash/searchServices.jsp" method="get">
            <input type="text" name="search" placeholder="Search for services (e.g., plumbing, electrical, AC repair)" value="<%= searchQuery != null ? searchQuery : "" %>">
            <button type="submit">Search</button>
        </form>
    </div>
    
    <% if (services.isEmpty()) { %>
        <div class="no-results">
            <h3>No services found</h3>
            <p>Try adjusting your search or check back later for new services.</p>
        </div>
    <% } else { %>
        <div class="services-grid">
            <% for (Service service : services) {
                User technician = userDAO.getUserById(service.getTechnicianId());
                String technicianName = technician != null ? 
                    technician.getFirstName() + " " + technician.getLastName() : "Unknown";
            %>
            <div class="service-card">
                <h3><%= service.getServiceName() %></h3>
                <% if (service.getCategory() != null && !service.getCategory().isEmpty()) { %>
                    <span class="category"><%= service.getCategory() %></span>
                <% } %>
                <% if (service.getDescription() != null && !service.getDescription().isEmpty()) { %>
                    <div class="description"><%= service.getDescription() %></div>
                <% } %>
                <div class="pricing">
                    <% if ("fixed".equals(service.getPricingType())) { %>
                        Fixed Rate: LKR <%= String.format("%.2f", service.getFixedRate()) %>
                    <% } else if ("hourly".equals(service.getPricingType())) { %>
                        Hourly Rate: LKR <%= String.format("%.2f", service.getHourlyRate()) %>/hour
                    <% } %>
                </div>
                <div class="technician">
                    👤 <%= technicianName %>
                </div>
                <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/bookService.jsp?serviceId=<%= service.getServiceId() %>" class="btn-book">Book Now</a>
            </div>
            <% } %>
        </div>
    <% } %>
</main>

</body>
</html>
