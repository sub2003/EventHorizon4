<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.eventhorizon.model.Admin" %>
<%@ page import="com.eventhorizon.service.UserService" %>
<%
    HttpSession currentSession = request.getSession(false);
    String role = currentSession != null ? (String) currentSession.getAttribute("role") : null;
    String userName = currentSession != null ? (String) currentSession.getAttribute("userName") : null;
    String adminPermission = currentSession != null ? (String) currentSession.getAttribute("adminPermission") : null;

    if (currentSession == null || role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }

    if (adminPermission == null || adminPermission.trim().isEmpty()) {
        adminPermission = Admin.CORE_ADMIN;
    }

    boolean canManageEvents = UserService.hasEventAccess(adminPermission);
    boolean canManageBookings = UserService.hasBookingAccess(adminPermission);
    boolean hasFullAccess = UserService.hasFullAccess(adminPermission);
    boolean canRequestAdmins = UserService.canRequestAdmin(adminPermission);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - EventHorizon</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,600..900,40,0..1&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css?v=20260501">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin.css?v=20260501">
</head>
<body>

<div class="admin-shell">

    <aside class="sidebar">
        <div class="sidebar-top">
            <div class="brand">
                <div class="brand-icon">
                    <i class="fa-solid fa-leaf"></i>
                </div>
                <div class="brand-text">
                    <h2>EVENTHORIZON</h2>
                    <p>Admin Workspace</p>
                </div>
            </div>

            <nav class="nav-links">
                <a class="active" href="<%= request.getContextPath() %>/admin/dashboard.jsp">
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

                <a href="<%= request.getContextPath() %>/booking?action=pendingPayments">
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
            <div class="permission-box">
                <div class="permission-label">Permission</div>
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
                <p class="eyebrow">Administration</p>
                <h1>Dashboard</h1>
                <p class="subtitle">Welcome back, <strong><%= userName != null ? userName : "Admin" %></strong></p>
            </div>

            <div class="topbar-badge">
                <i class="fa-solid fa-shield-halved"></i>
                <span><%= UserService.permissionLabel(adminPermission) %></span>
            </div>
        </section>

        <% if ("noEventPermission".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">You do not have permission to manage events.</div>
        <% } %>

        <% if ("noBookingPermission".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">You do not have permission to manage bookings.</div>
        <% } %>

        <% if ("noCoreAccess".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">Only an authorized admin can access that section.</div>
        <% } %>

        <section class="hero-panel admin-hero-panel">
            <div class="hero-text">
                <p class="eyebrow">Admin Control Center</p>
                <h2>Clear access overview for your admin account</h2>
                <p>
                    Your dashboard shows exactly which platform facilities are available for your current permission level.
                    Use the action buttons only when needed; the cards below explain your access clearly.
                </p>
            </div>

            <div class="hero-actions">
                <% if (canManageEvents) { %>
                <a href="<%= request.getContextPath() %>/event?action=adminList" class="primary-btn">
                    <i class="fa-solid fa-calendar-plus"></i>
                    <span>Manage Events</span>
                </a>
                <% } %>

                <% if (canManageBookings) { %>
                <a href="<%= request.getContextPath() %>/booking?action=allBookings" class="secondary-btn">
                    <i class="fa-solid fa-list-check"></i>
                    <span>Review Bookings</span>
                </a>

                <a href="<%= request.getContextPath() %>/booking?action=pendingPayments" class="secondary-btn">
                    <i class="fa-solid fa-money-check-dollar"></i>
                    <span>Approve Payments</span>
                </a>
                <% } %>
            </div>
        </section>

        <section class="facility-section">
            <div class="facility-header">
                <div>
                    <p class="eyebrow">Available Facilities</p>
                    <h2>Admin facilities and responsibilities</h2>
                    <p>Each card explains what the facility allows you to do for your current permission level.</p>
                </div>
            </div>

            <div class="facility-grid">
                <% if (hasFullAccess) { %>
                <article class="facility-card is-available">
                    <div class="facility-icon"><i class="fa-solid fa-users"></i></div>
                    <div class="facility-content">
                        <div class="facility-topline">
                            <h3>User Control</h3>
                            <span class="facility-status available">Available</span>
                        </div>
                        <p>Manage customer accounts and admin accounts from one place.</p>
                        <ul class="facility-list">
                            <li>View registered users</li>
                            <li>Update user information</li>
                            <li>Remove accounts when necessary</li>
                        </ul>
                    </div>
                </article>
                <% } %>

                <% if (canManageEvents) { %>
                <article class="facility-card is-available">
                    <div class="facility-icon"><i class="fa-solid fa-calendar-days"></i></div>
                    <div class="facility-content">
                        <div class="facility-topline">
                            <h3>Event Management</h3>
                            <span class="facility-status available">Available</span>
                        </div>
                        <p>Create, edit, cancel, and organize events shown to customers.</p>
                        <ul class="facility-list">
                            <li>Add event details and images</li>
                            <li>Manage ticket types and seats</li>
                            <li>Update event status</li>
                        </ul>
                    </div>
                </article>
                <% } %>

                <% if (canManageBookings) { %>
                <article class="facility-card is-available">
                    <div class="facility-icon"><i class="fa-solid fa-ticket"></i></div>
                    <div class="facility-content">
                        <div class="facility-topline">
                            <h3>Booking Control</h3>
                            <span class="facility-status available">Available</span>
                        </div>
                        <p>Track customer bookings, booking status, and ticket generation flow.</p>
                        <ul class="facility-list">
                            <li>Review all customer bookings</li>
                            <li>Check booking status</li>
                            <li>Follow approved ticket records</li>
                        </ul>
                    </div>
                </article>

                <article class="facility-card is-available">
                    <div class="facility-icon"><i class="fa-solid fa-money-check-dollar"></i></div>
                    <div class="facility-content">
                        <div class="facility-topline">
                            <h3>Payment Review</h3>
                            <span class="facility-status available">Available</span>
                        </div>
                        <p>Verify payment references submitted by customers before ticket approval.</p>
                        <ul class="facility-list">
                            <li>Check bank reference numbers</li>
                            <li>Approve valid payments</li>
                            <li>Reject incorrect references</li>
                        </ul>
                    </div>
                </article>
                <% } %>

                <article class="facility-card is-available">
                    <div class="facility-icon"><i class="fa-solid fa-envelope-open-text"></i></div>
                    <div class="facility-content">
                        <div class="facility-topline">
                            <h3>Issue Requests</h3>
                            <span class="facility-status available">Available</span>
                        </div>
                        <p>Read customer support issues and respond through the admin issue center.</p>
                        <ul class="facility-list">
                            <li>View customer issue messages</li>
                            <li>Reply to support requests</li>
                            <li>Track issue status</li>
                        </ul>
                    </div>
                </article>

                <% if (canRequestAdmins && !hasFullAccess) { %>
                <article class="facility-card is-available">
                    <div class="facility-icon"><i class="fa-solid fa-user-plus"></i></div>
                    <div class="facility-content">
                        <div class="facility-topline">
                            <h3>Request New Admin</h3>
                            <span class="facility-status available">Available</span>
                        </div>
                        <p>Create a request for a new admin account according to your permission level.</p>
                        <ul class="facility-list">
                            <li>Submit new admin requests</li>
                            <li>Send requested admin details</li>
                            <li>Wait for core admin approval</li>
                        </ul>
                    </div>
                </article>
                <% } %>

                <% if (hasFullAccess) { %>
                <article class="facility-card is-available">
                    <div class="facility-icon"><i class="fa-solid fa-user-check"></i></div>
                    <div class="facility-content">
                        <div class="facility-topline">
                            <h3>Admin Requests</h3>
                            <span class="facility-status available">Available</span>
                        </div>
                        <p>Review requests for new admin access and control admin permissions.</p>
                        <ul class="facility-list">
                            <li>Approve admin requests</li>
                            <li>Reject invalid requests</li>
                            <li>Control admin access level</li>
                        </ul>
                    </div>
                </article>
                <% } %>
            </div>
        </section>

        <section class="access-summary-panel">
            <div class="hero-text">
                <p class="eyebrow">Current Access Summary</p>
                <h2>Your active modules</h2>
                <p>These modules are enabled for your current admin permission.</p>
            </div>

            <div class="access-chip-wrap">
                <% if (canManageEvents) { %>
                    <span class="access-chip"><i class="fa-solid fa-check"></i> Events</span>
                <% } %>

                <% if (canManageBookings) { %>
                    <span class="access-chip"><i class="fa-solid fa-check"></i> Bookings</span>
                    <span class="access-chip"><i class="fa-solid fa-check"></i> Payment Approval</span>
                <% } %>

                <span class="access-chip"><i class="fa-solid fa-check"></i> Issue Requests</span>

                <% if (hasFullAccess) { %>
                    <span class="access-chip"><i class="fa-solid fa-check"></i> Users</span>
                    <span class="access-chip"><i class="fa-solid fa-check"></i> Admin Requests</span>
                <% } %>

                <% if (canRequestAdmins && !hasFullAccess) { %>
                    <span class="access-chip"><i class="fa-solid fa-check"></i> Request New Admin</span>
                <% } %>
            </div>
        </section>
    </main>
</div>

<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
