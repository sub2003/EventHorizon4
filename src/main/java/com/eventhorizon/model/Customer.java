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
    

    public int  getTotalBookings()          { return totalBookings; }
    public void setTotalBookings(int count) { this.totalBookings = count; }
}
