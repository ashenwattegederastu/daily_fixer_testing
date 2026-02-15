<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Details - DailyFixer</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

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
            margin-top: 80px;
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

        .content-wrapper {
            display: flex;
            gap: 3rem;
            align-items: flex-start;
            margin-bottom: 3rem;
        }

        .service-image {
            width: 100%;
            max-width: 400px;
            height: 300px;
            object-fit: cover;
            border-radius: 16px;
            box-shadow: var(--shadow-md);
            flex-shrink: 0;
        }

        .info-cards {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.5rem;
            flex: 1;
        }

        .info-card {
            background: var(--white);
            border-radius: 16px;
            padding: 1.5rem;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(139, 125, 216, 0.1);
        }

        .card-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 0.8rem;
        }

        .card-value {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--primary-purple);
            margin-bottom: 0.5rem;
        }

        .card-subtitle {
            font-size: 0.9rem;
            color: var(--text-light);
        }

        .book-section {
            background: var(--white);
            border-radius: 16px;
            padding: 2rem;
            box-shadow: var(--shadow-sm);
            border: 1px solid rgba(139, 125, 216, 0.1);
        }

        .book-section h3 {
            font-size: 1.8rem;
            margin-bottom: 2rem;
            color: var(--text-dark);
            font-weight: 600;
            text-align: center;
        }

        label {
            display: block;
            margin: 1rem 0 0.5rem;
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.95rem;
        }

        input, textarea, select {
            width: 100%;
            padding: 0.8rem;
            border-radius: 8px;
            border: 1px solid rgba(139, 125, 216, 0.2);
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: var(--white);
        }

        input:focus, textarea:focus, select:focus {
            outline: none;
            border-color: var(--primary-purple);
            box-shadow: 0 0 0 3px rgba(139, 125, 216, 0.1);
        }

        button {
            background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
            color: var(--white);
            border: none;
            padding: 1rem 2rem;
            border-radius: 8px;
            margin-top: 1.5rem;
            cursor: pointer;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-sm);
            width: 100%;
        }

        button:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .availability {
            margin-top: 1rem;
            background: var(--light-purple);
            padding: 1rem;
            border-radius: 8px;
            border: 1px solid rgba(139, 125, 216, 0.2);
        }

        .availability p {
            color: var(--text-dark);
            font-weight: 500;
            line-height: 1.6;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .main-content {
                padding: 1rem;
                margin-top: 70px;
            }

            .page-title {
                font-size: 2rem;
            }

            .content-wrapper {
                flex-direction: column;
                gap: 2rem;
            }

            .info-cards {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .book-section {
                padding: 1.5rem;
            }

            .service-image {
                height: 250px;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/pages/shared/header.jsp" />

<div class="main-content">
    <div class="container">
        <h1 class="page-title">AC Repair Service</h1>

        <div class="content-wrapper">
            <img src="${pageContext.request.contextPath}/assets/images/images.jpeg" alt="Service Image" class="service-image">

            <div class="info-cards">
                <div class="info-card">
                    <div class="card-title">Technician</div>
                    <div class="card-value">John Silva</div>
                    <div class="card-subtitle">Certified AC Specialist</div>
                </div>

                <div class="info-card">
                    <div class="card-title">Service Price</div>
                    <div class="card-value">Rs. 3,500</div>
                    <div class="card-subtitle">Fixed Rate</div>
                </div>

                <div class="info-card">
                    <div class="card-title">Inspection Charge</div>
                    <div class="card-value">Rs. 500</div>
                    <div class="card-subtitle">Diagnostic Fee</div>
                </div>

                <div class="info-card">
                    <div class="card-title">Transport Charge</div>
                    <div class="card-value">Rs. 800</div>
                    <div class="card-subtitle">Travel Fee</div>
                </div>

                <div class="info-card">
                    <div class="card-title">Service Type</div>
                    <div class="card-value">AC Repair</div>
                    <div class="card-subtitle">Air Conditioning</div>
                </div>

                <div class="info-card">
                    <div class="card-title">Service Area</div>
                    <div class="card-value">City Wide</div>
                    <div class="card-subtitle">All Areas Covered</div>
                </div>
            </div>
        </div>

        <div class="book-section">
            <h3>Book This Service</h3>
            <label>Available Dates</label>
            <div class="availability">
                <p>25 Oct 2025 - 9 AM, 2 PM<br>26 Oct 2025 - 10 AM, 5 PM</p>
            </div>

            <label for="time">Preferred Time</label>
            <input type="text" id="time" placeholder="Enter preferred time or choose from above">

            <label for="desc">Issue Description (Optional)</label>
            <textarea id="desc" placeholder="Describe your issue here..."></textarea>

            <label for="location">Your Location</label>
            <input type="text" id="location" placeholder="Enter your address or nearby landmark">

            <button>Book Now</button>
        </div>
    </div>
</div>

</body>
</html>