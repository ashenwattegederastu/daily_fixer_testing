<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.dao.OrderDAO" %>
<%@ page import="com.dailyfixer.dao.StoreDAO" %>
<%@ page import="com.dailyfixer.dao.UserDAO" %>
<%@ page import="com.dailyfixer.model.Order" %>
<%@ page import="com.dailyfixer.model.OrderItem" %>
<%@ page import="com.dailyfixer.model.Store" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.math.BigDecimal" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
%>

<%
    // Get order_id from URL parameter
    String orderIdParam = request.getParameter("order_id");
    Order order = null;
    List<Order> allRelatedOrders = new ArrayList<>(); // Store all related orders for multi-store purchases
    OrderDAO orderDAO = new OrderDAO(); // Declare orderDAO outside if block for use in JSP rendering
    
    if (orderIdParam != null && !orderIdParam.isEmpty()) {
        order = orderDAO.findOrderById(orderIdParam);
        
        // Update order status to PAID if it's still PENDING
        // This is a fallback in case NotifyServlet wasn't called (common in sandbox/development)
        if (order != null) {
            String currentStatus = order.getStatus() != null ? order.getStatus().trim() : "";
            boolean statusChangedToPaid = false;
            
            if ("PENDING".equalsIgnoreCase(currentStatus)) {
                boolean updated = orderDAO.updateStatus(orderIdParam, "PAID");
                if (updated) {
                    System.out.println("Order status updated to PAID on success page: " + orderIdParam);
                    statusChangedToPaid = true;
                    // Refresh order data first
                    order = orderDAO.findOrderById(orderIdParam);
                    
                    // Reduce stock for this order
                    try {
                        boolean stockReduced = orderDAO.reduceStockForOrder(orderIdParam);
                        if (stockReduced) {
                            System.out.println("Stock reduced successfully for order: " + orderIdParam);
                        } else {
                            System.err.println("Warning: Stock reduction failed or incomplete for order: " + orderIdParam);
                        }
                    } catch (Exception e) {
                        System.err.println("Error reducing stock for order " + orderIdParam + ": " + e.getMessage());
                        e.printStackTrace();
                    }
                } else {
                    System.err.println("Failed to update order status to PAID: " + orderIdParam);
                }
            } else if (!"PAID".equalsIgnoreCase(currentStatus)) {
                // If status is not PAID and not PENDING, update to PAID anyway (for safety)
                System.out.println("Order status is '" + currentStatus + "', updating to PAID: " + orderIdParam);
                boolean updated = orderDAO.updateStatus(orderIdParam, "PAID");
                if (updated) {
                    statusChangedToPaid = true;
                    order = orderDAO.findOrderById(orderIdParam);
                    
                    // Reduce stock for this order
                    try {
                        boolean stockReduced = orderDAO.reduceStockForOrder(orderIdParam);
                        if (stockReduced) {
                            System.out.println("Stock reduced successfully for order: " + orderIdParam);
                        } else {
                            System.err.println("Warning: Stock reduction failed or incomplete for order: " + orderIdParam);
                        }
                    } catch (Exception e) {
                        System.err.println("Error reducing stock for order " + orderIdParam + ": " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
            // Note: If order is already PAID, we don't reduce stock again to avoid duplicate reductions
            
            // Get all related orders from session (stored during checkout)
            @SuppressWarnings("unchecked")
            List<String> allOrderIds = (List<String>) session.getAttribute("allOrderIds");
            
            if (allOrderIds != null && !allOrderIds.isEmpty()) {
                // Fetch all orders by their IDs
                for (String orderId : allOrderIds) {
                    try {
                        Order relatedOrder = orderDAO.findOrderById(orderId);
                        if (relatedOrder != null) {
                            allRelatedOrders.add(relatedOrder);
                        }
                    } catch (Exception e) {
                        System.err.println("Error fetching order " + orderId + ": " + e.getMessage());
                    }
                }
            }
            
            // Fallback: If no orders from session, find by email and time
            if (allRelatedOrders.isEmpty() && order.getEmail() != null) {
                try {
                    List<Order> allOrders = orderDAO.getOrdersByStatus("PAID");
                    for (Order relatedOrder : allOrders) {
                        if (relatedOrder.getEmail() != null && 
                            relatedOrder.getEmail().equals(order.getEmail()) &&
                            relatedOrder.getCreatedAt() != null && order.getCreatedAt() != null) {
                            long timeDiff = Math.abs(relatedOrder.getCreatedAt().getTime() - order.getCreatedAt().getTime());
                            if (timeDiff < 300000) { // 5 minutes in milliseconds
                                allRelatedOrders.add(relatedOrder);
                            }
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Warning: Could not get related orders: " + e.getMessage());
                }
            }
            
            // If still no related orders, just use the main order
            if (allRelatedOrders.isEmpty()) {
                allRelatedOrders.add(order);
            }
        } else {
            System.err.println("Order not found for order_id: " + orderIdParam);
        }
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    
    // Helper function to update related orders (for multi-store orders)
    if (order != null && order.getEmail() != null) {
        try {
            OrderDAO tempOrderDAO = new OrderDAO();
            // Update all orders with same email and PENDING status created recently
            List<Order> relatedOrders = tempOrderDAO.getOrdersByStatus("PENDING");
            for (Order relatedOrder : relatedOrders) {
                if (relatedOrder.getEmail() != null && 
                    relatedOrder.getEmail().equals(order.getEmail()) &&
                    !relatedOrder.getOrderId().equals(order.getOrderId())) {
                    // Check if created within last 5 minutes (related order)
                    if (relatedOrder.getCreatedAt() != null && order.getCreatedAt() != null) {
                        long timeDiff = Math.abs(relatedOrder.getCreatedAt().getTime() - order.getCreatedAt().getTime());
                        if (timeDiff < 300000) { // 5 minutes in milliseconds
                            String relatedStatus = relatedOrder.getStatus() != null ? relatedOrder.getStatus().trim() : "";
                            if (!"PAID".equalsIgnoreCase(relatedStatus)) {
                                tempOrderDAO.updateStatus(relatedOrder.getOrderId(), "PAID");
                                System.out.println("Updated related order to PAID: " + relatedOrder.getOrderId());
                                
                                // Reduce stock for related order
                                try {
                                    boolean stockReduced = tempOrderDAO.reduceStockForOrder(relatedOrder.getOrderId());
                                    if (stockReduced) {
                                        System.out.println("Stock reduced successfully for related order: " + relatedOrder.getOrderId());
                                    } else {
                                        System.err.println("Warning: Stock reduction failed for related order: " + relatedOrder.getOrderId());
                                    }
                                } catch (Exception e) {
                                    System.err.println("Error reducing stock for related order " + relatedOrder.getOrderId() + ": " + e.getMessage());
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Warning: Could not update related orders: " + e.getMessage());
        }
    }
    
    // Prepare order data for receipt
    String customerName = "";
    String orderDate = "";
    String totalAmount = "";
    List<OrderItem> allOrderItems = new ArrayList<>();
    BigDecimal combinedTotal = BigDecimal.ZERO;
    
    // Store information map (storeId -> Store info with User details)
    Map<Integer, Map<String, String>> storeInfoMap = new HashMap<>();
    StoreDAO storeDAO = new StoreDAO();
    UserDAO userDAO = new UserDAO();
    
    if (order != null) {
        customerName = order.getFirstName() + (order.getLastName() != null && !order.getLastName().isEmpty() ? " " + order.getLastName() : "");
        orderDate = order.getCreatedAt() != null ? dateFormat.format(order.getCreatedAt()) : "N/A";
        totalAmount = String.format("LKR %.2f", order.getAmount());
        
        // Get all order items from all related orders
        for (Order relatedOrder : allRelatedOrders) {
            List<OrderItem> items = orderDAO.getOrderItemsByOrderId(relatedOrder.getOrderId());
            if (items != null) {
                allOrderItems.addAll(items);
                
                // Collect unique store information
                for (OrderItem item : items) {
                    int storeId = item.getStoreId();
                    if (!storeInfoMap.containsKey(storeId)) {
                        try {
                            Store store = storeDAO.getStoreById(storeId);
                            if (store != null) {
                                Map<String, String> storeInfo = new HashMap<>();
                                storeInfo.put("storeName", store.getStoreName() != null ? store.getStoreName() : "N/A");
                                storeInfo.put("storeAddress", store.getStoreAddress() != null ? store.getStoreAddress() : "N/A");
                                storeInfo.put("storeCity", store.getStoreCity() != null ? store.getStoreCity() : "N/A");
                                
                                // Get user (store owner) information for contact and email
                                try {
                                    User storeOwner = userDAO.getUserById(store.getUserId());
                                    if (storeOwner != null) {
                                        storeInfo.put("contact", storeOwner.getPhoneNumber() != null ? storeOwner.getPhoneNumber() : "N/A");
                                        storeInfo.put("email", storeOwner.getEmail() != null ? storeOwner.getEmail() : "N/A");
                                    } else {
                                        storeInfo.put("contact", "N/A");
                                        storeInfo.put("email", "N/A");
                                    }
                                } catch (Exception e) {
                                    System.err.println("Error getting store owner info: " + e.getMessage());
                                    storeInfo.put("contact", "N/A");
                                    storeInfo.put("email", "N/A");
                                }
                                
                                storeInfoMap.put(storeId, storeInfo);
                            }
                        } catch (Exception e) {
                            System.err.println("Error getting store info for storeId " + storeId + ": " + e.getMessage());
                        }
                    }
                }
            }
            if (relatedOrder.getAmount() != null) {
                combinedTotal = combinedTotal.add(relatedOrder.getAmount());
            }
        }
        
        if (combinedTotal.compareTo(BigDecimal.ZERO) > 0) {
            totalAmount = String.format("LKR %.2f", combinedTotal);
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Payment Successful - DailyFixer">
    <title>Payment Successful - Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
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
  --success: oklch(0.6290 0.1902 156.4499);
  --success-light: oklch(0.9000 0.0500 156.4499);
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
  --success: oklch(0.7000 0.2000 156.4499);
  --success-light: oklch(0.3000 0.1000 156.4499);
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
  padding-top: 80px;
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
  border-bottom: 1px solid var(--border);
  transition: all 0.3s ease;
}

.dark nav.public-nav {
  background-color: rgba(34, 35, 48, 0.1);
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

.nav-buttons {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.btn-logout {
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

.btn-logout:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

/* Main Content */
.main-content {
  max-width: 900px;
  margin: 0 auto;
  padding: 40px 20px;
}

.result-card {
  background: var(--card);
  border-radius: var(--radius-lg);
  padding: 3rem 2.5rem;
  box-shadow: var(--shadow-lg);
  text-align: center;
  position: relative;
  overflow: hidden;
  border: 1px solid var(--border);
}

.result-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 5px;
  background: linear-gradient(90deg, var(--success), var(--chart-1));
}

.result-icon {
  width: 100px;
  height: 100px;
  margin: 0 auto 2rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--success-light);
  animation: successPulse 2s ease-in-out infinite;
}

@keyframes successPulse {
  0%, 100% {
    transform: scale(1);
    box-shadow: 0 0 0 0 var(--success);
  }
  50% {
    transform: scale(1.05);
    box-shadow: 0 0 0 10px transparent;
  }
}

.result-icon svg {
  width: 50px;
  height: 50px;
  stroke: var(--success);
  stroke-width: 2.5;
}

h1 {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: var(--success);
}

.subtitle {
  color: var(--muted-foreground);
  font-size: 1.1rem;
  margin-bottom: 2.5rem;
  line-height: 1.6;
}

.order-details {
  background: var(--muted);
  border-radius: var(--radius-md);
  padding: 2rem;
  margin: 2rem 0;
  border: 1px solid var(--border);
  text-align: left;
}

.order-section {
  margin-bottom: 1.5rem;
}

.order-section:last-child {
  margin-bottom: 0;
}

.section-title {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--primary);
  margin-bottom: 1rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid var(--border);
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
  border-bottom: 1px solid var(--border);
}

.detail-row:last-child {
  border-bottom: none;
}

.detail-label {
  font-weight: 600;
  color: var(--foreground);
  font-size: 0.95rem;
}

.detail-value {
  font-weight: 500;
  color: var(--foreground);
  font-size: 0.95rem;
  text-align: right;
  max-width: 60%;
  word-wrap: break-word;
}

.status-paid {
  display: inline-block;
  padding: 0.5rem 1rem;
  background: var(--success);
  color: white;
  border-radius: var(--radius-md);
  font-weight: 600;
  font-size: 0.85rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  box-shadow: var(--shadow-sm);
}

.amount-highlight {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--primary);
}

.product-item {
  padding: 0.75rem;
  background: var(--card);
  border-radius: var(--radius-sm);
  border-left: 3px solid var(--primary);
  margin-bottom: 0.5rem;
}

.product-item-name {
  font-weight: 600;
  color: var(--foreground);
  margin-bottom: 0.25rem;
}

.product-item-details {
  font-size: 0.9em;
  color: var(--muted-foreground);
}

.action-buttons {
  display: flex;
  gap: 1rem;
  margin-top: 2.5rem;
  flex-wrap: wrap;
  justify-content: center;
}

.btn-primary, .btn-secondary {
  min-width: 200px;
  padding: 1rem 2rem;
  border: none;
  border-radius: var(--radius-md);
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  box-shadow: var(--shadow-sm);
}

.btn-primary {
  background: var(--primary);
  color: var(--primary-foreground);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  opacity: 0.9;
}

.btn-secondary {
  background: var(--secondary);
  color: var(--secondary-foreground);
  border: 1.5px solid var(--border);
}

.btn-secondary:hover {
  transform: translateY(-2px);
  background: var(--accent);
  color: var(--accent-foreground);
  box-shadow: var(--shadow-md);
}

.btn-download {
  background: var(--success);
  color: white;
}

.btn-download:hover {
  background: var(--chart-1);
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.success-message {
  margin-top: 2.5rem;
  padding: 1.5rem;
  background: var(--muted);
  border-radius: var(--radius-md);
  border-left: 4px solid var(--success);
}

.success-message p {
  color: var(--foreground);
  margin-bottom: 0.5rem;
  line-height: 1.6;
  font-weight: 500;
}

.success-message p:last-child {
  margin-bottom: 0;
}

/* Footer */
footer {
  text-align: center;
  padding: 2rem 20px;
  color: var(--muted-foreground);
  font-size: 0.9rem;
}

/* Receipt Print Styles */
@media print {
  body {
    padding-top: 0;
  }
  
  nav, .action-buttons, footer, .success-message {
    display: none;
  }
  
  .result-card {
    box-shadow: none;
    border: none;
  }
  
  .order-details {
    page-break-inside: avoid;
  }
}

/* Responsive */
@media (max-width: 768px) {
  .result-card {
    padding: 2rem 1.5rem;
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

  .nav-container {
    padding: 1rem;
  }
}
    </style>
</head>

<body>
    <!-- Navigation -->
    <nav class="public-nav">
        <div class="nav-container">
            <a href="<%=request.getContextPath()%>/index.jsp" class="logo">Daily Fixer</a>
            <div class="nav-buttons">
                <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
                <% if (isLoggedIn) { %>
                    <form action="<%=request.getContextPath()%>/logout" method="post" style="margin: 0; display: inline;">
                        <button type="submit" class="btn-logout">Logout</button>
                    </form>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
        <div class="result-card">
            <div class="result-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <circle cx="12" cy="12" r="10"></circle>
                    <path d="M9 12l2 2 4-4"></path>
                </svg>
            </div>

            <h1>Payment Successful!</h1>
            <p class="subtitle">
                Thank you for your purchase. Your order has been confirmed and will be processed shortly.
            </p>

            <% if (order != null) { %>
                <div class="order-details" id="orderDetails">
                    <!-- Order Information -->
                    <div class="order-section">
                        <div class="section-title">Order Information</div>
                        <div class="detail-row">
                            <span class="detail-label">Order ID</span>
                            <span class="detail-value"><%= order.getOrderId() %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Order Date</span>
                            <span class="detail-value"><%= orderDate %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Payment Status</span>
                            <span class="status-paid">PAID</span>
                        </div>
                    </div>

                    <!-- Customer Information -->
                    <div class="order-section">
                        <div class="section-title">Customer Information</div>
                        <div class="detail-row">
                            <span class="detail-label">Name</span>
                            <span class="detail-value"><%= customerName %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Email</span>
                            <span class="detail-value"><%= order.getEmail() != null ? order.getEmail() : "N/A" %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Phone</span>
                            <span class="detail-value"><%= order.getPhone() != null ? order.getPhone() : "N/A" %></span>
                        </div>
                    </div>

                    <!-- Delivery Information -->
                    <div class="order-section">
                        <div class="section-title">Delivery Information</div>
                        <div class="detail-row">
                            <span class="detail-label">Address</span>
                            <span class="detail-value"><%= order.getAddress() != null ? order.getAddress() : "N/A" %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">City</span>
                            <span class="detail-value"><%= order.getCity() != null ? order.getCity() : "N/A" %></span>
                        </div>
                    </div>

                    <!-- Store Information -->
                    <% if (!storeInfoMap.isEmpty()) { %>
                        <div class="order-section">
                            <div class="section-title">Store Information</div>
                            <% 
                                int storeIndex = 0;
                                for (Map.Entry<Integer, Map<String, String>> storeEntry : storeInfoMap.entrySet()) {
                                    Map<String, String> storeInfo = storeEntry.getValue();
                                    storeIndex++;
                            %>
                                <% if (storeInfoMap.size() > 1) { %>
                                    <div style="margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px solid var(--border);">
                                        <div style="font-weight: 600; color: var(--primary); margin-bottom: 0.5rem;">Store <%= storeIndex %></div>
                                <% } %>
                                <div class="detail-row">
                                    <span class="detail-label">Store Name</span>
                                    <span class="detail-value"><%= storeInfo.get("storeName") %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Store Address</span>
                                    <span class="detail-value"><%= storeInfo.get("storeAddress") %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Store City</span>
                                    <span class="detail-value"><%= storeInfo.get("storeCity") %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Contact</span>
                                    <span class="detail-value"><%= storeInfo.get("contact") %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Email</span>
                                    <span class="detail-value"><%= storeInfo.get("email") %></span>
                                </div>
                                <% if (storeInfoMap.size() > 1 && storeIndex < storeInfoMap.size()) { %>
                                    </div>
                                <% } %>
                            <% } %>
                        </div>
                    <% } %>

                    <!-- Order Summary -->
                    <div class="order-section">
                        <div class="section-title">Order Summary</div>
                        <div class="detail-row" style="flex-direction: column; align-items: flex-start;">
                            <span class="detail-label" style="margin-bottom: 10px;">Products</span>
                            <div style="width: 100%;">
                                <% 
                                    if (allOrderItems.isEmpty()) {
                                        // Fallback to product_name if order_items not available
                                        StringBuilder allProducts = new StringBuilder();
                                        for (int i = 0; i < allRelatedOrders.size(); i++) {
                                            Order relatedOrder = allRelatedOrders.get(i);
                                            if (relatedOrder.getProductName() != null && !relatedOrder.getProductName().isEmpty()) {
                                                if (i > 0) {
                                                    allProducts.append(", ");
                                                }
                                                allProducts.append(relatedOrder.getProductName());
                                            }
                                        }
                                        String displayProducts = allProducts.length() > 0 ? allProducts.toString() : "N/A";
                                %>
                                    <span class="detail-value"><%= displayProducts %></span>
                                <% } else { %>
                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                        <% for (OrderItem item : allOrderItems) { %>
                                            <div class="product-item">
                                                <div class="product-item-name"><%= item.getProductName() %></div>
                                                <div class="product-item-details">
                                                    Quantity: <%= item.getQuantity() %> × LKR <%= String.format("%.2f", item.getUnitPrice()) %> = LKR <%= String.format("%.2f", item.getTotalPrice()) %>
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Total Amount</span>
                            <span class="detail-value amount-highlight"><%= totalAmount %></span>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <div class="order-details">
                    <div class="detail-row">
                        <span class="detail-label">Order ID</span>
                        <span class="detail-value" id="order-id">Loading...</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Payment Status</span>
                        <span class="status-paid">PAID</span>
                    </div>
                </div>
            <% } %>

            <div class="action-buttons">
                <button onclick="downloadReceipt()" class="btn-primary btn-download">
                    📄 Download Receipt
                </button>
                <a href="store_main.jsp" class="btn-primary">
                    🛒 Continue Shopping
                </a>
                <a href="<%=request.getContextPath()%>/index.jsp" class="btn-secondary">
                    🏠 Back to Home
                </a>
            </div>

            <div class="success-message">
                <p>✅ Your payment has been successfully processed.</p>
                <p>📧 A confirmation email has been sent to your email address.</p>
                <p>📦 Your order will be prepared and shipped soon.</p>
                <p>📞 Our team will contact you if there are any updates regarding your order.</p>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer>
        <p>&copy; 2026 DailyFixer. All rights reserved.</p>
    </footer>

    <script>
        // Get order info from URL params if order not found in database
        document.addEventListener('DOMContentLoaded', function () {
            <% if (order == null) { %>
                const urlParams = new URLSearchParams(window.location.search);
                const orderId = urlParams.get('order_id');
                if (orderId) {
                    const orderIdElement = document.getElementById('order-id');
                    if (orderIdElement) {
                        orderIdElement.textContent = orderId;
                    }
                }
            <% } %>
        });

        // Download Receipt Function
        function downloadReceipt() {
            const orderDetails = document.getElementById('orderDetails');
            if (!orderDetails) {
                alert('Order details not available');
                return;
            }

            // Create a new window for printing
            const printWindow = window.open('', '_blank');
            
            // Get all order data
            <%
                // Escape JavaScript strings properly
                String safeOrderId = order != null ? order.getOrderId().replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ") : "N/A";
                String safeOrderDate = orderDate.replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeCustomerName = customerName.replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeEmail = (order != null && order.getEmail() != null ? order.getEmail() : "N/A").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safePhone = (order != null && order.getPhone() != null ? order.getPhone() : "N/A").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeAddress = (order != null && order.getAddress() != null ? order.getAddress() : "N/A").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeCity = (order != null && order.getCity() != null ? order.getCity() : "N/A").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeTotalAmount = totalAmount.replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
            %>
            const orderData = {
                orderId: '<%= safeOrderId %>',
                orderDate: '<%= safeOrderDate %>',
                customerName: '<%= safeCustomerName %>',
                email: '<%= safeEmail %>',
                phone: '<%= safePhone %>',
                address: '<%= safeAddress %>',
                city: '<%= safeCity %>',
                totalAmount: '<%= safeTotalAmount %>',
                stores: [
                    <% if (!storeInfoMap.isEmpty()) { %>
                        <% 
                            int storeIdx = 0;
                            for (Map.Entry<Integer, Map<String, String>> storeEntry : storeInfoMap.entrySet()) {
                                Map<String, String> storeInfo = storeEntry.getValue();
                                String safeStoreName = storeInfo.get("storeName").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                                String safeStoreAddress = storeInfo.get("storeAddress").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                                String safeStoreCity = storeInfo.get("storeCity").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                                String safeContact = storeInfo.get("contact").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                                String safeStoreEmail = storeInfo.get("email").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                        %>
                            {
                                name: '<%= safeStoreName %>',
                                address: '<%= safeStoreAddress %>',
                                city: '<%= safeStoreCity %>',
                                contact: '<%= safeContact %>',
                                email: '<%= safeStoreEmail %>'
                            }<%= storeIdx < storeInfoMap.size() - 1 ? "," : "" %>
                        <% 
                                storeIdx++;
                            }
                        %>
                    <% } %>
                ],
                items: [
                    <% if (!allOrderItems.isEmpty()) { %>
                        <% for (int i = 0; i < allOrderItems.size(); i++) { 
                            OrderItem item = allOrderItems.get(i);
                            String itemName = item.getProductName().replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                        %>
                            {
                                name: '<%= itemName %>',
                                quantity: <%= item.getQuantity() %>,
                                unitPrice: <%= item.getUnitPrice() %>,
                                totalPrice: <%= item.getTotalPrice() %>
                            }<%= i < allOrderItems.size() - 1 ? "," : "" %>
                        <% } %>
                    <% } %>
                ]
            };

            // Build receipt HTML using string concatenation
            let receiptHTML = '<!DOCTYPE html><html><head>';
            receiptHTML += '<meta charset="UTF-8">';
            receiptHTML += '<title>Receipt - Order ' + orderData.orderId + '</title>';
            receiptHTML += '<style>';
            receiptHTML += '* { margin: 0; padding: 0; box-sizing: border-box; }';
            receiptHTML += 'body { font-family: Arial, sans-serif; padding: 40px; max-width: 800px; margin: 0 auto; background: white; color: #000; }';
            receiptHTML += '.receipt-header { text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 3px solid #8b7dd8; }';
            receiptHTML += '.receipt-header h1 { color: #8b7dd8; font-size: 2rem; margin-bottom: 10px; }';
            receiptHTML += '.receipt-header p { color: #666; font-size: 0.9rem; }';
            receiptHTML += '.receipt-section { margin-bottom: 25px; }';
            receiptHTML += '.receipt-section h2 { color: #8b7dd8; font-size: 1.2rem; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 2px solid #e0e0e0; }';
            receiptHTML += '.receipt-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f0f0f0; }';
            receiptHTML += '.receipt-row:last-child { border-bottom: none; }';
            receiptHTML += '.receipt-label { font-weight: 600; color: #333; }';
            receiptHTML += '.receipt-value { color: #666; text-align: right; }';
            receiptHTML += '.receipt-items { margin-top: 10px; }';
            receiptHTML += '.receipt-item { padding: 12px; background: #f9f9f9; border-left: 3px solid #8b7dd8; margin-bottom: 10px; border-radius: 4px; }';
            receiptHTML += '.receipt-item-name { font-weight: 600; color: #333; margin-bottom: 5px; }';
            receiptHTML += '.receipt-item-details { font-size: 0.9em; color: #666; }';
            receiptHTML += '.receipt-total { margin-top: 20px; padding-top: 15px; border-top: 2px solid #8b7dd8; }';
            receiptHTML += '.receipt-total .receipt-row { font-size: 1.2rem; font-weight: 700; color: #8b7dd8; }';
            receiptHTML += '.receipt-footer { margin-top: 40px; padding-top: 20px; border-top: 2px solid #e0e0e0; text-align: center; color: #666; font-size: 0.9rem; }';
            receiptHTML += '@media print { body { padding: 20px; } }';
            receiptHTML += '</style></head><body>';
            
            // Header
            receiptHTML += '<div class="receipt-header">';
            receiptHTML += '<h1>Daily Fixer</h1>';
            receiptHTML += '<p>Order Receipt</p>';
            receiptHTML += '</div>';
            
            // Order Information
            receiptHTML += '<div class="receipt-section">';
            receiptHTML += '<h2>Order Information</h2>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Order ID:</span><span class="receipt-value">' + orderData.orderId + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Order Date:</span><span class="receipt-value">' + orderData.orderDate + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Payment Status:</span><span class="receipt-value" style="color: #27ae60; font-weight: 600;">PAID</span></div>';
            receiptHTML += '</div>';
            
            // Customer Information
            receiptHTML += '<div class="receipt-section">';
            receiptHTML += '<h2>Customer Information</h2>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Name:</span><span class="receipt-value">' + orderData.customerName + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Email:</span><span class="receipt-value">' + orderData.email + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Phone:</span><span class="receipt-value">' + orderData.phone + '</span></div>';
            receiptHTML += '</div>';
            
            // Delivery Information
            receiptHTML += '<div class="receipt-section">';
            receiptHTML += '<h2>Delivery Information</h2>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Address:</span><span class="receipt-value">' + orderData.address + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">City:</span><span class="receipt-value">' + orderData.city + '</span></div>';
            receiptHTML += '</div>';
            
            // Store Information
            if (orderData.stores && orderData.stores.length > 0) {
                receiptHTML += '<div class="receipt-section">';
                receiptHTML += '<h2>Store Information</h2>';
                for (let i = 0; i < orderData.stores.length; i++) {
                    const store = orderData.stores[i];
                    if (orderData.stores.length > 1) {
                        receiptHTML += '<div style="margin-bottom: 15px; padding-bottom: 15px; border-bottom: 1px solid #e0e0e0;">';
                        receiptHTML += '<div style="font-weight: 600; color: #8b7dd8; margin-bottom: 8px;">Store ' + (i + 1) + '</div>';
                    }
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Store Name:</span><span class="receipt-value">' + store.name + '</span></div>';
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Store Address:</span><span class="receipt-value">' + store.address + '</span></div>';
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Store City:</span><span class="receipt-value">' + store.city + '</span></div>';
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Contact:</span><span class="receipt-value">' + store.contact + '</span></div>';
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Email:</span><span class="receipt-value">' + store.email + '</span></div>';
                    if (orderData.stores.length > 1 && i < orderData.stores.length - 1) {
                        receiptHTML += '</div>';
                    }
                }
                receiptHTML += '</div>';
            }
            
            // Order Summary
            receiptHTML += '<div class="receipt-section">';
            receiptHTML += '<h2>Order Summary</h2>';
            receiptHTML += '<div class="receipt-items">';
            
            // Build items HTML
            for (let i = 0; i < orderData.items.length; i++) {
                const item = orderData.items[i];
                receiptHTML += '<div class="receipt-item">';
                receiptHTML += '<div class="receipt-item-name">' + item.name + '</div>';
                receiptHTML += '<div class="receipt-item-details">';
                receiptHTML += 'Quantity: ' + item.quantity + ' × LKR ' + item.unitPrice.toFixed(2) + ' = LKR ' + item.totalPrice.toFixed(2);
                receiptHTML += '</div>';
                receiptHTML += '</div>';
            }
            
            receiptHTML += '</div>';
            receiptHTML += '<div class="receipt-total">';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Total Amount:</span><span class="receipt-value">' + orderData.totalAmount + '</span></div>';
            receiptHTML += '</div>';
            receiptHTML += '</div>';
            
            // Footer
            receiptHTML += '<div class="receipt-footer">';
            receiptHTML += '<p>Thank you for your purchase!</p>';
            receiptHTML += '<p>Daily Fixer - Fix, Learn, Restore</p>';
            receiptHTML += '<p>This is a computer-generated receipt.</p>';
            receiptHTML += '</div>';
            
            receiptHTML += '</body></html>';

            // Write receipt to new window
            printWindow.document.write(receiptHTML);
            printWindow.document.close();

            // Wait for content to load, then print
            setTimeout(() => {
                printWindow.print();
            }, 250);
        }
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
</body>

</html>
