<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("currentUser");
    String username = (sessionUser != null) ? sessionUser.getUsername() : "Admin";
    boolean isAdmin = (sessionUser != null && "admin".equalsIgnoreCase(sessionUser.getRole()));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Incident Moderation - Command Center</title>

    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts - Inter, JetBrains Mono & Padauk -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@500;700&family=Padauk:wght@400;700&display=swap" rel="stylesheet">

    <!-- Unified Command Center Stylesheet -->
    <style>
        :root {
            --bg-deep: #07090e;
            --nav-bg: #0c1220;
            --card-surface: rgba(15, 23, 42, 0.90);
            --border-dim: rgba(255, 255, 255, 0.12);
            --accent-orange: #f97316;
            --text-main: #ffffff;
            --text-sub: #cbd5e1;
            --text-muted: #94a3b8;
        }

        body {
            background-color: var(--bg-deep);
            background-image:
                radial-gradient(ellipse at 15% 10%, rgba(249, 115, 22, 0.1), transparent 45%),
                radial-gradient(ellipse at 85% 90%, rgba(6, 182, 212, 0.08), transparent 40%);
            font-family: 'Inter', 'Padauk', sans-serif;
            color: var(--text-main);
            min-height: 100vh;
        }

        /* 1. Unified Navigation Bar */
        .navbar-command {
            background-color: var(--nav-bg);
            border-bottom: 1px solid var(--border-dim);
            padding: 10px 24px;
        }

        .brand-logo-box {
            width: 38px;
            height: 38px;
            background: rgba(249, 115, 22, 0.15);
            border: 1px solid rgba(249, 115, 22, 0.4);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--accent-orange);
            font-size: 18px;
        }

        .nav-switch-link {
            color: var(--text-sub);
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 600;
            padding: 7px 16px;
            border-radius: 8px;
            border: 1px solid transparent;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
        }

        .nav-switch-link:hover {
            color: #ffffff;
            background: rgba(255, 255, 255, 0.05);
            border-color: rgba(255, 255, 255, 0.1);
        }

        .nav-switch-link.active {
            color: var(--accent-orange);
            background: rgba(249, 115, 22, 0.15);
            border-color: rgba(249, 115, 22, 0.35);
            font-weight: 700;
        }

        .pulse-badge {
            display: inline-flex;
            align-items: center;
            padding: 5px 12px;
            background: rgba(239, 68, 68, 0.18);
            border: 1px solid rgba(239, 68, 68, 0.4);
            color: #fca5a5;
            border-radius: 50px;
            font-weight: 700;
            font-size: 11px;
            letter-spacing: 0.5px;
        }

        .pulse-dot {
            width: 7px;
            height: 7px;
            background-color: #ef4444;
            border-radius: 50%;
            margin-right: 7px;
            box-shadow: 0 0 10px #ef4444;
            animation: pulse-animation 2s infinite;
        }

        @keyframes pulse-animation {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(239, 68, 68, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
        }

        .user-identity-box {
            background: rgba(15, 23, 42, 0.8);
            border: 1px solid var(--border-dim);
            border-radius: 30px;
            padding: 4px 14px 4px 6px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
        }

        .role-badge {
            font-size: 10px;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 12px;
            font-family: 'JetBrains Mono', monospace;
        }
        .role-admin { background: #0284c7; color: #ffffff; }

        /* 2. Moving Alert Marquee Bar (UNDER NAVBAR) */
        .subnav-marquee-banner {
            background: linear-gradient(90deg, #18090b 0%, #2d0d0f 50%, #18090b 100%);
            border-bottom: 1px solid rgba(239, 68, 68, 0.35);
            padding: 7px 0;
            font-size: 13px;
            font-weight: 600;
            color: #ffffff;
        }

        .marquee-tag {
            background: #991b1b;
            color: #ffffff;
            font-size: 11px;
            font-weight: 700;
            padding: 2px 10px;
            border-radius: 6px;
            margin-right: 14px;
            white-space: nowrap;
            letter-spacing: 0.5px;
        }

        .marquee-content {
            display: inline-block;
            white-space: nowrap;
            animation: marquee 35s linear infinite;
        }

        @keyframes marquee {
            0% { transform: translateX(100%); }
            100% { transform: translateX(-100%); }
        }

        /* 3. Moderation Console Components */
        .hud-card {
            background: var(--card-surface);
            backdrop-filter: blur(20px);
            border: 1px solid var(--border-dim);
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.6);
        }

        .metric-card {
            background: rgba(15, 23, 42, 0.7);
            border: 1px solid var(--border-dim);
            border-radius: 14px;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .metric-card .metric-label {
            font-size: 11px;
            font-weight: 700;
            color: var(--text-muted);
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .metric-card .metric-val {
            font-family: 'JetBrains Mono', monospace;
            font-size: 26px;
            font-weight: 700;
        }

        .table-custom {
            --bs-table-bg: transparent;
            color: #ffffff;
            vertical-align: middle;
            margin-bottom: 0;
        }

        .table-custom thead th {
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            color: #94a3b8;
            border-bottom: 1px solid rgba(255, 255, 255, 0.15);
            padding: 14px;
            background: rgba(7, 10, 18, 0.5);
        }

        .table-custom tbody td {
            font-size: 13.5px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.07);
            padding: 14px;
            color: #f1f5f9;
        }

        .table-custom tbody tr:hover {
            background: rgba(255, 255, 255, 0.04);
        }

        .badge-status {
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            padding: 4px 10px;
            border-radius: 6px;
            font-weight: 700;
        }

        .badge-pending {
            background: rgba(245, 158, 11, 0.2);
            color: #fde047;
            border: 1px solid #f59e0b;
        }

        .badge-verified {
            background: rgba(16, 185, 129, 0.2);
            color: #6ee7b7;
            border: 1px solid #10b981;
        }

        .badge-resolved {
            background: rgba(148, 163, 184, 0.15);
            color: #cbd5e1;
            border: 1px solid #94a3b8;
        }

        .filter-btn-group .btn {
            font-size: 12.5px;
            font-weight: 700;
            border: 1px solid rgba(255, 255, 255, 0.16);
            color: var(--text-sub);
            padding: 6px 14px;
            background: rgba(7, 10, 18, 0.6);
        }

        .filter-btn-group .btn.active {
            background: var(--accent-orange);
            color: #05070d;
            border-color: var(--accent-orange);
            box-shadow: 0 0 12px rgba(249, 115, 22, 0.4);
        }

        .search-box {
            background: #090d16 !important;
            border: 1px solid rgba(255, 255, 255, 0.18) !important;
            color: #ffffff !important;
            border-radius: 8px;
            font-size: 13.5px;
        }

        .search-box:focus {
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 2px rgba(249, 115, 22, 0.25) !important;
        }

        .search-box::placeholder {
            color: #64748b;
        }
    </style>
</head>
<body>

    <!-- 1. TOP UNIFIED NAVIGATION BAR -->
    <nav class="navbar navbar-expand-xl navbar-command sticky-top shadow-sm">
        <div class="container-fluid px-2 px-md-3">
            <!-- Brand -->
            <a class="navbar-brand d-flex align-items-center gap-2 text-white fw-bold me-2 me-lg-3" href="index.jsp">
                <div class="brand-logo-box">
                    <i class="fa-solid fa-fire-flame-curved"></i>
                </div>
                <div>
                    <div style="line-height: 1.1; font-size: 14px;">MYANMAR DISASTER COMMAND</div>
                    <small class="text-warning fw-semibold" style="font-size: 10px;">Incident Triage & Moderation Console</small>
                </div>
            </a>

            <!-- Toggle Button for Mobile/Tablet -->
            <button class="navbar-toggler border-secondary bg-dark text-white ms-auto me-2" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavbarContent" aria-controls="adminNavbarContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <!-- Collapsible Wrapper -->
            <div class="collapse navbar-collapse justify-content-between align-items-center" id="adminNavbarContent">
                <!-- Page Navigation Tabs -->
                <div class="d-flex align-items-center gap-2 my-2 my-xl-0">
                    <a href="index.jsp" class="nav-switch-link">
                        <i class="fa-solid fa-map-location-dot me-1.5"></i> Live Map
                    </a>
                    <a href="admin.jsp" class="nav-switch-link active">
                        <i class="fa-solid fa-shield-halved me-1.5"></i> Moderation Console
                    </a>
                </div>

                <!-- Right Controls -->
                <div class="d-flex flex-wrap align-items-center gap-2.5 my-2 my-xl-0">
                    <!-- Live Status Indicator -->
                    <div class="pulse-badge">
                        <span class="pulse-dot"></span>
                        <span>TRIAGE ACTIVE</span>
                    </div>

                    <!-- Admin Identity Box -->
                    <div class="user-identity-box">
                        <i class="fa-solid fa-user-shield text-info ms-1"></i>
                        <span class="fw-semibold text-white"><%= username %></span>
                        <span class="role-badge role-admin">ADMIN</span>
                    </div>

                    <a href="logout" class="btn btn-outline-danger btn-sm rounded-pill px-3 py-1 fw-bold shadow-none">
                        <i class="fa-solid fa-right-from-bracket me-1"></i> Logout
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- 2. MOVING ALERT MARQUEE BAR (UNDER NAV BAR) -->
    <div class="subnav-marquee-banner shadow-sm">
        <div class="container-fluid d-flex align-items-center px-4">
            <span class="marquee-tag">
                <i class="fa-solid fa-shield-halved me-1"></i> MODERATION STATUS
            </span>
            <div class="overflow-hidden flex-grow-1">
                <div id="marquee-content" class="marquee-content">
                    <span>🛡️ စိစစ်ရေးစင်တာ အသင့်ဖြစ်နေပါသည် - ကွင်းဆင်းသတင်းပို့ချက်များကို စိစစ်အတည်ပြုခြင်းဖြင့် အများပြည်သူမြေပုံပေါ်တွင် တိုက်ရိုက်ဖော်ပြပေးနိုင်ပါသည်။ (Incident Moderation Active - Verify field reports to publish live to map).</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Container -->
    <div class="container-fluid py-4 px-4">

        <!-- KPI Telemetry Cards -->
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="metric-card">
                    <div>
                        <div class="metric-label">Pending Triage</div>
                        <div class="metric-val text-warning" id="kpi-pending">--</div>
                    </div>
                    <div class="fs-1 text-warning opacity-50"><i class="fa-solid fa-hourglass-half"></i></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card">
                    <div>
                        <div class="metric-label">Verified Active</div>
                        <div class="metric-val text-success" id="kpi-verified">--</div>
                    </div>
                    <div class="fs-1 text-success opacity-50"><i class="fa-solid fa-circle-check"></i></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card">
                    <div>
                        <div class="metric-label">Resolved Cases</div>
                        <div class="metric-val text-info" id="kpi-resolved">--</div>
                    </div>
                    <div class="fs-1 text-info opacity-50"><i class="fa-solid fa-box-archive"></i></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card">
                    <div>
                        <div class="metric-label">Total Submissions</div>
                        <div class="metric-val text-light" id="kpi-total">--</div>
                    </div>
                    <div class="fs-1 text-light opacity-50"><i class="fa-solid fa-database"></i></div>
                </div>
            </div>
        </div>

        <!-- Filter and Search Toolbar -->
        <div class="hud-card p-3 mb-3">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
                <div class="d-flex align-items-center gap-2">
                    <span class="small fw-bold text-sub me-2">FILTER BY STATUS:</span>
                    <div class="btn-group filter-btn-group" role="group">
                        <button type="button" class="btn active" onclick="setFilter('Pending', this)">Pending Triage</button>
                        <button type="button" class="btn" onclick="setFilter('Verified', this)">Verified</button>
                        <button type="button" class="btn" onclick="setFilter('Resolved', this)">Resolved</button>
                        <button type="button" class="btn" onclick="setFilter('all', this)">All Records</button>
                    </div>
                </div>

                <div style="min-width: 280px;">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-dark border-secondary text-warning"><i class="fa-solid fa-magnifying-glass"></i></span>
                        <input type="text" id="admin-search-input" class="form-control search-box" placeholder="Search title, reporter, or notes..." oninput="handleClientSearch()">
                    </div>
                </div>
            </div>
        </div>

        <!-- Moderation Data Table -->
        <div class="hud-card overflow-hidden">
            <div class="table-responsive">
                <table class="table table-custom">
                    <thead>
                        <tr>
                            <th style="width: 70px;">ID</th>
                            <th>Incident Title & Notes</th>
                            <th>Category</th>
                            <th>Risk Level</th>
                            <th>GPS Coordinates</th>
                            <th>Reporter</th>
                            <th>Recorded Time</th>
                            <th>Status</th>
                            <th class="text-end" style="min-width: 170px;">Action Controls</th>
                        </tr>
                    </thead>
                    <tbody id="reports-tbody">
                        <tr><td colspan="9" class="text-center text-sub py-5"><span class="spinner-border spinner-border-sm me-2"></span>Loading records...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- Scripts without EL syntax collisions -->
    <script>
        var currentFilterStatus = 'Pending';
        var cachedReports = [];

        document.addEventListener('DOMContentLoaded', function () {
            loadReports('Pending');
        });

        function setFilter(status, btn) {
            currentFilterStatus = status;
            document.querySelectorAll('.filter-btn-group .btn').forEach(function(b) {
                b.classList.remove('active');
            });
            btn.classList.add('active');
            loadReports(status);
        }

       async function loadReports(status) {
           var tbody = document.getElementById('reports-tbody');
           tbody.innerHTML = '<tr><td colspan="9" class="text-center text-sub py-5"><span class="spinner-border spinner-border-sm me-2"></span>Loading records...</td></tr>';

           try {
               // JSP ရဲ့ contextPath ကို တိုက်ရိုက်ယူသုံးခြင်း
               var contextPath = '<%= request.getContextPath() %>';
               var res = await fetch(contextPath + '/admin/reports?status=' + encodeURIComponent(status));
               if (!res.ok) throw new Error('Status code: ' + res.status);
               var reports = await res.json();
               cachedReports = reports;

               // Sync KPI metrics
               fetch(contextPath + '/admin/reports?status=all')
                   .then(function(r) { return r.json(); })
                   .then(function(allData) { updateKpis(allData); })
                   .catch(function(e) { console.warn('KPI sync error', e); });

               renderTableRows(cachedReports);

           } catch (err) {
               console.error(err);
               tbody.innerHTML = '<tr><td colspan="9" class="text-center text-danger py-5 fw-bold">⚠️ ဆာဗာ သို့မဟုတ် ဒေတာဘေ့စ် ချိတ်ဆက်မှု အမှားရှိပါသည် (Failed to load reports).</td></tr>';
           }
       }

        function updateKpis(allList) {
            if (!Array.isArray(allList)) return;
            var pending = 0, verified = 0, resolved = 0;
            allList.forEach(function(item) {
                if (item.status === 'Verified') verified++;
                else if (item.status === 'Resolved') resolved++;
                else pending++;
            });
            document.getElementById('kpi-pending').innerText = pending;
            document.getElementById('kpi-verified').innerText = verified;
            document.getElementById('kpi-resolved').innerText = resolved;
            document.getElementById('kpi-total').innerText = allList.length;
        }

        function handleClientSearch() {
            var q = document.getElementById('admin-search-input').value.toLowerCase().trim();
            if (!q) {
                renderTableRows(cachedReports);
                return;
            }
            var filtered = cachedReports.filter(function(r) {
                return (r.title && r.title.toLowerCase().indexOf(q) !== -1) ||
                       (r.reporterName && r.reporterName.toLowerCase().indexOf(q) !== -1) ||
                       (r.category && r.category.toLowerCase().indexOf(q) !== -1) ||
                       (r.description && r.description.toLowerCase().indexOf(q) !== -1);
            });
            renderTableRows(filtered);
        }

        function renderTableRows(reports) {
            var tbody = document.getElementById('reports-tbody');
            if (!reports || reports.length === 0) {
                tbody.innerHTML = '<tr><td colspan="9" class="text-center text-sub py-5"><i class="fa-regular fa-folder-open mb-2 fs-3 d-block"></i>No matching incident reports found.</td></tr>';
                return;
            }

            var rows = '';
            reports.forEach(function (r) {
                var statusClass = r.status === 'Verified' ? 'badge-verified' : (r.status === 'Pending' ? 'badge-pending' : 'badge-resolved');
                var riskColor = r.riskLevel === 'High Risk' ? 'text-danger fw-bold' : (r.riskLevel === 'Moderate' ? 'text-warning fw-bold' : 'text-info fw-bold');
                var lat = Number(r.latitude).toFixed(4);
                var lng = Number(r.longitude).toFixed(4);
                var desc = r.description ? r.description : 'No field notes provided.';

                var actions = '';
                if (r.status !== 'Verified') {
                    actions += '<button class="btn btn-sm btn-success py-1 px-2.5 me-1 fw-bold" title="Approve & Show on Public Map" onclick="updateReportStatus(' + r.id + ', \'verify\')"><i class="fa-solid fa-check me-1"></i>Approve</button>';
                }
                if (r.status !== 'Resolved') {
                    actions += '<button class="btn btn-sm btn-outline-secondary py-1 px-2 me-1" title="Mark Closed" onclick="updateReportStatus(' + r.id + ', \'resolve\')"><i class="fa-solid fa-box-archive"></i></button>';
                }
                if (r.status !== 'Pending') {
                    actions += '<button class="btn btn-sm btn-outline-warning py-1 px-2" title="Move back to Pending" onclick="updateReportStatus(' + r.id + ', \'pending\')"><i class="fa-solid fa-rotate-left"></i></button>';
                }

                var gmapsUrl = 'https://www.google.com/maps?q=' + lat + ',' + lng;

                rows += '<tr>' +
                    '<td class="font-monospace text-warning fw-bold">#' + r.id + '</td>' +
                    '<td>' +
                        '<div class="fw-bold text-white mb-1" style="font-size: 14px;">' + escapeHtml(r.title) + '</div>' +
                        '<div class="small" style="max-width: 320px; font-size: 12px; color: #cbd5e1; line-height: 1.4;">' + escapeHtml(desc) + '</div>' +
                    '</td>' +
                    '<td><span class="badge bg-dark border border-secondary text-light px-2.5 py-1">' + escapeHtml(r.category) + '</span></td>' +
                    '<td class="' + riskColor + '">' + escapeHtml(r.riskLevel) + '</td>' +
                    '<td>' +
                        '<a href="' + gmapsUrl + '" target="_blank" class="text-decoration-none text-info font-monospace small fw-bold" title="Open in Google Maps">' +
                            '<i class="fa-solid fa-location-dot me-1"></i>' + lat + ', ' + lng +
                        '</a>' +
                    '</td>' +
                    '<td><span class="fw-semibold text-white">' + escapeHtml(r.reporterName) + '</span></td>' +
                    '<td><small class="font-monospace" style="color: #cbd5e1;">' + escapeHtml(r.recordedTime) + '</small></td>' +
                    '<td><span class="badge-status ' + statusClass + '">' + escapeHtml(r.status) + '</span></td>' +
                    '<td class="text-end">' + actions + '</td>' +
                '</tr>';
            });
            tbody.innerHTML = rows;
        }

       async function updateReportStatus(reportId, action) {
           var formData = new URLSearchParams();
           formData.append('id', reportId);
           formData.append('action', action);

           try {
               var contextPath = '<%= request.getContextPath() %>';
               var res = await fetch(contextPath + '/admin/reports', {
                   method: 'POST',
                   headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                   body: formData.toString()
               });
               var data = await res.json();
               if (res.ok && data.success) {
                   loadReports(currentFilterStatus);
               } else {
                   alert('Update failed: ' + (data.message || 'Server error'));
               }
           } catch (err) {
               alert('Connection error occurred.');
           }
       }
        function escapeHtml(text) {
            if (!text) return '';
            return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        }
    </script>
</body>
</html>