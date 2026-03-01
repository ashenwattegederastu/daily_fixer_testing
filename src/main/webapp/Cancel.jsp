<%@ page contentType="text/html;charset=UTF-8" %>
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
    <meta name="description" content="Payment Cancelled - DailyFixer">
    <title>Payment Cancelled - Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/checkout.css">
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
        :root {
            --primary-purple: #8b7dd8;
            --primary-blue: #7ba3d4;
            --accent-purple: #d4c5e8;
            --danger: #e74c3c;
            --danger-light: #fadbd8;
            --white: #ffffff;
            --text-dark: #2d2d3d;
            --text-muted: #666;
            --shadow-sm: 0 2px 8px rgba(139,125,216,0.08);
            --shadow-md: 0 4px 16px rgba(139,125,216,0.12);
            --shadow-lg: 0 8px 32px rgba(139,125,216,0.15);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #f5f6fa 0%, #e8eaf6 100%);
            min-height: 100vh;
            padding-top: 80px;
            color: var(--text-dark);
        }

        /* Navigation */
        nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            backdrop-filter: blur(10px);
            background: rgba(139, 125, 216, 0.1);
            border-bottom: 1px solid rgba(139, 125, 216, 0.2);
            padding: 1rem 2rem;
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* Main Content */
        .main-content {
            max-width: 700px;
            margin: 0 auto;
            padding: 40px 20px;
        }

        .result-card {
            background: var(--white);
            border-radius: 20px;
            padding: 50px 40px;
            box-shadow: var(--shadow-lg);
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .result-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: linear-gradient(90deg, var(--danger), #ff6b6b);
        }

        .result-icon {
            width: 100px;
            height: 100px;
            margin: 0 auto 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--danger-light), #ffe0e0);
            animation: pulse 2s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
        }

        .result-icon svg {
            width: 50px;
            height: 50px;
            stroke: var(--danger);
            stroke-width: 2.5;
        }

        h1 {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 15px;
            background: linear-gradient(135deg, var(--danger), #ff6b6b);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .subtitle {
            color: var(--text-muted);
            font-size: 1.1rem;
            margin-bottom: 40px;
            line-height: 1.6;
        }

        .order-details {
            background: linear-gradient(135deg, #f9f9ff, #f0f0ff);
            border-radius: 15px;
            padding: 25px;
            margin: 30px 0;
            border: 2px solid var(--accent-purple);
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid rgba(139, 125, 216, 0.1);
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.95rem;
        }

        .detail-value {
            font-weight: 700;
            color: var(--primary-purple);
            font-size: 1rem;
        }

        .status-cancelled {
            display: inline-block;
            padding: 6px 16px;
            background: linear-gradient(135deg, var(--danger), #ff6b6b);
            color: white;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 40px;
            flex-wrap: wrap;
        }

        .btn-primary, .btn-secondary {
            flex: 1;
            min-width: 200px;
            padding: 16px 30px;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-md);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(139, 125, 216, 0.4);
            background: linear-gradient(135deg, #7b6dc8, #6b93c4);
        }

        .btn-secondary {
            background: white;
            color: var(--primary-purple);
            border: 2px solid var(--primary-purple);
        }

        .btn-secondary:hover {
            transform: translateY(-3px);
            background: var(--primary-purple);
            color: white;
            box-shadow: 0 8px 25px rgba(139, 125, 216, 0.4);
        }

        .info-box {
            margin-top: 40px;
            padding: 25px;
            background: linear-gradient(135deg, #f0f4ff, #e8f0ff);
            border-radius: 15px;
            border-left: 4px solid var(--primary-purple);
        }

        .info-box h3 {
            color: var(--primary-purple);
            margin-bottom: 15px;
            font-size: 1.2rem;
            font-weight: 600;
        }

        .info-box p {
            color: var(--text-muted);
            margin-bottom: 10px;
            line-height: 1.6;
        }

        .info-box .contact-info {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid rgba(139, 125, 216, 0.2);
        }

        .info-box .contact-info p {
            margin: 8px 0;
            font-weight: 500;
            color: var(--text-dark);
        }

        /* Footer */
        footer {
            text-align: center;
            padding: 30px 20px;
            color: var(--text-muted);
            font-size: 0.9rem;
        }

        @media (max-width: 600px) {
            .result-card {
                padding: 30px 20px;
            }

            h1 {
                font-size: 1.5rem;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn-primary, .btn-secondary {
                width: 100%;
            }
        }
    </style>
</head>

<body>
    <!-- Navigation -->
    <nav class="public-nav">
        <div class="nav-container">
            <a href="<%=request.getContextPath()%>/index.jsp" class="logo">Daily Fixer</a>
            <div style="display: flex; align-items: center; gap: 20px;">
                <div style="color: var(--text-muted); font-weight: 500;">Payment Status</div>
                <div class="nav-buttons">
                    <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
                    <% if (isLoggedIn) { %>
                        <form action="<%=request.getContextPath()%>/logout" method="post" style="margin: 0; display: inline;">
                            <button type="submit" class="btn-logout">Logout</button>
                        </form>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
        <div class="result-card">
            <div class="result-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <circle cx="12" cy="12" r="10"></circle>
                    <path d="M15 9l-6 6"></path>
                    <path d="M9 9l6 6"></path>
                </svg>
            </div>

            <h1><fmt:message key="common.cancel"/></h1>
            <p class="subtitle">
                Your payment was cancelled or could not be completed.<br>
                Don't worry - no charges have been made to your account.
            </p>

            <div class="order-details">
                <div class="detail-row">
                    <span class="detail-label">Order ID</span>
                    <span class="detail-value" id="order-id">N/A</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status</span>
                    <span class="status-cancelled">CANCELLED</span>
                </div>
            </div>

            <div class="action-buttons">
                <a href="checkout.jsp" class="btn-primary">
                    🔄 Try Again
                </a>
                <a href="store_main.jsp" class="btn-secondary">
                    <fmt:message key="product.back"/>
                </a>
            </div>

            <div class="info-box">
                <h3>Need Help?</h3>
                <p>If you're experiencing issues with payment, please contact us:</p>
                <div class="contact-info">
                    <p>📞 +94 11 234 5678</p>
                    <p>📧 support@dailyfixer.lk</p>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer>
        <p>&copy; 2026 DailyFixer. All rights reserved.</p>
    </footer>

    <script>
        // Get order info from URL params
        document.addEventListener('DOMContentLoaded', function () {
            const urlParams = new URLSearchParams(window.location.search);
            const orderId = urlParams.get('order_id');

            if (orderId) {
                document.getElementById('order-id').textContent = orderId;
            }
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
</body>

</html>
