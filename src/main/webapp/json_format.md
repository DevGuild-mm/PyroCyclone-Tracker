# Myanmar Wildfire & Cyclone Command - API Specifications & Payload Guide

This document outlines the standard JSON request and response payloads used for communication between the frontend dashboard and the Java Servlet backend (`/api/...`).

## 1. Request Payloads

### A. Submit Incident Report (`POST /api/reports`)
Payload submitted by an authenticated user when reporting a disaster event:
```json
{
  "category": "Wildfire",
  "title": "Forest fire outbreak in northern region",
  "riskLevel": "High Risk",
  "township": "Example Township",
  "latitude": 21.916200,
  "longitude": 95.956000,
  "description": "Intense flames spreading rapidly with heavy smoke."
}
```

### B. User Login (`POST /api/login`)
Payload sent when authenticating an existing user:
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

### C. User Registration (`POST /api/register`)
Payload sent when registering a new user account:
```json
{
  "fullName": "John Doe",
  "email": "user@example.com",
  "password": "securePassword123"
}
```

---

## 2. Response Payloads

### A. Success Response (`200 OK`)
Standard response returned upon successful processing of an action:
```json
{
  "success": true,
  "message": "Operation completed successfully."
}
```

### B. Unauthorized Response (`401 Unauthorized`)
Returned when an unauthenticated user attempts to access restricted endpoints (e.g., submitting a report):
```json
{
  "success": false,
  "message": "Unauthorized access. Please login first."
}
```

### C. Authentication Success (`200 OK`)
Returned with user profile data upon successful login:
```json
{
  "success": true,
  "message": "Login successful",
  "user": {
    "id": 1,
    "fullName": "John Doe",
    "email": "user@example.com",
    "role": "CITIZEN"
  }
}
```

### D. Error Response (`400 Bad Request` / `500 Internal Server Error`)
Returned when validation fails or a server-side error occurs:
```json
{
  "success": false,
  "message": "Invalid request data or server error encountered."
}
```