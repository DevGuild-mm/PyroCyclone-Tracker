package controller;

import dao.ReportedDisasterDao;
import model.ReportedDisaster;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/api/reports")
public class ReportDisasterServlet extends HttpServlet {

    private ReportedDisasterDao disasterDao;

    @Override
    public void init() {
        this.disasterDao = new ReportedDisasterDao();
    }

    /**
     * GET /api/reports
     * Query Parameters:
     *   - status: 'Verified' (default), 'Pending', 'Resolved', or 'all'
     *   - lat, lng, radius: Optional bounding search for nearby reports
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String statusParam = request.getParameter("status");
        String latParam = request.getParameter("lat");
        String lngParam = request.getParameter("lng");
        String radiusParam = request.getParameter("radius");

        List<ReportedDisaster> reports;

        try {
            if (latParam != null && lngParam != null) {
                double lat = Double.parseDouble(latParam);
                double lng = Double.parseDouble(lngParam);
                double radius = radiusParam != null ? Double.parseDouble(radiusParam) : 50.0;
                reports = disasterDao.findReportsNearLocation(lat, lng, radius);
            } else if ("all".equalsIgnoreCase(statusParam)) {
                reports = disasterDao.getAllReports();
            } else if (statusParam != null && !statusParam.trim().isEmpty()) {
                reports = disasterDao.getReportsByStatus(statusParam.trim());
            } else {
                reports = disasterDao.getVerifiedReports();
            }

            PrintWriter out = response.getWriter();
            out.print(buildJsonArray(reports));
            out.flush();
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Coordinates must be valid numbers.\"}");
        }
    }

    /**
     * POST /api/reports
     * Accepts form parameters or URL-encoded payloads.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String title = request.getParameter("title");
        String category = request.getParameter("category");
        String riskLevel = request.getParameter("risk_level");
        String description = request.getParameter("description");
        String latStr = request.getParameter("latitude");
        String lngStr = request.getParameter("longitude");
        String recordedTimeStr = request.getParameter("recorded_time");
        String reporterName = request.getParameter("reporter_name");

        if (title == null || category == null || riskLevel == null || latStr == null || lngStr == null ||
                title.trim().isEmpty() || latStr.trim().isEmpty() || lngStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Missing required fields.\"}");
            return;
        }

        try {
            BigDecimal latitude = new BigDecimal(latStr.trim());
            BigDecimal longitude = new BigDecimal(lngStr.trim());

            Timestamp recordedTime;
            if (recordedTimeStr != null && !recordedTimeStr.trim().isEmpty()) {
                String normalizedTime = recordedTimeStr.replace("T", " ");
                if (normalizedTime.length() == 16) {
                    normalizedTime += ":00";
                }
                recordedTime = Timestamp.valueOf(normalizedTime);
            } else {
                recordedTime = Timestamp.valueOf(LocalDateTime.now());
            }

            ReportedDisaster report = new ReportedDisaster(
                    title.trim(),
                    category.trim(),
                    riskLevel.trim(),
                    description != null ? description.trim() : "",
                    latitude,
                    longitude,
                    recordedTime,
                    reporterName,
                    "Pending"
            );

            boolean inserted = disasterDao.insertReport(report);

            if (inserted) {
                response.setStatus(HttpServletResponse.SC_CREATED);
                out.print("{\"success\": true, \"message\": \"Hazard report submitted successfully. Status: Pending.\", \"id\": " + report.getId() + "}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\": false, \"message\": \"Database insert failed.\"}");
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Invalid latitude or longitude.\"}");
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Invalid date-time format. Use yyyy-MM-ddTHH:mm.\"}");
        }
    }

    private String buildJsonArray(List<ReportedDisaster> reports) {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (int i = 0; i < reports.size(); i++) {
            ReportedDisaster r = reports.get(i);
            sb.append("{")
                    .append("\"id\":").append(r.getId()).append(",")
                    .append("\"title\":\"").append(escapeJson(r.getTitle())).append("\",")
                    .append("\"category\":\"").append(escapeJson(r.getCategory())).append("\",")
                    .append("\"riskLevel\":\"").append(escapeJson(r.getRiskLevel())).append("\",")
                    .append("\"description\":\"").append(escapeJson(r.getDescription())).append("\",")
                    .append("\"latitude\":").append(r.getLatitude()).append(",")
                    .append("\"longitude\":").append(r.getLongitude()).append(",")
                    .append("\"recordedTime\":\"").append(r.getRecordedTime()).append("\",")
                    .append("\"reporterName\":\"").append(escapeJson(r.getReporterName())).append("\",")
                    .append("\"status\":\"").append(escapeJson(r.getStatus())).append("\",")
                    .append("\"createdAt\":\"").append(r.getCreatedAt()).append("\"")
                    .append("}");
            if (i < reports.size() - 1) {
                sb.append(",");
            }
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}