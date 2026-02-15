<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Delivery Requests | Daily Fixer</title>
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

/* Delivery Cards */
.card {
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    padding: 25px;
    margin-bottom: 20px;
    transition: all 0.2s;
}
.card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}
.card h3 {
    font-size: 1.3em;
    margin-bottom: 20px;
    color: var(--accent);
    border-bottom: 2px solid var(--panel-color);
    padding-bottom: 10px;
}

/* Details Grid */
.details-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 15px;
    margin-bottom: 20px;
}
.details-grid p {
    margin: 8px 0;
    color: var(--text-secondary);
    font-weight: 500;
}
.details-grid strong {
    color: var(--text-dark);
    font-weight: 600;
}

/* Accept Button */
.accept-btn {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    box-shadow: var(--shadow-sm);
    transition: all 0.2s;
    width: 100%;
}
.accept-btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
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
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/vehicleManagement.jsp">Vehicle Management</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/deliveryrequests.jsp" class="active">Delivery Requests</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/acceptedOrders.jsp">Accepted Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/completedOrders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Delivery Requests</h2>
    
    <div class="card">
        <h3>Order 001</h3>
        <div class="details-grid">
            <p><strong>Customer:</strong> Kamal Silva</p>
            <p><strong>Phone:</strong> +94 70 234 5678</p>
            <p><strong>Pickup:</strong> MyStore, Pettah</p>
            <p><strong>Store Contact:</strong> 011 234 7567</p>
            <p><strong>Dropoff:</strong> 123 Main Street, Colombo</p>
        </div>
        <button class="accept-btn" onclick="acceptDelivery('Order 001')">Accept Delivery</button>
    </div>

    <div class="card">
        <h3>Order 002</h3>
        <div class="details-grid">
            <p><strong>Customer:</strong> Amal Bandara</p>
            <p><strong>Phone:</strong> +94 77 987 3218</p>
            <p><strong>Pickup:</strong> Handy, Dehiwala</p>
            <p><strong>Store Contact:</strong> 011 786 5467</p>
            <p><strong>Dropoff:</strong> 45, Lili Road, Colombo</p>
        </div>
        <button class="accept-btn" onclick="acceptDelivery('Order 002')">Accept Delivery</button>
    </div>
</main>

<script>
    function acceptDelivery(orderId) {
        alert(orderId + " has been accepted!");
    }
</script>

</body>
</html>