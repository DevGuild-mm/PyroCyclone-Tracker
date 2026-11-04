package service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class NasaApiClient {
    private static final String NASA_API_URL = "https://eonet.gsfc.nasa.gov/api/v3/events/geojson";
    private final HttpClient httpClient;

    public NasaApiClient() {
        this.httpClient = HttpClient.newHttpClient();
    }

    public String getDisasterData(String days, String category, String bbox) throws Exception {
        StringBuilder urlBuilder = new StringBuilder(NASA_API_URL + "?status=open");

        if (days != null && !days.isEmpty()) urlBuilder.append("&days=").append(days);
        if (category != null && !category.equals("all")) urlBuilder.append("&category=").append(category);
        if (bbox != null && !bbox.isEmpty()) urlBuilder.append("&bbox=").append(bbox);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(urlBuilder.toString()))
                .GET()
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }
}