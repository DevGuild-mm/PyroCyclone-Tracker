<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login & Register - Myanmar Wildfire & Cyclone Command</title>

    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts - Inter & Padauk -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Padauk:wght@400;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-main: #07090e;
            --card-bg: rgba(15, 23, 42, 0.85);
            --border-color: rgba(255, 255, 255, 0.08);
            --accent-orange: #f97316;
        }

        body {
            background-color: var(--bg-main);
            background-image:
                radial-gradient(ellipse at 15% 10%, rgba(249,115,22,.12), transparent 45%),
                radial-gradient(ellipse at 85% 85%, rgba(6,182,212,.08), transparent 40%);
            font-family: 'Inter', 'Padauk', sans-serif;
            color: #f8fafc;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow-x: hidden;
            margin: 0;
        }

        .auth-card {
            background: var(--card-bg);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(249, 115, 22, 0.2);
            border-radius: 20px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6);
            width: 100%;
            max-width: 440px;
            padding: 35px;
        }

        .auth-logo {
            width: 50px; height: 50px;
            background: rgba(249, 115, 22, 0.15);
            border: 1px solid rgba(249, 115, 22, 0.3);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--accent-orange);
            font-size: 22px;
            margin: 0 auto 15px auto;
        }

        .nav-pills {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 4px;
        }
        .nav-pills .nav-link {
            color: #94a3b8;
            font-weight: 600;
            font-size: 14px;
            border-radius: 10px;
            transition: all 0.2s ease;
        }
        .nav-pills .nav-link.active {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: #07090e;
            box-shadow: 0 4px 15px rgba(249, 115, 22, 0.3);
        }

        .form-control, .input-group-text {
            background-color: #0b101d !important;
            color: #f8fafc !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            border-radius: 10px;
            font-size: 14px;
        }
        .form-control:focus {
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.2rem rgba(249, 115, 22, 0.25) !important;
        }
        .form-control::placeholder {
            color: #64748b !important;
        }

        .btn-auth-submit {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            border: none;
            color: #07090e;
            font-weight: 700;
            padding: 10px;
            border-radius: 10px;
            box-shadow: 0 8px 20px rgba(249, 115, 22, 0.3);
            transition: filter 0.2s ease, transform 0.2s ease;
        }
        .btn-auth-submit:hover {
            filter: brightness(1.1);
            transform: translateY(-1px);
        }

        .back-link {
            color: #94a3b8;
            text-decoration: none;
            font-size: 13px;
            transition: color 0.2s;
        }
        .back-link:hover {
            color: var(--accent-orange);
        }
    </style>
</head>

<body>

    <div class="auth-card">
        <!-- Logo & Header -->
        <div class="text-center mb-4">
            <div class="auth-logo">
                <i class="fa-solid fa-fire-flame-curved"></i>
            </div>
            <h4 class="fw-bold text-white mb-1">Command Center</h4>
            <p class="small text-muted mb-0">Natural Disaster Information Management System</p>
        </div>

        <!-- Feedback Alerts via URL Parameters -->
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger py-2 px-3 small mb-3" role="alert">
                ⚠️ Invalid login credentials or registration failed. Please try again.
            </div>
        <% } %>
        <% if (request.getParameter("registered") != null) { %>
            <div class="alert alert-success py-2 px-3 small mb-3" role="alert">
                ✅ Registration successful! Please log in below.
            </div>
        <% } %>

        <!-- Tab Navigation (Login vs Signup) -->
        <ul class="nav nav-pills nav-fill mb-4" id="authTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="login-tab" data-bs-toggle="pill" data-bs-target="#loginPane" type="button" role="tab">Login</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="signup-tab" data-bs-toggle="pill" data-bs-target="#signupPane" type="button" role="tab">Register</button>
            </li>
        </ul>

        <!-- Tab Contents -->
        <div class="tab-content" id="authTabContent">

            <!-- 1. LOGIN PANE (Submits to LoginServlet via POST /login) -->
            <div class="tab-pane fade show active" id="loginPane" role="tabpanel">
                <form action="login" method="post">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-light mb-1">Username or Email</label>
                        <div class="input-group">
                            <span class="input-group-text bg-dark text-warning border-secondary"><i class="fa-solid fa-user"></i></span>
                            <input type="text" class="form-control shadow-none" name="usernameOrEmail" placeholder="Username or Email" required>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label small fw-semibold text-light mb-1">Password</label>
                        <div class="input-group">
                            <span class="input-group-text bg-dark text-warning border-secondary"><i class="fa-solid fa-lock"></i></span>
                            <input type="password" class="form-control shadow-none" name="password" placeholder="••••••••" required>
                        </div>
                    </div>

                    <div class="d-grid">
                        <button type="submit" class="btn btn-auth-submit">
                            <i class="fa-solid fa-right-to-bracket me-2"></i> Login
                        </button>
                    </div>
                </form>
            </div>

            <!-- 2. SIGN UP PANE (Submits to SignupServlet via POST /signup) -->
            <div class="tab-pane fade" id="signupPane" role="tabpanel">
                <form action="signup" method="post">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-light mb-1">Username</label>
                        <div class="input-group">
                            <span class="input-group-text bg-dark text-warning border-secondary"><i class="fa-solid fa-user"></i></span>
                            <input type="text" class="form-control shadow-none" name="username" placeholder="Username" required>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-light mb-1">Email</label>
                        <div class="input-group">
                            <span class="input-group-text bg-dark text-warning border-secondary"><i class="fa-solid fa-envelope"></i></span>
                            <input type="email" class="form-control shadow-none" name="email" placeholder="name@example.com" required>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label small fw-semibold text-light mb-1">Password</label>
                        <div class="input-group">
                            <span class="input-group-text bg-dark text-warning border-secondary"><i class="fa-solid fa-lock"></i></span>
                            <input type="password" class="form-control shadow-none" name="password" placeholder="••••••••" required>
                        </div>
                    </div>

                    <div class="d-grid">
                        <button type="submit" class="btn btn-auth-submit">
                            <i class="fa-solid fa-user-plus me-2"></i> Register
                        </button>
                    </div>
                </form>
            </div>

        </div>

        <!-- Footer Back Link -->
        <div class="text-center mt-4 pt-2 border-top border-secondary border-opacity-25">
            <a href="index.jsp" class="back-link">
                <i class="fa-solid fa-arrow-left me-1"></i> Back to Dashboard
            </a>
        </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>