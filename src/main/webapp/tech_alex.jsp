<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Daily Fixer</title>
  <!-- Link to external stylesheet -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tech_alex.css">
</head>
<body>
<header>

  <!-- Main Navbar -->
  <nav class="navbar">
    <div class="logo">Daily Fixer</div>
    <ul class="nav-links">
      <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
      <li><a href="${pageContext.request.contextPath}/login">Log in</a></li>
    </ul>
  </nav>

  <!-- Rounded Subnav -->
  <div class="subnav">
    <a href="${pageContext.request.contextPath}/diagnostic.jsp" >Diagnose Now</a>
    <a href="${pageContext.request.contextPath}/findtech.jsp" class="active">Find a Technician</a>
    <a href="${pageContext.request.contextPath}/">View Repair Guides</a>
    <a href="${pageContext.request.contextPath}/store_main.jsp">Stores</a>
  </div>
</header>

<main class="container">
  <!-- Left Technician Info -->
  <aside class="technician-profile">
    <div class="profile-pic"></div>
    <h3>Alex Johnson</h3>
    <p class="subtitle">Certified Technician</p>
    <p class="rating">⭐ 4.5 (120 Reviews)</p>

    <h4>About</h4>
    <p>
      Ethan is a highly skilled technician with over 5 years of experience in
      home repairs. He is certified in various fields and has a proven track
      record of resolving complex issues efficiently and effectively.
    </p>

    <h4>Qualifications</h4>
    <ul>
      <li>Certified Home Repair Specialist</li>
      <li>5+ years of experience</li>
    </ul>

    <h4>Reviews</h4>
    <div class="review">
      <p><strong>Sophie Clark</strong> · 1 week ago</p>
      <p>⭐⭐⭐⭐⭐</p>
      <p>
        Ethan was incredibly professional and knowledgeable. He fixed my
        plumbing issue in no time and explained everything clearly. Highly
        recommend!
      </p>
    </div>
  </aside>

  <!-- Right Booking Section -->
  <section class="booking">
    <h3>Book Alex Johnson</h3>

    <!-- Calendar -->
    <div class="calendar-section">
      <h4>Select Date</h4>
      <div class="calendar">
        <button class="nav">&lt;</button>
        <div class="month">July 2025</div>
        <button class="nav">&gt;</button>
      </div>
      <div class="days">
        <span>Mon</span><span>Tue</span><span>Wed</span><span>Thu</span>
        <span>Fri</span><span>Sat</span><span>Sun</span>
      </div>
      <div class="dates">
        <span>1</span><span>2</span><span class="active">3</span><span>4</span>
        <span>5</span><span>6</span>
      </div>
    </div>

    <!-- Availability -->
    <div class="availability">
      <h4>Availability</h4>
      <p>Mon - Sun · 8 AM - 8 PM</p>
    </div>

    <!-- Service Details -->
    <h4>Service Details</h4>
    <select>
      <option>Select service type</option>
      <option>Plumbing</option>
      <option>Electrical</option>
      <option>Appliance Repair</option>
    </select>
    <textarea placeholder="Describe the Issue"></textarea>

    <!-- Time Slot -->
    <h4>Preferred Time Slot</h4>
    <div class="time-slots">
      <button>Morning (8 AM - 12 PM)</button>
      <button>Afternoon (12 PM - 4 PM)</button>
      <button>Evening (4 PM - 8 PM)</button>
    </div>

    <!-- Pricing -->
    <div class="pricing">
      <h4>Pricing</h4>
      <p>Service Fee (per hour): <strong>LKR 500.00</strong></p>
    </div>

    <!-- Contact Details -->
    <h4>Contact Details</h4>
    <input type="text" placeholder="Enter Name">
    <input type="text" placeholder="Enter Home Address">
    <input type="text" placeholder="Phone">

    <!-- Confirm Button -->
    <button class="confirm-btn">Confirm Booking</button>
  </section>
</main>

<script>
  // Highlight selected date
  const dates = document.querySelectorAll(".dates span");
  dates.forEach(date => {
    date.addEventListener("click", () => {
      dates.forEach(d => d.classList.remove("active"));
      date.classList.add("active");
    });
  });

  // Highlight selected time slot
  const slots = document.querySelectorAll(".time-slots button");
  slots.forEach(slot => {
    slot.addEventListener("click", () => {
      slots.forEach(s => s.classList.remove("selected"));
      slot.classList.add("selected");
    });
  });

</script>
</body>
</html>