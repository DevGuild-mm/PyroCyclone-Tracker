# PyroCyclone-Tracker

A lightweight Java EE web application that tracks global wildfires and severe weather events by proxying data from the **NASA EONET v3 API**.

## Tech Stack
* **Backend:** Java Servlets, Apache HttpClient, Maven
* **Frontend:** JSP (JavaServer Pages), Tailwind CSS
* **Server:** Apache Tomcat 7 (Embedded via Maven plugin)
* **Data Source:** NASA EONET (Earth Observatory Natural Event Tracker) API

## How to Run

1. Open the project in your IDE (IntelliJ IDEA).
2. Open your terminal in the project root directory.
3. Start the embedded Tomcat 7 server using Maven:
```bash
mvn clean tomcat7:run
```


4. Open your browser and navigate to:
   `http://localhost:8080/`

