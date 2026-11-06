<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
    <!-- Google Fonts - Inter & Padauk -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Padauk:wght@400;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-main: #05070b;
            --card-bg: rgba(13, 19, 33, 0.75);
            --border-color: rgba(255, 255, 255, 0.07);
            --accent-orange: #f97316;
            --accent-blue: #06b6d4;
        }

        html { scroll-behavior: smooth; }

        body {
            background-color: var(--bg-main);
            background-image:
                radial-gradient(circle at 15% 10%, rgba(249, 115, 22, 0.07) 0%, transparent 45%),
                radial-gradient(circle at 85% 85%, rgba(6, 182, 212, 0.05) 0%, transparent 40%);
            font-family: 'Inter', 'Padauk', sans-serif;
            color: #f1f5f9;
            overflow-x: hidden;
            min-height: 100vh;
        }

        /* Sticky Marquee Banner */
        .sticky-marquee-banner {
            position: sticky;
            top: 0;
            z-index: 1050;
            background: linear-gradient(90deg, #991b1b 0%, #7f1d1d 100%);
            color: #fff;
            padding: 8px 0;
            font-size: 13px;
            font-weight: 500;
            overflow: hidden;
            white-space: nowrap;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
        }
        .sticky-marquee-banner .container-fluid,
        .sticky-marquee-banner .overflow-hidden {
            min-width: 0;
            flex-grow: 1;
        }
        .marquee-content {
            display: inline-block;
            animation: marquee 30s linear infinite;
        }
        .marquee-content span {
            margin-right: 80px;
        }
        @keyframes marquee {
            0% { transform: translateX(100%); }
            100% { transform: translateX(-100%); }
        }

        /* Navbar Modern Styling */
        .navbar {
            background: rgba(13, 19, 33, 0.85) !important;
            backdrop-filter: blur(16px);
            border-bottom: 1px solid var(--border-color);
        }

        /* Glassmorphism Cards with Polished Spacing */
        .modern-card {
            background: var(--card-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--border-color);
            border-radius: 18px;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.45);
            transition: transform 0.25s ease, border-color 0.25s ease, box-shadow 0.25s ease;
        }
        .modern-card:hover {
            transform: translateY(-3px);
            border-color: rgba(249, 115, 22, 0.25);
            box-shadow: 0 18px 45px rgba(0, 0, 0, 0.6);
        }

        .modern-card h6 {
            color: #94a3b8 !important;
            font-weight: 600;
            letter-spacing: 0.5px;
            font-size: 12px;
        }

        /* Pulse Live Badge */
        .pulse-badge {
            display: inline-flex;
            align-items: center;
            padding: 5px 14px;
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.25);
            color: #ef4444;
            border-radius: 50px;
            font-weight: 600;
            font-size: 11.5px;
            letter-spacing: 0.5px;
        }
        .pulse-dot {
            width: 7px; height: 7px;
            background-color: #ef4444;
            border-radius: 50%;
            margin-right: 8px;
            box-shadow: 0 0 10px #ef4444;
            animation: pulse-animation 2s infinite;
        }
        @keyframes pulse-animation {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(239, 68, 68, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
        }

        /* Alert Box List Styling */
        .alert-item {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.04);
            border-left: 4px solid;
            border-radius: 12px;
            padding: 12px 16px;
            margin-bottom: 12px;
            transition: all 0.2s ease;
        }
        .alert-item:hover {
            background: rgba(255, 255, 255, 0.04);
            transform: translateX(2px);
        }
        .alert-item.danger { border-color: #ef4444; }
        .alert-item.info { border-color: #06b6d4; }

        #map {
            height: 500px;
            border-radius: 14px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        /* High Visibility Form Controls */
        .form-control, .form-select, .input-group-text {
            background-color: #090e18 !important;
            color: #f1f5f9 !important;
            border: 1px solid rgba(255, 255, 255, 0.12) !important;
            border-radius: 10px;
            font-size: 13.5px;
            padding: 10px 14px;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.25rem rgba(249, 115, 22, 0.18) !important;
        }
        .form-control::placeholder {
            color: #64748b !important;
        }

        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.12); border-radius: 10px; }
    </style>
</head>

