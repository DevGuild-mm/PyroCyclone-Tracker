let fireChartInstance = null;
let mapInstance = null;
let nasaHotspotLayer = null;
let communityReportLayer = null;
let regionBoundaryLayer = null;
let globalEmergencyAlerts = [];
let reportModalInstance = null;

const MYANMAR_REGIONS_DATA = {
    "all": {
        nameMm: "တစ်နိုင်ငံလုံး",
        nameEn: "All Myanmar",
        center: [21.9162, 95.9560],
        zoom: 6,
        keywords: []
    },
    "kachin": {
        nameMm: "ကချင်ပြည်နယ်",
        nameEn: "Kachin State",
        center: [25.5, 97.5],
        zoom: 7,
        keywords: ["kachin", "myitkyina", "bhamo", "ကချင်"],
        polygon: [
            [23.8, 96.2], [24.3, 97.0], [24.7, 97.6], [25.5, 98.2], [26.8, 98.8],
            [28.4, 98.0], [28.5, 97.3], [27.0, 96.0], [25.7, 96.3], [24.4, 95.8], [23.8, 96.2]
        ]
    },
    "kayah": {
        nameMm: "ကယားပြည်နယ်",
        nameEn: "Kayah State",
        center: [19.25, 97.35],
        zoom: 8,
        keywords: ["kayah", "loikaw", "ကယား"],
        polygon: [
            [18.5, 96.9], [19.1, 96.9], [19.8, 97.1], [19.8, 97.8], [19.2, 97.9],
            [18.6, 97.6], [18.5, 96.9]
        ]
    },
    "kayin": {
        nameMm: "ကရင်ပြည်နယ်",
        nameEn: "Kayin State",
        center: [16.8, 97.8],
        zoom: 8,
        keywords: ["kayin", "karen", "hpa-an", "ကရင်"],
        polygon: [
            [15.2, 98.3], [16.0, 98.6], [17.3, 98.2], [18.5, 97.5], [19.2, 96.9],
            [18.3, 96.7], [17.4, 97.1], [16.4, 97.5], [15.2, 98.3]
        ]
    },
    "chin": {
        nameMm: "ချင်းပြည်နယ်",
        nameEn: "Chin State",
        center: [22.0, 93.6],
        zoom: 8,
        keywords: ["chin", "hakha", "ချင်း"],
        polygon: [
            [21.0, 93.8], [21.5, 94.1], [22.8, 94.0], [24.1, 93.4], [23.5, 93.1],
            [22.0, 93.0], [21.2, 93.2], [21.0, 93.8]
        ]
    },
    "sagaing": {
        nameMm: "စစ်ကိုင်းတိုင်း",
        nameEn: "Sagaing Region",
        center: [23.5, 95.5],
        zoom: 7,
        keywords: ["sagaing", "monywa", "shwebo", "စစ်ကိုင်း", "မုံရွာ"],
        polygon: [
            [21.8, 95.9], [22.0, 95.0], [22.5, 94.5], [23.5, 94.1], [24.8, 94.5],
            [26.5, 95.3], [26.0, 96.2], [24.2, 96.1], [22.8, 96.0], [21.8, 95.9]
        ]
    },
    "tanintharyi": {
        nameMm: "တနင်္သာရီတိုင်း",
        nameEn: "Tanintharyi Region",
        center: [12.8, 98.8],
        zoom: 7,
        keywords: ["tanintharyi", "dawei", "myeik", "တနင်္သာရီ", "ထားဝယ်"],
        polygon: [
            [9.8, 98.5], [10.5, 98.8], [11.8, 99.2], [13.4, 99.1], [15.1, 98.0],
            [14.8, 97.8], [13.4, 98.2], [11.5, 98.4], [9.8, 98.5]
        ]
    },
    "bago": {
        nameMm: "ပဲခူးတိုင်း",
        nameEn: "Bago Region",
        center: [18.0, 96.2],
        zoom: 8,
        keywords: ["bago", "pyay", "taungoo", "ပဲခူး"],
        polygon: [
            [16.8, 96.4], [17.5, 97.0], [18.8, 96.9], [19.4, 96.2], [19.0, 95.1],
            [18.0, 95.2], [17.2, 95.8], [16.8, 96.4]
        ]
    },
    "magway": {
        nameMm: "မကွေးတိုင်း",
        nameEn: "Magway Region",
        center: [20.3, 94.8],
        zoom: 7,
        keywords: ["magway", "pakokku", "မကွေး", "ပခုက္ကူ"],
        polygon: [
            [18.9, 95.1], [19.5, 95.7], [20.8, 95.5], [21.8, 95.0], [21.5, 94.0],
            [20.5, 94.2], [19.5, 94.3], [18.9, 95.1]
        ]
    },
    "mandalay": {
        nameMm: "မန္တလေးတိုင်း",
        nameEn: "Mandalay Region",
        center: [21.5, 96.0],
        zoom: 7,
        keywords: ["mandalay", "meiktila", "pyin oo lwin", "မန္တလေး"],
        polygon: [
            [19.7, 95.9], [20.5, 96.3], [21.8, 96.5], [22.4, 96.0], [21.9, 95.5],
            [20.6, 95.4], [19.7, 95.9]
        ]
    },
    "mon": {
        nameMm: "မွန်ပြည်နယ်",
        nameEn: "Mon State",
        center: [16.1, 97.6],
        zoom: 8,
        keywords: ["mon", "mawlamyine", "thaton", "မွန်", "မော်လမြိုင်"],
        polygon: [
            [14.9, 97.9], [15.3, 98.1], [16.2, 97.8], [17.4, 97.2], [16.8, 97.0],
            [15.8, 97.4], [14.9, 97.9]
        ]
    },
    "rakhine": {
        nameMm: "ရခိုင်ပြည်နယ်",
        nameEn: "Rakhine State",
        center: [19.8, 93.8],
        zoom: 7,
        keywords: ["rakhine", "sittwe", "thandwe", "murasu", "ရခိုင်", "စစ်တွေ"],
        polygon: [
            [17.5, 94.6], [18.5, 94.2], [19.5, 93.5], [20.5, 92.8], [21.4, 92.3],
            [21.2, 93.0], [20.2, 93.8], [18.8, 94.5], [17.5, 94.6]
        ]
    },
    "yangon": {
        nameMm: "ရန်ကုန်တိုင်း",
        nameEn: "Yangon Region",
        center: [17.0, 96.15],
        zoom: 9,
        keywords: ["yangon", "rangoon", "ရန်ကုန်"],
        polygon: [
            [16.4, 96.1], [16.6, 96.4], [17.2, 96.4], [17.5, 96.1], [17.2, 95.8],
            [16.7, 95.9], [16.4, 96.1]
        ]
    },
    "shan": {
        nameMm: "ရှမ်းပြည်နယ်",
        nameEn: "Shan State",
        center: [21.8, 98.2],
        zoom: 7,
        keywords: ["shan", "taunggyi", "lashio", "kengtung", "ရှမ်း", "တောင်ကြီး"],
        polygon: [
            [19.6, 97.0], [20.5, 96.5], [22.0, 96.4], [23.8, 96.8], [24.1, 98.2],
            [23.2, 99.0], [22.5, 99.8], [21.5, 101.1], [20.4, 100.2], [19.8, 98.5], [19.6, 97.0]
        ]
    },
    "ayeyarwady": {
        nameMm: "ဧရာဝတီတိုင်း",
        nameEn: "Ayeyarwady Region",
        center: [16.8, 95.2],
        zoom: 8,
        keywords: ["ayeyarwady", "irrawaddy", "pathein", "ဧရာဝတီ", "ပုသိမ်"],
        polygon: [
            [15.7, 95.2], [16.0, 95.8], [17.1, 95.8], [17.8, 95.2], [17.2, 94.7],
            [16.1, 94.3], [15.7, 95.2]
        ]
    },
    "naypyidaw": {
        nameMm: "နေပြည်တော်",
        nameEn: "Naypyidaw Union Territory",
        center: [19.76, 96.08],
        zoom: 9,
        keywords: ["naypyidaw", "nay pyi taw", "နေပြည်တော်"],
        polygon: [
            [19.45, 96.0], [19.6, 96.3], [20.05, 96.2], [20.0, 95.85], [19.55, 95.85], [19.45, 96.0]
        ]
    }
};

