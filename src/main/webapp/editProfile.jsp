<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
        return;
    }

    // Define role-specific redirect paths (easily modifiable)
    String basePath = request.getContextPath();  // <-- base path for all links
    String profilePath;

    switch (user.getRole().toLowerCase()) {
        case "driver":
            profilePath = "/pages/dashboards/driverdash/myProfile.jsp";
            break;
        case "admin":
            profilePath = basePath + "/pages/dashboards/admindash/adminProfile.jsp";
            break;
        default:
            profilePath = basePath + "/pages/dashboards/userdash/myProfile.jsp";
            break;
    }


%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Profile - Daily Fixer</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/updateprofile.css">
</head>
<body>

<div class="container">
    <div class="profile-card">
        <h2>Edit Account Information</h2>
        <form action="${pageContext.request.contextPath}/UpdateProfileServlet" method="post" class="profile-form">
            <input type="hidden" name="userId" value="${sessionScope.currentUser.userId}">

            <label>First Name</label>
            <input type="text" name="firstName" value="${sessionScope.currentUser.firstName}" required>

            <label>Last Name</label>
            <input type="text" name="lastName" value="${sessionScope.currentUser.lastName}" required>

            <label>Phone Number</label>
            <input type="text" name="phoneNumber" value="${sessionScope.currentUser.phoneNumber}" required pattern="[0-9]{10}" title="Enter 10 digit phone number">

            <label>City</label>
            <select name="city" required>
                <option value="">Select City</option>
                <c:forEach var="city" items="${['Colombo','Kandy','Galle','Matara','Jaffna','Kurunegala','Negombo','Anuradhapura','Ratnapura','Nuwara Eliya','Gampaha','Trincomalee','Badulla','Hambantota','Batticaloa','Kalutara','Polonnaruwa']}">
                    <option value="${city}" <c:if test="${sessionScope.currentUser.city == city}">selected</c:if>>${city}</option>
                </c:forEach>
            </select>

            <div class="profile-buttons">
                <button type="submit" class="btn edit">Save Changes</button>
                <a href="<%= request.getContextPath() + profilePath %>" class="btn reset">Cancel</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>
