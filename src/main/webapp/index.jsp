<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Myanmar Wildfire & Cyclone Tracker Dashboard</title>

    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Leaflet CSS CDN -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <!-- FontAwesome Icons CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts - Inter + Noto Sans Myanmar -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Noto+Sans+Myanmar:wght@400;500;600&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-main: #060810;
            --bg-grad-1: rgba(249, 115, 22, 0.10);
            --bg-grad-2: rgba(99, 102, 241, 0.10);
            --surface: rgba(17, 24, 39, 0.65);
            --surface-solid: #0e1423;
            --surface-hover: rgba(255, 255, 255, 0.04);
            --border-color: rgba(255, 255, 255, 0.07);
            --border-strong: rgba(255, 255, 255, 0.14);
            --text-main: #f1f5f9;
            --text-dim: #94a3b8;
            --accent: #f97316;
            --accent-2: #fb923c;
            --danger: #f43f5e;
            --warning: #fbbf24;
            --info: #22d3ee;
            --radius: 20px;
        }

        * { box-sizing: border-box; }

        body {
            background-color: var(--bg-main);
            background-image:
                radial-gradient(900px 500px at 8% -10%, var(--bg-grad-1), transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2), transparent 60%);
            background-attachment: fixed;
            font-family: 'Inter', 'Noto Sans Myanmar', sans-serif;
            color: var(--text-main);
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
        }

        /* ---------- Sticky + Marquee Banner ---------- */
        .sticky-marquee-banner {
            position: sticky;
            top: 0;
            z-index: 1050;
            background: linear-gradient(90deg, rgba(190, 18, 60, 0.95) 0%, rgba(127, 29, 29, 0.95) 100%);
            backdrop-filter: blur(10px);
            color: #fff;
            padding: 9px 0;
            font-size: 13px;
            font-weight: 500;
            overflow: hidden;
            white-space: nowrap;
            border-bottom: 1px solid rgba(255, 255, 255, 0.12);
            box-shadow: 0 6px 24px rgba(0, 0, 0, 0.45);
        }
        .sticky-marquee-banner .badge {
            background: rgba(0, 0, 0, 0.35) !important;
            color: #fecdd3 !important;
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 999px;
            letter-spacing: .06em;
            font-size: 11px;
        }
        .marquee-content {
            display: inline-block;
            animation: marquee 25s linear infinite;
        }
        .marquee-content:hover { animation-play-state: paused; }
        .marquee-content span { margin-right: 80px; }
        @keyframes marquee {
            0% { transform: translateX(100%); }
            100% { transform: translateX(-100%); }
        }

        /* ---------- Navbar ---------- */
        .app-nav {
            background: rgba(10, 14, 24, 0.7) !important;
            backdrop-filter: blur(14px);
            border-bottom: 1px solid var(--border-color);
        }
        .brand-icon {
            width: 40px; height: 40px;
            display: grid; place-items: center;
            border-radius: 12px;
            background: linear-gradient(135deg, #f97316, #ef4444);
            color: #fff;
            box-shadow: 0 6px 18px rgba(249, 115, 22, 0.35);
        }
        .brand-title { font-weight: 700; letter-spacing: -0.01em; line-height: 1.1; }
        .brand-sub { font-size: 11px; color: var(--text-dim); font-weight: 400; }

        /* ---------- Cards ---------- */
        .modern-card {
            background: var(--surface);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            box-shadow: 0 1px 0 rgba(255,255,255,0.04) inset, 0 20px 40px -20px rgba(0, 0, 0, 0.7);
            transition: transform .25s ease, border-color .25s ease;
        }
        .modern-card:hover { border-color: var(--border-strong); }

        .modern-card h6 {
            color: var(--text-dim) !important;
            font-weight: 600;
            letter-spacing: .08em;
            font-size: 11px;
        }

        /* Stat cards */
        .stat-card { position: relative; overflow: hidden; }
        .stat-card::before {
            content: '';
            position: absolute; inset: 0 0 auto 0; height: 2px;
            background: linear-gradient(90deg, transparent, var(--stat-color, var(--accent)), transparent);
            opacity: .9;
        }
        .stat-card::after {
            content: '';
            position: absolute; right: -40px; top: -40px;
            width: 140px; height: 140px; border-radius: 50%;
            background: radial-gradient(circle, var(--stat-color, var(--accent)), transparent 70%);
            opacity: .12;
            pointer-events: none;
        }
        .stat-card:hover { transform: translateY(-3px); }
        .stat-card h3 { font-size: 1.9rem; letter-spacing: -0.02em; font-variant-numeric: tabular-nums; }
        .stat-icon {
            width: 52px; height: 52px;
            display: grid; place-items: center;
            border-radius: 14px;
            font-size: 1.3rem;
            color: var(--stat-color);
            background: color-mix(in srgb, var(--stat-color) 14%, transparent);
            border: 1px solid color-mix(in srgb, var(--stat-color) 28%, transparent);
            z-index: 1;
        }
        .stat-danger  { --stat-color: #f43f5e; }
        .stat-warning { --stat-color: #fbbf24; }
        .stat-info    { --stat-color: #22d3ee; }
        .stat-light   { --stat-color: #a5b4fc; }

        /* Section headings */
        .section-title {
            font-weight: 600;
            letter-spacing: -0.01em;
            display: flex; align-items: center; gap: 10px;
        }
        .section-title i {
            width: 30px; height: 30px;
            display: inline-grid; place-items: center;
            border-radius: 9px;
            background: rgba(249, 115, 22, 0.14);
            color: var(--accent-2) !important;
            font-size: 13px;
            margin: 0 !important;
        }

        /* ---------- Pulse Live Badge ---------- */
        .pulse-badge {
            display: inline-flex;
            align-items: center;
            padding: 6px 14px;
            background: rgba(244, 63, 94, 0.12);
            border: 1px solid rgba(244, 63, 94, 0.3);
            color: #fb7185;
            border-radius: 50px;
            font-weight: 600;
            font-size: 11px;
            letter-spacing: .06em;
        }
        .pulse-dot {
            width: 8px; height: 8px;
            background-color: #f43f5e;
            border-radius: 50%;
            margin-right: 8px;
            box-shadow: 0 0 8px #f43f5e;
            animation: pulse-animation 2s infinite;
        }
        @keyframes pulse-animation {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(244, 63, 94, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(244, 63, 94, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(244, 63, 94, 0); }
        }

        /* ---------- Alert Items ---------- */
        .alert-item {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-color);
            border-left: 3px solid;
            border-radius: 12px;
            padding: 11px 14px;
            margin-bottom: 10px;
            transition: background .2s ease, transform .2s ease;
        }
        .alert-item:hover { background: var(--surface-hover); transform: translateX(2px); }
        .alert-item.danger  { border-left-color: #f43f5e; background: linear-gradient(90deg, rgba(244,63,94,.08), transparent 60%); }
        .alert-item.warning { border-left-color: #fbbf24; background: linear-gradient(90deg, rgba(251,191,36,.07), transparent 60%); }
        .alert-item.info    { border-left-color: #22d3ee; background: linear-gradient(90deg, rgba(34,211,238,.07), transparent 60%); }

        /* ---------- Map ---------- */
        #map {
            height: 480px;
            border-radius: 14px;
            border: 1px solid var(--border-color);
            background: #0b1020;
        }
        /* Dark-mode tint for Google tiles (visual only) */
        .leaflet-tile-pane {
            filter: invert(100%) hue-rotate(180deg) brightness(.92) contrast(.9) saturate(.75);
        }
        .leaflet-container { font-family: 'Inter', sans-serif; }
        .leaflet-popup-content-wrapper {
            background: #111827;
            color: var(--text-main);
            border: 1px solid var(--border-strong);
            border-radius: 12px;
            box-shadow: 0 12px 30px rgba(0,0,0,.6);
        }
        .leaflet-popup-tip { background: #111827; }
        .leaflet-bar a {
            background: #111827; color: #e2e8f0; border-color: var(--border-strong);
        }
        .leaflet-bar a:hover { background: #1f2937; }

        /* ---------- Form controls ---------- */
        .form-select, .form-control {
            background-color: rgba(255,255,255,0.04) !important;
            border: 1px solid var(--border-color) !important;
            color: var(--text-main) !important;
            border-radius: 10px !important;
        }
        .form-select:focus, .form-control:focus {
            border-color: rgba(249, 115, 22, 0.6) !important;
            box-shadow: 0 0 0 3px rgba(249, 115, 22, 0.15) !important;
        }
        .form-control::placeholder { color: #64748b; }
        .form-select option { background: #0e1423; color: #f1f5f9; }

        .btn-lang {
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--border-strong);
            color: var(--text-main);
            border-radius: 999px;
            padding: 6px 16px;
            font-size: 13px;
        }
        .btn-lang:hover, .btn-lang:focus, .btn-lang.show {
            background: rgba(255,255,255,0.1); color: #fff; border-color: rgba(255,255,255,.3);
        }
        .dropdown-menu-dark {
            background: #0e1423;
            border: 1px solid var(--border-strong);
            border-radius: 14px;
            padding: 6px;
        }
        .dropdown-menu-dark .dropdown-item { border-radius: 8px; }

        .map-chip {
            background: rgba(255,255,255,0.06);
            border: 1px solid var(--border-color);
            color: var(--text-dim);
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 500;
        }

        #alert-count-badge {
            background: linear-gradient(135deg, #f43f5e, #e11d48) !important;
            font-weight: 600;
            padding: 6px 10px;
            box-shadow: 0 4px 12px rgba(244, 63, 94, .35);
        }

        /* Scrollbar */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.16); border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(255,255,255,0.28); }

        /* ---------- Responsive ---------- */
        html, body { max-width: 100%; }
        img, canvas { max-width: 100%; }

        /* Tablet */
        @media (max-width: 991.98px) {
            #map { height: 400px; }
            .main-wrap { padding-left: 1rem !important; padding-right: 1rem !important; }
            .app-nav { padding-left: 1rem !important; padding-right: 1rem !important; }
            #emergency-alerts-container { max-height: 260px !important; }
        }

        /* Mobile */
        @media (max-width: 767.98px) {
            body { font-size: 14px; }

            /* Banner */
            .sticky-marquee-banner { padding: 7px 0; font-size: 12px; }
            .sticky-marquee-banner .badge { font-size: 10px; margin-right: .6rem !important; }
            .marquee-content { animation-duration: 18s; }
            .marquee-content span { margin-right: 48px; }

            /* Navbar: brand on top, controls below */
            .app-nav { padding-top: .75rem !important; padding-bottom: .75rem !important; }
            .app-nav .container-fluid { flex-wrap: wrap; gap: 10px; }
            .app-nav .navbar-brand { margin-right: 0; max-width: 100%; gap: .6rem !important; }
            .brand-icon { width: 34px; height: 34px; border-radius: 10px; font-size: 14px; flex-shrink: 0; }
            .brand-title { font-size: 14px; white-space: normal; }
            .brand-sub { display: none; }
            .app-nav .container-fluid > div:last-child {
                width: 100%;
                justify-content: space-between;
                gap: .5rem !important;
            }
            .pulse-badge { padding: 5px 11px; font-size: 10px; }
            .btn-lang { padding: 5px 12px; font-size: 12px; }

            /* Layout spacing */
            .main-wrap { padding: .75rem !important; }
            .main-wrap .row.g-4 { --bs-gutter-x: .75rem; --bs-gutter-y: .75rem; }
            .main-wrap .row.mb-4 { margin-bottom: .75rem !important; }
            .main-wrap .col-lg-4.d-flex { gap: .75rem !important; }
            .modern-card { border-radius: 16px; }

            /* Stat cards: compact 2-column grid */
            .stat-card { padding: .85rem !important; gap: .5rem; }
            .stat-card h6 { font-size: 9.5px; letter-spacing: .05em; margin-bottom: .35rem !important; }
            .stat-card h3 { font-size: 1.2rem; }
            .stat-card h3 .fs-6 { font-size: .7rem !important; }
            .stat-card .stat-icon { width: 34px; height: 34px; font-size: .85rem; border-radius: 10px; flex-shrink: 0; }
            .stat-card::after { width: 90px; height: 90px; right: -30px; top: -30px; }

            /* Map */
            #map { height: 320px; border-radius: 12px; }
            .map-chip { display: none; }
            .section-title { font-size: 14px; gap: 8px; }
            .section-title i { width: 26px; height: 26px; font-size: 12px; }

            /* Alerts */
            #emergency-alerts-container { max-height: 300px !important; }
            .alert-item { padding: 10px 12px; }
            .alert-item .d-flex { flex-wrap: wrap; gap: 2px; }
            #alert-count-badge { font-size: 11px; padding: 5px 9px; }

            /* Filters: bigger touch targets, avoids iOS zoom on focus */
            .form-select, .form-control { font-size: 16px !important; min-height: 42px; }

            /* Chart */
            #fireChart { min-height: 200px; }

            /* Leaflet controls easier to tap */
            .leaflet-bar a { width: 34px; height: 34px; line-height: 34px; }
        }

        /* Small phones */
        @media (max-width: 380px) {
            .brand-title { font-size: 13px; }
            .stat-card h3 { font-size: 1.05rem; }
            .stat-card .stat-icon { display: none; }
            #map { height: 280px; }
        }
    </style>
</head>
<body>

    <!-- 1. Sticky + Scrolling Marquee Banner -->
    <div class="sticky-marquee-banner shadow-sm">
        <div class="container-fluid d-flex align-items-center">
            <span class="badge bg-dark text-danger me-3 px-2 py-1 fw-bold"><i class="fa-solid fa-bullhorn me-1"></i>LIVE </span>
            <div class="overflow-hidden flex-grow-1">
                <div id="marquee-content" class="marquee-content">
                    <span>Loading live alerts from backend...</span>
                </div>
            </div>
        </div>
    </div>

    <!-- 2. Navbar -->
    <nav class="navbar navbar-dark app-nav px-4 py-3">
        <div class="container-fluid">
            <a class="navbar-brand d-flex align-items-center gap-3" href="#">
                <span class="brand-icon">
                    <i class="fa-solid fa-fire-flame-curved"></i>
                </span>
                <span class="d-flex flex-column">
                    <span class="brand-title">Myanmar Wildfire & Cyclone Tracker</span>
                    <span class="brand-sub">Real-time geospatial monitoring</span>
                </span>
            </a>
            <div class="d-flex align-items-center gap-3">
                <div class="pulse-badge">
                    <span class="pulse-dot"></span> LIVE MONITOR
                </div>
                <div class="dropdown">
                    <button class="btn btn-lang" type="button" data-bs-toggle="dropdown">
                        <i class="fa-solid fa-globe me-1"></i> Myanmar
                    </button>

                </div>
            </div>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="container-fluid py-4 px-4 main-wrap">

        <!-- 3. Top Stats Cards -->
        <div class="row g-4 mb-4">
            <div class="col-6 col-xl-3">
                <div class="modern-card stat-card stat-danger p-4 d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-uppercase mb-2">Total Fire Cases</h6>
                        <h3 class="fw-bold mb-0" id="stat-total-cases">--</h3>
                    </div>
                    <div class="stat-icon"><i class="fa-solid fa-file-waveform"></i></div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="modern-card stat-card stat-warning p-4 d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-uppercase mb-2">Active Hotspots</h6>
                        <h3 class="fw-bold mb-0" id="stat-active-hotspots">--</h3>
                    </div>
                    <div class="stat-icon"><i class="fa-solid fa-fire"></i></div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="modern-card stat-card stat-info p-4 d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-uppercase mb-2">Burned Area (Est.)</h6>
                        <h3 class="fw-bold mb-0"><span id="stat-burned-acres">--</span> <span class="fs-6 fw-medium" style="color: var(--text-dim);">Acres</span></h3>
                    </div>
                    <div class="stat-icon"><i class="fa-solid fa-chart-area"></i></div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="modern-card stat-card stat-light p-4 d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-uppercase mb-2">High Risk Townships</h6>
                        <h3 class="fw-bold mb-0" id="stat-high-risk">--</h3>
                    </div>
                    <div class="stat-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                </div>
            </div>
        </div>

        <!-- 4. Middle Section: Map, Townships Alert Box & Analytics Chart -->
        <div class="row g-4">
            <!-- Map Column (Left) -->
            <div class="col-lg-8">
                <div class="modern-card p-3 h-100 d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-center mb-2 px-2">
                        <h5 class="mb-0 text-white section-title">
                            <i class="fa-solid fa-map-location-dot"></i> Geospatial Monitoring Map
                        </h5>
                        <span class="map-chip">Google Roadmap & Overlays</span>
                    </div>
                    <div id="map" class="flex-grow-1 mt-2"></div>
                </div>
            </div>

            <!-- Right Column: Emergency Alerts Townships Box & Chart -->
            <div class="col-lg-4 d-flex flex-column gap-4">


                <div class="modern-card p-3 flex-grow-1 d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="mb-0 text-white section-title fs-6">
                            <i class="fa-solid fa-bell"></i> Affected Townships & Alerts
                        </h5>
                        <span class="badge rounded-pill" id="alert-count-badge">0 Active</span>
                    </div>

                    <!-- Filter Controls -->
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <select id="filter-risk" class="form-select form-select-sm">
                                <option value="">All Risks</option>
                                <option value="High Risk">High Risk</option>
                                <option value="Moderate">Moderate</option>
                                <option value="Advisory">Advisory</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <input type="text" id="filter-date" class="form-control form-control-sm" placeholder="Filter time/date...">
                        </div>
                    </div>

                    <!-- Scrollable Alerts List Container -->
                    <div class="flex-grow-1 pe-1" id="emergency-alerts-container" style="max-height: 200px; overflow-y: auto;">
                        <p class="text-muted small text-center py-3">Loading affected townships...</p>
                    </div>
                </div>

                <!-- Fire Incident Analytics Chart Box -->
                <div class="modern-card p-3 flex-grow-1 d-flex flex-column">
                    <h5 class="mb-2 text-white section-title fs-6">
                        <i class="fa-solid fa-chart-line"></i> Fire Incident Analytics
                    </h5>
                    <div class="flex-grow-1 d-flex align-items-center justify-content-center" style="min-height: 180px;">
                        <canvas id="fireChart"></canvas>
                    </div>
                </div>

            </div>
        </div>

    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <!-- Safe JS Script without JSP EL conflicts -->
    <script>
        let fireChartInstance = null;
        let mapInstance = null;
        let hotspotLayerGroup = null;
        let globalEmergencyAlerts = [];

        document.addEventListener("DOMContentLoaded", function () {
            //Leaflet Map
            const googleRoadmapLayer = L.tileLayer('https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', {
                maxZoom: 20,
                subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                attribution: '&copy; Google Maps'
            });

            const myanmarBounds = L.latLngBounds([9.0, 91.5], [28.8, 101.5]);

            mapInstance = L.map('map', {
                center: [21.9162, 95.9560],
                zoom: 6,
                layers: [googleRoadmapLayer],
                maxBounds: myanmarBounds,
                maxBoundsViscosity: 1.0,
                minZoom: 5
            });

            hotspotLayerGroup = L.layerGroup().addTo(mapInstance);

            //Backend API (JSON)
            async function fetchDashboardData() {
                try {
                    const response = await fetch('api/dashboard-data.json');
                    if (!response.ok) throw new Error('Failed to fetch data.');

                    const data = await response.json();

                    updateMarqueeAlert(data.topAlert);
                    updateStats(data.stats);

                    globalEmergencyAlerts = data.emergencyAlerts || [];
                    renderEmergencyAlerts(globalEmergencyAlerts);

                    updateChart(data.chart);
                    updateMapHotspots(data.hotspots);

                } catch (error) {
                    console.error("Error loading dashboard data:", error);
                    document.getElementById('marquee-content').innerHTML = "<span>⚠️ Error: Unable to connect to backend data.</span>";
                }
            }

            //Marquee Top Alert Update
            function updateMarqueeAlert(alertText) {
                const marqueeEl = document.getElementById('marquee-content');
                if (alertText) {
                    marqueeEl.innerHTML = '<span>' + alertText + '</span><span>' + alertText + '</span>';
                } else {
                    marqueeEl.innerHTML = "<span>No critical alerts at this moment.</span>";
                }
            }

            //Stats Cards Update
            function updateStats(stats) {
                if (!stats) return;
                document.getElementById('stat-total-cases').innerText = stats.totalCases ?? 0;
                document.getElementById('stat-active-hotspots').innerText = stats.activeHotspots ?? 0;
                document.getElementById('stat-burned-acres').innerText = stats.burnedAcres ?? 0;
                document.getElementById('stat-high-risk').innerText = (stats.highRiskTownships ?? 0) + " Townships";
            }

            //Emergency Alerts Box
            function renderEmergencyAlerts(alertsList) {
                const container = document.getElementById('emergency-alerts-container');
                const badge = document.getElementById('alert-count-badge');

                if (!alertsList || alertsList.length === 0) {
                    container.innerHTML = '<p class="text-muted small text-center py-3">No matching alerts found.</p>';
                    badge.innerText = '0 Active';
                    return;
                }

                badge.innerText = alertsList.length + ' Active';

                let htmlContent = '';
                alertsList.forEach(item => {
                    let borderClass = 'danger';
                    let textClass = 'text-danger';
                    if (item.risk === 'Moderate') {
                        borderClass = 'warning';
                        textClass = 'text-warning';
                    } else if (item.risk === 'Advisory') {
                        borderClass = 'info';
                        textClass = 'text-info';
                    }

                    htmlContent += '<div class="alert-item ' + borderClass + '">' +
                        '<div class="d-flex justify-content-between align-items-center mb-1">' +
                            '<span class="fw-bold ' + textClass + ' small">' + item.risk + ': ' + item.township + '</span>' +
                            '<span class="text-muted" style="font-size: 10px;">' + item.time + '</span>' +
                        '</div>' +
                        '<p class="mb-0 text-light small">' + item.desc + '</p>' +
                    '</div>';
                });

                container.innerHTML = htmlContent;
            }

            //Filter Logic
            function applyFilters() {
                const selectedRisk = document.getElementById('filter-risk').value;
                const dateQuery = document.getElementById('filter-date').value.toLowerCase().trim();

                const filtered = globalEmergencyAlerts.filter(item => {
                    const matchRisk = selectedRisk === "" || item.risk === selectedRisk;
                    const matchDate = dateQuery === "" || item.time.toLowerCase().includes(dateQuery) || item.township.toLowerCase().includes(dateQuery);
                    return matchRisk && matchDate;
                });

                renderEmergencyAlerts(filtered);
            }

            document.getElementById('filter-risk').addEventListener('change', applyFilters);
            document.getElementById('filter-date').addEventListener('input', applyFilters);

            //Chart.js Update
            function updateChart(chartData) {
                if (!chartData) return;
                const ctx = document.getElementById('fireChart').getContext('2d');

                if (fireChartInstance) fireChartInstance.destroy();

                fireChartInstance = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: chartData.labels,
                        datasets: [{
                            label: 'မီးလောင်မှု Case အရေအတွက်',
                            data: chartData.caseCounts,
                            borderColor: '#f97316',
                            backgroundColor: 'rgba(249, 115, 22, 0.1)',
                            borderWidth: 2,
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false } },
                        scales: {
                            x: { ticks: { color: '#aaa', font: { size: 10 } }, grid: { color: 'rgba(255,255,255,0.05)' } },
                            y: { ticks: { color: '#aaa', font: { size: 10 } }, grid: { color: 'rgba(255,255,255,0.05)' } }
                        }
                    }
                });
            }

            //Map Hotspots
            function updateMapHotspots(hotspots) {
                if (!hotspots) return;
                hotspotLayerGroup.clearLayers();

                hotspots.forEach(spot => {
                    L.circle([spot.lat, spot.lng], {
                        radius: spot.radius,
                        color: '#ff4757',
                        fillColor: '#ff4757',
                        fillOpacity: 0.2,
                        weight: 1
                    }).addTo(hotspotLayerGroup);

                    const fireIcon = L.divIcon({
                        className: '',
                        html: '<div style="font-size: 20px; filter: drop-shadow(0 0 6px #ff4757);">🔥</div>',
                        iconSize: [24, 24]
                    });

                    L.marker([spot.lat, spot.lng], { icon: fireIcon })
                      .bindPopup('<b>' + spot.region + '</b><br>Status: ' + spot.status)
                      .addTo(hotspotLayerGroup);
                });
            }


            fetchDashboardData();
        });
    </script>
</body>
</html>
