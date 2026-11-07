package model;

import java.sql.Timestamp;

public class Bookmark {
    private int userId;
    private String eventId;
    private Timestamp savedAt;

    // Constructors
    public Bookmark() {
    }

    public Bookmark(int userId, String eventId) {
        this.userId = userId;
        this.eventId = eventId;
    }

    public Bookmark(int userId, String eventId, Timestamp savedAt) {
        this.userId = userId;
        this.eventId = eventId;
        this.savedAt = savedAt;
    }

    // Getters and Setters
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getEventId() {
        return eventId;
    }

    public void setEventId(String eventId) {
        this.eventId = eventId;
    }

    public Timestamp getSavedAt() {
        return savedAt;
    }

    public void setSavedAt(Timestamp savedAt) {
        this.savedAt = savedAt;
    }

    @Override
    public String toString() {
        return "Bookmark{" +
                "userId=" + userId +
                ", eventId='" + eventId + '\'' +
                ", savedAt=" + savedAt +
                '}';
    }
}