package model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String username;
    private String email;
    private String passwordHash;
    private String role; // 'user' or 'admin'
    private Timestamp createdAt;

    public User() {}

    // Constructor for user registration (used by SignupServlet)
    public User(String username, String email, String passwordHash, String role) {
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role != null && !role.trim().isEmpty() ? role : "user";
    }

    // Optional convenience constructor defaulting role to 'user'
    public User(String username, String email, String passwordHash) {
        this(username, email, passwordHash, "user");
    }

    // Full constructor for retrieving records from database
    public User(int id, String username, String email, String passwordHash, String role, Timestamp createdAt) {
        this(username, email, passwordHash, role);
        this.id = id;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isAdmin() {
        return "admin".equalsIgnoreCase(this.role);
    }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}