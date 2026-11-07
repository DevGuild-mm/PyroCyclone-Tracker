package controller;

import dao.BookmarkDao;
import model.Bookmark;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/api/bookmark")
public class BookmarkServlet extends HttpServlet {
    private final BookmarkDao bookmarkDao = new BookmarkDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"status\": \"UNAUTHORIZED\", \"message\": \"Please login first.\"}");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        String eventId = request.getParameter("eventId");

        if (eventId == null || eventId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\": \"ERROR\", \"message\": \"Invalid event ID.\"}");
            return;
        }

        // Instantiate model
        Bookmark bookmark = new Bookmark(user.getId(), eventId.trim());
        String result = bookmarkDao.addBookmark(bookmark);

        if ("SUCCESS".equals(result)) {
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"status\": \"SUCCESS\"}");
        } else if ("EXISTS".equals(result)) {
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"status\": \"EXISTS\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\": \"ERROR\", \"message\": \"Database insert failed.\"}");
        }
    }
}