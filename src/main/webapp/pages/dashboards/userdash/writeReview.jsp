<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User com.dailyfixer.user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null || !"user".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Write Review | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
    --panel-color: #dcdaff;
    --accent: #8b95ff;
    --text-dark: #000000;
    --text-secondary: #333333;
    --shadow-sm: 0 4px 12px rgba(0,0,0,0.12);
    --shadow-md: 0 8px 24px rgba(0,0,0,0.18);
    --shadow-lg: 0 12px 36px rgba(0,0,0,0.22);
}

/* Reset */
* { margin:0; padding:0; box-sizing:border-box; }
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
    top:0; left:0; right:0;
    height:76px;
    background-color: var(--panel-color);
    border-bottom: 1px solid rgba(0,0,0,0.1);
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 30px;
    z-index: 200;
    box-shadow: var(--shadow-md);
}
.topbar .logo { font-size: 1.5em; font-weight: 700; color: var(--accent); }
.topbar .panel-name { font-weight: 600; flex:1; text-align:center; color: var(--text-dark); }
.topbar-actions {
    display: flex;
    gap: 15px;
    align-items: center;
}

.topbar .home-btn {
    padding: 0.6rem 1.2rem;
    background: linear-gradient(135deg, #10b981, #059669);
    border: none;
    color: #fff;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    box-shadow: var(--shadow-sm);
    text-decoration: none;
    transition: all 0.2s;
}
.topbar .home-btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
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
    transition: all 0.2s;
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
    top:0;
    left:0;
    padding-top: 96px;
    box-shadow: var(--shadow-md);
    overflow-y: auto;
    z-index: 100;
}
.sidebar h3 { padding: 0 20px 12px; font-size: 0.85em; color: var(--text-dark); text-transform: uppercase; }
.sidebar ul { list-style:none; }
.sidebar a {
    display:block;
    padding:12px 20px;
    text-decoration:none;
    color: var(--text-dark);
    font-weight:500;
    border-left:3px solid transparent;
    border-radius:0 8px 8px 0;
    margin-bottom:4px;
    transition: all 0.2s;
}
.sidebar a:hover, .sidebar a.active {
    background-color: #f0f0ff;
    border-left-color: var(--accent);
}

/* Main Content */
.container {
    flex:1;
    margin-left:240px;
    margin-top:83px;
    padding:30px;
}
.container h2 {
    font-size:1.6em;
    margin-bottom:20px;
    color: #000000;
}

/* Product Card */
.product-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    padding: 25px;
    margin-bottom: 30px;
    display: flex;
    align-items: center;
    gap: 20px;
}

.product-image {
    width: 100px;
    height: 100px;
    border-radius: 12px;
    border: 3px solid var(--accent);
    object-fit: cover;
    box-shadow: var(--shadow-sm);
}

.product-info h3 {
    font-size: 1.4em;
    margin-bottom: 8px;
    color: var(--text-dark);
}

.product-info p {
    color: var(--text-secondary);
    margin: 3px 0;
    font-size: 0.95em;
}

.product-info .price {
    font-size: 1.1em;
    font-weight: 600;
    color: var(--accent);
}

/* Review Form */
.review-form {
    background: #fff;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
    border: 1px solid rgba(0,0,0,0.1);
    padding: 30px;
    margin-bottom: 30px;
}

.review-form h4 {
    font-size: 1.3em;
    margin-bottom: 20px;
    color: var(--text-dark);
    border-bottom: 2px solid var(--panel-color);
    padding-bottom: 10px;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    font-weight: 600;
    color: var(--text-dark);
    margin-bottom: 8px;
    font-size: 1em;
}

.rating-input {
    display: flex;
    align-items: center;
    gap: 15px;
}

.rating-input input[type="number"] {
    width: 80px;
    padding: 10px 12px;
    border: 2px solid var(--panel-color);
    border-radius: 8px;
    font-size: 1em;
    font-weight: 600;
    text-align: center;
    color: var(--text-dark);
    background: #fff;
}

.rating-input input[type="number"]:focus {
    outline: none;
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(139, 149, 255, 0.1);
}

.star-display {
    display: flex;
    gap: 5px;
    font-size: 1.5em;
    color: #fbbf24;
}

.star-display .star {
    cursor: pointer;
    transition: all 0.2s;
}

.star-display .star:hover {
    transform: scale(1.2);
}

