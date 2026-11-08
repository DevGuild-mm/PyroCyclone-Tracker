let fireChartInstance = null;
let mapInstance = null;
let nasaHotspotLayer = null;
let communityReportLayer = null;
let regionBoundaryLayer = null;
let myanmarGeoJsonLayer = null;
let myanmarGeoJsonData = null;
let globalEmergencyAlerts = [];
let reportModalInstance = null;

// Exact colors from your reference map + accurate property matchers
const MYANMAR_REGIONS_DATA = {
    "all": { nameMm: "တစ်နိုင်ငံလုံး", nameEn: "All Myanmar", center: [21.9162, 95.9560], zoom: 6, keywords: [] },
    "kachin": {
        nameMm: "ကချင်ပြည်နယ်", nameEn: "Kachin State", color: "#2574a9",
        match: ["kachin"], keywords: ["kachin", "myitkyina", "bhamo", "ကချင်"],
        center: [25.8, 97.4], zoom: 7
    },
    "kayah": {
        nameMm: "ကယားပြည်နယ်", nameEn: "Kayah State", color: "#8c821e",
        match: ["kayah", "karenni"], keywords: ["kayah", "loikaw", "ကယား"],
        center: [19.2, 97.3], zoom: 8
    },
    "kayin": {
        nameMm: "ကရင်ပြည်နယ်", nameEn: "Kayin State", color: "#de7a73",
        match: ["kayin", "karen"], keywords: ["kayin", "karen", "hpa-an", "ကရင်"],
        center: [17.0, 97.8], zoom: 7
    },
    "chin": {
        nameMm: "ချင်းပြည်နယ်", nameEn: "Chin State", color: "#d46a6a",
        match: ["chin"], keywords: ["chin", "hakha", "ချင်း"],
        center: [22.5, 93.5], zoom: 7
    },
    "sagaing": {
        nameMm: "စစ်ကိုင်းတိုင်း", nameEn: "Sagaing Region", color: "#b8e186",
        // Added "saigang" to match your GeoJSON shapeName spelling
        match: ["sagaing", "saigang"], keywords: ["sagaing", "saigang", "monywa", "shwebo", "စစ်ကိုင်း", "မုံရွာ"],
        center: [23.8, 95.3], zoom: 7
    },
    "tanintharyi": {
        nameMm: "တနင်္သာရီတိုင်း", nameEn: "Tanintharyi Region", color: "#d953c4",
        // If missing from ADM1, falls back gracefully to bounding center coordinates
        match: ["tanintharyi", "tenasserim", "taninthari", "dawei", "myeik"], keywords: ["tanintharyi", "dawei", "myeik", "တနင်္သာရီ", "ထားဝယ်"],
        center: [12.5, 98.8], zoom: 7
    },
    "bago": {
        nameMm: "ပဲခူးတိုင်း", nameEn: "Bago Region", color: "#34a832",
        match: ["bago", "pegu"], keywords: ["bago", "pyay", "taungoo", "ပဲခူး"],
        center: [18.1, 96.1], zoom: 7
    },
    "magway": {
        nameMm: "မကွေးတိုင်း", nameEn: "Magway Region", color: "#9e9e9e",
        match: ["magway", "magwe"], keywords: ["magway", "pakokku", "မကွေး", "ပခုက္ကူ"],
        center: [20.2, 94.9], zoom: 7
    },
    "mandalay": {
        nameMm: "မန္တလေးတိုင်း", nameEn: "Mandalay Region", color: "#1d4ed8",
        match: ["mandalay"], keywords: ["mandalay", "meiktila", "pyin oo lwin", "မန္တလေး"],
        center: [21.1, 96.0], zoom: 7
    },
    "mon": {
        nameMm: "မွန်ပြည်နယ်", nameEn: "Mon State", color: "#00b4ff",
        match: ["mon"], keywords: ["mon", "mawlamyine", "thaton", "မွန်", "မော်လမြိုင်"],
        center: [16.2, 97.6], zoom: 8
    },
    "rakhine": {
        nameMm: "ရခိုင်ပြည်နယ်", nameEn: "Rakhine State", color: "#456b48",
        match: ["rakhine", "arakan"], keywords: ["rakhine", "sittwe", "thandwe", "murasu", "ရခိုင်", "စစ်တွေ"],
        center: [19.5, 93.6], zoom: 7
    },
    "yangon": {
        nameMm: "ရန်ကုန်တိုင်း", nameEn: "Yangon Region", color: "#ff1100",
        match: ["yangon", "rangoon"], keywords: ["yangon", "rangoon", "ရန်ကုန်"],
        center: [16.9, 96.15], zoom: 8
    },
    "shan": {
        nameMm: "ရှမ်းပြည်နယ်", nameEn: "Shan State", color: "#a6cee3",
        match: ["shan"], keywords: ["shan", "taunggyi", "lashio", "kengtung", "ရှမ်း", "တောင်ကြီး"],
        center: [21.5, 98.2], zoom: 7
    },
    "ayeyarwady": {
        nameMm: "ဧရာဝတီတိုင်း", nameEn: "Ayeyarwady Region", color: "#ff9999",
        match: ["ayeyarwady", "irrawaddy"], keywords: ["ayeyarwady", "irrawaddy", "pathein", "ဧရာဝတီ", "ပုသိမ်"],
        center: [16.8, 95.1], zoom: 7
    },
    "naypyidaw": {
        nameMm: "နေပြည်တော်", nameEn: "Naypyidaw Union Territory", color: "#f97316",
        // Maps smoothly to Mandalay/Bago boundary area if unified in ADM1
        match: ["naypyidaw", "nay pyi taw", "naypyitaw", "mandalay", "bago"], keywords: ["naypyidaw", "nay pyi taw", "နေပြည်တော်"],
        center: [19.76, 96.08], zoom: 9
    },
};

