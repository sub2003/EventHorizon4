package com.eventhorizon.model;

/**
 * One physical ticket per seat inside a booking.
 */
public class Ticket {



    private String ticketId;
    private String bookingId;
    private String eventId;
    private String customerId;
    private int ticketTypeId;
    private String ticketTypeName;
    private String qrToken;
    private boolean used;
    private String createdAt;

    public Ticket() {
    }

    public Ticket(String ticketId, String bookingId, String eventId, String customerId,
                  int ticketTypeId, String ticketTypeName,
                  String qrToken, boolean used, String createdAt) {
        this.ticketId = ticketId;
        this.bookingId = bookingId;
        this.eventId = eventId;
        this.customerId = customerId;
        this.ticketTypeId = ticketTypeId;
        this.ticketTypeName = ticketTypeName;
        this.qrToken = qrToken;
        this.used = used;
        this.createdAt = createdAt;
    }

    public String getTicketId() {
        return ticketId;
    }

    public void setTicketId(String ticketId) {
        this.ticketId = ticketId;
    }

    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public String getEventId() {
        return eventId;
    }

    public void setEventId(String eventId) {
        this.eventId = eventId;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public int getTicketTypeId() {
        return ticketTypeId;
    }

    public void setTicketTypeId(int ticketTypeId) {
        this.ticketTypeId = ticketTypeId;
    }

    public String getTicketTypeName() {
        return ticketTypeName;
    }

    public void setTicketTypeName(String ticketTypeName) {
        this.ticketTypeName = ticketTypeName;
    }

    public String getQrToken() {
        return qrToken;
    }

    public void setQrToken(String qrToken) {
        this.qrToken = qrToken;
    }

    public boolean isUsed() {
        return used;
    }

    public void setUsed(boolean used) {
        this.used = used;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}