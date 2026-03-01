<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />
<%
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Fixer - Store</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/store_main.css">
    <style>
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

/* Theme toggle in public nav */
nav.public-nav .theme-toggle {
  margin-right: 0.5rem;
}

/* Public Navigation Styles (for non-dashboard pages) */
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
  color: oklch(0.6132 0.2294 291.7437);
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
    </style>
</head>

<body>
    <jsp:include page="fragment_cart.jsp" />

    <!-- Navigation -->
    <nav id="navbar" class="public-nav">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index.jsp" class="logo">Daily Fixer</a>
            <ul class="nav-links">
                <li><a href="${pageContext.request.contextPath}/pages/diagnostic/diagnostic-browse.jsp">Diagnostic Tool</a></li>
                <li><a href="${pageContext.request.contextPath}/guides">View Repair Guides</a></li>
                <li><a href="${pageContext.request.contextPath}/findtech.jsp">Book a Technician</a></li>
                <li><a href="${pageContext.request.contextPath}/store_main.jsp">Store</a></li>
            </ul>
            <div class="nav-buttons">
                <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
                <% if (isLoggedIn) { %>
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="margin: 0; display: inline;">
                        <button type="submit" class="btn-logout">Logout</button>
                    </form>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/login.jsp" class="btn-login">Login</a>
                    <a href="${pageContext.request.contextPath}/preliminarySignup.jsp" class="btn-signup">Sign Up</a>
                <% } %>
            </div>
        </div>
    </nav>

        <!-- Search Section -->
        <div class="container">
            <section class="search-section">
                <h3 class="search-title">What are you looking for?</h3>
                <form action="${pageContext.request.contextPath}/search" method="get" style="display: contents;">
                    <div class="search-box">
                        <input type="text" name="q" id="search-input" placeholder="Search for a part/item or category" required>
                        <button type="submit">
                            <img src="${pageContext.request.contextPath}/assets/images/search.png" alt="Search">
                        </button>
                    </div>
                </form>

                <!-- Category Section -->
                <section class="category-section">
                    <h4 class="category-header">Browse Items by Category</h4>
                    <div class="category-grid">
                        <a href="${pageContext.request.contextPath}/products?category=Cutting Tools"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/saw-machine.png"
                                alt="Cutting Tools">
                            <p class="category-label">Cutting Tools</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Painting Tools"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/paint-roller.png"
                                alt="Painting Tools">
                            <p class="category-label">Painting Tools</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Tool Storage %26 Safety Gear"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/safety-gear.png"
                                alt="Tool Storage & Safety Gear">
                            <p class="category-label">Tool Storage <br>& Safety Gear</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Electrical Tools %26 Accessories"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/power-cable.png"
                                alt="Electrical Tools & Accessories">
                            <p class="category-label">Electrical Tools <br>& Accessories</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Power Tools"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/power-drill.png"
                                alt="Power Tools">
                            <p class="category-label">Power Tools</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Cleaning %26 Maintenance"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/cleaning.png"
                                alt="Cleaning & Maintenance">
                            <p class="category-label">Cleaning & Maintenance</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Vehicle Parts %26 Accessories"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/tyre.png"
                                alt="Vehicle Parts & Accessories">
                            <p class="category-label">Vehicle Parts <br>& Accessories</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Measuring %26 Marking Tools"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/tape-measure.png"
                                alt="Measuring & Marking Tools">
                            <p class="category-label">Measuring & <br>Marking Tools</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Tapes" class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/masking-tape.png" alt="Tapes">
                            <p class="category-label">Tapes</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Fasteners %26 Fittings"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/tools.png"
                                alt="Fasteners & Fittings">
                            <p class="category-label">Fasteners & <br>Fittings</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Plumbing Tools %26 Supplies"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/pipe.png"
                                alt="Plumbing Tools & Supplies">
                            <p class="category-label">Plumbing Tools <br>& Supplies</p>
                        </a>

                        <a href="${pageContext.request.contextPath}/products?category=Adhesives %26 Sealants"
                            class="category-item">
                            <img src="${pageContext.request.contextPath}/assets/images/glue.png"
                                alt="Adhesives & Sealants">
                            <p class="category-label">Adhesives & <br>Sealants</p>
                        </a>
                    </div>
                </section>
            </section>
        </div>

        <!-- Suggested Products Section -->
        <section class="suggested-section">
            <div class="suggested-card">
                <h4 class="suggested-header">You Might Also Like</h4>
                <div class="suggested-grid">
                    <a href="${pageContext.request.contextPath}/product_details.jsp" class="suggested-item">
                        <img src="${pageContext.request.contextPath}/assets/images/glass_cutter.jpg" alt="Glass Cutter">
                        <p class="item-name">Glass Cutter</p>
                        <p class="item-desc">Durable tool for precise glass cutting at home or DIY projects.</p>
                        <p class="item-price">Rs 1,200</p>
                    </a>
                    <a href="${pageContext.request.contextPath}/product_details.jsp" class="suggested-item">
                        <img src="${pageContext.request.contextPath}/assets/images/sawmachine.jpg" alt="Saw Machine">
                        <p class="item-name">Saw Machine</p>
                        <p class="item-desc">Efficient cutting tool for wood, metal, and plastic surfaces.</p>
                        <p class="item-price">Rs 7,250</p>
                    </a>
                    <a href="${pageContext.request.contextPath}/product_details.jsp" class="suggested-item">
                        <img src="${pageContext.request.contextPath}/assets/images/drill.jpg" alt="Drill Machine">
                        <p class="item-name">Drill Machine</p>
                        <p class="item-desc">Compact drill for versatile DIY and home repair tasks.</p>
                        <p class="item-price">Rs 4,500</p>
                    </a>
                    <a href="${pageContext.request.contextPath}/product_details.jsp" class="suggested-item">
                        <img src="${pageContext.request.contextPath}/assets/images/roller.jpg" alt="Paint Roller">
                        <p class="item-name">Paint Roller</p>
                        <p class="item-desc">Smooth finish roller for walls, ceilings, and furniture.</p>
                        <p class="item-price">Rs 1,200</p>
                    </a>
                </div>
            </div>
        </section>

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
