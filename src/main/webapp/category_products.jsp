<%@ page import="java.util.List" %>
    <%@ page import="java.util.ArrayList" %>
        <%@ page import="com.dailyfixer.model.Product" %>
            <%@ page import="com.dailyfixer.model.Store" %>
                <%@ page import="com.dailyfixer.model.ProductVariant" %>
                <%@ page import="com.dailyfixer.model.User" %>
                <%@ page import="com.dailyfixer.dao.StoreDAO" %>
                <%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>

                    <% double userLat=0; double userLng=0; boolean hasLocationFilter=false; List<Product> products =
                        (List<Product>) request.getAttribute("products");
                            String categoryName = (String) request.getAttribute("category");
                            String searchTerm = (String) request.getAttribute("searchTerm");
                            String searchType = (String) request.getAttribute("searchType");
                            boolean isSearch = (searchTerm != null && !searchTerm.isEmpty());
                            
                            // Set display title based on search or category
                            String displayTitle = categoryName;
                            if (isSearch && "product".equals(searchType)) {
                                displayTitle = "Search Results for \"" + searchTerm + "\"";
                            } else if (isSearch && "category".equals(searchType)) {
                                displayTitle = categoryName + " (Category)";
                            }

                            // Apply location filter if coordinates are provided
                            if (request.getParameter("lat") != null && request.getParameter("lng") != null && products
                            != null) {
                            userLat = Double.parseDouble(request.getParameter("lat"));
                            userLng = Double.parseDouble(request.getParameter("lng"));
                            hasLocationFilter = true;
                            StoreDAO storeDAO = new StoreDAO();
                            List<Product> filteredProducts = new ArrayList<>();

                                    for (Product prod : products) {
                                    Store store = storeDAO.getStoreById(prod.getStoreId());
                                    if (store != null) {
                                    double R = 6371; // Earth radius km
                                    double dLat = Math.toRadians(store.getLatitude() - userLat);
                                    double dLng = Math.toRadians(store.getLongitude() - userLng);
                                    double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                                    + Math.cos(Math.toRadians(userLat)) * Math.cos(Math.toRadians(store.getLatitude()))
                                    * Math.sin(dLng / 2) * Math.sin(dLng / 2);
                                    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                                    double distance = R * c;
                                    if (distance <= 10) { filteredProducts.add(prod); } } } products=filteredProducts; }
                                    
                                    // Check if user is logged in
                                    User currentUser = (User) session.getAttribute("currentUser");
                                    boolean isLoggedIn = (currentUser != null);
                                        %>

                                        <!DOCTYPE html>
                                        <html lang="en">

                                        <head>
                                            <meta charset="UTF-8">
                                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                            <title>Daily Fixer - <%= categoryName %>
                                            </title>
                                            <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
                                            <link rel="stylesheet"
                                                href="${pageContext.request.contextPath}/assets/css/cutting_tool.css">
                                            <jsp:include page="fragment_cart.jsp" />
                                            <style>
