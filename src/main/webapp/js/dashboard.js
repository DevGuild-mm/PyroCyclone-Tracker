let fireChartInstance = null;
let mapInstance = null;
let hotspotLayerGroup = null;
let globalEmergencyAlerts = [];

document.addEventListener("DOMContentLoaded", function () {

    const reportModalBtn = document.querySelector('[data-bs-target="#reportModal"]');
    if (reportModalBtn) {
        reportModalBtn.addEventListener('click', function (e) {
            if (typeof isLoggedIn !== 'undefined' && !isLoggedIn) {
                e.preventDefault();
                alert("⚠️ Please login first to submit a report.");
                window.location.href = 'login.jsp';
            }
        });
    }

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

    fetchDashboardData('all');

    const riskFilter = document.getElementById('filter-risk');
    if (riskFilter) riskFilter.addEventListener('change', applyFilters);

    const dateFilter = document.getElementById('filter-date');
    if (dateFilter) dateFilter.addEventListener('input', applyFilters);

    const categoryFilter = document.getElementById('filter-category');
    if (categoryFilter) {
        categoryFilter.addEventListener('change', function () {
            fetchDashboardData(this.value);
        });
    }

    const btnGetLocation = document.getElementById('btnGetLocation');
    const locationStatus = document.getElementById('locationStatus');
    const latInput = document.getElementById('reportLat');
    const lngInput = document.getElementById('reportLng');

    if (btnGetLocation) {
        btnGetLocation.addEventListener('click', function () {
            if (!navigator.geolocation) {
                alert("⚠️ Your browser does not support geolocation.");
                return;
            }

            if (locationStatus) {
                locationStatus.className = "form-text small mt-2 text-info";
                locationStatus.innerText = "📍 Retrieving current location...";
                locationStatus.classList.remove('d-none');
            }
            btnGetLocation.disabled = true;

            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const lat = position.coords.latitude.toFixed(6);
                    const lng = position.coords.longitude.toFixed(6);

                    if (latInput) latInput.value = lat;
                    if (lngInput) lngInput.value = lng;

                    if (locationStatus) {
                        locationStatus.className = "form-text small mt-2 text-success fw-bold";
                        locationStatus.innerText = '✅ Location retrieved! (Lat: ' + lat + ', Lng: ' + lng + ')';
                    }
                    btnGetLocation.disabled = false;
                },
                (error) => {
                    let errMsg = "⚠️ Unable to retrieve location. Please enter Latitude / Longitude manually.";
                    console.warn("Geolocation Error:", error);
                    if (locationStatus) {
                        locationStatus.className = "form-text small mt-2 text-danger";
                        locationStatus.innerText = errMsg;
                    }
                    btnGetLocation.disabled = false;
                },
                { enableHighAccuracy: false, timeout: 30000, maximumAge: 0 }
            );
        });
    }

    const reportForm = document.getElementById('incidentReportForm');
    const reportFeedback = document.getElementById('reportFeedback');

    if (reportForm) {
        reportForm.addEventListener('submit', async function (e) {
            e.preventDefault();

            const payload = {
                category: document.getElementById('reportCategory').value,
                title: document.getElementById('reportTitle').value.trim(),
                riskLevel: document.getElementById('reportRisk').value,
                township: document.getElementById('reportTownship').value.trim(),
                latitude: Number(latInput ? latInput.value : 0),
                longitude: Number(lngInput ? lngInput.value : 0),
                description: document.getElementById('reportDesc').value.trim()
            };

            if (!Number.isFinite(payload.latitude) || !Number.isFinite(payload.longitude)) {
                showReportFeedback('danger', 'Please enter valid Latitude / Longitude coordinates.');
                return;
            }

            const submitButton = reportForm.querySelector('button[type="submit"]');
            const originalButtonText = submitButton.innerHTML;
            submitButton.disabled = true;
            submitButton.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Sending...';
            showReportFeedback('info', 'Sending JSON report to backend...');

            const endpoint = 'api/reports';
            const requestJson = JSON.stringify(payload);

            console.group('[Report API] JSON Request');
            console.info('POST', endpoint);
            console.log('Payload JSON:', requestJson);
            console.groupEnd();

            try {
                const response = await fetch(endpoint, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Accept': 'application/json'
                    },
                    body: requestJson
                });

                // 1. Redirect to Login Page if session expires
                if (response.status === 401) {
                    alert("⚠️ Session has expired or you are not logged in. Please login first.");
                    window.location.href = 'login.jsp';
                    return;
                }

                const responseText = await response.text();
                let responseData = null;

                // 2. Check whether the response text is JSON (to avoid HTML error pages)
                try {
                    responseData = JSON.parse(responseText);
                } catch (e) {
                    responseData = null; // Not JSON, it is HTML
                }

                if (!response.ok) {
                    let errorMessage = 'Server Error (' + response.status + ')';

                    if (response.status === 404) {
                        errorMessage = 'API endpoint not found';
                    } else if (response.status === 500) {
                        errorMessage = 'Internal server error. (HTTP 500 Internal Error)';
                    } else if (responseData && responseData.message) {
                        errorMessage = responseData.message;
                    }

                    throw new Error(errorMessage);
                }

                showReportFeedback('success', 'Report submitted successfully.');
                setTimeout(() => {
                    const modalEl = document.getElementById('reportModal');
                    if (modalEl && typeof bootstrap !== 'undefined') {
                        bootstrap.Modal.getOrCreateInstance(modalEl).hide();
                    }
                    reportForm.reset();
                    if (locationStatus) locationStatus.classList.add('d-none');
                    if (reportFeedback) reportFeedback.classList.add('d-none');
                }, 1200);

            } catch (error) {
                console.error('[Report API] Error:', error);
                showReportFeedback('danger', '⚠️ Failed to send. ' + error.message);
            } finally {
                submitButton.disabled = false;
                submitButton.innerHTML = originalButtonText;
            }
        });
    }

    function showReportFeedback(type, message) {
        if (!reportFeedback) return;
        reportFeedback.className = 'alert alert-' + type + ' mb-3';
        reportFeedback.textContent = message;
        reportFeedback.classList.remove('d-none');
    }
});

