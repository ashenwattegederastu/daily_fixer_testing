<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
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

    VehicleDAO dao = new VehicleDAO();
    List<Vehicle> vehicles = dao.getVehiclesByDriver(user.getUserId());
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Vehicle Management | Daily Fixer</title>
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

/* Vehicle Cards */
.vehicle-cards { 
    display: grid; 
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); 
    gap: 20px; 
    margin-top: 20px;
}
.vehicle-card { 
    background: #fff;
    border: 1px solid rgba(0,0,0,0.1); 
    border-radius: 12px; 
    padding: 20px; 
    text-align: center; 
    position: relative;
    box-shadow: var(--shadow-sm);
    transition: all 0.2s;
}
.vehicle-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}
.vehicle-card img { 
    width: 100%; 
    height: 160px; 
    object-fit: cover; 
    border-radius: 8px; 
    margin-bottom: 15px;
}
.vehicle-card p {
    margin: 8px 0;
    color: var(--text-secondary);
    font-weight: 500;
}
.vehicle-card p strong {
    color: var(--text-dark);
}

/* Add Vehicle Button */
.add-vehicle-btn { 
    margin: 20px 0; 
    padding: 12px 24px; 
    background: linear-gradient(135deg, #28a745, #20c997); 
    color: white; 
    border: none; 
    border-radius: 8px; 
    cursor: pointer; 
    font-weight: 600;
    font-size: 0.9rem;
    box-shadow: var(--shadow-sm);
    transition: all 0.2s;
}
.add-vehicle-btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}

/* Vehicle Form */
.vehicle-form { 
    display: none; 
    margin-top: 20px; 
    background: #fff;
    border: 1px solid rgba(0,0,0,0.1); 
    padding: 25px; 
    border-radius: 12px; 
    max-width: 500px;
    box-shadow: var(--shadow-sm);
}
.vehicle-form h3 {
    margin-bottom: 20px;
    color: var(--text-dark);
    font-size: 1.2em;
}
.vehicle-form input, .vehicle-form button { 
    display: block; 
    margin: 12px 0; 
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
}
.vehicle-form button:hover {
    transform: translateY(-1px);
    box-shadow: var(--shadow-sm);
    opacity: 0.9;
}

/* Vehicle Actions */
.vehicle-card .actions { 
    margin-top: 15px; 
    display: flex;
    gap: 10px;
    justify-content: center;
}
.vehicle-card .actions a { 
    display: inline-block; 
    padding: 8px 16px; 
    border-radius: 6px; 
    text-decoration: none; 
    color: white; 
    font-weight: 500;
    font-size: 0.85rem;
    transition: all 0.2s;
}
.edit-btn { 
    background: linear-gradient(135deg, #007bff, #0056b3); 
}
.delete-btn { 
    background: linear-gradient(135deg, #dc3545, #c82333); 
}
.vehicle-card .actions a:hover {
    transform: translateY(-1px);
    box-shadow: var(--shadow-sm);
    opacity: 0.9;
}

/* Empty State */
.empty-state {
    text-align: center;
    padding: 40px;
    color: var(--text-secondary);
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
}
</style>
    <script>
        function toggleForm() {
            const form = document.getElementById('addVehicleForm');
            form.style.display = form.style.display === 'block' ? 'none' : 'block';
        }

        function openEditForm(vehicleId, type, brand, model, plate, fare1, fareNext) {
            const form = document.getElementById('addVehicleForm');
            form.style.display = 'block';
            form.action = '${pageContext.request.contextPath}/EditVehicleServlet';
            document.getElementById('vehicleId').value = vehicleId;
            document.getElementById('vehicleType').value = type;
            document.getElementById('brand').value = brand;
            document.getElementById('model').value = model;
            document.getElementById('plateNumber').value = plate;
            document.getElementById('fareFirstKm').value = fare1;
            document.getElementById('fareNextKm').value = fareNext;
        }
    </script>
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
    <h2>Vehicle Management</h2>

    <!-- Add/Edit Vehicle Form -->
    <button class="add-vehicle-btn" onclick="toggleForm()">Add Vehicle</button>
    <form id="addVehicleForm" action="${pageContext.request.contextPath}/AddVehicleServlet" method="post" enctype="multipart/form-data" class="vehicle-form">
        <h3>Add / Edit Vehicle</h3>
        <input type="hidden" id="vehicleId" name="id">
        <input type="text" id="vehicleType" name="vehicleType" placeholder="Vehicle Type" required>
        <input type="text" id="brand" name="brand" placeholder="Brand" required>
        <input type="text" id="model" name="model" placeholder="Model" required>
        <input type="text" id="plateNumber" name="plateNumber" placeholder="Plate Number" required>
        <input type="file" name="picture" accept="image/*">
        <input type="number" step="0.01" id="fareFirstKm" name="fareFirstKm" placeholder="Fare for 1st KM" required>
        <input type="number" step="0.01" id="fareNextKm" name="fareNextKm" placeholder="Fare for next KMs" required>
        <button type="submit">Submit</button>
    </form>

    <!-- Vehicles Display -->
    <div class="vehicle-cards">
        <% for (Vehicle vehicle : vehicles) { %>
        <div class="vehicle-card">
            <img src="${pageContext.request.contextPath}/GetVehicleImageServlet?id=<%= vehicle.getId() %>" alt="Vehicle Image">
            <p><strong>Type:</strong> <%= vehicle.getVehicleType() %></p>
            <p><strong>Brand:</strong> <%= vehicle.getBrand() %></p>
            <p><strong>Model:</strong> <%= vehicle.getModel() %></p>
            <p><strong>Plate:</strong> <%= vehicle.getPlateNumber() %></p>
            <p><strong>Fare 1st KM:</strong> <%= vehicle.getFareFirstKm() %></p>
            <p><strong>Fare Next KMs:</strong> <%= vehicle.getFareNextKm() %></p>
            <div class="actions">
                <a href="javascript:void(0);" class="edit-btn"
                   onclick="openEditForm('<%= vehicle.getId() %>', '<%= vehicle.getVehicleType() %>', '<%= vehicle.getBrand() %>', '<%= vehicle.getModel() %>', '<%= vehicle.getPlateNumber() %>', '<%= vehicle.getFareFirstKm() %>', '<%= vehicle.getFareNextKm() %>')">Edit</a>
                <a href="${pageContext.request.contextPath}/DeleteVehicleServlet?id=<%= vehicle.getId() %>" class="delete-btn" onclick="return confirm('Are you sure you want to delete this vehicle?');">Delete</a>
            </div>
        </div>
        <% } %>
        <% if (vehicles.isEmpty()) { %>
        <div class="empty-state">
            <p>No vehicles added yet. Click "Add Vehicle" to register your first vehicle.</p>
        </div>
        <% } %>
    </div>
</main>

</body>
</html>
