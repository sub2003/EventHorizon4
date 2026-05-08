package com.eventhorizon.servlet;

import com.eventhorizon.model.Admin;
import com.eventhorizon.model.Event;
import com.eventhorizon.service.EventService;
import com.eventhorizon.service.EventTicketTypeService;
import com.eventhorizon.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;

import com.eventhorizon.util.DatabaseConnection;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class EventServlet extends HttpServlet {

    private final EventService eventService = new EventService();
    private final EventTicketTypeService ticketTypeService = new EventTicketTypeService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        switch (action == null ? "list" : action) {
            case "list":
                showEventList(req, resp);
                break;
            case "view":
                showEventDetail(req, resp);
                break;
            case "search":
                showEventList(req, resp);
                break;
            case "adminList":
                requireEventAdmin(req, resp);
                if (resp.isCommitted()) return;
                showAdminEventList(req, resp);
                break;
            case "image":
                serveEventImage(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/event?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
            return;
        }

        String permission = (String) session.getAttribute("adminPermission");
        if (permission == null) permission = Admin.CORE_ADMIN;

        if (!UserService.hasEventAccess(permission)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=noEventPermission");
            return;
        }

        String action = req.getParameter("action");

        switch (action == null ? "" : action) {
            case "add":
                handleAdd(req, resp);
                break;
            case "update":
                handleUpdate(req, resp);
                break;
            case "delete":
                handleDelete(req, resp);
                break;
            case "cancel":
                handleCancel(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
        }
    }

    private void showEventList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String keyword = req.getParameter("keyword");
        String category = req.getParameter("category");

        if (keyword != null) keyword = keyword.trim();
        if (category != null) category = category.trim();

        List<Event> allEvents = eventService.getActiveEvents();
        List<Event> filteredEvents = new ArrayList<>();

        boolean hasKeyword = keyword != null && !keyword.isEmpty();
        boolean hasCategory = category != null && !category.isEmpty();

        if (!hasKeyword && !hasCategory) {
            filteredEvents = allEvents;
        } else {
            String lowerKeyword = hasKeyword ? keyword.toLowerCase() : "";

            for (Event event : allEvents) {
                boolean matchesKeyword = true;
                boolean matchesCategory = true;

                if (hasKeyword) {
                    String title = event.getTitle() != null ? event.getTitle().toLowerCase() : "";
                    String venue = event.getVenue() != null ? event.getVenue().toLowerCase() : "";
                    matchesKeyword = title.contains(lowerKeyword) || venue.contains(lowerKeyword);
                }

                if (hasCategory) {
                    String eventCategory = event.getCategory() != null ? event.getCategory() : "";
                    matchesCategory = eventCategory.equalsIgnoreCase(category);
                }

                if (matchesKeyword && matchesCategory) {
                    filteredEvents.add(event);
                }
            }
        }

        req.setAttribute("events", filteredEvents);
        req.setAttribute("keyword", keyword != null ? keyword : "");
        req.setAttribute("category", category != null ? category : "");

        req.getRequestDispatcher("/events.jsp").forward(req, resp);
    }

    private void showEventDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String id = req.getParameter("id");

        if (id == null || id.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/event?action=list");
            return;
        }

        Event event = eventService.getEventById(id.trim());

        if (event == null) {
            resp.sendRedirect(req.getContextPath() + "/event?action=list");
            return;
        }

        req.setAttribute("event", event);
        req.setAttribute("ticketTypes", ticketTypeService.getByEvent(id.trim()));
        req.getRequestDispatcher("/eventDetail.jsp").forward(req, resp);
    }

    private void showAdminEventList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Event> events = eventService.getAllEvents();
        req.setAttribute("events", events);
        req.getRequestDispatcher("/admin/addEvent.jsp").forward(req, resp);
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        String title = req.getParameter("title");
        String category = req.getParameter("category");
        String date = req.getParameter("date");
        String time = req.getParameter("time");
        String venue = req.getParameter("venue");
        String description = req.getParameter("description");

        String[] typeNames = req.getParameterValues("typeName");
        String[] typePrices = req.getParameterValues("typePrice");
        String[] typeSeats = req.getParameterValues("typeSeats");

        double summaryPrice = calculateMinPrice(typePrices);
        int summarySeats = calculateTotalSeats(typeSeats);

        Part imagePart = req.getPart("eventImage");
        byte[] imageData = extractImageBytes(imagePart);
        String imageType = getImageType(imagePart);

        Connection conn = null;
        String newId = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            newId = eventService.addEvent(
                    title,
                    category,
                    date,
                    time,
                    venue,
                    description,
                    imageData,
                    imageType,
                    summaryPrice,
                    summarySeats,
                    conn
            );

            if (newId == null) {
                conn.rollback();
                resp.sendRedirect(req.getContextPath() + "/event?action=adminList&msg=error");
                return;
            }

            ticketTypeService.replaceTicketTypes(newId, typeNames, typePrices, typeSeats, conn);

            conn.commit();
            resp.sendRedirect(req.getContextPath() + "/event?action=adminList&msg=added");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ignored) {
            }
            resp.sendRedirect(req.getContextPath() + "/event?action=adminList&msg=error");
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {
            }
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        String eventId = req.getParameter("eventId");
        String title = req.getParameter("title");
        String category = req.getParameter("category");
        String date = req.getParameter("date");
        String time = req.getParameter("time");
        String venue = req.getParameter("venue");
        String description = req.getParameter("description");

        String[] typeNames = req.getParameterValues("typeName");
        String[] typePrices = req.getParameterValues("typePrice");
        String[] typeSeats = req.getParameterValues("typeSeats");

        double summaryPrice = calculateMinPrice(typePrices);
        Part imagePart = req.getPart("eventImage");

        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            boolean ok;

            if (imagePart != null && imagePart.getSize() > 0) {
                byte[] imageData = extractImageBytes(imagePart);
                String imageType = getImageType(imagePart);

                ok = eventService.updateEventWithImage(
                        eventId,
                        title,
                        category,
                        date,
                        time,
                        venue,
                        description,
                        imageData,
                        imageType,
                        summaryPrice,
                        conn
                );
            } else {
                ok = eventService.updateEvent(
                        eventId,
                        title,
                        category,
                        date,
                        time,
                        venue,
                        description,
                        summaryPrice,
                        conn
                );
            }

            if (!ok) {
                conn.rollback();
                resp.sendRedirect(req.getContextPath() + "/event?action=adminList&msg=error");
                return;
            }

            ticketTypeService.replaceTicketTypes(eventId, typeNames, typePrices, typeSeats, conn);

            conn.commit();
            resp.sendRedirect(req.getContextPath() + "/event?action=adminList&msg=updated");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ignored) {
            }
            resp.sendRedirect(req.getContextPath() + "/event?action=adminList&msg=error");
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {
            }
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String eventId = req.getParameter("eventId");
        eventService.deleteEvent(eventId);
        resp.sendRedirect(req.getContextPath() + "/event?action=adminList&msg=deleted");
    }

    private void handleCancel(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String eventId = req.getParameter("eventId");
        eventService.cancelEvent(eventId);
        resp.sendRedirect(req.getContextPath() + "/event?action=adminList&msg=cancelled");
    }

    private void serveEventImage(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String eventId = req.getParameter("id");

        if (eventId == null || eventId.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Event event = eventService.getEventById(eventId.trim());

        if (event == null || event.getImageData() == null || event.getImageData().length == 0) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        resp.setContentType(event.getImageType() != null ? event.getImageType() : "image/jpeg");
        resp.setContentLength(event.getImageData().length);
        resp.getOutputStream().write(event.getImageData());
        resp.getOutputStream().flush();
    }

    private byte[] extractImageBytes(Part imagePart) throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }

        try (InputStream inputStream = imagePart.getInputStream()) {
            return inputStream.readAllBytes();
        }
    }

    private String getImageType(Part imagePart) {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }
        return imagePart.getContentType();
    }

    private void requireEventAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession(false);

        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
            return;
        }

        String permission = (String) session.getAttribute("adminPermission");
        if (permission == null) permission = Admin.CORE_ADMIN;

        if (!UserService.hasEventAccess(permission)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=noEventPermission");
        }
    }

    private double calculateMinPrice(String[] prices) {
        if (prices == null || prices.length == 0) return 0;

        double min = Double.MAX_VALUE;
        boolean found = false;

        for (String p : prices) {
            if (p == null || p.trim().isEmpty()) continue;

            try {
                double value = Double.parseDouble(p.trim());
                if (value >= 0) {
                    min = Math.min(min, value);
                    found = true;
                }
            } catch (Exception ignored) {
            }
        }

        return found ? min : 0;
    }

    private int calculateTotalSeats(String[] seats) {
        if (seats == null || seats.length == 0) return 0;

        int total = 0;
        for (String s : seats) {
            if (s == null || s.trim().isEmpty()) continue;

            try {
                int value = Integer.parseInt(s.trim());
                if (value > 0) total += value;
            } catch (Exception ignored) {
            }
        }
        return total;
    }
}