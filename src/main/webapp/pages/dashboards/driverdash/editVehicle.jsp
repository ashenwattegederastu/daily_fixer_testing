<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.Vehicle" %>
<%@ page import="com.dailyfixer.dao.VehicleDAO" %>
<%@ page import="com.dailyfixer.model.User" %>
<%
  // Get logged-in user
  User user = (User) session.getAttribute("currentUser");
  if (user == null || !"driver".equals(user.getRole())) {
    response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
    return;
  }

  // Get vehicle ID from query parameter
  String idParam = request.getParameter("id");
  if (idParam == null || idParam.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");
    return;
  }

  int vehicleId = Integer.parseInt(idParam);
  VehicleDAO dao = new VehicleDAO();
  Vehicle vehicle = dao.getVehicleById(vehicleId);

  if (vehicle == null || vehicle.getDriverId() != user.getUserId()) {
    response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");
    return;
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Vehicle | Daily Fixer</title>
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

/* Vehicle Form */
.vehicle-form { 
    max-width: 500px; 
    margin: 20px auto; 
    background: #fff;
    border: 1px solid rgba(0,0,0,0.1); 
    padding: 30px; 
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
}
.vehicle-form h3 {
    margin-bottom: 25px;
    color: var(--text-dark);
    font-size: 1.3em;
    text-align: center;
    border-bottom: 2px solid var(--panel-color);
    padding-bottom: 15px;
}
.vehicle-form label {
    display: block;
    margin: 15px 0 5px;
    color: var(--text-dark);
    font-weight: 600;
    font-size: 0.9rem;
}
.vehicle-form input, .vehicle-form button { 
    display: block; 
    margin: 8px 0; 
    width: 100%; 
    padding: 12px; 
    border: 1px solid #ddd;
    border-radius: 8px;
    font-family: 'Inter', sans-serif;
    font-size: 0.9rem;
}
.vehicle-form input:focus {
    outline: none;
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(139, 149, 255, 0.1);
}
.vehicle-form button {
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
    color: white;
    border: none;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.2s;
    margin-top: 20px;
}
.vehicle-form button:hover {
    transform: translateY(-1px);
    box-shadow: var(--shadow-sm);
    opacity: 0.9;
}
.current-image { 
    width: 100%; 
    height: 200px; 
    object-fit: cover; 
    border-radius: 8px; 
    margin-bottom: 15px;
    border: 2px solid var(--panel-color);
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Driver Panel</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/driverdashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/vehicleManagement.jsp" class="active">Vehicle Management</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/deliveryrequests.jsp">Delivery Requests</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/acceptedOrders.jsp">Accepted Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/completedOrders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Edit Vehicle</h2>
    <form action="${pageContext.request.contextPath}/EditVehicleServlet" method="post" enctype="multipart/form-data" class="vehicle-form">
        <h3>Update Vehicle Information</h3>
        <input type="hidden" name="id" value="<%= vehicle.getId() %>">

        <label>Current Image:</label>
        <img src="${pageContext.request.contextPath}/GetVehicleImageServlet?id=<%= vehicle.getId() %>" class="current-image" alt="Vehicle Image">

        <label for="vehicleType">Vehicle Type:</label>
        <input type="text" name="vehicleType" value="<%= vehicle.getVehicleType() %>" placeholder="Vehicle Type" required>

        <label for="brand">Brand:</label>
        <input type="text" name="brand" value="<%= vehicle.getBrand() %>" placeholder="Brand" required>

        <label for="model">Model:</label>
        <input type="text" name="model" value="<%= vehicle.getModel() %>" placeholder="Model" required>

        <label for="plateNumber">Plate Number:</label>
        <input type="text" name="plateNumber" value="<%= vehicle.getPlateNumber() %>" placeholder="Plate Number" required>

        <label for="picture">New Image (optional):</label>
        <input type="file" name="picture" accept="image/*">

        <label for="fareFirstKm">Fare for 1st KM:</label>
        <input type="number" step="0.01" name="fareFirstKm" value="<%= vehicle.getFareFirstKm() %>" placeholder="Fare for 1st KM" required>

        <label for="fareNextKm">Fare for next KMs:</label>
        <input type="number" step="0.01" name="fareNextKm" value="<%= vehicle.getFareNextKm() %>" placeholder="Fare for next KMs" required>

        <button type="submit">Update Vehicle</button>
    </form>
</main>

</body>
</html>
