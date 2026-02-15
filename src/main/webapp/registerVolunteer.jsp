<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Volunteer Signup - Daily Fixer</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
            <style>
                body {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    min-height: 100vh;
                    background-color: var(--background);
                    padding: 40px 20px;
                }

                .register-container {
                    width: 100%;
                    max-width: 600px;
                }

                .form-container {
                    margin: 0 auto;
                }

                .page-header {
                    text-align: center;
                    margin-bottom: 30px;
                }

                .page-header h2 {
                    font-size: 2rem;
                    color: var(--primary);
                    margin-bottom: 10px;
                }

                .error-text {
                    color: var(--destructive);
                    font-size: 0.85rem;
                    margin-top: 5px;
                    font-weight: 500;
                }

                .server-error {
                    background-color: var(--destructive);
                    color: white;
                    padding: 15px;
                    border-radius: var(--radius-md);
                    margin-bottom: 20px;
                    font-weight: 500;
                }

                .form-cols {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 16px;
                }

                .login-link {
                    text-align: center;
                    margin-top: 20px;
                    color: var(--muted-foreground);
                }

                .login-link a {
                    color: var(--primary);
                    font-weight: 600;
                    text-decoration: none;
                }

                .login-link a:hover {
                    text-decoration: underline;
                }

                .checkbox-group {
                    display: flex;
                    align-items: flex-start;
                    gap: 10px;
                    margin-bottom: 20px;
                }

                .checkbox-group input[type="checkbox"] {
                    margin-top: 4px;
                    width: 18px;
                    height: 18px;
                    accent-color: var(--primary);
                }

                .checkbox-group label {
                    font-size: 0.9rem;
                    color: var(--muted-foreground);
                    margin: 0;
                }

                @media (max-width: 600px) {
                    .form-cols {
                        grid-template-columns: 1fr;
                        gap: 0;
                    }
                }
            </style>
        </head>

        <body>

            <div class="register-container">
                <div class="form-container">
                    <div class="page-header">
                        <h2>Volunteer Signup</h2>
                        <p style="color: var(--muted-foreground)">Join DailyFixer as a Volunteer Writer</p>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="server-error">${error}</div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/registerVolunteer" method="post" id="registerForm">
                        <div class="form-cols">
                            <div class="form-group">
                                <label for="firstName">First Name</label>
                                <input type="text" id="firstName" name="firstName" placeholder="First Name" required>
                            </div>
                            <div class="form-group">
                                <label for="lastName">Last Name</label>
                                <input type="text" id="lastName" name="lastName" placeholder="Last Name" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="username">Username</label>
                            <input type="text" id="username" name="username" placeholder="Username" required>
                        </div>

                        <div class="form-cols">
                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" placeholder="Email" required>
                            </div>
                            <div class="form-group">
                                <label for="password">Password</label>
                                <input type="password" id="password" name="password" placeholder="Password" required>
                            </div>
                        </div>

                        <div class="form-cols">
                            <div class="form-group">
                                <label for="phone">Phone Number</label>
                                <input type="text" id="phone" name="phone" placeholder="Phone Number">
                            </div>
                            <div class="form-group">
                                <label for="city">City</label>
                                <select id="city" name="city" class="filter-select" style="width: 100%;" required>
                                    <option value="">Select City</option>
                                    <option>Colombo</option>
                                    <option>Kandy</option>
                                    <option>Galle</option>
                                    <option>Matara</option>
                                    <option>Kurunegala</option>
                                    <option>Negombo</option>
                                    <option>Jaffna</option>
                                    <option>Anuradhapura</option>
                                    <option>Trincomalee</option>
                                    <option>Batticaloa</option>
                                    <option>Badulla</option>
                                    <option>Rathnapura</option>
                                    <option>Kalutara</option>
                                    <option>Hambantota</option>
                                    <option>Polonnaruwa</option>
                                    <option>Ampara</option>
                                    <option>Vavuniya</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="expertise">Expertise</label>
                            <input type="text" id="expertise" name="expertise"
                                placeholder="e.g., Electronics, Plumbing, Carpentry" required>
                        </div>

                        <div class="checkbox-group">
                            <input type="checkbox" id="agreement" name="agreement">
                            <label for="agreement">I confirm I will not misuse the platform or upload false
                                material.</label>
                        </div>

                        <div id="errorMsg" class="error-text" style="margin-bottom: 15px; text-align: center;"></div>

                        <button type="submit" class="btn-primary" style="width: 100%;">Register</button>
                    </form>
                    <p class="login-link">Already have an account? <a
                            href="${pageContext.request.contextPath}/login.jsp">Login</a></p>
                </div>
            </div>

            <script>
                document.getElementById('registerForm').addEventListener('submit', function (e) {
                    let username = document.getElementById("username").value.trim();
                    let email = document.getElementById("email").value.trim();
                    let password = document.getElementById("password").value.trim();
                    let agreement = document.getElementById("agreement").checked;

                    let errorDiv = document.getElementById("errorMsg");
                    errorDiv.innerHTML = "";

                    if (username === "" || email === "" || password === "") {
                        errorDiv.innerHTML = "All fields are required.";
                        e.preventDefault();
                        return;
                    }
                    if (!agreement) {
                        errorDiv.innerHTML = "You must agree to the terms before proceeding.";
                        e.preventDefault();
                        return;
                    }
                });
            </script>
            <script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>
        </body>

        </html>