/* Framework CSS Variables */
:root {
  --background: oklch(0.9940 0 0);
  --foreground: oklch(0 0 0);
  --card: oklch(0.9940 0 0);
  --card-foreground: oklch(0 0 0);
  --popover: oklch(0.9911 0 0);
  --popover-foreground: oklch(0 0 0);
  --primary: oklch(0.5393 0.2713 286.7462);
  --primary-foreground: oklch(1.0000 0 0);
  --secondary: oklch(0.9540 0.0063 255.4755);
  --secondary-foreground: oklch(0.1344 0 0);
  --muted: oklch(0.9702 0 0);
  --muted-foreground: oklch(0.4386 0 0);
  --accent: oklch(0.9393 0.0288 266.3680);
  --accent-foreground: oklch(0.5445 0.1903 259.4848);
  --destructive: oklch(0.6290 0.1902 23.0704);
  --destructive-foreground: oklch(1.0000 0 0);
  --border: oklch(0.9300 0.0094 286.2156);
  --input: oklch(0.9401 0 0);
  --ring: oklch(0 0 0);
  --chart-1: oklch(0.7459 0.1483 156.4499);
  --chart-2: oklch(0.5393 0.2713 286.7462);
  --chart-3: oklch(0.7336 0.1758 50.5517);
  --chart-4: oklch(0.5828 0.1809 259.7276);
  --chart-5: oklch(0.5590 0 0);
  --sidebar: oklch(0.9777 0.0051 247.8763);
  --sidebar-foreground: oklch(0 0 0);
  --sidebar-primary: oklch(0 0 0);
  --sidebar-primary-foreground: oklch(1.0000 0 0);
  --sidebar-accent: oklch(0.9401 0 0);
  --sidebar-accent-foreground: oklch(0 0 0);
  --sidebar-border: oklch(0.9401 0 0);
  --sidebar-ring: oklch(0 0 0);
  --font-sans: 'Plus Jakarta Sans', 'Inter', sans-serif;
  --font-serif: 'Lora', serif;
  --font-mono: 'IBM Plex Mono', monospace;
  --radius: 1.4rem;
  --shadow-x: 0px;
  --shadow-y: 2px;
  --shadow-blur: 3px;
  --shadow-spread: 0px;
  --shadow-opacity: 0.16;
  --shadow-color: hsl(0 0% 0%);
  --shadow-2xs: 0px 2px 3px 0px hsl(0 0% 0% / 0.08);
  --shadow-xs: 0px 2px 3px 0px hsl(0 0% 0% / 0.08);
  --shadow-sm: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 1px 2px -1px hsl(0 0% 0% / 0.16);
  --shadow: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 1px 2px -1px hsl(0 0% 0% / 0.16);
  --shadow-md: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 2px 4px -1px hsl(0 0% 0% / 0.16);
  --shadow-lg: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 4px 6px -1px hsl(0 0% 0% / 0.16);
  --shadow-xl: 0px 2px 3px 0px hsl(0 0% 0% / 0.16), 0px 8px 10px -1px hsl(0 0% 0% / 0.16);
  --shadow-2xl: 0px 2px 3px 0px hsl(0 0% 0% / 0.40);
  --tracking-normal: -0.025em;
  --spacing: 0.27rem;
}

.dark {
  --background: oklch(0.2223 0.0060 271.1393);
  --foreground: oklch(0.9551 0 0);
  --card: oklch(0.2568 0.0076 274.6528);
  --card-foreground: oklch(0.9551 0 0);
  --popover: oklch(0.2568 0.0076 274.6528);
  --popover-foreground: oklch(0.9551 0 0);
  --primary: oklch(0.6132 0.2294 291.7437);
  --primary-foreground: oklch(1.0000 0 0);
  --secondary: oklch(0.2940 0.0130 272.9312);
  --secondary-foreground: oklch(0.9551 0 0);
  --muted: oklch(0.2940 0.0130 272.9312);
  --muted-foreground: oklch(0.7058 0 0);
  --accent: oklch(0.2795 0.0368 260.0310);
  --accent-foreground: oklch(0.7857 0.1153 246.6596);
  --destructive: oklch(0.7106 0.1661 22.2162);
  --destructive-foreground: oklch(1.0000 0 0);
  --border: oklch(0.3289 0.0092 268.3843);
  --input: oklch(0.3289 0.0092 268.3843);
  --ring: oklch(0.6132 0.2294 291.7437);
  --chart-1: oklch(0.8003 0.1821 151.7110);
  --chart-2: oklch(0.6132 0.2294 291.7437);
  --chart-3: oklch(0.8077 0.1035 19.5706);
  --chart-4: oklch(0.6691 0.1569 260.1063);
  --chart-5: oklch(0.7058 0 0);
  --sidebar: oklch(0.2011 0.0039 286.0396);
  --sidebar-foreground: oklch(0.9551 0 0);
  --sidebar-primary: oklch(0.6132 0.2294 291.7437);
  --sidebar-primary-foreground: oklch(1.0000 0 0);
  --sidebar-accent: oklch(0.2940 0.0130 272.9312);
  --sidebar-accent-foreground: oklch(0.6132 0.2294 291.7437);
  --sidebar-border: oklch(0.3289 0.0092 268.3843);
  --sidebar-ring: oklch(0.6132 0.2294 291.7437);
}

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);
  --color-popover: var(--popover);
  --color-popover-foreground: var(--popover-foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-secondary: var(--secondary);
  --color-secondary-foreground: var(--secondary-foreground);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-destructive: var(--destructive);
  --color-destructive-foreground: var(--destructive-foreground);
  --color-border: var(--border);
  --color-input: var(--input);
  --color-ring: var(--ring);
  --color-chart-1: var(--chart-1);
  --color-chart-2: var(--chart-2);
  --color-chart-3: var(--chart-3);
  --color-chart-4: var(--chart-4);
  --color-chart-5: var(--chart-5);
  --color-sidebar: var(--sidebar);
  --color-sidebar-foreground: var(--sidebar-foreground);
  --color-sidebar-primary: var(--sidebar-primary);
  --color-sidebar-primary-foreground: var(--sidebar-primary-foreground);
  --color-sidebar-accent: var(--sidebar-accent);
  --color-sidebar-accent-foreground: var(--sidebar-accent-foreground);
  --color-sidebar-border: var(--sidebar-border);
  --color-sidebar-ring: var(--sidebar-ring);

  --font-sans: var(--font-sans);
  --font-mono: var(--font-mono);
  --font-serif: var(--font-serif);

  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);

  --shadow-2xs: var(--shadow-2xs);
  --shadow-xs: var(--shadow-xs);
  --shadow-sm: var(--shadow-sm);
  --shadow: var(--shadow);
  --shadow-md: var(--shadow-md);
  --shadow-lg: var(--shadow-lg);
  --shadow-xl: var(--shadow-xl);
  --shadow-2xl: var(--shadow-2xl);

  --tracking-tighter: calc(var(--tracking-normal) - 0.05em);
  --tracking-tight: calc(var(--tracking-normal) - 0.025em);
  --tracking-normal: var(--tracking-normal);
  --tracking-wide: calc(var(--tracking-normal) + 0.025em);
  --tracking-wider: calc(var(--tracking-normal) + 0.05em);
  --tracking-widest: calc(var(--tracking-normal) + 0.1em);
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--font-sans);
  background-color: var(--background);
  color: var(--foreground);
  letter-spacing: var(--tracking-normal);
  transition: background-color 0.3s ease, color 0.3s ease;
  min-height: 100vh;
}

