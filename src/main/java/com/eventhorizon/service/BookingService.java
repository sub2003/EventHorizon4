package com.eventhorizon.service;

import com.eventhorizon.model.Booking;
import com.eventhorizon.model.Event;
import com.eventhorizon.model.EventTicketType;
import com.eventhorizon.model.Ticket;
import com.eventhorizon.util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class BookingService {

    private final EventService eventService = new EventService();
    private final TicketService ticketService = new TicketService();
    private final EventTicketTypeService ticketTypeService = new EventTicketTypeService();

    public String createBooking(String customerId, String eventId, int ticketTypeId,
                                int numberOfTickets, String paymentReference) {

        customerId = safeTrim(customerId);
        eventId = safeTrim(eventId);
        paymentReference = safeTrim(paymentReference);

        if (isBlank(customerId) || isBlank(eventId) || ticketTypeId <= 0 || numberOfTickets <= 0) {
            System.err.println("createBooking failed: invalid input");
            return null;
        }

        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            Event event = eventService.getEventById(eventId, conn);
            if (event == null) {
                conn.rollback();
                return null;
            }

            if (!"ACTIVE".equalsIgnoreCase(event.getStatus())) {
                conn.rollback();
                return null;
            }

            EventTicketType ticketType = ticketTypeService.getById(ticketTypeId, conn);
            if (ticketType == null) {
                conn.rollback();
                return null;
            }

            if (!eventId.equals(ticketType.getEventId())) {
                conn.rollback();
                return null;
            }

            if (ticketType.getAvailableSeats() < numberOfTickets) {
                conn.rollback();
                return null;
            }

            boolean reduced = ticketTypeService.reduceSeat(ticketTypeId, numberOfTickets, conn);
            if (!reduced) {
                conn.rollback();
                return null;
            }

            ticketTypeService.refreshEventSummary(eventId, conn);

            String bookingId = generateId(conn);
            double total = ticketType.getPrice() * numberOfTickets;
            String today = LocalDate.now().toString();

            String sql = "INSERT INTO bookings " +
                    "(booking_id, customer_id, event_id, event_title, ticket_type_id, ticket_type_name, " +
                    "number_of_tickets, total_amount, booking_date, status, payment_status, payment_reference) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'CONFIRMED', 'PENDING', ?)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, bookingId);
                ps.setString(2, customerId);
                ps.setString(3, eventId);
                ps.setString(4, event.getTitle());
                ps.setInt(5, ticketTypeId);
                ps.setString(6, ticketType.getTypeName());
                ps.setInt(7, numberOfTickets);
                ps.setDouble(8, total);
                ps.setString(9, today);
                ps.setString(10, paymentReference != null ? paymentReference : "");

                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return null;
                }
            }

            conn.commit();
            return bookingId;

        } catch (SQLException e) {
            System.err.println("createBooking error: " + e.getMessage());
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            return null;

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

    public boolean approveBooking(String bookingId) {
        bookingId = safeTrim(bookingId);
        if (isBlank(bookingId)) return false;

        Booking booking = getBookingById(bookingId);
        if (booking == null) return false;

        if ("CANCELLED".equalsIgnoreCase(booking.getStatus())) return false;
        if ("APPROVED".equalsIgnoreCase(booking.getPaymentStatus())) return true;
        if ("REJECTED".equalsIgnoreCase(booking.getPaymentStatus())) return false;

        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            String sql = "UPDATE bookings " +
                    "SET payment_status = 'APPROVED' " +
                    "WHERE booking_id = ? AND status = 'CONFIRMED' AND payment_status = 'PENDING'";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, bookingId);
                int rows = ps.executeUpdate();

                if (rows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();

        } catch (SQLException e) {
            System.err.println("approveBooking error: " + e.getMessage());
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

        try {
            List<Ticket> tickets = ticketService.generateTickets(
                    booking.getBookingId(),
                    booking.getEventId(),
                    booking.getCustomerId(),
                    booking.getTicketTypeId(),
                    booking.getTicketTypeName(),
                    booking.getNumberOfTickets()
            );

            if (tickets == null || tickets.isEmpty()) {
                System.err.println("approveBooking warning: payment approved but no tickets were generated for " + bookingId);
            }
        } catch (Exception e) {
            System.err.println("approveBooking warning: payment approved but ticket generation failed for " + bookingId);
            e.printStackTrace();
        }

        return true;
    }

    public boolean rejectBooking(String bookingId) {
        Booking booking = getBookingById(bookingId);
        if (booking == null) return false;
        if ("CANCELLED".equalsIgnoreCase(booking.getStatus())) return false;
        if ("REJECTED".equalsIgnoreCase(booking.getPaymentStatus())) return false;

        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            boolean restored = ticketTypeService.restoreSeat(
                    booking.getTicketTypeId(),
                    booking.getNumberOfTickets(),
                    conn
            );

            if (!restored) {
                conn.rollback();
                return false;
            }

            ticketTypeService.refreshEventSummary(booking.getEventId(), conn);

            String sql = "UPDATE bookings " +
                    "SET payment_status = 'REJECTED', status = 'CANCELLED' " +
                    "WHERE booking_id = ? AND payment_status = 'PENDING'";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, bookingId);

                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("rejectBooking error: " + e.getMessage());
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

    public List<Booking> getPendingBookings() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM bookings " +
                "WHERE payment_status = 'PENDING' AND status = 'CONFIRMED' " +
                "ORDER BY booking_date DESC, booking_id DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                list.add(mapRowToBooking(rs));
            }

        } catch (SQLException e) {
            System.err.println("getPendingBookings error: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    public List<Booking> getAllBookings() {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings ORDER BY booking_date DESC, booking_id DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                bookings.add(mapRowToBooking(rs));
            }

        } catch (SQLException e) {
            System.err.println("getAllBookings error: " + e.getMessage());
            e.printStackTrace();
        }

        return bookings;
    }

    public Booking getBookingById(String bookingId) {
        String sql = "SELECT * FROM bookings WHERE booking_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, safeTrim(bookingId));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToBooking(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("getBookingById error: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    public List<Booking> getBookingsByCustomer(String customerId) {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE customer_id = ? ORDER BY booking_date DESC, booking_id DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, safeTrim(customerId));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapRowToBooking(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("getBookingsByCustomer error: " + e.getMessage());
            e.printStackTrace();
        }

        return bookings;
    }

    public List<Booking> getBookingsByEvent(String eventId) {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE event_id = ? ORDER BY booking_date DESC, booking_id DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, safeTrim(eventId));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapRowToBooking(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("getBookingsByEvent error: " + e.getMessage());
            e.printStackTrace();
        }

        return bookings;
    }

    public boolean cancelBooking(String bookingId) {
        Booking booking = getBookingById(bookingId);
        if (booking == null) return false;
        if ("CANCELLED".equalsIgnoreCase(booking.getStatus())) return false;

        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            boolean restored = ticketTypeService.restoreSeat(
                    booking.getTicketTypeId(),
                    booking.getNumberOfTickets(),
                    conn
            );

            if (!restored) {
                conn.rollback();
                return false;
            }

            ticketTypeService.refreshEventSummary(booking.getEventId(), conn);

            String sql = "UPDATE bookings SET status = 'CANCELLED' WHERE booking_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, bookingId);

                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("cancelBooking error: " + e.getMessage());
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

    public boolean deleteBookingPermanently(String bookingId) {
        bookingId = safeTrim(bookingId);
        if (isBlank(bookingId)) return false;

        Booking booking = getBookingById(bookingId);
        if (booking == null) {
            System.err.println("deleteBookingPermanently failed: booking not found for ID = " + bookingId);
            return false;
        }

        boolean canDelete =
                "CANCELLED".equalsIgnoreCase(booking.getStatus()) ||
                        "REJECTED".equalsIgnoreCase(booking.getPaymentStatus());

        if (!canDelete) {
            System.err.println("deleteBookingPermanently failed: booking is not deletable.");
            return false;
        }

        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement deleteTickets = conn.prepareStatement(
                    "DELETE FROM tickets WHERE booking_id = ?")) {
                deleteTickets.setString(1, bookingId);
                deleteTickets.executeUpdate();
            } catch (SQLException e) {
                System.err.println("deleteBookingPermanently warning while deleting tickets: " + e.getMessage());
            }

            try (PreparedStatement deleteBooking = conn.prepareStatement(
                    "DELETE FROM bookings WHERE booking_id = ?")) {
                deleteBooking.setString(1, bookingId);

                int bookingRows = deleteBooking.executeUpdate();
                if (bookingRows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("deleteBookingPermanently error: " + e.getMessage());
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

    private Booking mapRowToBooking(ResultSet rs) throws SQLException {
        String payStatus = "PENDING";
        String payRef = null;
        int ticketTypeId = 0;
        String ticketTypeName = null;

        try {
            payStatus = rs.getString("payment_status");
        } catch (SQLException ignored) {
        }

        try {
            payRef = rs.getString("payment_reference");
        } catch (SQLException ignored) {
        }

        try {
            ticketTypeId = rs.getInt("ticket_type_id");
        } catch (SQLException ignored) {
        }

        try {
            ticketTypeName = rs.getString("ticket_type_name");
        } catch (SQLException ignored) {
        }

        return new Booking(
                rs.getString("booking_id"),
                rs.getString("customer_id"),
                rs.getString("event_id"),
                rs.getString("event_title"),
                ticketTypeId,
                ticketTypeName,
                rs.getInt("number_of_tickets"),
                rs.getDouble("total_amount"),
                rs.getString("booking_date"),
                rs.getString("status"),
                payStatus != null ? payStatus : "PENDING",
                payRef
        );
    }

    private String generateId(Connection conn) {
        String sql = "SELECT MAX(CAST(SUBSTRING(booking_id, 4) AS UNSIGNED)) FROM bookings WHERE booking_id LIKE 'BKG%'";

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            int next = 1;
            if (rs.next()) next = rs.getInt(1) + 1;
            return String.format("BKG%03d", next);

        } catch (SQLException e) {
            System.err.println("generateId error: " + e.getMessage());
            return "BKG" + System.currentTimeMillis();
        }
    }

    private String safeTrim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}