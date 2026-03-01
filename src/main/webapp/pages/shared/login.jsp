<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />
<html>
<head>
  <title>DailyFixer - Login</title>
<%--  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">--%>
</head>
<body>
<div class="login-wrapper">
  <div class="login-card">
    <h2><fmt:message key="auth.dailyfixer"/></h2>
    <form action="${pageContext.request.contextPath}/LoginServlet" method="post" onsubmit="return validateLogin()">
      <div class="input-field">
        <label for="username"><fmt:message key="auth.username"/></label>
        <input type="text" id="username" name="username" required>
      </div>
      <div class="input-field">
        <label for="password"><fmt:message key="auth.password"/></label>
        <input type="password" id="password" name="password" required>
      </div>
      <button type="submit" class="login-btn"><fmt:message key="auth.sign_in"/></button>
    </form>

    <c:if test="${not empty error}">
      <div class="error">${error}</div>
    </c:if>

    <div class="note">Use your DailyFixer account credentials.</div>
    <a href="${pageContext.request.contextPath}/index.jsp" class="back-link"><fmt:message key="auth.back_home"/></a>
  </div>
</div>

<script>
  function validateLogin() {
    let user = document.getElementById("username").value.trim();
    let pass = document.getElementById("password").value.trim();
    if(user === "" || pass === "") {
      alert("Please fill in both fields.");
      return false;
    }
    return true;
  }
</script>
<script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>
</body>
</html>
