<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.TechnicianAvailability" %>
<%@ page import="com.dailyfixer.dao.TechnicianAvailabilityDAO" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"technician".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    TechnicianAvailabilityDAO availabilityDAO = new TechnicianAvailabilityDAO();
    TechnicianAvailability availability = availabilityDAO.getAvailabilityByTechnicianId(user.getUserId());
    
    String availabilityMode = "WEEKDAYS";
    String startTime = "09:00";
    String endTime = "17:00";
    boolean[] days = new boolean[7];
    
    if (availability != null) {
        availabilityMode = availability.getAvailabilityMode();
        if (availability.getStartTime() != null) {
            startTime = availability.getStartTime().toString().substring(0, 5);
        }
        if (availability.getEndTime() != null) {
            endTime = availability.getEndTime().toString().substring(0, 5);
        }
        days[0] = availability.isMonday();
        days[1] = availability.isTuesday();
        days[2] = availability.isWednesday();
        days[3] = availability.isThursday();
        days[4] = availability.isFriday();
        days[5] = availability.isSaturday();
        days[6] = availability.isSunday();
    } else {
        days[0] = days[1] = days[2] = days[3] = days[4] = true;
    }
    
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Set Availability | Daily Fixer</title>
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
    background-color: #ffffff;
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

.topbar .logout-btn {
    padding: 0.6rem 1.2rem;
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
    border: none;
    color: #fff;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    text-decoration: none;
}

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

.sidebar ul { list-style:none; }

.sidebar a {
    display:block;
    padding:12px 20px;
    text-decoration:none;
    color: var(--text-dark);
    font-weight:500;
    border-left:3px solid transparent;
    transition: all 0.2s;
}

.sidebar a:hover, .sidebar a.active {
    background-color: #f0f0ff;
    border-left-color: var(--accent);
}

.container {
    flex:1;
    margin-left:240px;
    margin-top:83px;
    padding:30px;
    max-width: 800px;
}

.container h2 {
    font-size:1.8em;
    margin-bottom:10px;
}

.container p {
    color: #666;
    margin-bottom: 30px;
}

.alert {
    padding: 15px 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    font-weight: 500;
}

.alert-success {
    background: #d1fae5;
    color: #065f46;
    border: 1px solid #10b981;
}

.alert-error {
    background: #fee2e2;
    color: #991b1b;
    border: 1px solid #ef4444;
}

.form-card {
    background: #fff;
    padding: 30px;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
}

.form-group {
    margin-bottom: 25px;
}

.form-group label {
    display: block;
    font-weight: 600;
    margin-bottom: 8px;
    color: var(--text-dark);
}

.form-group select, .form-group input {
    width: 100%;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 1em;
    font-family: inherit;
}

.day-selector {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
    gap: 10px;
    margin-top: 10px;
}

.day-checkbox {
    display: flex;
    align-items: center;
    padding: 10px;
    background: #f8f9fa;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;
}

.day-checkbox:hover {
    background: #e9ecef;
}

.day-checkbox input[type="checkbox"] {
    width: auto;
    margin-right: 8px;
}

.time-inputs {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
}

.btn-primary {
    padding: 12px 30px;
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
    color: #fff;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    font-size: 1em;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: var(--shadow-sm);
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

#customDays {
    display: none;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Technician Dashboard</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/techniciandashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/bookings.jsp">Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/serviceListings.jsp">Service Listings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/setAvailability.jsp" class="active">Set Availability</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/acceptedBookings.jsp">Accepted Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/completedBookings.jsp">Completed Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Set Your Availability</h2>
    <p>Configure when you're available to accept booking requests from customers.</p>
    
    <% if (successMessage != null) { %>
        <div class="alert alert-success"><%= successMessage %></div>
    <% } %>
    
    <% if (errorMessage != null) { %>
        <div class="alert alert-error"><%= errorMessage %></div>
    <% } %>
    
    <div class="form-card">
        <form action="${pageContext.request.contextPath}/SetAvailabilityServlet" method="post">
            
            <div class="form-group">
                <label>Availability Mode</label>
                <select name="availabilityMode" id="availabilityMode" onchange="toggleCustomDays()" required>
                    <option value="WEEKDAYS" <%= "WEEKDAYS".equals(availabilityMode) ? "selected" : "" %>>Weekdays Only (Mon-Fri)</option>
                    <option value="WEEKENDS" <%= "WEEKENDS".equals(availabilityMode) ? "selected" : "" %>>Weekends Only (Sat-Sun)</option>
                    <option value="CUSTOM" <%= "CUSTOM".equals(availabilityMode) ? "selected" : "" %>>Custom Days</option>
                </select>
            </div>
            
            <div id="customDays" style="display: <%= "CUSTOM".equals(availabilityMode) ? "block" : "none" %>;">
                <div class="form-group">
                    <label>Select Available Days</label>
                    <div class="day-selector">
                        <label class="day-checkbox">
                            <input type="checkbox" name="monday" <%= days[0] ? "checked" : "" %>>
                            Monday
                        </label>
                        <label class="day-checkbox">
                            <input type="checkbox" name="tuesday" <%= days[1] ? "checked" : "" %>>
                            Tuesday
                        </label>
                        <label class="day-checkbox">
                            <input type="checkbox" name="wednesday" <%= days[2] ? "checked" : "" %>>
                            Wednesday
                        </label>
                        <label class="day-checkbox">
                            <input type="checkbox" name="thursday" <%= days[3] ? "checked" : "" %>>
                            Thursday
                        </label>
                        <label class="day-checkbox">
                            <input type="checkbox" name="friday" <%= days[4] ? "checked" : "" %>>
                            Friday
                        </label>
                        <label class="day-checkbox">
                            <input type="checkbox" name="saturday" <%= days[5] ? "checked" : "" %>>
                            Saturday
                        </label>
                        <label class="day-checkbox">
                            <input type="checkbox" name="sunday" <%= days[6] ? "checked" : "" %>>
                            Sunday
                        </label>
                    </div>
                </div>
            </div>
            
            <div class="form-group">
                <label>Working Hours</label>
                <div class="time-inputs">
                    <div>
                        <label style="font-weight: normal; font-size: 0.9em; color: #666;">Start Time</label>
                        <input type="time" name="startTime" value="<%= startTime %>" required>
                    </div>
                    <div>
                        <label style="font-weight: normal; font-size: 0.9em; color: #666;">End Time</label>
                        <input type="time" name="endTime" value="<%= endTime %>" required>
                    </div>
                </div>
            </div>
            
            <button type="submit" class="btn-primary">Save Availability Settings</button>
        </form>
    </div>
</main>

<script>
function toggleCustomDays() {
    const mode = document.getElementById('availabilityMode').value;
    const customDays = document.getElementById('customDays');
    customDays.style.display = mode === 'CUSTOM' ? 'block' : 'none';
}
</script>

</body>
</html>