async function fetchDashboardData(category) {
    if (!category) category = 'all';
    try {
        let url = 'api/events?days=30';
        if (category !== 'all') url += '&category=' + category;

        const response = await fetch(url);
        if (!response.ok) throw new Error('Failed to fetch data.');

        const geoJson = await response.json();
        parseEonetData(geoJson);
    } catch (error) {
        console.warn("Error loading dashboard data:", error);
        const marqueeEl = document.getElementById('marquee-content');
        if (marqueeEl) {
            marqueeEl.innerHTML = "<span>⚠️ Unable to connect to live alerts.</span>";
        }
    }
}

function extractCoordinates(geometry) {
    if (!geometry || !geometry.coordinates) return [95.9560, 21.9162];
    let coords = geometry.coordinates;
    while (Array.isArray(coords) && coords.length > 0 && Array.isArray(coords[0])) {
        coords = coords[0];
    }
    if (Array.isArray(coords) && coords.length >= 2) {
        return [Number(coords[0]) || 95.9560, Number(coords[1]) || 21.9162];
    }
    return [95.9560, 21.9162];
}

function parseEonetData(geoJson) {
    const features = geoJson.features || [];
    let totalCases = features.length;
    let wildfireCount = 0;
    let stormCount = 0;
    let emergencyAlerts = [];
    let hotspots = [];
    let chartLabels = [];
    let chartCounts = [];
    let dateMap = {};

    features.forEach((feature) => {
        try {
            const props = feature.properties || {};
            const coords = extractCoordinates(feature.geometry);
            const lng = coords[0];
            const lat = coords[1];
            const title = props.title || "Disaster Event";
            const eventDate = props.date ? props.date.substring(0, 10) : "Recent";
            const lowerTitle = title.toLowerCase();

            let isStorm = lowerTitle.includes('cyclone') || lowerTitle.includes('storm') || lowerTitle.includes('typhoon');
            if (isStorm) stormCount++; else wildfireCount++;

            let risk = "High Risk";
            let englishDesc = isStorm
                ? "Storm / Cyclone hazard alert issued."
                : "Wildfire hazard warning. Fire alert issued.";
            let iconSymbol = isStorm ? "🌀" : "🔥";

            emergencyAlerts.push({ risk: risk, township: title, time: eventDate, desc: englishDesc, isStorm: isStorm });
            hotspots.push({ lat: lat, lng: lng, radius: isStorm ? 30000 : 15000, region: title, status: risk, iconSymbol: iconSymbol });
            dateMap[eventDate] = (dateMap[eventDate] || 0) + 1;
        } catch (err) {
            console.warn("Skipping feature:", err);
        }
    });

    const sortedDates = Object.keys(dateMap).sort();
    sortedDates.forEach(d => { chartLabels.push(d); chartCounts.push(dateMap[d]); });

    if (sortedDates.length === 0) { chartLabels = ["No Data"]; chartCounts = [0]; }

    const topAlertText = totalCases > 0
        ? '⚠️ Wildfire (' + wildfireCount + ') and Storm (' + stormCount + ') warnings are currently active.'
        : 'There are currently no active natural disaster emergency alerts.';

    updateMarqueeAlert(topAlertText);

    const totalElem = document.getElementById('stat-total-cases');
    if (totalElem) totalElem.innerText = totalCases;

    const activeElem = document.getElementById('stat-active-hotspots');
    if (activeElem) activeElem.innerText = wildfireCount;

    const burnedElem = document.getElementById('stat-burned-acres');
    if (burnedElem) burnedElem.innerText = (wildfireCount * 1250).toLocaleString();

    const highRiskElem = document.getElementById('stat-high-risk');
    if (highRiskElem) highRiskElem.innerText = stormCount + " Storms";

    globalEmergencyAlerts = emergencyAlerts;
    renderEmergencyAlerts(globalEmergencyAlerts);

    updateChart({ labels: chartLabels, caseCounts: chartCounts });
    updateMapHotspots(hotspots);
}

