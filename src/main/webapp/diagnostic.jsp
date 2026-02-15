<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="true" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Daily Fixer - Diagnose Now</title>
    <style>
        /* === MAIN CONTENT === */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
            padding-top: 100px; /* account for fixed navbar */
        }

        .page-title {
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 2rem;
            background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-align: center;
        }

        .search-section {
            text-align: center;
            margin-bottom: 2.5rem;
        }

        .issue-title {
            font-size: 1.6rem;
            margin-bottom: 1rem;
            color: var(--text-dark);
        }

        .search-box {
            display: flex;
            max-width: 500px;
            margin: 0 auto;
            gap: 0.5rem;
        }

        .search-box input {
            flex: 1;
            padding: 0.8rem 1.2rem;
            border: 1.5px solid rgba(139, 125, 216, 0.3);
            border-radius: 12px;
            font-size: 1rem;
            outline: none;
            transition: border-color 0.3s ease;
        }

        .search-box input:focus {
            border-color: var(--primary-purple);
        }

        .search-box button {
            padding: 0.8rem 1.2rem;
            background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
            border: none;
            border-radius: 12px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .search-box button:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .search-box img {
            width: 20px;
            height: 20px;
            filter: invert(1);
        }

        /* === DIAGNOSTIC FLOW STYLING === */
        .category {
            font-size: 1.4rem;
            font-weight: 600;
            margin: 2rem 0 1rem;
            color: var(--text-dark);
            padding-left: 0.5rem;
            border-left: 4px solid var(--primary-purple);
        }

        .question-box {
            background: var(--white);
            padding: 1.2rem;
            border-radius: 16px;
            margin-bottom: 1.5rem;
            box-shadow: var(--shadow-sm);
            border: 1px solid rgba(139, 125, 216, 0.1);
            font-size: 1.2rem;
            text-align: center;
        }

        .prev-btn {
            background: transparent;
            border: 1.5px solid var(--primary-purple);
            color: var(--primary-purple);
            padding: 0.4rem 0.8rem;
            border-radius: 8px;
            margin-right: 1rem;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .prev-btn:hover {
            background: var(--light-purple);
        }

        .options-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 1rem;
            margin-bottom: 2.5rem;
        }

        .options-grid.centered {
            display: flex;
            justify-content: center;
            gap: 1.5rem;
            grid-template-columns: unset;
        }

        .option-btn {
            padding: 0.8rem;
            background: var(--white);
            border: 1.5px solid rgba(139, 125, 216, 0.3);
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            color: var(--text-dark);
        }

        .option-btn:hover {
            border-color: var(--primary-purple);
            transform: translateY(-2px);
            box-shadow: var(--shadow-sm);
        }

        /* === SUGGESTION PAGES === */
        .suggestion-page {
            padding: 2rem;
            background: var(--white);
            border-radius: 16px;
            box-shadow: var(--shadow-md);
            margin-bottom: 2rem;
            border: 1px solid rgba(139, 125, 216, 0.1);
        }

        .suggestion-page h2 {
            text-align: center;
            margin-bottom: 1.5rem;
            font-size: 1.8rem;
            background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .top-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .card {
            background: var(--white);
            padding: 1.5rem;
            border-radius: 14px;
            box-shadow: var(--shadow-sm);
            border: 1px solid rgba(139, 125, 216, 0.1);
        }

        .card h3 {
            margin-bottom: 1rem;
            color: var(--primary-purple);
            font-size: 1.2rem;
        }

        .confidence-bar {
            height: 8px;
            background: #e0e0e0;
            border-radius: 4px;
            margin: 0.5rem 0 1rem;
            overflow: hidden;
        }

        .confidence-level {
            height: 100%;
            background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
            border-radius: 4px;
        }

        .book-btn {
            width: 100%;
            padding: 0.8rem;
            background: linear-gradient(135deg, var(--primary-purple), var(--primary-blue));
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 0.8rem;
        }

        .book-btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .repair-guides ul,
        .recommended-fixes ul {
            list-style: none;
            padding-left: 0;
        }

        .repair-guides li,
        .recommended-fixes li {
            padding: 0.6rem 0;
            border-bottom: 1px solid rgba(0,0,0,0.05);
            cursor: pointer;
            transition: color 0.2s;
        }

        .repair-guides li:hover,
        .recommended-fixes li:hover {
            color: var(--primary-purple);
        }

        .parts-tools .parts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 1rem;
        }

        .part-item {
            padding: 1rem;
            background: var(--light-blue);
            border-radius: 12px;
            text-align: center;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid rgba(139, 125, 216, 0.2);
        }

        .part-item:hover {
            background: var(--accent-purple);
            transform: translateY(-2px);
            box-shadow: var(--shadow-sm);
        }

        .suggestion-box.center-screen {
            text-align: center;
            padding: 2rem;
            background: var(--white);
            border-radius: 16px;
            box-shadow: var(--shadow-md);
            margin: 2rem auto;
            max-width: 600px;
        }

        /* === RESPONSIVE === */
        @media (max-width: 768px) {
            .container {
                padding-top: 90px;
            }

            .page-title {
                font-size: 1.8rem;
            }

            .top-section {
                grid-template-columns: 1fr;
            }

            .options-grid {
                grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            }

            .search-box {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>

<!-- Include Header -->
<jsp:include page="/pages/shared/header.jsp" />

<!-- Main Content -->
<main class="container">
    <h2 class="page-title">Diagnose Your Issue</h2>

    <div class="search-section">
        <h3 class="issue-title">What's the issue?</h3>
        <div class="search-box">
            <input type="text" placeholder="Search for an issue" />
            <button>
                <img src="${pageContext.request.contextPath}/assets/images/pictures/search.png" alt="Search" />
            </button>
        </div>
    </div>

    <div class="category">Electrical Repairs</div>

    <!-- Initial Question -->
    <div class="question-box" id="question0">
        Where is the problem occurring?
    </div>
    <div class="options-grid">
        <button class="option-btn">Home Wiring</button>
        <button class="option-btn">Switches</button>
        <button class="option-btn">Lights</button>
        <button class="option-btn">Iron</button>
        <button class="option-btn">TV</button>
        <button class="option-btn">Fridge</button>
        <button class="option-btn" data-next="question1">Fan</button>
        <button class="option-btn">Sockets</button>
        <button class="option-btn">Overheating</button>
        <button class="option-btn">Burning smell</button>
        <button class="option-btn">Shocks</button>
        <button class="option-btn">Cookers</button>
        <button class="option-btn">Washing Machine</button>
        <button class="option-btn">Blender</button>
        <button class="option-btn">Oven</button>
        <button class="option-btn">Plug point</button>
    </div>

    <!-- Step 1 -->
    <div class="question-box" id="question1" style="display:none;">
        <button class="prev-btn" data-prev="question0">Previous</button>
        Is the fan turning on when you switch it on?
    </div>
    <div class="options-grid centered" id="options1" style="display:none;">
        <button class="option-btn" data-next="question4" data-answer="yes">Yes</button>
        <button class="option-btn" data-next="question2" data-answer="no">No</button>
    </div>

    <!-- Step 2 -->
    <div class="question-box" id="question2" style="display:none;">
        <button class="prev-btn" data-prev="question1">Previous</button>
        Is there power in the switchboard?
    </div>
    <div class="options-grid centered" id="options2" style="display:none;">
        <button class="option-btn" data-next="question3" data-answer="yes">Yes</button>
        <button class="option-btn" data-next="check_power" data-answer="no">No</button>
    </div>

    <!-- Step 3 -->
    <div class="question-box" id="question3" style="display:none;">
        <button class="prev-btn" data-prev="question2">Previous</button>
        Can you hear any humming sound from the fan?
    </div>
    <div class="options-grid centered" id="options3" style="display:none;">
        <button class="option-btn" data-next="question5" data-answer="yes">Yes</button>
        <button class="option-btn" data-next="wiring_fault" data-answer="no">No</button>
    </div>

    <!-- Step 4 -->
    <div class="question-box" id="question4" style="display:none;">
        <button class="prev-btn" data-prev="question1">Previous</button>
        Is the fan rotating slowly or unevenly?
    </div>
    <div class="options-grid centered" id="options4" style="display:none;">
        <button class="option-btn" data-next="question6" data-answer="yes">Yes</button>
        <button class="option-btn" data-next="question7" data-answer="no">No</button>
    </div>

    <!-- Suggestion Pages -->
    <div class="suggestion-page" id="question5" style="display:none;">
        <h2>Diagnostic Results for Your Fan</h2>
        <div class="top-section">
            <div class="most-likely-issue card">
                <h3>Most Likely Issue</h3>
                <p><strong>Fan capacitor fault</strong></p>
                <p>The capacitor inside the fan is worn out or damaged, causing the fan to not start or run slowly.</p>
                <p>Confidence level</p>
                <div class="confidence-bar">
                    <div class="confidence-level" style="width: 75%;"></div>
                </div>
                <button class="book-btn" onclick="window.location.href='${pageContext.request.contextPath}/findtech.jsp'">Book Technician</button>
            </div>
            <div class="recommended-fixes card">
                <h3>Recommended Fixes</h3>
                <ul>
                    <li>Test the capacitor using a multimeter and replace if faulty.</li>
                    <li>Ensure all connections to the capacitor are secure.</li>
                    <li>Restart the fan and check for normal operation.</li>
                </ul>
            </div>
        </div>
        <div class="repair-guides card">
            <h3>Recommended Repair Guides</h3>
            <ul>
                <li onclick="window.open('${pageContext.request.contextPath}/guide1.html', '_blank')">How to Test a Ceiling Fan Capacitor</li>
                <li onclick="window.open('${pageContext.request.contextPath}/guide2.html', '_blank')">Troubleshooting Ceiling Fan</li>
                <li onclick="window.open('${pageContext.request.contextPath}/guide3.html', '_blank')">Routine Ceiling Fan Maintenance Guide</li>
            </ul>
        </div>
        <div class="parts-tools card">
            <h3>Recommended Parts and Tools</h3>
            <div class="parts-grid">
                <div class="part-item">Capacitor</div>
                <div class="part-item">Screwdriver Set</div>
                <div class="part-item">Multimeter</div>
            </div>
        </div>
    </div>

    <div class="suggestion-page" id="question6" style="display:none;">
        <h2>Diagnostic Results for Your Fan</h2>
        <div class="top-section">
            <div class="most-likely-issue card">
                <h3>Most Likely Issue</h3>
                <p><strong>Dust Buildup or Worn Bearings</strong></p>
                <p>Dust or aging can cause friction in the fan motor, slowing rotation and reducing efficiency.</p>
                <p>Confidence level</p>
                <div class="confidence-bar">
                    <div class="confidence-level" style="width: 75%;"></div>
                </div>
                <button class="book-btn" onclick="window.location.href='${pageContext.request.contextPath}/findtech.jsp'">Book Technician</button>
            </div>
            <div class="recommended-fixes card">
                <h3>Recommended Fixes</h3>
                <ul>
                    <li>Clean the fan blades and motor vents using a soft brush or compressed air.</li>
                    <li>Apply a few drops of machine oil to the motor shaft if accessible.</li>
                    <li>If noise or slow rotation continues, consider replacing the bearings or the motor unit.</li>
                </ul>
            </div>
        </div>
        <div class="repair-guides card">
            <h3>Recommended Repair Guides</h3>
            <ul>
                <li onclick="window.open('${pageContext.request.contextPath}/guide1.html', '_blank')">Cleaning a Ceiling Fan: Step-by-Step</li>
                <li onclick="window.open('${pageContext.request.contextPath}/guide2.html', '_blank')">Lubricating Ceiling Fan Bearings</li>
                <li onclick="window.open('${pageContext.request.contextPath}/guide3.html', '_blank')">Routine Ceiling Fan Maintenance Guide</li>
            </ul>
        </div>
        <div class="parts-tools card">
            <h3>Recommended Parts and Tools</h3>
            <div class="parts-grid">
                <div class="part-item">Blades</div>
                <div class="part-item">Fan Motor</div>
                <div class="part-item">Bearings</div>
            </div>
        </div>
    </div>

    <div class="suggestion-box center-screen" id="question7" style="display:none;">
        <h3>Fan rotates fine</h3>
        <p>No repair needed.</p>
    </div>

    <div class="suggestion-page" id="check_power" style="display:none;">
        <h2>Diagnostic Results for Your Fan</h2>
        <div class="top-section">
            <div class="most-likely-issue card">
                <h3>Most Likely Issue</h3>
                <p><strong>Power not reaching the fan</strong></p>
                <p>The fan isn't receiving electricity, possibly due to a tripped breaker, blown fuse, or disconnected wiring.</p>
                <p>Confidence level</p>
                <div class="confidence-bar">
                    <div class="confidence-level" style="width: 75%;"></div>
                </div>
                <button class="book-btn" onclick="window.location.href='${pageContext.request.contextPath}/findtech.jsp'">Book Technician</button>
            </div>
            <div class="recommended-fixes card">
                <h3>Recommended Fixes</h3>
                <ul>
                    <li>Check the main circuit breaker or fuse box and reset or replace if needed.</li>
                    <li>Inspect wiring connections in the switchboard for loose or damaged wires.</li>
                    <li>Ensure the wall switch controlling the fan is functional.</li>
                </ul>
            </div>
        </div>
        <div class="repair-guides card">
            <h3>Recommended Repair Guides</h3>
            <ul>
                <li onclick="window.open('${pageContext.request.contextPath}/guide1.html', '_blank')">How to Check Main Power Supply</li>
                <li onclick="window.open('${pageContext.request.contextPath}/guide2.html', '_blank')">Resetting a Tripped Circuit Breaker Safely</li>
                <li onclick="window.open('${pageContext.request.contextPath}/guide3.html', '_blank')">Inspecting Switchboard Wiring for Beginners</li>
            </ul>
        </div>
        <div class="parts-tools card">
            <h3>Recommended Parts and Tools</h3>
            <div class="parts-grid">
                <div class="part-item">Multimeter</div>
                <div class="part-item">Screwdriver Set</div>
                <div class="part-item">Electrical Tape</div>
            </div>
        </div>
    </div>

    <div class="suggestion-page" id="wiring_fault" style="display:none;">
        <h2>Diagnostic Results for Your Fan</h2>
        <div class="top-section">
            <div class="most-likely-issue card">
                <h3>Most Likely Issue</h3>
                <p><strong>Wiring or switch fault</strong></p>
                <p>The fan is not receiving proper electrical connection due to damaged wires or a faulty switch.</p>
                <p>Confidence level</p>
                <div class="confidence-bar">
                    <div class="confidence-level" style="width: 75%;"></div>
                </div>
                <button class="book-btn" onclick="window.location.href='${pageContext.request.contextPath}/findtech.jsp'">Book Technician</button>
            </div>
            <div class="recommended-fixes card">
                <h3>Recommended Fixes</h3>
                <ul>
                    <li>Inspect the wall switch controlling the fan and replace if faulty.</li>
                    <li>Check wiring connections in the fan circuit for loose, broken, or disconnected wires.</li>
                    <li>Replace any damaged wires or connectors.</li>
                </ul>
            </div>
        </div>
        <div class="repair-guides card">
            <h3>Recommended Repair Guides</h3>
            <ul>
                <li onclick="window.open('${pageContext.request.contextPath}/guide1.html', '_blank')">Basic Electrical Safety While Inspecting Wires</li>
                <li onclick="window.open('${pageContext.request.contextPath}/guide2.html', '_blank')">How to Replace a Faulty Wall Switch</li>
                <li onclick="window.open('${pageContext.request.contextPath}/guide3.html', '_blank')">Troubleshooting Ceiling Fan</li>
            </ul>
        </div>
        <div class="parts-tools card">
            <h3>Recommended Parts and Tools</h3>
            <div class="parts-grid">
                <div class="part-item">Switch</div>
                <div class="part-item">Screwdriver Set</div>
                <div class="part-item">Multimeter</div>
            </div>
        </div>
    </div>
</main>

<script>
    // Navigation logic
    function showQuestion(id) {
        // Hide all questions and option grids
        document.querySelectorAll('.question-box, .options-grid, .suggestion-page, .suggestion-box').forEach(el => {
            el.style.display = 'none';
        });

        // Show target
        const target = document.getElementById(id);
        if (target) target.style.display =
            target.classList.contains('center-screen') ? 'block' :
                target.classList.contains('suggestion-page') ? 'block' :
                    'block';

        // Show associated options if exists
        const options = document.getElementById('options' + id.replace('question', ''));
        if (options) {
            options.style.display = options.classList.contains('centered') ? 'flex' : 'grid';
        }
    }

    // Handle option clicks
    document.querySelectorAll('.option-btn[data-next]').forEach(btn => {
        btn.addEventListener('click', () => {
            const next = btn.getAttribute('data-next');
            showQuestion(next);
        });
    });

    // Handle previous buttons
    document.querySelectorAll('.prev-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const prev = btn.getAttribute('data-prev');
            showQuestion(prev);
        });
    });
</script>
</body>
</html>