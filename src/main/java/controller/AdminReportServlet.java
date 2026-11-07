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
import java.util.List;

@WebServlet("/admin/reports")
public class AdminReportServlet extends HttpServlet {

    private ReportedDisasterDao disasterDao;

    @Override
    public void init() {
        this.disasterDao = new ReportedDisasterDao();
    }

    /**
     * GET /admin/reports
     * Returns JSON list of all reports or filtered by status.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String status = request.getParameter("status");
        List<ReportedDisaster> reports;

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            reports = disasterDao.getReportsByStatus(status.trim());
        } else {
            reports = disasterDao.getAllReports();
        }

        PrintWriter out = response.getWriter();
        out.print(buildJsonArray(reports));
        out.flush();
    }

    /**
     * POST /admin/reports
     * Parameters: id, action ('verify', 'resolve', 'pending')
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String idStr = request.getParameter("id");
        String action = request.getParameter("action");

        if (idStr == null || action == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Missing id or action.\"}");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            String newStatus;

            switch (action.toLowerCase()) {
                case "verify":
                    newStatus = "Verified";
                    break;
                case "resolve":
                    newStatus = "Resolved";
                    break;
                case "pending":
                    newStatus = "Pending";
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\": false, \"message\": \"Invalid action.\"}");
                    return;
            }

            boolean updated = disasterDao.updateStatus(id, newStatus);

            if (updated) {
                out.print("{\"success\": true, \"message\": \"Report status updated to " + newStatus + ".\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\": false, \"message\": \"Database update failed.\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Invalid ID format.\"}");
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
            if (i < reports.size() - 1) sb.append(",");
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