<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventhorizon.model.Ticket" %>
<%@ page import="com.eventhorizon.model.Booking" %>
<%@ page import="com.eventhorizon.service.IssueService" %>

<%
    HttpSession currentSession = request.getSession(false);
    String role = currentSession != null ? (String) currentSession.getAttribute("role") : null;

    if (currentSession == null || role == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Boolean paymentPending = (Boolean) request.getAttribute("paymentPending");
    if (paymentPending == null) paymentPending = false;

    Booking booking = (Booking) request.getAttribute("booking");
    List<Ticket> tickets = (List<Ticket>) request.getAttribute("tickets");
    if (tickets == null) tickets = new java.util.ArrayList<>();
%>

<%
    int ehNavIssueCount = 0;
    String ehNavRole = (String) session.getAttribute("role");
    Object ehNavUserIdObj = session.getAttribute("userId");

    boolean ehCustomerLogged = ehNavUserIdObj != null && "CUSTOMER".equals(ehNavRole);
    boolean ehAdminLogged = ehNavUserIdObj != null && "ADMIN".equals(ehNavRole);

    if (ehCustomerLogged) {
        try {
            String numericPart = String.valueOf(ehNavUserIdObj).replaceAll("\\D+", "");
            if (!numericPart.isEmpty()) {
                ehNavIssueCount = new IssueService().countIssuesWithRepliesByUser(Integer.parseInt(numericPart));
            }
        } catch (Exception ignored) { }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Tickets - EventHorizon</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,600..900,40,0..1&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

    <style>
        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --linen: #FAF8F4;
            --linen-deep: #F1EBDD;
            --paper: #FFFFFF;

            --forest: #1E4A3A;
            --forest-dark: #123528;
            --forest-deep: #0E2A20;
            --forest-soft: #E8F1EC;

            --sage: #72887A;
            --clay: #B08D65;

            --text: #18251F;
            --text-soft: #52635A;
            --muted: #6F7F76;

            --border: rgba(30, 74, 58, 0.16);
            --border-strong: rgba(30, 74, 58, 0.30);

            --danger-bg: #FFF0EC;
            --danger-text: #A23A27;

            --success-bg: #E8F6EE;
            --success-text: #176B3B;

            --warning-bg: #FFF7E3;
            --warning-text: #8A5A00;

            --shadow-soft: 0 18px 50px rgba(24, 37, 31, 0.09);
            --shadow-premium: 0 30px 90px rgba(24, 37, 31, 0.16);
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            position: relative;
            font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(30, 74, 58, 0.08), transparent 32%),
                radial-gradient(circle at top right, rgba(176, 141, 101, 0.10), transparent 30%),
                linear-gradient(180deg, #ffffff 0%, var(--linen) 48%, #F7F3EA 100%);
            color: var(--text);
            min-height: 100vh;
            line-height: 1.6;
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
        }

        body::before {
            content: "";
            position: fixed;
            inset: 0;
            z-index: -10;
            pointer-events: none;
            background-image:
                radial-gradient(circle at 1px 1px, rgba(30, 74, 58, 0.10) 1.2px, transparent 1.4px),
                linear-gradient(135deg, rgba(30, 74, 58, 0.035) 25%, transparent 25%),
                linear-gradient(45deg, rgba(176, 141, 101, 0.035) 25%, transparent 25%);
            background-size: 34px 34px, 88px 88px, 88px 88px;
            background-position: 0 0, 0 0, 44px 44px;
            opacity: 0.72;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        /* ================= NAVBAR ================= */

        .eh-navbar {
            position: sticky;
            top: 0;
            z-index: 1000;
            width: 100%;
            background: rgba(250, 248, 244, 0.96);
            border-bottom: 1px solid var(--border);
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
            box-shadow: 0 10px 28px rgba(24, 37, 31, 0.05);
        }

        .eh-navbar-inner {
            width: min(92%, 1240px);
            min-height: 76px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
        }

        .eh-brand {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            color: var(--forest-dark);
            font-weight: 900;
            letter-spacing: 1.8px;
            text-transform: uppercase;
        }

        .eh-brand-mark {
            width: 42px;
            height: 42px;
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
            flex-shrink: 0;
        }

        .eh-brand-mark i {
            color: #ffffff;
        }

        .eh-brand-text {
            font-size: 1.08rem;
        }

        .eh-nav-links {
            list-style: none;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 8px;
            flex-wrap: wrap;
        }

        .eh-nav-links li {
            list-style: none;
        }

        .eh-nav-link,
        .eh-nav-bell,
        .eh-nav-btn,
        .eh-nav-btn-outline {
            min-height: 42px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 15px;
            border-radius: 13px;
            border: 1px solid transparent;
            font-size: 0.88rem;
            font-weight: 800;
            color: var(--text-soft);
            transition: 0.22s ease;
            white-space: nowrap;
        }

        .eh-nav-link:hover,
        .eh-nav-link.active {
            color: var(--forest);
            background: var(--forest-soft);
            border-color: var(--border);
        }

        .eh-nav-bell {
            position: relative;
            width: 44px;
            padding: 0;
            background: rgba(255, 255, 255, 0.86);
            border-color: var(--border);
            box-shadow: 0 8px 18px rgba(24, 37, 31, 0.05);
        }

        .eh-nav-bell:hover {
            color: var(--forest);
            background: var(--forest-soft);
            border-color: var(--border-strong);
        }

        .eh-bell-badge {
            position: absolute;
            top: -7px;
            right: -7px;
            min-width: 19px;
            height: 19px;
            padding: 0 6px;
            border-radius: 999px;
            background: linear-gradient(135deg, #D94B32, #F08A4C);
            color: #ffffff;
            font-size: 0.64rem;
            font-weight: 900;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 18px rgba(217, 75, 50, 0.30);
        }

        .eh-nav-btn {
            color: #ffffff;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
        }

        .eh-nav-btn i {
            color: #ffffff;
        }

        .eh-nav-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 18px 42px rgba(30, 74, 58, 0.30);
        }

        .eh-nav-btn-outline {
            color: var(--forest);
            background: rgba(255, 255, 255, 0.86);
            border-color: var(--border-strong);
        }

        .eh-nav-btn-outline:hover {
            background: var(--forest-soft);
            border-color: rgba(30, 74, 58, 0.34);
        }

        /* ================= PAGE ================= */

        .container {
            width: 92%;
            max-width: 1300px;
            margin: 38px auto 70px;
        }

        .page-header {
            margin-bottom: 26px;
        }

        .page-title {
            color: var(--forest-dark);
            font-size: clamp(2rem, 4vw, 2.6rem);
            font-weight: 900;
            letter-spacing: -0.05em;
            line-height: 1.1;
            margin-bottom: 8px;
        }

        .page-subtitle {
            color: var(--text-soft);
            font-size: 0.98rem;
            font-weight: 650;
        }

        /* ================= NOTICE BOX ================= */

        .notice-box {
            background: rgba(255, 255, 255, 0.97);
            border: 1px solid var(--border);
            border-radius: 26px;
            box-shadow: var(--shadow-premium);
            padding: 34px;
            color: var(--text);
        }

        .notice-box h2 {
            color: var(--forest-dark);
            margin-bottom: 10px;
            font-size: clamp(1.5rem, 3vw, 2rem);
            font-weight: 900;
            letter-spacing: -0.04em;
        }

        .notice-box p {
            color: var(--text-soft);
            line-height: 1.7;
            margin-bottom: 12px;
            font-weight: 650;
        }

        .notice-box strong {
            color: var(--forest-dark);
            font-weight: 900;
        }

        /* ================= BUTTONS ================= */

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-top: 15px;
            text-decoration: none;
            border: none;
            border-radius: 14px;
            padding: 13px 20px;
            font-weight: 900;
            font-size: 0.92rem;
            cursor: pointer;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            color: #ffffff;
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
            transition: 0.22s ease;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 18px 42px rgba(30, 74, 58, 0.30);
        }

        /* ================= TICKET GRID ================= */

        .ticket-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(360px, 1fr));
            gap: 24px;
        }

        .ticket-card {
            position: relative;
            overflow: hidden;
            background: rgba(255, 255, 255, 0.97);
            border: 1px solid var(--border);
            border-radius: 26px;
            box-shadow: var(--shadow-soft);
            padding: 24px;
            color: var(--text);
        }

        .ticket-card::before {
            content: "";
            position: absolute;
            inset: 0 0 auto 0;
            height: 6px;
            background: linear-gradient(90deg, var(--forest), var(--sage));
        }

        .ticket-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 14px;
            padding: 7px 13px;
            border-radius: 999px;
            background: var(--forest-soft);
            color: var(--forest-dark);
            border: 1px solid var(--border-strong);
            font-size: 0.72rem;
            font-weight: 900;
            letter-spacing: 0.8px;
            text-transform: uppercase;
        }

        .ticket-title {
            color: var(--forest-dark);
            font-size: 1.45rem;
            font-weight: 900;
            margin-bottom: 18px;
            letter-spacing: -0.03em;
            line-height: 1.2;
        }

        .row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 18px;
            padding: 11px 0;
            border-bottom: 1px solid rgba(30, 74, 58, 0.11);
        }

        .row:last-of-type {
            border-bottom: none;
        }

        .label {
            color: var(--text-soft);
            font-size: 0.9rem;
            font-weight: 850;
            min-width: 110px;
        }

        .value {
            color: var(--text);
            font-size: 0.9rem;
            font-weight: 900;
            text-align: right;
            word-break: break-word;
        }

        .type-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 13px;
            border-radius: 999px;
            font-size: 0.72rem;
            font-weight: 900;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            background: var(--forest-soft);
            color: var(--forest-dark);
            border: 1px solid var(--border-strong);
        }

        .dash-text {
            color: var(--muted);
            font-weight: 900;
        }

        .used {
            color: #A23A27;
            background: var(--danger-bg);
            border: 1px solid rgba(162, 58, 39, 0.18);
            padding: 5px 10px;
            border-radius: 999px;
            font-weight: 900;
        }

        .unused {
            color: var(--success-text);
            background: var(--success-bg);
            border: 1px solid rgba(23, 107, 59, 0.18);
            padding: 5px 10px;
            border-radius: 999px;
            font-weight: 900;
        }

        /* ================= QR ================= */

        .qr-box {
            margin-top: 22px;
            background:
                radial-gradient(circle at top left, rgba(30, 74, 58, 0.07), transparent 45%),
                #FAF8F4;
            border: 1px solid rgba(30, 74, 58, 0.14);
            border-radius: 20px;
            padding: 20px;
            text-align: center;
        }

        .qr-box img {
            width: 260px;
            max-width: 100%;
            height: auto;
            border-radius: 14px;
            background: #ffffff;
            border: 1px solid rgba(30, 74, 58, 0.16);
            padding: 10px;
            box-shadow: 0 10px 28px rgba(24, 37, 31, 0.08);
        }

        .qr-note {
            margin-top: 12px;
            color: var(--forest-dark);
            font-size: 0.82rem;
            font-weight: 850;
            word-break: break-word;
        }

        /* ================= RESPONSIVE ================= */

        @media (max-width: 768px) {
            .eh-navbar-inner {
                min-height: auto;
                padding: 14px 0;
                flex-direction: column;
                justify-content: center;
            }

            .eh-brand {
                justify-content: center;
            }

            .eh-nav-links {
                justify-content: center;
            }

            .container {
                width: 94%;
                margin-top: 28px;
            }

            .notice-box {
                padding: 26px;
            }
        }

        @media (max-width: 520px) {
            .eh-nav-link span,
            .eh-nav-btn span,
            .eh-nav-btn-outline span {
                display: none;
            }

            .eh-nav-link,
            .eh-nav-btn,
            .eh-nav-btn-outline {
                width: 42px;
                padding: 0;
            }

            .ticket-grid {
                grid-template-columns: 1fr;
            }

            .ticket-card {
                padding: 22px;
            }

            .row {
                flex-direction: column;
                gap: 4px;
            }

            .value {
                text-align: left;
            }
        }
    </style>
