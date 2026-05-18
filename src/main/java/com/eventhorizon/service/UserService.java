package com.eventhorizon.service;

import com.eventhorizon.model.Admin;
import com.eventhorizon.model.Customer;
import com.eventhorizon.model.User;
import com.eventhorizon.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserService {

    private static final String CUSTOMER_TABLE = "customers";
    private static final String ADMIN_TABLE = "admins";

    public boolean registerCustomer(String name, String email, String password, String phone) {
        name = safeTrim(name);        //Sanitize all inputes
        email = normalizeEmail(email);
        password = safeTrim(password);
        phone = safeTrim(phone);

        if (isBlank(name) || isBlank(email) || isBlank(password) || isBlank(phone)) {
            return false;
        }

        if (getUserByEmail(email) != null) {
            return false;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String id = generateUserId("USR", CUSTOMER_TABLE, "customer_id", conn);

            String sql = "INSERT INTO customers (customer_id, name, email, password, phone) " +
                    "VALUES (?, ?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, id);
                ps.setString(2, name);
                ps.setString(3, email);
                ps.setString(4, password);
                ps.setString(5, phone);
                return ps.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            System.err.println("registerCustomer error: " + e.getMessage());
            return false;
        }
    }

    public boolean registerAdmin(String name, String email, String password,
                                 String phone, String adminPermission) {
        name = safeTrim(name);
        email = normalizeEmail(email);
        password = safeTrim(password);
        phone = safeTrim(phone);
        adminPermission = normalizeAdminPermission(adminPermission);

        if (isBlank(name) || isBlank(email) || isBlank(password) || isBlank(phone)) {
            return false;
        }

        if (getUserByEmail(email) != null) {
            return false;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String id = generateUserId("ADM", ADMIN_TABLE, "admin_id", conn);

            String sql = "INSERT INTO admins (admin_id, name, email, password, phone, admin_permission) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, id);
                ps.setString(2, name);
                ps.setString(3, email);
                ps.setString(4, password);
                ps.setString(5, phone);
                ps.setString(6, adminPermission);
                return ps.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            System.err.println("registerAdmin error: " + e.getMessage());
            return false;
        }
    }

    public boolean submitAdminRequest(String requesterAdminId,
                                      String name,
                                      String email,
                                      String password,
                                      String phone,
                                      String adminPermission) {  // Allows an existing admin to submit a request for creating a new admin account.

        // Step 1: Clean and normalize input
        requesterAdminId = safeTrim(requesterAdminId);
        name = safeTrim(name);
        email = normalizeEmail(email);
        password = safeTrim(password);
        phone = safeTrim(phone);
        adminPermission = normalizeAdminPermission(adminPermission);

        // Step 2: Validate required fields
        if (isBlank(requesterAdminId) || isBlank(name) || isBlank(email)
                || isBlank(password) || isBlank(phone)) {
            return false;
        }

        // Step 3: Prevent duplicate email
        if (getUserByEmail(email) != null) {
            return false;
        }

        // SQL statements
        String pendingCheckSql =
                "SELECT request_id FROM admin_requests WHERE LOWER(requested_email) = LOWER(?) AND status = 'PENDING'";
        String insertSql =
                "INSERT INTO admin_requests " +
                        "(request_id, requester_admin_id, requested_name, requested_email, requested_password, requested_phone, requested_permission, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')";

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Step 4: Check requester admin exists and has permission
            Admin requester = getAdminById(requesterAdminId, conn);
            if (requester == null || !canRequestAdmin(requester.getAdminPermission())) {
                return false;  // Only CORE_ADMIN or EVENTS_BOOKINGS_REQUEST_ADMIN can submit
            }

            try (PreparedStatement checkPs = conn.prepareStatement(pendingCheckSql);
                 PreparedStatement insertPs = conn.prepareStatement(insertSql)) {

                // Step 5: Prevent duplicate pending requests for same email
                checkPs.setString(1, email);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        return false;
                    }
                }

                // Step 6: Generate new request ID
                String requestId = generateAdminRequestId(conn);

                // Step 7: Insert new admin request
                insertPs.setString(1, requestId);
                insertPs.setString(2, requesterAdminId);
                insertPs.setString(3, name);
                insertPs.setString(4, email);
                insertPs.setString(5, password);
                insertPs.setString(6, phone);
                insertPs.setString(7, adminPermission);

                return insertPs.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            System.err.println("submitAdminRequest error: " + e.getMessage());
            return false;
        }
    }

    public List<Map<String, String>> getPendingAdminRequests(String currentAdminId) {
        List<Map<String, String>> requests = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Step 1: Check if the current admin exists and has full access (Core Admin)
            Admin admin = getAdminById(currentAdminId, conn);
            if (admin == null || !hasFullAccess(admin.getAdminPermission())) {
                // Not authorized, return empty list
                return requests;
            }

            // Step 2: Fetch pending requests from the database
            String sql = "SELECT * FROM admin_requests WHERE status = 'PENDING' ORDER BY requested_at DESC";
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sql)) {

                while (rs.next()) { // Loop through each row in the database
                    Map<String, String> row = new HashMap<>();
                    row.put("requestId", rs.getString("request_id"));
                    row.put("requesterAdminId", rs.getString("requester_admin_id"));
                    row.put("requestedName", rs.getString("requested_name"));
                    row.put("requestedEmail", rs.getString("requested_email"));
                    row.put("requestedPhone", rs.getString("requested_phone"));
                    row.put("requestedPermission", normalizeAdminPermission(rs.getString("requested_permission")));
                    row.put("status", rs.getString("status"));
                    row.put("requestedAt", rs.getString("requested_at"));
                    requests.add(row);
                }
            }

        } catch (SQLException e) {
            System.err.println("getPendingAdminRequests error: " + e.getMessage());
        }

        return requests;
    }

    public boolean approveAdminRequest(String requestId, String approverAdminId) {
        requestId = safeTrim(requestId);
        approverAdminId = safeTrim(approverAdminId);

        String selectSql = "SELECT * FROM admin_requests WHERE request_id = ? AND status = 'PENDING'";
        String insertAdminSql =
                "INSERT INTO admins (admin_id, name, email, password, phone, admin_permission) VALUES (?, ?, ?, ?, ?, ?)";
        String updateRequestSql =
                "UPDATE admin_requests SET status = 'APPROVED', reviewed_by = ?, reviewed_at = CURRENT_TIMESTAMP WHERE request_id = ?";

        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // Step 1: Check that approver exists
            Admin approver = getAdminById(approverAdminId, conn);
            if (approver == null) {
                conn.rollback();
                return false;
            }

            // Step 2: Check that approver is Core Admin
            if (!hasFullAccess(approver.getAdminPermission())) {
                conn.rollback();
                return false;
            }

            // Step 3: Check the request exists and is pending
            try (PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
                selectPs.setString(1, requestId);
                try (ResultSet rs = selectPs.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }

                    // Step 4: Extract requested admin details
                    String name = rs.getString("requested_name");
                    String email = normalizeEmail(rs.getString("requested_email"));
                    String password = rs.getString("requested_password");
                    String phone = rs.getString("requested_phone");
                    String permission = normalizeAdminPermission(rs.getString("requested_permission"));

                    // Step 5: Prevent duplicate emails
                    if (getUserByEmail(email, conn) != null) {
                        conn.rollback();
                        return false;
                    }

                    // Step 6: Generate new admin ID
                    String newAdminId = generateUserId("ADM", ADMIN_TABLE, "admin_id", conn);

                    // Step 7: Insert new admin and update request
                    try (PreparedStatement insertPs = conn.prepareStatement(insertAdminSql);
                         PreparedStatement updatePs = conn.prepareStatement(updateRequestSql)) {

                        insertPs.setString(1, newAdminId);
                        insertPs.setString(2, name);
                        insertPs.setString(3, email);
                        insertPs.setString(4, password);
                        insertPs.setString(5, phone);
                        insertPs.setString(6, permission);
                        insertPs.executeUpdate();

                        updatePs.setString(1, approverAdminId);
                        updatePs.setString(2, requestId);
                        updatePs.executeUpdate();
                    }
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("approveAdminRequest error: " + e.getMessage());

            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            return false;

        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public boolean rejectAdminRequest(String requestId, String approverAdminId) {
        requestId = safeTrim(requestId);
        approverAdminId = safeTrim(approverAdminId);

        String updateSql =
                "UPDATE admin_requests " +
                        "SET status = 'REJECTED', reviewed_by = ?, reviewed_at = CURRENT_TIMESTAMP " +
                        "WHERE request_id = ? AND status = 'PENDING'";

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Step 1: Fetch the admin object
            Admin approver = getAdminById(approverAdminId, conn);

            // Step 2: Check that the approver exists and is CORE_ADMIN
            if (approver == null || !hasFullAccess(approver.getAdminPermission())) {
                return false; // Only Core Admins can reject
            }

            // Step 3: Execute the update
            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                updatePs.setString(1, approverAdminId);
                updatePs.setString(2, requestId);
                return updatePs.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            System.err.println("rejectAdminRequest error: " + e.getMessage());
            return false;
        }
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>(); //--------------------------------------------------------------------------------------------------------------------------------------------------------

        try (Connection conn = DatabaseConnection.getConnection()) {
            String customerSql = "SELECT * FROM customers ORDER BY name ASC";
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(customerSql)) {
                while (rs.next()) {
                    users.add(mapCustomerRow(rs, conn));
                }
            }

            String adminSql = "SELECT * FROM admins ORDER BY name ASC";
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(adminSql)) {
                while (rs.next()) {
                    users.add(mapAdminRow(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("getAllUsers error: " + e.getMessage());
        }

        return users;
    }

    public List<Customer> getAllCustomers() {
        List<Customer> customers = new ArrayList<>();  //--------------------------------------------------------------------------------------------------------------------------------------------------------
        String sql = "SELECT * FROM customers ORDER BY name ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                customers.add(mapCustomerRow(rs, conn));
            }

        } catch (SQLException e) {
            System.err.println("getAllCustomers error: " + e.getMessage());
        }

        return customers;
    }

    public User getUserById(String userId) {
        userId = safeTrim(userId);
        if (isBlank(userId)) return null;

        try (Connection conn = DatabaseConnection.getConnection()) {
            return getUserById(userId, conn);
        } catch (SQLException e) {
            System.err.println("getUserById error: " + e.getMessage());
            return null;
        }
    }

    public User getUserByEmail(String email) {
        email = normalizeEmail(email);
        if (isBlank(email)) return null;

        try (Connection conn = DatabaseConnection.getConnection()) {
            return getUserByEmail(email, conn);
        } catch (SQLException e) {
            System.err.println("getUserByEmail error: " + e.getMessage());
            return null;
        }
    }

    /**
     * Customer login only. Public /login.jsp must not authenticate admin accounts.
     */
    public User login(String email, String password) {
        return loginCustomer(email, password);
    }

    public Customer loginCustomer(String email, String password) {
        String sql = "SELECT * FROM customers WHERE LOWER(email) = LOWER(?) AND password = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, normalizeEmail(email));
            ps.setString(2, safeTrim(password));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCustomerRow(rs, conn);
                }
            }

        } catch (SQLException e) {
            System.err.println("loginCustomer error: " + e.getMessage());
        }

        return null;
    }

    public Admin loginAdmin(String email, String password) {
        String sql = "SELECT * FROM admins WHERE LOWER(email) = LOWER(?) AND password = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, normalizeEmail(email));
            ps.setString(2, safeTrim(password));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAdminRow(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("loginAdmin error: " + e.getMessage());
        }

        return null;
    }

    public String getAdminPermission(String userId) {
        String sql = "SELECT admin_permission FROM admins WHERE admin_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, safeTrim(userId));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return normalizeAdminPermission(rs.getString("admin_permission"));
                }
            }

        } catch (SQLException e) {
            System.err.println("getAdminPermission error: " + e.getMessage());
        }

        return Admin.CORE_ADMIN;
    }

    public boolean updateUser(String userId, String newName, String newPhone, String newPassword) {
        userId = safeTrim(userId);
        newName = safeTrim(newName);
        newPhone = safeTrim(newPhone);
        newPassword = safeTrim(newPassword);

        if (isBlank(userId) || isBlank(newName) || isBlank(newPhone)) {
            return false;
        }

        User existing = getUserById(userId);
        if (existing == null) {
            return false;
        }

        boolean updatePassword = !isBlank(newPassword);
        String table = "ADMIN".equalsIgnoreCase(existing.getRole()) ? ADMIN_TABLE : CUSTOMER_TABLE;
        String idColumn = "ADMIN".equalsIgnoreCase(existing.getRole()) ? "admin_id" : "customer_id";

        String sql = updatePassword
                ? "UPDATE " + table + " SET name = ?, phone = ?, password = ? WHERE " + idColumn + " = ?"
                : "UPDATE " + table + " SET name = ?, phone = ? WHERE " + idColumn + " = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newName);
            ps.setString(2, newPhone);

            if (updatePassword) {
                ps.setString(3, newPassword);
                ps.setString(4, userId);
            } else {
                ps.setString(3, userId);
            }

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("updateUser error: " + e.getMessage());
            return false;
        }
    }

    public boolean updateUserByAdmin(String targetUserId,
                                     String name,
                                     String email,
                                     String phone,
                                     String password,
                                     String role,
                                     String currentAdminId,
                                     String adminPermission) {

        targetUserId = safeTrim(targetUserId);      //Sanitize all inputes
        name = safeTrim(name);
        email = normalizeEmail(email);
        phone = safeTrim(phone);
        password = safeTrim(password);
        currentAdminId = safeTrim(currentAdminId);
        adminPermission = normalizeAdminPermission(adminPermission);

        if (isBlank(targetUserId) || isBlank(name) || isBlank(email) //rejects the update if fiels is missing.
                || isBlank(phone)) {
            return false;
        }

        /*if (!"ADMIN".equalsIgnoreCase(role) && !"CUSTOMER".equalsIgnoreCase(role)) { // i have done this for future updations. if we want to add a new user role like "guests" so these case is complusory. but right now it doesnt need.
            return false;
        }*/

        User existing = getUserById(targetUserId);
        if (existing == null) {
            return false;
        }

        User userWithSameEmail = getUserByEmail(email);
        if (userWithSameEmail != null && !targetUserId.equals(userWithSameEmail.getUserId())) { //only blocks differnt user own that email
            return false;
        }

        boolean updatePassword = !isBlank(password);
        boolean targetIsAdmin = "ADMIN".equalsIgnoreCase(existing.getRole());

        String sql;
        if (targetIsAdmin) {
            sql = updatePassword
                    ? "UPDATE admins SET name = ?, email = ?, phone = ?, password = ?, admin_permission = ? WHERE admin_id = ?"
                    : "UPDATE admins SET name = ?, email = ?, phone = ?, admin_permission = ? WHERE admin_id = ?";
        } else {
            sql = updatePassword
                    ? "UPDATE customers SET name = ?, email = ?, phone = ?, password = ? WHERE customer_id = ?"
                    : "UPDATE customers SET name = ?, email = ?, phone = ? WHERE customer_id = ?";
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);

            if (targetIsAdmin) {
                if (updatePassword) {
                    ps.setString(4, password);
                    ps.setString(5, adminPermission);
                    ps.setString(6, targetUserId);
                } else {
                    ps.setString(4, adminPermission);
                    ps.setString(5, targetUserId);
                }
            } else {
                if (updatePassword) {
                    ps.setString(4, password);
                    ps.setString(5, targetUserId);
                } else {
                    ps.setString(4, targetUserId);
                }
            }

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("updateUserByAdmin error: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteUser(String userId) {
        return deleteUser(userId, null, null, null);
    }

    public boolean deleteUser(String userId, String currentUserId, String role, String adminPermission) {
        userId = safeTrim(userId);
        currentUserId = safeTrim(currentUserId);
        role = safeTrim(role);
        adminPermission = safeTrim(adminPermission);

        if (isBlank(userId)) {
            return false;
        }

        User targetUser = getUserById(userId);
        if (targetUser == null) {
            return false;
        }

        boolean isSelfDelete = currentUserId != null && currentUserId.equals(userId);

        if ("CUSTOMER".equalsIgnoreCase(role)) {
            if (!isSelfDelete) {   //if user ID not equal it imediately reject the deletion. whe we go to ui page it shows only delete my account like wise not but never trust any value from the requester body.
                return false;      //because the ui is not the only way to send a post request.  The session is the only trustes source.
            }

            if (!"CUSTOMER".equalsIgnoreCase(targetUser.getRole())) { //double checks the customer
                return false;
            }
        } else if ("ADMIN".equalsIgnoreCase(role)) {
            if (!hasFullAccess(adminPermission)) { //reject non core admins
                return false;
            }

            if (isSelfDelete) {
                return false;
            }
        } else {
            return false;
        }

        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);   //runs as one atomic unit — either all succeeds or all rolls back.

            if ("CUSTOMER".equalsIgnoreCase(targetUser.getRole())) {
                try (PreparedStatement bookingPs = conn.prepareStatement(
                        "DELETE FROM bookings WHERE customer_id = ?")) {
                    bookingPs.setString(1, userId);
                    bookingPs.executeUpdate();
                }

                try (PreparedStatement deletePs = conn.prepareStatement(
                        "DELETE FROM customers WHERE customer_id = ?")) {
                    deletePs.setString(1, userId);
                    boolean success = deletePs.executeUpdate() > 0;
                    if (!success) {
                        conn.rollback();  //undo changes
                        return false;
                    }
                }
            } else {
                try (PreparedStatement requestByApproverPs = conn.prepareStatement(
                        "UPDATE admin_requests SET reviewed_by = NULL WHERE reviewed_by = ?")) {//nulled out to preserve the request history,not deleted
                    requestByApproverPs.setString(1, userId);
                    requestByApproverPs.executeUpdate();
                }

                try (PreparedStatement requestByRequesterPs = conn.prepareStatement(
                        "DELETE FROM admin_requests WHERE requester_admin_id = ?")) {
                    requestByRequesterPs.setString(1, userId);
                    requestByRequesterPs.executeUpdate();
                }

                try (PreparedStatement deletePs = conn.prepareStatement(
                        "DELETE FROM admins WHERE admin_id = ?")) {
                    deletePs.setString(1, userId);
                    boolean success = deletePs.executeUpdate() > 0;
                    if (!success) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("deleteUser error: " + e.getMessage());

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

    public boolean deleteUserByEmail(String email) {
        email = normalizeEmail(email);
        if (isBlank(email)) return false;

        try (Connection conn = DatabaseConnection.getConnection()) {
            User user = getUserByEmail(email, conn); //-------------------------------------------------------------------------------------------------------------------
            if (user == null) return false;

            String sql;
            if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                sql = "DELETE FROM admins WHERE LOWER(email) = LOWER(?)";
            } else {
                sql = "DELETE FROM customers WHERE LOWER(email) = LOWER(?)";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);
                return ps.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            System.err.println("deleteUserByEmail error: " + e.getMessage());
            return false;
        }
    }

    private int getBookingCount(String customerId, Connection conn) {
        String sql = "SELECT COUNT(*) FROM bookings WHERE customer_id = ? AND status = 'CONFIRMED'";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            System.err.println("getBookingCount error: " + e.getMessage());
        }

        return 0;
    }

    private User getUserById(String userId, Connection conn) throws SQLException {
        if (isBlank(userId)) {
            return null;
        }

        String upperId = userId.trim().toUpperCase();

        if (upperId.startsWith("ADM")) {
            return getAdminById(userId, conn);
        }

        else if (upperId.startsWith("USR")) {
            return getCustomerById(userId, conn);
        }
        return null;
    }

    private User getUserByEmail(String email, Connection conn) throws SQLException {
        Customer customer = getCustomerByEmail(email, conn);
        if (customer != null) return customer;
        return getAdminByEmail(email, conn);
    }

    private Customer getCustomerById(String customerId, Connection conn) throws SQLException {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, safeTrim(customerId));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCustomerRow(rs, conn);
                }
            }
        }
        return null;
    }

    private Admin getAdminById(String adminId, Connection conn) throws SQLException {
        String sql = "SELECT * FROM admins WHERE admin_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, safeTrim(adminId));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAdminRow(rs);
                }
            }
        }
        return null;
    }

    private Customer getCustomerByEmail(String email, Connection conn) throws SQLException {
        String sql = "SELECT * FROM customers WHERE LOWER(email) = LOWER(?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizeEmail(email));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCustomerRow(rs, conn);
                }
            }
        }
        return null;
    }

    private Admin getAdminByEmail(String email, Connection conn) throws SQLException {
        String sql = "SELECT * FROM admins WHERE LOWER(email) = LOWER(?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizeEmail(email));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAdminRow(rs);
                }
            }
        }
        return null;
    }

    private Customer mapCustomerRow(ResultSet rs, Connection conn) throws SQLException {
        String id = rs.getString("customer_id");
        int bookingCount = getBookingCount(id, conn);

        return new Customer(
                id,
                rs.getString("name"),
                rs.getString("email"),
                rs.getString("password"),
                rs.getString("phone"),
                bookingCount
        );// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    }

    private Admin mapAdminRow(ResultSet rs) throws SQLException {
        return new Admin(
                rs.getString("admin_id"),
                rs.getString("name"),
                rs.getString("email"),
                rs.getString("password"),
                rs.getString("phone"),
                normalizeAdminPermission(rs.getString("admin_permission")) //---------------------------------------------------------------------------------------------------------------------------------------------
        );
    }

    private String generateUserId(String prefix, String table, String column, Connection conn) {
        String sql = "SELECT MAX(CAST(SUBSTRING(" + column + ", 4) AS UNSIGNED)) " +
                "FROM " + table + " WHERE " + column + " LIKE ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prefix + "%");

            try (ResultSet rs = ps.executeQuery()) {
                int next = 1;
                if (rs.next()) {
                    next = rs.getInt(1) + 1;
                }
                return String.format("%s%03d", prefix, next);
            }

        } catch (SQLException e) {
            System.err.println("generateUserId error: " + e.getMessage());
            return prefix + System.currentTimeMillis();
        }
    }

    private String generateAdminRequestId(Connection conn) {
        String sql =
                "SELECT MAX(CAST(SUBSTRING(request_id, 4) AS UNSIGNED)) " +
                        "FROM admin_requests WHERE request_id LIKE 'ARQ%'";

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            int next = 1;
            if (rs.next()) {
                next = rs.getInt(1) + 1;
            }
            return String.format("ARQ%03d", next);

        } catch (SQLException e) {
            System.err.println("generateAdminRequestId error: " + e.getMessage());
            return "ARQ" + System.currentTimeMillis();
        }
    }

    public static boolean hasEventAccess(String permission) {
        String p = permission == null ? Admin.CORE_ADMIN : permission.trim().toUpperCase();
        return Admin.CORE_ADMIN.equals(p)
                || Admin.EVENTS_BOOKINGS_REQUEST_ADMIN.equals(p)
                || Admin.EVENTS_ONLY.equals(p);
    }

    public static boolean hasBookingAccess(String permission) {
        String p = permission == null ? Admin.CORE_ADMIN : permission.trim().toUpperCase();
        return Admin.CORE_ADMIN.equals(p)
                || Admin.EVENTS_BOOKINGS_REQUEST_ADMIN.equals(p)
                || Admin.BOOKINGS_ONLY.equals(p);
    }

    public static boolean hasFullAccess(String permission) {
        String p = permission == null ? Admin.CORE_ADMIN : permission.trim().toUpperCase();
        return Admin.CORE_ADMIN.equals(p);
    }

    public static boolean canRequestAdmin(String permission) {
        String p = permission == null ? Admin.CORE_ADMIN : permission.trim().toUpperCase();
        return Admin.CORE_ADMIN.equals(p)
                || Admin.EVENTS_BOOKINGS_REQUEST_ADMIN.equals(p);
    }

    public static String permissionLabel(String permission) {
        String p = permission == null ? Admin.CORE_ADMIN : permission.trim().toUpperCase();
        switch (p) {
            case Admin.EVENTS_BOOKINGS_REQUEST_ADMIN:
                return "Events + Bookings + New Admin Requests";
            case Admin.EVENTS_ONLY:
                return "Events only";
            case Admin.BOOKINGS_ONLY:
                return "Bookings only";
            default:
                return "Core Admin";
        }
    }

    private String normalizeAdminPermission(String permission) {
        if (permission == null || permission.trim().isEmpty()) {
            return Admin.CORE_ADMIN;
        }

        String p = permission.trim().toUpperCase();

        switch (p) {
            case "CORE_ADMIN":
            case "FULL":
            case "FULL_ACCESS":
                return Admin.CORE_ADMIN;
            case "EVENTS_BOOKINGS_REQUEST_ADMIN":
            case "EVENTS_BOOKINGS":
            case "EVENTS_BOOKINGS_REQUESTS":
            case "EVENTS+BOOKINGS+REQUESTS":
                return Admin.EVENTS_BOOKINGS_REQUEST_ADMIN;
            case "EVENTS":
            case "EVENTS_ONLY":
                return Admin.EVENTS_ONLY;
            case "BOOKINGS":
            case "BOOKINGS_ONLY":
                return Admin.BOOKINGS_ONLY;
            default:
                return Admin.CORE_ADMIN;
        }
    }

    private String safeTrim(String value) {
        return value == null ? null : value.trim();
    }

    private String normalizeEmail(String email) {
        return email == null ? null : email.trim().toLowerCase();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
