<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Command Terminal Access - Myanmar Wildfire & Cyclone Command</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@500;700&family=Padauk:wght@400;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-deep: #07090e;
            --card-surface: rgba(15, 23, 42, 0.92);
            --border-dim: rgba(255, 255, 255, 0.12);
            --accent-orange: #f97316;
            --accent-orange-hover: #ea580c;
            --text-primary: #ffffff;
            --text-secondary: #cbd5e1;
            --text-muted: #94a3b8;
        }

        /* Clean Radial Glow Background (No Grid Pattern) */
        body {
            background-color: var(--bg-deep);
            background-image:
                radial-gradient(ellipse at 15% 10%, rgba(249, 115, 22, 0.14), transparent 45%),
                radial-gradient(ellipse at 85% 85%, rgba(6, 182, 212, 0.10), transparent 40%);
            font-family: 'Inter', 'Padauk', sans-serif;
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            padding: 20px;
            overflow-x: hidden;
        }

        /* Terminal Auth Card */
        .auth-card {
            background: var(--card-surface);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid var(--border-dim);
            border-radius: 20px;
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.8), 0 0 35px rgba(249, 115, 22, 0.12);
            width: 100%;
            max-width: 450px;
            padding: 36px 32px;
            position: relative;
        }

        /* Ambient Top Accent Bar */
        .auth-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 15%;
            right: 15%;
            height: 2px;
            background: linear-gradient(90deg, transparent, var(--accent-orange), transparent);
        }

        .brand-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            background: rgba(249, 115, 22, 0.15);
            border: 1px solid rgba(249, 115, 22, 0.4);
            border-radius: 30px;
            color: #fb923c;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }

        /* Segmented Tab Switcher */
        .nav-segment {
            background: rgba(7, 10, 18, 0.9);
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-radius: 12px;
            padding: 5px;
            display: flex;
            margin-bottom: 24px;
            gap: 4px;
        }

        .nav-segment button {
            flex: 1;
            background: transparent;
            border: none;
            color: var(--text-secondary);
            padding: 9px 16px;
            font-size: 13.5px;
            font-weight: 700;
            border-radius: 9px;
            transition: all 0.2s ease;
        }

        .nav-segment button.active {
            background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
            color: #05070d;
            box-shadow: 0 4px 15px rgba(249, 115, 22, 0.4);
        }

        .form-label-custom {
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.5px;
            color: var(--text-secondary);
            margin-bottom: 6px;
            display: block;
        }

        /* High-Contrast Inputs */
        .input-group-custom {
            background: #090d16;
            border: 1px solid rgba(255, 255, 255, 0.18);
            border-radius: 10px;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            overflow: hidden;
        }

        .input-group-custom:focus-within {
            border-color: var(--accent-orange);
            box-shadow: 0 0 0 3px rgba(249, 115, 22, 0.3);
        }

        .input-group-custom .input-icon {
            padding: 0 14px;
            color: #fb923c;
            font-size: 14px;
        }

        .input-group-custom input {
            background: transparent;
            border: none;
            color: #ffffff;
            padding: 11px 12px 11px 0;
            font-size: 14px;
            width: 100%;
            outline: none;
        }

        .input-group-custom input::placeholder {
            color: #64748b;
        }

        .toggle-pwd-btn {
            background: transparent;
            border: none;
            color: #94a3b8;
            padding: 0 14px;
            cursor: pointer;
            transition: color 0.2s;
        }

        .toggle-pwd-btn:hover {
            color: var(--accent-orange);
        }

        /* Action Submit Button */
        .btn-action {
            background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
            border: none;
            color: #07090e;
            font-weight: 700;
            font-size: 14px;
            padding: 12px;
            border-radius: 10px;
            width: 100%;
            box-shadow: 0 6px 20px rgba(249, 115, 22, 0.35);
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-top: 8px;
        }

        .btn-action:hover {
            filter: brightness(1.1);
            transform: translateY(-1px);
            box-shadow: 0 8px 24px rgba(249, 115, 22, 0.5);
        }

        /* Telemetry Footer */
        .telemetry-status {
            font-family: 'JetBrains Mono', monospace;
            font-size: 11.5px;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 24px;
            padding-top: 16px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .telemetry-status a {
            color: var(--text-secondary);
            text-decoration: none;
            font-weight: 600;
            transition: color 0.2s;
        }

        .telemetry-status a:hover {
            color: var(--accent-orange);
        }
    </style>
</head>

<body>

    <div class="auth-card">
        <!-- Brand Header -->
        <div class="text-center mb-3">
            <div class="brand-badge">
                <i class="fa-solid fa-satellite-dish"></i> PYROCYCLONE TRACKER
            </div>
            <h4 class="fw-bold text-white mb-1">Myanmar Disaster Terminal</h4>
            <p class="small text-secondary mb-0">Wildfire, Cyclone & Crowdsourced Reporting</p>
        </div>

        <!-- Alert Notifications -->
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger py-2 px-3 small rounded-3 d-flex align-items-center gap-2 mb-3" style="background: rgba(239,68,68,0.2); border: 1px solid #ef4444; color: #fee2e2;">
                <i class="fa-solid fa-circle-exclamation fs-6"></i>
                <span class="fw-semibold">အချက်အလက် မှားယွင်းနေပါသည်။ (Invalid credentials).</span>
            </div>
        <% } %>
        <% if (request.getParameter("registered") != null) { %>
            <div class="alert alert-success py-2 px-3 small rounded-3 d-flex align-items-center gap-2 mb-3" style="background: rgba(16,185,129,0.2); border: 1px solid #10b981; color: #d1fae5;">
                <i class="fa-solid fa-circle-check fs-6"></i>
                <span class="fw-semibold">အကောင့်ဖွင့်ခြင်း အောင်မြင်ပါသည်။ ကျေးဇူးပြု၍ လော့ဂ်အင်ဝင်ပါ။</span>
            </div>
        <% } %>

        <!-- Segmented Tab Switcher -->
        <div class="nav-segment">
            <button type="button" class="active" id="tab-login" onclick="switchAuthTab('login')">
                <i class="fa-solid fa-right-to-bracket me-1"></i> Login
            </button>
            <button type="button" id="tab-register" onclick="switchAuthTab('register')">
                <i class="fa-solid fa-user-plus me-1"></i> Register
            </button>
        </div>

        <!-- 1. Login Form -->
        <form id="form-login" action="login" method="post">
            <div class="mb-3">
                <label class="form-label-custom">USERNAME OR EMAIL</label>
                <div class="input-group-custom">
                    <span class="input-icon"><i class="fa-regular fa-user"></i></span>
                    <input type="text" name="usernameOrEmail" placeholder="Enter username or email" required autocomplete="username">
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label-custom">PASSWORD</label>
                <div class="input-group-custom">
                    <span class="input-icon"><i class="fa-solid fa-lock"></i></span>
                    <input type="password" id="login-pwd" name="password" placeholder="••••••••" required autocomplete="current-password">
                    <button type="button" class="toggle-pwd-btn" onclick="togglePasswordVisibility('login-pwd', this)">
                        <i class="fa-regular fa-eye"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-action">
                <span>Access Command Center</span>
                <i class="fa-solid fa-arrow-right"></i>
            </button>
        </form>

        <!-- 2. Register Form -->
        <form id="form-register" action="signup" method="post" style="display: none;">
            <div class="mb-3">
                <label class="form-label-custom">OPERATOR USERNAME</label>
                <div class="input-group-custom">
                    <span class="input-icon"><i class="fa-regular fa-id-badge"></i></span>
                    <input type="text" name="username" placeholder="Choose a username" required>
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label-custom">EMAIL ADDRESS</label>
                <div class="input-group-custom">
                    <span class="input-icon"><i class="fa-regular fa-envelope"></i></span>
                    <input type="email" name="email" placeholder="operator@command.org" required>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label-custom">SECRET KEY (PASSWORD)</label>
                <div class="input-group-custom">
                    <span class="input-icon"><i class="fa-solid fa-key"></i></span>
                    <input type="password" id="reg-pwd" name="password" placeholder="Minimum 6 characters" required>
                    <button type="button" class="toggle-pwd-btn" onclick="togglePasswordVisibility('reg-pwd', this)">
                        <i class="fa-regular fa-eye"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-action">
                <span>Register Account</span>
                <i class="fa-solid fa-user-check"></i>
            </button>
        </form>

        <!-- Bottom Telemetry Status -->
        <div class="telemetry-status">
            <a href="index.jsp">
                <i class="fa-solid fa-arrow-left me-1"></i> Public Map
            </a>
            <span class="text-secondary">COORDINATES: 21.916°N, 95.956°E</span>
        </div>
    </div>

    <!-- Interactive Tab & Password Visibility Logic -->
    <script>
        function switchAuthTab(tab) {
            const loginBtn = document.getElementById('tab-login');
            const regBtn = document.getElementById('tab-register');
            const loginForm = document.getElementById('form-login');
            const regForm = document.getElementById('form-register');

            if (tab === 'login') {
                loginBtn.classList.add('active');
                regBtn.classList.remove('active');
                loginForm.style.display = 'block';
                regForm.style.display = 'none';
            } else {
                regBtn.classList.add('active');
                loginBtn.classList.remove('active');
                loginForm.style.display = 'none';
                regForm.style.display = 'block';
            }
        }

        function togglePasswordVisibility(inputId, btn) {
            const input = document.getElementById(inputId);
            const icon = btn.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }
    </script>
</body>

</html>