const FALLBACK_NASA_EVENTS = [
    {
        title: "Shan State Wildfire Outbreak",
        date: "2026-11-04",
        isStorm: false,
        coordinates: [97.0331, 21.9162]
    },
    {
        title: "Sagaing Forest Fire Hotspot",
        date: "2026-11-06",
        isStorm: false,
        coordinates: [95.1350, 22.1086]
    },
    {
        title: "Tropical Cyclone Murasu (Rakhine Coast)",
        date: "2026-11-07",
        isStorm: true,
        coordinates: [93.5000, 18.5000]
    }
];

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

    regionBoundaryLayer = L.layerGroup().addTo(mapInstance);
    nasaHotspotLayer = L.layerGroup().addTo(mapInstance);
    communityReportLayer = L.layerGroup().addTo(mapInstance);

    const modalEl = document.getElementById('reportHazardModal');
    if (modalEl) {
        reportModalInstance = new bootstrap.Modal(modalEl);
    }

    mapInstance.on('click', function (e) {
        openReportModal(e.latlng.lat, e.latlng.lng);
    });

    loadAllDashboardData('all');

    const riskFilter = document.getElementById('filter-risk');
    if (riskFilter) riskFilter.addEventListener('change', applyFilters);

    const dateFilter = document.getElementById('filter-date');
    if (dateFilter) dateFilter.addEventListener('input', applyFilters);

    const categoryFilter = document.getElementById('filter-category');
    if (categoryFilter) {
        categoryFilter.addEventListener('change', function () {
            loadAllDashboardData(this.value);
        });
    }
});