.form-group textarea {
    width: 100%;
    height: 120px;
    padding: 15px;
    border: 2px solid var(--panel-color);
    border-radius: 8px;
    font-family: 'Inter', sans-serif;
    font-size: 1em;
    color: var(--text-dark);
    resize: vertical;
    transition: all 0.2s;
}

.form-group textarea:focus {
    outline: none;
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(139, 149, 255, 0.1);
}

.form-group textarea::placeholder {
    color: var(--text-secondary);
}

/* Action Buttons */
.form-actions {
    display: flex;
    gap: 15px;
    justify-content: flex-end;
    margin-top: 25px;
}

.btn {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9em;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-block;
}

.btn-submit {
    background: linear-gradient(135deg, var(--accent), #7ba3d4);
    color: #ffffff;
}

.btn-submit:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.btn-cancel {
    background: #f3f4f6;
    color: var(--text-dark);
    border: 2px solid var(--panel-color);
}

.btn-cancel:hover {
    background: #e5e7eb;
    transform: translateY(-2px);
}

/* Review Guidelines */
.guidelines {
    background: var(--panel-color);
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 30px;
}

.guidelines h5 {
    font-size: 1.1em;
    margin-bottom: 10px;
    color: var(--text-dark);
}

.guidelines ul {
    margin: 0;
    padding-left: 20px;
    color: var(--text-secondary);
}

.guidelines li {
    margin-bottom: 5px;
    font-size: 0.9em;
}
</style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">User Panel</div>
    <div class="topbar-actions">
        <a href="${pageContext.request.contextPath}" class="home-btn">Home</a>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
<%--    <h3>Navigation</h3>--%>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/userdashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/notifications.jsp">Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myBookings.jsp">My Bookings</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myPurchases.jsp">My Purchases</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Write Review</h2>
    
    <!-- Product Information -->
    <div class="product-card">
        <img src="${pageContext.request.contextPath}/assets/images/hammer.png" alt="Heavy Duty Hammer" class="product-image">
        <div class="product-info">
            <h3>Heavy Duty Hammer</h3>
            <p><strong>Category:</strong> Tools</p>
            <p><strong>Order #:</strong> 12345</p>
            <p class="price">$25.00</p>
        </div>
    </div>

    <!-- Review Guidelines -->
    <div class="guidelines">
        <h5>Review Guidelines</h5>
        <ul>
            <li>Be honest and constructive in your feedback</li>
            <li>Focus on the product quality and your experience</li>
            <li>Avoid personal attacks or inappropriate language</li>
            <li>Your review will help other customers make informed decisions</li>
        </ul>
    </div>

    <!-- Review Form -->
    <form class="review-form" action="${pageContext.request.contextPath}/submitReview" method="post">
        <h4>Share Your Experience</h4>
        
        <div class="form-group">
            <label for="rating">Overall Rating</label>
            <div class="rating-input">
                <input type="number" id="rating" name="rating" min="1" max="5" value="5" required>
                <span>out of 5 stars</span>
                <div class="star-display" id="starDisplay">
                    <span class="star">★</span>
                    <span class="star">★</span>
                    <span class="star">★</span>
                    <span class="star">★</span>
                    <span class="star">★</span>
                </div>
            </div>
        </div>

        <div class="form-group">
            <label for="comment">Your Review</label>
            <textarea id="comment" name="comment" placeholder="Tell us about your experience with this product. What did you like? What could be improved?" required></textarea>
        </div>

        <div class="form-actions">
            <a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myPurchases.jsp" class="btn btn-cancel">Cancel</a>
            <button type="submit" class="btn btn-submit">Submit Review</button>
        </div>
    </form>
</main>

<script>
// Star rating interaction
const ratingInput = document.getElementById('rating');
const starDisplay = document.getElementById('starDisplay');
const stars = starDisplay.querySelectorAll('.star');

function updateStars(rating) {
    stars.forEach((star, index) => {
        if (index < rating) {
            star.textContent = '★';
            star.style.color = '#fbbf24';
        } else {
            star.textContent = '☆';
            star.style.color = '#d1d5db';
        }
    });
}

// Update stars when input changes
ratingInput.addEventListener('input', function() {
    updateStars(parseInt(this.value));
});

// Update input when stars are clicked
stars.forEach((star, index) => {
    star.addEventListener('click', function() {
        const rating = index + 1;
        ratingInput.value = rating;
        updateStars(rating);
    });
});

// Initialize stars
updateStars(parseInt(ratingInput.value));
</script>

</body>
</html>