/* Dark Mode Toggle Button */
.theme-toggle {
  padding: 0.5rem 1rem;
  background: var(--secondary);
  border: 1px solid var(--border);
  color: var(--secondary-foreground);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 500;
  font-size: 0.85rem;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  margin-right: 10px;
}

.theme-toggle:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

/* Public Navigation Styles */
nav.public-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  background-color: rgba(255, 255, 255, 0.1);
  border-bottom: 1px solid rgba(139, 125, 216, 0.2);
  transition: all 0.3s ease;
}

.dark nav.public-nav {
  background-color: rgba(34, 35, 48, 0.1);
  border-bottom: 1px solid rgba(139, 125, 216, 0.2);
}

nav.public-nav.scrolled {
  background-color: rgba(255, 255, 255, 0.15);
  box-shadow: var(--shadow-md);
}

.dark nav.public-nav.scrolled {
  background-color: rgba(34, 35, 48, 0.15);
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

nav.public-nav .logo {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary);
  text-decoration: none;
}

.nav-links {
  display: flex;
  gap: 2rem;
  list-style: none;
  align-items: center;
}

.nav-links a {
  text-decoration: none;
  color: var(--foreground);
  font-size: 0.95rem;
  font-weight: 500;
  transition: color 0.3s ease;
  position: relative;
}

.nav-links a:hover {
  color: var(--primary);
}

.nav-links a::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 0;
  width: 0;
  height: 2px;
  background: var(--primary);
  transition: width 0.3s ease;
}

.nav-links a:hover::after {
  width: 100%;
}

.nav-buttons {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.btn-login, .btn-logout {
  padding: 0.6rem 1.2rem;
  background: transparent;
  border: 1.5px solid var(--primary);
  color: var(--primary);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  font-size: 0.9rem;
  text-decoration: none;
  display: inline-block;
}

.btn-login:hover, .btn-logout:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

.btn-signup {
  padding: 0.6rem 1.2rem;
  background: var(--primary);
  border: none;
  color: var(--primary-foreground);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  font-size: 0.9rem;
  box-shadow: var(--shadow-sm);
  text-decoration: none;
  display: inline-block;
}

.btn-signup:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  opacity: 0.9;
}