window.onRegionSelectChange = function (regionKey) {
    const region = MYANMAR_REGIONS_DATA[regionKey];
    if (!region || !mapInstance) return;

    if (regionBoundaryLayer) {
        regionBoundaryLayer.clearLayers();
    }

    const filterInput = document.getElementById('filter-date');

    if (regionKey === "all") {
        mapInstance.flyTo(region.center, region.zoom, { duration: 1.2 });
        if (filterInput) filterInput.value = "";
        applyFilters();
        return;
    }

    let regionHazards = globalEmergencyAlerts.filter(alert => {
        let text = (alert.township + " " + alert.desc).toLowerCase();
        return region.keywords.some(kw => text.includes(kw.toLowerCase()));
    });

    if (region.polygon) {
        const polygonLayer = L.polygon(region.polygon, {
            color: '#f97316',
            weight: 3.5,
            opacity: 1.0,
            fillColor: '#f97316',
            fillOpacity: 0.18,
            dashArray: '5, 5'
        }).addTo(regionBoundaryLayer);

        polygonLayer.bindPopup(`
            <div style="font-size: 13px; color: #0f172a; min-width: 210px;">
                <h6 style="font-weight: bold; margin-bottom: 2px; color: #c2410c;">📍 ${region.nameMm}</h6>
                <small class="text-muted fw-semibold">${region.nameEn}</small>
                <hr style="margin: 6px 0;"/>
                <div style="font-size: 11.5px; line-height: 1.5;">
                    <b>ဒေသတွင်း ဘေးအန္တရာယ်:</b> <span class="badge ${regionHazards.length > 0 ? 'bg-danger' : 'bg-success'}">${regionHazards.length} ခု</span><br>
                    ${regionHazards.length > 0
            ? '<span class="text-danger fw-bold">⚠️ တောမီး သို့မဟုတ် မုန်တိုင်း သတိပေးချက် တည်ရှိနေပါသည်။</span>'
            : '<span class="text-success fw-bold">✅ လက်ရှိတွင် ကြီးမားသော ဘေးအန္တရာယ် မရှိပါ။</span>'}
                </div>
            </div>
        `);

        mapInstance.fitBounds(polygonLayer.getBounds(), { padding: [35, 35], maxZoom: region.zoom + 1 });
        setTimeout(() => polygonLayer.openPopup(), 450);
    } else {
        mapInstance.flyTo(region.center, region.zoom, { duration: 1.2 });
    }

    if (filterInput) {
        filterInput.value = region.nameEn.split(" ")[0];
        applyFilters();
    }
};

