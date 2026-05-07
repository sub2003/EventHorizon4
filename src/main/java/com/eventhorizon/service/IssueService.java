package com.eventhorizon.service;

import com.eventhorizon.model.Issue;
import com.eventhorizon.model.IssueReply;
import com.eventhorizon.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class IssueService {

    public static String resolveAdminType(String category) {
        if (category == null) {
            return "CORE_ADMIN";
        }

        switch (category.trim()) {
            case "Booking Problem":
            case "Payment Verification Issue":
            case "Ticket Not Received":
            case "QR Code Not Working":
            case "Refund Request":
            case "Seat Availability Problem":
                return "BOOKINGS_ADMIN";

            case "Event Information Error":
            case "Event Cancellation Complaint":
                return "EVENTS_ADMIN";

            case "Account Login Problem":
            case "Profile / Registration Problem":
            case "Website Technical Issue":
            case "General Inquiry":
            case "Other":
            default:
                return "CORE_ADMIN";
        }
    }

    public boolean submitIssue(Issue issue) {
        String sql = "INSERT INTO issues (user_id, booking_id, ticket_id, category, subject, " +
                "description, priority, assigned_admin_type, status, customer_email, customer_phone) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'OPEN', ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, issue.getUserId());

            if (issue.getBookingId() != null) {
                ps.setInt(2, issue.getBookingId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            if (issue.getTicketId() != null) {
                ps.setInt(3, issue.getTicketId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }

            ps.setString(4, safeTrim(issue.getCategory()));
            ps.setString(5, safeTrim(issue.getSubject()));
            ps.setString(6, safeTrim(issue.getDescription()));
            ps.setString(7, normalizePriority(issue.getPriority()));
            ps.setString(8, safeTrim(issue.getAssignedAdminType()));
            ps.setString(9, safeTrim(issue.getCustomerEmail()));
            ps.setString(10, safeTrim(issue.getCustomerPhone()));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        issue.setIssueId(keys.getInt(1));
                    }
                }
                return true;
            }

        } catch (Exception e) {
            System.err.println("[IssueService] submitIssue error: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    public List<Issue> getAllIssues() {
        return getIssuesByFilter(null, null, null);
    }

    public List<Issue> getIssuesByAdminType(String adminType) {
        return getIssuesByFilter(adminType, null, null);
    }

    public List<Issue> getIssuesByFilter(String adminTypeFilter, String categoryFilter, String statusFilter) {
        List<Issue> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT * FROM issues WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        appendAdminTypeCondition(sql, params, adminTypeFilter);

        if (!isBlank(categoryFilter) && !"ALL".equalsIgnoreCase(categoryFilter.trim())) {
            sql.append("AND category = ? ");
            params.add(categoryFilter.trim());
        }

        if (!isBlank(statusFilter) && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND status = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }

        sql.append("ORDER BY created_at DESC, issue_id DESC");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapIssue(rs));
                }
            }

        } catch (Exception e) {
            System.err.println("[IssueService] getIssuesByFilter error: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    public Issue getIssueById(int issueId) {
        String sql = "SELECT * FROM issues WHERE issue_id = ?";
        Issue issue = null;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, issueId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    issue = mapIssue(rs);
                    issue.setReplies(getRepliesByIssueId(issueId));
                }
            }

        } catch (Exception e) {
            System.err.println("[IssueService] getIssueById error: " + e.getMessage());
            e.printStackTrace();
        }

        return issue;
    }

    public List<Issue> getIssuesByUser(int userId) {
        List<Issue> list = new ArrayList<>();
        String sql = "SELECT * FROM issues WHERE user_id = ? ORDER BY created_at DESC, issue_id DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapIssue(rs));
                }
            }

        } catch (Exception e) {
            System.err.println("[IssueService] getIssuesByUser error: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    public boolean updateStatus(int issueId, String status) {
        String sql = "UPDATE issues SET status = ? WHERE issue_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, safeStatus(status));
            ps.setInt(2, issueId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("[IssueService] updateStatus error: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    public boolean addReply(IssueReply reply) {
        String sql = "INSERT INTO issue_replies (issue_id, admin_id, reply_message) VALUES (?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, reply.getIssueId());
            ps.setInt(2, reply.getAdminId());
            ps.setString(3, safeTrim(reply.getReplyMessage()));

            if (ps.executeUpdate() > 0) {
                updateStatusIfOpen(reply.getIssueId());
                return true;
            }

        } catch (Exception e) {
            System.err.println("[IssueService] addReply error: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    private void updateStatusIfOpen(int issueId) {
        String sql = "UPDATE issues SET status = 'IN_PROGRESS' WHERE issue_id = ? AND status = 'OPEN'";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, issueId);
            ps.executeUpdate();

        } catch (Exception e) {
            System.err.println("[IssueService] updateStatusIfOpen error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public List<IssueReply> getRepliesByIssueId(int issueId) {
        List<IssueReply> list = new ArrayList<>();
        String sql = "SELECT * FROM issue_replies WHERE issue_id = ? ORDER BY replied_at ASC, reply_id ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, issueId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    IssueReply reply = new IssueReply();
                    reply.setReplyId(rs.getInt("reply_id"));
                    reply.setIssueId(rs.getInt("issue_id"));
                    reply.setAdminId(rs.getInt("admin_id"));
                    reply.setReplyMessage(rs.getString("reply_message"));
                    reply.setRepliedAt(rs.getTimestamp("replied_at"));
                    reply.setAdminName("Admin #" + rs.getInt("admin_id"));
                    list.add(reply);
                }
            }

        } catch (Exception e) {
            System.err.println("[IssueService] getRepliesByIssueId error: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    public int countIssuesWithRepliesByUser(int userId) {
        String sql = "SELECT COUNT(DISTINCT i.issue_id) " +
                "FROM issues i WHERE i.user_id = ? " +
                "AND EXISTS (SELECT 1 FROM issue_replies r WHERE r.issue_id = i.issue_id)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            System.err.println("[IssueService] countIssuesWithRepliesByUser error: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    public boolean issueBelongsToUser(int issueId, int userId) {
        String sql = "SELECT 1 FROM issues WHERE issue_id = ? AND user_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, issueId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            System.err.println("[IssueService] issueBelongsToUser error: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    public int countByStatus(String status, String adminType) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM issues WHERE status = ? ");
        List<Object> params = new ArrayList<>();
        params.add(safeStatus(status));

        appendAdminTypeCondition(sql, params, adminType);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            System.err.println("[IssueService] countByStatus error: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /*
     * This method is the important fix.
     *
     * The issues table stores assigned_admin_type as:
     * CORE_ADMIN / EVENTS_ADMIN / BOOKINGS_ADMIN
     *
     * But your logged-in admin permission can be:
     * CORE_ADMIN / EVENTS_BOOKINGS_REQUEST_ADMIN / EVENTS_ONLY / BOOKINGS_ONLY
     *
     * Also IssueServlet converts Events + Bookings permission into:
     * EVENTS_AND_BOOKINGS_ADMIN
     *
     * So we convert all possible admin permission names into the actual
     * assigned_admin_type values stored in the issues table.
     */
    private void appendAdminTypeCondition(StringBuilder sql, List<Object> params, String adminTypeFilter) {
        List<String> allowedAssignedTypes = getAllowedAssignedAdminTypes(adminTypeFilter);

        // null means Core Admin / full access / no admin-type restriction
        if (allowedAssignedTypes == null) {
            return;
        }

        // Empty list means invalid/unknown permission. Return no rows safely.
        if (allowedAssignedTypes.isEmpty()) {
            sql.append("AND 1 = 0 ");
            return;
        }

        sql.append("AND assigned_admin_type IN (");
        for (int i = 0; i < allowedAssignedTypes.size(); i++) {
            if (i > 0) {
                sql.append(", ");
            }
            sql.append("?");
            params.add(allowedAssignedTypes.get(i));
        }
        sql.append(") ");
    }

    private List<String> getAllowedAssignedAdminTypes(String adminTypeFilter) {
        if (isBlank(adminTypeFilter)) {
            return null;
        }

        String normalized = adminTypeFilter.trim().toUpperCase();

        if (isCorePermission(normalized)) {
            return null;
        }

        List<String> result = new ArrayList<>();
        String[] parts = normalized.split(",");

        for (String part : parts) {
            String value = part == null ? "" : part.trim().toUpperCase();
            if (value.isEmpty()) {
                continue;
            }

            if (isCorePermission(value)) {
                return null;
            }

            if (isEventsAndBookingsPermission(value)) {
                addUnique(result, "EVENTS_ADMIN");
                addUnique(result, "BOOKINGS_ADMIN");
            } else if (isEventsPermission(value)) {
                addUnique(result, "EVENTS_ADMIN");
            } else if (isBookingsPermission(value)) {
                addUnique(result, "BOOKINGS_ADMIN");
            } else {
                // Backward-compatible fallback for old direct assigned_admin_type values.
                addUnique(result, value);
            }
        }

        return result;
    }

    private boolean isCorePermission(String value) {
        return "CORE_ADMIN".equals(value)
                || value.contains("CORE")
                || value.contains("FULL");
    }

    private boolean isEventsAndBookingsPermission(String value) {
        return "EVENTS_AND_BOOKINGS_ADMIN".equals(value)
                || "EVENTS_BOOKINGS_REQUEST_ADMIN".equals(value)
                || "EVENTS_AND_BOOKINGS_REQUEST_ADMIN".equals(value)
                || (value.contains("EVENT") && value.contains("BOOKING"));
    }

    private boolean isEventsPermission(String value) {
        return "EVENTS_ADMIN".equals(value)
                || "EVENTS_ONLY".equals(value)
                || value.contains("EVENT");
    }

    private boolean isBookingsPermission(String value) {
        return "BOOKINGS_ADMIN".equals(value)
                || "BOOKINGS_ONLY".equals(value)
                || value.contains("BOOKING");
    }

    private void addUnique(List<String> list, String value) {
        if (!list.contains(value)) {
            list.add(value);
        }
    }

    private Issue mapIssue(ResultSet rs) throws SQLException {
        Issue issue = new Issue();

        issue.setIssueId(rs.getInt("issue_id"));
        issue.setUserId(rs.getInt("user_id"));

        Object bookingIdObj = rs.getObject("booking_id");
        issue.setBookingId(bookingIdObj != null ? ((Number) bookingIdObj).intValue() : null);

        Object ticketIdObj = rs.getObject("ticket_id");
        issue.setTicketId(ticketIdObj != null ? ((Number) ticketIdObj).intValue() : null);

        issue.setCategory(rs.getString("category"));
        issue.setSubject(rs.getString("subject"));
        issue.setDescription(rs.getString("description"));
        issue.setPriority(rs.getString("priority"));
        issue.setAssignedAdminType(rs.getString("assigned_admin_type"));
        issue.setStatus(rs.getString("status"));
        issue.setCustomerEmail(rs.getString("customer_email"));
        issue.setCustomerPhone(rs.getString("customer_phone"));
        issue.setCreatedAt(rs.getTimestamp("created_at"));

        // IMPORTANT:
        // Some databases do not have updated_at in issues table.
        // So read it safely instead of crashing the whole row mapping.
        issue.setUpdatedAt(getOptionalTimestamp(rs, "updated_at"));

        String customerEmail = rs.getString("customer_email");
        if (customerEmail != null && !customerEmail.trim().isEmpty()) {
            issue.setUserName(customerEmail);
        } else {
            issue.setUserName("User #" + rs.getInt("user_id"));
        }

        return issue;
    }

    private Timestamp getOptionalTimestamp(ResultSet rs, String columnName) {
        try {
            return rs.getTimestamp(columnName);
        } catch (SQLException e) {
            return null;
        }
    }

    private String normalizePriority(String priority) {
        if (priority == null || priority.trim().isEmpty()) {
            return "MEDIUM";
        }

        String value = priority.trim().toUpperCase();
        switch (value) {
            case "LOW":
            case "HIGH":
            case "MEDIUM":
                return value;
            default:
                return "MEDIUM";
        }
    }

    private String safeStatus(String status) {
        if (status == null || status.trim().isEmpty()) {
            return "OPEN";
        }

        String value = status.trim().toUpperCase();
        switch (value) {
            case "OPEN":
            case "IN_PROGRESS":
            case "RESOLVED":
            case "REJECTED":
                return value;
            default:
                return "OPEN";
        }
    }

    private String safeTrim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
