<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.Service" %>

<%
    Service s = (Service) request.getAttribute("service");
    if (s == null) {
        response.sendRedirect(request.getContextPath() + "/pages/dashboards/techniciandash/serviceListings.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Service | Daily Fixer</title>
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

.form-container {
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    max-width: 700px;
    margin: 0 auto;
}
.form-container h2 { margin-bottom: 20px; color: var(--text-dark); }
label { display: block; margin-top: 15px; font-weight: bold; color: var(--text-dark); }
input[type="text"], input[type="number"], select { width: 100%; padding: 12px; border-radius: 8px; border: 1px solid #ddd; margin-top: 5px; font-size: 14px; }
input[type="file"] { margin-top: 5px; }
.submit-btn { margin-top: 25px; padding: 12px 25px; background: var(--accent); color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; transition: all 0.2s; box-shadow: var(--shadow-sm); }
.submit-btn:hover { 
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}
.back-link { display: inline-block; margin-top: 15px; text-decoration: none; color: var(--accent); font-weight: 500; }
.back-link:hover { text-decoration: underline; }
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Technician Dashboard</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/techniciandashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/bookings.jsp">Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/serviceListings.jsp" class="active">Service Listings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/acceptedBookings.jsp">Accepted Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/completedBookings.jsp">Completed Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<div class="container">
    <main class="dashboard">
        <div class="form-container">
            <h2>Edit Service</h2>
            <form action="${pageContext.request.contextPath}/EditServiceServlet" method="post" enctype="multipart/form-data">
                <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">

                <label for="serviceName">Service Name:</label>
                <input type="text" name="serviceName" id="serviceName" value="<%= s.getServiceName() %>" required>

                <label for="category">Category:</label>
                <input type="text" name="category" id="category" value="<%= s.getCategory() %>" required>

                <label for="pricingType">Pricing Type:</label>
                <select name="pricingType" id="pricingType" required onchange="toggleRates()">
                    <option value="">Select Type</option>
                    <option value="hourly" <%= "hourly".equalsIgnoreCase(s.getPricingType()) ? "selected" : "" %>>Hourly</option>
                    <option value="fixed" <%= "fixed".equalsIgnoreCase(s.getPricingType()) ? "selected" : "" %>>Fixed</option>
                </select>

                <div id="hourlyRateDiv" style="display:<%= "hourly".equalsIgnoreCase(s.getPricingType()) ? "block" : "none" %>;">
                    <label for="hourlyRate">Hourly Rate (Rs):</label>
                    <input type="number" name="hourlyRate" id="hourlyRate" value="<%= s.getHourlyRate() %>">
                </div>

                <div id="fixedRateDiv" style="display:<%= "fixed".equalsIgnoreCase(s.getPricingType()) ? "block" : "none" %>;">
                    <label for="fixedRate">Fixed Charge (Rs):</label>
                    <input type="number" name="fixedRate" id="fixedRate" value="<%= s.getFixedRate() %>">
                </div>

                <label for="inspectionCharge">Inspection Charge (Rs):</label>
                <input type="number" name="inspectionCharge" id="inspectionCharge" value="<%= s.getInspectionCharge() %>" required>

                <label for="transportCharge">Transport Charge (Rs):</label>
                <input type="number" name="transportCharge" id="transportCharge" value="<%= s.getTransportCharge() %>" required>

                <label for="availableDates">Available Dates:</label>
                <input type="text" name="availableDates" id="availableDates" value="<%= s.getAvailableDates() %>" required>

                <label for="serviceImage">Service Image:</label>
                <input type="file" name="serviceImage" id="serviceImage" accept="image/*">

                <button type="submit" class="submit-btn">Update Service</button>
            </form>
            <a href="${pageContext.request.contextPath}/pages/dashboards/techdash/serviceListings.jsp" class="back-link">← Back to Service Listings</a>
        </div>
    </main>
</div>

<script>
    function toggleRates() {
        const type = document.getElementById('pricingType').value;
        document.getElementById('hourlyRateDiv').style.display = type === 'hourly' ? 'block' : 'none';
        document.getElementById('fixedRateDiv').style.display = type === 'fixed' ? 'block' : 'none';
    }
</script>
</body>
</html>
