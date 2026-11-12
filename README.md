# PyroCyclone Tracker

**A Myanmar disaster-monitoring dashboard for wildfires, cyclones, and community-reported hazards.**

PyroCyclone Tracker is a web application designed to help users view disaster-related events across Myanmar on an interactive map. It brings together NASA EONET event data and community-submitted reports in one dashboard, with tools for browsing incidents by region and reviewing submitted reports.

> This project was created as part of the **7 Day Warm Up Program**.

## Features

- Interactive map displaying disaster and hazard events around Myanmar
- Region-based browsing for Myanmar states and regions
- NASA EONET API integration for event data, with fallback sample data when the API is unavailable
- Community hazard reporting with location, category, risk level, and description
- User registration, login, and event bookmarking
- Admin moderation tools for reviewing reports and updating their status

## Tech Stack

- **Backend:** Java Servlets, JSP, Maven
- **Frontend:** JSP, HTML, CSS, JavaScript, Bootstrap, Leaflet
- **Database:** MySQL
- **External data:** NASA EONET API
- **Application server:** Apache Tomcat (see project configuration for version compatibility)

## Project Contributors

- **Frontend:** [Your Name] — frontend development and dashboard interface
- **Backend:** **Ko Aung** — backend development and server-side functionality

## Getting Started

### Requirements

- Java 17 or a compatible JDK
- Maven
- MySQL
- Apache Tomcat compatible with the project's Servlet API and Java version

### Run locally

1. Clone or download this project and open a terminal in the project directory.
2. Configure your MySQL database connection using secure environment-specific settings. Do not commit real database passwords to source control.
3. Build and run the application with the Maven/Tomcat setup configured for your environment.
4. Open the local application URL in your browser.

> The original project README describes running the app with `mvn clean tomcat7:run`. Check that the configured Tomcat plugin and Java version are compatible in your development environment before running it.

## Data and Disclaimer

NASA EONET provides event data through its API. If the API cannot be reached, the application may show fallback sample events. **Fallback/sample events are for demonstration only and should not be treated as verified, real-time emergency information.** Always confirm hazards and safety instructions through official local authorities and trusted emergency services.

Community-submitted reports may require administrative review before appearing as verified information. This application is an educational project and is not a replacement for official disaster alerts or emergency response systems.

## Program

Built during the **7 Day Warm Up Program** as a collaborative project to explore disaster tracking, interactive mapping, and full-stack web development.