function updateMarqueeAlert(alertText) {
    const marqueeEl = document.getElementById('marquee-content');
    if (marqueeEl) {
        marqueeEl.innerHTML = '<span>' + alertText + '</span><span>' + alertText + '</span>';
    }
}

function renderEmergencyAlerts(alertsList) {
    const container = document.getElementById('emergency-alerts-container');
    const badge = document.getElementById('alert-count-badge');
    if (!container) return;

    if (!alertsList || alertsList.length === 0) {
        container.innerHTML = '<p class="text-muted small text-center py-3">No matching alerts found.</p>';
        if (badge) badge.innerText = '0 Active';
        return;
    }

    if (badge) badge.innerText = alertsList.length + ' Active';
    let htmlContent = '';
    alertsList.forEach(item => {
        let borderClass = item.isStorm ? 'info' : 'danger';
        let textClass = item.isStorm ? 'text-info' : 'text-danger';
        let hazardText = item.isStorm ? '🌀 Storm: ' : '🔥 Wildfire: ';

        htmlContent += '<div class="alert-item ' + borderClass + '">' +
            '<div class="d-flex justify-content-between align-items-center mb-1">' +
            '<span class="fw-bold ' + textClass + ' small">' + hazardText + item.township + '</span>' +
            '<span class="text-muted" style="font-size: 10px;">' + item.time + '</span>' +
            '</div>' +
            '<p class="mb-0 text-light small">' + item.desc + '</p>' +
            '</div>';
    });
    container.innerHTML = htmlContent;
}

function applyFilters() {
    const riskElem = document.getElementById('filter-risk');
    const dateElem = document.getElementById('filter-date');
    const selectedRisk = riskElem ? riskElem.value : "";
    const dateQuery = dateElem ? dateElem.value.toLowerCase().trim() : "";

    const filtered = globalEmergencyAlerts.filter(item => {
        const matchRisk = selectedRisk === "" || item.risk === selectedRisk;
        const matchDate = dateQuery === "" || item.time.toLowerCase().includes(dateQuery) || item.township.toLowerCase().includes(dateQuery);
        return matchRisk && matchDate;
    });
    renderEmergencyAlerts(filtered);
}

function updateChart(chartData) {
    const chartElem = document.getElementById('fireChart');
    if (!chartElem) return;
    const ctx = chartElem.getContext('2d');

    if (fireChartInstance) fireChartInstance.destroy();

    fireChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: chartData.labels,
            datasets: [{
                label: 'Disaster Incidents',
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
                x: { ticks: { color: '#94a3b8', font: { size: 10 } }, grid: { color: 'rgba(255,255,255,0.04)' } },
                y: { ticks: { color: '#94a3b8', font: { size: 10 } }, grid: { color: 'rgba(255,255,255,0.04)' } }
            }
        }
    });
}

function updateMapHotspots(hotspots) {
    if (!hotspots || !hotspotLayerGroup) return;
    hotspotLayerGroup.clearLayers();

    hotspots.forEach(spot => {
        let circleColor = spot.iconSymbol === '🌀' ? '#06b6d4' : '#ef4444';

        L.circle([spot.lat, spot.lng], {
            radius: spot.radius,
            color: circleColor,
            fillColor: circleColor,
            fillOpacity: 0.2,
            weight: 1.5
        }).addTo(hotspotLayerGroup);

        const customIcon = L.divIcon({
            className: '',
            html: '<div style="font-size: 20px; filter: drop-shadow(0 0 6px rgba(0,0,0,0.8));">' + spot.iconSymbol + '</div>',
            iconSize: [24, 24]
        });

        let hazardTypeText = spot.iconSymbol === '🌀' ? 'Storm' : 'Wildfire';

        L.marker([spot.lat, spot.lng], { icon: customIcon })
            .bindPopup('<b>' + spot.region + '</b><br>Category: ' + hazardTypeText)
            .addTo(hotspotLayerGroup);
    });
}