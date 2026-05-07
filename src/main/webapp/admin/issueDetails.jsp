<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%
    request.setAttribute("pageTitle", "Issue Requests");
%>
<%@ include file="layout.jsp" %>

<style>
    :root {
        --eh-linen: #FAF8F4;
        --eh-paper: #FFFFFF;
        --eh-forest: #1E4A3A;
        --eh-forest-dark: #123528;
        --eh-forest-soft: #E8F1EC;
        --eh-text: #18251F;
        --eh-text-soft: #52635A;
        --eh-muted: #6F7F76;
        --eh-border: rgba(30, 74, 58, 0.16);
        --eh-border-strong: rgba(30, 74, 58, 0.30);
        --eh-success-bg: #E8F6EE;
        --eh-success-text: #176B3B;
        --eh-warning-bg: #FFF7E3;
        --eh-warning-text: #76520F;
        --eh-danger-bg: #FFF0EC;
        --eh-danger-text: #A23A27;

        --accent: #1E4A3A;
        --accent2: #72887A;
        --danger: #A23A27;
        --success: #176B3B;
        --warn: #76520F;
        --bg: #FAF8F4;
        --surface: #FFFFFF;
        --card: #FFFFFF;
        --border: rgba(30, 74, 58, 0.16);
        --text: #18251F;
        --muted: #52635A;
        --radius: 22px;
    }

    .admin-content {
        width: 100%;
    }

    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: var(--eh-forest-dark);
        background: #ffffff;
        border: 1px solid var(--eh-border-strong);
        border-radius: 13px;
        padding: 10px 14px;
        text-decoration: none;
        font-size: 0.86rem;
        font-weight: 900;
        margin-bottom: 20px;
        transition: 0.22s ease;
    }

    .back-link i {
        color: var(--eh-forest);
    }

    .back-link:hover {
        background: var(--eh-forest-soft);
        transform: translateY(-1px);
    }

    .page-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 18px;
        flex-wrap: wrap;
        margin-bottom: 24px;
        padding: 26px 28px;
        background: rgba(255, 255, 255, 0.97);
        border: 1px solid var(--eh-border);
        border-radius: 24px;
        box-shadow: 0 18px 50px rgba(24, 37, 31, 0.09);
    }

    .page-header h2 {
        margin: 0;
        color: var(--eh-forest-dark);
        font-size: clamp(1.8rem, 3vw, 2.35rem);
        font-weight: 900;
        letter-spacing: -0.05em;
        line-height: 1.1;
    }

    .issue-id {
        color: var(--eh-forest);
    }

    .detail-wrap {
        display: grid;
        grid-template-columns: minmax(0, 1fr) 340px;
        gap: 24px;
        align-items: start;
    }

    .card {
        background: #ffffff;
        border: 1px solid var(--eh-border);
        border-radius: 22px;
        padding: 24px;
        margin-bottom: 20px;
        box-shadow: 0 18px 50px rgba(24, 37, 31, 0.09);
        color: var(--eh-text);
    }

    .card h3 {
        color: var(--eh-forest-dark);
        font-size: 1rem;
        font-weight: 900;
        margin-bottom: 18px;
        display: flex;
        align-items: center;
        gap: 9px;
        letter-spacing: -0.01em;
    }

    .card h3 i {
        color: var(--eh-forest);
        font-size: 0.96rem;
    }

    .meta-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 14px;
    }

    .meta-item {
        background: #FAF8F4;
        border: 1px solid rgba(30, 74, 58, 0.12);
        border-radius: 14px;
        padding: 14px;
    }

    .meta-item small,
    .info-row small {
        display: block;
        font-size: 0.72rem;
        color: var(--eh-text-soft);
        margin-bottom: 4px;
        font-weight: 900;
        text-transform: uppercase;
        letter-spacing: 0.6px;
    }

    .meta-item span,
    .info-row div div {
        font-size: 0.92rem;
        font-weight: 900;
        color: var(--eh-text);
        word-break: break-word;
    }

    .badge,
    .priority-badge,
    .cat-chip {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        border-radius: 999px;
        font-size: 0.74rem;
        font-weight: 900;
        letter-spacing: 0.35px;
        text-transform: uppercase;
        white-space: nowrap;
    }

    .badge-open {
        background: var(--eh-danger-bg);
        color: var(--eh-danger-text);
        border: 1px solid rgba(162, 58, 39, 0.24);
    }

    .badge-progress {
        background: var(--eh-warning-bg);
        color: var(--eh-warning-text);
        border: 1px solid rgba(138, 90, 0, 0.24);
    }

    .badge-resolved {
        background: var(--eh-success-bg);
        color: var(--eh-success-text);
        border: 1px solid rgba(23, 107, 59, 0.24);
    }

    .badge-rejected {
        background: #F1F3F1;
        color: #65726C;
        border: 1px solid rgba(101, 114, 108, 0.24);
    }

    .priority-high {
        background: var(--eh-danger-bg);
        color: var(--eh-danger-text);
        border: 1px solid rgba(162, 58, 39, 0.24);
    }

    .priority-medium {
        background: var(--eh-warning-bg);
        color: var(--eh-warning-text);
        border: 1px solid rgba(138, 90, 0, 0.24);
    }

    .priority-low {
        background: var(--eh-success-bg);
        color: var(--eh-success-text);
        border: 1px solid rgba(23, 107, 59, 0.24);
    }

    .cat-chip {
        background: var(--eh-forest-soft);
        color: var(--eh-forest-dark);
        border: 1px solid var(--eh-border-strong);
        text-transform: none;
    }

    .desc-box {
        background: #FAF8F4;
        border: 1px solid rgba(30, 74, 58, 0.14);
        border-radius: 16px;
        padding: 18px;
        line-height: 1.75;
        font-size: 0.92rem;
        white-space: pre-wrap;
        color: var(--eh-text);
        font-weight: 650;
    }

    .reply-thread {
        display: flex;
        flex-direction: column;
        gap: 14px;
    }

    .reply-bubble {
        background: #FAF8F4;
        border: 1px solid rgba(30, 74, 58, 0.14);
        border-radius: 18px;
        padding: 16px;
    }

    .reply-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        margin-bottom: 10px;
        flex-wrap: wrap;
    }

    .reply-author {
        display: flex;
        align-items: center;
        gap: 10px;
        font-weight: 900;
        font-size: 0.88rem;
        color: var(--eh-forest-dark);
    }

    .author-dot {
        width: 34px;
        height: 34px;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, var(--eh-forest), var(--eh-forest-dark));
        color: #ffffff;
        font-weight: 900;
        font-size: 0.82rem;
        flex-shrink: 0;
    }

    .reply-time {
        font-size: 0.76rem;
        color: var(--eh-text-soft);
        font-weight: 750;
    }

    .reply-text {
        font-size: 0.92rem;
        line-height: 1.75;
        white-space: pre-wrap;
        color: var(--eh-text);
        font-weight: 650;
    }

    .admin-reply {
        border-left: 4px solid var(--eh-forest);
    }

    .no-replies {
        text-align: center;
        padding: 30px 20px;
        color: var(--eh-text-soft);
        border: 1px dashed rgba(30, 74, 58, 0.28);
        border-radius: 16px;
        background: #FAF8F4;
        font-weight: 750;
    }

    .no-replies i {
        display: block;
        font-size: 1.6rem;
        margin-bottom: 10px;
        color: var(--eh-forest);
    }

    .form-label {
        display: block;
        color: var(--eh-forest-dark);
        font-size: 0.78rem;
        font-weight: 900;
        letter-spacing: 0.7px;
        text-transform: uppercase;
        margin-bottom: 9px;
    }

    textarea,
    select {
        width: 100%;
        background: #ffffff;
        border: 1px solid var(--eh-border-strong);
        border-radius: 14px;
        color: var(--eh-text);
        padding: 12px 14px;
        font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
        font-size: 0.92rem;
        font-weight: 700;
        outline: none;
    }

    textarea {
        min-height: 140px;
        resize: vertical;
    }

    textarea:focus,
    select:focus {
        border-color: rgba(30, 74, 58, 0.52);
        box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.10);
    }

    .btn-send,
    .qs-btn {
        width: 100%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        min-height: 46px;
        border-radius: 14px;
        padding: 12px 16px;
        margin-top: 14px;
        font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
        font-size: 0.9rem;
        font-weight: 900;
        cursor: pointer;
        transition: 0.22s ease;
    }

    .btn-send {
        color: #ffffff;
        background: linear-gradient(135deg, var(--eh-forest), var(--eh-forest-dark));
        border: 1px solid transparent;
        box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
    }

    .btn-send i {
        color: #ffffff;
    }

    .btn-send:hover,
    .qs-btn:hover {
        transform: translateY(-1px);
    }

    .info-row {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        padding: 13px 0;
        border-bottom: 1px solid rgba(30, 74, 58, 0.12);
    }

    .info-row:last-child {
        border-bottom: none;
    }

    .info-row i {
        width: 38px;
        height: 38px;
        border-radius: 12px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: var(--eh-forest-soft);
        color: var(--eh-forest);
        border: 1px solid var(--eh-border);
        flex-shrink: 0;
    }

    .quick-status {
        display: grid;
        gap: 10px;
    }

    .qs-btn {
        margin-top: 0;
        background: #ffffff;
        color: var(--eh-forest-dark);
        border: 1px solid var(--eh-border-strong);
        box-shadow: none;
    }

    .qs-btn i {
        color: var(--eh-forest);
    }

    .qs-progress:hover,
    .qs-progress.active {
        background: var(--eh-warning-bg);
        color: var(--eh-warning-text);
        border-color: rgba(138, 90, 0, 0.28);
    }

    .qs-resolved:hover,
    .qs-resolved.active {
        background: var(--eh-success-bg);
        color: var(--eh-success-text);
        border-color: rgba(23, 107, 59, 0.28);
    }

    .qs-rejected:hover,
    .qs-rejected.active {
        background: var(--eh-danger-bg);
        color: var(--eh-danger-text);
        border-color: rgba(162, 58, 39, 0.28);
    }

    @media (max-width: 980px) {
        .detail-wrap {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 640px) {
        .meta-grid {
            grid-template-columns: 1fr;
        }

        .page-header {
            padding: 22px;
        }
    }
</style>

<div class="admin-content">

    <a href="${pageContext.request.contextPath}/IssueServlet?action=adminList" class="back-link">
        <i class="fas fa-arrow-left"></i> Back to Issues
    </a>

    <div class="page-header">
        <div>
            <h2>Issue <span class="issue-id">#${issue.issueId}</span></h2>
            <div style="margin-top:5px; display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                <span class="cat-chip">${issue.category}</span>
                <span class="badge badge-${issue.status == 'IN_PROGRESS' ? 'progress' : issue.status.toLowerCase()}">
                    <c:choose>
                        <c:when test="${issue.status == 'OPEN'}"><i class="fas fa-circle-dot"></i> Open</c:when>
                        <c:when test="${issue.status == 'IN_PROGRESS'}"><i class="fas fa-spinner"></i> In Progress</c:when>
                        <c:when test="${issue.status == 'RESOLVED'}"><i class="fas fa-check-circle"></i> Resolved</c:when>
                        <c:otherwise><i class="fas fa-ban"></i> Rejected</c:otherwise>
                    </c:choose>
                </span>
                <span class="priority-badge priority-${issue.priority.toLowerCase()}">${issue.priority}</span>
            </div>
        </div>
    </div>

    <div class="detail-wrap">

        <div>
            <div class="card">
                <h3><i class="fas fa-info-circle"></i> Issue Details</h3>

                <div style="margin-bottom:18px;">
                    <span style="font-size:1.05rem; font-weight:600;">${issue.subject}</span>
                </div>

                <div class="meta-grid" style="margin-bottom:18px;">
                    <div class="meta-item">
                        <small>Submitted By</small>
                        <span>${issue.userName}</span>
                    </div>
                    <div class="meta-item">
                        <small>Email</small>
                        <span>${issue.customerEmail}</span>
                    </div>

                    <c:if test="${not empty issue.customerPhone}">
                        <div class="meta-item">
                            <small>Phone</small>
                            <span>${issue.customerPhone}</span>
                        </div>
                    </c:if>

                    <div class="meta-item">
                        <small>Submitted On</small>
                        <span><fmt:formatDate value="${issue.createdAt}" pattern="dd MMM yyyy, hh:mm a" /></span>
                    </div>

                    <c:if test="${issue.bookingId != null}">
                        <div class="meta-item">
                            <small>Booking ID</small>
                            <span>#${issue.bookingId}</span>
                        </div>
                    </c:if>

                    <c:if test="${issue.ticketId != null}">
                        <div class="meta-item">
                            <small>Ticket ID</small>
                            <span>#${issue.ticketId}</span>
                        </div>
                    </c:if>

                    <div class="meta-item">
                        <small>Assigned To</small>
                        <span>${issue.assignedAdminType.replace('_', ' ')}</span>
                    </div>

                    <div class="meta-item">
                        <small>Last Updated</small>
                        <span>
                            <c:choose>
                                <c:when test="${not empty issue.updatedAt}">
                                    <fmt:formatDate value="${issue.updatedAt}" pattern="dd MMM yyyy, hh:mm a" />
                                </c:when>
                                <c:otherwise>
                                    -
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <small style="font-size:.75rem; color:var(--muted); display:block; margin-bottom:8px;">Description</small>
                <div class="desc-box">${issue.description}</div>
            </div>

            <div class="card">
                <h3><i class="fas fa-comments"></i> Reply History</h3>
                <c:choose>
                    <c:when test="${not empty issue.replies}">
                        <div class="reply-thread">
                            <c:forEach var="reply" items="${issue.replies}">
                                <div class="reply-bubble admin-reply">
                                    <div class="reply-header">
                                        <div class="reply-author">
                                            <div class="author-dot">${reply.adminName.substring(0,1).toUpperCase()}</div>
                                            ${reply.adminName}
                                            <span style="background:rgba(108,92,231,.15);color:#a29bfe;padding:2px 8px;border-radius:100px;font-size:.68rem;">Admin</span>
                                        </div>
                                        <span class="reply-time">
                                            <fmt:formatDate value="${reply.repliedAt}" pattern="dd MMM yyyy, hh:mm a" />
                                        </span>
                                    </div>
                                    <div class="reply-text">${reply.replyMessage}</div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="no-replies">
                            <i class="fas fa-comment-slash"></i>
                            No replies yet. Use the form on the right to respond.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <c:if test="${issue.status != 'RESOLVED' && issue.status != 'REJECTED'}">
                <div class="card">
                    <h3><i class="fas fa-reply"></i> Send Reply to Customer</h3>

                    <form action="${pageContext.request.contextPath}/IssueServlet" method="post">
                        <input type="hidden" name="action" value="reply" />
                        <input type="hidden" name="issueId" value="${issue.issueId}" />

                        <div style="margin-bottom:14px;">
                            <label class="form-label">Reply Message <span style="color:var(--danger);">*</span></label>
                            <textarea name="replyMessage" placeholder="Type your reply to the customer here…" required></textarea>
                        </div>

                        <div>
                            <label class="form-label">Update Status (optional)</label>
                            <select name="newStatus">
                                <option value="">Keep current status</option>
                                <option value="IN_PROGRESS">In Progress</option>
                                <option value="RESOLVED">Resolved</option>
                                <option value="REJECTED">Rejected</option>
                            </select>
                        </div>

                        <button type="submit" class="btn-send">
                            <i class="fas fa-paper-plane"></i> Send Reply
                        </button>
                    </form>
                </div>
            </c:if>
        </div>

        <div>
            <div class="card">
                <h3><i class="fas fa-user-circle"></i> Customer Contact</h3>

                <div class="info-row">
                    <i class="fas fa-envelope"></i>
                    <div>
                        <small>Email</small>
                        <div>${issue.customerEmail}</div>
                    </div>
                </div>

                <c:if test="${not empty issue.customerPhone}">
                    <div class="info-row">
                        <i class="fas fa-phone"></i>
                        <div>
                            <small>Phone</small>
                            <div>${issue.customerPhone}</div>
                        </div>
                    </div>
                </c:if>

                <div class="info-row">
                    <i class="fas fa-layer-group"></i>
                    <div>
                        <small>Category</small>
                        <div>${issue.category}</div>
                    </div>
                </div>

                <div class="info-row">
                    <i class="fas fa-shield-halved"></i>
                    <div>
                        <small>Assigned Admin Type</small>
                        <div>${issue.assignedAdminType.replace('_', ' ')}</div>
                    </div>
                </div>
            </div>

            <c:if test="${issue.status != 'RESOLVED' && issue.status != 'REJECTED'}">
                <div class="card">
                    <h3><i class="fas fa-bolt"></i> Quick Status</h3>

                    <div class="quick-status">
                        <form action="${pageContext.request.contextPath}/IssueServlet" method="post">
                            <input type="hidden" name="action" value="updateStatus" />
                            <input type="hidden" name="issueId" value="${issue.issueId}" />
                            <input type="hidden" name="status" value="IN_PROGRESS" />
                            <button type="submit" class="qs-btn qs-progress ${issue.status == 'IN_PROGRESS' ? 'active' : ''}">
                                <i class="fas fa-spinner"></i> Mark In Progress
                            </button>
                        </form>

                        <form action="${pageContext.request.contextPath}/IssueServlet" method="post">
                            <input type="hidden" name="action" value="updateStatus" />
                            <input type="hidden" name="issueId" value="${issue.issueId}" />
                            <input type="hidden" name="status" value="RESOLVED" />
                            <button type="submit" class="qs-btn qs-resolved ${issue.status == 'RESOLVED' ? 'active' : ''}">
                                <i class="fas fa-check-circle"></i> Mark Resolved
                            </button>
                        </form>

                        <form action="${pageContext.request.contextPath}/IssueServlet" method="post">
                            <input type="hidden" name="action" value="updateStatus" />
                            <input type="hidden" name="issueId" value="${issue.issueId}" />
                            <input type="hidden" name="status" value="REJECTED" />
                            <button type="submit" class="qs-btn qs-rejected ${issue.status == 'REJECTED' ? 'active' : ''}">
                                <i class="fas fa-ban"></i> Reject Issue
                            </button>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>

    </div>

</div>

</main>
</div>

</body>
</html>