<body>

    <!-- 1. Sticky Marquee Banner -->
    <div class="sticky-marquee-banner">
        <div class="container-fluid px-4 d-flex align-items-center">
            <span class="badge bg-dark text-danger me-3 px-2.5 py-1 fw-bold"><i class="fa-solid fa-bullhorn me-1"></i> LIVE ALERTS</span>
            <div class="overflow-hidden flex-grow-1">
                <div id="marquee-content" class="marquee-content">
                    <span>Checking live disaster updates...</span>
                </div>
            </div>
        </div>
    </div>

    <!-- 2. Navbar -->
    <nav class="navbar navbar-dark px-4 py-3">
        <div class="container-fluid">
            <a class="navbar-brand fw-bold d-flex align-items-center gap-2.5" href="#">
                <span class="p-2.5 rounded-3 text-warning" style="background: rgba(249, 115, 22, 0.12); border: 1px solid rgba(249, 115, 22, 0.25);">
                    <i class="fa-solid fa-fire-flame-curved fs-5"></i>
                </span>
                <span style="letter-spacing: 0.4px; font-size: 17px;">Myanmar Wildfire & Cyclone Command</span>
            </a>
            <div class="d-flex align-items-center gap-3">
                <div class="pulse-badge">
                    <span class="pulse-dot"></span> LIVE MONITOR
                </div>

                <!-- Link to Login / Register Page -->
                <a href="login.jsp" class="btn btn-outline-warning btn-sm rounded-pill px-3.5 py-1.5 fw-semibold shadow-none">
                    <i class="fa-solid fa-right-to-bracket me-1.5"></i> Login
                </a>

                <!-- Report Incident Button -->
                <button class="btn btn-danger btn-sm rounded-pill px-4 py-1.5 fw-semibold shadow-sm" data-bs-toggle="modal" data-bs-target="#reportModal" style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); border: none;">
                    <i class="fa-solid fa-triangle-exclamation me-1.5"></i> Report Case
                </button>
            </div>
        </div>
    </nav>

    <!-- Main Container with Balanced Spacing -->
    <div class="container-fluid py-4 px-4 px-lg-5">

        <!-- 3. Top Stats Cards -->
        <div class="row g-4 mb-4">
            <div class="col-xl-3 col-md-6">
                <div class="modern-card p-4 d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-uppercase mb-1">Total Cases</h6>
                        <h2 class="fw-bold text-danger mb-0" id="stat-total-cases">--</h2>
                    </div>
                    <div class="fs-1 text-danger opacity-25"><i class="fa-solid fa-file-waveform"></i></div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="modern-card p-4 d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-uppercase mb-1">Active Hotspots</h6>
                        <h2 class="fw-bold text-warning mb-0" id="stat-active-hotspots">--</h2>
                    </div>
                    <div class="fs-1 text-warning opacity-25"><i class="fa-solid fa-fire"></i></div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="modern-card p-4 d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-uppercase mb-1">Burned Area (Est.)</h6>
                        <h2 class="fw-bold text-info mb-0"><span id="stat-burned-acres">--</span> <span class="fs-6 fw-normal text-light">Acres</span></h2>
                    </div>
                    <div class="fs-1 text-info opacity-25"><i class="fa-solid fa-chart-area"></i></div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="modern-card p-4 d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-uppercase mb-1">High Risk Regions</h6>
                        <h2 class="fw-bold text-light mb-0" id="stat-high-risk">--</h2>
                    </div>
                    <div class="fs-1 text-light opacity-25"><i class="fa-solid fa-triangle-exclamation"></i></div>
                </div>
            </div>
        </div>

        <!-- 4. Middle Section: Map & Analytics -->
        <div class="row g-4">
            <!-- Map Column -->
            <div class="col-lg-8">
                <div class="modern-card p-4 h-100 d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="mb-0 text-white fw-semibold fs-6">
                            <i class="fa-solid fa-map-location-dot me-2 text-warning"></i> Geospatial Monitoring Map
                        </h5>
                        <span class="badge bg-secondary bg-opacity-15 text-light px-3 py-1.5 rounded-pill small border border-secondary border-opacity-25">Google Roadmap & Overlays</span>
                    </div>
                    <div id="map" class="flex-grow-1"></div>
                </div>
            </div>

            <!-- Right Column: Alerts Box & Analytics Chart -->
            <div class="col-lg-4 d-flex flex-column gap-4">
                <div class="modern-card p-4 flex-grow-1 d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="mb-0 text-white fw-semibold fs-6">
                            <i class="fa-solid fa-bell me-2 text-warning"></i> Affected Regions & Alerts
                        </h5>
                        <span class="badge bg-danger rounded-pill px-2.5 py-1" id="alert-count-badge">0 Active</span>
                    </div>

                    <!-- Filter Controls -->
                    <div class="row g-2 mb-3">
                        <div class="col-4">
                            <select id="filter-category" class="form-select form-select-sm py-2">
                                <option value="all">All Hazards</option>
                                <option value="wildfires">Wildfires</option>
                                <option value="severeStorms">Storms</option>
                            </select>
                        </div>
                        <div class="col-4">
                            <select id="filter-risk" class="form-select form-select-sm py-2">
                                <option value="">All Risks</option>
                                <option value="High Risk">High Risk</option>
                                <option value="Moderate">Moderate</option>
                            </select>
                        </div>
                        <div class="col-4">
                            <input type="text" id="filter-date" class="form-control form-control-sm py-2" placeholder="Search...">
                        </div>
                    </div>

                    <!-- Alerts List Container -->
                    <div class="flex-grow-1 pe-1" id="emergency-alerts-container" style="max-height: 220px; overflow-y: auto;">
                        <p class="text-muted small text-center py-4">Loading affected regions...</p>
                    </div>
                </div>

                <!-- Incident Analytics Chart Box -->
                <div class="modern-card p-4 flex-grow-1 d-flex flex-column">
                    <h5 class="mb-3 text-white fw-semibold fs-6">
                        <i class="fa-solid fa-chart-line me-2 text-warning"></i> Incident Analytics
                    </h5>
                    <div class="flex-grow-1 d-flex align-items-center justify-content-center" style="min-height: 190px;">
                        <canvas id="fireChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- Report Incident Modal -->
    <div class="modal fade" id="reportModal" tabindex="-1" aria-labelledby="reportModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content text-light border border-warning border-opacity-25 shadow-lg" style="background: rgba(10, 15, 27, 0.96) !important; backdrop-filter: blur(25px); border-radius: 20px;">

                <div class="modal-header border-bottom border-secondary border-opacity-25 px-4 py-3.5" style="background: rgba(249, 115, 22, 0.04);">
                    <div class="d-flex align-items-center gap-3">
                        <span class="p-2.5 rounded-3 text-warning" style="background: rgba(249, 115, 22, 0.12); border: 1px solid rgba(249, 115, 22, 0.3);">
                            <i class="fa-solid fa-triangle-exclamation fs-5"></i>
                        </span>
                        <div>
                            <h5 class="modal-title fw-bold text-white mb-0 fs-5">Report Emergency Incident</h5>
                            <p class="small text-muted mb-0 mt-0.5" style="font-size: 12px;">Submit natural disaster hazards immediately to response teams.</p>
                        </div>
                    </div>
                    <button type="button" class="btn-close btn-close-white shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4 p-lg-4.5">
                    <div id="reportFeedback" class="alert d-none mb-4" role="status" aria-live="polite"></div>
                    <form id="incidentReportForm">
                        <div class="row g-3.5">

                            <div class="col-md-6">
                                <label class="form-label small fw-semibold text-light mb-1.5">Incident Category</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-fire-flame-curved text-warning"></i></span>
                                    <select class="form-select shadow-none" id="reportCategory" required>
                                        <option value="Wildfire">🔥 Wildfire</option>
                                        <option value="Cyclone">🌀 Cyclone / Storm Hazard</option>
                                        <option value="Flood">🌊 Flood</option>
                                    </select>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label small fw-semibold text-light mb-1.5">Risk Level</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-gauge-high text-danger"></i></span>
                                    <select class="form-select shadow-none" id="reportRisk" required>
                                        <option value="High Risk">🔴 High Risk (Emergency)</option>
                                        <option value="Moderate">🟡 Moderate</option>
                                        <option value="Advisory">🔵 Advisory</option>
                                    </select>
                                </div>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label small fw-semibold text-light mb-1.5">Incident Title</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-heading text-info"></i></span>
                                    <input type="text" class="form-control shadow-none" id="reportTitle" placeholder="Example: Forest fire outbreak in eastern Pyin Oo Lwin township" required>
                                </div>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label small fw-semibold text-light mb-1.5">Township / Region</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-map-pin text-success"></i></span>
                                    <input type="text" class="form-control shadow-none" id="reportTownship" placeholder="Example: Pyin Oo Lwin" required>
                                </div>
                            </div>

                            <!-- GPS Coordinates Box -->
                            <div class="col-md-12">
                                <div class="p-3.5 rounded-3" style="background: rgba(255, 255, 255, 0.02); border: 1px dashed rgba(249, 115, 22, 0.35);">
                                    <div class="d-flex justify-content-between align-items-center mb-2.5">
                                        <label class="form-label small mb-0 fw-semibold text-light">
                                            <i class="fa-solid fa-location-crosshairs text-info me-1.5"></i> GPS Coordinates
                                        </label>
                                        <button type="button" class="btn btn-outline-warning btn-sm rounded-pill px-3 fw-semibold shadow-sm" id="btnGetLocation" style="font-size: 12px;">
                                            <i class="fa-solid fa-location-arrow me-1"></i> Get Current Location
                                        </button>
                                    </div>
                                    <div class="row g-2">
                                        <div class="col-6">
                                            <div class="input-group input-group-sm">
                                                <span class="input-group-text text-muted">Lat</span>
                                                <input type="number" step="any" class="form-control shadow-none" id="reportLat" placeholder="Latitude" required>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="input-group input-group-sm">
                                                <span class="input-group-text text-muted">Lng</span>
                                                <input type="number" step="any" class="form-control shadow-none" id="reportLng" placeholder="Longitude" required>
                                            </div>
                                        </div>
                                    </div>
                                    <div id="locationStatus" class="form-text small mt-2 d-none"></div>
                                </div>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label small fw-semibold text-light mb-1.5">Description</label>
                                <div class="input-group">
                                    <span class="input-group-text align-items-start pt-2.5"><i class="fa-solid fa-align-left text-warning"></i></span>
                                    <textarea class="form-control shadow-none" id="reportDesc" rows="3" placeholder="Provide details about the current situation, wind speed, or surrounding environment..." required></textarea>
                                </div>
                            </div>
                        </div>

                        <div class="d-grid mt-4 pt-1">
                            <button type="submit" class="btn btn-warning fw-bold text-dark py-3 rounded-3 shadow-lg" style="background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); border: none; font-size: 14.5px;">
                                <i class="fa-solid fa-paper-plane me-2"></i> Submit Incident Report
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- JS Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <!-- Unified Dashboard Script -->
    <script src="js/dashboard.js"></script>
</body>

</html>