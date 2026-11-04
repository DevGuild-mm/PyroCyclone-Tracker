<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="service.NasaApiClient" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>EONET Disaster Data - Plain JSP</title>
</head>
<body>
    <h1>EONET Wildfire & Weather Tracker (Plain JSP Server-Side Render)</h1>

    <hr>

    <h3>Raw Data Fetched from Java Backend:</h3>

    <div style="background-color: #f4f4f4; padding: 15px; border: 1px solid #ccc; font-family: monospace; white-space: pre-wrap; max-height: 500px; overflow-y: auto;">
        <%
            try {
                // Directly instantiate your backend service in the JSP
                NasaApiClient client = new NasaApiClient();
                // Fetch default open events for the last 30 days
                String rawJson = client.getDisasterData("30", "all", null);
                out.print(rawJson);
            } catch (Exception e) {
                out.print("ERROR FETCHING DATA FROM BACKEND: " + e.getMessage());
                e.printStackTrace();
            }
        %>
    </div>

</body>
</html>