package com.eventhorizon.model;

/**
 * Abstract base class for all users - demonstrates INHERITANCE & ENCAPSULATION
 * Both Admin and Customer extend this class.
 */
public abstract class User {

    // Encapsulated fields (private) - accessed only via getters/setters
    private String userId;
    private String name;
    private String email;
    private String password;
    private String phone;

    // Constructor
    public User(String userId, String name, String email, String password, String phone) {
        this.userId  = userId;
        this.name    = name;
        this.email   = email;
        this.password = password;
        this.phone   = phone;
    }

    // Default constructor (needed for file deserialization)
    public User() {}


    // Abstract method - POLYMORPHISM: each subclass provides its own implementation
    public abstract String getRole();

    // Returns a CSV line to save into the .txt file
    public String toFileString() {
        return userId + "," + name + "," + email + "," + password + "," + phone + "," + getRole();
    }

    // -------------------- Getters & Setters --------------------
    public String getUserId()               { return userId; }
    public void   setUserId(String userId)  { this.userId = userId; }

    public String getName()                 { return name; }
    public void   setName(String name)      { this.name = name; }

    public String getEmail()                { return email; }
    public void   setEmail(String email)    { this.email = email; }

    public String getPassword()             { return password; }
    public void   setPassword(String p)     { this.password = p; }

    public String getPhone()                { return phone; }
    public void   setPhone(String phone)    { this.phone = phone; }


    @Override
    public String toString() {
        return "User[id=" + userId + ", name=" + name + ", role=" + getRole() + "]";
    }
}
