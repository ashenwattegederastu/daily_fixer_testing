<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Order" %>
<%@ page import="com.dailyfixer.model.OrderItem" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<% User user = (User) session.getAttribute("currentUser");
    if (user == null ||
            user.getRole() == null || !"user".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp"
        );
        return;
    } %>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Purchases | Daily Fixer</title>
    <link
            href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
            rel="stylesheet">


    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        /* Order Cards Grid */
        .orders-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: 24px;
        }

        /* Order Card */
        .order-card {
            background: var(--card);
            color: var(--card-foreground);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            overflow: hidden;
            transition: all 0.3s ease;
            border: 1px solid var(--border);
        }

        .order-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
        }

        .order-header {
            background: var(--background);
            padding: 16px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
        }

        .order-id {
            color: var(--primary);
            font-weight: 700;
            font-size: 1em;
        }

        .order-date {
            color: var(--muted-foreground);
            font-size: 0.85em;
        }

        .order-items {
            padding: 20px;
        }

        /* Product Item */
        .product-item {
            display: flex;
            gap: 16px;
            padding: 16px;
            background: var(--muted);
            border-radius: var(--radius-md);
            margin-bottom: 12px;
            transition: all 0.2s ease;
        }

        .product-item:last-child {
            margin-bottom: 0;
        }

        .product-item:hover {
            background: var(--accent);
        }

        .product-image {
            width: 80px;
            height: 80px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            object-fit: cover;
            background: var(--muted);
            flex-shrink: 0;
        }

        .product-placeholder {
            width: 80px;
            height: 80px;
            border-radius: var(--radius-sm);
            background: var(--input);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--muted-foreground);
            font-size: 2em;
            flex-shrink: 0;
        }

        .product-details {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .product-name {
            font-weight: 600;
            color: var(--foreground);
            margin-bottom: 6px;
            font-size: 0.95em;
            line-height: 1.4;
        }

        .product-meta {
            display: flex;
            gap: 16px;
            color: var(--muted-foreground);
            font-size: 0.85em;
        }

        .product-qty {
            background: var(--background);
            padding: 2px 10px;
            border-radius: 20px;
            font-weight: 500;
            color: var(--primary);
            border: 1px solid var(--border);
        }

        .product-price {
            font-weight: 600;
            color: var(--primary);
        }

        /* Order Footer */
        .order-footer {
            padding: 16px 20px;
            background: var(--muted);
            border-top: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .order-total {
            font-size: 1.1em;
            color: var(--foreground);
        }

        .order-total span {
            color: var(--muted-foreground);
            font-size: 0.85em;
        }

        .order-total strong {
            color: var(--primary);
            font-weight: 700;
        }

        /* Status Badges */
        .status-badge {
            padding: 6px 14px;
            border-radius: 25px;
            font-size: 0.75em;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-pending {
            background: color-mix(in srgb, var(--primary) 15%, transparent);
            color: var(--primary);
        }

        .status-paid {
            background: color-mix(in srgb, #10b981 15%, transparent);
            color: #10b981;
        }

        .status-processing {
            background: color-mix(in srgb, #3b82f6 15%, transparent);
            color: #3b82f6;
        }

        .status-out_for_delivery {
            background: color-mix(in srgb, #f59e0b 15%, transparent);
            color: #f59e0b;
        }

        .status-delivered {
            background: color-mix(in srgb, #10b981 15%, transparent);
            color: #10b981;
        }

        .status-cancelled {
            background: color-mix(in srgb, var(--destructive) 15%, transparent);
            color: var(--destructive);
        }

        .status-refund_pending {
            background: color-mix(in srgb, #f59e0b 15%, transparent);
            color: #b45309;
        }

        .status-refunded {
            background: color-mix(in srgb, #6366f1 15%, transparent);
            color: #4f46e5;
        }

        /* Reuse framework's empty-state and btn-primary */
        .empty-state {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
        }

        .empty-icon {
            font-size: 4em;
            margin-bottom: 20px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .orders-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<jsp:include page="sidebar.jsp" />
<main class="dashboard-container">
    <div class="page-header">
        <h2>My Purchases</h2>
        <p>Track your orders and view purchase history</p>
    </div>
    <c:choose>
        <c:when test="${not empty orders}">
            <div class="orders-grid">
                <c:forEach var="order" items="${orders}">
                    <div class="order-card">
                        <div class="order-header">
                            <span class="order-id">${order.orderId}</span>
                            <span class="order-date">
                                <c:if test="${order.createdAt != null}">
                                    <fmt:formatDate
                                            value="${order.createdAt}"
                                            pattern="MMM dd, yyyy"/>
                                </c:if>
                            </span>
                        </div>
                        <div class="order-items">
                            <c:choose>
                                <c:when
                                        test="${not empty orderItemsMap[order.orderId]}">
                                    <c:forEach var="item"
                                               items="${orderItemsMap[order.orderId]}">
                                        <div class="product-item">
                                            <c:choose>
                                                <c:when
                                                        test="${not empty productsMap[item.productId] and not empty productsMap[item.productId].imageBase64}">
                                                    <img src="data:image/jpeg;base64,${productsMap[item.productId].imageBase64}"
                                                         alt="${item.productName}"
                                                         class="product-image">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="product-placeholder">
                                                        📦
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div class="product-details">
                                                <div class="product-name">
                                                        ${item.productName}
                                                </div>
                                                <div class="product-meta">
                                                    <span class="product-qty">x${item.quantity}</span>
                                                    <span class="product-price">LKR${item.unitPrice}</span>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="product-item">
                                        <div class="product-placeholder">
                                            📦
                                        </div>
                                        <div class="product-details">
                                            <div class="product-name">
                                                    ${order.productName}
                                            </div>
                                            <div class="product-meta">
                                                <span class="product-price">${order.currency}${order.formattedAmount}</span>
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="order-footer">
                            <div class="order-total">
                                <span>Total:</span>
                                <strong>${order.currency}
                                        ${order.formattedAmount}</strong>
                            </div>
                            <c:set var="statusClass"
                                   value="status-${fn:toLowerCase(order.status)}"/>
                            <c:choose>
                                <c:when test="${order.status == 'REFUND_PENDING'}">
                                    <span class="status-badge ${statusClass}">Refund Pending</span>
                                </c:when>
                                <c:when test="${order.status == 'REFUNDED'}">
                                    <span class="status-badge ${statusClass}">Refunded</span>
                                </c:when>
                                <c:when test="${order.status == 'OUT_FOR_DELIVERY'}">
                                    <span class="status-badge ${statusClass}">Out for Delivery</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge ${statusClass}">${order.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div class="empty-icon">🛒</div>
                <h3>No Orders Yet</h3>
                <p>You haven't made any purchases yet. Start exploring
                    our stores to find amazing products!</p>
                <a href="${pageContext.request.contextPath}/stores"
                   class="btn-primary">Browse Stores</a>
            </div>
        </c:otherwise>
    </c:choose>
</main>
</body>
</html>