<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>

        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>${guide.title} | Daily Fixer</title>
            <link
                href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
            <style>
                .page-container {
                    max-width: 1000px;
                    margin: 0 auto;
                    padding: 100px 30px 50px;
                }

                .breadcrumb {
                    margin-bottom: 20px;
                    font-size: 0.9rem;
                }

                .breadcrumb a {
                    color: var(--primary);
                    text-decoration: none;
                }

                .breadcrumb span {
                    color: var(--muted-foreground);
                }

                .guide-header {
                    background: var(--card);
                    border-radius: var(--radius-lg);
                    padding: 30px;
                    border: 1px solid var(--border);
                    margin-bottom: 30px;
                }

                .guide-main-image {
                    width: 100%;
                    max-height: 400px;
                    object-fit: cover;
                    border-radius: var(--radius-md);
                    margin-bottom: 20px;
                }

                .guide-title {
                    font-size: 2rem;
                    color: var(--foreground);
                    margin-bottom: 15px;
                }

                .guide-meta {
                    display: flex;
                    gap: 15px;
                    flex-wrap: wrap;
                    margin-bottom: 20px;
                }

                .guide-badge {
                    padding: 6px 14px;
                    background: var(--accent);
                    color: var(--accent-foreground);
                    border-radius: 20px;
                    font-size: 0.85rem;
                    font-weight: 500;
                }

                .guide-author {
                    color: var(--muted-foreground);
                }

                .requirements-section,
                .steps-section,
                .video-section,
                .comments-section {
                    background: var(--card);
                    border-radius: var(--radius-lg);
                    padding: 25px;
                    border: 1px solid var(--border);
                    margin-bottom: 25px;
                }

                .section-title {
                    font-size: 1.4rem;
                    color: var(--primary);
                    margin-bottom: 15px;
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }

                .requirements-list {
                    list-style: none;
                    padding: 0;
                }

                .requirements-list li {
                    padding: 10px 0;
                    border-bottom: 1px solid var(--border);
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }

                .requirements-list li:last-child {
                    border-bottom: none;
                }

                .step-item {
                    margin-bottom: 30px;
                    padding-bottom: 30px;
                    border-bottom: 1px solid var(--border);
                }

                .step-item:last-child {
                    border-bottom: none;
                    margin-bottom: 0;
                    padding-bottom: 0;
                }

                .step-header {
                    display: flex;
                    align-items: center;
                    gap: 15px;
                    margin-bottom: 15px;
                }

                .step-number {
                    width: 40px;
                    height: 40px;
                    background: var(--primary);
                    color: var(--primary-foreground);
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-weight: 700;
                    flex-shrink: 0;
                }

                .step-title {
                    font-size: 1.2rem;
                    color: var(--foreground);
                }

                .step-images {
                    display: flex;
                    gap: 15px;
                    overflow-x: auto;
                    margin-bottom: 15px;
                }

                .step-image {
                    width: 280px;
                    height: 200px;
                    object-fit: cover;
                    border-radius: var(--radius-md);
                    flex-shrink: 0;
                }

                .step-body {
                    color: var(--foreground);
                    line-height: 1.7;
                    white-space: pre-wrap;
                }

                .video-embed {
                    position: relative;
                    padding-bottom: 56.25%;
                    height: 0;
                    overflow: hidden;
                    border-radius: var(--radius-md);
                }

                .video-embed iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: none;
                }

                .rating-section {
                    display: flex;
                    align-items: center;
                    gap: 20px;
                    padding: 20px 0;
                    border-top: 1px solid var(--border);
                    margin-top: 20px;
                }

                .rating-btn {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding: 10px 20px;
                    border: 2px solid var(--border);
                    border-radius: var(--radius-md);
                    background: transparent;
                    cursor: pointer;
                    font-size: 1rem;
                    transition: all 0.2s;
                    color: var(--foreground);
                }

                .rating-btn:hover {
                    border-color: var(--primary);
                }

                .rating-btn.active-up {
                    background: #22c55e;
                    border-color: #22c55e;
                    color: white;
                }

                .rating-btn.active-down {
                    background: #ef4444;
                    border-color: #ef4444;
                    color: white;
                }

                .comment-form {
                    margin-bottom: 25px;
                }

                .comment-form textarea {
                    width: 100%;
                    padding: 15px;
                    border: 2px solid var(--border);
                    border-radius: var(--radius-md);
                    background: var(--input);
                    color: var(--foreground);
                    resize: vertical;
                    min-height: 100px;
                    font-family: inherit;
                    margin-bottom: 10px;
                }

                .comment-item {
                    padding: 15px;
                    background: var(--muted);
                    border-radius: var(--radius-md);
                    margin-bottom: 15px;
                }

                .comment-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 8px;
                }

                .comment-author {
                    font-weight: 600;
                    color: var(--foreground);
                }

                .comment-date {
                    font-size: 0.8rem;
                    color: var(--muted-foreground);
                }

                .comment-text {
                    color: var(--foreground);
                    line-height: 1.5;
                }

                .delete-comment-btn {
                    background: transparent;
                    border: none;
                    color: var(--destructive);
                    cursor: pointer;
                    font-size: 0.8rem;
                }

                .edit-actions {
                    display: flex;
                    gap: 15px;
                    margin-bottom: 20px;
                }
            </style>
        </head>

        <body>
            <!-- Navigation -->
            <nav id="navbar" class="public-nav">
                <div class="nav-container">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="logo">Daily Fixer</a>
                    <ul class="nav-links">
                        <li><a href="${pageContext.request.contextPath}/diagnostic.jsp">Diagnostic Tool</a></li>
                        <li><a href="${pageContext.request.contextPath}/guides">View Repair Guides</a></li>
                        <li><a href="${pageContext.request.contextPath}/findtech.jsp">Book a Technician</a></li>
                        <li><a href="${pageContext.request.contextPath}/store_main.jsp">Store</a></li>
                    </ul>
                    <div class="nav-buttons">
                        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()">🌙 Dark</button>
                        <c:choose>
                            <c:when test="${not empty sessionScope.currentUser}">
                                <a href="${pageContext.request.contextPath}/pages/dashboards/${sessionScope.currentUser.role}dash/${sessionScope.currentUser.role}dashmain.jsp"
                                    class="btn-login" style="text-decoration: none; padding: 0.6rem 1.2rem;">
                                    Hi, ${sessionScope.currentUser.firstName}
                                </a>
                                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/login.jsp" class="btn-login">Login</a>
                                <a href="${pageContext.request.contextPath}/preliminarySignup.jsp"
                                    class="btn-signup">Sign Up</a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </nav>

            <div class="page-container">
                <!-- Breadcrumb -->
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/guides">Repair Guides</a>
                    <span> / ${guide.mainCategory} / ${guide.subCategory}</span>
                </div>

                <!-- Edit Actions (for owners/admins) -->
                <c:if test="${canEdit}">
                    <div class="edit-actions">
                        <a href="${pageContext.request.contextPath}/guides/edit?id=${guide.guideId}"
                            class="btn-primary">Edit Guide</a>
                        <form action="${pageContext.request.contextPath}/guides/delete" method="post"
                            style="display:inline;"
                            onsubmit="return confirm('Are you sure you want to delete this guide?');">
                            <input type="hidden" name="id" value="${guide.guideId}">
                            <button type="submit" class="btn-danger">Delete Guide</button>
                        </form>
                    </div>
                </c:if>

                <!-- Guide Header -->
                <div class="guide-header">
                    <c:if test="${not empty guide.mainImagePath}">
                        <img src="${pageContext.request.contextPath}/${guide.mainImagePath}" alt="${guide.title}"
                            class="guide-main-image">
                    </c:if>
                    <h1 class="guide-title">${guide.title}</h1>
                    <div class="guide-meta">
                        <span class="guide-badge">${guide.mainCategory}</span>
                        <span class="guide-badge">${guide.subCategory}</span>
                    </div>
                    <p class="guide-author">Created by <strong>${guide.creatorName}</strong></p>

                    <!-- Rating Section -->
                    <div class="rating-section">
                        <span style="font-weight: 500;">Was this guide helpful?</span>
                        <button class="rating-btn ${userRating == 'UP' ? 'active-up' : ''}" id="upBtn"
                            onclick="rateGuide('UP')">
                            👍 <span id="upCount">${upCount}</span>
                        </button>
                        <button class="rating-btn ${userRating == 'DOWN' ? 'active-down' : ''}" id="downBtn"
                            onclick="rateGuide('DOWN')">
                            👎 <span id="downCount">${downCount}</span>
                        </button>
                        <div
                            style="margin-left: auto; display: flex; align-items: center; gap: 5px; color: var(--muted-foreground);">
                            <span>👁️ ${guide.viewCount} views</span>
                        </div>
                    </div>
                </div>

                <!-- Requirements -->
                <c:if test="${not empty guide.requirements}">
                    <div class="requirements-section">
                        <h2 class="section-title">🔧 Things You Need</h2>
                        <ul class="requirements-list">
                            <c:forEach var="req" items="${guide.requirements}">
                                <li>✓ ${req}</li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>

                <!-- Video Section -->
                <c:if test="${not empty guide.youtubeEmbedUrl}">
                    <div class="video-section">
                        <h2 class="section-title">🎥 Video Overview</h2>
                        <div class="video-embed">
                            <iframe src="${guide.youtubeEmbedUrl}" allowfullscreen></iframe>
                        </div>
                    </div>
                </c:if>

                <!-- Steps -->
                <c:if test="${not empty guide.steps}">
                    <div class="steps-section">
                        <h2 class="section-title">📋 Step-by-Step Guide</h2>
                        <c:forEach var="step" items="${guide.steps}" varStatus="status">
                            <div class="step-item">
                                <div class="step-header">
                                    <span class="step-number">${status.index + 1}</span>
                                    <h3 class="step-title">${step.stepTitle}</h3>
                                </div>
                                <c:if test="${not empty step.imagePaths}">
                                    <div class="step-images">
                                        <c:forEach var="imgPath" items="${step.imagePaths}">
                                            <img src="${pageContext.request.contextPath}/${imgPath}" alt="Step image"
                                                class="step-image">
                                        </c:forEach>
                                    </div>
                                </c:if>
                                <div class="step-body">${step.stepBody}</div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <!-- Comments -->
                <div class="comments-section">
                    <h2 class="section-title">💬 Comments</h2>

                    <c:if test="${not empty sessionScope.currentUser}">
                        <form class="comment-form" action="${pageContext.request.contextPath}/guides/comment"
                            method="post">
                            <input type="hidden" name="guideId" value="${guide.guideId}">
                            <input type="hidden" name="action" value="add">
                            <textarea name="comment" placeholder="Write a comment..." required></textarea>
                            <button type="submit" class="btn-primary">Post Comment</button>
                        </form>
                    </c:if>
                    <c:if test="${empty sessionScope.currentUser}">
                        <p style="margin-bottom: 20px; color: var(--muted-foreground);">
                            <a href="${pageContext.request.contextPath}/login.jsp">Login</a> to leave a comment.
                        </p>
                    </c:if>

                    <c:choose>
                        <c:when test="${not empty comments}">
                            <c:forEach var="comment" items="${comments}">
                                <div class="comment-item">
                                    <div class="comment-header">
                                        <span class="comment-author">${comment.userFirstName}
                                            (@${comment.username})</span>
                                        <div>
                                            <span class="comment-date">${comment.createdAt}</span>
                                            <c:if test="${comment.userId == currentUserId}">
                                                <form action="${pageContext.request.contextPath}/guides/comment"
                                                    method="post" style="display:inline;">
                                                    <input type="hidden" name="guideId" value="${guide.guideId}">
                                                    <input type="hidden" name="commentId" value="${comment.commentId}">
                                                    <input type="hidden" name="action" value="delete">
                                                    <button type="submit" class="delete-comment-btn">Delete</button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </div>
                                    <p class="comment-text">${comment.comment}</p>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p style="color: var(--muted-foreground);">No comments yet. Be the first!</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <script src="${pageContext.request.contextPath}/assets/js/dark-mode.js"></script>
            <script>
                function rateGuide(rating) {
                    <c:if test="${empty sessionScope.currentUser}">
                        alert('Please login to rate guides.');
                        return;
                    </c:if>

                    fetch('${pageContext.request.contextPath}/guides/rate', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'guideId=${guide.guideId}&rating=' + rating
                    })
                        .then(response => response.json())
                        .then(data => {
                            document.getElementById('upCount').textContent = data.upCount;
                            document.getElementById('downCount').textContent = data.downCount;

                            document.getElementById('upBtn').classList.remove('active-up');
                            document.getElementById('downBtn').classList.remove('active-down');

                            if (data.userRating === 'UP') {
                                document.getElementById('upBtn').classList.add('active-up');
                            } else if (data.userRating === 'DOWN') {
                                document.getElementById('downBtn').classList.add('active-down');
                            }
                        })
                        .catch(err => console.error('Rating error:', err));
                }
            </script>
        </body>

        </html>