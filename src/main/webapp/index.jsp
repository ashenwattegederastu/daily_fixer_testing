<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ page session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Daily Fixer - Fix, Learn, Restore</title>
                <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                        rel="stylesheet">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
            </head>

            <body>
                <!-- Shared Header/Navigation -->
                <jsp:include page="/pages/shared/header.jsp" />

                <!-- Hero Section 1: Community -->
                <section class="hero-section active" id="hero1">
                    <div class="hero-content">
                        <h1><fmt:message key="home.hero1"/></h1>
                        <p><fmt:message key="home.hero1_sub"/></p>
                        <c:choose>
                            <c:when test="${not empty sessionScope.currentUser}">
                                <a href="${pageContext.request.contextPath}/pages/diagnostic/diagnostic-browse.jsp"
                                    class="hero-cta"><fmt:message key="home.start_diagnosing"/></a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/preliminarySignup.jsp" class="hero-cta"><fmt:message key="home.hero1_cta"/></a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="scroll-indicator">
                        <div class="chevron"></div>
                    </div>
                </section>

                <!-- Hero Section 2: View Guides -->
                <section class="hero-section" id="hero2">
                    <div class="hero-content">
                        <h1><fmt:message key="home.hero2"/></h1>
                        <p><fmt:message key="home.hero2_sub"/></p>
                        <a href="${pageContext.request.contextPath}/guides" class="hero-cta"><fmt:message key="home.hero2_cta"/></a>
                    </div>
                    <div class="scroll-indicator">
                        <div class="chevron"></div>
                    </div>
                </section>

                <!-- Features Section: View Guides -->
                <section class="features-section" id="guides">
                    <div class="features-container">
                        <h2 class="section-title"><fmt:message key="home.guides_why"/></h2>
                        <div class="features-grid">
                            <div class="feature-card">
                                <div class="feature-icon">📚</div>
                                <h3><fmt:message key="home.guides_lib"/></h3>
                                <p><fmt:message key="home.guides_lib_desc"/></p>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">👥</div>
                                <h3><fmt:message key="home.guides_community"/></h3>
                                <p><fmt:message key="home.guides_community_desc"/></p>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">⚡</div>
                                <h3><fmt:message key="home.guides_easy"/></h3>
                                <p><fmt:message key="home.guides_easy_desc"/></p>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Hero Section 3: Technician Booking -->
                <section class="hero-section" id="hero3">
                    <div class="hero-content">
                        <h1><fmt:message key="home.hero3"/></h1>
                        <p><fmt:message key="home.hero3_sub"/></p>
                        <a href="${pageContext.request.contextPath}/findtech.jsp" class="hero-cta"><fmt:message key="home.hero3_cta"/></a>
                    </div>
                    <div class="scroll-indicator">
                        <div class="chevron"></div>
                    </div>
                </section>

                <!-- Features Section: Technician Booking -->
                <section class="features-section" id="technician">
                    <div class="features-container">
                        <h2 class="section-title"><fmt:message key="home.tech_services"/></h2>
                        <div class="features-grid">
                            <div class="feature-card">
                                <div class="feature-icon">✓</div>
                                <h3><fmt:message key="home.certified"/></h3>
                                <p><fmt:message key="home.certified_desc"/></p>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">⏱️</div>
                                <h3><fmt:message key="home.quick_response"/></h3>
                                <p><fmt:message key="home.quick_response_desc"/></p>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">💰</div>
                                <h3><fmt:message key="home.transparent"/></h3>
                                <p><fmt:message key="home.transparent_desc"/></p>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Page-specific Scripts -->
                <script>
                    // Hero section visibility on scroll
                    const heroSections = document.querySelectorAll('.hero-section');
                    const observerOptions = {
                        threshold: 0.5
                    };

                    const observer = new IntersectionObserver((entries) => {
                        entries.forEach(entry => {
                            if (entry.isIntersecting) {
                                entry.target.classList.add('active');
                            } else {
                                entry.target.classList.remove('active');
                            }
                        });
                    }, observerOptions);

                    heroSections.forEach(section => {
                        observer.observe(section);
                    });

                    // Smooth scroll for internal links
                    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                        anchor.addEventListener('click', function (e) {
                            e.preventDefault();
                            const target = document.querySelector(this.getAttribute('href'));
                            if (target) {
                                target.scrollIntoView({
                                    behavior: 'smooth',
                                    block: 'start'
                                });
                            }
                        });
                    });
                </script>
            </body>

            </html>