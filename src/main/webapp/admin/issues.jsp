<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventhorizon.model.Issue" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%
    request.setAttribute("pageTitle", "Issue Requests");

    List<Issue> issueListRaw = (List<Issue>) request.getAttribute("issueList");
    Integer showingCountRaw = (Integer) request.getAttribute("showingCount");

    int safeShowingCount = 0;
    if (showingCountRaw != null) {
        safeShowingCount = showingCountRaw;
    } else if (issueListRaw != null) {
        safeShowingCount = issueListRaw.size();
    }
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

        /* Keep old variable names readable because the JSP already uses them inline */
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
    }

    .admin-content {
        width: 100%;
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

    .page-header h2 span {
        color: var(--eh-forest);
    }

    .admin-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: var(--eh-forest-soft);
        color: var(--eh-forest-dark);
        border: 1px solid var(--eh-border-strong);
        border-radius: 999px;
        padding: 9px 14px;
        font-size: 0.8rem;
        font-weight: 900;
        white-space: nowrap;
    }

    .admin-badge i {
        color: var(--eh-forest);
    }

    .stat-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
        gap: 16px;
        margin-bottom: 24px;
    }

    .stat-card {
        background: #ffffff;
        border: 1px solid var(--eh-border);
        border-radius: 20px;
        padding: 20px;
        display: flex;
        flex-direction: column;
        gap: 8px;
        box-shadow: 0 14px 34px rgba(24, 37, 31, 0.07);
        position: relative;
        overflow: hidden;
    }

    .stat-card::before {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 5px;
        background: var(--eh-forest);
    }

    .stat-card.open::before { background: var(--eh-danger-text); }
    .stat-card.progress::before { background: #C2882E; }
    .stat-card.resolved::before { background: var(--eh-success-text); }

    .stat-card .stat-val {
        font-size: 2.2rem;
        font-weight: 900;
        line-height: 1;
        color: var(--eh-forest-dark);
    }

    .stat-card .stat-lbl {
        font-size: 0.78rem;
        color: var(--eh-text-soft);
        font-weight: 900;
        letter-spacing: 0.6px;
        text-transform: uppercase;
    }

    .filter-bar {
        display: flex;
        flex-wrap: wrap;
        gap: 14px;
        align-items: flex-end;
        background: #ffffff;
        border: 1px solid var(--eh-border);
        border-radius: 20px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 14px 34px rgba(24, 37, 31, 0.07);
    }

    .filter-bar > div {
        min-width: 170px;
    }

    .filter-bar label {
        font-size: 0.76rem;
        color: var(--eh-forest-dark);
        display: block;
        margin-bottom: 7px;
        font-weight: 900;
        letter-spacing: 0.6px;
        text-transform: uppercase;
    }

    .filter-bar select,
    .filter-bar input {
        width: 100%;
        background: #ffffff;
        border: 1px solid var(--eh-border-strong);
        border-radius: 12px;
        color: var(--eh-text);
        padding: 11px 13px;
        font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
        font-size: 0.9rem;
        font-weight: 700;
        outline: none;
    }

    .filter-bar select:focus,
    .filter-bar input:focus {
        border-color: rgba(30, 74, 58, 0.52);
        box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.10);
    }

    .btn-filter,
    .btn-reset,
    .btn-view {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        min-height: 42px;
        padding: 10px 16px;
        border-radius: 12px;
        font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
        font-size: 0.86rem;
        font-weight: 900;
        cursor: pointer;
        text-decoration: none;
        transition: 0.22s ease;
        white-space: nowrap;
    }

    .btn-filter {
        background: linear-gradient(135deg, var(--eh-forest), var(--eh-forest-dark));
        border: 1px solid transparent;
        color: #ffffff;
        box-shadow: 0 12px 26px rgba(30, 74, 58, 0.22);
    }

    .btn-filter i {
        color: #ffffff;
    }

    .btn-filter:hover,
    .btn-reset:hover,
    .btn-view:hover {
        transform: translateY(-1px);
    }

    .btn-reset,
    .btn-view {
        background: #ffffff;
        border: 1px solid var(--eh-border-strong);
        color: var(--eh-forest-dark);
        box-shadow: none;
    }

    .btn-reset:hover,
    .btn-view:hover {
        background: var(--eh-forest-soft);
        border-color: rgba(30, 74, 58, 0.42);
    }

    .btn-view i {
        color: var(--eh-forest);
    }

    .table-wrap {
        overflow-x: auto;
        background: #ffffff;
        border: 1px solid var(--eh-border);
        border-radius: 22px;
        box-shadow: 0 18px 50px rgba(24, 37, 31, 0.09);
    }

    table {
        width: 100%;
        border-collapse: collapse;
        min-width: 960px;
        background: #ffffff;
    }

    th {
        font-size: 0.75rem;
        font-weight: 900;
        color: var(--eh-forest-dark);
        text-transform: uppercase;
        letter-spacing: 0.7px;
        padding: 14px 16px;
        border-bottom: 1px solid var(--eh-border-strong);
        background: var(--eh-forest-soft);
        text-align: left;
        white-space: nowrap;
    }

    td {
        padding: 16px;
        border-bottom: 1px solid rgba(30, 74, 58, 0.12);
        font-size: 0.9rem;
        color: var(--eh-text);
        vertical-align: middle;
        font-weight: 700;
    }

    tr:hover td {
        background: #FAF8F4;
    }

    .id-cell {
        color: var(--eh-forest-dark);
        font-weight: 900;
    }

    .badge {
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

    .priority-dot {
        display: inline-block;
        width: 10px;
        height: 10px;
        border-radius: 50%;
        margin-right: 7px;
        vertical-align: middle;
    }

    .p-high { background: var(--eh-danger-text); }
    .p-medium { background: #C2882E; }
    .p-low { background: var(--eh-success-text); }

    .cat-chip {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: var(--eh-forest-soft);
        color: var(--eh-forest-dark);
        padding: 6px 12px;
        border-radius: 999px;
        border: 1px solid var(--eh-border-strong);
        font-size: 0.76rem;
        font-weight: 900;
        white-space: nowrap;
    }

    .empty-state {
        text-align: center;
        padding: 52px 24px;
        color: var(--eh-text-soft);
        font-weight: 750;
        background: #ffffff;
    }

    .empty-state i {
        display: block;
        font-size: 2rem;
        margin-bottom: 12px;
        color: var(--eh-forest);
    }

    @media (max-width: 768px) {
        .page-header,
        .filter-bar {
            align-items: stretch;
        }

        .filter-bar > div,
        .btn-filter,
        .btn-reset {
            width: 100%;
        }
    }
</style>

<div class="admin-content">

    <div class="page-header">
        <h2>Issue <span>Management</span></h2>
        <span class="admin-badge"><i class="fas fa-user-shield"></i> ${adminType}</span>
    </div>

    <div class="stat-grid">
        <div class="stat-card open">
            <span class="stat-val" style="color:var(--danger);">${openCount}</span>
            <span class="stat-lbl">Open Issues</span>
        </div>
        <div class="stat-card progress">
            <span class="stat-val" style="color:var(--warn);">${progressCount}</span>
            <span class="stat-lbl">In Progress</span>
        </div>
        <div class="stat-card resolved">
            <span class="stat-val" style="color:var(--success);">${resolvedCount}</span>
            <span class="stat-lbl">Resolved</span>
        </div>
        <div class="stat-card" style="border-left:3px solid var(--accent);">
            <span class="stat-val" style="color:var(--accent);"><%= safeShowingCount %></span>
            <span class="stat-lbl">Showing</span>
        </div>
    </div>

    <form action="${pageContext.request.contextPath}/IssueServlet" method="get" class="filter-bar">
        <input type="hidden" name="action" value="adminList" />

        <div>
            <label>Category</label>
            <select name="category">
                <option value="">All Categories</option>
                <optgroup label="Booking &amp; Payments">
                    <option value="Booking Problem" <c:if test="${catFilter=='Booking Problem'}">selected</c:if>>Booking Problem</option>
                    <option value="Payment Verification Issue" <c:if test="${catFilter=='Payment Verification Issue'}">selected</c:if>>Payment Verification Issue</option>
                    <option value="Ticket Not Received" <c:if test="${catFilter=='Ticket Not Received'}">selected</c:if>>Ticket Not Received</option>
                    <option value="QR Code Not Working" <c:if test="${catFilter=='QR Code Not Working'}">selected</c:if>>QR Code Not Working</option>
                    <option value="Refund Request" <c:if test="${catFilter=='Refund Request'}">selected</c:if>>Refund Request</option>
                    <option value="Seat Availability Problem" <c:if test="${catFilter=='Seat Availability Problem'}">selected</c:if>>Seat Availability Problem</option>
                </optgroup>
                <optgroup label="Events">
                    <option value="Event Information Error" <c:if test="${catFilter=='Event Information Error'}">selected</c:if>>Event Information Error</option>
                    <option value="Event Cancellation Complaint" <c:if test="${catFilter=='Event Cancellation Complaint'}">selected</c:if>>Event Cancellation Complaint</option>
                </optgroup>
                <optgroup label="Account &amp; Technical">
                    <option value="Account Login Problem" <c:if test="${catFilter=='Account Login Problem'}">selected</c:if>>Account Login Problem</option>
                    <option value="Profile / Registration Problem" <c:if test="${catFilter=='Profile / Registration Problem'}">selected</c:if>>Profile / Registration Problem</option>
                    <option value="Website Technical Issue" <c:if test="${catFilter=='Website Technical Issue'}">selected</c:if>>Website Technical Issue</option>
                </optgroup>
                <optgroup label="General">
                    <option value="General Inquiry" <c:if test="${catFilter=='General Inquiry'}">selected</c:if>>General Inquiry</option>
                    <option value="Other" <c:if test="${catFilter=='Other'}">selected</c:if>>Other</option>
                </optgroup>
            </select>
        </div>

        <div>
            <label>Status</label>
            <select name="status">
                <option value="">All Statuses</option>
                <option value="OPEN" <c:if test="${statFilter=='OPEN'}">selected</c:if>>Open</option>
                <option value="IN_PROGRESS" <c:if test="${statFilter=='IN_PROGRESS'}">selected</c:if>>In Progress</option>
                <option value="RESOLVED" <c:if test="${statFilter=='RESOLVED'}">selected</c:if>>Resolved</option>
                <option value="REJECTED" <c:if test="${statFilter=='REJECTED'}">selected</c:if>>Rejected</option>
            </select>
        </div>

        <button type="submit" class="btn-filter"><i class="fas fa-filter"></i> Filter</button>
        <a href="${pageContext.request.contextPath}/IssueServlet?action=adminList" class="btn-reset">Reset</a>
    </form>

    <div class="table-wrap">
        <%
            if (issueListRaw != null && !issueListRaw.isEmpty()) {
        %>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Customer</th>
                    <th>Category</th>
                    <th>Subject</th>
                    <th>Priority</th>
                    <th>Status</th>
                    <th>Submitted</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Issue issue : issueListRaw) {
                        String priority = issue.getPriority() != null ? issue.getPriority() : "MEDIUM";
                        String priorityClass = priority.toLowerCase();

                        String status = issue.getStatus() != null ? issue.getStatus() : "OPEN";
                        String badgeClass = "badge-" + status.toLowerCase();
                        if ("IN_PROGRESS".equals(status)) {
                            badgeClass = "badge-progress";
                        }
                %>
                <tr>
                    <td class="id-cell">#<%= issue.getIssueId() %></td>
                    <td>
                        <div style="font-weight:500;">
                            <%= (issue.getUserName() != null && !issue.getUserName().trim().isEmpty())
                                    ? issue.getUserName()
                                    : "Customer #" + issue.getUserId() %>
                        </div>
                        <div style="font-size:.76rem;color:var(--muted);">
                            <%= issue.getCustomerEmail() != null ? issue.getCustomerEmail() : "" %>
                        </div>
                    </td>
                    <td>
                        <span class="cat-chip"><%= issue.getCategory() != null ? issue.getCategory() : "" %></span>
                    </td>
                    <td style="max-width:220px;">
                        <div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:220px;"
                             title="<%= issue.getSubject() != null ? issue.getSubject() : "" %>">
                            <%= issue.getSubject() != null ? issue.getSubject() : "" %>
                        </div>
                    </td>
                    <td>
                        <span class="priority-dot p-<%= priorityClass %>"></span>
                        <%= priority %>
                    </td>
                    <td>
                        <span class="badge <%= badgeClass %>">
                            <%= status %>
                        </span>
                    </td>
                    <td style="white-space:nowrap;color:var(--muted);font-size:.8rem;">
                        <%
                            if (issue.getCreatedAt() != null) {
                        %>
                            <fmt:formatDate value="<%= issue.getCreatedAt() %>" pattern="dd MMM yyyy" />
                        <%
                            } else {
                        %>
                            -
                        <%
                            }
                        %>
                    </td>
                    <td>
                        <a href="<%= request.getContextPath() %>/IssueServlet?action=adminDetail&id=<%= issue.getIssueId() %>" class="btn-view">
                            <i class="fas fa-eye"></i> View
                        </a>
                    </td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        <%
            } else {
        %>
        <div class="empty-state">
            <i class="fas fa-inbox"></i>
            No issues found matching your filters.
        </div>
        <%
            }
        %>
    </div>

</div>

</main>
</div>

</body>
</html>