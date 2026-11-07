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

    // Strict Myanmar & Surrounding Region Boundary Limits (prevents panning out to the global view)
    const myanmarBounds = L.latLngBounds([9.0, 91.5], [28.8, 101.5]);

    mapInstance = L.map('map', {
        center: [21.9162, 95.9560],
        zoom: 6,
        layers: [googleRoadmapLayer],
        maxBounds: myanmarBounds,
        maxBoundsViscosity: 1.0, // Prevents panning outside the box completely
        minZoom: 5               // Prevents zooming out past regional view
    });

    hotspotLayerGroup = L.layerGroup().addTo(mapInstance);

    // Initial fetch
    fetchDashboardData('all');

    // Bind filters
    document.getElementById('filter-risk').addEventListener('change', applyFilters);
    document.getElementById('filter-date').addEventListener('input', applyFilters);

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
        document.getElementById('marquee-content').innerHTML = "<span>⚠️ အမှား: ဘက်ခ်အင်ဒ်ဒေတာသို့ ချိတ်ဆက်၍ မရပါ။</span>";
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
            // Myanmar Language Descriptions
            let myanmarDesc = isStorm
                ? "🌀 မုန်တိုင်း/စိုင်ကလုန်းအန္တရာယ် သတိပေးချက် ထုတ်ပြန်ထားသည်။ ဒေသခံများ အထူးသတိပြုရန်။"
                : "🔥 တောမီးလောင်မှုအန္တရာယ် သတိပြုရန်။ မီးဘေးအရေးပေါ် သတိပေးချက် ထုတ်ပြန်ထားသည်။";
            let iconSymbol = isStorm ? "🌀" : "🔥";

            emergencyAlerts.push({
                risk: risk,
                township: title,
                time: eventDate,
                desc: myanmarDesc,
                isStorm: isStorm,
                lat: lat,
                lng: lng
            });

            hotspots.push({
                lat: lat,
                lng: lng,
                radius: isStorm ? 30000 : 15000,
                region: title,
                status: risk,
                iconSymbol: iconSymbol,
                date: eventDate,
                desc: myanmarDesc
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
        ? "⚠️ သတိပေးချက်များ - တောမီး (" + wildfireCount + ") နှင့် မုန်တိုင်း/စိုင်ကလုန်း (" + stormCount + ") များ တည်ရှိနေပါသည်။"
        : "လက်ရှိတွင် သဘာဝဘေး အရေးပေါ်သတိပေးချက် မရှိပါ။";

    updateMarqueeAlert(topAlertText);

    document.getElementById('stat-total-cases').innerText = totalCases;
    document.getElementById('stat-active-hotspots').innerText = wildfireCount;
    document.getElementById('stat-burned-acres').innerText = (wildfireCount * 1250).toLocaleString();
    document.getElementById('stat-high-risk').innerText = stormCount + " Storms";

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
            '<span class="fw-bold ' + textClass + ' small">' + (item.isStorm ? '🌀 မုန်တိုင်း: ' : '🔥 တောမီး: ') + item.township + '</span>' +
            '<span class="text-muted" style="font-size: 10px;">' + item.time + '</span>' +
            '</div>' +
            '<p class="mb-0 text-light small">' + item.desc + '</p>' +
            '<div class="mt-1 text-end"><small class="text-muted" style="font-size: 9px;">📍 Lat: ' + item.lat.toFixed(3) + ', Lng: ' + item.lng.toFixed(3) + '</small></div>' +
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
            fillOpacity: 0.25,
            weight: 1.5
        }).addTo(hotspotLayerGroup);

        const customIcon = L.divIcon({
            className: '',
            html: '<div style="font-size: 30px; line-height: 30px; filter: drop-shadow(0 0 8px rgba(0,0,0,0.9)); text-align: center;">' + spot.iconSymbol + '</div>',
            iconSize: [36, 36],
            iconAnchor: [18, 18]
        });

        // Detailed popup content including the Bookmark action button
        let popupContent = `
            <div style="font-size: 13px; color: #1e293b; min-width: 200px;">
                <h6 style="font-weight: bold; margin-bottom: 6px; color: #0f172a;">${spot.iconSymbol} ${spot.region}</h6>
                <p style="margin-bottom: 4px; font-size: 11.5px;"><b>အမျိုးအစား (Category):</b> ${spot.iconSymbol === '🌀' ? 'မုန်တိုင်း (Storm)' : 'တောမီး (Wildfire)'}</p>
                <p style="margin-bottom: 4px; font-size: 11.5px;"><b>ရက်စွဲ (Date):</b> ${spot.date || 'Recent'}</p>
                <p style="margin-bottom: 6px; font-size: 11.5px;"><b>တည်နေရာ (Coordinates):</b> ${spot.lat.toFixed(4)}, ${spot.lng.toFixed(4)}</p>
                <p style="margin-bottom: 8px; font-size: 11px; background: #f1f5f9; padding: 6px; border-radius: 4px;">${spot.desc || 'Active hazard warning issued.'}</p>
                <button onclick="bookmarkEvent('${encodeURIComponent(spot.region)}')" class="btn btn-sm btn-outline-warning w-100 py-1" style="font-size: 11px; font-weight: bold; background-color: #d97706; color: #fff;">⭐ Save Bookmark</button>
            </div>
        `;

        L.marker([spot.lat, spot.lng], { icon: customIcon })
            .bindPopup(popupContent)
            .addTo(hotspotLayerGroup);
    });
}

// Frontend handler that talks to your BookmarkServlet (/api/bookmark)
function bookmarkEvent(encodedEventId) {
    const eventId = decodeURIComponent(encodedEventId);

    // Check frontend session state injected from index.jsp
    if (typeof isLoggedIn !== 'undefined' && !isLoggedIn) {
        alert('⚠️ ကျေးဇူးပြု၍ ပထမဆုံး အကောင့်ဝင်ပါ (Please login first to bookmark events).');
        window.location.href = 'login.jsp';
        return;
    }

    fetch('api/bookmark?eventId=' + encodeURIComponent(eventId), { method: 'POST' })
        .then(async res => {
            if (res.status === 401) {
                alert('⚠️ ကျေးဇူးပြု၍ ပထမဆုံး အကောင့်ဝင်ပါ (Unauthorized. Please login first).');
                window.location.href = 'login.jsp';
                return;
            }

            const data = await res.json().catch(() => null);

            if (res.ok && data) {
                if (data.status === 'SUCCESS') {
                    alert('✅ ဘေးအန္တရာယ် အချက်အလက်ကို အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ (Event bookmarked successfully)!');
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