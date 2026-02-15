<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Fixer</title>
    <!-- Link to external stylesheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cutting_tool.css">
</head>
<body>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Fixer - Fix, Learn, Restore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/product_details.css">
</head>
    <body>
    <!-- Navigation -->
    <nav id="navbar">
        <div class="nav-container">
            <div class="logo">Daily Fixer</div>
            <ul class="nav-links">
                <li><a href="${pageContext.request.contextPath}/diagnostic.jsp">Diagnostic Tool</a></li>
                <li><a href="${pageContext.request.contextPath}/listguides.jsp">View Repair Guides</a></li>
                <li><a href="${pageContext.request.contextPath}/findtech.jsp">Book a Technician</a></li>
                <li><a href="${pageContext.request.contextPath}/store_main.jsp">Store</a></li>
            </ul>
            <div class="nav-buttons">
                <button class="btn-login">Login</button>
                <button class="btn-signup">Sign Up</button>
            </div>
        </div>
    </nav>

    <!-- Search Bar -->
  <section class="search-section">
    <h3 class="search-title">Find Cutting Tools</h3>
    <div class="search-box">
      <input type="text" placeholder="Search for a tool...">
      <button><img src="images/search.png" alt="Search"></button>
    </div>
  </section>

  <!-- Main Content -->
  <div class="cutting-tools-container">
    <!-- Left Card -->
    <div class="filter-card">
      <h3>Set Your Location</h3>
      <input type="text" placeholder="Enter your city or area">
      <button class="btn-set-location">Set Location</button>

      <h3>Sort Products</h3>
      <select>
        <option>Default</option>
        <option>Price: Low to High</option>
        <option>Price: High to Low</option>
        <option>Newest</option>
      </select>
    </div>

    <!-- Right Card -->
    <div class="product-list-card">
      <h3>Available Cutting Tools</h3>
      <div class="product-grid">
        <div class="product-card">
          <img src="${pageContext.request.contextPath}/assets/images/glass_cutter.jpg" alt="Glass Cutter">
          <h4>Glass Cutter</h4>
          <p class="desc">High-precision cutting tool for glass and tiles.</p>
          <p class="price">Rs. 1,200</p>
          <button class="btn-buy" onclick="viewDetails('${pageContext.request.contextPath}/product_details.jsp')">View Details</button>
        </div>
        <div class="product-card">
          <img src="${pageContext.request.contextPath}/assets/images/hackshaw.jpg" alt="Hacksaw">
          <h4>Hacksaw</h4>
          <p class="desc">Durable steel frame with ergonomic grip for cutting glass.</p>
          <p class="price">Rs. 2,100</p>
          <button class="btn-buy">View Details</button>
        </div>
        <div class="product-card">
          <img src="${pageContext.request.contextPath}/assets/images/utilityKnife.jpg" alt="Utility Knife">
          <h4>Utility Knife</h4>
          <p class="desc">Compact retractable blade for versatile use.</p>
          <p class="price">Rs. 950</p>
          <button class="btn-buy">View Details</button>
        </div>
        <div class="product-card">
          <img src="${pageContext.request.contextPath}/assets/images/tileCutter.jpg" alt="Tile Cutter">
          <h4>Tile Cutter</h4>
          <p class="desc">Perfect tool for ceramic and marble tile cutting.</p>
          <p class="price">Rs. 4,300</p>
          <button class="btn-buy">View Details</button>
        </div>

        <div class="product-card">
          <img src="${pageContext.request.contextPath}/assets/images/circulatCutter.jpg" alt="Circular Saw">
          <h4>Circular Saw</h4>
          <p class="desc">Powerful saw ideal for wood and metal cutting tasks.</p>
          <p class="price">Rs. 8,900</p>
          <button class="btn-buy">View Details</button>
        </div>

        <div class="product-card">
          <img src="${pageContext.request.contextPath}/assets/images/wireCutter.jpg" alt="Wire Cutter">
          <h4>Wire Cutter</h4>
          <p class="desc">Precision tool for clean and safe wire cutting.</p>
          <p class="price">Rs. 1,450</p>
          <button class="btn-buy">View Details</button>
        </div>
      </div>
    </div>
  </div>
<script>
    function viewDetails(page) {
  // Redirects to another page (e.g., product-details.html)
  window.location.href = page;
}
</script>
</body>
</html>