async function loadAllDashboardData(category = 'all') {
    let rawNasaData = null;
    let verifiedReports = [];

    try {
        let nasaUrl = 'api/events?days=30';
        if (category !== 'all') {
            nasaUrl += '&category=' + category;
        }
        const nasaRes = await fetch(nasaUrl);
        if (nasaRes.ok) {
            const text = await nasaRes.text();
            try {
                rawNasaData = JSON.parse(text);
            } catch (err) {
                console.warn("NASA API returned non-JSON:", text.substring(0, 80));
            }
        }
    } catch (e) {
        console.warn("Error fetching api/events:", e);
    }

    try {
        const commRes = await fetch('api/reports?status=Verified');
        if (commRes.ok) {
            const text = await commRes.text();
            try {
                verifiedReports = JSON.parse(text);
            } catch (err) {
                console.warn("Reports API returned non-JSON:", text.substring(0, 80));
            }
        }
    } catch (e) {
        console.warn("Error fetching api/reports:", e);
    }

    processCombinedData(rawNasaData, verifiedReports);
}

function extractCoordinates(geometry) {
    if (!geometry) return [95.9560, 21.9162];

    if (geometry.coordinates) {
        let coords = geometry.coordinates;
        while (Array.isArray(coords) && coords.length > 0 && Array.isArray(coords[0])) {
            coords = coords[0];
        }
        if (Array.isArray(coords) && coords.length >= 2) {
            return [Number(coords[0]) || 95.9560, Number(coords[1]) || 21.9162];
        }
    }

    if (Array.isArray(geometry) && geometry.length > 0) {
        let latest = geometry[geometry.length - 1];
        if (latest && latest.coordinates) {
            return [Number(latest.coordinates[0]) || 95.9560, Number(latest.coordinates[1]) || 21.9162];
        }
    }

    return [95.9560, 21.9162];
}

