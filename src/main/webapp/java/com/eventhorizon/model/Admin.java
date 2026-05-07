package com.eventhorizon.model;

/**
 * Admin class - inherits from User.
 * Supports permission categories for admin access control.
 */
public class Admin extends User {

    public static final String CORE_ADMIN = "CORE_ADMIN";
    public static final String EVENTS_BOOKINGS_REQUEST_ADMIN = "EVENTS_BOOKINGS_REQUEST_ADMIN";
    public static final String EVENTS_ONLY = "EVENTS_ONLY";
    public static final String BOOKINGS_ONLY = "BOOKINGS_ONLY";

    private String adminPermission;

    public Admin(String userId, String name, String email,
                 String password, String phone, String adminPermission) {
        super(userId, name, email, password, phone);
        setAdminPermission(adminPermission);
    }

    public Admin() {
        super();
        this.adminPermission = CORE_ADMIN;
    }

    @Override
    public String getRole() {
        return "ADMIN";
    }

    public String getAdminPermission() {
        return adminPermission;
    }

    public void setAdminPermission(String adminPermission) {
        if (adminPermission == null || adminPermission.trim().isEmpty()) {
            this.adminPermission = CORE_ADMIN;
            return;
        }

        String normalized = adminPermission.trim().toUpperCase();
        switch (normalized) {
            case CORE_ADMIN:
            case EVENTS_BOOKINGS_REQUEST_ADMIN:
            case EVENTS_ONLY:
            case BOOKINGS_ONLY:
                this.adminPermission = normalized;
                break;
            default:
                this.adminPermission = CORE_ADMIN;
        }
    }

    public boolean canManageEvents() {
        return CORE_ADMIN.equals(adminPermission)
                || EVENTS_BOOKINGS_REQUEST_ADMIN.equals(adminPermission)
                || EVENTS_ONLY.equals(adminPermission);
    }

    public boolean canManageBookings() {
        return CORE_ADMIN.equals(adminPermission)
                || EVENTS_BOOKINGS_REQUEST_ADMIN.equals(adminPermission)
                || BOOKINGS_ONLY.equals(adminPermission);
    }

    public boolean canRequestAdmins() {
        return CORE_ADMIN.equals(adminPermission)
                || EVENTS_BOOKINGS_REQUEST_ADMIN.equals(adminPermission);
    }

    public boolean canApproveAdmins() {
        return CORE_ADMIN.equals(adminPermission);
    }

    public String getPermissionLabel() {
        switch (adminPermission) {
            case EVENTS_BOOKINGS_REQUEST_ADMIN:
                return "Events + Bookings + New Admin Requests";
            case EVENTS_ONLY:
                return "Events only";
            case BOOKINGS_ONLY:
                return "Bookings only";
            default:
                return "Core Admin";
        }
    }
}
