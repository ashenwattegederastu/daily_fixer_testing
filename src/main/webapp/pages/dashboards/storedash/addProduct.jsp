<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="com.dailyfixer.model.User" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />
        <% User user=(User) session.getAttribute("currentUser"); if (user==null || !"store".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp" ); return; } %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Add Product | Daily Fixer</title>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                    rel="stylesheet">

                <style>
                    :root {
                        --panel-color: #dcdaff;
                        --accent: #8b95ff;
                        --text-dark: #000000;
                        --text-secondary: #333333;
                        --shadow-sm: 0 4px 12px rgba(0, 0, 0, 0.12);
                        --shadow-md: 0 8px 24px rgba(0, 0, 0, 0.18);
                        --shadow-lg: 0 12px 36px rgba(0, 0, 0, 0.22);
                    }

                    /* Reset */
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }

                    body {
                        font-family: 'Inter', sans-serif;
                        background-color: #ffffff;
                        color: var(--text-dark);
                        display: flex;
                        min-height: 100vh;
                    }

                    /* Top Navbar */
                    .topbar {
                        position: fixed;
                        top: 0;
                        left: 0;
                        right: 0;
                        height: 76px;
                        background-color: var(--panel-color);
                        border-bottom: 1px solid rgba(0, 0, 0, 0.1);
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        padding: 0 30px;
                        z-index: 200;
                        box-shadow: var(--shadow-md);
                    }

                    .topbar .logo {
                        font-size: 1.5em;
                        font-weight: 700;
                        color: var(--accent);
                    }

                    .topbar .panel-name {
                        font-weight: 600;
                        flex: 1;
                        text-align: center;
                        color: var(--text-dark);
                    }

                    .topbar .logout-btn {
                        padding: 0.6rem 1.2rem;
                        background: linear-gradient(135deg, var(--accent), #7ba3d4);
                        border: none;
                        color: #fff;
                        border-radius: 8px;
                        cursor: pointer;
                        font-weight: 600;
                        font-size: 0.9rem;
                        box-shadow: var(--shadow-sm);
                        text-decoration: none;
                    }

                    .topbar .logout-btn:hover {
                        transform: translateY(-2px);
                        box-shadow: var(--shadow-md);
                        opacity: 0.9;
                    }

                    /* Sidebar */
                    .sidebar {
                        width: 240px;
                        background-color: var(--panel-color);
                        height: 100vh;
                        position: fixed;
                        top: 0;
                        left: 0;
                        padding-top: 96px;
                        box-shadow: var(--shadow-md);
                        overflow-y: auto;
                        z-index: 100;
                    }

                    .sidebar h3 {
                        padding: 0 20px 12px;
                        font-size: 0.85em;
                        color: var(--text-dark);
                        text-transform: uppercase;
                    }

                    .sidebar ul {
                        list-style: none;
                    }

                    .sidebar a {
                        display: block;
                        padding: 12px 20px;
                        text-decoration: none;
                        color: var(--text-dark);
                        font-weight: 500;
                        border-left: 3px solid transparent;
                        border-radius: 0 8px 8px 0;
                        margin-bottom: 4px;
                        transition: all 0.2s;
                    }

                    .sidebar a:hover,
                    .sidebar a.active {
                        background-color: #f0f0ff;
                        border-left-color: var(--accent);
                    }

                    /* Main Content */
                    .container {
                        flex: 1;
                        margin-left: 240px;
                        margin-top: 83px;
                        padding: 30px;
                        display: flex;
                        justify-content: center;
                        align-items: flex-start;
                    }

                    .form-card {
                        background: white;
                        border-radius: 12px;
                        padding: 30px;
                        max-width: 600px;
                        width: 100%;
                        box-shadow: var(--shadow-sm);
                        border: 1px solid rgba(0, 0, 0, 0.1);
                    }

                    .form-card h2 {
                        color: var(--accent);
                        text-align: center;
                        margin-bottom: 25px;
                        font-size: 1.5em;
                    }

                    .form-card label {
                        display: block;
                        font-weight: 600;
                        color: var(--text-dark);
                        margin-top: 15px;
                        margin-bottom: 5px;
                    }

                    .form-card input,
                    .form-card select,
                    .form-card textarea {
                        width: 100%;
                        padding: 12px;
                        border: 2px solid #e0e0e0;
                        border-radius: 8px;
                        background: #fafafa;
                        margin-bottom: 5px;
                        font-size: 0.9em;
                        transition: all 0.2s;
                    }

                    .form-card input:focus,
                    .form-card select:focus,
                    .form-card textarea:focus {
                        outline: none;
                        border-color: var(--accent);
                        background: white;
                        box-shadow: 0 0 0 3px rgba(139, 149, 255, 0.1);
                    }

                    .form-card button {
                        background: var(--accent);
                        color: white;
                        width: 100%;
                        padding: 12px;
                        border: none;
                        border-radius: 8px;
                        cursor: pointer;
                        margin-top: 20px;
                        font-weight: 600;
                        font-size: 1em;
                        box-shadow: var(--shadow-sm);
                        transition: all 0.2s;
                    }

                    .form-card button:hover {
                        transform: translateY(-2px);
                        box-shadow: var(--shadow-md);
                        opacity: 0.9;
                    }

                    .back-btn {
                        background: #6c757d;
                        color: white;
                        padding: 10px 20px;
                        border: none;
                        border-radius: 8px;
                        cursor: pointer;
                        text-decoration: none;
                        display: inline-block;
                        margin-top: 15px;
                        text-align: center;
                        font-weight: 500;
                        box-shadow: var(--shadow-sm);
                        transition: all 0.2s;
                    }

                    .back-btn:hover {
                        transform: translateY(-2px);
                        box-shadow: var(--shadow-md);
                        opacity: 0.9;
                    }

                    .variant-row {
                        position: relative;
                    }

                    .remove-variant-btn {
                        display: none;
                    }

                    .variant-row:not(:only-child) .remove-variant-btn {
                        display: inline-block;
                    }
                </style>

                <script>
                    function addVariantRow() {
                        const container = document.getElementById('variantsContainer');
                        const firstRow = container.querySelector('.variant-row');
                        const newRow = firstRow.cloneNode(true);

                        // Clear all input values
                        newRow.querySelectorAll('input').forEach(input => {
                            input.value = '';
                        });

                        container.appendChild(newRow);
                    }

                    function removeVariantRow(btn) {
                        const row = btn.closest('.variant-row');
                        if (document.querySelectorAll('.variant-row').length > 1) {
                            row.remove();
                        } else {
                            alert('At least one variant row is required. Clear the fields if you don\'t want variants.');
                        }
                        checkVariantFields();
                    }

                    // Function to check if any variant fields are filled
                    function checkVariantFields() {
                        const variantRows = document.querySelectorAll('.variant-row');
                        let hasVariants = false;

                        variantRows.forEach(row => {
                            const color = row.querySelector('input[name="variantColor[]"]')?.value.trim();
                            const size = row.querySelector('input[name="variantSize[]"]')?.value.trim();
                            const power = row.querySelector('input[name="variantPower[]"]')?.value.trim();
                            const price = row.querySelector('input[name="variantPrice[]"]')?.value.trim();
                            const qty = row.querySelector('input[name="variantQuantity[]"]')?.value.trim();

                            if (color || size || power || price || qty) {
                                hasVariants = true;
                            }
                        });

                        const quantityInput = document.getElementById('quantityInput');
                        const quantityNote = document.getElementById('quantityNote');
                        const priceInput = document.getElementsByName('price')[0];
                        const priceNote = document.getElementById('priceNote');

                        if (hasVariants) {
                            // If variants exist, quantity is not required
                            quantityInput.removeAttribute('required');
                            quantityInput.value = '0';
                            if (quantityNote) {
                                quantityNote.textContent = '(Not required - variants have their own quantities)';
                                quantityNote.style.color = '#28a745';
                            }
                            // If variants exist, main price is not required
                            if (priceInput) priceInput.removeAttribute('required');
                            if (priceNote) {
                                priceNote.textContent = '(Optional if variants have prices)';
                                priceNote.style.color = '#28a745';
                            }
                        } else {
                            // If no variants, quantity is required
                            quantityInput.setAttribute('required', 'required');
                            if (quantityNote) {
                                quantityNote.textContent = '(Required if no variants)';
                                quantityNote.style.color = '#666';
                            }
                            // If no variants, main price is required
                            if (priceInput) priceInput.setAttribute('required', 'required');
                            if (priceNote) {
                                priceNote.textContent = '';
                            }
                        }
                    }

                    // Check variant fields on input change
                    document.addEventListener('DOMContentLoaded', function () {
                        checkVariantFields();

                        // Monitor variant input changes
                        const variantContainer = document.getElementById('variantsContainer');
                        if (variantContainer) {
                            variantContainer.addEventListener('input', function (e) {
                                if (e.target.name && e.target.name.includes('variant')) {
                                    checkVariantFields();
                                }
                            });
                        }
                    });
                </script>
            </head>

            <body>

                <header class="topbar">
                    <div class="logo"><fmt:message key="app.name"/></div>
                    <div class="panel-name"><fmt:message key="store.panel"/></div>
                    <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><fmt:message key="common.logout"/></a>
                </header>

                <aside class="sidebar">
                    <h3><fmt:message key="sidebar.navigation"/></h3>
                    <ul>
                        <li><a
                                href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp"><fmt:message key="store.dashboard"/></a>
                        </li>
                        <li><a
                                href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp"><fmt:message key="store.orders"/></a>
                        </li>
                        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up
                                for Delivery</a></li>
                        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed
                                Orders</a></li>
                        <li><a href="${pageContext.request.contextPath}/ListProductsServlet"><fmt:message key="store.catalogue"/></a></li>
                        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet"><fmt:message key="store.discounts"/></a></li>
                        <li><a
                                href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp"><fmt:message key="store.profile"/></a>
                        </li>
                    </ul>
<div class="sidebar-actions" style="padding: 15px;">
    <a href="?lang=${sessionScope.sessionLocale.language == 'si' ? 'en' : 'si'}"
       class="action-btn lang-toggle" style="display:block; text-align:center; padding:8px; background:var(--primary); color:var(--primary-foreground); border-radius:var(--radius-md); text-decoration:none; font-weight:600;">
       <fmt:message key="nav.lang_switch"/>
    </a>
</div>
                </aside>

                <main class="container">
                    <div class="form-card">
                        <h2><fmt:message key="store.products.add_title"/></h2>

                        <form action="${pageContext.request.contextPath}/AddProductServlet" method="post"
                            enctype="multipart/form-data">

                            <label for="name">Product Name</label>
                            <input type="text" name="name" placeholder="Enter product name" required>

                            <label for="type">Category</label>
                            <select name="type" required>
                                <option value="">-- Select Category --</option>
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

                            <label for="quantity">Quantity <span id="quantityNote"
                                    style="font-size: 0.85em; color: #666; font-weight: normal;">(Required if no
                                    variants)</span></label>
                            <input type="number" step="0.01" name="quantity" id="quantityInput"
                                placeholder="Enter quantity" value="0">

                            <label for="quantityUnit">Unit</label>
                            <select name="quantityUnit" required>
                                <option value="No of items">No of items</option>
                                <option value="Litres">Litres</option>
                                <option value="Kg">Kg</option>
                                <option value="Metres">Metres</option>
                            </select>

                            <label for="price">Price (Rs.) <span id="priceNote"
                                    style="font-size: 0.85em; color: #666; font-weight: normal;"></span></label>
                            <input type="number" step="0.01" name="price" placeholder="Enter price" required>

                            <label for="description">Description</label>
                            <textarea name="description" id="description" rows="4"
                                placeholder="Enter product description" required></textarea>


                            <label for="image">Product Image</label>
                            <input type="file" name="image" accept="image/*" required>

                            <!-- Product Variants Section -->
                            <div style="margin-top: 30px; padding-top: 20px; border-top: 2px solid #e0e0e0;">
                                <h3 style="color: var(--accent); margin-bottom: 15px;">Product Variants (Optional)</h3>
                                <p style="font-size: 0.85em; color: #666; margin-bottom: 15px;">
                                    If your product has different options (color, size, power), add variants below.
                                    Leave empty if product has no variants.
                                </p>

                                <div id="variantsContainer">
                                    <!-- First variant row -->
                                    <div class="variant-row"
                                        style="background: #f9f9f9; padding: 15px; border-radius: 8px; margin-bottom: 15px; border: 1px solid #e0e0e0;">
                                        <div
                                            style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px;">
                                            <div>
                                                <label style="font-size: 0.85em;">Color</label>
                                                <input type="text" name="variantColor[]" placeholder="e.g. Red"
                                                    style="margin-bottom: 0;">
                                            </div>
                                            <div>
                                                <label style="font-size: 0.85em;">Size</label>
                                                <input type="text" name="variantSize[]" placeholder="e.g. M"
                                                    style="margin-bottom: 0;">
                                            </div>
                                        </div>
                                        <div
                                            style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px;">
                                            <div>
                                                <label style="font-size: 0.85em;">Power</label>
                                                <input type="text" name="variantPower[]" placeholder="e.g. 500W"
                                                    style="margin-bottom: 0;">
                                            </div>
                                            <div>
                                                <label style="font-size: 0.85em;">Variant Price (Rs.)</label>
                                                <input type="number" step="0.01" name="variantPrice[]"
                                                    placeholder="Price" style="margin-bottom: 0;">
                                            </div>
                                        </div>
                                        <div>
                                            <label style="font-size: 0.85em;">Variant Stock</label>
                                            <input type="number" name="variantQuantity[]" placeholder="Stock quantity"
                                                style="margin-bottom: 0;">
                                        </div>
                                        <button type="button" class="remove-variant-btn"
                                            onclick="removeVariantRow(this)"
                                            style="margin-top: 10px; padding: 6px 12px; background: #dc3545; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 0.85em;">Remove</button>
                                    </div>
                                </div>

                                <button type="button" onclick="addVariantRow()"
                                    style="background: #28a745; color: white; padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; margin-top: 10px;">
                                    + Add Variant
                                </button>
                            </div>

                            <button type="submit">Add Product</button>
                        </form>

                        <a href="${pageContext.request.contextPath}/ListProductsServlet" class="back-btn">Back to
                            Products</a>
                    </div>
                </main>

            </body>

            </html>