const FALLBACK_NASA_EVENTS = [
    { title: "Shan State Wildfire Outbreak", date: "2026-11-04", isStorm: false, coordinates: [21.9162, 97.0331] },
    { title: "Sagaing Forest Fire Hotspot", date: "2026-11-06", isStorm: false, coordinates: [22.1086, 95.1350] },
    { title: "Kachin Mountain Wildfire", date: "2026-11-07", isStorm: false, coordinates: [25.4000, 97.4000] },
    { title: "Tropical Cyclone Murasu (Rakhine Coast)", date: "2026-11-07", isStorm: true, coordinates: [19.5000, 93.5000] }
];

document.addEventListener("DOMContentLoaded", async function () {
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

    // Load dashboard data and GeoJSON borders
    await loadAllDashboardData('all');
    await loadMyanmarGeoJsonBorders();
});

function matchRegionKeyFromFeature(feature) {
    if (!feature || !feature.properties) return null;
    const propsStr = JSON.stringify(feature.properties).toLowerCase();
    for (let key in MYANMAR_REGIONS_DATA) {
        if (key === "all") continue;
        const matches = MYANMAR_REGIONS_DATA[key].match || [];
        if (matches.some(m => propsStr.includes(m))) {
            return key;
        }
    }
    return null;
}

async function loadMyanmarGeoJsonBorders() {
    if (!myanmarGeoJsonData) {
        // 1. Try local file first, then exact HDX/geoBoundaries commit 9469f09
        const urls = [
            'js/myanmar_states.geojson?v=' + Date.now(),
            'https://raw.githubusercontent.com/wmgeolab/geoBoundaries/9469f09/releaseData/gbOpen/MMR/ADM1/geoBoundaries-MMR-ADM1_simplified.geojson',
            'https://cdn.jsdelivr.net/gh/wmgeolab/geoBoundaries@9469f09/releaseData/gbOpen/MMR/ADM1/geoBoundaries-MMR-ADM1_simplified.geojson'
        ];

        for (const url of urls) {
            try {
                const res = await fetch(url);
                if (res.ok) {
                    const text = await res.text();
                    if (text.trim().startsWith('version https://git-lfs')) {
                        console.warn(`Local file ${url} is still a Git LFS pointer, fetching from CDN...`);
                        continue;
                    }
                    const parsed = JSON.parse(text);
                    if (parsed && Array.isArray(parsed.features) && parsed.features.length > 0) {
                        myanmarGeoJsonData = parsed;
                        console.log("✅ Loaded accurate Myanmar GeoJSON with", parsed.features.length, "features.");
                        break;
                    }
                }
            } catch (err) {
                console.warn(`Failed loading GeoJSON from ${url}:`, err);
            }
        }
    }

    if (!myanmarGeoJsonData) return;

    if (myanmarGeoJsonLayer) {
        regionBoundaryLayer.removeLayer(myanmarGeoJsonLayer);
    }

    // Draw subtle state/region borders across all of Myanmar
    myanmarGeoJsonLayer = L.geoJSON(myanmarGeoJsonData, {
        style: function (feature) {
            const key = matchRegionKeyFromFeature(feature);
            const regionColor = key ? MYANMAR_REGIONS_DATA[key].color : '#334155';
            return {
                color: '#1e293b',
                weight: 1.2,
                opacity: 0.7,
                fillColor: regionColor,
                fillOpacity: 0.12
            };
        },
        onEachFeature: function (feature, layer) {
            const key = matchRegionKeyFromFeature(feature);
            if (key) {
                const reg = MYANMAR_REGIONS_DATA[key];
                layer.bindTooltip(`<b>${reg.nameMm}</b> (${reg.nameEn})`, { sticky: true });
            }
            layer.on('click', function (e) {
                L.DomEvent.stopPropagation(e);
                if (key) {
                    document.getElementById('region-jump-select').value = key;
                    window.onRegionSelectChange(key);
                }
            });
        }
    }).addTo(regionBoundaryLayer);
}

