package com.eventhorizon.model;

import java.sql.Timestamp;

public class IssueReply {

    private int replyId;
    private int issueId;
    private int adminId;
    private String replyMessage;
    private Timestamp repliedAt;

    // Joined field
    private String adminName;

    // ─── Constructors ────────────────────────────────────────────────────────

    public IssueReply() {}

    public IssueReply(int issueId, int adminId, String replyMessage) {
        this.issueId      = issueId;
        this.adminId      = adminId;
        this.replyMessage = replyMessage;
    }

    // ─── Getters & Setters ───────────────────────────────────────────────────

    public int getReplyId()                        { return replyId; }
    public void setReplyId(int replyId)            { this.replyId = replyId; }

    public int getIssueId()                        { return issueId; }
    public void setIssueId(int issueId)            { this.issueId = issueId; }

    public int getAdminId()                        { return adminId; }
    public void setAdminId(int adminId)            { this.adminId = adminId; }

    public String getReplyMessage()                        { return replyMessage; }
    public void setReplyMessage(String replyMessage)       { this.replyMessage = replyMessage; }

    public Timestamp getRepliedAt()                        { return repliedAt; }
    public void setRepliedAt(Timestamp repliedAt)          { this.repliedAt = repliedAt; }

    public String getAdminName()                           { return adminName; }
    public void setAdminName(String adminName)             { this.adminName = adminName; }
}
