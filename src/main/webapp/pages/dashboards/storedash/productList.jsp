<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"store".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Product> products = (List<Product>) request.getAttribute("products");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Product Catalogue | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">

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
  display: flex;
}

/* Top Navbar */
.topbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 76px;
  background-color: var(--sidebar);
  border-bottom: 1px solid var(--border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 30px;
  z-index: 200;
  box-shadow: var(--shadow-md);
  transition: background-color 0.3s ease, border-color 0.3s ease;
}

.topbar .logo {
  font-size: 1.5em;
  font-weight: 700;
  color: var(--primary);
  text-decoration: none;
}

.topbar .panel-name {
  font-weight: 600;
  flex: 1;
  text-align: center;
  color: var(--foreground);
}

.topbar .logout-btn {
  padding: 0.6rem 1.2rem;
  background: var(--primary);
  border: none;
  color: var(--primary-foreground);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
}

.topbar .logout-btn:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  opacity: 0.9;
}

/* Sidebar */
.sidebar {
  width: 240px;
  background-color: var(--sidebar);
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  padding-top: 96px;
  box-shadow: var(--shadow-md);
  overflow-y: auto;
  z-index: 100;
  border-right: 1px solid var(--sidebar-border);
  transition: background-color 0.3s ease, border-color 0.3s ease;
}

.sidebar h3 {
  padding: 0 20px 12px;
  font-size: 0.85em;
  color: var(--sidebar-foreground);
  text-transform: uppercase;
  font-weight: 600;
}

.sidebar ul {
  list-style: none;
}

.sidebar a {
  display: block;
  padding: 12px 20px;
  text-decoration: none;
  color: var(--sidebar-foreground);
  font-weight: 500;
  border-left: 3px solid transparent;
  border-radius: 0 var(--radius-md) var(--radius-md) 0;
  margin-bottom: 4px;
  transition: all 0.2s;
}

.sidebar a:hover,
.sidebar a.active {
  background-color: var(--sidebar-accent);
  color: var(--sidebar-accent-foreground);
  border-left-color: var(--sidebar-primary);
}

/* Main Content */
.main-content,
.container {
  flex: 1;
  margin-left: 240px;
  margin-top: 83px;
  padding: 30px;
  background-color: var(--background);
  transition: background-color 0.3s ease;
}

body.dashboard-layout {
  display: flex;
  min-height: 100vh;
}

.container h2 {
  font-size: 1.6em;
  margin-bottom: 20px;
  color: var(--foreground);
}

/* Top Bar */
.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 15px;
}

.top-bar-left {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.category-filter {
  display: flex;
  align-items: center;
  gap: 10px;
}

.category-filter label {
  font-weight: 600;
  color: var(--foreground);
  font-size: 0.95em;
}

.category-filter select {
  padding: 10px 15px;
  border: 2px solid var(--border);
  border-radius: var(--radius-md);
  background: var(--input);
  font-size: 0.95em;
  color: var(--foreground);
  cursor: pointer;
  transition: all 0.2s;
  min-width: 220px;
  font-weight: 500;
}

.category-filter select:hover {
  border-color: var(--ring);
}

.category-filter select:focus {
  outline: none;
  border-color: var(--ring);
  box-shadow: 0 0 0 3px var(--ring) / 0.1;
}

.product-count {
  font-size: 0.9em;
  color: var(--muted-foreground);
  font-weight: 500;
  padding: 8px 12px;
  background: var(--muted);
  border-radius: var(--radius-md);
}

.product-count strong {
  color: var(--primary);
  font-weight: 600;
}

.btn-add {
  background: var(--primary);
  color: var(--primary-foreground);
  padding: 10px 20px;
  border-radius: var(--radius-md);
  text-decoration: none;
  font-weight: 600;
  box-shadow: var(--shadow-sm);
  white-space: nowrap;
  transition: all 0.3s ease;
}

.btn-add:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  opacity: 0.9;
}

/* Table Styles */
.table-container {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  background-color: var(--card);
  color: var(--card-foreground);
  box-shadow: var(--shadow-lg);
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--border);
  transition: background-color 0.3s ease, border-color 0.3s ease;
  table-layout: fixed;
}

table th,
table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid var(--border);
  transition: border-color 0.3s ease;
  word-wrap: break-word;
  overflow-wrap: break-word;
  vertical-align: top;
}

table th {
  background-color: var(--muted);
  color: var(--foreground);
  font-weight: 600;
}

table tr:hover {
  background-color: var(--accent);
  color: var(--accent-foreground);
}

