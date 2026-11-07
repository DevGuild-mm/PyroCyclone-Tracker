package dao;

import model.Bookmark;
import util.DbConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BookmarkDao {

    // Overloaded: Accepts Bookmark model object
    public String addBookmark(Bookmark bookmark) {
        return addBookmark(bookmark.getUserId(), bookmark.getEventId());
    }

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
            e.printStackTrace();
            return "ERROR";
        }
    }

    // Fetches all Bookmark models for a specific user
    public List<Bookmark> getBookmarksByUserId(int userId) {
        List<Bookmark> bookmarks = new ArrayList<>();
        String query = "SELECT user_id, event_id, saved_at FROM user_bookmarks WHERE user_id = ? ORDER BY saved_at DESC";

        try (Connection conn = DbConnection.openConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Bookmark bookmark = new Bookmark(
                            rs.getInt("user_id"),
                            rs.getString("event_id"),
                            rs.getTimestamp("saved_at")
                    );
                    bookmarks.add(bookmark);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookmarks;
    }
}