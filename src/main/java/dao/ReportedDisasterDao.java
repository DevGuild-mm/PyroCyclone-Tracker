package dao;

import model.ReportedDisaster;
import util.DbConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportedDisasterDao {

    /**
     * Inserts a new crowdsourced disaster report.
     */
    public boolean insertReport(ReportedDisaster report) {
        String sql = "INSERT INTO reported_disasters " +
                "(title, category, risk_level, description, latitude, longitude, recorded_time, reporter_name, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DbConnection.openConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, report.getTitle());
            ps.setString(2, report.getCategory());
            ps.setString(3, report.getRiskLevel());
            ps.setString(4, report.getDescription());
            ps.setBigDecimal(5, report.getLatitude());
            ps.setBigDecimal(6, report.getLongitude());
            ps.setTimestamp(7, report.getRecordedTime());
            ps.setString(8, report.getReporterName());
            ps.setString(9, report.getStatus());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        report.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Fetches verified reports for the public dashboard map.
     */
    public List<ReportedDisaster> getVerifiedReports() {
        return getReportsByStatus("Verified");
    }

    /**
     * Fetches reports filtered by status (e.g., 'Pending', 'Verified', 'Resolved').
     */
    public List<ReportedDisaster> getReportsByStatus(String status) {
        List<ReportedDisaster> reports = new ArrayList<>();
        String sql = "SELECT * FROM reported_disasters WHERE status = ? ORDER BY recorded_time DESC";

        try (Connection conn = DbConnection.openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reports.add(mapResultSetToReport(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reports;
    }

    /**
     * Fetches all reports (for admin moderation).
     */
    public List<ReportedDisaster> getAllReports() {
        List<ReportedDisaster> reports = new ArrayList<>();
        String sql = "SELECT * FROM reported_disasters ORDER BY created_at DESC";

        try (Connection conn = DbConnection.openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                reports.add(mapResultSetToReport(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reports;
    }

    /**
     * Finds reports within a given radius in kilometers using the Haversine formula.
     */
    public List<ReportedDisaster> findReportsNearLocation(double lat, double lon, double radiusKm) {
        List<ReportedDisaster> reports = new ArrayList<>();
        String sql = "SELECT *, (" +
                "  6371 * acos(" +
                "    cos(radians(?)) * cos(radians(latitude)) * " +
                "    cos(radians(longitude) - radians(?)) + " +
                "    sin(radians(?)) * sin(radians(latitude))" +
                "  )" +
                ") AS distance " +
                "FROM reported_disasters " +
                "WHERE status = 'Verified' " +
                "HAVING distance < ? " +
                "ORDER BY distance ASC";

        try (Connection conn = DbConnection.openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDouble(1, lat);
            ps.setDouble(2, lon);
            ps.setDouble(3, lat);
            ps.setDouble(4, radiusKm);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reports.add(mapResultSetToReport(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reports;
    }

    /**
     * Updates moderation status ('Pending', 'Verified', 'Resolved').
     */
    public boolean updateStatus(int id, String newStatus) {
        String sql = "UPDATE reported_disasters SET status = ? WHERE id = ?";

        try (Connection conn = DbConnection.openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private ReportedDisaster mapResultSetToReport(ResultSet rs) throws SQLException {
        return new ReportedDisaster(
                rs.getInt("id"),
                rs.getString("title"),
                rs.getString("category"),
                rs.getString("risk_level"),
                rs.getString("description"),
                rs.getBigDecimal("latitude"),
                rs.getBigDecimal("longitude"),
                rs.getTimestamp("recorded_time"),
                rs.getString("reporter_name"),
                rs.getString("status"),
                rs.getTimestamp("created_at")
        );
    }
}