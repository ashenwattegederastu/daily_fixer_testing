<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    // Get the currently logged-in user from session
    User user = (User) session.getAttribute("currentUser");

    // Redirect to login if no user or role is set
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Check role: allow only admin or store
    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>


<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Orders | Daily Fixer</title>
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

/* Table Styles */
table {
    width:100%;
    border-collapse: collapse;
    box-shadow: var(--shadow-sm);
    background: white;
    border-radius: 12px;
    overflow: hidden;
    border: 1px solid rgba(0,0,0,0.1);
}
thead { background-color: var(--panel-color); }
th, td {
    padding:12px 10px;
    text-align:left;
    border-bottom:1px solid #ddd;
}
tbody tr:hover { background-color:#f9f9f9; }

td .status {
    display:inline-block;
    width:14px;
    height:14px;
    border-radius:50%;
    margin-right: 8px;
}
.status.pending { background-color: #f39c12; }
.status.out-delivery { background-color: #3498db; }
.status.delivered { background-color: #27ae60; }

/* Buttons */
.btn { 
    padding:6px 12px; 
    border:none; 
    border-radius:8px; 
    cursor:pointer; 
    font-weight:500; 
    margin-right:5px;
    font-size: 0.85em;
}
.view-btn { background:#20255b; color:#fff; }
.update-btn { background: var(--accent); color:#fff; }
.delivery-btn { background: #e74c3c; color:#fff; }

.btn:hover {
    opacity: 0.9;
    transform: translateY(-1px);
}

/* Status Options */
.status-options {
    display: none;
    position: absolute;
    background: white;
    border: 1px solid #ddd;
    border-radius: 8px;
    box-shadow: var(--shadow-sm);
    z-index: 10;
    margin-top: 5px;
}

.status-options button {
    display: block;
    width: 100%;
    padding: 8px 12px;
    border: none;
    background: none;
    text-align: left;
    cursor: pointer;
    font-size: 0.85em;
}

.status-options button:hover {
    background-color: #f0f0ff;
}

/* Modal */
.vehicle-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.6);
    justify-content: center;
    align-items: center;
    z-index: 500;
}

.vehicle-modal .modal-content {
    background: white;
    padding: 30px;
    border-radius: 12px;
    max-width: 400px;
    width: 90%;
    text-align: center;
    box-shadow: var(--shadow-lg);
}

.vehicle-modal h3 {
    color: var(--accent);
    margin-bottom: 20px;
}

.vehicle-modal .vehicle-options {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 10px;
    margin-bottom: 20px;
}

.vehicle-modal .vehicle-btn {
    padding: 12px;
    border: 2px solid #ddd;
    border-radius: 8px;
    background: white;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.2s;
}

.vehicle-modal .vehicle-btn:hover {
    border-color: var(--accent);
    background: #f0f0ff;
}

.vehicle-modal .vehicle-btn.selected {
    border-color: var(--accent);
    background: var(--panel-color);
}

.vehicle-modal .modal-buttons {
    display: flex;
    gap: 10px;
    justify-content: center;
}

.vehicle-modal .modal-btn {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 500;
}

.vehicle-modal .confirm-btn {
    background: var(--accent);
    color: white;
}

.vehicle-modal .cancel-btn {
    background: #ddd;
    color: var(--text-dark);
}

.close-btn {
    position: absolute;
    top: 15px;
    right: 20px;
    font-size: 1.5em;
    font-weight: bold;
    cursor: pointer;
    color: var(--text-secondary);
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp" class="active">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Orders</h2>
    
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Status</th>
                <th>Total</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>001</td>
                <td>Kamal Silva</td>
                <td>2025-07-20</td>
                <td><span class="status pending"></span>Pending</td>
                <td>LKR 1,100</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn update-btn" onclick="toggleStatusOptions(this, 1)">Update Status</button>
                    <div class="status-options" id="status-options-1">
                        <button onclick="changeStatus(this, 'Pending')">Pending</button>
                        <button onclick="changeStatus(this, 'Out for Delivery')">Out for Delivery</button>
                        <button onclick="changeStatus(this, 'Delivered')">Delivered</button>
                    </div>
                    <button class="btn delivery-btn" onclick="showVehicleModal('001')">Ready to Deliver</button>
                </td>
            </tr>
            <tr>
                <td>002</td>
                <td>Amal Bandara</td>
                <td>2025-07-06</td>
                <td><span class="status delivered"></span>Delivered</td>
                <td>LKR 350</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn update-btn" onclick="toggleStatusOptions(this, 2)">Update Status</button>
                    <div class="status-options" id="status-options-2">
                        <button onclick="changeStatus(this, 'Pending')">Pending</button>
                        <button onclick="changeStatus(this, 'Out for Delivery')">Out for Delivery</button>
                        <button onclick="changeStatus(this, 'Delivered')">Delivered</button>
                    </div>
                    <button class="btn delivery-btn" onclick="showVehicleModal('002')">Ready to Deliver</button>
                </td>
            </tr>
            <tr>
                <td>003</td>
                <td>Nimal Perera</td>
                <td>2025-07-19</td>
                <td><span class="status out-delivery"></span>Out for Delivery</td>
                <td>LKR 2,500</td>
                <td>
                    <button class="btn view-btn">View Details</button>
                    <button class="btn update-btn" onclick="toggleStatusOptions(this, 3)">Update Status</button>
                    <div class="status-options" id="status-options-3">
                        <button onclick="changeStatus(this, 'Pending')">Pending</button>
                        <button onclick="changeStatus(this, 'Out for Delivery')">Out for Delivery</button>
                        <button onclick="changeStatus(this, 'Delivered')">Delivered</button>
                    </div>
                    <button class="btn delivery-btn" onclick="showVehicleModal('003')">Ready to Deliver</button>
                </td>
            </tr>
        </tbody>
    </table>
</main>

<!-- Vehicle Selection Modal -->
<div id="vehicleModal" class="vehicle-modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeVehicleModal()">&times;</span>
        <h3>Select Delivery Vehicle</h3>
        <p>Choose the type of vehicle needed for delivery:</p>
        
        <div class="vehicle-options">
            <button class="vehicle-btn" onclick="selectVehicle('bike')">Bike</button>
            <button class="vehicle-btn" onclick="selectVehicle('threewheel')">Three Wheel</button>
            <button class="vehicle-btn" onclick="selectVehicle('van')">Van</button>
            <button class="vehicle-btn" onclick="selectVehicle('lorry')">Lorry</button>
        </div>
        
        <div class="modal-buttons">
            <button class="modal-btn confirm-btn" onclick="confirmDelivery()">Confirm</button>
            <button class="modal-btn cancel-btn" onclick="closeVehicleModal()">Cancel</button>
        </div>
    </div>
</div>

<script>
let selectedOrderId = '';
let selectedVehicle = '';

function toggleStatusOptions(btn, orderId) {
    const optionsDiv = document.getElementById(`status-options-${orderId}`);
    optionsDiv.style.display = optionsDiv.style.display === "block" ? "none" : "block";
}

function changeStatus(button, newStatus) {
    const row = button.closest("tr");
    const statusCell = row.querySelector("td:nth-child(4)");
    
    // Update status visually
    let statusClass = "";
    if (newStatus === "Pending") statusClass = "pending";
    if (newStatus === "Out for Delivery") statusClass = "out-delivery";
    if (newStatus === "Delivered") statusClass = "delivered";
    
    statusCell.innerHTML = `<span class="status ${statusClass}"></span> ${newStatus}`;
    
    // Hide status options
    button.parentElement.style.display = "none";
}

function showVehicleModal(orderId) {
    selectedOrderId = orderId;
    document.getElementById('vehicleModal').style.display = 'flex';
}

function closeVehicleModal() {
    document.getElementById('vehicleModal').style.display = 'none';
    selectedVehicle = '';
    // Reset vehicle button selections
    document.querySelectorAll('.vehicle-btn').forEach(btn => {
        btn.classList.remove('selected');
    });
}

function selectVehicle(vehicle) {
    selectedVehicle = vehicle;
    // Reset all buttons
    document.querySelectorAll('.vehicle-btn').forEach(btn => {
        btn.classList.remove('selected');
    });
    // Select clicked button
    event.target.classList.add('selected');
}

function confirmDelivery() {
    if (selectedVehicle) {
        alert(`Order ${selectedOrderId} is ready for delivery using ${selectedVehicle}. Driver will be notified.`);
        closeVehicleModal();
    } else {
        alert('Please select a delivery vehicle type.');
    }
}

// Close modal on outside click
document.getElementById('vehicleModal').addEventListener('click', e => {
    if(e.target.id === 'vehicleModal') {
        closeVehicleModal();
    }
});
</script>

</body>
</html>
