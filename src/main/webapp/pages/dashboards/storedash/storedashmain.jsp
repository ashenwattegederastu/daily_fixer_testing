<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.OrderDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.ProductSales" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>

<%
    // Get the current user from session
    User user = (User) session.getAttribute("currentUser");

    // If user is not logged in, redirect to login
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Check if role is admin or store; otherwise redirect
    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Fetch data for dashboard
    String storeUsername = user.getUsername();
    ProductDAO productDAO = new ProductDAO();
    OrderDAO orderDAO = new OrderDAO();
    ProductVariantDAO variantDAO = new ProductVariantDAO();
    
    // Get all products for this store
    List<Product> allProducts = new ArrayList<>();
    try {
        allProducts = productDAO.getAllProducts(storeUsername);
    } catch (Exception e) {
        System.err.println("Error fetching products: " + e.getMessage());
        e.printStackTrace();
    }
    
    // Filter low stock items (quantity < 5)
    List<Product> lowStockProducts = new ArrayList<>();
    for (Product product : allProducts) {
        int totalStock = product.getQuantity();
        
        // Check if product has variants - if so, sum variant quantities
        try {
            List<ProductVariant> variants = variantDAO.getVariantsByProductId(product.getProductId());
            if (variants != null && !variants.isEmpty()) {
                totalStock = 0;
                for (ProductVariant variant : variants) {
                    totalStock += variant.getQuantity();
                }
            }
        } catch (Exception e) {
            // If variant check fails, use product quantity
        }
        
        if (totalStock < 5) {
            lowStockProducts.add(product);
        }
    }
    
    // Get order statistics
    List<com.dailyfixer.model.Order> allStoreOrders = new ArrayList<>();
    List<com.dailyfixer.model.Order> pendingOrders = new ArrayList<>();
    List<com.dailyfixer.model.Order> completedOrders = new ArrayList<>();
    List<com.dailyfixer.model.Order> processingOrders = new ArrayList<>();
    List<com.dailyfixer.model.Order> outForDeliveryOrders = new ArrayList<>();
    BigDecimal totalRevenue = BigDecimal.ZERO;
    
    try {
        // Get all orders for this store (PAID status)
        allStoreOrders = orderDAO.getOrdersByStatusAndStore("PAID", storeUsername);
        
        // Get DELIVERED orders for completed count
        List<com.dailyfixer.model.Order> deliveredOrders = orderDAO.getOrdersByStatusAndStore("DELIVERED", storeUsername);
        if (deliveredOrders != null) {
            completedOrders.addAll(deliveredOrders);
        }
        
        // Get PROCESSING orders
        List<com.dailyfixer.model.Order> processingOrdersList = orderDAO.getOrdersByStatusAndStore("PROCESSING", storeUsername);
        if (processingOrdersList != null) {
            processingOrders.addAll(processingOrdersList);
        }
        
        // Get OUT_FOR_DELIVERY orders
        List<com.dailyfixer.model.Order> outForDeliveryOrdersList = orderDAO.getOrdersByStatusAndStore("OUT_FOR_DELIVERY", storeUsername);
        if (outForDeliveryOrdersList != null) {
            outForDeliveryOrders.addAll(outForDeliveryOrdersList);
        }
        
        // Filter pending orders (non-DELIVERED, non-PROCESSING, non-OUT_FOR_DELIVERY from PAID orders)
        if (allStoreOrders != null) {
            for (com.dailyfixer.model.Order order : allStoreOrders) {
                String status = order.getStatus() != null ? order.getStatus().trim().toUpperCase() : "";
                if (!"DELIVERED".equals(status) && !"OUT_FOR_DELIVERY".equals(status) && !"PROCESSING".equals(status)) {
                    pendingOrders.add(order);
                }
                // Calculate revenue from all orders
                if (order.getAmount() != null) {
                    totalRevenue = totalRevenue.add(order.getAmount());
                }
            }
        }
        
        // Add revenue from completed orders
        if (completedOrders != null) {
            for (com.dailyfixer.model.Order order : completedOrders) {
                if (order.getAmount() != null) {
                    totalRevenue = totalRevenue.add(order.getAmount());
                }
            }
        }
        
        // Add revenue from processing orders
        if (processingOrders != null) {
            for (com.dailyfixer.model.Order order : processingOrders) {
                if (order.getAmount() != null) {
                    totalRevenue = totalRevenue.add(order.getAmount());
                }
            }
        }
        
        // Add revenue from out for delivery orders
        if (outForDeliveryOrders != null) {
            for (com.dailyfixer.model.Order order : outForDeliveryOrders) {
                if (order.getAmount() != null) {
                    totalRevenue = totalRevenue.add(order.getAmount());
                }
            }
        }
    } catch (Exception e) {
        System.err.println("Error fetching orders: " + e.getMessage());
        e.printStackTrace();
    }
    
    // Format revenue for display
    NumberFormat currencyFormat = NumberFormat.getNumberInstance(Locale.US);
    String formattedRevenue = currencyFormat.format(totalRevenue.doubleValue());
    
    // --- Data for charts ---
    int pendingCount = pendingOrders != null ? pendingOrders.size() : 0;
    int processingCount = processingOrders != null ? processingOrders.size() : 0;
    int outForDeliveryCount = outForDeliveryOrders != null ? outForDeliveryOrders.size() : 0;
    int deliveredCount = completedOrders != null ? completedOrders.size() : 0;
    
    // Last 7 days: order count and revenue per day
    String[] dayLabels = new String[7];
    int[] orderCounts = new int[7];
    double[] revenueByDay = new double[7];
    Map<String, Integer> keyToIndex = new HashMap<>();
    SimpleDateFormat keyFmt = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat labelFmt = new SimpleDateFormat("d MMM");
    Calendar cal = Calendar.getInstance();
    cal.set(Calendar.HOUR_OF_DAY, 0);
    cal.set(Calendar.MINUTE, 0);
    cal.set(Calendar.SECOND, 0);
    cal.set(Calendar.MILLISECOND, 0);
    for (int i = 0; i < 7; i++) {
        Calendar d = (Calendar) cal.clone();
        d.add(Calendar.DATE, -(6 - i));
        String key = keyFmt.format(d.getTime());
        keyToIndex.put(key, i);
        dayLabels[i] = labelFmt.format(d.getTime());
    }
    List<com.dailyfixer.model.Order> allOrdersForCharts = new ArrayList<>();
    try {
        allOrdersForCharts = orderDAO.getAllOrdersByStore(storeUsername);
    } catch (Exception e) { }
    if (allOrdersForCharts != null) {
        for (com.dailyfixer.model.Order o : allOrdersForCharts) {
            if (o.getCreatedAt() == null) continue;
            String k = keyFmt.format(o.getCreatedAt());
            if (keyToIndex.containsKey(k)) {
                int idx = keyToIndex.get(k);
                orderCounts[idx]++;
                if (o.getAmount() != null) revenueByDay[idx] += o.getAmount().doubleValue();
            }
        }
    }
    
    // Most selling items for chart and for Most Selling Item card
    StringBuilder mostSellingJson = new StringBuilder("[");
    List<ProductSales> productSales = new ArrayList<>();
    try {
        productSales = orderDAO.getProductSalesByStore(storeUsername);
    } catch (Exception e) {
        System.err.println("Error fetching product sales: " + e.getMessage());
    }
    if (productSales != null) {
        for (int i = 0; i < productSales.size(); i++) {
            ProductSales ps = productSales.get(i);
            if (i > 0) mostSellingJson.append(",");
            String nm = ps.getProductName() != null ? ps.getProductName().replace("\"", "\\\"") : "";
            mostSellingJson.append("{\"name\":\"").append(nm).append("\",\"qty\":").append(ps.getQuantitySold()).append("}");
        }
    }
    mostSellingJson.append("]");
    
    // Top-selling product for the Most Selling Item card (with image)
    ProductSales topSales = (productSales != null && !productSales.isEmpty()) ? productSales.get(0) : null;
    Product mostSellingProduct = null;
    if (topSales != null && topSales.getProductId() > 0) {
        try {
            mostSellingProduct = productDAO.getProductById(topSales.getProductId());
        } catch (Exception e) { }
    }
    
    // JS arrays for charts
    StringBuilder orderCountsJs = new StringBuilder();
    StringBuilder revenueByDayJs = new StringBuilder();
    for (int i = 0; i < 7; i++) {
        if (i > 0) { orderCountsJs.append(','); revenueByDayJs.append(','); }
        orderCountsJs.append(orderCounts[i]);
        revenueByDayJs.append(String.format(Locale.US, "%.2f", revenueByDay[i]));
    }
