package com.eventhorizon.model;

/**
 * Event model - encapsulates all event data.
 * ticketPrice / totalSeats / availableSeats are now summary values
 * derived from event_ticket_types for compatibility with old pages.
 */
public class Event {

    private String eventId;
    private String title;
    private String category;
    private String date;
    private String time;
    private String venue;
    private double ticketPrice;   // summary: lowest ticket type price
    private int totalSeats;       // summary: total of all ticket types
    private int availableSeats;   // summary: total available of all ticket types
    private String description;
    private String status;
    private String imagePath;

    private byte[] imageData;
    private String imageType;

    public Event() {
    }

    public Event(String eventId, String title, String category, String date,
                 String time, String venue, double ticketPrice,
                 int totalSeats, int availableSeats,
                 String description, String status, String imagePath) {
        this.eventId = eventId;
        this.title = title;
        this.category = category;
        this.date = date;
        this.time = time;
        this.venue = venue;
        this.ticketPrice = ticketPrice;
        this.totalSeats = totalSeats;
        this.availableSeats = availableSeats;
        this.description = description;
        this.status = status;
        this.imagePath = imagePath;
    }

    public boolean hasAvailableSeats() {
        return availableSeats > 0;
    }

    public boolean bookSeats(int count) {
        if (availableSeats >= count) {
            availableSeats -= count;
            return true;
        }
        return false;
    }

    public void cancelSeats(int count) {
        availableSeats = Math.min(availableSeats + count, totalSeats);
    }

    public String getEventId() {
        return eventId;
    }

    public void setEventId(String eventId) {
        this.eventId = eventId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getVenue() {
        return venue;
    }

    public void setVenue(String venue) {
        this.venue = venue;
    }

    public double getTicketPrice() {
        return ticketPrice;
    }

    public void setTicketPrice(double ticketPrice) {
        this.ticketPrice = ticketPrice;
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public byte[] getImageData() {
        return imageData;
    }

    public void setImageData(byte[] imageData) {
        this.imageData = imageData;
    }

    public String getImageType() {
        return imageType;
    }

    public void setImageType(String imageType) {
        this.imageType = imageType;
    }

    public boolean hasImage() {
        return imageData != null && imageData.length > 0;
    }
}