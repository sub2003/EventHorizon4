package com.eventhorizon.service;

import com.eventhorizon.model.Event;
import com.eventhorizon.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventService {

    public String addEvent(String title, String category, String date, String time,
                           String venue, String description,
                           byte[] imageData, String imageType,
                           double summaryPrice, int summaryTotalSeats) {

        try (Connection conn = DatabaseConnection.getConnection()) {
            return addEvent(title, category, date, time, venue, description,
                    imageData, imageType, summaryPrice, summaryTotalSeats, conn);
        } catch (SQLException e) {
            System.err.println("addEvent error: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public String addEvent(String title, String category, String date, String time,
                           String venue, String description,
                           byte[] imageData, String imageType,
                           double summaryPrice, int summaryTotalSeats,
                           Connection conn) throws SQLException {

        String id = generateId(conn);

        String sql = "INSERT INTO events (event_id, title, category, date, time, venue, " +
                "ticket_price, total_seats, available_seats, description, status, image_data, image_type) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);
            ps.setString(2, title);
            ps.setString(3, category);
            ps.setString(4, date);
            ps.setString(5, time);
            ps.setString(6, venue);
            ps.setDouble(7, summaryPrice);
            ps.setInt(8, summaryTotalSeats);
            ps.setInt(9, summaryTotalSeats);
            ps.setString(10, description);

            if (imageData != null && imageData.length > 0) {
                ps.setBytes(11, imageData);
                ps.setString(12, imageType);
            } else {
                ps.setNull(11, Types.BLOB);
                ps.setNull(12, Types.VARCHAR);
            }

            ps.executeUpdate();
            return id;
        }
    }

    public List<Event> getAllEvents() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM events ORDER BY date ASC, time ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                events.add(mapRowToEvent(rs));
            }

        } catch (SQLException e) {
            System.err.println("getAllEvents error: " + e.getMessage());
            e.printStackTrace();
        }

        return events;
    }

    public List<Event> getActiveEvents() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM events WHERE status = 'ACTIVE' ORDER BY date ASC, time ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                events.add(mapRowToEvent(rs));
            }

        } catch (SQLException e) {
            System.err.println("getActiveEvents error: " + e.getMessage());
            e.printStackTrace();
        }

        return events;
    }

    public Event getEventById(String eventId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return getEventById(eventId, conn);
        } catch (SQLException e) {
            System.err.println("getEventById error: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public Event getEventById(String eventId, Connection conn) {
        String sql = "SELECT * FROM events WHERE event_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, safeTrim(eventId));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToEvent(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("getEventById(tx) error: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    public List<Event> searchEvents(String keyword) {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM events WHERE status = 'ACTIVE' AND " +
                "(title LIKE ? OR category LIKE ? OR venue LIKE ?) ORDER BY date ASC, time ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String q = "%" + (keyword == null ? "" : keyword.trim()) + "%";
            ps.setString(1, q);
            ps.setString(2, q);
            ps.setString(3, q);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    events.add(mapRowToEvent(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("searchEvents error: " + e.getMessage());
            e.printStackTrace();
        }

        return events;
    }

    public boolean updateEvent(String eventId, String title, String category,
                               String date, String time, String venue,
                               String description, double summaryPrice) {

        try (Connection conn = DatabaseConnection.getConnection()) {
            return updateEvent(eventId, title, category, date, time, venue, description, summaryPrice, conn);
        } catch (SQLException e) {
            System.err.println("updateEvent error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateEvent(String eventId, String title, String category,
                               String date, String time, String venue,
                               String description, double summaryPrice,
                               Connection conn) throws SQLException {

        String sql = "UPDATE events SET title = ?, category = ?, date = ?, time = ?, " +
                "venue = ?, description = ?, ticket_price = ? WHERE event_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, title);
            ps.setString(2, category);
            ps.setString(3, date);
            ps.setString(4, time);
            ps.setString(5, venue);
            ps.setString(6, description);
            ps.setDouble(7, summaryPrice);
            ps.setString(8, eventId);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateEventWithImage(String eventId, String title, String category,
                                        String date, String time, String venue,
                                        String description, byte[] imageData,
                                        String imageType, double summaryPrice) {

        try (Connection conn = DatabaseConnection.getConnection()) {
            return updateEventWithImage(eventId, title, category, date, time, venue,
                    description, imageData, imageType, summaryPrice, conn);
        } catch (SQLException e) {
            System.err.println("updateEventWithImage error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateEventWithImage(String eventId, String title, String category,
                                        String date, String time, String venue,
                                        String description, byte[] imageData,
                                        String imageType, double summaryPrice,
                                        Connection conn) throws SQLException {

        String sql = "UPDATE events SET title = ?, category = ?, date = ?, time = ?, " +
                "venue = ?, description = ?, ticket_price = ?, image_data = ?, image_type = ? " +
                "WHERE event_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, title);
            ps.setString(2, category);
            ps.setString(3, date);
            ps.setString(4, time);
            ps.setString(5, venue);
            ps.setString(6, description);
            ps.setDouble(7, summaryPrice);

            if (imageData != null && imageData.length > 0) {
                ps.setBytes(8, imageData);
                ps.setString(9, imageType);
            } else {
                ps.setNull(8, Types.BLOB);
                ps.setNull(9, Types.VARCHAR);
            }

            ps.setString(10, eventId);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean cancelEvent(String eventId) {
        String sql = "UPDATE events SET status = 'CANCELLED' WHERE event_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, safeTrim(eventId));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("cancelEvent error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteEvent(String eventId) {
        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps1 = conn.prepareStatement(
                    "DELETE FROM event_ticket_types WHERE event_id = ?")) {
                ps1.setString(1, safeTrim(eventId));
                ps1.executeUpdate();
            }

            try (PreparedStatement ps2 = conn.prepareStatement(
                    "DELETE FROM events WHERE event_id = ?")) {
                ps2.setString(1, safeTrim(eventId));
                boolean deleted = ps2.executeUpdate() > 0;
                if (!deleted) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("deleteEvent error: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            return false;

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    private Event mapRowToEvent(ResultSet rs) throws SQLException {
        Event event = new Event(
                rs.getString("event_id"),
                rs.getString("title"),
                rs.getString("category"),
                rs.getString("date"),
                rs.getString("time"),
                rs.getString("venue"),
                rs.getDouble("ticket_price"),
                rs.getInt("total_seats"),
                rs.getInt("available_seats"),
                rs.getString("description"),
                rs.getString("status"),
                null
        );

        try {
            event.setImageData(rs.getBytes("image_data"));
        } catch (SQLException ignored) {
        }

        try {
            event.setImageType(rs.getString("image_type"));
        } catch (SQLException ignored) {
        }

        return event;
    }

    private String generateId() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return generateId(conn);
        } catch (SQLException e) {
            throw new RuntimeException("Failed to generate event ID", e);
        }
    }

    private String generateId(Connection conn) throws SQLException {
        String sql = "SELECT event_id FROM events ORDER BY event_id DESC LIMIT 1";

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            if (rs.next()) {
                String lastId = rs.getString("event_id");
                int number = Integer.parseInt(lastId.substring(3)) + 1;
                return String.format("EVT%03d", number);
            } else {
                return "EVT001";
            }
        }
    }

    private String safeTrim(String value) {
        return value == null ? null : value.trim();
    }
}