/* Column widths */
th:nth-child(1), td:nth-child(1) { width: 40px; } /* Expand toggle */
th:nth-child(2), td:nth-child(2) { width: 120px; } /* Image */
th:nth-child(3), td:nth-child(3) { width: 200px; max-width: 200px; } /* Name */
th:nth-child(4), td:nth-child(4) { width: 100px; } /* Type */
th:nth-child(5), td:nth-child(5) { width: 120px; } /* Stock */
th:nth-child(6), td:nth-child(6) { width: 120px; } /* Price */
th:nth-child(7), td:nth-child(7) { width: 100px; } /* Variants */
th:nth-child(8), td:nth-child(8) { width: 220px; } /* Actions */
td:nth-child(8) {
  white-space: nowrap;
}

td:nth-child(8) .btn {
  margin-bottom: 0;
  vertical-align: middle;
}

/* Name column styling */
td:nth-child(3) {
  max-width: 200px;
}

td:nth-child(3) strong {
  word-wrap: break-word;
}

img.service-thumb {
  width: 100px;
  height: 80px;
  border-radius: var(--radius-md);
  object-fit: cover;
}

/* Action Buttons */
.action-btn,
.btn {
  padding: 6px 12px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 500;
  transition: all 0.2s;
  text-decoration: none;
  display: inline-block;
  margin: 2px;
  white-space: nowrap;
}

.btn-view,
.view-btn {
  background-color: var(--primary);
  color: var(--primary-foreground);
}

