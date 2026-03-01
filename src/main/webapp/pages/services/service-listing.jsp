<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Book a Technician - Daily Fixer</title>
            <jsp:include page="../shared/header.jsp" />
        </head>

        <body>
            <div style="max-width: 1200px; margin: 100px auto 2rem; padding: 0 1rem;">
                <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem; color: var(--foreground);">Book a
                    Technician</h1>

                <!-- Search and Filter Section -->
                <div
                    style="background: var(--card); padding: 1.5rem; border-radius: 0; margin-bottom: 2rem; box-shadow: var(--shadow-sm);">
                    <form method="get" action="${pageContext.request.contextPath}/services">
                        <div
                            style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 1rem;">
                            <div>
                                <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Search</label>
                                <input type="text" name="search" value="${searchQuery}" placeholder="Search services..."
                                    style="width: 100%; padding: 0.5rem; border: 1px solid var(--border); border-radius: 0; background: var(--input);">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Category</label>
                                <select name="category"
                                    style="width: 100%; padding: 0.5rem; border: 1px solid var(--border); border-radius: 0; background: var(--input);">
                                    <option value="">All Categories</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.name}" ${selectedCategory==cat.name ? 'selected' : '' }>
                                            ${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <button type="submit"
                            style="background: var(--primary); color: var(--primary-foreground); padding: 0.5rem 1.5rem; border: none; border-radius: 0; font-weight: 600; cursor: pointer;">
                            Search
                        </button>
                    </form>
                </div>

                <!-- Services Grid -->
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem;">
                    <c:forEach var="service" items="${services}">
                        <div
                            style="background: var(--card); border-radius: 0; padding: 1.5rem; box-shadow: var(--shadow-sm); border: 1px solid var(--border);">
                            <h3
                                style="font-size: 1.25rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--foreground);">
                                ${service.serviceName}</h3>
                            <p style="color: var(--muted-foreground); font-size: 0.875rem; margin-bottom: 0.5rem;">
                                <strong>Category:</strong> ${service.category}
                            </p>
                            <p style="color: var(--muted-foreground); font-size: 0.875rem; margin-bottom: 0.5rem;">
                                ${service.description}
                            </p>
                            <div
                                style="margin: 1rem 0; padding: 1rem 0; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);">
                                <c:choose>
                                    <c:when test="${service.pricingType == 'fixed'}">
                                        <p style="font-size: 1.5rem; font-weight: 700; color: var(--primary);">LKR
                                            ${service.fixedRate}</p>
                                    </c:when>
                                    <c:otherwise>
                                        <p style="font-size: 1.5rem; font-weight: 700; color: var(--primary);">LKR
                                            ${service.hourlyRate}/hr</p>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${service.inspectionCharge > 0}">
                                    <p style="font-size: 0.875rem; color: var(--muted-foreground);">+ Inspection: LKR
                                        ${service.inspectionCharge}</p>
                                </c:if>
                                <c:if test="${service.transportCharge > 0}">
                                    <p style="font-size: 0.875rem; color: var(--muted-foreground);">+ Transport: LKR
                                        ${service.transportCharge}</p>
                                </c:if>
                            </div>
                            <a href="${pageContext.request.contextPath}/bookings/create?serviceId=${service.serviceId}"
                                style="display: block; text-align: center; background: var(--primary); color: var(--primary-foreground); padding: 0.75rem; border-radius: 0; text-decoration: none; font-weight: 600;">
                                Book Now
                            </a>
                        </div>
                    </c:forEach>
                </div>

                <c:if test="${empty services}">
                    <div
                        style="text-align: center; padding: 3rem; background: var(--card); border-radius: 0; margin-top: 2rem;">
                        <p style="font-size: 1.125rem; color: var(--muted-foreground);">No services found matching your
                            criteria.</p>
                    </div>
                </c:if>
            </div>
        </body>

        </html>