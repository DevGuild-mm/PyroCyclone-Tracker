let fireChartInstance = null;
let mapInstance = null;
let nasaHotspotLayer = null;
let communityReportLayer = null;
let globalEmergencyAlerts = [];
let reportModalInstance = null;

document.addEventListener("DOMContentLoaded", function () {
    const googleRoadmapLayer = L.tileLayer('https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', {
        maxZoom: 20,
        subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
        attribution: '&copy; Google Maps'
    });

    // Myanmar and surrounding regional bounds
    const myanmarBounds = L.latLngBounds([9.0, 91.5], [28.8, 101.5]);

    mapInstance = L.map('map', {
        center: [21.9162, 95.9560],
        zoom: 6,
        layers: [googleRoadmapLayer],
        maxBounds: myanmarBounds,
        maxBoundsViscosity: 1.0,
        minZoom: 5
    });

    nasaHotspotLayer = L.layerGroup().addTo(mapInstance);
    communityReportLayer = L.layerGroup().addTo(mapInstance);

    // Initialize Bootstrap Modal
    const modalEl = document.getElementById('reportHazardModal');
    if (modalEl) {
        reportModalInstance = new bootstrap.Modal(modalEl);
    }

    // Map Click Listener: Auto-fills coordinates and triggers the Report Modal
    mapInstance.on('click', function (e) {
        openReportModal(e.latlng.lat, e.latlng.lng);
    });

    // Initial Fetch: Loads NASA API data and Community Reports concurrently
    loadAllDashboardData('all');

    // Bind UI filters
    document.getElementById('filter-risk').addEventListener('change', applyFilters);
    document.getElementById('filter-date').addEventListener('input', applyFilters);

    const categoryFilter = document.getElementById('filter-category');
    if (categoryFilter) {
        categoryFilter.addEventListener('change', function () {
            loadAllDashboardData(this.value);
        });
    }
});

/**
 * Loads NASA EONET events and verified Crowdsourced Reports in parallel
 */
