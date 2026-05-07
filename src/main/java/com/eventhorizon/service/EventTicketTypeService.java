package com.eventhorizon.service;

import com.eventhorizon.model.EventTicketType;
import com.eventhorizon.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventTicketTypeService {

    public List<EventTicketType> getByEvent(String eventId) {
        List<EventTicketType> list = new ArrayList<>();
        String sql = "SELECT * FROM event_ticket_types WHERE event_id = ? ORDER BY ticket_type_id ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("getByEvent error: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    public EventTicketType getById(int ticketTypeId) {
        String sql = "SELECT * FROM event_ticket_types WHERE ticket_type_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketTypeId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("getById error: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    public EventTicketType getById(int ticketTypeId, Connection conn) throws SQLException {
        String sql = "SELECT * FROM event_ticket_types WHERE ticket_type_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketTypeId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }

        return null;
    }

    public void addTicketType(String eventId, String typeName, double price, int seats, Connection conn)
            throws SQLException {
        String sql = "INSERT INTO event_ticket_types (event_id, type_name, price, total_seats, available_seats) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eventId);
            ps.setString(2, typeName);
            ps.setDouble(3, price);
            ps.setInt(4, seats);
            ps.setInt(5, seats);
            ps.executeUpdate();
        }
    }

    public void replaceTicketTypes(String eventId, String[] names, String[] prices, String[] seats, Connection conn)
            throws SQLException {

        try (PreparedStatement del = conn.prepareStatement(
                "DELETE FROM event_ticket_types WHERE event_id = ?")) {
            del.setString(1, eventId);
            del.executeUpdate();
        }

        if (names == null || prices == null || seats == null) {
            refreshEventSummary(eventId, conn);
            return;
        }

        int len = Math.min(names.length, Math.min(prices.length, seats.length));
        for (int i = 0; i < len; i++) {
            String name = names[i] == null ? "" : names[i].trim();
            String priceStr = prices[i] == null ? "" : prices[i].trim();
            String seatStr = seats[i] == null ? "" : seats[i].trim();

            if (name.isEmpty() || priceStr.isEmpty() || seatStr.isEmpty()) {
                continue;
            }

            double price = Double.parseDouble(priceStr);
            int totalSeats = Integer.parseInt(seatStr);

            if (price < 0 || totalSeats <= 0) {
                continue;
            }

            addTicketType(eventId, name, price, totalSeats, conn);
        }

        refreshEventSummary(eventId, conn);
    }

    public boolean reduceSeat(int ticketTypeId, int count, Connection conn) throws SQLException {
        String sql = "UPDATE event_ticket_types " +
                "SET available_seats = available_seats - ? " +
                "WHERE ticket_type_id = ? AND available_seats >= ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, count);
            ps.setInt(2, ticketTypeId);
            ps.setInt(3, count);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean restoreSeat(int ticketTypeId, int count, Connection conn) throws SQLException {
        String sql = "UPDATE event_ticket_types " +
                "SET available_seats = LEAST(total_seats, available_seats + ?) " +
                "WHERE ticket_type_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, count);
            ps.setInt(2, ticketTypeId);
            return ps.executeUpdate() > 0;
        }
    }

    public void refreshEventSummary(String eventId, Connection conn) throws SQLException {
        String summarySql =
                "SELECT COALESCE(MIN(price), 0) AS min_price, " +
                        "COALESCE(SUM(total_seats), 0) AS total_seats, " +
                        "COALESCE(SUM(available_seats), 0) AS available_seats " +
                        "FROM event_ticket_types WHERE event_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(summarySql)) {
            ps.setString(1, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double minPrice = rs.getDouble("min_price");
                    int totalSeats = rs.getInt("total_seats");
                    int availableSeats = rs.getInt("available_seats");

                    try (PreparedStatement upd = conn.prepareStatement(
                            "UPDATE events SET ticket_price = ?, total_seats = ?, available_seats = ? WHERE event_id = ?")) {
                        upd.setDouble(1, minPrice);
                        upd.setInt(2, totalSeats);
                        upd.setInt(3, availableSeats);
                        upd.setString(4, eventId);
                        upd.executeUpdate();
                    }
                }
            }
        }
    }

    private EventTicketType mapRow(ResultSet rs) throws SQLException {
        return new EventTicketType(
                rs.getInt("ticket_type_id"),
                rs.getString("event_id"),
                rs.getString("type_name"),
                rs.getDouble("price"),
                rs.getInt("total_seats"),
                rs.getInt("available_seats")
        );
    }
}