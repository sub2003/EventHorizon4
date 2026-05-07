package com.eventhorizon.model;

import java.sql.Timestamp;
import java.util.List;

public class Issue {

    private int issueId;
    private int userId;
    private Integer bookingId;
    private Integer ticketId;
    private String category;
    private String subject;
    private String description;
    private String priority;
    private String assignedAdminType;
    private String status;
    private String customerEmail;
    private String customerPhone;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Optional: populated when loading issue details
    private List<IssueReply> replies;
    private String userName; // joined from users table

    // ─── Constructors ────────────────────────────────────────────────────────

    public Issue() {}

    public Issue(int userId, String category, String subject, String description,
                 String priority, String assignedAdminType, String customerEmail,
                 String customerPhone, Integer bookingId, Integer ticketId) {
        this.userId           = userId;
        this.category         = category;
        this.subject          = subject;
        this.description      = description;
        this.priority         = priority;
        this.assignedAdminType = assignedAdminType;
        this.customerEmail    = customerEmail;
        this.customerPhone    = customerPhone;
        this.bookingId        = bookingId;
        this.ticketId         = ticketId;
        this.status           = "OPEN";
    }

    // ─── Getters & Setters ───────────────────────────────────────────────────

    public int getIssueId()                      { return issueId; }
    public void setIssueId(int issueId)          { this.issueId = issueId; }

    public int getUserId()                       { return userId; }
    public void setUserId(int userId)            { this.userId = userId; }

    public Integer getBookingId()                { return bookingId; }
    public void setBookingId(Integer bookingId)  { this.bookingId = bookingId; }

    public Integer getTicketId()                 { return ticketId; }
    public void setTicketId(Integer ticketId)    { this.ticketId = ticketId; }

    public String getCategory()                  { return category; }
    public void setCategory(String category)     { this.category = category; }

    public String getSubject()                   { return subject; }
    public void setSubject(String subject)       { this.subject = subject; }

    public String getDescription()               { return description; }
    public void setDescription(String d)         { this.description = d; }

    public String getPriority()                  { return priority; }
    public void setPriority(String priority)     { this.priority = priority; }

    public String getAssignedAdminType()                       { return assignedAdminType; }
    public void setAssignedAdminType(String assignedAdminType) { this.assignedAdminType = assignedAdminType; }

    public String getStatus()                    { return status; }
    public void setStatus(String status)         { this.status = status; }

    public String getCustomerEmail()                     { return customerEmail; }
    public void setCustomerEmail(String customerEmail)   { this.customerEmail = customerEmail; }

    public String getCustomerPhone()                     { return customerPhone; }
    public void setCustomerPhone(String customerPhone)   { this.customerPhone = customerPhone; }

    public Timestamp getCreatedAt()                      { return createdAt; }
    public void setCreatedAt(Timestamp createdAt)        { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt()                      { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt)        { this.updatedAt = updatedAt; }

    public List<IssueReply> getReplies()                 { return replies; }
    public void setReplies(List<IssueReply> replies)     { this.replies = replies; }

    public String getUserName()                          { return userName; }
    public void setUserName(String userName)             { this.userName = userName; }

    // ─── Helpers ────────────────────────────────────────────────────────────

    public String getStatusBadgeClass() {
        switch (status) {
            case "OPEN":        return "badge-open";
            case "IN_PROGRESS": return "badge-progress";
            case "RESOLVED":    return "badge-resolved";
            case "REJECTED":    return "badge-rejected";
            default:            return "badge-secondary";
        }
    }

    public String getPriorityBadgeClass() {
        switch (priority) {
            case "HIGH":   return "priority-high";
            case "LOW":    return "priority-low";
            default:       return "priority-medium";
        }
    }
}