window.onRegionSelectChange = async function (regionKey) {
    const region = MYANMAR_REGIONS_DATA[regionKey];
    if (!region || !mapInstance) return;

    if (regionBoundaryLayer) {
        regionBoundaryLayer.clearLayers();
    }

    // Ensure GeoJSON is loaded
    await loadMyanmarGeoJsonBorders();

    const filterInput = document.getElementById('filter-date');

    if (regionKey === "all") {
        mapInstance.flyTo(region.center, region.zoom, { duration: 1.2 });
        if (filterInput) filterInput.value = "";
        applyFilters();
        return;
    }

    // Match all features belonging to the selected region (e.g. Shan North/South/East)
    let matchedFeatures = [];
    if (myanmarGeoJsonData && myanmarGeoJsonData.features) {
        matchedFeatures = myanmarGeoJsonData.features.filter(f => matchRegionKeyFromFeature(f) === regionKey);
    }

    let regionHazards = globalEmergencyAlerts.filter(alert => {
        let text = (alert.township + " " + alert.desc).toLowerCase();
        return region.keywords.some(kw => text.includes(kw.toLowerCase()));
    });

    // Draw the exact region border when selected!
    if (matchedFeatures.length > 0) {
        const highlightColor = region.color || '#f97316';
        const exactBorderLayer = L.geoJSON({ type: "FeatureCollection", features: matchedFeatures }, {
            style: {
                color: '#f97316',          // Crisp orange outer border
                weight: 3.5,
                opacity: 1.0,
                fillColor: highlightColor, // Reference map region color fill
                fillOpacity: 0.45
            }
        }).addTo(regionBoundaryLayer);

        bindPopupAndFit(exactBorderLayer, region, regionHazards);
    } else {
        mapInstance.flyTo(region.center, region.zoom, { duration: 1.2 });
    }

    if (filterInput) {
        filterInput.value = region.nameEn.split(" ")[0];
        applyFilters();
    }
};

