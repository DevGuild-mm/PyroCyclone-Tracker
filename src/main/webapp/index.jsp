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
        <!-- Google Fonts - Inter -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
            rel="stylesheet">
        <!-- External CSS stylesheet -->
        <link rel="stylesheet" href="css/style.css">
    </head>

    <body>

        <!-- 1. Sticky + Scrolling Marquee Banner -->
        <div class="sticky-marquee-banner shadow-sm">
            <div class="container-fluid d-flex align-items-center">
                <span class="badge bg-dark text-danger me-3 px-2 py-1 fw-bold"><i class="fa-solid fa-bullhorn me-1"></i>
                    LIVE ALERTS</span>
                <div class="overflow-hidden flex-grow-1">
                    <div id="marquee-content" class="marquee-content">
                        <span>စုံစမ်းစစ်ဆေးနေသည်... (Loading live alerts...)</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. Navbar -->
        <nav class="navbar navbar-dark bg-dark px-4 py-2 border-bottom border-secondary border-opacity-25">
            <div class="container-fluid">
                <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="#">
                    <span class="p-2 rounded-3 text-warning" style="background: rgba(249, 115, 22, 0.15);">
                        <i class="fa-solid fa-fire-flame-curved"></i>
                    </span>
                    <span>Myanmar Wildfire & Cyclone Command</span>
                </a>
                <div class="d-flex align-items-center gap-3">
                    <div class="pulse-badge">
                        <span class="pulse-dot"></span> LIVE MONITOR
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-outline-light btn-sm dropdown-toggle rounded-pill px-3" type="button"
                            data-bs-toggle="dropdown">
                            <i class="fa-solid fa-globe me-1"></i> မြန်မာနိုင်ငံ
                        </button>
                        <ul class="dropdown-menu dropdown-menu-dark shadow">
                            <li><a class="dropdown-item" href="#">တစ်နိုင်ငံလုံး</a></li>
                            <li><a class="dropdown-item" href="#">ရှမ်းပြည်နယ်</a></li>
                            <li><a class="dropdown-item" href="#">စစ်ကိုင်းတိုင်း</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Main Container -->
        <div class="container-fluid py-4 px-4">

            <!-- 3. Top Stats Cards -->
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="modern-card p-3 d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-uppercase small mb-1">Total Cases</h6>
                            <h3 class="fw-bold text-danger mb-0" id="stat-total-cases">--</h3>
                        </div>
                        <div class="fs-1 text-danger opacity-50"><i class="fa-solid fa-file-waveform"></i></div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="modern-card p-3 d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-uppercase small mb-1">Active Hotspots</h6>
                            <h3 class="fw-bold text-warning mb-0" id="stat-active-hotspots">--</h3>
                        </div>
                        <div class="fs-1 text-warning opacity-50"><i class="fa-solid fa-fire"></i></div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="modern-card p-3 d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-uppercase small mb-1">Burned Area (Est.)</h6>
                            <h3 class="fw-bold text-info mb-0"><span id="stat-burned-acres">--</span> Acres</h3>
                        </div>
                        <div class="fs-1 text-info opacity-50"><i class="fa-solid fa-chart-area"></i></div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="modern-card p-3 d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-uppercase small mb-1">High Risk Regions</h6>
                            <h3 class="fw-bold text-light mb-0" id="stat-high-risk">--</h3>
                        </div>
                        <div class="fs-1 text-light opacity-50"><i class="fa-solid fa-triangle-exclamation"></i></div>
                    </div>
                </div>
            </div>

            <!-- 4. Middle Section: Map, Alerts Box & Analytics Chart -->
            <div class="row g-4">
                <!-- Map Column (Left) -->
                <div class="col-lg-8">
                    <div class="modern-card p-3 h-100 d-flex flex-column">
                        <div class="d-flex justify-content-between align-items-center mb-2 px-2">
                            <h5 class="mb-0 text-white fw-semibold">
                                <i class="fa-solid fa-map-location-dot me-2 text-warning"></i> Geospatial Monitoring Map
                            </h5>
                            <span
                                class="badge bg-secondary bg-opacity-25 text-light px-3 py-1 rounded-pill small">Google
                                Roadmap & Overlays</span>
                        </div>
                        <div id="map" class="flex-grow-1 mt-2"></div>
                    </div>
                </div>

                <!-- Right Column: Emergency Alerts Box & Chart -->
                <div class="col-lg-4 d-flex flex-column gap-4">
                    <div class="modern-card p-3 flex-grow-1 d-flex flex-column">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h5 class="mb-0 text-white fw-semibold fs-6">
                                <i class="fa-solid fa-bell me-2 text-warning"></i> Affected Regions & Alerts
                            </h5>
                            <span class="badge bg-danger rounded-pill" id="alert-count-badge">0 Active</span>
                        </div>

                        <!-- Filter Controls -->
                        <div class="row g-2 mb-2">
                            <div class="col-4">
                                <select id="filter-category"
                                    class="form-select form-select-sm bg-dark text-light border-secondary">
                                    <option value="all">All Hazards</option>
                                    <option value="wildfires">Wildfires Only</option>
                                    <option value="severeStorms">Storms Only</option>
                                </select>
                            </div>
                            <div class="col-4">
                                <select id="filter-risk"
                                    class="form-select form-select-sm bg-dark text-light border-secondary">
                                    <option value="">All Risks</option>
                                    <option value="High Risk">High Risk</option>
                                    <option value="Moderate">Moderate</option>
                                </select>
                            </div>
                            <div class="col-4">
                                <input type="text" id="filter-date"
                                    class="form-control form-control-sm bg-dark text-light border-secondary"
                                    placeholder="Date...">
                            </div>
                        </div>
                        <!-- Scrollable Alerts List Container -->
                        <div class="flex-grow-1 pe-1" id="emergency-alerts-container"
                            style="max-height: 200px; overflow-y: auto;">
                            <p class="text-muted small text-center py-3">Loading affected regions...</p>
                        </div>
                    </div>

                    <!-- Incident Analytics Chart Box -->
                    <div class="modern-card p-3 flex-grow-1 d-flex flex-column">
                        <h5 class="mb-2 text-white fw-semibold fs-6">
                            <i class="fa-solid fa-chart-line me-2 text-warning"></i> Incident Analytics
                        </h5>
                        <div class="flex-grow-1 d-flex align-items-center justify-content-center"
                            style="min-height: 180px;">
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
        <!-- External JS Logic -->
        <script src="js/dashboard.js"></script>
    </body>

    </html>