.btn-view:hover,
.view-btn:hover {
  opacity: 0.8;
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

.btn-edit,
.edit-btn {
  background-color: oklch(0.7336 0.1758 50.5517);
  color: white;
}

.btn-edit:hover,
.edit-btn:hover {
  opacity: 0.8;
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

.btn-delete,
.delete-btn {
  background-color: var(--destructive);
  color: var(--destructive-foreground);
}

.btn-delete:hover,
.delete-btn:hover {
  opacity: 0.8;
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

/* Confirmation Modal */
.confirm-modal {
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

.confirm-modal .modal-content {
  background: var(--card);
  color: var(--card-foreground);
  padding: 30px;
  border-radius: var(--radius-lg);
  max-width: 400px;
  width: 90%;
  text-align: center;
  box-shadow: var(--shadow-xl);
  border: 1px solid var(--border);
  position: relative;
}

.confirm-modal h3 {
  color: var(--primary);
  margin-bottom: 15px;
}

.confirm-modal p {
  color: var(--muted-foreground);
  margin-bottom: 25px;
}

.confirm-modal .modal-buttons {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.confirm-modal .modal-btn {
  padding: 10px 20px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
}

.confirm-modal .confirm-btn {
  background: var(--destructive);
  color: var(--destructive-foreground);
}

.confirm-modal .confirm-btn:hover {
  opacity: 0.8;
}

.confirm-modal .cancel-btn {
  background: var(--secondary);
  color: var(--secondary-foreground);
  border: 1px solid var(--border);
}

.confirm-modal .cancel-btn:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

.close-btn {
  position: absolute;
  top: 15px;
  right: 20px;
  font-size: 1.5em;
  font-weight: bold;
  cursor: pointer;
  color: var(--muted-foreground);
  transition: color 0.2s ease;
}

.close-btn:hover {
  color: var(--foreground);
}

/* Product Details Modal */
.product-details-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.7);
  backdrop-filter: blur(4px);
  justify-content: center;
  align-items: center;
  z-index: 600;
  overflow-y: auto;
  padding: 20px;
}

.product-details-modal .modal-content {
  background: var(--card);
  color: var(--card-foreground);
  padding: 0;
  border-radius: var(--radius-lg);
  max-width: 1000px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: var(--shadow-2xl);
  position: relative;
  border: 1px solid var(--border);
}

.product-details-modal .modal-header {
  background: var(--primary);
  color: var(--primary-foreground);
  padding: 25px 30px;
  border-radius: var(--radius-lg) var(--radius-lg) 0 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.product-details-modal .modal-header h3 {
  margin: 0;
  font-size: 1.6em;
  font-weight: 700;
  color: var(--primary-foreground);
}

.product-details-modal .close-btn {
  color: var(--primary-foreground);
  font-size: 1.8em;
  background: rgba(255,255,255,0.2);
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.product-details-modal .close-btn:hover {
  background: rgba(255,255,255,0.3);
  transform: rotate(90deg);
}

.product-details-modal .modal-body {
  padding: 30px;
}

.product-details-grid {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 40px;
  margin-bottom: 40px;
  align-items: start;
}

.product-image-section {
  position: sticky;
  top: 20px;
}

.product-image-section img {
  width: 100%;
  height: auto;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  border: 3px solid var(--card);
}

.product-info-section {
  background: var(--card);
  padding: 25px;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  border: 1px solid var(--border);
}

.product-info-section h4 {
  color: var(--primary);
  margin-top: 0;
  margin-bottom: 20px;
  font-size: 1.3em;
  padding-bottom: 10px;
  border-bottom: 2px solid var(--border);
}

.info-row {
  display: flex;
  margin-bottom: 18px;
  padding-bottom: 18px;
  border-bottom: 1px solid var(--border);
  align-items: flex-start;
}

.info-row:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.info-label {
  font-weight: 600;
  color: var(--muted-foreground);
  width: 140px;
  flex-shrink: 0;
  font-size: 0.95em;
}

.info-value {
  color: var(--foreground);
  flex: 1;
  line-height: 1.6;
  word-wrap: break-word;
}

.variants-section {
  margin-top: 30px;
  padding: 25px;
  background: var(--card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  border: 1px solid var(--border);
}

.variants-section h4 {
  color: var(--primary);
  margin-top: 0;
  margin-bottom: 20px;
  font-size: 1.3em;
  padding-bottom: 10px;
  border-bottom: 2px solid var(--border);
}

.product-details-modal .variants-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  margin-top: 15px;
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--border);
  background: var(--card);
  box-shadow: var(--shadow-sm);
}

.product-details-modal .variants-table thead {
  background: var(--primary);
}

.product-details-modal .variants-table th {
  padding: 16px 12px;
  text-align: left;
  font-weight: 600;
  color: var(--primary-foreground);
  font-size: 0.85em;
  text-transform: uppercase;
  letter-spacing: 0.8px;
  border-right: 1px solid rgba(255,255,255,0.2);
  white-space: nowrap;
}

.product-details-modal .variants-table th:last-child {
  border-right: none;
}

.product-details-modal .variants-table th:nth-child(1),
.product-details-modal .variants-table td:nth-child(1) {
    width: 120px;
}

.product-details-modal .variants-table th:nth-child(2),
.product-details-modal .variants-table td:nth-child(2) {
    width: 100px;
}

.product-details-modal .variants-table th:nth-child(3),
.product-details-modal .variants-table td:nth-child(3) {
    width: 100px;
}

.product-details-modal .variants-table th:nth-child(4),
.product-details-modal .variants-table td:nth-child(4) {
    width: 140px;
}

.product-details-modal .variants-table th:nth-child(5),
.product-details-modal .variants-table td:nth-child(5) {
    width: 150px;
}

.product-details-modal .variants-table th:nth-child(6),
.product-details-modal .variants-table td:nth-child(6) {
    width: 80px;
    text-align: center;
}

.product-details-modal .variants-table th:nth-child(7),
.product-details-modal .variants-table td:nth-child(7) {
    width: 120px;
    text-align: center;
}

.product-details-modal .variants-table td {
  padding: 16px 12px;
  border-bottom: 1px solid var(--border);
  font-size: 0.9em;
  color: var(--foreground);
  vertical-align: middle;
}

.product-details-modal .variants-table tbody tr {
  transition: all 0.2s ease;
  background: var(--card);
}

.product-details-modal .variants-table tbody tr:last-child td {
  border-bottom: none;
}

.product-details-modal .variants-table tbody tr:nth-child(even) {
  background-color: var(--muted);
}

.product-details-modal .variants-table tbody tr:hover {
  background-color: var(--accent);
  color: var(--accent-foreground);
  transform: translateX(4px);
  box-shadow: -4px 0 0 var(--primary);
}

.variant-attribute {
  display: inline-block;
  padding: 6px 14px;
  background: var(--secondary);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  font-weight: 500;
  color: var(--secondary-foreground);
  font-size: 0.9em;
  box-shadow: var(--shadow-xs);
  white-space: nowrap;
  text-align: center;
  min-width: 60px;
}

.variant-price {
  font-weight: 600;
  color: var(--foreground);
  display: block;
  line-height: 1.4;
}

.variant-price.original {
  text-decoration: line-through;
  color: var(--muted-foreground);
  font-size: 0.85em;
  margin-bottom: 2px;
}

.variant-price.discounted {
  color: oklch(0.6290 0.1902 156.4499);
  font-size: 1em;
}

.discount-badge {
  background: var(--destructive);
  color: var(--destructive-foreground);
  padding: 6px 14px;
  border-radius: var(--radius-md);
  font-size: 0.85em;
  font-weight: 600;
  display: inline-block;
  box-shadow: var(--shadow-sm);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.no-variants {
  color: var(--muted-foreground);
  font-style: italic;
  padding: 40px 20px;
  text-align: center;
  background: var(--muted);
  border-radius: var(--radius-md);
  border: 2px dashed var(--border);
}

/* Responsive design for modal */
@media (max-width: 768px) {
  .product-details-grid {
    grid-template-columns: 1fr;
    gap: 25px;
  }
  
  .product-image-section {
    position: relative;
    text-align: center;
  }
  
  .product-image-section img {
    max-width: 250px;
  }
  
  .product-details-modal .modal-content {
    max-width: 95%;
    margin: 10px;
  }
  
  .product-details-modal .variants-table {
    font-size: 0.8em;
  }
  
  .product-details-modal .variants-table th,
  .product-details-modal .variants-table td {
    padding: 8px 6px;
  }

  .main-content,
  .container {
    margin-left: 0;
    padding: 20px;
  }

  .sidebar {
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }

  .sidebar.open {
    transform: translateX(0);
  }
}

/* Variant Toggle Button */
.toggle-variants-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 5px;
  font-size: 0.9em;
  color: var(--primary);
  transition: transform 0.2s;
}

.toggle-variants-btn:hover {
  transform: scale(1.2);
}

.toggle-variants-btn[data-expanded="true"] .toggle-icon {
  transform: rotate(90deg);
}

.toggle-icon {
  display: inline-block;
  transition: transform 0.2s;
}

/* Variant Details Row */
.variant-details-row {
  background-color: var(--muted);
}

.variant-details-row td {
  padding: 20px;
  border-top: 2px solid var(--primary);
}

.variants-container {
  padding: 15px;
  background: var(--card);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--border);
}

.variants-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
  box-shadow: none;
  border: 1px solid var(--border);
  background: var(--card);
}

.variants-table thead {
  background-color: var(--muted);
}

.variants-table th,
.variants-table td {
  padding: 10px;
  text-align: left;
  border-bottom: 1px solid var(--border);
  font-size: 0.9em;
}

.variants-table tbody tr:hover {
  background-color: var(--accent);
  color: var(--accent-foreground);
}

.variant-badge {
  display: inline-block;
  background: var(--primary);
  color: var(--primary-foreground);
  padding: 4px 10px;
  border-radius: var(--radius-md);
  font-size: 0.85em;
  font-weight: 600;
}

.status-badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: var(--radius-md);
  font-size: 0.85em;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  box-shadow: var(--shadow-xs);
}

.status-badge.in-stock {
  background: oklch(0.6290 0.1902 156.4499);
  color: white;
}

.status-badge.out-of-stock {
  background: var(--destructive);
  color: var(--destructive-foreground);
}
</style>
</head>
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo"><fmt:message key="app.name"/></div>
    <div class="panel-name"><fmt:message key="store.panel"/></div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><fmt:message key="common.logout"/></a>
</header>

<aside class="sidebar">
    <h3><fmt:message key="sidebar.navigation"/></h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp"><fmt:message key="store.dashboard"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp"><fmt:message key="store.orders"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp"><fmt:message key="store.up_for_delivery"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp"><fmt:message key="store.completed_orders"/></a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet" class="active"><fmt:message key="store.catalogue"/></a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet"><fmt:message key="store.discounts"/></a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet"><fmt:message key="store.customer_reviews"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp"><fmt:message key="store.profile"/></a></li>
    </ul>
<div class="sidebar-actions" style="padding: 15px;">
    <a href="?lang=${sessionScope.sessionLocale.language == 'si' ? 'en' : 'si'}"
       class="action-btn lang-toggle" style="display:block; text-align:center; padding:8px; background:var(--primary); color:var(--primary-foreground); border-radius:var(--radius-md); text-decoration:none; font-weight:600;">
       <fmt:message key="nav.lang_switch"/>
    </a>
</div>
</aside>

<main class="container">
    <!-- Top Bar -->
    <div class="top-bar">
        <div class="top-bar-left">
            <h2 style="margin: 0;">Product Catalogue</h2>
            <div class="category-filter">
                <label for="categoryFilter">Filter by Category:</label>
                <select id="categoryFilter" onchange="filterByCategory()">
                    <option value="">All Categories</option>
                    <option value="Cutting Tools">Cutting Tools</option>
                    <option value="Painting Tools">Painting Tools</option>
                    <option value="Tool Storage & Safety Gear">Tool Storage & Safety Gear</option>
                    <option value="Electrical Tools & Accessories">Electrical Tools & Accessories</option>
                    <option value="Power Tools">Power Tools</option>
                    <option value="Cleaning & Maintenance">Cleaning & Maintenance</option>
                    <option value="Vehicle Parts & Accessories">Vehicle Parts & Accessories</option>
                    <option value="Measuring & Marking Tools">Measuring & Marking Tools</option>
                    <option value="Tapes">Tapes</option>
                    <option value="Fasteners & Fittings">Fasteners & Fittings</option>
                    <option value="Plumbing Tools & Supplies">Plumbing Tools & Supplies</option>
                    <option value="Adhesives & Sealants">Adhesives & Sealants</option>
                </select>
                <span class="product-count" id="productCount">
                    <strong id="visibleCount"><%=products != null ? products.size() : 0%></strong> product(s) shown
                </span>
            </div>
        </div>
        <a class="btn-add" href="${pageContext.request.contextPath}/pages/dashboards/storedash/addProduct.jsp">+ Add Product</a>
    </div>

    <!-- Products Table -->
    <table>
        <thead>
            <tr>
                <th style="width: 50px;"></th>
                <th>Image</th>
                <th>Name</th>
                <th>Type</th>
                <th>Stock</th>
                <th><fmt:message key="store.products.price"/></th>
                <th>Variants</th>
                <th><fmt:message key="store.products.actions"/></th>
            </tr>
        </thead>
        <tbody>
            <% if(products != null && !products.isEmpty()){
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                for(Product p : products){ 
                    // Get variants for this product
                    List<ProductVariant> variants = null;
                    boolean hasVariants = false;
                    int totalVariantStock = 0;
                    double minPrice = p.getPrice();
                    double maxPrice = p.getPrice();
                    
                    try {
                        variants = variantDAO.getVariantsByProductId(p.getProductId());
                        hasVariants = (variants != null && !variants.isEmpty());
                        
                        if (hasVariants) {
                            // Calculate total stock and price range
                            for (ProductVariant v : variants) {
                                totalVariantStock += v.getQuantity();
                                if (v.getPrice() != null) {
                                    double vPrice = v.getPrice().doubleValue();
                                    if (minPrice == 0.00 || vPrice < minPrice) minPrice = vPrice;
                                    if (vPrice > maxPrice) maxPrice = vPrice;
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                    // Get display price
                    double displayPrice = p.getPrice();
                    if (hasVariants && p.getPrice() == 0.00 && variants.get(0).getPrice() != null) {
                        displayPrice = variants.get(0).getPrice().doubleValue();
                    }
                    
                    int totalStock = hasVariants ? totalVariantStock : p.getQuantity();
                %>
            <tr class="product-row" data-product-id="<%=p.getProductId()%>" data-category="<%=p.getType() != null ? p.getType() : ""%>">
                <td>
                    <% if (hasVariants) { %>
                    <button class="toggle-variants-btn" onclick="toggleVariants(<%=p.getProductId()%>)" data-expanded="false">
                        <span class="toggle-icon">▶</span>
                    </button>
                    <% } else { %>
                    <span style="color: #ccc;">—</span>
                    <% } %>
                </td>
                <td>
                    <% if(p.getImage() != null){ %>
                    <img class="service-thumb" src="data:image/jpeg;base64,<%=java.util.Base64.getEncoder().encodeToString(p.getImage())%>">
                    <% } else { %>
                    <img class="service-thumb" src="${pageContext.request.contextPath}/assets/images/tools.png" alt="No Image">
                    <% } %>
                </td>
                <td>
                    <strong><%=p.getName()%></strong>
                </td>
                <td><%=p.getType()%></td>
                <td>
                    <% if (hasVariants) { %>
                    <strong><%=totalStock%></strong> <%=p.getQuantityUnit() != null ? p.getQuantityUnit() : "units"%>
                    <br><small style="color: #666;">(<%=variants.size()%> variants)</small>
                    <% } else { %>
                    <strong><%=p.getQuantity()%></strong> <%=p.getQuantityUnit() != null ? p.getQuantityUnit() : "units"%>
                    <% } %>
                </td>
                <td>
                    <% if (hasVariants) { %>
                    <% if (minPrice == maxPrice) { %>
                    Rs. <%=String.format("%.2f", minPrice)%>
                    <% } else { %>
                    Rs. <%=String.format("%.2f", minPrice)%> - Rs. <%=String.format("%.2f", maxPrice)%>
                    <% } %>
                    <% } else { %>
                    Rs. <%=String.format("%.2f", displayPrice)%>
                    <% } %>
                </td>
                <td>
                    <% if (hasVariants) { %>
                    <span class="variant-badge"><%=variants.size()%> variant<%=variants.size() > 1 ? "s" : ""%></span>
                    <% } else { %>
                    <span style="color: #999;">No variants</span>
                    <% } %>
                </td>
                <td>
                    <button class="btn view-btn" onclick="viewProductDetails(<%=p.getProductId()%>)">View Details</button>
                    <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/editProduct.jsp?productId=<%=p.getProductId()%>" class="btn edit-btn">Edit</a>
                    <button class="btn delete-btn" onclick="confirmDelete('<%=p.getProductId()%>', '<%=p.getName()%>')">Delete</button>
                </td>
            </tr>
            <% if (hasVariants) { %>
            <tr class="variant-details-row" id="variants-<%=p.getProductId()%>" style="display: none;" data-product-id="<%=p.getProductId()%>" data-category="<%=p.getType() != null ? p.getType() : ""%>">
                <td colspan="8">
                    <div class="variants-container">
                        <h4 style="margin-bottom: 15px; color: var(--accent);">Variant Details</h4>
                        <table class="variants-table">
                            <thead>
                                <tr>
                                    <th>Color</th>
                                    <th>Size</th>
                                    <th>Power</th>
                                    <th>Price</th>
                                    <th>Stock</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (ProductVariant v : variants) { %>
                                <tr>
                                    <td><%=v.getColor() != null && !v.getColor().isEmpty() ? v.getColor() : "—"%></td>
                                    <td><%=v.getSize() != null && !v.getSize().isEmpty() ? v.getSize() : "—"%></td>
                                    <td><%=v.getPower() != null && !v.getPower().isEmpty() ? v.getPower() : "—"%></td>
                                    <td><strong>Rs. <%=v.getPrice() != null ? String.format("%.2f", v.getPrice().doubleValue()) : "0.00"%></strong></td>
                                    <td><strong><%=v.getQuantity()%></strong> <%=p.getQuantityUnit() != null ? p.getQuantityUnit() : "units"%></td>
                                    <td>
                                        <% if (v.getQuantity() > 0) { %>
                                        <span class="status-badge in-stock">In Stock</span>
                                        <% } else { %>
                                        <span class="status-badge out-of-stock">Out of Stock</span>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </td>
            </tr>
            <% } %>
            <% }} else { %>
            <tr><td colspan="8" style="text-align:center; color:#777;">No products found.</td></tr>
            <% } %>
        </tbody>
    </table>
</main>

<!-- Product Details Modal -->
<div id="productDetailsModal" class="product-details-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalProductName">Product Details</h3>
            <span class="close-btn" onclick="closeProductDetailsModal()">&times;</span>
        </div>
        <div class="modal-body">
            <div class="product-details-grid">
                <div class="product-image-section">
                    <img id="modalProductImage" src="" alt="Product Image">
                </div>
                <div class="product-info-section">
                    <h4>Product Information</h4>
                    <div class="info-row">
                        <span class="info-label">Name:</span>
                        <span class="info-value" id="modalName"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Type:</span>
                        <span class="info-value" id="modalType"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Description:</span>
                        <span class="info-value" id="modalDescription"></span>
                    </div>
                <div class="info-row">
                    <span class="info-label">Price Range:</span>
                    <span class="info-value" id="modalBasePrice" style="font-weight: 600; color: oklch(0.5393 0.2713 286.7462);"></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Total Stock:</span>
                    <span class="info-value" id="modalBaseStock" style="font-weight: 600; color: oklch(0.5393 0.2713 286.7462);"></span>
                </div>
                    <div class="info-row">
                        <span class="info-label">Unit:</span>
                        <span class="info-value" id="modalUnit"></span>
                    </div>
                </div>
            </div>
            <div class="variants-section">
                <h4>Product Variants</h4>
                <div id="modalVariantsContainer"></div>
            </div>
        </div>
    </div>
</div>

<!-- Confirmation Modal -->
<div id="confirmModal" class="confirm-modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeConfirmModal()">&times;</span>
        <h3>Confirm Delete</h3>
        <p>Are you sure you want to delete the product "<span id="productName"></span>"?</p>
        <p style="color: #e74c3c; font-size: 0.9em;">This action cannot be undone.</p>
        
        <div class="modal-buttons">
            <button class="modal-btn confirm-btn" onclick="deleteProduct()">Yes, Delete</button>
            <button class="modal-btn cancel-btn" onclick="closeConfirmModal()">Cancel</button>
        </div>
    </div>
</div>

<script>
let productToDelete = '';
let productData = {};

// Store product data for modal
<% if(products != null && !products.isEmpty()){
    ProductVariantDAO variantDAO = new ProductVariantDAO();
    DiscountDAO discountDAO = new DiscountDAO();
    for(Product p : products){ 
        List<ProductVariant> variants = null;
        try {
            variants = variantDAO.getVariantsByProductId(p.getProductId());
        } catch (Exception e) {
            e.printStackTrace();
        }
%>
productData[<%=p.getProductId()%>] = {
    id: <%=p.getProductId()%>,
    name: "<%=p.getName() != null ? p.getName().replace("\"", "\\\"").replace("\n", "\\n") : ""%>",
    type: "<%=p.getType() != null ? p.getType() : ""%>",
    description: "<%=p.getDescription() != null ? p.getDescription().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r") : ""%>",
    price: <%=p.getPrice()%>,
    quantity: <%=p.getQuantity()%>,
    unit: "<%=p.getQuantityUnit() != null ? p.getQuantityUnit() : ""%>",
    image: "<%=p.getImage() != null ? "data:image/jpeg;base64," + java.util.Base64.getEncoder().encodeToString(p.getImage()) : ""%>",
    variants: [
        <% if (variants != null && !variants.isEmpty()) {
            for (int i = 0; i < variants.size(); i++) {
                ProductVariant v = variants.get(i);
                Discount variantDiscount = null;
                Discount productDiscount = null;
                try {
                    variantDiscount = discountDAO.getActiveDiscountForVariant(v.getVariantId());
                    if (variantDiscount == null || !variantDiscount.isValid()) {
                        productDiscount = discountDAO.getActiveDiscountForProduct(p.getProductId());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                Discount activeDiscount = (variantDiscount != null && variantDiscount.isValid()) ? variantDiscount : 
                                        ((productDiscount != null && productDiscount.isValid()) ? productDiscount : null);
                double variantPrice = v.getPrice() != null ? v.getPrice().doubleValue() : 0.0;
                double variantDisplayPrice = variantPrice;
                if (activeDiscount != null && activeDiscount.isValid()) {
                    variantDisplayPrice = activeDiscount.calculateDiscountedPrice(variantPrice);
                }
        %>{
            id: <%=v.getVariantId()%>,
            color: "<%=v.getColor() != null ? v.getColor().replace("\"", "\\\"") : ""%>",
            size: "<%=v.getSize() != null ? v.getSize().replace("\"", "\\\"") : ""%>",
            power: "<%=v.getPower() != null ? v.getPower().replace("\"", "\\\"") : ""%>",
            price: <%=variantPrice%>,
            displayPrice: <%=variantDisplayPrice%>,
            quantity: <%=v.getQuantity()%>,
            discount: <% if (activeDiscount != null && activeDiscount.isValid()) { %>{
                name: "<%=activeDiscount.getDiscountName() != null ? activeDiscount.getDiscountName().replace("\"", "\\\"").replace("\n", "\\n") : ""%>",
                type: "<%=activeDiscount.getDiscountType() != null ? activeDiscount.getDiscountType() : ""%>",
                value: <%=activeDiscount.getDiscountValue() != null ? activeDiscount.getDiscountValue() : 0%>
            }<% } else { %>null<% } %>
        }<%= (i < variants.size() - 1) ? "," : "" %>
        <%   }
           } %>
    ]
};
<%   }
   } %>

function viewProductDetails(productId) {
    const product = productData[productId];
    if (!product) return;
    
    // Calculate price range and total quantity from variants
    let priceRange = '';
    let totalQuantity = product.quantity;
    
    if (product.variants && product.variants.length > 0) {
        // Calculate price range from variants
        const prices = product.variants.map(v => v.price).filter(p => p > 0);
        const displayPrices = product.variants.map(v => v.displayPrice).filter(p => p > 0);
        
        if (prices.length > 0) {
            const minPrice = Math.min(...prices);
            const maxPrice = Math.max(...prices);
            const minDisplayPrice = Math.min(...displayPrices);
            const maxDisplayPrice = Math.max(...displayPrices);
            
            if (minPrice === maxPrice) {
                priceRange = 'Rs. ' + minPrice.toFixed(2);
            } else {
                priceRange = 'Rs. ' + minPrice.toFixed(2) + ' - Rs. ' + maxPrice.toFixed(2);
            }
        } else {
            priceRange = 'Rs. ' + product.price.toFixed(2);
        }
        
        // Calculate total quantity from all variants
        totalQuantity = product.variants.reduce((sum, v) => sum + (v.quantity || 0), 0);
    } else {
        priceRange = 'Rs. ' + product.price.toFixed(2);
    }
    
    // Populate basic info
    document.getElementById('modalProductName').textContent = product.name;
    document.getElementById('modalName').textContent = product.name;
    document.getElementById('modalType').textContent = product.type || 'N/A';
    document.getElementById('modalDescription').textContent = product.description || 'No description';
    document.getElementById('modalBasePrice').textContent = priceRange;
    document.getElementById('modalBaseStock').textContent = totalQuantity;
    document.getElementById('modalUnit').textContent = product.unit || 'units';
    
    // Set image
    const imgEl = document.getElementById('modalProductImage');
    if (product.image) {
        imgEl.src = product.image;
        imgEl.style.display = 'block';
    } else {
        imgEl.src = '${pageContext.request.contextPath}/assets/images/tools.png';
        imgEl.style.display = 'block';
    }
    
    // Populate variants
    const variantsContainer = document.getElementById('modalVariantsContainer');
    if (product.variants && product.variants.length > 0) {
        let html = '<table class="variants-table"><thead><tr>';
        html += '<th>Color</th><th>Size</th><th>Power</th><th>Price</th><th>Discount</th><th>Stock</th><th>Status</th>';
        html += '</tr></thead><tbody>';
        
        product.variants.forEach(variant => {
            html += '<tr>';
            
            // Color column
            html += '<td>';
            if (variant.color && variant.color.trim() !== '') {
                html += '<span class="variant-attribute">' + variant.color + '</span>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Size column
            html += '<td>';
            if (variant.size && variant.size.trim() !== '') {
                html += '<span class="variant-attribute">' + variant.size + '</span>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Power column
            html += '<td>';
            if (variant.power && variant.power.trim() !== '') {
                html += '<span class="variant-attribute">' + variant.power + '</span>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Price column
            html += '<td>';
            if (variant.discount && variant.displayPrice < variant.price) {
                html += '<span class="variant-price original">Rs. ' + variant.price.toFixed(2) + '</span>';
                html += '<br><span class="variant-price discounted">Rs. ' + variant.displayPrice.toFixed(2) + '</span>';
            } else {
                html += '<span class="variant-price">Rs. ' + variant.price.toFixed(2) + '</span>';
            }
            html += '</td>';
            
            // Discount column
            html += '<td>';
            if (variant.discount && variant.displayPrice < variant.price) {
                html += '<span class="discount-badge">';
                if (variant.discount.type === 'PERCENTAGE') {
                    html += variant.discount.value + '% OFF';
                } else {
                    html += 'Rs. ' + variant.discount.value + ' OFF';
                }
                html += '</span>';
                html += '<br><small style="color: #666; margin-top: 4px; display: block; font-size: 0.8em;">' + variant.discount.name + '</small>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Stock column
            html += '<td><strong style="font-size: 1.05em;">' + variant.quantity + '</strong></td>';
            
            // Status column
            html += '<td>';
            if (variant.quantity > 0) {
                html += '<span class="status-badge in-stock">In Stock</span>';
            } else {
                html += '<span class="status-badge out-of-stock">Out of Stock</span>';
            }
            html += '</td>';
            
            html += '</tr>';
        });
        
        html += '</tbody></table>';
        variantsContainer.innerHTML = html;
    } else {
        variantsContainer.innerHTML = '<p class="no-variants">No variants available for this product.</p>';
    }
    
    // Show modal
    document.getElementById('productDetailsModal').style.display = 'flex';
}

function closeProductDetailsModal() {
    document.getElementById('productDetailsModal').style.display = 'none';
}

function confirmDelete(productId, productName) {
    productToDelete = productId;
    document.getElementById('productName').textContent = productName;
    document.getElementById('confirmModal').style.display = 'flex';
}

function closeConfirmModal() {
    document.getElementById('confirmModal').style.display = 'none';
    productToDelete = '';
}

function deleteProduct() {
    if (productToDelete) {
        window.location.href = '${pageContext.request.contextPath}/DeleteProductServlet?productId=' + productToDelete;
    }
}

// Close modals on outside click
document.getElementById('confirmModal').addEventListener('click', e => {
    if(e.target.id === 'confirmModal') {
        closeConfirmModal();
    }
});

document.getElementById('productDetailsModal').addEventListener('click', e => {
    if(e.target.id === 'productDetailsModal') {
        closeProductDetailsModal();
    }
});

// Category filter function
function filterByCategory() {
    const selectedCategory = document.getElementById('categoryFilter').value;
    const productRows = document.querySelectorAll('.product-row');
    let visibleCount = 0;
    
    productRows.forEach(row => {
        const rowCategory = row.getAttribute('data-category');
        const shouldShow = selectedCategory === '' || rowCategory === selectedCategory;
        
        if (shouldShow) {
            row.style.display = '';
            visibleCount++;
            
            // Keep variant rows in their current state (expanded/collapsed) but ensure they're not hidden by filter
            const productId = row.getAttribute('data-product-id');
            const relatedVariantRows = document.querySelectorAll(`.variant-details-row[data-product-id="${productId}"]`);
            relatedVariantRows.forEach(vr => {
                // Only show variant row if it was already visible (expanded)
                if (vr.style.display !== 'none' && vr.style.display !== '') {
                    // Keep it visible
                } else if (vr.style.display === 'none') {
                    // Keep it hidden (was collapsed)
                }
            });
        } else {
            row.style.display = 'none';
            
            // Hide variant rows for hidden products
            const productId = row.getAttribute('data-product-id');
            const relatedVariantRows = document.querySelectorAll(`.variant-details-row[data-product-id="${productId}"]`);
            relatedVariantRows.forEach(vr => {
                vr.style.display = 'none';
            });
        }
    });
    
    // Update product count
    const visibleCountEl = document.getElementById('visibleCount');
    if (visibleCountEl) {
        visibleCountEl.textContent = visibleCount;
    }
    
    // Show message if no products match
    const tbody = document.querySelector('table tbody');
    let noResultsRow = tbody.querySelector('.no-results-row');
    
    if (visibleCount === 0 && selectedCategory !== '') {
        if (!noResultsRow) {
            noResultsRow = document.createElement('tr');
            noResultsRow.className = 'no-results-row';
            noResultsRow.innerHTML = '<td colspan="8" style="text-align:center; color:#777; padding: 40px;">No products found in this category.</td>';
            tbody.appendChild(noResultsRow);
        }
        noResultsRow.style.display = '';
    } else {
        if (noResultsRow) {
            noResultsRow.style.display = 'none';
        }
    }
}

// Add data-category to variant detail rows as well
document.addEventListener('DOMContentLoaded', function() {
    const variantRows = document.querySelectorAll('.variant-details-row');
    variantRows.forEach(vr => {
        const productRow = vr.previousElementSibling;
        if (productRow && productRow.classList.contains('product-row')) {
            const category = productRow.getAttribute('data-category');
            vr.setAttribute('data-category', category);
            vr.setAttribute('data-product-id', productRow.getAttribute('data-product-id'));
        }
    });
});
</script>

</body>
</html>