function bindPopupAndFit(layer, region, regionHazards) {
    layer.bindPopup(`
        <div style="font-size: 13px; color: #0f172a; min-width: 210px;">
            <h6 style="font-weight: bold; margin-bottom: 2px; color: #c2410c;">📍 ${region.nameMm}</h6>
            <small style="color: #475569; font-weight: 600;">${region.nameEn}</small>
            <hr style="margin: 6px 0;"/>
            <div style="font-size: 11.5px; line-height: 1.5;">
                <b>ဒေသတွင်း ဘေးအန္တရာယ်:</b> <span class="badge ${regionHazards.length > 0 ? 'bg-danger' : 'bg-success'}">${regionHazards.length} ခု</span><br>
                ${regionHazards.length > 0
            ? '<span class="text-danger fw-bold">⚠️ တောမီး သို့မဟုတ် မုန်တိုင်း သတိပေးချက် တည်ရှိနေပါသည်။</span>'
            : '<span class="text-success fw-bold">✅ လက်ရှိတွင် ကြီးမားသော ဘေးအန္တရာယ် မရှိပါ။</span>'}
            </div>
        </div>
    `);

    mapInstance.fitBounds(layer.getBounds(), { padding: [35, 35] });
    setTimeout(() => layer.openPopup(), 450);
}

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
    if (!geometry) return [21.9162, 95.9560];

    if (geometry.coordinates) {
        let coords = geometry.coordinates;
        while (Array.isArray(coords) && coords.length > 0 && Array.isArray(coords[0])) {
            coords = coords[0];
        }
        if (Array.isArray(coords) && coords.length >= 2) {
            return [Number(coords[1]) || 21.9162, Number(coords[0]) || 95.9560];
        }
    }

    if (Array.isArray(geometry) && geometry.length >= 2) {
        return [Number(geometry[0]) || 21.9162, Number(geometry[1]) || 95.9560];
    }

    return [21.9162, 95.9560];
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
            const geom = item.geometry || item.geometries || item.coordinates;
            const [lat, lng] = extractCoordinates(geom);

            const title = props.title || item.title || "Disaster Event";
            const eventDate = props.date || item.date ? (props.date || item.date).substring(0, 10) : "Recent";

            const lowerTitle = title.toLowerCase();
            let isStorm = item.isStorm || lowerTitle.includes('cyclone') || lowerTitle.includes('storm') || lowerTitle.includes('hurricane') || lowerTitle.includes('typhoon');

            if (isStorm) stormCount++;
            else wildfireCount++;

            let risk = "High Risk";
            let myanmarDesc = isStorm ? "🌀 မုန်တိုင်း/စိုင်ကလုန်းအန္တရာယ် သတိပေးချက်" : "🔥 တောမီးလောင်မှုအန္တရာယ် သတိပေးချက်";
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
                    <span class="text-muted" style="font-size: 10.5px;">${item.time}</span>
                </div>
                <p class="mb-0 text-white small">${item.desc}</p>
                <div class="mt-1 d-flex justify-content-between align-items-center">
                    <span class="badge bg-dark border border-secondary text-white" style="font-size: 9.5px;">${item.risk}</span>
                    <small class="text-muted" style="font-size: 10px;">📍 Lat: ${item.lat.toFixed(3)}, Lng: ${item.lng.toFixed(3)}</small>
                </div>
            </div>`;
    });

    container.innerHTML = htmlContent;
}

window.focusOnAlert = function (lat, lng) {
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
                backgroundColor: 'rgba(249, 115, 22, 0.15)',
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
                x: { ticks: { color: '#e2e8f0', font: { size: 10.5 } }, grid: { color: 'rgba(255,255,255,0.08)' } },
                y: { ticks: { color: '#e2e8f0', font: { size: 10.5 } }, grid: { color: 'rgba(255,255,255,0.08)' } }
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