<%@ page import="java.util.Map" %>
    <%@ page import="com.dailyfixer.model.CartItem" %>
    <%@ page import="com.dailyfixer.model.User" %>
        <%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />
        
        <%
            // Check if user is logged in
            User currentUser = (User) session.getAttribute("currentUser");
            boolean isLoggedIn = (currentUser != null);
        %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <title>Daily Fixer - Cart</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cart.css">
                <style>
                    body {
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                        background-color: #f5f6fa;
                        color: #2d2d3d;
                        margin: 0;
                        padding: 0;
                    }

                    .cart-container {
                        max-width: 950px;
                        margin: 120px auto 50px auto;
                        background: #fff;
                        padding: 40px;
                        border-radius: 15px;
                        box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
                    }

                    h2 {
                        text-align: center;
                        margin-bottom: 30px;
                        color: #7b2cff;
                    }

                    .cart-items {
                        display: flex;
                        flex-direction: column;
                        gap: 20px;
                    }

                    .cart-item {
                        display: flex;
                        gap: 20px;
                        align-items: center;
                        padding: 15px;
                        border-radius: 12px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
                        transition: transform 0.2s, box-shadow 0.2s;
                    }

                    .cart-item:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                    }

                    .cart-item img {
                        width: 90px;
                        height: 90px;
                        object-fit: cover;
                        border-radius: 10px;
                        border: 2px solid #e0d6ff;
                    }

                    .item-details {
                        flex: 1;
                    }

                    .item-name {
                        font-weight: 700;
                        font-size: 1.1rem;
                        margin-bottom: 6px;
                        color: #360062;
                    }

                    .item-qty,
                    .item-price {
                        color: #555;
                        font-size: 0.95rem;
                        margin-bottom: 4px;
                    }

                    .quantity-controls {
                        display: inline-flex;
                        align-items: center;
                        gap: 8px;
                        margin-top: 6px;
                    }

                    .qty-btn {
                        width: 28px;
                        height: 28px;
                        border-radius: 50%;
                        border: 1px solid #d0c4ff;
                        background: #f4f1ff;
                        color: #360062;
                        font-weight: 700;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        transition: background 0.2s, transform 0.1s, box-shadow 0.2s;
                    }

                    .qty-btn:hover {
                        background: #e5ddff;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                        transform: translateY(-1px);
                    }

                    .qty-value {
                        min-width: 24px;
                        text-align: center;
                        font-weight: 600;
                        color: #360062;
                    }

                    .remove-item {
                        cursor: pointer;
                        background: #ff4d4f;
                        color: white;
                        border: none;
                        padding: 6px 12px;
                        border-radius: 8px;
                        font-weight: 600;
                        transition: background 0.3s, transform 0.2s;
                    }

                    .remove-item:hover {
                        background: #d9363e;
                        transform: translateY(-2px);
                    }

                    /* Summary Section - Improved Styling */
                    .cart-summary {
                        margin-top: 40px;
                        padding: 25px;
                        background: linear-gradient(135deg, #f8f9ff, #ffffff);
                        border-radius: 15px;
                        box-shadow: 0 4px 20px rgba(123, 44, 255, 0.1);
                        border: 2px solid #e8e8ff;
                    }

                    .summary-row {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        padding: 12px 0;
                        border-bottom: 1px solid #e0e0e0;
                        font-size: 1rem;
                    }

                    .summary-row:last-child {
                        border-bottom: none;
                    }

                    .summary-row.subtotal-row {
                        color: #555;
                        font-weight: 500;
                    }

                    .summary-row.discount-row {
                        color: #4caf50;
                        font-weight: 600;
                    }

                    .summary-row.total-row {
                        margin-top: 15px;
                        padding-top: 20px;
                        border-top: 2px solid #7b2cff;
                        font-size: 1.5em;
                        font-weight: 700;
                        color: #7b2cff;
                    }

                    .summary-label {
                        font-weight: 600;
                    }

                    .summary-value {
                        font-weight: 700;
                        letter-spacing: 0.5px;
                    }

                    .discount-value {
                        color: #4caf50;
                        font-weight: 700;
                    }

                    .total-value {
                        color: #7b2cff;
                        font-size: 1.2em;
                    }

                    .empty-cart-msg {
                        text-align: center;
                        font-size: 1.2rem;
                        color: #888;
                        margin-top: 30px;
                    }

                    /* Checkout Button */
                    .checkout-btn {
                        display: block;
                        margin: 30px auto 0 auto;
                        padding: 14px 40px;
                        background: linear-gradient(135deg, #7b2cff, #8b95ff);
                        color: white;
                        font-weight: 700;
                        font-size: 1.1rem;
                        border: none;
                        border-radius: 12px;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        box-shadow: 0 4px 15px rgba(123, 44, 255, 0.3);
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
                        min-width: 200px;
                    }

                    .checkout-btn:hover {
                        transform: translateY(-3px);
                        box-shadow: 0 8px 25px rgba(123, 44, 255, 0.4);
                        background: linear-gradient(135deg, #8b3dff, #9ba5ff);
                    }

                    .checkout-btn:active {
                        transform: translateY(-1px);
                        box-shadow: 0 4px 15px rgba(123, 44, 255, 0.3);
                    }

                    /* Responsive */
                    @media (max-width: 700px) {
                        .cart-item {
                            flex-direction: column;
                            align-items: flex-start;
                        }

                        .cart-item img {
                            width: 100%;
                            height: auto;
                        }

                        .cart-summary {
                            margin-top: 20px;
                            padding: 20px;
                        }

                        .summary-row {
                            font-size: 0.95rem;
                        }

                        .summary-row.total-row {
                            font-size: 1.3em;
                        }
                    }
                </style>
            </head>

            <body>

                <jsp:include page="fragment_cart.jsp" />

                <div class="cart-container">
                    <h2><fmt:message key="cart.title"/></h2>

                    <% Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
                            if (cart == null || cart.isEmpty()) {
                            %>
                            <p class="empty-cart-msg"><fmt:message key="cart.empty"/></p>
                            <p class="subtotal">Subtotal: Rs 0</p>
                            <% } else { %>
                                <div class="cart-items">
                                    <% for (CartItem ci : cart.values()) { %>
                                        <div class="cart-item" data-id="<%=ci.getProductId()%>"
                                            data-cart-key="<%=ci.getVariantId() != null ? ci.getVariantId() : ci.getProductId()%>">
                                            <img src="data:image/jpeg;base64,<%=ci.getImageBase64()%>"
                                                alt="<%=ci.getName()%>">
                                            <div class="item-details">
                                                <p class="item-name">
                                                    <%=ci.getName()%>
                                                </p>
                                                <% if (ci.getVariantId() !=null) { %>
                                                    <p style="font-size: 0.85rem; color: #666; margin-bottom: 4px;">
                                                        <% if (ci.getVariantColor() !=null &&
                                                            !ci.getVariantColor().isEmpty()) { %>
                                                            Color: <%=ci.getVariantColor()%>
                                                                <% } %>
                                                                    <% if (ci.getVariantSize() !=null &&
                                                                        !ci.getVariantSize().isEmpty()) { %>
                                                                        <% if (ci.getVariantColor() !=null &&
                                                                            !ci.getVariantColor().isEmpty()) { %> | <% }
                                                                                %>
                                                                                Size: <%=ci.getVariantSize()%>
                                                                                    <% } %>
                                                                                        <% if (ci.getVariantPower()
                                                                                            !=null &&
                                                                                            !ci.getVariantPower().isEmpty())
                                                                                            { %>
                                                                                            <% if ((ci.getVariantColor()
                                                                                                !=null &&
                                                                                                !ci.getVariantColor().isEmpty())
                                                                                                || (ci.getVariantSize()
                                                                                                !=null &&
                                                                                                !ci.getVariantSize().isEmpty()))
                                                                                                { %> | <% } %>
                                                                                                    Power:
                                                                                                    <%=ci.getVariantPower()%>
                                                                                                        <% } %>
                                                    </p>
                                                    <% } %>
                                                        <p class="item-qty">
                                                            Quantity:
                                                            <span class="quantity-controls"
                                                                data-product-id="<%=ci.getProductId()%>"
                                                                data-variant-id="<%=ci.getVariantId() != null ? ci.getVariantId() : ""%>"
                                                                data-cart-key="<%=ci.getVariantId() != null ? ci.getVariantId() : ci.getProductId()%>">
                                                                <button type="button"
                                                                    class="qty-btn qty-decrease">-</button>
                                                                <span class="qty-value">
                                                                    <%=ci.getQuantity()%>
                                                                </span>
                                                                <button type="button"
                                                                    class="qty-btn qty-increase">+</button>
                                                            </span>
                                                        </p>
                                                        <p class="item-price">
                                                            <% if (ci.getDiscountAmount() > 0.01 && 
                                                                ci.getOriginalPrice() > ci.getPrice()) { %>
                                                                <span
                                                                    style="text-decoration: line-through; color: #999; margin-right: 10px;">
                                                                    Rs <%= String.format("%.2f", ci.getOriginalPrice())
                                                                        %>
                                                                </span>
                                                                <span style="color: #4caf50; font-weight: 600;">
                                                                    Rs <%= String.format("%.2f", ci.getPrice()) %>
                                                                </span>
                                                                <% if (ci.getDiscountName() !=null && !ci.getDiscountName().trim().isEmpty()) { %>
                                                                    <span
                                                                        style="background: #ff4d4f; color: white; padding: 2px 8px; border-radius: 8px; font-size: 0.8em; margin-left: 8px;">
                                                                        <%= ci.getDiscountName() %>
                                                                    </span>
                                                                    <% } %>
                                                                        <% } else { %>
                                                                            Price: Rs <%= String.format("%.2f",
                                                                                ci.getPrice()) %>
                                                                                <% } %>
                                                        </p>
                                            </div>
                                            <button class="remove-item" data-product-id="<%=ci.getProductId()%>"
                                                data-variant-id="<%=ci.getVariantId() != null ? ci.getVariantId() : ""%>"
                                                data-cart-key="<%=ci.getVariantId() != null ? ci.getVariantId() : ci.getProductId()%>"><fmt:message key="cart.remove"/></button>
                                        </div>
                                        <% } %>
                                </div>

                                <% double subtotal=0; double totalDiscount=0; for (CartItem ci : cart.values()) {
                                    subtotal +=ci.getQuantity() * ci.getOriginalPrice(); if (ci.getDiscountAmount()> 0)
                                    {
                                    totalDiscount += ci.getTotalDiscount();
                                    }
                                    }
                                    double finalTotal = subtotal - totalDiscount;
                                    %>
                                    <div class="cart-summary">
                                        <div class="summary-row subtotal-row">
                                            <span class="summary-label"><fmt:message key="cart.subtotal"/></span>
                                            <span class="summary-value" id="subtotal">Rs <%= String.format("%.2f",
                                                    subtotal) %></span>
                                        </div>
                                        <% if (totalDiscount> 0) { %>
                                            <div class="summary-row discount-row">
                                                <span class="summary-label">Discount</span>
                                                <span class="summary-value discount-value" id="totalDiscount">-Rs <%=
                                                        String.format("%.2f", totalDiscount) %></span>
                                            </div>
                                            <% } %>
                                                <div class="summary-row total-row">
                                                    <span class="summary-label">Total</span>
                                                    <span class="summary-value total-value" id="finalTotal">Rs <%=
                                                            String.format("%.2f", finalTotal) %></span>
                                                </div>
                                    </div>

                                    <form id="checkoutForm">
                                        <button type="button" id="checkoutBtn" class="checkout-btn">Proceed to
                                            Checkout</button>
                                    </form>

                                    <% } %>
                </div>

                <script>
                    function updateSubtotal() {
                        const items = document.querySelectorAll(".cart-item");
                        let subtotal = 0;
                        let totalDiscount = 0;

                        items.forEach(item => {
                            const qtyText = item.querySelector(".qty-value").innerText;
                            const qty = parseInt(qtyText);
                            const priceElement = item.querySelector(".item-price");

                            // Get original price and discounted price
                            let originalPrice = 0;
                            let discountedPrice = 0;
                            const priceText = priceElement.innerText;

                            // Check if there's a discount (line-through price exists)
                            const originalPriceMatch = priceText.match(/Rs\s+([\d.]+)/);
                            if (originalPriceMatch) {
                                originalPrice = parseFloat(originalPriceMatch[1]);
                            }

                            // Get the discounted price (usually the second price)
                            const prices = priceText.match(/Rs\s+([\d.]+)/g);
                            if (prices && prices.length > 1) {
                                discountedPrice = parseFloat(prices[1].replace("Rs ", ""));
                                totalDiscount += (originalPrice - discountedPrice) * qty;
                                subtotal += originalPrice * qty;
                            } else if (originalPriceMatch) {
                                // No discount, single price
                                discountedPrice = originalPrice;
                                subtotal += originalPrice * qty;
                            } else {
                                // Fallback: try to parse single price
                                const singlePrice = parseFloat(priceText.replace(/[^\d.]/g, ''));
                                if (!isNaN(singlePrice)) {
                                    originalPrice = singlePrice;
                                    discountedPrice = singlePrice;
                                    subtotal += originalPrice * qty;
                                }
                            }
                        });

                        const subtotalElement = document.getElementById("subtotal");
                        const discountElement = document.getElementById("totalDiscount");
                        const discountRow = discountElement ? discountElement.closest(".summary-row") : null;
                        const finalTotalElement = document.getElementById("finalTotal");
                        const finalTotal = subtotal - totalDiscount;

                        if (subtotalElement) {
                            subtotalElement.innerText = "Rs " + subtotal.toFixed(2);
                        }

                        if (discountElement && discountRow) {
                            if (totalDiscount > 0) {
                                discountElement.innerText = "-Rs " + totalDiscount.toFixed(2);
                                discountRow.style.display = "flex";
                            } else {
                                discountRow.style.display = "none";
                            }
                        }

                        if (finalTotalElement) {
                            finalTotalElement.innerText = "Rs " + finalTotal.toFixed(2);
                        }
                    }

                    function sendQuantityUpdate(productId, variantId, cartKey, newQty, onSuccess) {
                        let body = "productId=" + encodeURIComponent(productId) + "&quantity=" + encodeURIComponent(newQty);
                        if (variantId && variantId !== "") {
                            body += "&variantId=" + encodeURIComponent(variantId);
                        }
                        body += "&cartKey=" + encodeURIComponent(cartKey);

                        fetch('<%=request.getContextPath()%>/updateCartQuantity', {
                            method: "POST",
                            headers: { "Content-Type": "application/x-www-form-urlencoded" },
                            body: body
                        })
                            .then(res => res.json())
                            .then(data => {
                                if (data.error) {
                                    alert(data.error);
                                    return;
                                }
                                if (typeof onSuccess === "function") {
                                    onSuccess(data);
                                }
                            })
                            .catch(() => alert("Server error"));
                    }

                    document.querySelectorAll(".cart-item").forEach(item => {
                        const quantityControls = item.querySelector(".quantity-controls");
                        if (!quantityControls) return;

                        const productId = quantityControls.getAttribute("data-product-id");
                        const variantId = quantityControls.getAttribute("data-variant-id") || "";
                        const cartKey = quantityControls.getAttribute("data-cart-key");
                        const decBtn = item.querySelector(".qty-decrease");
                        const incBtn = item.querySelector(".qty-increase");
                        const qtyValueEl = item.querySelector(".qty-value");

                        if (!decBtn || !incBtn || !qtyValueEl) return;

                        decBtn.addEventListener("click", () => {
                            let currentQty = parseInt(qtyValueEl.innerText);
                            if (currentQty <= 1) return; // keep at least 1
                            const newQty = currentQty - 1;
                            sendQuantityUpdate(productId, variantId, cartKey, newQty, (data) => {
                                qtyValueEl.innerText = newQty;
                                const cartCountEl = document.querySelector(".cart-count");
                                if (cartCountEl && typeof data.cartCount === "number") {
                                    cartCountEl.innerText = data.cartCount;
                                }
                                updateSubtotal();
                            });
                        });

                        incBtn.addEventListener("click", () => {
                            let currentQty = parseInt(qtyValueEl.innerText);
                            const newQty = currentQty + 1;
                            sendQuantityUpdate(productId, variantId, cartKey, newQty, (data) => {
                                const finalQty = typeof data.quantity === "number" ? data.quantity : newQty;
                                qtyValueEl.innerText = finalQty;
                                const cartCountEl = document.querySelector(".cart-count");
                                if (cartCountEl && typeof data.cartCount === "number") {
                                    cartCountEl.innerText = data.cartCount;
                                }
                                updateSubtotal();
                            });
                        });
                    });

                    document.querySelectorAll(".remove-item").forEach(btn => {
                        btn.addEventListener("click", () => {
                            const productId = btn.dataset.productId;
                            const variantId = btn.dataset.variantId || "";
                            const cartKey = btn.dataset.cartKey;

                            let body = "productId=" + encodeURIComponent(productId);
                            if (variantId && variantId !== "") {
                                body += "&variantId=" + encodeURIComponent(variantId);
                            }
                            body += "&cartKey=" + encodeURIComponent(cartKey);

                            fetch('<%=request.getContextPath()%>/removeFromCart', {
                                method: "POST",
                                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                                body: body
                            })
                                .then(async res => {
                                    if (!res.ok) {
                                        throw new Error("HTTP " + res.status);
                                    }
                                    const text = await res.text();
                                    try {
                                        return JSON.parse(text);
                                    } catch (e) {
                                        throw new Error("Invalid JSON: " + text.substring(0, 50));
                                    }
                                })
                                .then(data => {
                                    if (data.error) {
                                        alert(data.error);
                                        return;
                                    }
                                    // Remove item from DOM
                                    const itemDiv = btn.closest(".cart-item");
                                    itemDiv.remove();

                                    // Update floating cart count
                                    const cartCountEl = document.querySelector(".cart-count");
                                    if (cartCountEl) cartCountEl.innerText = data.cartCount;

                                    // Update subtotal
                                    updateSubtotal();

                                    // Show "cart empty" if no items
                                    if (document.querySelectorAll(".cart-item").length === 0) {
                                        document.querySelector(".cart-items")?.remove();
                                        document.querySelector(".cart-summary")?.remove();
                                        document.getElementById("checkoutForm")?.remove();

                                        const cartContainer = document.querySelector(".cart-container");

                                        const emptyMsg = document.createElement("p");
                                        emptyMsg.className = "empty-cart-msg";
                                        emptyMsg.innerText = "Your cart is empty.";
                                        cartContainer.appendChild(emptyMsg);

                                        const subtotalP = document.createElement("p");
                                        subtotalP.className = "subtotal";
                                        subtotalP.innerText = "Subtotal: Rs 0";
                                        cartContainer.appendChild(subtotalP);
                                    }
                                })
                                .catch(err => alert("Server error details: " + err.message));
                        });
                    });
                    document.getElementById("checkoutBtn").addEventListener("click", () => {
                        <% if (!isLoggedIn) { %>
                            alert("Please login before purchasing products");
                            // Pass current page path and query to redirect back after login
                            const currentPath = window.location.pathname + window.location.search;
                            window.location.href = "<%=request.getContextPath()%>/login.jsp?redirect=" + encodeURIComponent(currentPath);
                            return;
                        <% } %>
                        // Just redirect to checkout.jsp
                        window.location.href = "checkout.jsp";
                    });

                </script>

            </body>

            </html>