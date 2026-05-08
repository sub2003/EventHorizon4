package com.eventhorizon.service;

import com.eventhorizon.model.Ticket;
import com.eventhorizon.util.DatabaseConnection;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class TicketService {

    private static final String SECRET_KEY =
            System.getenv("TICKET_HMAC_SECRET") != null
                    ? System.getenv("TICKET_HMAC_SECRET")
                    : "EH@T1cket$3cr3tK3y_2026!#Horizon";

    public List<Ticket> generateTickets(String bookingId, String eventId,
                                        String customerId, int ticketTypeId,
                                        String ticketTypeName, int count) {
        List<Ticket> tickets = new ArrayList<>();

        String sql = "INSERT INTO tickets " +
                "(ticket_id, booking_id, event_id, customer_id, ticket_type_id, ticket_type_name, qr_token, is_used) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, 0)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 0; i < count; i++) {
                String ticketId = UUID.randomUUID().toString();
                String qrToken = buildQrToken(ticketId, bookingId, eventId, customerId);

                ps.setString(1, ticketId);
                ps.setString(2, bookingId);
                ps.setString(3, eventId);
                ps.setString(4, customerId);
                ps.setInt(5, ticketTypeId);
                ps.setString(6, ticketTypeName);
                ps.setString(7, qrToken);
                ps.addBatch();

                tickets.add(new Ticket(
                        ticketId,
                        bookingId,
                        eventId,
                        customerId,
                        ticketTypeId,
                        ticketTypeName,
                        qrToken,
                        false,
                        null
                ));
            }

            ps.executeBatch();

        } catch (SQLException e) {
            System.err.println("generateTickets error: " + e.getMessage());
            e.printStackTrace();
            tickets.clear();
        }

        return tickets;
    }

    public List<Ticket> getTicketsByBooking(String bookingId) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM tickets WHERE booking_id = ? ORDER BY created_at";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tickets.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("getTicketsByBooking error: " + e.getMessage());
        }

        return tickets;
    }

    public List<Ticket> getTicketsByCustomer(String customerId) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM tickets WHERE customer_id = ? ORDER BY created_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tickets.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("getTicketsByCustomer error: " + e.getMessage());
        }

        return tickets;
    }

    public Ticket getTicketByToken(String qrToken) {
        if (qrToken == null || qrToken.isBlank()) return null;

        String sql = "SELECT * FROM tickets WHERE qr_token = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, qrToken.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("getTicketByToken error: " + e.getMessage());
        }

        return null;
    }

    public enum VerifyResult {
        VALID,
        ALREADY_USED,
        INVALID
    }

    public VerifyResult verifyAndRedeemTicket(String qrToken) {
        if (qrToken == null || qrToken.isBlank()) return VerifyResult.INVALID;

        Ticket ticket = getTicketByToken(qrToken);
        if (ticket == null) return VerifyResult.INVALID;

        String bookingSql = "SELECT payment_status, status FROM bookings WHERE booking_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(bookingSql)) {

            ps.setString(1, ticket.getBookingId());

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return VerifyResult.INVALID;

                String paymentStatus = rs.getString("payment_status");
                String bookingStatus = rs.getString("status");

                if (!"APPROVED".equalsIgnoreCase(paymentStatus)
                        || !"CONFIRMED".equalsIgnoreCase(bookingStatus)) {
                    return VerifyResult.INVALID;
                }
            }

            if (ticket.isUsed()) {
                return VerifyResult.ALREADY_USED;
            }

            String updateSql = "UPDATE tickets SET is_used = 1 WHERE ticket_id = ?";
            try (PreparedStatement upd = conn.prepareStatement(updateSql)) {
                upd.setString(1, ticket.getTicketId());
                upd.executeUpdate();
            }

            return VerifyResult.VALID;

        } catch (SQLException e) {
            System.err.println("verifyAndRedeemTicket error: " + e.getMessage());
            return VerifyResult.INVALID;
        }
    }

    public static String buildQrToken(String ticketId, String bookingId,
                                      String eventId, String customerId) {
        try {
            String payload = ticketId + "|" + bookingId + "|" + eventId + "|" + customerId;

            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec keySpec = new SecretKeySpec(SECRET_KEY.getBytes("UTF-8"), "HmacSHA256");
            mac.init(keySpec);

            byte[] raw = mac.doFinal(payload.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : raw) {
                sb.append(String.format("%02x", b));
            }

            return ticketId.replace("-", "").substring(0, 8).toUpperCase() + "_" + sb;
        } catch (Exception e) {
            throw new RuntimeException("HMAC generation failed", e);
        }
    }

    private Ticket mapRow(ResultSet rs) throws SQLException {
        return new Ticket(
                rs.getString("ticket_id"),
                rs.getString("booking_id"),
                rs.getString("event_id"),
                rs.getString("customer_id"),
                safeInt(rs, "ticket_type_id"),
                safeString(rs, "ticket_type_name"),
                rs.getString("qr_token"),
                rs.getInt("is_used") == 1,
                safeString(rs, "created_at")
        );
    }

    private int safeInt(ResultSet rs, String column) {
        try {
            return rs.getInt(column);
        } catch (SQLException e) {
            return 0;
        }
    }

    private String safeString(ResultSet rs, String column) {
        try {
            return rs.getString(column);
        } catch (SQLException e) {
            return null;
        }
    }
}