async function loadAllDashboardData(category = 'all') {
    try {
        let nasaUrl = 'api/events?days=30';
        if (category !== 'all') {
            nasaUrl += '&category=' + category;
        }

        // Fetch both feeds concurrently
        const [nasaRes, communityRes] = await Promise.all([
            fetch(nasaUrl).catch(() => null),
            fetch('api/reports?status=Verified').catch(() => null)
        ]);

        let geoJson = { features: [] };
        if (nasaRes && nasaRes.ok) {
            geoJson = await nasaRes.json();
        }

        let verifiedReports = [];
        if (communityRes && communityRes.ok) {
            verifiedReports = await communityRes.json();
        }

        processCombinedData(geoJson, verifiedReports);

    } catch (error) {
        console.error("Error loading dashboard data:", error);
        document.getElementById('marquee-content').innerHTML = "<span>⚠️ အမှား: ဒေတာများ ချိတ်ဆက်၍ မရနိုင်ပါ။</span>";
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

/**
 * Merges NASA EONET and Community Reports into charts, map markers, and alert feeds
 */
function processCombinedData(geoJson, communityReports) {
    const features = geoJson.features || [];

    let wildfireCount = 0;
    let stormCount = 0;
    let floodCount = 0;
    let combinedAlerts = [];
    let nasaHotspots = [];
    let dateMap = {};

    // 1. Process NASA Events
    features.forEach((feature) => {
        try {
            const props = feature.properties || {};
            const [lng, lat] = extractCoordinates(feature.geometry);
            const title = props.title || "Disaster Event";
            const eventDate = props.date ? props.date.substring(0, 10) : "Recent";

            const lowerTitle = title.toLowerCase();
            let isStorm = lowerTitle.includes('cyclone') || lowerTitle.includes('storm') || lowerTitle.includes('hurricane') || lowerTitle.includes('typhoon');

            if (isStorm) stormCount++;
            else wildfireCount++;

            let risk = "High Risk";
            let myanmarDesc = isStorm
                ? "🌀 မုန်တိုင်း/စိုင်ကလုန်းအန္တရာယ် သတိပေးချက် (NASA EONET)"
                : "🔥 တောမီးလောင်မှုအန္တရာယ် သတိပေးချက် (NASA EONET)";
            let iconSymbol = isStorm ? "🌀" : "🔥";

            combinedAlerts.push({
                source: 'NASA',
                risk: risk,
                township: title,
                time: eventDate,
                desc: myanmarDesc,
                isStorm: isStorm,
                lat: lat,
                lng: lng
            });

            nasaHotspots.push({
                lat: lat,
                lng: lng,
                radius: isStorm ? 30000 : 15000,
                region: title,
                iconSymbol: iconSymbol,
                date: eventDate,
                desc: myanmarDesc
            });

            dateMap[eventDate] = (dateMap[eventDate] || 0) + 1;
        } catch (err) {
            console.warn("Skipping feature:", err);
        }
    });

    // 2. Process Community Reports
    let verifiedCommunitySpots = [];
    if (Array.isArray(communityReports)) {
        communityReports.forEach((rep) => {
            const isStorm = rep.category === 'severeStorms';
            const isFlood = rep.category === 'floods';

            if (isStorm) stormCount++;
            else if (isFlood) floodCount++;
            else wildfireCount++;

            let iconSymbol = isStorm ? "🌀" : (isFlood ? "🌊" : "🔥");
            let repDate = rep.recordedTime ? rep.recordedTime.substring(0, 10) : "Recent";

            combinedAlerts.push({
                source: 'COMMUNITY',
                risk: rep.riskLevel || 'Moderate',
                township: rep.title + " (အစီရင်ခံသူ: " + rep.reporterName + ")",
                time: repDate,
                desc: rep.description || "ကွင်းဆင်း စိစစ်အတည်ပြုထားသော ဘေးအန္တရာယ် သတင်းပေးပို့ချက်။",
                isStorm: isStorm,
                isFlood: isFlood,
                lat: parseFloat(rep.latitude),
                lng: parseFloat(rep.longitude)
            });

            verifiedCommunitySpots.push({
                id: rep.id,
                lat: parseFloat(rep.latitude),
                lng: parseFloat(rep.longitude),
                title: rep.title,
                category: rep.category,
                risk: rep.riskLevel,
                desc: rep.description,
                reporter: rep.reporterName,
                date: repDate,
                iconSymbol: iconSymbol
            });

            dateMap[repDate] = (dateMap[repDate] || 0) + 1;
        });
    }

    // 3. Build Chart Data
    const sortedDates = Object.keys(dateMap).sort();
    let chartLabels = [];
    let chartCounts = [];
    sortedDates.forEach(d => {
        chartLabels.push(d);
        chartCounts.push(dateMap[d]);
    });
    if (sortedDates.length === 0) {
        chartLabels = ["No Data"];
        chartCounts = [0];
    }

    // 4. Update Header Metrics
    let totalCases = features.length + (communityReports ? communityReports.length : 0);
    const topAlertText = totalCases > 0
        ? `⚠️ သတိပေးချက် - တောမီး (${wildfireCount})၊ မုန်တိုင်း (${stormCount})၊ ရေကြီးမှု (${floodCount}) နှင့် ကွင်းဆင်းသတင်း (${communityReports ? communityReports.length : 0}) ခု တည်ရှိနေပါသည်။`
        : "လက်ရှိတွင် သဘာဝဘေး အရေးပေါ်သတိပေးချက် မရှိပါ။";

    updateMarqueeAlert(topAlertText);

    document.getElementById('stat-total-cases').innerText = totalCases;
    document.getElementById('stat-active-hotspots').innerText = wildfireCount;
    document.getElementById('stat-community-reports').innerText = (communityReports ? communityReports.length : 0) + " Verified";
    document.getElementById('stat-high-risk').innerText = (stormCount + floodCount) + " Severe Hazards";

    globalEmergencyAlerts = combinedAlerts;
    renderEmergencyAlerts(globalEmergencyAlerts);

    updateChart({ labels: chartLabels, caseCounts: chartCounts });
    renderNasaHotspots(nasaHotspots);
    renderCommunityMarkers(verifiedCommunitySpots);
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

    if (!alertsList || alertsList.length === 0) {
        container.innerHTML = '<p class="text-muted small text-center py-3">No matching alerts found.</p>';
        badge.innerText = '0 Active';
        return;
    }

    badge.innerText = alertsList.length + ' Active';
    let htmlContent = '';
    alertsList.forEach(item => {
        let borderClass = item.source === 'COMMUNITY' ? 'success' : (item.isStorm ? 'info' : 'danger');
        let textClass = item.source === 'COMMUNITY' ? 'text-success' : (item.isStorm ? 'text-info' : 'text-danger');
        let sourceTag = item.source === 'COMMUNITY' ? '<span class="badge bg-success ms-1" style="font-size: 9px;">Field Report</span>' : '<span class="badge bg-secondary ms-1" style="font-size: 9px;">NASA</span>';

        htmlContent += `
            <div class="alert-item ${borderClass}">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <span class="fw-bold ${textClass} small">${item.township} ${sourceTag}</span>
                    <span class="text-muted" style="font-size: 10px;">${item.time}</span>
                </div>
                <p class="mb-0 text-light small">${item.desc}</p>
                <div class="mt-1 d-flex justify-content-between align-items-center">
                    <span class="badge bg-dark border border-secondary" style="font-size: 9px;">${item.risk}</span>
                    <small class="text-muted" style="font-size: 9px;">📍 Lat: ${item.lat.toFixed(3)}, Lng: ${item.lng.toFixed(3)}</small>
                </div>
            </div>`;
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

function updateChart(chartData) {
    const ctx = document.getElementById('fireChart').getContext('2d');
    if (fireChartInstance) fireChartInstance.destroy();

    fireChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: chartData.labels,
            datasets: [{
                label: 'ဘေးအန္တရာယ် အခြေအနေများ (Total Incidents)',
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

function renderNasaHotspots(hotspots) {
    nasaHotspotLayer.clearLayers();

    hotspots.forEach(spot => {
        let circleColor = spot.iconSymbol === '🌀' ? '#06b6d4' : '#ff4757';

        L.circle([spot.lat, spot.lng], {
            radius: spot.radius,
            color: circleColor,
            fillColor: circleColor,
            fillOpacity: 0.25,
            weight: 1.5
        }).addTo(nasaHotspotLayer);

        const customIcon = L.divIcon({
            className: '',
            html: `<div style="font-size: 28px; filter: drop-shadow(0 0 6px rgba(0,0,0,0.9)); text-align: center;">${spot.iconSymbol}</div>`,
            iconSize: [34, 34],
            iconAnchor: [17, 17]
        });

        let popupContent = `
            <div style="font-size: 13px; color: #1e293b; min-width: 210px;">
                <h6 style="font-weight: bold; margin-bottom: 6px; color: #0f172a;">${spot.iconSymbol} ${spot.region}</h6>
                <span class="badge bg-secondary mb-2" style="font-size: 10px;">NASA EONET Satellite</span>
                <p style="margin-bottom: 4px; font-size: 11.5px;"><b>ရက်စွဲ (Date):</b> ${spot.date}</p>
                <p style="margin-bottom: 6px; font-size: 11.5px;"><b>တည်နေရာ:</b> ${spot.lat.toFixed(4)}, ${spot.lng.toFixed(4)}</p>
                <button onclick="bookmarkEvent('${encodeURIComponent(spot.region)}')" class="btn btn-sm w-100 py-1 text-white" style="font-size: 11px; font-weight: bold; background-color: #d97706;">⭐ Save Bookmark</button>
            </div>
        `;

        L.marker([spot.lat, spot.lng], { icon: customIcon })
            .bindPopup(popupContent)
            .addTo(nasaHotspotLayer);
    });
}

function renderCommunityMarkers(reports) {
    communityReportLayer.clearLayers();

    reports.forEach(rep => {
        // High-visibility green radar marker for verified community reports
        L.circle([rep.lat, rep.lng], {
            radius: 8000,
            color: '#10b981',
            fillColor: '#10b981',
            fillOpacity: 0.35,
            weight: 2
        }).addTo(communityReportLayer);

        const badgeIcon = L.divIcon({
            className: '',
            html: `<div style="background: #10b981; color: #fff; border-radius: 50%; width: 30px; height: 30px; display: flex; align-items: center; justify-content: center; font-size: 16px; border: 2px solid #ffffff; box-shadow: 0 0 10px rgba(16,185,129,0.8);">📢</div>`,
            iconSize: [30, 30],
            iconAnchor: [15, 15]
        });

        let popupContent = `
            <div style="font-size: 13px; color: #1e293b; min-width: 220px;">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <h6 style="font-weight: bold; margin-bottom: 0; color: #065f46;">📢 ${rep.title}</h6>
                    <span class="badge bg-success" style="font-size: 9px;">Verified Report</span>
                </div>
                <hr style="margin: 4px 0 8px 0;"/>
                <p style="margin-bottom: 3px; font-size: 11.5px;"><b>အမျိုးအစား:</b> ${rep.category}</p>
                <p style="margin-bottom: 3px; font-size: 11.5px;"><b>အန္တရာယ်အဆင့်:</b> <span class="badge bg-dark">${rep.risk}</span></p>
                <p style="margin-bottom: 3px; font-size: 11.5px;"><b>သတင်းပို့သူ:</b> ${rep.reporter}</p>
                <p style="margin-bottom: 6px; font-size: 11.5px;"><b>ဖြစ်ပွားချိန်:</b> ${rep.date}</p>
                <p style="margin-bottom: 8px; font-size: 11px; background: #ecfdf5; padding: 6px; border-radius: 4px; border-left: 3px solid #10b981;">${rep.desc || 'No details provided.'}</p>
            </div>
        `;

        L.marker([rep.lat, rep.lng], { icon: badgeIcon })
            .bindPopup(popupContent)
            .addTo(communityReportLayer);
    });
}

/**
 * Open the Crowdsourced Report modal and auto-populate coordinates
 */
function openReportModal(lat = 21.9162, lng = 95.9560) {
    document.getElementById('field-lat').value = Number(lat).toFixed(6);
    document.getElementById('field-lng').value = Number(lng).toFixed(6);

    // Auto-populate local datetime
    const now = new Date();
    const localIsoTime = new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
    document.getElementById('field-time').value = localIsoTime;

    // Set reporter name if logged in
    const reporterInput = document.getElementById('field-reporter');
    if (typeof currentUsername !== 'undefined' && currentUsername.trim() !== "") {
        reporterInput.value = currentUsername;
    }

    if (reportModalInstance) {
        reportModalInstance.show();
    }
}

/**
 * Submit field report to ReportDisasterServlet via POST /api/reports
 */
async function submitHazardReport(event) {
    event.preventDefault();

    const submitBtn = document.getElementById('btn-submit-report');
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> ပေးပို့နေသည်...';

    const params = new URLSearchParams();
    params.append('title', document.getElementById('field-title').value);
    params.append('category', document.getElementById('field-category').value);
    params.append('risk_level', document.getElementById('field-risk').value);
    params.append('latitude', document.getElementById('field-lat').value);
    params.append('longitude', document.getElementById('field-lng').value);
    params.append('recorded_time', document.getElementById('field-time').value);
    params.append('reporter_name', document.getElementById('field-reporter').value || 'Anonymous Operator');
    params.append('description', document.getElementById('field-description').value);

    try {
        const response = await fetch('api/reports', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: params.toString()
        });

        const result = await response.json();

        if (response.ok && result.success) {
            alert('✅ ' + result.message);
            if (reportModalInstance) reportModalInstance.hide();
            document.getElementById('reportHazardForm').reset();
            // Refresh to load any state updates
            loadAllDashboardData();
        } else {
            alert('⚠️ တင်ပြမှု မအောင်မြင်ပါ: ' + (result.message || 'Server error occurred.'));
        }
    } catch (err) {
        console.error('Error submitting hazard report:', err);
        alert('⚠️ ကွန်ရက်ချိတ်ဆက်မှု အမှားရှိပါသည်။ (Failed to connect to /api/reports)');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane me-1"></i> အတည်ပြုပေးပို့မည်';
    }
}

function bookmarkEvent(encodedEventId) {
    const eventId = decodeURIComponent(encodedEventId);

    if (typeof isLoggedIn !== 'undefined' && !isLoggedIn) {
        alert('⚠️ ကျေးဇူးပြု၍ ပထမဆုံး အကောင့်ဝင်ပါ (Please login first to bookmark events).');
        window.location.href = 'login.jsp';
        return;
    }

    fetch('api/bookmark?eventId=' + encodeURIComponent(eventId), { method: 'POST' })
        .then(async res => {
            if (res.status === 401) {
                alert('⚠️ ကျေးဇူးပြု၍ ပထမဆုံး အကောင့်ဝင်ပါ (Unauthorized).');
                window.location.href = 'login.jsp';
                return;
            }

            const data = await res.json().catch(() => null);

            if (res.ok && data) {
                if (data.status === 'SUCCESS') {
                    alert('✅ ဘေးအန္တရာယ် အချက်အလက်ကို အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ!');
                } else if (data.status === 'EXISTS') {
                    alert('ℹ️ ဤအချက်အလက်ကို သိမ်းဆည်းပြီးသား ဖြစ်ပါသည် (Already bookmarked).');
                } else {
                    alert('⚠️ သိမ်းဆည်း၍ မရပါ။ (Could not save bookmark).');
                }
            } else {
                let errorMsg = (data && data.message) ? data.message : 'Database error occurred';
                alert('⚠️ ဆာဗာ သို့မဟုတ် ဒေတာဘေ့စ် အမှားရှိပါသည်: ' + errorMsg);
            }
        })
        .catch(err => {
            console.error('Error bookmarking:', err);
            alert('⚠️ ဆာဗာချိတ်ဆက်မှု အမှားရှိပါသည်။ (Network error)');
        });
}