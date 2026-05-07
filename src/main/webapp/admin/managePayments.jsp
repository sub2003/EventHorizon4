<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventhorizon.model.Booking" %>
<%@ page import="com.eventhorizon.model.Admin" %>
<%@ page import="com.eventhorizon.service.UserService" %>

<%
    HttpSession currentSession = request.getSession(false);
    String role = currentSession != null ? (String) currentSession.getAttribute("role") : null;
    String adminPermission = currentSession != null ? (String) currentSession.getAttribute("adminPermission") : null;

    if (currentSession == null || role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }

    if (adminPermission == null || adminPermission.trim().isEmpty()) {
        adminPermission = Admin.CORE_ADMIN;
    }

    boolean hasFullAccess = UserService.hasFullAccess(adminPermission);
    boolean canManageEvents = UserService.hasEventAccess(adminPermission);
    boolean canManageBookings = UserService.hasBookingAccess(adminPermission);
    boolean canRequestAdmins = UserService.canRequestAdmin(adminPermission);

    if (!canManageBookings) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp?error=noBookingPermission");
        return;
    }

    List<Booking> pendingBookings = (List<Booking>) request.getAttribute("pendingBookings");
    if (pendingBookings == null) pendingBookings = new java.util.ArrayList<>();

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Payments - EventHorizon</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,600..900,40,0..1&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css?v=20260501">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin.css?v=20260501">
</head>
<body>

<div class="admin-shell">
    <aside class="sidebar">
        <div>
            <div class="brand">
                <div class="brand-icon"><i class="fa-solid fa-leaf"></i></div>
                <div>
                    <h2>EVENTHORIZON</h2>
                    <p>Admin Workspace</p>
                </div>
            </div>

            <nav class="nav-links">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp">
                    <i class="fa-solid fa-chart-line"></i>
                    <span>Dashboard</span>
                </a>

                <% if (hasFullAccess) { %>
                <a href="<%= request.getContextPath() %>/user?action=list">
                    <i class="fa-solid fa-users"></i>
                    <span>Manage Users</span>
                </a>
                <% } %>

                <% if (canManageEvents) { %>
                <a href="<%= request.getContextPath() %>/event?action=adminList">
                    <i class="fa-solid fa-calendar-days"></i>
                    <span>Manage Events</span>
                </a>
                <% } %>

                <% if (canManageBookings) { %>
                <a href="<%= request.getContextPath() %>/booking?action=allBookings">
                    <i class="fa-solid fa-ticket"></i>
                    <span>Bookings</span>
                </a>

                <a class="active" href="<%= request.getContextPath() %>/booking?action=pendingPayments">
                    <i class="fa-solid fa-money-check-dollar"></i>
                    <span>Manage Payments</span>
                </a>
                <% } %>

                <a href="<%= request.getContextPath() %>/IssueServlet?action=adminList">
                    <i class="fa-solid fa-envelope-open-text"></i>
                    <span>Issue Requests</span>
                </a>

                <% if (canRequestAdmins) { %>
                <a href="<%= request.getContextPath() %>/user?action=addAdminForm">
                    <i class="fa-solid fa-user-plus"></i>
                    <span>Request New Admin</span>
                </a>
                <% } %>

                <% if (hasFullAccess) { %>
                <a href="<%= request.getContextPath() %>/user?action=listAdminRequests">
                    <i class="fa-solid fa-user-check"></i>
                    <span>Admin Requests</span>
                </a>
                <% } %>
            </nav>
        </div>

        <div class="sidebar-footer">
            <div class="permission-box">\n                <div class="permission-label">Permission</div>
                <strong><%= UserService.permissionLabel(adminPermission) %></strong>
            </div>

            <a class="back-site" href="<%= request.getContextPath() %>/index.jsp">
                <i class="fa-solid fa-globe"></i>
                <span>Open Website</span>
            </a>

            <a class="logout-btn" href="<%= request.getContextPath() %>/user?action=logout">
                <i class="fa-solid fa-right-from-bracket"></i>
                <span>Logout</span>
            </a>
        </div>
    </aside>

    <main class="main-content">
        <section class="topbar">
            <div>
                <p class="eyebrow">Payment Review</p>
                <h1>Pending Payments</h1>
                <p class="subtitle">Check each reference number manually and approve or reject it.</p>
            </div>

            <div class="topbar-badge">
                <i class="fa-solid fa-shield-halved"></i>
                <span><%= UserService.permissionLabel(adminPermission) %></span>
            </div>
        </section>

        <% if ("approved".equals(msg)) { %>
            <div class="alert-box alert-success-box">Payment approved successfully.</div>
        <% } else if ("rejected".equals(msg)) { %>
            <div class="alert-box alert-success-box">Payment rejected. Booking was cancelled and seats were restored.</div>
        <% } else if ("error".equals(msg)) { %>
            <div class="alert-box alert-error-box">Action failed. Please try again.</div>
        <% } %>

        <div class="page-card">
            <div class="page-header">
                <div>
                    <h2>Pending Reference Checks</h2>
                    <p>Only pending customer payment references are shown here.</p>
                </div>
            </div>

            <div class="table-wrap">
                <table class="payment-table">
                    <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Customer ID</th>
                        <th>Event</th>
                        <th>Ticket Type</th>
                        <th>Tickets</th>
                        <th>Total</th>
                        <th>Date</th>
                        <th>Reference Number</th>
                        <th>Status</th>
                        <th>Decision</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Booking b : pendingBookings) { %>
                        <tr>
                            <td class="mono-id"><%= b.getBookingId() %></td>
                            <td><%= b.getCustomerId() %></td>
                            <td><%= b.getEventTitle() %></td>

                            <td>
                                <%
                                    String ttn = b.getTicketTypeName();
                                    if (ttn != null && !ttn.trim().isEmpty()) {
                                %>
                                    <span class="type-pill"><%= ttn %></span>
                                <%  } else { %>
                                    <span style="color:#5a6a9a;">—</span>
                                <%  } %>
                            </td>

                            <td><%= b.getNumberOfTickets() %></td>
                            <td>LKR <%= String.format("%.1f", b.getTotalAmount()) %></td>
                            <td><%= b.getBookingDate() %></td>
                            <td>
                                <div class="reference-box">
                                    <%= (b.getPaymentReference() != null && !b.getPaymentReference().trim().isEmpty())
                                            ? b.getPaymentReference()
                                            : "No reference given" %>
                                </div>
                            </td>
                            <td>
                                <span class="status-pill status-pending">PENDING</span>
                            </td>
                            <td>
                                <div class="action-group">
                                    <form method="post" action="<%= request.getContextPath() %>/booking" style="margin:0;">
                                        <input type="hidden" name="action" value="approvePayment">
                                        <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
                                        <button type="submit" class="action-btn approve-btn">Approve</button>
                                    </form>

                                    <form method="post" action="<%= request.getContextPath() %>/booking" style="margin:0;"
                                          onsubmit="return confirm('Reject this reference and cancel the booking?');">
                                        <input type="hidden" name="action" value="rejectPayment">
                                        <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
                                        <button type="submit" class="action-btn reject-btn">Reject</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <% } %>

                    <% if (pendingBookings.isEmpty()) { %>
                        <tr>
                            <td colspan="10" class="muted" style="padding:24px;">No pending payments found.</td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>
</body>
</html>