/* Responsive */
@media (max-width: 768px) {
  .nav-links {
    gap: 1rem;
    font-size: 0.85rem;
  }

  .nav-container {
    padding: 1rem;
  }
}
                                                #location-map {
                                                    width: 100%;
                                                    height: 200px;
                                                    border-radius: 10px;
                                                    margin: 12px 0;
                                                    border: 2px solid #e0e0e0;
                                                }

                                                .location-status {
                                                    background: #f5f5f5;
                                                    padding: 10px;
                                                    border-radius: 8px;
                                                    font-size: 12px;
                                                    margin-top: 8px;
                                                }

                                                .location-status.active {
                                                    background: #e8f5e9;
                                                    color: #2e7d32;
                                                }

                                                .map-hint {
                                                    font-size: 11px;
                                                    color: #666;
                                                    margin-top: 6px;
                                                    background: #fff3e0;
                                                    padding: 6px 8px;
                                                    border-radius: 4px;
                                                }

                                                .filter-card h3 {
                                                    margin-top: 0;
                                                    margin-bottom: 10px;
                                                }

                                                .filter-card input[type="text"] {
                                                    width: 100%;
                                                    padding: 10px;
                                                    border-radius: 8px;
                                                    border: 1px solid #ccc;
                                                    box-sizing: border-box;
                                                    margin-bottom: 8px;
                                                }

                                                .filter-card button {
                                                    width: 100%;
                                                    padding: 10px;
                                                    border-radius: 8px;
                                                    border: none;
                                                    cursor: pointer;
                                                    margin-bottom: 6px;
                                                    font-weight: 500;
                                                }

                                                #btn-set-location {
                                                    background: #4CAF50;
                                                    color: white;
                                                }

                                                #btn-set-location:hover {
                                                    background: #43A047;
                                                }

                                                #btn-use-current-location {
                                                    background: #2196F3;
                                                    color: white;
                                                }

                                                #btn-use-current-location:hover {
                                                    background: #1976D2;
                                                }

                                                #btn-clear-location {
                                                    background: #ff5722;
                                                    color: white;
                                                }

                                                #btn-clear-location:hover {
                                                    background: #e64a19;
                                                }

                                                .filter-card select {
                                                    width: 100%;
                                                    padding: 10px;
                                                    border-radius: 8px;
                                                    border: 1px solid #ccc;
                                                    box-sizing: border-box;
                                                }

                                                #btn-clear-filters {
                                                    background: #9e9e9e;
                                                    color: white;
                                                    margin-top: 12px;
                                                }
                                            </style>
                                        </head>

                                        <body>

                                            <nav id="navbar" class="public-nav">
                                                <div class="nav-container">
                                                    <a href="${pageContext.request.contextPath}/index.jsp" class="logo">Daily Fixer</a>
                                                    <ul class="nav-links">
                                                        <li><a href="${pageContext.request.contextPath}/diagnostic.jsp">Diagnostic
                                                                Tool</a></li>
                                                        <li><a href="${pageContext.request.contextPath}/listguides.jsp">View
                                                                Repair Guides</a></li>
                                                        <li><a href="${pageContext.request.contextPath}/findtech.jsp">Book
                                                                a Technician</a></li>
                                                        <li><a
                                                                href="${pageContext.request.contextPath}/store_main.jsp">Store</a>
                                                        </li>
                                                    </ul>
                                                    <div class="nav-buttons">
                                                        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
                                                        <% if (isLoggedIn) { %>
                                                            <form action="${pageContext.request.contextPath}/logout" method="post" style="margin: 0; display: inline;">
                                                                <button type="submit" class="btn-logout">Logout</button>
                                                            </form>
                                                        <% } else { %>
                                                            <a href="${pageContext.request.contextPath}/login.jsp" class="btn-login">Login</a>
                                                            <a href="${pageContext.request.contextPath}/registerUser.jsp" class="btn-signup">Sign Up</a>
                                                        <% } %>
                                                    </div>
                                                </div>
                                            </nav>

                                            <section class="search-section">
                                                <h3 class="search-title">
                                                    <% if (isSearch) { %>
                                                        <%= displayTitle %>
                                                    <% } else { %>
                                                        Find <%= categoryName %>
                                                    <% } %>
                                                </h3>
                                                <form action="${pageContext.request.contextPath}/search" method="get" style="display: contents;">
                                                    <div class="search-box">
                                                        <input id="search-input" type="text" name="q"
                                                            placeholder="Search for a tool or category..." 
                                                            value="<%= searchTerm != null ? searchTerm : "" %>">
                                                        <button type="submit" id="search-btn"><img
                                                                src="${pageContext.request.contextPath}/assets/images/search.png"
                                                                alt="Search"></button>
                                                    </div>
                                                </form>
                                            </section>

                                            <div class="cutting-tools-container">

                                                <!-- Filter Card with Map -->
                                                <div class="filter-card" data-page-url="<%= request.getRequestURI() %>"
                                                    data-category="<%= categoryName %>">

                                                    <h3>Set Your Location</h3>

                                                    <!-- Search Input with Autocomplete -->
                                                    <input id="location-input" type="text"
                                                        placeholder="Search for your location...">

                                                    <!-- Interactive Map -->
                                                    <div id="location-map"></div>

                                                    <div class="map-hint">
                                                        Type an address above OR click on the map to set location
                                                    </div>

                                                    <!-- Location Action Buttons -->
                                                    <button id="btn-set-location">Apply Location Filter</button>
                                                    <button id="btn-use-current-location">Use My Current
                                                        Location</button>
                                                    <button id="btn-clear-location">Clear Location</button>

                                                    <!-- Location Status -->
                                                    <div id="location-status"
                                                        class="location-status<%= hasLocationFilter ? " active" : "" %>
                                                        ">
                                                        <% if (hasLocationFilter) { %>
                                                            Showing products within 10km of your location
                                                            <% } else { %>
                                                                No location filter applied. Showing all products.
                                                                <% } %>
                                                    </div>

                                                    <h3 style="margin-top:16px;">Sort Products</h3>
                                                    <select id="sort-products">
                                                        <option value="default">Default</option>
                                                        <option value="price-asc">Price: Low to High</option>
                                                        <option value="price-desc">Price: High to Low</option>
                                                    </select>

                                                    <button id="btn-clear-filters">Clear All Filters</button>
                                                </div>

                                                <!-- Product List -->
                                                <div class="product-list-card">
                                                    <h3>
                                                        <% if (isSearch && "product".equals(searchType)) { %>
                                                            Products matching "<%= searchTerm %>"
                                                        <% } else if (isSearch && "category".equals(searchType)) { %>
                                                            All Products in <%= categoryName %>
                                                        <% } else { %>
                                                            Available <%= categoryName %>
                                                        <% } %>
                                                    </h3>
                                                    <div class="product-grid" id="product-grid">
                                                        <% if (products !=null && !products.isEmpty()) { for (Product
                                                            item : products) { 
                                                            // Get display price - use first variant price if main price is 0.00
                                                            double displayPrice = item.getPrice().doubleValue();
                                                            if (item.getPrice().doubleValue() == 0.00) {
                                                                try {
                                                                    ProductVariantDAO variantDAO = new ProductVariantDAO();
                                                                    List<ProductVariant> variants = variantDAO.getVariantsByProductId(item.getProductId());
                                                                    if (variants != null && !variants.isEmpty() && variants.get(0).getPrice() != null) {
                                                                        displayPrice = variants.get(0).getPrice().doubleValue();
                                                                    }
                                                                } catch (Exception e) {
                                                                    // If error getting variants, use main price
                                                                }
                                                            }
                                                            %>
                                                            <div class="product-card"
                                                                data-name="<%= item.getName().toLowerCase() %>"
                                                                data-price="<%= displayPrice %>">
                                                                <img src="data:image/jpeg;base64,<%= item.getImageBase64() %>"
                                                                    alt="<%= item.getName() %>">
                                                                <h4>
                                                                    <%= item.getName() %>
                                                                </h4>
                                                                <p class="desc">
                                                                    <%= item.getDescription() %>
                                                                </p>
                                                                <p class="price">Rs. <%= String.format("%.2f", displayPrice) %>
                                                                </p>
                                                                <button class="btn-buy"
                                                                    onclick="window.location.href='product_details.jsp?productId=<%= item.getProductId() %>'">
                                                                    View Details
                                                                </button>
                                                            </div>
                                                            <% } } else { %>
                                                                <p id="no-products">No products available in this
                                                                    category.</p>
                                                                <% } %>
                                                    </div>
                                                </div>

                                            </div>

                                            <!-- Google Maps API with Places -->
                                            <script
                                                src="https://maps.googleapis.com/maps/api/js?key=AIzaSyA8zSes6UGbYKIHNzCp3tny5RgccFruILI&libraries=places&callback=initLocationMap"
                                                async defer></script>

                                            <script>
                                                var map;
                                                var marker;
                                                var geocoder;
                                                var autocomplete;
                                                var selectedLat = null;
                                                var selectedLng = null;

                                                // Get current filter values from URL
                                                var urlParams = new URLSearchParams(window.location.search);
                                                var currentLat = urlParams.get('lat');
                                                var currentLng = urlParams.get('lng');
                                                var category = '<%= categoryName %>';

                                                function initLocationMap() {
                                                    // Default center: Sri Lanka
                                                    var defaultCenter = { lat: 7.8731, lng: 80.7718 };
                                                    var defaultZoom = 8;

                                                    // If there's an existing filter, center on that location
                                                    if (currentLat && currentLng) {
                                                        defaultCenter = { lat: parseFloat(currentLat), lng: parseFloat(currentLng) };
                                                        defaultZoom = 13;
                                                        selectedLat = parseFloat(currentLat);
                                                        selectedLng = parseFloat(currentLng);
                                                    }

                                                    map = new google.maps.Map(document.getElementById('location-map'), {
                                                        center: defaultCenter,
                                                        zoom: defaultZoom,
                                                        mapTypeControl: false,
                                                        streetViewControl: false,
                                                        fullscreenControl: false
                                                    });

                                                    geocoder = new google.maps.Geocoder();

                                                    // Create draggable marker
                                                    marker = new google.maps.Marker({
                                                        map: map,
                                                        draggable: true,
                                                        visible: currentLat && currentLng ? true : false,
                                                        position: defaultCenter,
                                                        animation: google.maps.Animation.DROP
                                                    });

                                                    // Click on map to set location
                                                    map.addListener('click', function (e) {
                                                        setLocation(e.latLng.lat(), e.latLng.lng());
                                                        reverseGeocode(e.latLng);
                                                    });

                                                    // Drag marker
                                                    marker.addListener('dragend', function (e) {
                                                        setLocation(e.latLng.lat(), e.latLng.lng());
                                                        reverseGeocode(e.latLng);
                                                    });

                                                    // Places Autocomplete
                                                    var input = document.getElementById('location-input');
                                                    autocomplete = new google.maps.places.Autocomplete(input, {
                                                        componentRestrictions: { country: 'lk' },
                                                        fields: ['geometry', 'formatted_address']
                                                    });

                                                    autocomplete.addListener('place_changed', function () {
                                                        var place = autocomplete.getPlace();
                                                        if (place.geometry) {
                                                            var lat = place.geometry.location.lat();
                                                            var lng = place.geometry.location.lng();
                                                            setLocation(lat, lng);
                                                            map.setCenter(place.geometry.location);
                                                            map.setZoom(14);
                                                            updateStatus('Location selected: ' + (place.formatted_address || 'Selected'), true);
                                                        }
                                                    });
                                                }

                                                function setLocation(lat, lng) {
                                                    selectedLat = lat;
                                                    selectedLng = lng;
                                                    var pos = new google.maps.LatLng(lat, lng);
                                                    marker.setPosition(pos);
                                                    marker.setVisible(true);
                                                    updateStatus('Lat: ' + lat.toFixed(4) + ', Lng: ' + lng.toFixed(4), true);
                                                }

                                                function reverseGeocode(latLng) {
                                                    geocoder.geocode({ location: latLng }, function (results, status) {
                                                        if (status === 'OK' && results[0]) {
                                                            document.getElementById('location-input').value = results[0].formatted_address;
                                                        }
                                                    });
                                                }

                                                function updateStatus(message, isActive) {
                                                    var statusDiv = document.getElementById('location-status');
                                                    statusDiv.textContent = isActive ? 'Selected: ' + message : message;
                                                    statusDiv.className = 'location-status' + (isActive ? ' active' : '');
                                                }

                                                window.addEventListener('load', function () {
                                                    var searchInput = document.getElementById('search-input');
                                                    var searchBtn = document.getElementById('search-btn');
                                                    var sortSelect = document.getElementById('sort-products');
                                                    var clearFiltersBtn = document.getElementById('btn-clear-filters');
                                                    var clearLocationBtn = document.getElementById('btn-clear-location');
                                                    var setLocationBtn = document.getElementById('btn-set-location');
                                                    var useCurrentBtn = document.getElementById('btn-use-current-location');
                                                    var productGrid = document.getElementById('product-grid');
                                                    var productCards = Array.from(productGrid.getElementsByClassName('product-card'));

                                                    // Apply sort only (search is now handled server-side via form submission)
                                                    function applySort() {
                                                        var sortVal = sortSelect ? sortSelect.value : 'default';
                                                        var sortedCards = Array.from(productCards);
                                                        
                                                        if (sortVal === 'price-asc') {
                                                            sortedCards.sort(function (a, b) { 
                                                                return parseFloat(a.dataset.price) - parseFloat(b.dataset.price); 
                                                            });
                                                        } else if (sortVal === 'price-desc') {
                                                            sortedCards.sort(function (a, b) { 
                                                                return parseFloat(b.dataset.price) - parseFloat(a.dataset.price); 
                                                            });
                                                        }

                                                        productGrid.innerHTML = '';
                                                        sortedCards.forEach(function (card) {
                                                            productGrid.appendChild(card);
                                                        });
                                                    }

                                                    // Sort functionality
                                                    if (sortSelect) {
                                                        sortSelect.addEventListener('change', applySort);
                                                    }
                                                    
                                                    // Search form will submit to /search servlet (handled by form action)

                                                    // Set location filter
                                                    if (setLocationBtn) {
                                                        setLocationBtn.addEventListener('click', function () {
                                                            if (selectedLat && selectedLng) {
                                                                window.location.href = '${pageContext.request.contextPath}/products?category=' + encodeURIComponent(category) +
                                                                    '&lat=' + selectedLat + '&lng=' + selectedLng;
                                                            } else {
                                                                alert('Please select a location on the map first.');
                                                            }
                                                        });
                                                    }

                                                    // Use current location
                                                    if (useCurrentBtn) {
                                                        useCurrentBtn.addEventListener('click', function () {
                                                            if (navigator.geolocation) {
                                                                useCurrentBtn.textContent = 'Getting location...';
                                                                navigator.geolocation.getCurrentPosition(
                                                                    function (position) {
                                                                        var lat = position.coords.latitude;
                                                                        var lng = position.coords.longitude;
                                                                        setLocation(lat, lng);
                                                                        map.setCenter({ lat: lat, lng: lng });
                                                                        map.setZoom(14);
                                                                        reverseGeocode(new google.maps.LatLng(lat, lng));
                                                                        useCurrentBtn.textContent = 'Use My Current Location';
                                                                    },
                                                                    function (error) {
                                                                        alert('Could not get your location. Please select manually.');
                                                                        useCurrentBtn.textContent = 'Use My Current Location';
                                                                    }
                                                                );
                                                            } else {
                                                                alert('Geolocation is not supported by your browser.');
                                                            }
                                                        });
                                                    }

                                                    // Clear filters
                                                    if (clearFiltersBtn) {
                                                        clearFiltersBtn.addEventListener('click', function () {
                                                            if (searchInput) searchInput.value = '';
                                                            if (sortSelect) sortSelect.value = 'default';
                                                            // Reset product grid to original order
                                                            productGrid.innerHTML = '';
                                                            productCards.forEach(function (card) { productGrid.appendChild(card); });
                                                        });
                                                    }

                                                    // Clear location
                                                    if (clearLocationBtn) {
                                                        clearLocationBtn.addEventListener('click', function () {
                                                            window.location.href = '${pageContext.request.contextPath}/products?category=' + encodeURIComponent(category);
                                                        });
                                                    }
                                                });
                                            </script>

<script>
    // Navbar scroll effect
    const navbar = document.getElementById('navbar');
    if (navbar) {
        window.addEventListener('scroll', function() {
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });
    }
</script>
<script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>

                                        </body>

                                        </html>