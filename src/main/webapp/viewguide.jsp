<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Fix a Tap | Daily Fixer</title>
    <style>
        /* === Inherit your existing color palette === */
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #ffffff;
            color: #2d2d3d;
            line-height: 1.6;
        }

        .guide-container {
            max-width: 900px;
            margin: 120px auto 4rem;
            padding: 1rem 2rem;
        }

        .guide-header img {
            width: 100%;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(139,125,216,0.15);
            margin-bottom: 2rem;
        }

        .guide-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, #8b7dd8, #7ba3d4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .requirements {
            margin-bottom: 2rem;
            background: #f8f9ff;
            padding: 1rem 1.5rem;
            border-radius: 8px;
            border-left: 4px solid #8b7dd8;
        }

        .requirements ul {
            margin-top: 0.5rem;
            padding-left: 1.5rem;
        }

        .step {
            margin-bottom: 2rem;
        }

        .step img {
            width: 100%;
            border-radius: 8px;
            margin-top: 0.8rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .back-btn {
            display: inline-block;
            margin-top: 2rem;
            background: linear-gradient(135deg, #8b7dd8, #7ba3d4);
            color: #fff;
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
        }

        .back-btn:hover {
            box-shadow: 0 4px 16px rgba(139,125,216,0.2);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

<jsp:include page="/pages/shared/header.jsp" />

<!-- Guide Content -->
<div class="guide-container">
    <!-- === Main Image === -->
    <div class="guide-header">
        <img src="${pageContext.request.contextPath}/assets/images/pictures/Wasserhahn.jpg" alt="Fix a Tap">
    </div>

    <!-- === Guide Title === -->
    <h1 class="guide-title">Fix a Tap</h1>

    <!-- === Requirements Section === -->
    <div class="requirements">
        <h3>Requirements</h3>
        <ul>
            <li>Adjustable wrench</li>
            <li>Replacement washer</li>
            <li>Towel</li>
            <li>Bucket</li>
            <li>Plumber's tape (optional)</li>
        </ul>
    </div>

    <!-- === Steps Section === -->
    <div class="steps">
        <!-- DUPLICATE EACH STEP FOR NEW ONES -->
        <div class="step">
            <h3>Step 1: Turn off the water supply</h3>
            <p>Locate the tap's water valve and turn it off before you begin.</p>
            <img src="images/tap_step1.jpg" alt="Turn off water supply">
        </div>

        <div class="step">
            <h3>Step 2: Remove the tap handle</h3>
            <p>Use a wrench to carefully remove the handle without scratching the metal.</p>
            <img src="images/tap_step2.jpg" alt="Remove tap handle">
        </div>

        <div class="step">
            <h3>Step 3: Replace the washer</h3>
            <p>Unscrew the valve and replace the worn washer with a new one.</p>
            <img src="images/tap_step3.jpg" alt="Replace washer">
        </div>

        <div class="step">
            <h3>Step 4: Reassemble and test</h3>
            <p>Reattach all parts, turn the water back on, and test for leaks.</p>
            <img src="images/tap_step4.jpg" alt="Reassemble tap">
        </div>
    </div>

    <a href="${pageContext.request.contextPath}/listguides.jsp" class="back-btn">← Back to Guides</a>
</div>

</body>
</html>