%>


<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Store Dashboard | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
.container {
    padding:40px;
    min-height: calc(100vh - 83px);
}

.container h2 {
    font-size: 2.2em;
    margin-bottom: 10px;
    color: var(--foreground);
    font-weight: 700;
    background: linear-gradient(135deg, var(--primary), var(--accent-foreground));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.dashboard-subtitle {
    color: var(--muted-foreground);
    font-size: 1em;
    margin-bottom: 35px;
    font-weight: 400;
}

/* Cards Grid */
.cards-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 24px;
    margin-bottom: 40px;
}

.card {
    position: relative;
    overflow: hidden;
}

.card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg, var(--primary), var(--accent-foreground));
    opacity: 0;
    transition: opacity 0.3s ease;
}

.card:hover::before {
    opacity: 1;
}

.card-header {
    margin-bottom: 16px;
}

.card h3 {
    color: var(--foreground);
    margin: 0;
    font-size: 1.2em;
    font-weight: 600;
}

.card .number {
    font-size: 2.8em;
    font-weight: 700;
    color: var(--primary);
    margin-bottom: 8px;
    line-height: 1;
}

.card .label {
    color: var(--muted-foreground);
    font-size: 0.95em;
    font-weight: 400;
}

/* Most Selling Item card */
.most-selling-item {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px;
    background: var(--muted);
    border-radius: 12px;
    transition: all 0.3s ease;
}
.most-selling-item:hover { background: var(--accent); }
.most-selling-item img {
    width: 70px;
    height: 70px;
    border-radius: 12px;
    object-fit: cover;
    border: 2px solid var(--border);
    box-shadow: var(--shadow-sm);
}
.most-selling-item .info { flex: 1; }
.most-selling-item .info h4 {
    color: var(--foreground);
    margin: 0 0 6px 0;
    font-size: 1.1em;
    font-weight: 600;
}
.most-selling-item .info p {
    color: var(--muted-foreground);
    font-size: 0.9em;
    margin: 0;
}

