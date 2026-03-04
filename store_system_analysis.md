# 🔍 Daily Fixer Store System — Issue Analysis

This document is a thorough review of the current store system in the Daily Fixer project. It covers **database schema design**, **product & variant handling**, **cart & checkout flow**, **multi-store orders**, **discount system**, **delivery driver integration**, and **user experience gaps**.

Each issue includes a brief explanation and a suggested easy fix.

---

## 1. Database Schema Issues

### 1.1 `products` table has no Foreign Key to `stores`

**Problem:** The `products` table uses `store_username` (a plain `VARCHAR(50)`) to associate products with a store, but there is no `FOREIGN KEY` constraint to the `users` or `stores` table.

**Why it matters:**
- If a store owner changes their username, all their products silently break — queries return nothing.
- No referential integrity means you can insert products with a non-existent `store_username`.

**Suggested fix:** Add a `store_id INT` column to `products` with a FK to `stores(store_id)`. You already have `store_id` as a field in [Product.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/Product.java), so this is partially prepared.

---

### 1.2 `orders` table uses `store_username` (VARCHAR) instead of `store_id`

**Problem:** The `orders` table identifies the store via `store_username VARCHAR(100)` — a string. Meanwhile, `order_items` correctly uses `store_id INT` with a FK.

**Why it matters:**
- **Inconsistency**: Half the system looks up stores by username, the other half by ID.
- The `OrderDAO.createOrder()` method has 3 fallback INSERT statements because it doesn't know which columns exist — this is a sign the schema evolved without a clean migration.
- The `orders.store_username` column has no FK constraint, so a deleted store's orders become orphaned.

**Suggested fix:** Use `store_id INT` consistently in `orders` and make it a FK to `stores(store_id)`. Keep `store_username` only if needed for display, but don't use it as a join key.

---

### 1.3 `orders.customer_name` is a single column, but the Java model has `firstName` + `lastName`

