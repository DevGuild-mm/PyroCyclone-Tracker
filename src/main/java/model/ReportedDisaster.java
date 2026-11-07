package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ReportedDisaster {
    private int id;
    private String title;
    private String category;
    private String riskLevel;
    private String description;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private Timestamp recordedTime;
    private String reporterName;
    private String status;
    private Timestamp createdAt;

    public ReportedDisaster() {}

    // Constructor for creating a new report before database insert
    public ReportedDisaster(String title, String category, String riskLevel, String description,
                            BigDecimal latitude, BigDecimal longitude, Timestamp recordedTime,
                            String reporterName, String status) {
        this.title = title;
        this.category = category;
        this.riskLevel = riskLevel;
        this.description = description;
        this.latitude = latitude;
        this.longitude = longitude;
        this.recordedTime = recordedTime;
        this.reporterName = reporterName != null && !reporterName.trim().isEmpty()
                ? reporterName : "Anonymous Operator";
        this.status = status != null && !status.trim().isEmpty() ? status : "Pending";
    }

    // Full constructor for retrieving existing records from DB
    public ReportedDisaster(int id, String title, String category, String riskLevel, String description,
                            BigDecimal latitude, BigDecimal longitude, Timestamp recordedTime,
                            String reporterName, String status, Timestamp createdAt) {
        this(title, category, riskLevel, description, latitude, longitude, recordedTime, reporterName, status);
        this.id = id;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public Timestamp getRecordedTime() { return recordedTime; }
    public void setRecordedTime(Timestamp recordedTime) { this.recordedTime = recordedTime; }

    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}