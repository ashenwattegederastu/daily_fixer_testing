<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
  User currentUser = (User) session.getAttribute("currentUser");
  if (currentUser == null || !"volunteer".equalsIgnoreCase(currentUser.getRole())) {
    response.sendRedirect(request.getContextPath() + "/pages/shared/login.jsp");
    return;
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Add New Guide | Daily Fixer</title>
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

  /* Form Container */
  .form-container {
      background: #fff;
      border-radius: 12px;
      padding: 30px;
      box-shadow: var(--shadow-sm);
      border: 1px solid rgba(0,0,0,0.1);
      margin-top: 20px;
  }

  .form-section {
      margin-bottom: 30px;
      padding: 20px;
      background: var(--panel-color);
      border-radius: 8px;
      border-left: 4px solid var(--accent);
  }

  .form-section h3 {
      color: var(--text-dark);
      margin-bottom: 15px;
      font-size: 1.2em;
  }

  .form-group {
      margin-bottom: 20px;
  }

  label {
      display: block;
      margin-bottom: 8px;
      font-weight: 500;
      color: var(--text-dark);
  }

  input[type="text"], textarea, input[type="file"] {
      width: 100%;
      padding: 12px;
      border-radius: 8px;
      border: 1px solid rgba(0,0,0,0.2);
      font-family: inherit;
      font-size: 0.9em;
      transition: border-color 0.2s;
  }

  input[type="text"]:focus, textarea:focus {
      outline: none;
      border-color: var(--accent);
  }

  textarea {
      resize: vertical;
      min-height: 80px;
  }

  .add-btn {
      display: inline-block;
      margin-top: 10px;
      padding: 8px 16px;
      background: var(--accent);
      color: white;
      font-weight: 500;
      border-radius: 6px;
      cursor: pointer;
      border: none;
      font-size: 0.9em;
      transition: all 0.2s;
  }

  .add-btn:hover {
      background: #7a85e6;
      transform: translateY(-1px);
  }

  .submit-btn {
      margin-top: 25px;
      padding: 12px 30px;
      background: var(--accent);
      color: white;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
      font-size: 1em;
      box-shadow: var(--shadow-sm);
  }

  .submit-btn:hover {
      background: #7a85e6;
      transform: translateY(-2px);
      box-shadow: var(--shadow-md);
  }

  .back-btn {
      display: inline-block;
      margin-right: 15px;
      padding: 12px 20px;
      background: #6c757d;
      color: white;
      font-weight: 500;
      border-radius: 8px;
      text-decoration: none;
      transition: all 0.2s;
      font-size: 0.9em;
  }

  .back-btn:hover {
      background: #5a6268;
      transform: translateY(-1px);
  }

  .step-item {
      background: #fff;
      padding: 15px;
      border-radius: 8px;
      margin-bottom: 15px;
      border: 1px solid rgba(0,0,0,0.1);
  }
  </style>
</head>
<body>

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Volunteer Panel</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/volunteerdashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/myguides.jsp">My Guides</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/guideComments.jsp">Guide Comments</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/notifications.jsp">Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/addGuide.jsp" class="active">Add Guide</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/myProfile.jsp">My Profile</a></li>
    </ul>
</aside>

<div class="container">
    <h2>Add New Guide</h2>
    <p style="color: var(--text-secondary); margin-bottom: 20px;">Create a helpful guide to assist users with their daily repair needs</p>

    <div class="form-container">
        <form action="${pageContext.request.contextPath}/AddGuideServlet" method="post" enctype="multipart/form-data">

            <div class="form-section">
                <h3>Step 1: Basic Information</h3>
                <div class="form-group">
                    <label for="title">Guide Title:</label>
                    <input type="text" id="title" name="title" required placeholder="Enter a descriptive title for your guide">
                </div>
                <div class="form-group">
                    <label for="mainImage">Main Image:</label>
                    <input type="file" id="mainImage" name="mainImage" accept="image/*" required>
                </div>
            </div>

            <div class="form-section">
                <h3>Step 2: Requirements</h3>
                <div id="reqDiv">
                    <div class="form-group">
                        <input type="text" name="requirements" placeholder="Enter a requirement (e.g., tools, materials needed)">
                    </div>
                </div>
                <button type="button" onclick="addReq()" class="add-btn">+ Add Another Requirement</button>
            </div>

            <div class="form-section">
                <h3>Step 3: Guide Steps</h3>
                <div id="stepsDiv">
                    <div class="step-item">
                        <div class="form-group">
                            <label>Step Title:</label>
                            <input type="text" name="stepTitle" placeholder="Enter step title">
                        </div>
                        <div class="form-group">
                            <label>Step Description:</label>
                            <textarea name="stepDescription" placeholder="Provide detailed instructions for this step"></textarea>
                        </div>
                        <div class="form-group">
                            <label>Step Image:</label>
                            <input type="file" name="stepImage" accept="image/*">
                        </div>
                    </div>
                </div>
                <button type="button" onclick="addStep()" class="add-btn">+ Add Another Step</button>
            </div>

            <div style="margin-top: 30px;">
                <button type="submit" class="submit-btn">Submit Guide</button>
                <a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/myguides.jsp" class="back-btn">← Back to My Guides</a>
            </div>
        </form>
    </div>
</div>

<script>
  function addReq() {
    const div = document.createElement("div");
    div.className = "form-group";
    div.innerHTML = '<input type="text" name="requirements" placeholder="Enter a requirement (e.g., tools, materials needed)">';
    document.getElementById("reqDiv").appendChild(div);
  }

  function addStep() {
    const div = document.createElement("div");
    div.className = "step-item";
    div.innerHTML = `
      <div class="form-group">
        <label>Step Title:</label>
        <input type="text" name="stepTitle" placeholder="Enter step title">
      </div>
      <div class="form-group">
        <label>Step Description:</label>
        <textarea name="stepDescription" placeholder="Provide detailed instructions for this step"></textarea>
      </div>
      <div class="form-group">
        <label>Step Image:</label>
        <input type="file" name="stepImage" accept="image/*">
      </div>`;
    document.getElementById("stepsDiv").appendChild(div);
  }
</script>

</body>
</html>