**Problem:** The DB stores a single `customer_name` field, but [Order.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/Order.java) has separate `firstName` and `lastName`. The [OrderDAO](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/dao/OrderDAO.java#16-763) splits and combines them at runtime:

```java
// On INSERT: combines them
String customerName = order.getFirstName() + " " + order.getLastName();

// On SELECT: splits them back
String[] nameParts = customerName.trim().split("\\s+", 2);
```

**Why it matters:** If someone has a middle name like "John Michael Doe", the split will put "Michael Doe" into `lastName`. It works but is fragile.

**Suggested fix:** Either store `first_name` and `last_name` as two DB columns (cleaner), or just accept the single-column approach and remove the separate fields from [Order.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/Order.java).

---

### 1.4 `orders.product_name` is a single VARCHAR field for an entire order

**Problem:** The `orders` table has a `product_name VARCHAR(500)` field. But an order can have **multiple items** (that's what `order_items` is for). This field seems to be a legacy flat string, like `"Product A, Product B"`.

**Why it matters:** You already have the proper `order_items` table. Having `product_name` on the `orders` table too means the data is duplicated and can go out of sync.

**Suggested fix:** For display purposes, build the product name string dynamically from `order_items` when needed, rather than storing it on the `orders` table.

---

### 1.5 `store_orders` table exists but appears unused

**Problem:** There's a `store_orders` table designed to track per-store totals, commission, and payable amounts for multi-store orders. But no DAO or servlet references it. No `StoreOrderDAO` exists.

**Why it matters:** This table was clearly designed for multi-store order splitting (commission calculation, per-store totals), but the feature is not implemented. It's dead schema.

**Suggested fix:** Either implement the `StoreOrderDAO` and populate `store_orders` during checkout, or remove the table to avoid confusion.

---

## 2. Product & Variant Handling Issues

### 2.1 Hardcoded variant attributes (color, size, power)

**Problem:** The `product_variants` table has three specific columns: `color`, `size`, `power`. The [ProductVariant.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/ProductVariant.java) model matches this exactly.

**Why it matters:**
- If a store wants to sell a product by **material**, **capacity**, **voltage**, or any other attribute, there's no way to do it — the system only understands color, size, and power.
- Adding a new attribute means altering the DB table, the model, the DAO, the add/edit JSP forms, and the cart — every layer.

**Suggested fix (simple for university):** For your project level, this is actually fine. If you want a slightly better approach, you could add a generic `attribute_name` and `attribute_value` pair, but honestly the 3-column approach works for a repair tools / electronics store.

---

### 2.2 Product image stored as `LONGBLOB` in the database

**Problem:** Product images are stored directly in the `products` table as `image LONGBLOB`. The [Product.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/Product.java) converts this to Base64 for display:

```java
public String getImageBase64() {
    return Base64.getEncoder().encodeToString(image);
}
```

**Why it matters:**
- **Performance**: Every time you load products, you fetch the full image bytes from the DB. A product list page with 20 products fetches 20 BLOBs.
- **Memory**: Base64 encoding increases the data size by ~33%, and it's all held in server memory.
- **Scalability**: This approach slows down significantly with many products.

**Suggested fix:** Store images as files on the server's filesystem (e.g., `/uploads/products/123.jpg`) and save only the file path in the DB. Serve them via a static URL.

---

### 2.3 No product status / "Published" flag

**Problem:** Once a product is added, it's immediately visible. There's no `is_active`, `status`, or `published` column in the `products` table.

**Why it matters:**
- A store owner can't temporarily hide a product without deleting it.
- No concept of "draft" products — you can't save a half-complete product and publish it later.

**Suggested fix:** Add `is_active BOOLEAN DEFAULT TRUE` to the `products` table and filter queries with `WHERE is_active = TRUE` for public-facing pages.

---

### 2.4 Products have no `created_at` or `updated_at` timestamps

**Problem:** The `products` table has no timestamp columns. You can't tell when a product was added or last modified.

**Why it matters:** Sorting by "newest" is impossible. You also can't implement features like "new arrivals" in the store.

**Suggested fix:** Add `created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP` and `updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`.

---

### 2.5 Variant images are not supported

**Problem:** Each product has one image. If a product has 3 color variants (Red, Blue, Black), they all share the same image.

**Why it matters:** Users can't see what the variant looks like before buying. This is a common e-commerce expectation.

**Suggested fix (for uni level):** This is a "nice to have". If you want, add an `image LONGBLOB` (or file path) column to `product_variants`. But for a university project, a single product image is acceptable.

---

### 2.6 No product categories table — `type` is a free-text VARCHAR

**Problem:** Products have a `type VARCHAR(50)` column used for categorization. This is just a free-text string — there's no `categories` table with proper IDs and hierarchy.

**Why it matters:**
- Typos create duplicate categories: "Electronics" vs "electronics" vs "Electroncs".
- No way to manage categories from an admin panel.
- `ProductDAO.getAllCategories()` does a `SELECT DISTINCT type FROM products` which is inefficient.

**Suggested fix:** Create a `product_categories` table with `category_id` and [name](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/Order.java#163-166), then use `category_id` in the `products` table instead of free-text `type`.

---

## 3. Cart & Checkout Issues

### 3.1 Cart is session-only (no DB persistence)

**Problem:** The shopping cart is a `Map<Integer, CartItem>` stored in the `HttpSession`. There is no `cart` or `cart_items` table.

**Why it matters:**
- If the user's session expires (e.g., server restart, idle timeout), the cart is lost with no recovery.
- The user can't see their cart across different devices.
- If the server restarts during deployment, all active carts vanish.

**Suggested fix (for uni level):** This is acceptable for a university project. Session-based carts are simpler. But be aware that in production, you'd want a `cart_items` DB table.

---

### 3.2 Cart key collision between products and variants

**Problem:** In [CartServlet.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/servlet/cart/CartServlet.java), the cart key is:

```java
int cartKey = variantId != null ? variantId : productId;
```

**Why it matters:** If a `variantId` happens to have the same numeric value as a different `productId`, they'll overwrite each other in the cart. For example, if variant ID = 5 and a different product also has ID = 5, adding both will collide.

**Suggested fix:** Use a composite key string like `"P-" + productId` or `"V-" + variantId` to avoid collisions:
```java
String cartKey = variantId != null ? "V-" + variantId : "P-" + productId;
```
This requires changing the cart Map from `Map<Integer, CartItem>` to `Map<String, CartItem>`.

---

### 3.3 Cart doesn't track which store each item belongs to

**Problem:** [CartItem.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/CartItem.java) has no `storeId` or `storeUsername` field. It only stores `productId`, [name](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/Order.java#163-166), `price`, and variant info.

**Why it matters:**
- When checking out, the system can't split items by store for multi-store orders.
- The [CheckoutServlet](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/servlet/order/CheckoutServlet.java#24-146) creates a single order without knowing which store each item is from.
- The `order_items` table requires a `store_id`, but the cart doesn't carry this info.

**Suggested fix:** Add `storeId` and `storeName` fields to [CartItem](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/CartItem.java#3-101). Populate them when adding to cart (look up from the product).

---

### 3.4 Checkout doesn't create `order_items` records

**Problem:** Looking at [CheckoutServlet.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/servlet/order/CheckoutServlet.java), it creates a single [Order](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/Order.java#9-199) record with a flat `productName` and `amount`. But it **never creates [OrderItem](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/OrderItem.java#9-128) records** for the individual products in the cart.

```java
// CheckoutServlet just does:
Order order = new Order(orderId, firstName, lastName, email,
        phone, address, city, product, amount);
orderDAO.createOrder(order);
```

**Why it matters:** This is a **major gap**. The `order_items` table exists and the [OrderDAO](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/dao/OrderDAO.java#16-763) has methods for it, but checkout doesn't use them. This means:
- Stores can't see which specific products were ordered.
- Stock reduction via [reduceStockForOrder()](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/dao/OrderDAO.java#684-744) can't work because there are no `order_items` to process.
- Per-store order splitting is impossible.

**Suggested fix:** After creating the order, loop through the cart items and create an [OrderItem](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/OrderItem.java#9-128) for each:
```java
for (CartItem item : cart.values()) {
    OrderItem oi = new OrderItem(orderId, storeId, item.getProductId(), 
        item.getVariantId(), item.getName(), item.getQuantity(), ...);
    orderDAO.createOrderItem(oi);
}
```

---

### 3.5 Stock is not validated at checkout time

**Problem:** Stock is checked when adding to cart ([CartServlet](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/servlet/cart/CartServlet.java#21-195)), but **not at checkout**. Between adding to cart and paying, another customer could buy the same product.

**Why it matters:** Two users could add the last item to their carts. Both proceed to checkout. Both succeed. But only one item exists — the stock goes negative (or the `GREATEST(0, ...)` clause hides it by clamping to 0).

**Suggested fix:** Before creating the order, re-check stock levels for each cart item and return an error if any are insufficient.

---

### 3.6 Stock reduction uses `GREATEST(0, quantity - ?)` which silently allows overselling

**Problem:** Both `ProductDAO.reduceProductQuantity()` and `ProductVariantDAO.reduceVariantQuantity()` use:

```sql
UPDATE products SET quantity = GREATEST(0, quantity - ?) WHERE product_id = ?
```

**Why it matters:** If current stock is 2 and someone buys 5, the stock becomes 0 instead of failing. The seller loses 3 items they don't have.

**Suggested fix:** Use a conditional update:
```sql
UPDATE products SET quantity = quantity - ? WHERE product_id = ? AND quantity >= ?
```
If `rowsAffected == 0`, it means there wasn't enough stock.

---

## 4. Multi-Store Order Handling Issues

### 4.1 One order = One store assumption

**Problem:** The `orders` table has a single `store_username` field, implying one order belongs to one store. But the `order_items` table has a `store_id` per item, implying items from different stores can be in one order.

**Why it matters:** The schema is contradictory:
- If user buys from Store A and Store B, you'd need either 2 separate orders or 1 order with items from both stores.
- Currently, [CheckoutServlet](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/servlet/order/CheckoutServlet.java#24-146) sets one `store_username` per order, so multi-store orders are broken.

**Suggested fix:** Decide on one approach:
- **Option A (simpler):** One order per store. Split the cart by store at checkout and create separate orders.
- **Option B (complex):** Allow multi-store orders. Remove `store_username` from `orders` and rely entirely on `order_items.store_id`.

For a university project, **Option A** is much simpler and recommended.

---

### 4.2 No store selection during browsing

**Problem:** Looking at the store pages, it seems products from all stores are mixed together or filtered by category. There's no clear "browse Store X's products" flow.

**Why it matters:**
- Users might not realize they're buying from multiple stores.
- Shipping/delivery expectations differ between stores (different cities/locations).

**Suggested fix:** Add a "Store" page where users can browse a specific store's catalogue. Display the store name on each product card.

---

## 5. Discount System Issues

### 5.1 Discounts reference `store_username` (varchar) instead of `store_id`

**Problem:** The `discounts` table uses `store_username VARCHAR(255)` with a FK to `users(username)`, not to `stores(store_id)`.

**Why it matters:** Same problem as products — if the username changes, all discounts break.

**Suggested fix:** Use `store_id INT` with a FK to `stores(store_id)`.

---

### 5.2 Discount validation is only at cart-add time

**Problem:** Discounts are applied when adding to cart, but if a discount expires between adding to cart and checkout, the user still gets the old discounted price.

**Why it matters:** A discount that ends at midnight could still be applied to someone who added to cart at 11pm and checks out at 1am.

**Suggested fix (for uni level):** Re-validate discounts at checkout time. Or, for simplicity, just document this as a known limitation — it's acceptable for a university project.

---

### 5.3 No maximum discount cap or minimum order value

**Problem:** A `FIXED` discount of ₹10,000 on a ₹500 product would make the price -₹9,500. The `Discount.calculateDiscountedPrice()` method might handle this, but there's no minimum order constraint.

**Why it matters:** Store owners could accidentally create discounts that make products free or negative-priced.

**Suggested fix:** Add a `Math.max(0, discountedPrice)` check and optionally a `min_order_value` column on the `discounts` table.

---

## 6. Delivery Driver & Order Fulfilment Issues

### 6.1 No delivery assignment system exists

**Problem:** The system has:
- A `driver` role in the `users` table
- A `vehicles` table linking drivers to vehicles with fare info
- A [UserDriver.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/UserDriver.java) model with driver-specific fields

But there is **no `delivery_assignments` or `order_deliveries` table**. There is no mechanism to:
- Assign a driver to an order
- Track delivery status per driver
- Record pickup/delivery timestamps

**Why it matters:** Orders can go to `OUT_FOR_DELIVERY` status, but there's no record of *who* is delivering it or tracking the delivery.

**Suggested fix:** Create a table like:
```sql
CREATE TABLE delivery_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    driver_id INT NOT NULL,
    store_id INT NOT NULL,
    status ENUM('ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED') DEFAULT 'ASSIGNED',
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivered_at TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (driver_id) REFERENCES users(user_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);
```

---

### 6.2 [UserDriver](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/UserDriver.java#3-26) model doesn't match the `vehicles` DB table

**Problem:** [UserDriver.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/UserDriver.java) has: `driverId`, `user`, `realPic`, `serviceArea`, `licensePic`. But the `vehicles` table has: `driver_id`, `vehicle_type`, `brand`, `model`, `plate_number`, `picture`, `fare_first_km`, `fare_next_km`. There's no `drivers` table at all — there's only `vehicles`.

**Why it matters:** The [UserDriver](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/UserDriver.java#3-26) Java model doesn't correspond to any actual DB table. The `serviceArea` and `licensePic` fields have nowhere to be stored.

**Suggested fix:** Create a `drivers` table that stores driver-specific info (license, service area, real pic), while `vehicles` stays for vehicle details.

---

### 6.3 No driver dashboard or order assignment flow

**Problem:** There are store dashboards, user dashboards, and admin dashboards, but no driver dashboard. No servlet handles:
- Showing available deliveries to a driver
- Accepting/rejecting a delivery
- Updating delivery status
- Driver earnings

**Why it matters:** The driver role exists in user registration but has no functionality after login.

**Suggested fix:** For a university project, a basic driver page that shows assigned orders and lets the driver mark them as "Picked Up" → "Delivered" would be sufficient.

---

### 6.4 Multi-store orders with one driver = complex logistics

**Problem:** If one order has items from Store A (Colombo) and Store B (Kandy), a single driver would need to pick up from both stores. There's no mechanism for:
- Split deliveries
- Multiple pickup points
- Separate delivery fees per store

**Why it matters:** This is the hardest part of multi-store delivery. Without solving it, allowing multi-store orders will cause confusion.

**Suggested fix:** The simplest solution is **one order per store** (see 4.1 Option A). Each order gets its own delivery driver. Users pay separate delivery fees.

---

## 7. Filtering & Display Issues

### 7.1 No pagination on product listings

**Problem:** `ProductDAO.getAllProducts()` and [getProductsByCategory()](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/dao/ProductDAO.java#182-213) return ALL products with no `LIMIT` or `OFFSET`. On the store's public page, every product is loaded at once.

**Why it matters:** With 100+ products, the page will be slow (especially with BLOB images). There's no way to browse page by page.

**Suggested fix:** Add `LIMIT ? OFFSET ?` to product queries and pass page numbers from the servlet/JSP.

---

### 7.2 No price range filtering

**Problem:** The search function ([searchProductsByName](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/dao/ProductDAO.java#214-326)) searches by name/description, but there's no way to filter by price range.

**Why it matters:** Users often want to find products "under ₹5,000" or "between ₹1,000 and ₹3,000". Can't do this currently.

**Suggested fix:** Add optional `minPrice` and `maxPrice` parameters to the query with `AND price BETWEEN ? AND ?`.

---

### 7.3 No sorting options (price low-high, newest, popular)

**Problem:** Products are returned in database insertion order. No sorting mechanism exists in the DAOs or servlets.

**Why it matters:** Users expect to sort by price (ascending/descending), newest, or popularity (best-selling).

**Suggested fix:** Add an `ORDER BY` clause based on a `sort` parameter: `price ASC`, `price DESC`, `created_at DESC`, etc.

---

### 7.4 Category filtering is case-sensitive

**Problem:** [getProductsByCategory()](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/dao/ProductDAO.java#182-213) uses `WHERE type = ?` (exact match). But [getAllCategories()](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/dao/ProductDAO.java#343-358) uses `SELECT DISTINCT type` — if categories were entered inconsistently, "Electronics" and "electronics" would be different categories.

**Why it matters:** Users clicking on "Electronics" won't see products tagged as "electronics".

**Suggested fix:** Use `WHERE LOWER(type) = LOWER(?)` for case-insensitive matching.

---

## 8. Order Management Issues

### 8.1 Order status flow has no validation

**Problem:** [UpdateOrderStatusServlet](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/servlet/order/UpdateOrderStatusServlet.java#20-97) allows setting any valid status on any order. There's no check for valid transitions:
- You could set an order directly from `PENDING` to `DELIVERED`, skipping `PAID` and `PROCESSING`.
- A `DELIVERED` order could be set back to `PENDING`.

**Why it matters:** Invalid status transitions can break business logic and confuse users.

**Suggested fix:** Add a status transition map:
```java
Map<String, List<String>> validTransitions = Map.of(
    "PENDING", List.of("PAID", "CANCELLED"),
    "PAID", List.of("PROCESSING", "CANCELLED"),
    "PROCESSING", List.of("OUT_FOR_DELIVERY"),
    "OUT_FOR_DELIVERY", List.of("DELIVERED")
);
```

---

### 8.2 No order cancellation / refund flow for customers

**Problem:** The `orders` table has `refund_reason`, `refund_number`, and `refunded_at` columns, suggesting refunds were planned. But there's no servlet or JSP to handle:
- Customer-initiated cancellation
- Store-initiated refund
- Admin-approved refund

**Why it matters:** Customers can't cancel orders. The refund columns exist but are unused.

**Suggested fix:** Add a simple cancellation servlet that sets the order status to `CANCELLED` and an admin page to process refunds (filling in `refund_reason` and `refund_number`).

---

### 8.3 No order confirmation email or notification

**Problem:** After checkout, the order is created and sent to PayHere for payment. But there's no email confirmation or in-app notification to the customer or store owner.

**Why it matters:** Without confirmation, customers don't know if their order went through, and stores don't know about new orders until they check the dashboard.

**Suggested fix (for uni level):** At minimum, show a "Your order #DF-XXXX was placed successfully" page after payment. Email is optional for a university project.

---

## 9. Security & Data Integrity Issues

### 9.1 No authorization checks on order status updates

**Problem:** [UpdateOrderStatusServlet](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/servlet/order/UpdateOrderStatusServlet.java#20-97) accepts any `orderId` and `status` via POST. It doesn't check whether the logged-in user owns that store's order.

**Why it matters:** Any authenticated user could potentially update any order's status by guessing the order ID.

**Suggested fix:** Check that the logged-in store user actually owns the order before allowing status changes.

---

### 9.2 `Product.price` uses `double` — floating-point precision issues

**Problem:** [Product.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/Product.java) uses `double price` while [ProductVariant.java](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/ProductVariant.java) correctly uses `BigDecimal price`. Mixing `double` and `BigDecimal` for monetary values is inconsistent.

**Why it matters:** `double` can produce rounding errors (e.g., `0.1 + 0.2 = 0.30000000000000004`). For money, this is unacceptable.

**Suggested fix:** Change `Product.price` to `BigDecimal` to match [ProductVariant](file:///c:/Users/Ashen%20Wattegedera/Downloads/daily_fixer/src/main/java/com/dailyfixer/model/ProductVariant.java#5-48).

---

## 10. Summary — Quick Priority List

| Priority | Issue | Impact | Difficulty |
|----------|-------|--------|------------|
| 🔴 Critical | Checkout doesn't create `order_items` (§3.4) | Orders have no item details | Medium |
| 🔴 Critical | Cart key collision (§3.2) | Items overwrite each other | Easy |
| 🔴 Critical | Cart doesn't track store (§3.3) | Multi-store checkout broken | Easy |
| 🟠 High | No delivery assignment system (§6.1) | Driver role has no purpose | Medium |
| 🟠 High | `store_username` used as FK everywhere (§1.1, 1.2, 5.1) | Breaks if username changes | Medium |
| 🟠 High | Stock overselling (§3.5, 3.6) | Negative stock possible | Easy |
| 🟠 High | No order status transition validation (§8.1) | Invalid status changes | Easy |
| 🟡 Medium | BLOB images in DB (§2.2) | Performance degrades | Medium |
| 🟡 Medium | No pagination (§7.1) | Slow pages with many products | Easy |
| 🟡 Medium | Product price as `double` (§9.2) | Rounding errors | Easy |
| 🟢 Low | No product timestamps (§2.4) | Can't sort by newest | Easy |
| 🟢 Low | Hardcoded variant attributes (§2.1) | Limited flexibility | Acceptable |
| 🟢 Low | Session-only cart (§3.1) | Cart lost on restart | Acceptable |

> [!NOTE]
> This is a university project — not everything needs to be fixed. Focus on the 🔴 Critical and 🟠 High items. The 🟢 Low items are acceptable at this level and can be documented as "known limitations" in your project report.