/* Low Stock Items */
.low-stock-list {
    max-height: 220px;
    overflow-y: auto;
}

.low-stock-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 14px 16px;
    margin-bottom: 8px;
    background: var(--muted);
    border-radius: 10px;
    border-left: 4px solid var(--destructive);
    transition: all 0.2s ease;
}

.low-stock-item:hover {
    background: var(--accent);
    transform: translateX(4px);
    box-shadow: var(--shadow-sm);
}

.low-stock-item:last-child {
    margin-bottom: 0;
}
a.low-stock-item {
    text-decoration: none;
    color: inherit;
    cursor: pointer;
}

.low-stock-item .item-name {
    font-weight: 500;
    color: var(--foreground);
    font-size: 0.95em;
}

.low-stock-item .stock-count {
    color: var(--destructive);
    font-weight: 700;
    font-size: 1em;
    padding: 4px 12px;
    background: rgba(220, 38, 38, 0.1);
    border-radius: 20px;
}

.low-stock-empty {
    text-align: center;
    padding: 40px 20px;
    color: var(--muted-foreground);
}

/* Stats Grid */
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 20px;
    margin-top: 24px;
}

.stat-card {
    background: var(--card);
    border-radius: var(--radius-lg);
    padding: 24px;
    box-shadow: var(--shadow-lg);
    border: 1px solid var(--border);
    text-align: center;
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
}

