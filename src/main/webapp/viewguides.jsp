<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.dailyfixer.model.Guide" %>

<%
  List<Guide> guides = (List<Guide>) request.getAttribute("guides");
%>

<html>
<head>
  <title>All Guides</title>
  <style>
    .guide-card { border:1px solid #ccc; padding:10px; margin:10px; display:inline-block; width:200px; vertical-align:top; text-align:center; }
    .guide-card img { width:180px; height:120px; object-fit:cover; }
    .guide-card a { text-decoration:none; color:#003366; font-weight:bold; }
    .guide-card a:hover { text-decoration:underline; }
  </style>
</head>
<body>
<h2>All Guides</h2>

<% if (guides != null && !guides.isEmpty()) { %>
<% for (Guide g : guides) { %>
<div class="guide-card">
  <%-- Use correct URL for ImageServlet --%>
  <img src="<%= request.getContextPath() %>/ImageServlet?id=<%= g.getGuideId() %>&type=main" alt="Guide Image">
  <br>
  <a href="<%= request.getContextPath() %>/ViewGuidesServlet?id=<%= g.getGuideId() %>">
    <%= g.getTitle() %>
  </a>
</div>
<% } %>
<% } else { %>
<p>No guides found.</p>
<% } %>

</body>
</html>
