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

    // Initial fetch
    fetchDashboardData('all');

    // Bind filters
    document.getElementById('filter-risk').addEventListener('change', applyFilters);
    document.getElementById('filter-date').addEventListener('input', applyFilters);

    // Add Category Filter Listener if present
    const categoryFilter = document.getElementById('filter-category');
    if (categoryFilter) {
        categoryFilter.addEventListener('change', function() {
            fetchDashboardData(this.value);
        });
    }
});

async function fetchDashboardData(category = 'all') {
    try {
        let url = 'api/events?days=30';
        if (category !== 'all') {
            url += '&category=' + category;
        }

        const response = await fetch(url);
        if (!response.ok) throw new Error('Failed to fetch data from proxy servlet.');

        const geoJson = await response.json();
        parseEonetData(geoJson);

    } catch (error) {
        console.error("Error loading dashboard data:", error);
        document.getElementById('marquee-content').innerHTML = "<span>⚠️ Error: Unable to connect to backend data.</span>";
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
            const [lng, lat] = extractCoordinates(feature.geometry);

            const title = props.title || "Disaster Event";
            const eventDate = props.date ? props.date.substring(0, 10) : "Recent";

            const lowerTitle = title.toLowerCase();
            let isStorm = lowerTitle.includes('cyclone') || lowerTitle.includes('storm') || lowerTitle.includes('hurricane') || lowerTitle.includes('typhoon');

            if (isStorm) stormCount++;
            else wildfireCount++;

            let risk = "High Risk";
            let myanmarDesc = isStorm
                ? "မုန်တိုင်း/စိုင်ကလုန်းအန္တရာယ် သတိပေးချက် ထုတ်ပြန်ထားသည်။"
                : "တောမီးလောင်မှုအန္တရာယ် သတိပြုရန်။ မီးဘေးသတိပေးချက် ထုတ်ပြန်ထားသည်။";
            let iconSymbol = isStorm ? "🌀" : "🔥";

            emergencyAlerts.push({
                risk: risk,
                township: title,
                time: eventDate,
                desc: myanmarDesc,
                isStorm: isStorm
            });

            hotspots.push({
                lat: lat,
                lng: lng,
                radius: isStorm ? 30000 : 15000,
                region: title,
                status: risk,
                iconSymbol: iconSymbol
            });

            dateMap[eventDate] = (dateMap[eventDate] || 0) + 1;
        } catch (err) {
            console.warn("Skipping feature:", err);
        }
    });

    const sortedDates = Object.keys(dateMap).sort();
    sortedDates.forEach(d => {
        chartLabels.push(d);
        chartCounts.push(dateMap[d]);
    });

    if (sortedDates.length === 0) {
        chartLabels = ["No Data"];
        chartCounts = [0];
    }

    const topAlertText = totalCases > 0
        ? "⚠️ တောမီး (" + wildfireCount + ") နှင့် မုန်တိုင်း (" + stormCount + ") သတိပေးချက်များ တည်ရှိနေပါသည်။"
        : "လက်ရှိတွင် သဘာဝဘေး အရေးပေါ်သတိပေးချက် မရှိပါ။";

    updateMarqueeAlert(topAlertText);

    // Update stats with separated counts
    document.getElementById('stat-total-cases').innerText = totalCases;
    document.getElementById('stat-active-hotspots').innerText = wildfireCount; // Fire specific count
    document.getElementById('stat-burned-acres').innerText = (wildfireCount * 1250).toLocaleString();
    document.getElementById('stat-high-risk').innerText = stormCount + " Storms"; // Storm specific count

    globalEmergencyAlerts = emergencyAlerts;
    renderEmergencyAlerts(globalEmergencyAlerts);

    updateChart({ labels: chartLabels, caseCounts: chartCounts });
    updateMapHotspots(hotspots);
}

function updateMarqueeAlert(alertText) {
    const marqueeEl = document.getElementById('marquee-content');
    marqueeEl.innerHTML = '<span>' + alertText + '</span><span>' + alertText + '</span>';
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
        let borderClass = item.isStorm ? 'info' : 'danger';
        let textClass = item.isStorm ? 'text-info' : 'text-danger';

        htmlContent += '<div class="alert-item ' + borderClass + '">' +
            '<div class="d-flex justify-content-between align-items-center mb-1">' +
            '<span class="fw-bold ' + textClass + ' small">' + (item.isStorm ? '🌀 Storm: ' : '🔥 Wildfire: ') + item.township + '</span>' +
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

function updateChart(chartData) {
    const ctx = document.getElementById('fireChart').getContext('2d');
    if (fireChartInstance) fireChartInstance.destroy();

    fireChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: chartData.labels,
            datasets: [{
                label: 'ဘေးအန္တရာယ်ဖြစ်ပွားမှု',
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
        let circleColor = spot.iconSymbol === '🌀' ? '#06b6d4' : '#ff4757';

        L.circle([spot.lat, spot.lng], {
            radius: spot.radius,
            color: circleColor,
            fillColor: circleColor,
            fillOpacity: 0.2,
            weight: 1
        }).addTo(hotspotLayerGroup);

        const customIcon = L.divIcon({
            className: '',
            html: '<div style="font-size: 20px; filter: drop-shadow(0 0 6px rgba(0,0,0,0.8));">' + spot.iconSymbol + '</div>',
            iconSize: [24, 24]
        });

        L.marker([spot.lat, spot.lng], { icon: customIcon })
            .bindPopup('<b>' + spot.region + '</b><br>အမျိုးအစား: ' + (spot.iconSymbol === '🌀' ? 'မုန်တိုင်း (Storm)' : 'တောမီး (Wildfire)'))
            .addTo(hotspotLayerGroup);
    });
}