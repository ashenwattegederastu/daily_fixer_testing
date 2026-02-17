<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Service" %>
<%@ page import="com.dailyfixer.dao.ServiceDAO" %>
<%@ page import="com.dailyfixer.dao.UserDAO" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String serviceIdParam = request.getParameter("serviceId");
    if (serviceIdParam == null) {
        response.sendRedirect(request.getContextPath() + "/pages/dashboards/userdash/searchServices.jsp");
        return;
    }

    int serviceId = Integer.parseInt(serviceIdParam);
    ServiceDAO serviceDAO = new ServiceDAO();
    Service service = serviceDAO.getServiceById(serviceId);
    
    if (service == null) {
        response.sendRedirect(request.getContextPath() + "/pages/dashboards/userdash/searchServices.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    User technician = userDAO.getUserById(service.getTechnicianId());
    String technicianName = technician != null ? 
        technician.getFirstName() + " " + technician.getLastName() : "Unknown";
    
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Book Service | Daily Fixer</title>
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
}

.topbar .home-btn {
    background: linear-gradient(135deg, #10b981, #059669);
}

.topbar .logout-btn {
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
}

.container {
    flex:1;
    margin-top:83px;
    padding:30px;
    max-width: 900px;
    margin-left: auto;
    margin-right: auto;
}

.container h2 {
    font-size:1.8em;
    margin-bottom:30px;
}

.alert {
    padding: 15px 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    font-weight: 500;
}

.alert-error {
    background: #fee2e2;
    color: #991b1b;
    border: 1px solid #ef4444;
}

.service-info {
    background: #fff;
    padding: 20px;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    margin-bottom: 30px;
}

.service-info h3 {
    color: var(--accent);
    margin-bottom: 10px;
}

.service-info .detail {
    margin-bottom: 8px;
    color: #666;
}

.booking-form {
    background: #fff;
    padding: 30px;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    font-weight: 600;
    margin-bottom: 8px;
    color: var(--text-dark);
}

.form-group input, .form-group textarea {
    width: 100%;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 1em;
    font-family: inherit;
}

.form-group textarea {
    resize: vertical;
    min-height: 100px;
}

.form-group small {
    display: block;
    margin-top: 5px;
    color: #666;
    font-size: 0.85em;
}

.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
}

.btn-submit {
    width: 100%;
    padding: 15px;
    background: linear-gradient(135deg, #10b981, #059669);
    color: #fff;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    font-size: 1.1em;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-submit:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.btn-back {
    display: inline-block;
    padding: 10px 20px;
    background: #6c757d;
    color: #fff;
    text-decoration: none;
    border-radius: 8px;
    margin-bottom: 20px;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Book Service</div>
    <div class="topbar-actions">
        <a href="${pageContext.request.contextPath}" class="home-btn">Home</a>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<main class="container">
    <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/searchServices.jsp" class="btn-back">← Back to Services</a>
    
    <h2>Book Service</h2>
    
    <% if (errorMessage != null) { %>
        <div class="alert alert-error"><%= errorMessage %></div>
    <% } %>
    
    <div class="service-info">
        <h3><%= service.getServiceName() %></h3>
        <div class="detail"><strong>Technician:</strong> <%= technicianName %></div>
        <div class="detail"><strong>Category:</strong> <%= service.getCategory() != null ? service.getCategory() : "General" %></div>
        <div class="detail">
            <strong>Price:</strong>
            <% if ("fixed".equals(service.getPricingType())) { %>
                LKR <%= String.format("%.2f", service.getFixedRate()) %> (Fixed)
            <% } else if ("hourly".equals(service.getPricingType())) { %>
                LKR <%= String.format("%.2f", service.getHourlyRate()) %>/hour
            <% } %>
        </div>
        <% if (service.getDescription() != null && !service.getDescription().isEmpty()) { %>
            <div class="detail"><strong>Description:</strong> <%= service.getDescription() %></div>
        <% } %>
    </div>
    
    <div class="booking-form">
        <form action="${pageContext.request.contextPath}/CreateBookingServlet" method="post" onsubmit="return validateForm()">
            <input type="hidden" name="serviceId" value="<%= service.getServiceId() %>">
            
            <div class="form-grid">
                <div class="form-group">
                    <label for="bookingDate">Preferred Date *</label>
                    <input type="date" id="bookingDate" name="bookingDate" required 
                           min="<%= java.time.LocalDate.now() %>">
                    <small>Select your preferred date for the service</small>
                </div>
                
                <div class="form-group">
                    <label for="bookingTime">Preferred Time *</label>
                    <input type="time" id="bookingTime" name="bookingTime" required>
                    <small>Select your preferred time</small>
                </div>
            </div>
            
            <div class="form-group">
                <label for="phoneNumber">Phone Number *</label>
                <input type="tel" id="phoneNumber" name="phoneNumber" 
                       value="<%= user.getPhoneNumber() != null ? user.getPhoneNumber() : "" %>" required>
                <small>We'll use this to contact you about the booking</small>
            </div>
            
            <div class="form-group">
                <label for="problemDescription">Problem Description</label>
                <textarea id="problemDescription" name="problemDescription" 
                          placeholder="Please describe the issue or service you need..."></textarea>
                <small>Provide details to help the technician prepare</small>
            </div>
            
            <div class="form-group">
                <label for="locationAddress">Service Location Address *</label>
                <textarea id="locationAddress" name="locationAddress" required 
                          placeholder="Enter the full address where the service is needed"></textarea>
                <small>Enter the complete address including street, city, and postal code</small>
            </div>
            
            <div class="form-grid">
                <div class="form-group">
                    <label for="latitude">Latitude (Optional)</label>
                    <input type="text" id="latitude" name="latitude" placeholder="e.g., 6.9271">
                    <small>GPS coordinates for precise location</small>
                </div>
                
                <div class="form-group">
                    <label for="longitude">Longitude (Optional)</label>
                    <input type="text" id="longitude" name="longitude" placeholder="e.g., 79.8612">
                    <small>GPS coordinates for precise location</small>
                </div>
            </div>
            
            <button type="submit" class="btn-submit">Submit Booking Request</button>
        </form>
    </div>
</main>

<script>
function validateForm() {
    const date = document.getElementById('bookingDate').value;
    const time = document.getElementById('bookingTime').value;
    const phone = document.getElementById('phoneNumber').value;
    const address = document.getElementById('locationAddress').value;
    
    if (!date || !time || !phone || !address) {
        alert('Please fill in all required fields.');
        return false;
    }
    
    const selectedDate = new Date(date);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    if (selectedDate < today) {
        alert('Please select a future date.');
        return false;
    }
    
    if (confirm('Please confirm your booking request. The technician will review and respond to your request.')) {
        return true;
    }
    
    return false;
}
</script>

</body>
</html>
