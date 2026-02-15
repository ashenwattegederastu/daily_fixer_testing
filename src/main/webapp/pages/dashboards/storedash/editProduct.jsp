<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="java.util.List" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"store".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    int id = Integer.parseInt(request.getParameter("productId"));
    Product product = new ProductDAO().getProductById(id);
    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/ListProductsServlet");
        return;
    }
    
    // Load existing variants
    List<ProductVariant> variants = null;
    try {
        ProductVariantDAO variantDAO = new ProductVariantDAO();
        variants = variantDAO.getVariantsByProductId(id);
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

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
                                        .form-card select {
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
                                        .form-card select:focus {
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

                                            // Clear all input values and set variantId to empty (new variant)
                                            newRow.querySelectorAll('input').forEach(input => {
                                                if (input.type === 'hidden' && input.name === 'variantId[]') {
                                                    input.value = '';
                                                } else if (input.type !== 'hidden') {
                                                    input.value = '';
                                                }
                                            });

                                            // Show remove button if there are multiple rows
                                            if (container.querySelectorAll('.variant-row').length > 0) {
                                                newRow.querySelector('.remove-variant-btn').style.display = 'inline-block';
                                            }

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
        <div class="logo">Daily Fixer</div>
        <div class="panel-name">Store Panel</div>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </header>

    <aside class="sidebar">
        <h3>Navigation</h3>
        <ul>
            <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
            <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
            <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
            <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
        </ul>
    </aside>

    <main class="container">
        <div class="form-card">
            <h2>Edit Product</h2>

            <form action="${pageContext.request.contextPath}/EditProductServlet" method="post" enctype="multipart/form-data">
                <input type="hidden" name="productId" value="<%=product.getProductId()%>">

                <label>Product Name</label>
                <input type="text" name="name" value="<%=product.getName()%>" placeholder="Enter product name" required>

                <label>Category</label>
                <select name="type" required>
                    <option value="Cutting Tools" <%=product.getType().equals("Cutting Tools")?"selected":""%>>Cutting Tools</option>
                    <option value="Painting Tools" <%=product.getType().equals("Painting Tools")?"selected":""%>>Painting Tools</option>
                    <option value="Tool Storage & Safety Gear" <%=product.getType().equals("Tool Storage & Safety Gear")?"selected":""%>>Tool Storage & Safety Gear</option>
                    <option value="Electrical Tools & Accessories" <%=product.getType().equals("Electrical Tools & Accessories")?"selected":""%>>Electrical Tools & Accessories</option>
                    <option value="Power Tools" <%=product.getType().equals("Power Tools")?"selected":""%>>Power Tools</option>
                    <option value="Cleaning & Maintenance" <%=product.getType().equals("Cleaning & Maintenance")?"selected":""%>>Cleaning & Maintenance</option>
                    <option value="Vehicle Parts & Accessories" <%=product.getType().equals("Vehicle Parts & Accessories")?"selected":""%>>Vehicle Parts & Accessories</option>
                    <option value="Measuring & Marking Tools" <%=product.getType().equals("Measuring & Marking Tools")?"selected":""%>>Measuring & Marking Tools</option>
                    <option value="Tapes" <%=product.getType().equals("Tapes")?"selected":""%>>Tapes</option>
                    <option value="Fasteners & Fittings" <%=product.getType().equals("Fasteners & Fittings")?"selected":""%>>Fasteners & Fittings</option>
                    <option value="Plumbing Tools & Supplies" <%=product.getType().equals("Plumbing Tools & Supplies")?"selected":""%>>Plumbing Tools & Supplies</option>
                    <option value="Adhesives & Sealants" <%=product.getType().equals("Adhesives & Sealants")?"selected":""%>>Adhesives & Sealants</option>
                </select>

                <label>Quantity <span id="quantityNote" style="font-size: 0.85em; color: #666; font-weight: normal;">(<%= (variants != null && !variants.isEmpty()) ? "Not required - variants have their own quantities" : "Required if no variants" %>)</span></label>
                <input type="number" step="0.01" name="quantity" id="quantityInput" value="<%=product.getQuantity()%>" placeholder="Enter quantity" <%=(variants==null || variants.isEmpty()) ? "required" : "" %>>

                <label>Quantity Unit</label>
                <select name="quantityUnit" required>
                    <option value="No of items" <%=product.getQuantityUnit().equals("No of items")?"selected":""%>>No of items</option>
                    <option value="Litres" <%=product.getQuantityUnit().equals("Litres")?"selected":""%>>Litres</option>
                    <option value="Kg" <%=product.getQuantityUnit().equals("Kg")?"selected":""%>>Kg</option>
                    <option value="Metres" <%=product.getQuantityUnit().equals("Metres")?"selected":""%>>Metres</option>
                </select>

                <label>Price (Rs.) <span id="priceNote" style="font-size: 0.85em; color: #666; font-weight: normal;"></span></label>
                <input type="number" step="0.01" name="price" value="<%=product.getPrice()%>" placeholder="Enter price" required>

                <label>Description</label>
                <textarea name="description" rows="4" placeholder="Enter product description" required><%=product.getDescription()%></textarea>

                <label>Product Image</label>
                <input type="file" name="image" accept="image/*">

                <!-- Product Variants Section -->
                <div style="margin-top: 30px; padding-top: 20px; border-top: 2px solid #e0e0e0;">
                    <h3 style="color: var(--accent); margin-bottom: 15px;">Product Variants</h3>
                    <p style="font-size: 0.85em; color: #666; margin-bottom: 15px;">Manage product variants (color, size, power). Leave empty to remove a variant.</p>

                    <div id="variantsContainer">
                        <% if (variants != null && !variants.isEmpty()) { 
                            for (ProductVariant v : variants) { %>
                            <div class="variant-row" style="background: #f9f9f9; padding: 15px; border-radius: 8px; margin-bottom: 15px; border: 1px solid #e0e0e0;">
                                <input type="hidden" name="variantId[]" value="<%=v.getVariantId()%>">
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px;">
                                    <div>
                                        <label style="font-size: 0.85em;">Color</label>
                                        <input type="text" name="variantColor[]" value="<%=v.getColor() != null ? v.getColor() : ""%>" placeholder="e.g. Red" style="margin-bottom: 0;">
                                    </div>
                                    <div>
                                        <label style="font-size: 0.85em;">Size</label>
                                        <input type="text" name="variantSize[]" value="<%=v.getSize() != null ? v.getSize() : ""%>" placeholder="e.g. M" style="margin-bottom: 0;">
                                    </div>
                                </div>
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px;">
                                    <div>
                                        <label style="font-size: 0.85em;">Power</label>
                                        <input type="text" name="variantPower[]" value="<%=v.getPower() != null ? v.getPower() : ""%>" placeholder="e.g. 500W" style="margin-bottom: 0;">
                                    </div>
                                    <div>
                                        <label style="font-size: 0.85em;">Variant Price (Rs.)</label>
                                        <input type="number" step="0.01" name="variantPrice[]" value="<%=v.getPrice()%>" placeholder="Price" style="margin-bottom: 0;">
                                    </div>
                                </div>
                                <div>
                                    <label style="font-size: 0.85em;">Variant Stock</label>
                                    <input type="number" name="variantQuantity[]" value="<%=v.getQuantity()%>" placeholder="Stock quantity" style="margin-bottom: 0;">
                                </div>
                                <button type="button" class="remove-variant-btn" onclick="removeVariantRow(this)" style="margin-top: 10px; padding: 6px 12px; background: #dc3545; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 0.85em;">Remove</button>
                            </div>
                        <% } } else { %>
                            <!-- Empty variant row if no variants exist -->
                            <div class="variant-row" style="background: #f9f9f9; padding: 15px; border-radius: 8px; margin-bottom: 15px; border: 1px solid #e0e0e0;">
                                <input type="hidden" name="variantId[]" value="">
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px;">
                                    <div>
                                        <label style="font-size: 0.85em;">Color</label>
                                        <input type="text" name="variantColor[]" placeholder="e.g. Red" style="margin-bottom: 0;">
                                    </div>
                                    <div>
                                        <label style="font-size: 0.85em;">Size</label>
                                        <input type="text" name="variantSize[]" placeholder="e.g. M" style="margin-bottom: 0;">
                                    </div>
                                </div>
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px;">
                                    <div>
                                        <label style="font-size: 0.85em;">Power</label>
                                        <input type="text" name="variantPower[]" placeholder="e.g. 500W" style="margin-bottom: 0;">
                                    </div>
                                    <div>
                                        <label style="font-size: 0.85em;">Variant Price (Rs.)</label>
                                        <input type="number" step="0.01" name="variantPrice[]" placeholder="Price" style="margin-bottom: 0;">
                                    </div>
                                </div>
                                <div>
                                    <label style="font-size: 0.85em;">Variant Stock</label>
                                    <input type="number" name="variantQuantity[]" placeholder="Stock quantity" style="margin-bottom: 0;">
                                </div>
                                <button type="button" class="remove-variant-btn" onclick="removeVariantRow(this)" style="margin-top: 10px; padding: 6px 12px; background: #dc3545; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 0.85em; display: none;">Remove</button>
                            </div>
                        <% } %>
                                                    </div>

                    <button type="button" onclick="addVariantRow()" style="background: #28a745; color: white; padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; margin-top: 10px;">+ Add Variant</button>
                </div>

                <button type="submit">Update Product</button>
            </form>

            <a href="${pageContext.request.contextPath}/ListProductsServlet" class="back-btn">Back to Products</a>
        </div>
    </main>

</body>
</html>