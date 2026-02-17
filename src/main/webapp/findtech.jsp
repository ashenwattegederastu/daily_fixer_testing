<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Service" %>
<%@ page import="com.dailyfixer.dao.ServiceDAO" %>
<%@ page import="com.dailyfixer.dao.UserDAO" %>
<%@ page import="java.util.List" %>

<%
    // This page is public - no login required to view services
    User currentUser = (User) session.getAttribute("currentUser");
    
    ServiceDAO serviceDAO = new ServiceDAO();
    UserDAO userDAO = new UserDAO();
    
    String searchQuery = request.getParameter("search");
    String categoryFilter = request.getParameter("category");
    
    List<Service> services;
    try {
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            services = serviceDAO.searchServices(searchQuery);
        } else {
            services = serviceDAO.getAllServices();
        }
    } catch (Exception e) {
        e.printStackTrace();
        services = new java.util.ArrayList<>();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Find a Technician | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
        }

        .page-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 100px 30px 50px;
        }

        .page-header {
            text-align: center;
            margin-bottom: 50px;
        }

        .page-header h1 {
            font-size: 2.5em;
            color: #333;
            margin-bottom: 10px;
        }

        .page-header p {
            font-size: 1.1em;
            color: #666;
        }

        .search-section {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            margin-bottom: 40px;
        }

        .search-form {
            display: flex;
            gap: 15px;
            max-width: 800px;
            margin: 0 auto;
        }

        .search-form input {
            flex: 1;
            padding: 15px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 1em;
            transition: border-color 0.3s;
        }

        .search-form input:focus {
            outline: none;
            border-color: #8b95ff;
        }

        .search-form button {
            padding: 15px 40px;
            background: linear-gradient(135deg, #8b95ff, #7ba3d4);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 1em;
            cursor: pointer;
            transition: all 0.3s;
        }

        .search-form button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(139, 149, 255, 0.3);
        }

        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 25px;
            margin-bottom: 50px;
        }

        .service-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            padding: 25px;
            transition: all 0.3s;
            border: 2px solid transparent;
        }

        .service-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
            border-color: #8b95ff;
        }

        .service-header {
            margin-bottom: 15px;
        }

        .service-header h3 {
            color: #8b95ff;
            font-size: 1.4em;
            margin-bottom: 8px;
        }

        .service-category {
            display: inline-block;
            background: #e9ecef;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            color: #666;
            margin-bottom: 10px;
        }

        .service-description {
            color: #666;
            font-size: 0.95em;
            line-height: 1.6;
            margin-bottom: 15px;
            min-height: 60px;
        }

        .service-pricing {
            font-weight: 600;
            color: #333;
            font-size: 1.1em;
            margin-bottom: 12px;
        }

        .service-technician {
            font-size: 0.9em;
            color: #666;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .service-technician::before {
            content: "👤";
        }

        .btn-book {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 1em;
            cursor: pointer;
            text-decoration: none;
            display: block;
            text-align: center;
            transition: all 0.3s;
        }

        .btn-book:hover {
            background: linear-gradient(135deg, #059669, #047857);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }

        .no-results {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }

        .no-results h3 {
            color: #666;
            font-size: 1.5em;
            margin-bottom: 10px;
        }

        .no-results p {
            color: #999;
            font-size: 1.1em;
        }

        .login-prompt {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 8px;
            padding: 15px 20px;
            margin-bottom: 30px;
            text-align: center;
        }

        .login-prompt a {
            color: #8b95ff;
            font-weight: 600;
            text-decoration: none;
        }

        .login-prompt a:hover {
            text-decoration: underline;
        }

        @media (max-width: 768px) {
            .page-container {
                padding: 80px 15px 30px;
            }

            .page-header h1 {
                font-size: 2em;
            }

            .search-form {
                flex-direction: column;
            }

            .services-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Include shared header -->
    <jsp:include page="/pages/shared/header.jsp" />

    <div class="page-container">
        <div class="page-header">
            <h1>Find a Technician</h1>
            <p>Browse available services and book qualified technicians for your repair needs</p>
        </div>

        <% if (currentUser == null) { %>
        <div class="login-prompt">
            📢 <a href="${pageContext.request.contextPath}/login.jsp">Login</a> or 
            <a href="${pageContext.request.contextPath}/preliminarySignup.jsp">Sign up</a> to book services
        </div>
        <% } %>

        <div class="search-section">
            <form action="${pageContext.request.contextPath}/findtech.jsp" method="get" class="search-form">
                <input 
                    type="text" 
                    name="search" 
                    placeholder="Search for services (e.g., plumbing, electrical, AC repair)" 
                    value="<%= searchQuery != null ? searchQuery : "" %>"
                >
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
                    User technician = null;
                    try {
                        technician = userDAO.getUserById(service.getTechnicianId());
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    String technicianName = technician != null ? 
                        technician.getFirstName() + " " + technician.getLastName() : "Unknown";
                %>
                <div class="service-card">
                    <div class="service-header">
                        <h3><%= service.getServiceName() %></h3>
                        <% if (service.getCategory() != null && !service.getCategory().isEmpty()) { %>
                            <span class="service-category"><%= service.getCategory() %></span>
                        <% } %>
                    </div>
                    
                    <% if (service.getDescription() != null && !service.getDescription().isEmpty()) { %>
                        <div class="service-description"><%= service.getDescription() %></div>
                    <% } %>
                    
                    <div class="service-pricing">
                        <% if ("fixed".equals(service.getPricingType())) { %>
                            💰 LKR <%= String.format("%.2f", service.getFixedRate()) %> (Fixed Rate)
                        <% } else if ("hourly".equals(service.getPricingType())) { %>
                            💰 LKR <%= String.format("%.2f", service.getHourlyRate()) %>/hour
                        <% } %>
                    </div>
                    
                    <div class="service-technician">
                        <%= technicianName %>
                    </div>
                    
                    <% if (currentUser != null && "user".equalsIgnoreCase(currentUser.getRole())) { %>
                        <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/bookService.jsp?serviceId=<%= service.getServiceId() %>" class="btn-book">
                            Book Now
                        </a>
                    <% } else if (currentUser != null) { %>
                        <button class="btn-book" onclick="alert('Only regular users can book services. Please login with a user account.')">
                            Book Now
                        </button>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login.jsp?redirect=findtech.jsp" class="btn-book">
                            Login to Book
                        </a>
                    <% } %>
                </div>
                <% } %>
            </div>
        <% } %>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
</body>
</html>