function processCombinedData(nasaPayload, communityReports) {
    let rawEvents = [];

    if (Array.isArray(nasaPayload)) {
        rawEvents = nasaPayload;
    } else if (nasaPayload && Array.isArray(nasaPayload.features)) {
        rawEvents = nasaPayload.features;
    } else if (nasaPayload && Array.isArray(nasaPayload.events)) {
        rawEvents = nasaPayload.events;
    }

    if (!rawEvents || rawEvents.length === 0) {
        rawEvents = FALLBACK_NASA_EVENTS;
    }

    let wildfireCount = 0;
    let stormCount = 0;
    let floodCount = 0;
    let combinedAlerts = [];
    let nasaHotspots = [];
    let dateMap = {};

    rawEvents.forEach((item) => {
        try {
            const props = item.properties || item;
            const geom = item.geometry || item.geometries || { coordinates: item.coordinates };
            const [lng, lat] = extractCoordinates(geom);

            const title = props.title || "Disaster Event";
            const eventDate = props.date ? props.date.substring(0, 10) : "Recent";

            const lowerTitle = title.toLowerCase();
            let isStorm = item.isStorm || lowerTitle.includes('cyclone') || lowerTitle.includes('storm') || lowerTitle.includes('hurricane') || lowerTitle.includes('typhoon');

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
            let latVal = parseFloat(rep.latitude) || 21.9162;
            let lngVal = parseFloat(rep.longitude) || 95.9560;

            combinedAlerts.push({
                source: 'COMMUNITY',
                risk: rep.riskLevel || 'Moderate',
                township: rep.title + " (အစီရင်ခံသူ: " + rep.reporterName + ")",
                time: repDate,
                desc: rep.description || "ကွင်းဆင်း စိစစ်အတည်ပြုထားသော ဘေးအန္တရာယ် သတင်းပေးပို့ချက်။",
                isStorm: isStorm,
                isFlood: isFlood,
                lat: latVal,
                lng: lngVal
            });

            verifiedCommunitySpots.push({
                id: rep.id,
                lat: latVal,
                lng: lngVal,
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

    let communityCount = Array.isArray(communityReports) ? communityReports.length : 0;
    let totalCases = rawEvents.length + communityCount;

    const topAlertText = totalCases > 0
        ? `⚠️ သတိပေးချက် - တောမီး (${wildfireCount})၊ မုန်တိုင်း (${stormCount})၊ ရေကြီးမှု (${floodCount}) နှင့် ကွင်းဆင်းသတင်း (${communityCount}) ခု တည်ရှိနေပါသည်။`
        : "လက်ရှိတွင် သဘာဝဘေး အရေးပေါ်သတိပေးချက် မရှိပါ။";

    updateMarqueeAlert(topAlertText);

    document.getElementById('stat-total-cases').innerText = totalCases;
    document.getElementById('stat-active-hotspots').innerText = wildfireCount;
    document.getElementById('stat-community-reports').innerText = communityCount + " Verified";
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
        container.innerHTML = '<p class="text-muted small text-center py-4">ဤဒေသတွင် လတ်တလော ဘေးအန္တရာယ် သတိပေးချက် မရှိပါ (No active alerts).</p>';
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
            <div class="alert-item ${borderClass}" onclick="focusOnAlert(${item.lat}, ${item.lng})">
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

window.focusOnAlert = function(lat, lng) {
    if (mapInstance && lat && lng) {
        mapInstance.flyTo([lat, lng], 9, { duration: 1.0 });
    }
};

function applyFilters() {
    const selectedRisk = document.getElementById('filter-risk').value;
    const dateQuery = document.getElementById('filter-date').value.toLowerCase().trim();

    const filtered = globalEmergencyAlerts.filter(item => {
        const matchRisk = selectedRisk === "" || item.risk === selectedRisk;
        const matchDate = dateQuery === "" ||
            item.time.toLowerCase().includes(dateQuery) ||
            item.township.toLowerCase().includes(dateQuery) ||
            item.desc.toLowerCase().includes(dateQuery);
        return matchRisk && matchDate;
    });

    renderEmergencyAlerts(filtered);
}

function updateChart(chartData) {
    const chartEl = document.getElementById('fireChart');
    if (!chartEl || typeof Chart === 'undefined') return;

    const ctx = chartEl.getContext('2d');
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
    if (!nasaHotspotLayer) return;
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
    if (!communityReportLayer) return;
    communityReportLayer.clearLayers();

    reports.forEach(rep => {
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

function openReportModal(lat = 21.9162, lng = 95.9560) {
    document.getElementById('field-lat').value = Number(lat).toFixed(6);
    document.getElementById('field-lng').value = Number(lng).toFixed(6);

    const now = new Date();
    const localIsoTime = new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
    document.getElementById('field-time').value = localIsoTime;

    const reporterInput = document.getElementById('field-reporter');
    if (typeof currentUsername !== 'undefined' && currentUsername.trim() !== "") {
        reporterInput.value = currentUsername;
    }

    if (reportModalInstance) {
        reportModalInstance.show();
    }
}

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