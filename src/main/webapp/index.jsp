<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("currentUser");
    boolean loggedIn = (sessionUser != null);
    String username = loggedIn ? sessionUser.getUsername() : "";
    boolean isAdmin = loggedIn && "admin".equalsIgnoreCase(sessionUser.getRole());
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Myanmar Wildfire & Cyclone Command Dashboard</title>

    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Leaflet CSS CDN -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <!-- FontAwesome Icons CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts - Inter, JetBrains Mono & Padauk -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@500;700&family=Padauk:wght@400;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-main: #07090e;
            --nav-bg: #0c1220;
            --card-bg: rgba(15, 23, 42, 0.90);
            --border-dim: rgba(255, 255, 255, 0.12);
            --accent-orange: #f97316;
            --accent-blue: #06b6d4;
            --accent-green: #10b981;
            --accent-red: #ef4444;
            --text-main: #ffffff;
            --text-sub: #cbd5e1;
            --text-muted: #94a3b8;
        }

        body {
            background-color: var(--bg-main);
            background-image:
                radial-gradient(ellipse at 15% 10%, rgba(249, 115, 22, 0.14), transparent 45%),
                radial-gradient(ellipse at 85% 85%, rgba(6, 182, 212, 0.09), transparent 40%);
            font-family: 'Inter', 'Padauk', sans-serif;
            color: var(--text-main);
            min-height: 100vh;
        }

        .navbar-command {
            background-color: var(--nav-bg);
            border-bottom: 1px solid var(--border-dim);
            padding: 10px 24px;
        }

        .brand-logo-box {
            width: 38px; height: 38px;
            background: rgba(249, 115, 22, 0.15);
            border: 1px solid rgba(249, 115, 22, 0.4);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: var(--accent-orange); font-size: 18px;
        }

        .nav-switch-link {
            color: var(--text-sub); text-decoration: none;
            font-size: 13.5px; font-weight: 600; padding: 7px 16px;
            border-radius: 8px; border: 1px solid transparent;
            transition: all 0.2s ease; display: inline-flex; align-items: center;
        }
        .nav-switch-link.active {
            color: var(--accent-orange);
            background: rgba(249, 115, 22, 0.15);
            border-color: rgba(249, 115, 22, 0.35);
            font-weight: 700;
        }

        .pulse-badge {
            display: inline-flex; align-items: center;
            padding: 5px 12px; background: rgba(239, 68, 68, 0.18);
            border: 1px solid rgba(239, 68, 68, 0.4);
            color: #fca5a5; border-radius: 50px; font-weight: 700; font-size: 11px;
        }
        .pulse-dot {
            width: 7px; height: 7px; background-color: #ef4444; border-radius: 50%;
            margin-right: 7px; box-shadow: 0 0 10px #ef4444; animation: pulse-animation 2s infinite;
        }
        @keyframes pulse-animation {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(239, 68, 68, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
        }

        .user-identity-box {
            background: rgba(15, 23, 42, 0.8);
            border: 1px solid var(--border-dim); border-radius: 30px;
            padding: 4px 14px 4px 6px; display: flex; align-items: center; gap: 8px; font-size: 13px;
        }
        .role-badge { font-size: 10px; font-weight: 700; padding: 2px 7px; border-radius: 12px; font-family: 'JetBrains Mono', monospace; }
        .role-admin { background: #0284c7; color: #ffffff; }
        .role-user { background: #334155; color: #e2e8f0; }

        .subnav-marquee-banner {
            background: linear-gradient(90deg, #18090b 0%, #2d0d0f 50%, #18090b 100%);
            border-bottom: 1px solid rgba(239, 68, 68, 0.35);
            padding: 7px 0; font-size: 13px; font-weight: 600; color: #ffffff;
        }
        .marquee-tag {
            background: #991b1b; color: #ffffff; font-size: 11px; font-weight: 700;
            padding: 2px 10px; border-radius: 6px; margin-right: 14px; white-space: nowrap;
        }
        .marquee-content { display: inline-block; white-space: nowrap; animation: marquee 35s linear infinite; }
        @keyframes marquee { 0% { transform: translateX(100%); } 100% { transform: translateX(-100%); } }

        .modern-card {
            background: var(--card-bg); backdrop-filter: blur(18px);
            border: 1px solid var(--border-dim); border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.55);
        }
        .card-stat-label { font-size: 11.5px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; margin-bottom: 4px; }
        .card-stat-val { font-family: 'JetBrains Mono', monospace; font-size: 28px; font-weight: 700; line-height: 1.1; }

        #map { height: 490px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.1); cursor: crosshair; }

        .alert-item {
            padding: 12px; border-radius: 10px; background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08); border-left: 4px solid var(--accent-red);
            margin-bottom: 8px; cursor: pointer; transition: all 0.2s ease;
        }
        .alert-item.info { border-left-color: var(--accent-blue); }
        .alert-item.success { border-left-color: var(--accent-green); }

        .region-select-dropdown {
            background-color: #0b1220 !important;
            color: #f8fafc !important;
            border: 1px solid rgba(249, 115, 22, 0.5) !important;
            border-radius: 8px;
            font-size: 12.5px;
            font-weight: 600;
            padding: 5px 12px;
            max-width: 250px;
        }

        .dark-modal { background-color: #0c1222; color: #ffffff; border: 1px solid rgba(249, 115, 22, 0.4); border-radius: 18px; }
        .dark-modal .form-control, .dark-modal .form-select { background-color: #080c16 !important; color: #ffffff !important; border: 1px solid rgba(255, 255, 255, 0.18) !important; }
        select option { background-color: #0f172a !important; color: #ffffff !important; }
    </style>
</head>

<body>

    <script>
        const isLoggedIn = <%= loggedIn %>;
        const currentUsername = "<%= username %>";
    </script>

    <!-- Top Navigation -->
    <nav class="navbar navbar-command sticky-top shadow-sm">
        <div class="container-fluid px-0">
            <a class="navbar-brand d-flex align-items-center gap-2.5 text-white fw-bold me-4" href="index.jsp">
                <div class="brand-logo-box"><i class="fa-solid fa-fire-flame-curved"></i></div>
                <div>
                    <div style="line-height: 1.1; font-size: 15px;">MYANMAR DISASTER COMMAND</div>
                    <small class="text-warning fw-semibold" style="font-size: 10.5px;">Wildfire & Cyclone Early Warning</small>
                </div>
            </a>

            <div class="d-none d-md-flex align-items-center gap-2 me-auto">
                <a href="index.jsp" class="nav-switch-link active"><i class="fa-solid fa-map-location-dot me-1.5"></i> Live Map</a>
                <% if (isAdmin) { %>
                    <a href="admin.jsp" class="nav-switch-link"><i class="fa-solid fa-shield-halved me-1.5"></i> Moderation Console</a>
                <% } %>
            </div>

            <div class="d-flex align-items-center gap-2.5">
                <button type="button" class="btn btn-warning btn-sm rounded-pill px-3 py-1.5 fw-bold shadow-sm d-flex align-items-center gap-1.5" onclick="openReportModal()">
                    <i class="fa-solid fa-bullhorn"></i> <span>သတင်းပို့မည် (Report)</span>
                </button>
                <div class="pulse-badge"><span class="pulse-dot"></span> LIVE SENSORS</div>

                <% if (loggedIn) { %>
                    <div class="user-identity-box">
                        <i class="fa-solid <%= isAdmin ? "fa-user-shield text-info" : "fa-user text-warning" %> ms-1"></i>
                        <span class="fw-semibold text-white"><%= username %></span>
                        <span class="role-badge <%= isAdmin ? "role-admin" : "role-user" %>"><%= sessionUser.getRole().toUpperCase() %></span>
                    </div>
                    <a href="logout" class="btn btn-outline-danger btn-sm rounded-pill px-3 py-1 fw-bold shadow-none">
                        <i class="fa-solid fa-right-from-bracket me-1"></i> Logout
                    </a>
                <% } else { %>
                    <a href="login.jsp" class="btn btn-outline-warning btn-sm rounded-pill px-3.5 py-1.5 fw-bold shadow-none">
                        <i class="fa-solid fa-right-to-bracket me-1.5"></i> Login
                    </a>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- Subnav Marquee -->
    <div class="subnav-marquee-banner shadow-sm">
        <div class="container-fluid d-flex align-items-center px-4">
            <span class="marquee-tag"><i class="fa-solid fa-satellite-dish me-1"></i> LIVE TELEMETRY</span>
            <div class="overflow-hidden flex-grow-1">
                <div id="marquee-content" class="marquee-content">
                    <span>မြန်မာနိုင်ငံ သဘာဝဘေး အချက်အလက်များကို ရှာဖွေနေသည်...</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Container -->
    <div class="container-fluid py-4 px-4">
        <!-- Top Stats Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="modern-card p-3 d-flex justify-content-between align-items-center">
                    <div>
                        <div class="card-stat-label">Total Incidents</div>
                        <div class="card-stat-val text-danger" id="stat-total-cases">--</div>
                    </div>
                    <div class="fs-1 text-danger opacity-50"><i class="fa-solid fa-file-waveform"></i></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="modern-card p-3 d-flex justify-content-between align-items-center">
                    <div>
                        <div class="card-stat-label">Active Hotspots</div>
                        <div class="card-stat-val text-warning" id="stat-active-hotspots">--</div>
                    </div>
                    <div class="fs-1 text-warning opacity-50"><i class="fa-solid fa-fire"></i></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="modern-card p-3 d-flex justify-content-between align-items-center">
                    <div>
                        <div class="card-stat-label">Community Reports</div>
                        <div class="card-stat-val text-success" id="stat-community-reports">0 Verified</div>
                    </div>
                    <div class="fs-1 text-success opacity-50"><i class="fa-solid fa-users"></i></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="modern-card p-3 d-flex justify-content-between align-items-center">
                    <div>
                        <div class="card-stat-label">High Risk Hazards</div>
                        <div class="card-stat-val text-info" id="stat-high-risk">--</div>
                    </div>
                    <div class="fs-1 text-info opacity-50"><i class="fa-solid fa-triangle-exclamation"></i></div>
                </div>
            </div>
        </div>

        <!-- Map & Alerts -->
        <div class="row g-4">
            <div class="col-lg-8">
                <div class="modern-card p-3 h-100 d-flex flex-column">
                    <div class="d-flex flex-wrap justify-content-between align-items-center mb-2 px-1 gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <h5 class="mb-0 text-white fw-bold"><i class="fa-solid fa-map-location-dot me-2 text-warning"></i> Geospatial Monitoring Map</h5>
                        </div>

                        <!-- 15 States and Regions Selector -->
                        <div class="d-flex align-items-center gap-2">
                            <label class="small text-warning fw-bold d-none d-sm-inline" style="font-size: 11px;">တိုင်း/ပြည်နယ်:</label>
                            <select id="region-jump-select" class="form-select form-select-sm region-select-dropdown" onchange="window.onRegionSelectChange(this.value)">
                                <option value="all">🇲🇲 တစ်နိုင်ငံလုံး (All Myanmar)</option>
                                <option value="kachin">ကချင်ပြည်နယ် (Kachin)</option>
                                <option value="kayah">ကယားပြည်နယ် (Kayah)</option>
                                <option value="kayin">ကရင်ပြည်နယ် (Kayin)</option>
                                <option value="chin">ချင်းပြည်နယ် (Chin)</option>
                                <option value="sagaing">စစ်ကိုင်းတိုင်း (Sagaing)</option>
                                <option value="tanintharyi">တနင်္သာရီတိုင်း (Tanintharyi)</option>
                                <option value="bago">ပဲခူးတိုင်း (Bago)</option>
                                <option value="magway">မကွေးတိုင်း (Magway)</option>
                                <option value="mandalay">မန္တလေးတိုင်း (Mandalay)</option>
                                <option value="mon">မွန်ပြည်နယ် (Mon)</option>
                                <option value="rakhine">ရခိုင်ပြည်နယ် (Rakhine)</option>
                                <option value="yangon">ရန်ကုန်တိုင်း (Yangon)</option>
                                <option value="shan">ရှမ်းပြည်နယ် (Shan)</option>
                                <option value="ayeyarwady">ဧရာဝတီတိုင်း (Ayeyarwady)</option>
                                <option value="naypyidaw">နေပြည်တော် (Naypyidaw)</option>
                            </select>
                        </div>
                    </div>

                    <div id="map" class="flex-grow-1 mt-2"></div>
                </div>
            </div>

            <!-- Warning Feed -->
            <div class="col-lg-4 d-flex flex-column gap-3">
                <div class="modern-card p-3 flex-grow-1 d-flex flex-column" style="min-height: 290px;">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h6 class="mb-0 text-white fw-bold"><i class="fa-solid fa-bell me-1.5 text-warning"></i> Active Warnings Feed</h6>
                        <span class="badge bg-danger rounded-pill font-monospace" id="alert-count-badge">0 Active</span>
                    </div>

                    <div class="row g-2 mb-2">
                        <div class="col-4">
                            <select id="filter-category" class="form-select form-select-sm bg-dark text-light border-secondary">
                                <option value="all">All Hazards</option>
                                <option value="wildfires">Wildfires</option>
                                <option value="severeStorms">Storms</option>
                                <option value="floods">Floods</option>
                            </select>
                        </div>
                        <div class="col-4">
                            <select id="filter-risk" class="form-select form-select-sm bg-dark text-light border-secondary">
                                <option value="">All Risks</option>
                                <option value="High Risk">High Risk</option>
                                <option value="Moderate">Moderate</option>
                                <option value="Advisory">Advisory</option>
                            </select>
                        </div>
                        <div class="col-4">
                            <input type="text" id="filter-date" class="form-control form-control-sm bg-dark text-light border-secondary" placeholder="Search...">
                        </div>
                    </div>

                    <div class="flex-grow-1 pe-1" id="emergency-alerts-container" style="max-height: 210px; overflow-y: auto;">
                        <p class="text-sub small text-center py-4">Loading active alerts...</p>
                    </div>
                </div>

                <div class="modern-card p-3">
                    <h6 class="mb-2 text-white fw-bold"><i class="fa-solid fa-chart-line me-1.5 text-warning"></i> Incident Frequency (30 Days)</h6>
                    <div style="height: 155px;">
                        <canvas id="fireChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Report Modal -->
    <div class="modal fade" id="reportHazardModal" tabindex="-1" aria-labelledby="reportHazardModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content dark-modal">
                <div class="modal-header border-secondary border-opacity-25 pb-2">
                    <h5 class="modal-title fw-bold text-warning" id="reportHazardModalLabel">
                        <i class="fa-solid fa-triangle-exclamation me-1"></i> သဘာဝဘေး သတင်းပေးပို့ရန် (Hazard Report)
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="reportHazardForm" onsubmit="submitHazardReport(event)">
                    <div class="modal-body py-3">
                        <div class="mb-3">
                            <label class="form-label">ခေါင်းစဉ် / မြို့နယ် *</label>
                            <input type="text" id="field-title" class="form-control" required placeholder="ဥပမာ - မုံရွာ တောမီးလောင်မှု">
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label">အမျိုးအစား *</label>
                                <select id="field-category" class="form-select" required>
                                    <option value="wildfires">🔥 တောမီး (Wildfires)</option>
                                    <option value="severeStorms">🌀 မုန်တိုင်း (Storms)</option>
                                    <option value="floods">🌊 ရေကြီးရေလျှံမှု (Floods)</option>
                                </select>
                            </div>
                            <div class="col-6">
                                <label class="form-label">အန္တရာယ်အဆင့် *</label>
                                <select id="field-risk" class="form-select" required>
                                    <option value="High Risk">အလွန်ပြင်းထန် (High Risk)</option>
                                    <option value="Moderate">အလယ်အလတ် (Moderate)</option>
                                    <option value="Advisory">သတိပေးချက် (Advisory)</option>
                                </select>
                            </div>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label">လတ္တီတွဒ် *</label>
                                <input type="number" step="any" id="field-lat" class="form-control font-monospace" required readonly>
                            </div>
                            <div class="col-6">
                                <label class="form-label">လောင်ဂျီတွဒ် *</label>
                                <input type="number" step="any" id="field-lng" class="form-control font-monospace" required readonly>
                            </div>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label">ဖြစ်ပွားချိန်</label>
                                <input type="datetime-local" id="field-time" class="form-control">
                            </div>
                            <div class="col-6">
                                <label class="form-label">သတင်းပေးပို့သူ</label>
                                <input type="text" id="field-reporter" class="form-control" placeholder="Anonymous Operator">
                            </div>
                        </div>

                        <div class="mb-1">
                            <label class="form-label">အသေးစိတ် အခြေအနေ</label>
                            <textarea id="field-description" rows="3" class="form-control" placeholder="ဒေသခံများ ဘေးကင်းရာသို့ ရွှေ့ပြောင်းနေရပါသည်..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-secondary border-opacity-25 pt-2">
                        <button type="button" class="btn btn-secondary btn-sm rounded-pill px-3" data-bs-dismiss="modal">ပယ်ဖျက်မည်</button>
                        <button type="submit" id="btn-submit-report" class="btn btn-warning btn-sm rounded-pill px-4 fw-bold">
                            <i class="fa-solid fa-paper-plane me-1"></i> အတည်ပြုပေးပို့မည်
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <!-- Cache-busting script tag -->
    <script src="js/dashboard.js?v=3"></script>

</html>