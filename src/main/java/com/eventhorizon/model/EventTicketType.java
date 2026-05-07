package com.eventhorizon.model;

public class EventTicketType {

    private int ticketTypeId;
    private String eventId;
    private String typeName;
    private double price;
    private int totalSeats;
    private int availableSeats;

    public EventTicketType() {
    }

    public EventTicketType(int ticketTypeId, String eventId, String typeName,
                           double price, int totalSeats, int availableSeats) {
        this.ticketTypeId = ticketTypeId;
        this.eventId = eventId;
        this.typeName = typeName;
        this.price = price;
        this.totalSeats = totalSeats;
        this.availableSeats = availableSeats;
    }

    public int getTicketTypeId() {
        return ticketTypeId;
    }

    public void setTicketTypeId(int ticketTypeId) {
        this.ticketTypeId = ticketTypeId;
    }

    public String getEventId() {
        return eventId;
    }

    public void setEventId(String eventId) {
        this.eventId = eventId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }
}