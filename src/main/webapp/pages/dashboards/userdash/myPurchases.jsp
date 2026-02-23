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

                                        <% User user=(User) session.getAttribute("currentUser"); if (user==null ||
                                            user.getRole()==null || !"user".equalsIgnoreCase(user.getRole().trim())) {
                                            response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp"
                                            ); return; } %>

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
                                                        background: #ffffff;
                                                        border-radius: 20px;
                                                        box-shadow: var(--shadow-md);
                                                        overflow: hidden;
                                                        transition: all 0.3s ease;
                                                        border: 1px solid rgba(139, 149, 255, 0.1);
                                                    }

                                                    .order-card:hover {
                                                        transform: translateY(-5px);
                                                        box-shadow: var(--shadow-lg);
                                                    }

                                                    .order-header {
                                                        background: var(--gradient-primary, linear-gradient(135deg, #8b95ff 0%, #a8b4ff 100%));
                                                        padding: 16px 20px;
                                                        display: flex;
                                                        justify-content: space-between;
                                                        align-items: center;
                                                    }

                                                    .order-id {
                                                        color: #ffffff;
                                                        font-weight: 700;
                                                        font-size: 1em;
                                                    }

                                                    .order-date {
                                                        color: rgba(255, 255, 255, 0.85);
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
                                                        background: #f8f9ff;
                                                        border-radius: 14px;
                                                        margin-bottom: 12px;
                                                        transition: all 0.2s ease;
                                                    }

                                                    .product-item:last-child {
                                                        margin-bottom: 0;
                                                    }

                                                    .product-item:hover {
                                                        background: #f0f2ff;
                                                    }

                                                    .product-image {
                                                        width: 80px;
                                                        height: 80px;
                                                        border-radius: 12px;
                                                        border: 1px solid rgba(0, 0, 0, 0.1);
                                                        object-fit: cover;
                                                        background: linear-gradient(135deg, #e0e0e0, #f5f5f5);
                                                        flex-shrink: 0;
                                                        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
                                                    }

                                                    .product-placeholder {
                                                        width: 80px;
                                                        height: 80px;
                                                        border-radius: 12px;
                                                        background: linear-gradient(135deg, var(--panel-color), #e8e6ff);
                                                        display: flex;
                                                        align-items: center;
                                                        justify-content: center;
                                                        color: var(--accent);
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
                                                        color: var(--text-dark);
                                                        margin-bottom: 6px;
                                                        font-size: 0.95em;
                                                        line-height: 1.4;
                                                    }

                                                    .product-meta {
                                                        display: flex;
                                                        gap: 16px;
                                                        color: var(--text-muted, #888888);
                                                        font-size: 0.85em;
                                                    }

                                                    .product-qty {
                                                        background: var(--panel-color);
                                                        padding: 2px 10px;
                                                        border-radius: 20px;
                                                        font-weight: 500;
                                                        color: var(--accent-dark, #6b75df);
                                                    }

                                                    .product-price {
                                                        font-weight: 600;
                                                        color: var(--accent-dark, #6b75df);
                                                    }

                                                    /* Order Footer */
                                                    .order-footer {
                                                        padding: 16px 20px;
                                                        background: #fafbff;
                                                        border-top: 1px solid rgba(139, 149, 255, 0.1);
                                                        display: flex;
                                                        justify-content: space-between;
                                                        align-items: center;
                                                    }

                                                    .order-total {
                                                        font-size: 1.1em;
                                                    }

                                                    .order-total span {
                                                        color: var(--text-muted, #888888);
                                                        font-size: 0.85em;
                                                    }

                                                    .order-total strong {
                                                        color: var(--accent-dark, #6b75df);
                                                        font-weight: 700;
                                                    }

                                                    /* Status Badges */
                                                    .status-badge {
                                                        padding: 8px 16px;
                                                        border-radius: 25px;
                                                        font-size: 0.75em;
                                                        font-weight: 700;
                                                        text-transform: uppercase;
                                                        letter-spacing: 0.5px;
                                                    }

                                                    .status-pending {
                                                        background: linear-gradient(135deg, #fef3c7, #fde68a);
                                                        color: #92400e;
                                                    }

                                                    .status-paid {
                                                        background: linear-gradient(135deg, #dbeafe, #bfdbfe);
                                                        color: #1e40af;
                                                    }

                                                    .status-processing {
                                                        background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
                                                        color: #3730a3;
                                                    }

                                                    .status-out_for_delivery {
                                                        background: linear-gradient(135deg, #fce7f3, #fbcfe8);
                                                        color: #9d174d;
                                                    }

                                                    .status-delivered {
                                                        background: linear-gradient(135deg, #d1fae5, #a7f3d0);
                                                        color: #065f46;
                                                    }

                                                    .status-cancelled {
                                                        background: linear-gradient(135deg, #fee2e2, #fecaca);
                                                        color: #991b1b;
                                                    }

                                                    /* Empty State */
                                                    .empty-state {
                                                        text-align: center;
                                                        padding: 80px 40px;
                                                        background: #ffffff;
                                                        border-radius: 24px;
                                                        box-shadow: var(--shadow-md);
                                                    }

                                                    .empty-icon {
                                                        width: 120px;
                                                        height: 120px;
                                                        background: var(--gradient-primary, linear-gradient(135deg, #8b95ff 0%, #a8b4ff 100%));
                                                        border-radius: 50%;
                                                        display: flex;
                                                        align-items: center;
                                                        justify-content: center;
                                                        margin: 0 auto 24px;
                                                        font-size: 3em;
                                                        color: #ffffff;
                                                    }

                                                    .empty-state h3 {
                                                        font-size: 1.5em;
                                                        color: var(--text-dark);
                                                        margin-bottom: 12px;
                                                    }

                                                    .empty-state p {
                                                        color: var(--text-secondary);
                                                        margin-bottom: 24px;
                                                        max-width: 400px;
                                                        margin-left: auto;
                                                        margin-right: auto;
                                                    }

                                                    .btn-shop {
                                                        padding: 14px 32px;
                                                        background: var(--gradient-primary, linear-gradient(135deg, #8b95ff 0%, #a8b4ff 100%));
                                                        color: #fff;
                                                        border-radius: 12px;
                                                        text-decoration: none;
                                                        font-weight: 600;
                                                        display: inline-block;
                                                        box-shadow: 0 4px 15px rgba(139, 149, 255, 0.4);
                                                        transition: all 0.3s ease;
                                                    }

                                                    .btn-shop:hover {
                                                        transform: translateY(-2px);
                                                        box-shadow: 0 6px 20px rgba(139, 149, 255, 0.5);
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
                                                                            <span
                                                                                class="order-id">${order.orderId}</span>
                                                                            <span class="order-date">
                                                                                <c:if test="${order.createdAt != null}">
                                                                                    <fmt:formatDate
                                                                                        value="${order.createdAt}"
                                                                                        pattern="MMM dd, yyyy" />
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
                                                                                                    <div
                                                                                                        class="product-placeholder">
                                                                                                        📦</div>
                                                                                                </c:otherwise>
                                                                                            </c:choose>
                                                                                            <div
                                                                                                class="product-details">
                                                                                                <div
                                                                                                    class="product-name">
                                                                                                    ${item.productName}
                                                                                                </div>
                                                                                                <div
                                                                                                    class="product-meta">
                                                                                                    <span
                                                                                                        class="product-qty">x${item.quantity}</span>
                                                                                                    <span
                                                                                                        class="product-price">LKR
                                                                                                        ${item.unitPrice}</span>
                                                                                                </div>
                                                                                            </div>
                                                                                        </div>
                                                                                    </c:forEach>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <div class="product-item">
                                                                                        <div
                                                                                            class="product-placeholder">
                                                                                            📦</div>
                                                                                        <div class="product-details">
                                                                                            <div class="product-name">
                                                                                                ${order.productName}
                                                                                            </div>
                                                                                            <div class="product-meta">
                                                                                                <span
                                                                                                    class="product-price">${order.currency}
                                                                                                    ${order.formattedAmount}</span>
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
                                                                                value="status-${fn:toLowerCase(order.status)}" />
                                                                            <span
                                                                                class="status-badge ${statusClass}">${order.status}</span>
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
                                                                    class="btn-shop">Browse Stores</a>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </main>

                                            </body>

                                            </html>