</head>

<body>

<nav class="eh-navbar">
    <div class="eh-navbar-inner">
        <a href="${pageContext.request.contextPath}/index.jsp" class="eh-brand">
            <span class="eh-brand-mark">
                <i class="fa-solid fa-leaf"></i>
            </span>
            <span class="eh-brand-text">EVENTHORIZON</span>
        </a>

        <ul class="eh-nav-links">
            <li>
                <a href="${pageContext.request.contextPath}/index.jsp" class="eh-nav-link">
                    <i class="fa-solid fa-house"></i>
                    <span>Home</span>
                </a>
            </li>

            <li>
                <a href="${pageContext.request.contextPath}/event?action=list" class="eh-nav-link">
                    <i class="fa-solid fa-calendar-days"></i>
                    <span>Events</span>
                </a>
            </li>

            <% if (ehCustomerLogged) { %>
                <li>
                    <a href="${pageContext.request.contextPath}/booking?action=myBookings" class="eh-nav-link active">
                        <i class="fa-solid fa-ticket"></i>
                        <span>My Bookings</span>
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/IssueServlet?action=myIssues" class="eh-nav-bell" title="Issue notifications">
                        <i class="fa-regular fa-bell"></i>

                        <% if (ehNavIssueCount > 0) { %>
                            <span class="eh-bell-badge"><%= ehNavIssueCount %></span>
                        <% } %>
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/profile.jsp" class="eh-nav-link">
                        <i class="fa-regular fa-user"></i>
                        <span>Profile</span>
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/user?action=logout" class="eh-nav-btn">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        <span>Logout</span>
                    </a>
                </li>
            <% } else if (ehAdminLogged) { %>
                <li>
                    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="eh-nav-link">
                        <i class="fa-solid fa-gauge-high"></i>
                        <span>Dashboard</span>
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/profile.jsp" class="eh-nav-link">
                        <i class="fa-regular fa-user"></i>
                        <span>Profile</span>
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/user?action=logout" class="eh-nav-btn">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        <span>Logout</span>
                    </a>
                </li>
            <% } else { %>
                <li>
                    <a href="${pageContext.request.contextPath}/login.jsp" class="eh-nav-link">
                        <i class="fa-solid fa-right-to-bracket"></i>
                        <span>Login</span>
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/register.jsp" class="eh-nav-btn-outline">
                        <i class="fa-solid fa-user-plus"></i>
                        <span>Register</span>
                    </a>
                </li>
            <% } %>
        </ul>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <div class="page-title">My Tickets</div>
        <div class="page-subtitle">
            View your approved digital tickets and scan-ready secure QR codes.
        </div>
    </div>

    <% if (paymentPending) { %>

        <div class="notice-box">
            <h2>Tickets are not available yet</h2>

            <p>Your payment is still waiting for admin approval.</p>

            <% if (booking != null) { %>
                <p><strong>Booking ID:</strong> <%= booking.getBookingId() %></p>
                <p><strong>Event:</strong> <%= booking.getEventTitle() %></p>
                <p><strong>Payment Status:</strong> <%= booking.getPaymentStatus() %></p>
            <% } %>

            <a class="btn" href="<%= request.getContextPath() %>/booking?action=myBookings">
                <i class="fa-solid fa-arrow-left"></i>
                Back to My Bookings
            </a>
        </div>

    <% } else if (tickets.isEmpty()) { %>

        <div class="notice-box">
            <h2>No tickets found</h2>

            <p>No generated tickets are linked to this booking yet.</p>

            <a class="btn" href="<%= request.getContextPath() %>/booking?action=myBookings">
                <i class="fa-solid fa-arrow-left"></i>
                Back to My Bookings
            </a>
        </div>

    <% } else { %>

        <div class="ticket-grid">
            <%
                int i = 1;
                for (Ticket t : tickets) {
            %>

                <div class="ticket-card">
                    <div class="ticket-badge">Ticket <%= i++ %></div>

                    <div class="ticket-title">
                        <%= booking != null ? booking.getEventTitle() : "Event Ticket" %>
                    </div>

                    <div class="row">
                        <div class="label">Ticket ID</div>
                        <div class="value"><%= t.getTicketId() %></div>
                    </div>

                    <div class="row">
                        <div class="label">Booking ID</div>
                        <div class="value"><%= t.getBookingId() %></div>
                    </div>

                    <div class="row">
                        <div class="label">Ticket Type</div>
                        <div class="value">
                            <%
                                String ttn = t.getTicketTypeName();
                                if (ttn != null && !ttn.trim().isEmpty()) {
                            %>
                                <span class="type-pill"><%= ttn %></span>
                            <% } else { %>
                                <span class="dash-text">—</span>
                            <% } %>
                        </div>
                    </div>

                    <div class="row">
                        <div class="label">Event ID</div>
                        <div class="value"><%= t.getEventId() %></div>
                    </div>

                    <div class="row">
                        <div class="label">Customer ID</div>
                        <div class="value"><%= t.getCustomerId() %></div>
                    </div>

                    <div class="row">
                        <div class="label">Issued At</div>
                        <div class="value"><%= t.getCreatedAt() == null ? "-" : t.getCreatedAt() %></div>
                    </div>

                    <div class="row">
                        <div class="label">Status</div>
                        <div class="value">
                            <span class="<%= t.isUsed() ? "used" : "unused" %>">
                                <%= t.isUsed() ? "USED" : "APPROVED" %>
                            </span>
                        </div>
                    </div>

                    <div class="qr-box">
                        <img src="<%= request.getContextPath() %>/ticket?action=qr&token=<%= java.net.URLEncoder.encode(t.getQrToken(), "UTF-8") %>&v=<%= java.net.URLEncoder.encode(t.getTicketId(), "UTF-8") %>"
                             alt="QR Code">

                        <div class="qr-note">Secure ticket token stored in system</div>
                    </div>
                </div>

            <% } %>
        </div>

    <% } %>
</div>

</body>
</html>