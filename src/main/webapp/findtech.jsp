<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Find a Technician - DailyFixer</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    /* Main Content */
    .main-content {
      padding: 2rem;
      margin-top: 80px; /* Add space for fixed header */
    }

    /* ... existing styles ... */



    :root {
      --primary-purple: #8b7dd8;
      --primary-blue: #7ba3d4;
      --light-purple: #e8e4f3;
      --light-blue: #e3ecf5;
      --accent-purple: #d4c5e8;
      --text-dark: #2d2d3d;
      --text-light: #6b6b7d;
      --white: #ffffff;
      --shadow-sm: 0 2px 8px rgba(139, 125, 216, 0.08);
      --shadow-md: 0 4px 16px rgba(139, 125, 216, 0.12);
      --shadow-lg: 0 8px 32px rgba(139, 125, 216, 0.15);
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background-color: var(--white);
      color: var(--text-dark);
      overflow-x: hidden;
    }


    /* Main Content */
    .main-content {
      padding: 2rem;
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
    }

    .page-title {
      font-size: 2.5rem;
      font-weight: 700;
      text-align: center;
      margin-bottom: 3rem;
      background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    .card-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 2rem;
      justify-items: center;
    }

    .card {
      background: var(--white);
      border-radius: 16px;
      box-shadow: var(--shadow-sm);
      overflow: hidden;
      width: 100%;
      max-width: 320px;
      transition: all 0.3s ease;
      border: 1px solid rgba(139, 125, 216, 0.1);
    }

    .card:hover {
      transform: translateY(-8px);
      box-shadow: var(--shadow-lg);
      border-color: rgba(139, 125, 216, 0.3);
    }

    .card img {
      width: 100%;
      height: 200px;
      object-fit: cover;
    }

    .card-content {
      padding: 1.5rem;
    }

    .card-content h3 {
      font-size: 1.3rem;
      margin-bottom: 0.8rem;
      color: var(--text-dark);
      font-weight: 600;
    }

    .tech-name {
      color: var(--text-light);
      font-size: 0.9rem;
      margin-bottom: 0.5rem;
    }

    .price {
      font-weight: 600;
      color: var(--primary-purple);
      font-size: 1.1rem;
      margin-bottom: 1rem;
    }

    .btn {
      display: inline-block;
      background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
      color: var(--white);
      text-decoration: none;
      padding: 0.8rem 1.5rem;
      border-radius: 8px;
      font-size: 0.9rem;
      font-weight: 600;
      transition: all 0.3s ease;
      box-shadow: var(--shadow-sm);
      border: none;
      cursor: pointer;
      width: 100%;
      text-align: center;
    }

    .btn:hover {
      transform: translateY(-2px);
      box-shadow: var(--shadow-md);
    }

    /* Responsive */
    @media (max-width: 768px) {
      .page-title {
        font-size: 2rem;
      }

      .main-content {
        padding: 1rem;
      }
    }
  </style>
</head>
<body>
<jsp:include page="/pages/shared/header.jsp" />

<div class="main-content">
  <div class="container">
    <h1 class="page-title">Find a Technician</h1>
    <div class="card-grid">
      <!-- Dummy Card Example -->
      <div class="card">
        <img src="${pageContext.request.contextPath}/assets/images/images.jpeg" alt="AC Repair">
        <div class="card-content">
          <h3>AC Repair</h3>
          <p class="tech-name">By: John Silva</p>
          <p class="price">Fixed Rate: Rs. 3500</p>
          <a href="viewservice.jsp?id=1" class="btn">View More</a>
        </div>
      </div>

      <div class="card">
        <img src="${pageContext.request.contextPath}/assets/images/images%20(1).jpeg" alt="AC Setup">
        <div class="card-content">
          <h3>AC Setup</h3>
          <p class="tech-name">By: John Silva</p>
          <p class="price">Hourly Rate: Rs. 1500/hr</p>
          <a href="viewservice.jsp?id=2" class="btn">View More</a>
        </div>
      </div>

      <div class="card">
        <img src="${pageContext.request.contextPath}/assets/images/proper-care-of-refrigerator.jpg" alt="Fridge Repair">
        <div class="card-content">
          <h3>Fridge Repair</h3>
          <p class="tech-name">By: Ramesh Kumar</p>
          <p class="price">Fixed Rate: Rs. 2800</p>
          <a href="viewservice.jsp?id=3" class="btn">View More</a>
        </div>
      </div>
    </div>
  </div>
</div>

</body>
</html>