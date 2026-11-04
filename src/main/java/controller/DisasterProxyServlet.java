package controller;

import service.NasaApiClient;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/api/events")
public class DisasterProxyServlet extends HttpServlet {
    private final NasaApiClient apiClient = new NasaApiClient();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String days = request.getParameter("days");
        String category = request.getParameter("category");
        String bbox = request.getParameter("bbox");

        try (PrintWriter out = response.getWriter()) {
            String geoJsonPayload = apiClient.getDisasterData(days, category, bbox);
            out.print(geoJsonPayload);
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"Failed to retrieve data from NASA EONET\"}");
        }
    }
}