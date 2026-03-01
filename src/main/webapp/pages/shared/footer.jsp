<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<fmt:setLocale value="${sessionScope.sessionLocale != null ? sessionScope.sessionLocale : 'en'}" />
<fmt:setBundle basename="messages" />
<footer class="footer">
  <div class="footer-container">
    <div class="footer-logo">
      <h2><fmt:message key="footer.logo"/></h2>
      <p><fmt:message key="footer.tagline"/></p>
    </div>
    <div class="footer-links">
      <h3><fmt:message key="footer.quick_links"/></h3>
      <ul>
        <li><a href="${pageContext.request.contextPath}/index.jsp"><fmt:message key="footer.home"/></a></li>
        <li><a href="#about"><fmt:message key="footer.about"/></a></li>
        <li><a href="#services"><fmt:message key="footer.services"/></a></li>
        <li><a href="${pageContext.request.contextPath}/pages/shared/login.jsp"><fmt:message key="footer.login"/></a></li>
      </ul>
    </div>
    <div class="footer-contact">
      <h3><fmt:message key="footer.contact"/></h3>
      <p>Email: support@dailyfixer.com</p>
      <p>Phone: +94 77 123 4567</p>
      <div class="socials">
        <a href="#"><img src="${pageContext.request.contextPath}/assets/images/icons/youtube.png" alt="YouTube"></a>
        <a href="#"><img src="${pageContext.request.contextPath}/assets/images/icons/facebook.png" alt="Facebook"></a>
        <a href="#"><img src="${pageContext.request.contextPath}/assets/images/icons/instagram.png" alt="Instagram"></a>
      </div>
    </div>
  </div>
  <div class="footer-bottom">
    <p><fmt:message key="footer.copyright"/></p>
  </div>
</footer>
