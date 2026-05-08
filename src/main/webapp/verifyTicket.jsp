<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.eventhorizon.model.Ticket" %>
<%@ page import="com.eventhorizon.model.Booking" %>
<%@ page import="com.eventhorizon.service.IssueService" %>

<%
    Ticket ticket = (Ticket) request.getAttribute("ticket");
    Booking booking = (Booking) request.getAttribute("booking");
    Boolean approved = (Boolean) request.getAttribute("approved");
    String scannedToken = (String) request.getAttribute("scannedToken");

    if (approved == null) {
        approved = false;
    }
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
    <title>Ticket Verification - EventHorizon</title>

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
            --forest-soft: #E8F1EC;

            --sage: #72887A;
            --clay: #B08D65;

            --text: #18251F;
            --text-soft: #52635A;
            --muted: #6F7F76;

            --border: rgba(30, 74, 58, 0.16);
            --border-strong: rgba(30, 74, 58, 0.30);

            --success-bg: #E8F6EE;
            --success-text: #176B3B;

            --danger-bg: #FFF0EC;
            --danger-text: #A23A27;

            --warning-bg: #FFF7E3;
            --warning-text: #76520F;

            --shadow-soft: 0 18px 50px rgba(24, 37, 31, 0.09);
            --shadow-premium: 0 30px 90px rgba(24, 37, 31, 0.15);
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
            font-weight: 850;
            color: var(--text-soft);
            transition: 0.22s ease;
            white-space: nowrap;
        }

        .eh-nav-link:hover,
        .eh-nav-link.active {
            color: var(--forest-dark);
            background: #ffffff;
            border-color: var(--border-strong);
            box-shadow: 0 8px 18px rgba(24, 37, 31, 0.06);
        }

        .eh-nav-bell {
            position: relative;
            width: 44px;
            padding: 0;
            background: #ffffff;
            border-color: var(--border);
            box-shadow: 0 8px 18px rgba(24, 37, 31, 0.05);
        }

        .eh-nav-bell:hover {
            color: var(--forest-dark);
            background: #ffffff;
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
            color: var(--forest-dark);
            background: #ffffff;
            border-color: var(--border-strong);
        }

        .eh-nav-btn-outline:hover {
            background: #ffffff;
            border-color: rgba(30, 74, 58, 0.48);
        }

        /* ================= VERIFICATION PAGE ================= */

        .container {
            width: 92%;
            max-width: 920px;
            margin: 42px auto 70px;
        }

        .verification-card {
            background: #ffffff;
            border: 2px solid rgba(30, 74, 58, 0.22);
            border-radius: 28px;
            padding: 34px;
            box-shadow: var(--shadow-premium);
            color: var(--text);
            overflow: hidden;
            position: relative;
        }

        .verification-card::before {
            content: "";
            position: absolute;
            inset: 0 0 auto 0;
            height: 6px;
            background: linear-gradient(90deg, var(--forest), var(--sage));
        }

        .title {
            color: var(--forest-dark);
            font-size: clamp(2rem, 4vw, 2.7rem);
            font-weight: 900;
            margin-bottom: 24px;
            letter-spacing: -0.05em;
            line-height: 1.1;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .title i {
            color: var(--forest);
        }

        .status-box {
            padding: 22px;
            border-radius: 20px;
            margin-bottom: 26px;
            font-size: clamp(1.35rem, 3vw, 2rem);
            font-weight: 900;
            text-align: center;
            letter-spacing: 0.8px;
            border: 2px solid transparent;
        }

        .approved {
            background: var(--success-bg);
            border-color: rgba(23, 107, 59, 0.24);
            color: var(--success-text);
        }

        .not-approved {
            background: var(--danger-bg);
            border-color: rgba(162, 58, 39, 0.24);
            color: var(--danger-text);
        }

        .details-box {
            background: #FAF8F4;
            border: 1px solid rgba(30, 74, 58, 0.14);
            border-radius: 20px;
            padding: 10px 20px;
        }

        .row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 20px;
            padding: 15px 0;
            border-bottom: 1px solid rgba(30, 74, 58, 0.14);
        }

        .row:last-child {
            border-bottom: none;
        }

        .label {
            color: var(--forest-dark);
            font-weight: 900;
            font-size: 0.92rem;
            min-width: 160px;
        }

        .value {
            color: var(--text);
            font-weight: 900;
            font-size: 0.94rem;
            text-align: right;
            word-break: break-word;
            overflow-wrap: anywhere;
        }

        .type-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 13px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 900;
            letter-spacing: 0.45px;
            text-transform: uppercase;
            background: #ffffff;
            color: var(--forest-dark);
            border: 1px solid rgba(30, 74, 58, 0.34);
            box-shadow: none;
        }

        .dash-text {
            color: var(--muted);
            font-weight: 900;
        }

        .note {
            margin-top: 24px;
            padding: 16px 18px;
            border-radius: 16px;
            color: var(--forest-dark);
            background: var(--forest-soft);
            border: 1px solid rgba(30, 74, 58, 0.22);
            line-height: 1.7;
            font-weight: 750;
        }

        .note.danger-note {
            background: var(--danger-bg);
            color: var(--danger-text);
            border-color: rgba(162, 58, 39, 0.22);
        }

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

            .verification-card {
                padding: 26px;
            }

            .row {
                flex-direction: column;
                gap: 4px;
            }

            .value {
                text-align: left;
            }

            .label {
                min-width: auto;
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

            .title {
                font-size: 2rem;
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
                    <a href="${pageContext.request.contextPath}/booking?action=myBookings" class="eh-nav-link">
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
    <div class="verification-card">
        <div class="title">
            <i class="fa-solid fa-qrcode"></i>
            Ticket Verification
        </div>

        <% if (approved && ticket != null && booking != null) { %>

            <div class="status-box approved">
                <i class="fa-solid fa-circle-check"></i>
                APPROVED
            </div>

            <div class="details-box">
                <div class="row">
                    <div class="label">Ticket ID</div>
                    <div class="value"><%= ticket.getTicketId() %></div>
                </div>

                <div class="row">
                    <div class="label">Booking ID</div>
                    <div class="value"><%= ticket.getBookingId() %></div>
                </div>

                <div class="row">
                    <div class="label">Event ID</div>
                    <div class="value"><%= ticket.getEventId() %></div>
                </div>

                <div class="row">
                    <div class="label">Customer ID</div>
                    <div class="value"><%= ticket.getCustomerId() %></div>
                </div>

                <div class="row">
                    <div class="label">Ticket Type</div>
                    <div class="value">
                        <%
                            String ttn = ticket.getTicketTypeName();

                            if (ttn != null && !ttn.trim().isEmpty()) {
                        %>
                            <span class="type-pill"><%= ttn %></span>
                        <% } else { %>
                            <span class="dash-text">—</span>
                        <% } %>
                    </div>
                </div>

                <div class="row">
                    <div class="label">Booking Payment</div>
                    <div class="value"><%= booking.getPaymentStatus() %></div>
                </div>

                <div class="row">
                    <div class="label">Booking Status</div>
                    <div class="value"><%= booking.getStatus() %></div>
                </div>

                <div class="row">
                    <div class="label">Scanned Token</div>
                    <div class="value"><%= scannedToken == null ? "-" : scannedToken %></div>
                </div>
            </div>

            <div class="note">
                <i class="fa-solid fa-shield-halved"></i>
                This is a valid ticket issued by the EventHorizon system.
            </div>

        <% } else { %>

            <div class="status-box not-approved">
                <i class="fa-solid fa-circle-xmark"></i>
                NOT APPROVED
            </div>

            <div class="details-box">
                <div class="row">
                    <div class="label">Scanned Token</div>
                    <div class="value"><%= scannedToken == null ? "-" : scannedToken %></div>
                </div>
            </div>

            <div class="note danger-note">
                <i class="fa-solid fa-triangle-exclamation"></i>
                This QR code is not a valid approved EventHorizon ticket.
                It may be fake, expired, or not found in the system.
            </div>

        <% } %>
    </div>
</div>

</body>
</html>