.stat-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg, var(--primary), var(--accent-foreground));
}

.stat-card:nth-child(1)::before {
    background: linear-gradient(90deg, #3b82f6, #60a5fa);
}

.stat-card:nth-child(2)::before {
    background: linear-gradient(90deg, #10b981, #34d399);
}

.stat-card:nth-child(3)::before {
    background: linear-gradient(90deg, #f59e0b, #fbbf24);
}

.stat-card:nth-child(4)::before {
    background: linear-gradient(90deg, #8b5cf6, #a78bfa);
}

.stat-card:nth-child(5)::before {
    background: linear-gradient(90deg, #ec4899, #f472b6);
}

.stat-card:hover {
    transform: translateY(-6px);
    box-shadow: var(--shadow-xl);
}

.stat-card .number {
    font-size: 2.5em;
    font-weight: 700;
    margin-bottom: 8px;
    line-height: 1;
    word-wrap: break-word;
    overflow-wrap: break-word;
}

.stat-card:nth-child(1) .number {
    color: #3b82f6;
}

.stat-card:nth-child(2) .number {
    color: #10b981;
}

.stat-card:nth-child(3) .number {
    color: #f59e0b;
}

.stat-card:nth-child(4) .number {
    color: #8b5cf6;
}

.stat-card:nth-child(5) .number {
    color: #ec4899;
}

.stat-card p {
    color: var(--muted-foreground);
    font-size: 0.95em;
    margin: 0;
    font-weight: 500;
}

/* Scrollbar Styling */
.low-stock-list::-webkit-scrollbar {
    width: 6px;
}

.low-stock-list::-webkit-scrollbar-track {
    background: var(--muted);
    border-radius: 10px;
}

.low-stock-list::-webkit-scrollbar-thumb {
    background: var(--primary);
    border-radius: 10px;
}

.low-stock-list::-webkit-scrollbar-thumb:hover {
    background: var(--accent-foreground);
}

/* Charts Section */
.charts-section {
    margin-top: 44px;
}
.charts-section h3 {
    font-size: 1.3em;
    color: var(--foreground);
    margin-bottom: 20px;
    font-weight: 600;
}
.charts-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 24px;
}
.chart-card {
    background: var(--card);
    border-radius: var(--radius-lg);
    padding: 24px;
    box-shadow: var(--shadow-lg);
    border: 1px solid var(--border);
    transition: all 0.3s ease;
}
.chart-card:hover {
    box-shadow: var(--shadow-xl);
}
.chart-card h4 {
    margin: 0 0 16px 0;
    font-size: 1.05em;
    color: var(--foreground);
    font-weight: 600;
}
.chart-container {
    position: relative;
    height: 280px;
}
.chart-container.chart-sm { height: 240px; }

/* Responsive */
@media (max-width: 900px) {
    .cards-grid {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 768px) {
    .container {
        margin-left: 0;
        padding: 20px;
    }
    
    .cards-grid {
        grid-template-columns: 1fr;
        gap: 20px;
    }
    
    .stats-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
    }
    
    .charts-grid {
        grid-template-columns: 1fr;
    }
    .chart-container { height: 260px; }
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp" class="active">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Store Dashboard</h2>
    <p class="dashboard-subtitle">Welcome back! Here's an overview of your store performance.</p>
    
    <!-- Key Performance Cards -->
    <div class="cards-grid">
        <div class="card">
            <div class="card-header">
                <h3>Total Revenue</h3>
            </div>
            <div class="number" style="font-size: 1.8em;">LKR <%= formattedRevenue %></div>
            <div class="label">Total sales from all orders</div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h3>Low Stock Items</h3>
            </div>
            <div class="low-stock-list">
                <% if (lowStockProducts != null && !lowStockProducts.isEmpty()) { 
                    int displayCount = 0;
                    for (Product product : lowStockProducts) {
                        if (displayCount >= 5) break; // Show max 5 items
                        
                        int totalStock = product.getQuantity();
                        // Check variants if exists
                        try {
                            List<ProductVariant> variants = variantDAO.getVariantsByProductId(product.getProductId());
                            if (variants != null && !variants.isEmpty()) {
                                totalStock = 0;
                                for (ProductVariant variant : variants) {
                                    totalStock += variant.getQuantity();
                                }
                            }
                        } catch (Exception e) {
                            // Use product quantity if variant check fails
                        }
                %>
                    <a class="low-stock-item" href="${pageContext.request.contextPath}/pages/dashboards/storedash/editProduct.jsp?productId=<%= product.getProductId() %>">
                        <span class="item-name"><%= product.getName() %></span>
                        <span class="stock-count"><%= totalStock %> left</span>
                    </a>
                <% 
                        displayCount++;
                    } 
                } else { %>
                    <div class="low-stock-empty">
                        <p style="font-weight: 500; margin-bottom: 4px;">All stocked!</p>
                        <p style="font-size: 0.9em;">No low stock items to display</p>
                    </div>
                <% } %>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h3>Total Products</h3>
            </div>
            <div class="number"><%= allProducts != null ? allProducts.size() : 0 %></div>
            <div class="label">Products in your store</div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h3>Most Selling Item</h3>
            </div>
            <% if (mostSellingProduct != null && topSales != null) { 
                String imgBase64 = mostSellingProduct.getImageBase64();
                String imgSrc = (imgBase64 != null && !imgBase64.isEmpty()) 
                    ? "data:image/jpeg;base64," + imgBase64 
                    : request.getContextPath() + "/assets/images/power-drill.png";
            %>
                <div class="most-selling-item">
                    <img src="<%= imgSrc %>" alt="<%= mostSellingProduct.getName() %>">
                    <div class="info">
                        <h4><%= mostSellingProduct.getName() %></h4>
                        <p><%= topSales.getQuantitySold() %> units sold</p>
                    </div>
                </div>
            <% } else { %>
                <div class="most-selling-item">
                    <img src="${pageContext.request.contextPath}/assets/images/power-drill.png" alt="No sales">
                    <div class="info">
                        <h4>No sales yet</h4>
                        <p>Top seller will appear here</p>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <!-- General Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="number"><%= allStoreOrders != null ? allStoreOrders.size() + (completedOrders != null ? completedOrders.size() : 0) : 0 %></div>
            <p>Total Orders</p>
        </div>
        <div class="stat-card">
            <div class="number"><%= completedOrders != null ? completedOrders.size() : 0 %></div>
            <p>Completed Orders</p>
        </div>
        <div class="stat-card">
            <div class="number"><%= pendingOrders != null ? pendingOrders.size() : 0 %></div>
            <p>Pending Orders</p>
        </div>
        <div class="stat-card">
            <div class="number"><%= processingOrders != null ? processingOrders.size() : 0 %></div>
            <p>Processing Orders</p>
        </div>
        <div class="stat-card">
            <div class="number"><%= outForDeliveryOrders != null ? outForDeliveryOrders.size() : 0 %></div>
            <p>Up for Delivery</p>
        </div>
    </div>

    <!-- Charts -->
    <section class="charts-section">
        <h3>Analytics</h3>
        <div class="charts-grid">
            <div class="chart-card">
                <h4>Order Status</h4>
                <div class="chart-container chart-sm">
                    <canvas id="chartOrderStatus"></canvas>
                </div>
            </div>
            <div class="chart-card">
                <h4>Orders & Revenue (Last 7 Days)</h4>
                <div class="chart-container">
                    <canvas id="chartOrdersOverTime"></canvas>
                </div>
            </div>
            <div class="chart-card">
                <h4>Most Selling Items</h4>
                <div class="chart-container chart-sm">
                    <canvas id="chartMostSelling"></canvas>
                </div>
            </div>
        </div>
    </section>
</main>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
<script>
(function() {
    var isDark = document.documentElement.classList.contains('dark');
    var textColor = isDark ? 'rgba(255,255,255,0.9)' : 'rgba(0,0,0,0.8)';
    var gridColor = isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.08)';
    
    // 1. Order Status (doughnut)
    var statusData = {
        labels: ['Pending', 'Processing', 'Out for Delivery', 'Delivered'],
        datasets: [{
            data: [<%= pendingCount %>, <%= processingCount %>, <%= outForDeliveryCount %>, <%= deliveredCount %>],
            backgroundColor: ['#f59e0b', '#ec4899', '#06b6d4', '#10b981'],
            borderWidth: 0
        }]
    };
    if (document.getElementById('chartOrderStatus')) {
        new Chart(document.getElementById('chartOrderStatus'), {
            type: 'doughnut',
            data: statusData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom', labels: { color: textColor, padding: 16 } }
                }
            }
        });
    }
    
    // 2. Orders & Revenue last 7 days (bar + line)
    var dayLabels = [<%= "\"" + String.join("\",\"", dayLabels) + "\"" %>];
    var orderCounts = [<%= orderCountsJs.toString() %>];
    var revenueByDay = [<%= revenueByDayJs.toString() %>];
    if (document.getElementById('chartOrdersOverTime')) {
        new Chart(document.getElementById('chartOrdersOverTime'), {
            type: 'bar',
            data: {
                labels: dayLabels,
                datasets: [
                    { label: 'Orders', data: orderCounts, backgroundColor: 'rgba(59,130,246,0.7)', borderColor: '#3b82f6', borderWidth: 1, yAxisID: 'y' },
                    { label: 'Revenue (LKR)', data: revenueByDay, type: 'line', borderColor: '#8b5cf6', backgroundColor: 'rgba(139,92,246,0.1)', fill: true, tension: 0.3, yAxisID: 'y1' }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: { beginAtZero: true, grid: { color: gridColor }, ticks: { color: textColor, stepSize: 1 } },
                    y1: { beginAtZero: true, position: 'right', grid: { drawOnChartArea: false }, ticks: { color: textColor, callback: function(v) { return v >= 1000 ? (v/1000)+'k' : v; } } },
                    x: { grid: { color: gridColor }, ticks: { color: textColor, maxRotation: 45 } }
                },
                plugins: { legend: { position: 'top', labels: { color: textColor } } }
            }
        });
    }
    
    // 3. Most selling items (horizontal bar)
    var mostSelling = <%= mostSellingJson.toString() %>;
    var sellLabels = mostSelling.map(function(x) { return x.name.length > 20 ? x.name.substring(0,19)+'\u2026' : x.name; });
    var sellQtys = mostSelling.map(function(x) { return x.qty; });
    if (mostSelling.length === 0) {
        sellLabels = ['No sales yet'];
        sellQtys = [0];
    }
    if (document.getElementById('chartMostSelling')) {
        new Chart(document.getElementById('chartMostSelling'), {
            type: 'bar',
            data: {
                labels: sellLabels,
                datasets: [{
                    label: 'Units sold',
                    data: sellQtys,
                    backgroundColor: 'rgba(59,130,246,0.6)',
                    borderColor: '#3b82f6',
                    borderWidth: 1
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: { beginAtZero: true, grid: { color: gridColor }, ticks: { color: textColor, stepSize: 1 } },
                    y: { grid: { display: false }, ticks: { color: textColor } }
                },
                plugins: { legend: { display: false } }
            }
        });
    }
})();
</script>

</body>
</html>

