package com.eventhorizon.model;

/**
 * Customer class - INHERITS from User.
 * Represents a regular user who can browse and book event tickets.
 */
public class Customer extends User {

    private int totalBookings;   // Extra field specific to Customer

    public Customer(String userId, String name, String email,
                    String password, String phone, int totalBookings) {
        super(userId, name, email, password, phone);  // Call parent constructor
        this.totalBookings = totalBookings;
    }

    public Customer() { super(); }

    // POLYMORPHISM - overrides abstract method from User
    @Override
    public String getRole() {
        return "CUSTOMER";
    }

    // Override toFileString to include totalBookings
    @Override
    public String toFileString() {
        return super.toFileString() + "," + totalBookings;
    }

    // Build Customer object from a CSV line read from users.txt
    public static Customer fromFileString(String line) {
        String[] parts = line.split(",");
        // parts: userId, name, email, password, phone, role, totalBookings
        int bookings = parts.length > 6 ? Integer.parseInt(parts[6]) : 0;
        return new Customer(parts[0], parts[1], parts[2], parts[3], parts[4], bookings);
    }

    public int  getTotalBookings()          { return totalBookings; }
    public void setTotalBookings(int count) { this.totalBookings = count; }
}
