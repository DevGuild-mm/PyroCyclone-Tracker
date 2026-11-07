package dao;

import util.DbConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class BookmarkDao {

    // Returns: "SUCCESS", "EXISTS", or "ERROR"
    public String addBookmark(int userId, String eventId) {
        String checkQuery = "SELECT 1 FROM user_bookmarks WHERE user_id = ? AND event_id = ?";
        String insertQuery = "INSERT INTO user_bookmarks (user_id, event_id) VALUES (?, ?)";

        try (Connection conn = DbConnection.openConnection()) {
            // 1. Check if already bookmarked
            try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
                checkStmt.setInt(1, userId);
                checkStmt.setString(2, eventId);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        return "EXISTS";
                    }
                }
            }

            // 2. Insert if new
            try (PreparedStatement insertStmt = conn.prepareStatement(insertQuery)) {
                insertStmt.setInt(1, userId);
                insertStmt.setString(2, eventId);
                int rows = insertStmt.executeUpdate();
                return rows > 0 ? "SUCCESS" : "ERROR";
            }

        } catch (SQLException e) {
            e.printStackTrace(); // Logs the exact error (e.g., Foreign Key violation) in your terminal
            return "ERROR";
        }
    }
}