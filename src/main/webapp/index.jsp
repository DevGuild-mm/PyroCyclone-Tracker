<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-main: #07090e;
            --card-bg: rgba(15, 23, 42, 0.8);
            --border-color: rgba(255, 255, 255, 0.08);
        }

        body {
            background-color: var(--bg-main);
            font-family: 'Inter', sans-serif;
            color: #f8fafc;
            overflow-x: hidden;
        }

        /* Sticky + Marquee Scrolling Banner */
        .sticky-marquee-banner {
            position: sticky;
            top: 0;
            z-index: 1050;
            background: linear-gradient(90deg, #b91c1c 0%, #7f1d1d 100%);
            color: #fff;
            padding: 8px 0;
            font-size: 14px;
            font-weight: 500;
            overflow: hidden;
            white-space: nowrap;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
        }
        .marquee-content {
            display: inline-block;
            animation: marquee 25s linear infinite;
        }
        .marquee-content span {
            margin-right: 80px;
        }
        @keyframes marquee {
            0% { transform: translateX(100%); }
            100% { transform: translateX(-100%); }
        }

        /* Glassmorphism Cards */
        .modern-card {
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }

        .modern-card h6 {
            color: #cbd5e1 !important;
            font-weight: 600;
        }

        /* Pulse Live Badge */
        .pulse-badge {
            display: inline-flex;
            align-items: center;
            padding: 5px 12px;
            background: rgba(239, 68, 68, 0.15);
            border: 1px solid rgba(239, 68, 68, 0.3);
            color: #ef4444;
            border-radius: 50px;
            font-weight: 600;
            font-size: 12px;
        }
        .pulse-dot {
            width: 8px; height: 8px;
            background-color: #ef4444;
            border-radius: 50%;
            margin-right: 6px;
            box-shadow: 0 0 8px #ef4444;
            animation: pulse-animation 2s infinite;
        }
        @keyframes pulse-animation {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(239, 68, 68, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
        }

        /* Alert Items for Townships Box */
        .alert-item {
            background: rgba(255, 255, 255, 0.03);
            border-left: 4px solid;
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 10px;
        }
        .alert-item.danger { border-color: #ef4444; }
        .alert-item.warning { border-color: #f59e0b; }
        .alert-item.info { border-color: #06b6d4; }

        #map {
            height: 480px;
            border-radius: 12px;
        }

        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.2); border-radius: 10px; }
    </style>
</head>
<body>

    <!-- 1. Sticky + Scrolling Marquee Banner -->
    <div class="sticky-marquee-banner shadow-sm">
        <div class="container-fluid d-flex align-items-center">
            <span class="badge bg-dark text-danger me-3 px-2 py-1 fw-bold"><i class="fa-solid fa-bullhorn me-1"></i> LIVE ALERTS</span>
            <div class="overflow-hidden flex-grow-1">
                <div id="marquee-content" class="marquee-content">
                    <span>Loading live alerts from backend...</span>
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
                    <button class="btn btn-outline-light btn-sm  rounded-pill px-3" type="button" data-bs-toggle="dropdown">
                        <i class="fa-solid fa-globe me-1"></i> Myanmar
                    </button>
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
                        <h6 class="text-uppercase small mb-1">Total Fire Cases</h6>
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
                        <h6 class="text-uppercase small mb-1">High Risk Townships</h6>
                        <h3 class="fw-bold text-light mb-0" id="stat-high-risk">--</h3>
                    </div>
                    <div class="fs-1 text-light opacity-50"><i class="fa-solid fa-triangle-exclamation"></i></div>
                </div>
            </div>
        </div>

        <!-- 4. Middle Section: Map, Townships Alert Box & Analytics Chart -->
        <div class="row g-4">
            <!-- Map Column (Left) -->
            <div class="col-lg-8">
                <div class="modern-card p-3 h-100 d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-center mb-2 px-2">
                        <h5 class="mb-0 text-white fw-semibold">
                            <i class="fa-solid fa-map-location-dot me-2 text-warning"></i> Geospatial Monitoring Map
                        </h5>
                        <span class="badge bg-secondary bg-opacity-25 text-light px-3 py-1 rounded-pill small">Google Roadmap & Overlays</span>
                    </div>
                    <div id="map" class="flex-grow-1 mt-2"></div>
                </div>
            </div>

            <!-- Right Column: Emergency Alerts Townships Box & Chart -->
            <div class="col-lg-4 d-flex flex-column gap-4">


                <div class="modern-card p-3 flex-grow-1 d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="mb-0 text-white fw-semibold fs-6">
                            <i class="fa-solid fa-bell me-2 text-warning"></i> Affected Townships & Alerts
                        </h5>
                        <span class="badge bg-danger rounded-pill" id="alert-count-badge">0 Active</span>
                    </div>

                    <!-- Filter Controls -->
                    <div class="row g-2 mb-2">
                        <div class="col-6">
                            <select id="filter-risk" class="form-select form-select-sm bg-dark text-light border-secondary">
                                <option value="">All Risks</option>
                                <option value="High Risk">High Risk</option>
                                <option value="Moderate">Moderate</option>
                                <option value="Advisory">Advisory</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <input type="text" id="filter-date" class="form-control form-control-sm bg-dark text-light border-secondary" placeholder="Filter time/date...">
                        </div>
                    </div>

                    <!-- Scrollable Alerts List Container -->
                    <div class="flex-grow-1 pe-1" id="emergency-alerts-container" style="max-height: 200px; overflow-y: auto;">
                        <p class="text-muted small text-center py-3">Loading affected townships...</p>
                    </div>
                </div>

                <!-- Fire Incident Analytics Chart Box -->
                <div class="modern-card p-3 flex-grow-1 d-flex flex-column">
                    <h5 class="mb-2 text-white fw-semibold fs-6">
                        <i class="fa-solid fa-chart-line me-2 text-warning"></i> Fire Incident Analytics
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


            function updateMarqueeAlert(alertText) {
                const marqueeEl = document.getElementById('marquee-content');
                if (alertText) {
                    marqueeEl.innerHTML = '<span>' + alertText + '</span><span>' + alertText + '</span>';
                } else {
                    marqueeEl.innerHTML = "<span>No critical alerts at this moment.</span>";
                }
            }

            function updateStats(stats) {
                if (!stats) return;
                document.getElementById('stat-total-cases').innerText = stats.totalCases ?? 0;
                document.getElementById('stat-active-hotspots').innerText = stats.activeHotspots ?? 0;
                document.getElementById('stat-burned-acres').innerText = stats.burnedAcres ?? 0;
                document.getElementById('stat-high-risk').innerText = (stats.highRiskTownships ?? 0) + " Townships";
            }


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