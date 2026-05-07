<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventhorizon.model.Booking" %>
<%@ page import="com.eventhorizon.service.IssueService" %>

<%
    HttpSession currentSession = request.getSession(false);
    String role = currentSession != null ? (String) currentSession.getAttribute("role") : null;
    String userName = currentSession != null ? (String) currentSession.getAttribute("userName") : null;

    if (currentSession == null || role == null || !"CUSTOMER".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    if (bookings == null) {
        bookings = new java.util.ArrayList<>();
    }

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");

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
    <title>My Bookings - EventHorizon</title>

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
            --border-strong: rgba(30, 74, 58, 0.34);

            --success-bg: #E8F6EE;
            --success-text: #176B3B;

            --warning-bg: #FFF7E3;
            --warning-text: #76520F;

            --danger-bg: #FFF0EC;
            --danger-text: #A23A27;

            --neutral-bg: #F1F3F1;
            --neutral-text: #65726C;

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
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
            line-height: 1.6;
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
            color: var(--forest);
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

        /* ================= PAGE ================= */

        .container {
            width: 92%;
            max-width: 1250px;
            margin: 38px auto 70px;
        }

        .page-header {
            margin-bottom: 26px;
        }

        .page-title {
            font-size: clamp(2rem, 4vw, 2.6rem);
            font-weight: 900;
            color: var(--forest-dark);
            margin-bottom: 8px;
            letter-spacing: -0.05em;
            line-height: 1.1;
        }

        .page-subtitle {
            color: var(--text-soft);
            font-size: 0.98rem;
            font-weight: 650;
        }

        /* ================= ALERTS ================= */

        .alert {
            padding: 14px 18px;
            border-radius: 14px;
            margin-bottom: 22px;
            font-weight: 800;
            border: 1px solid transparent;
        }

        .alert.success {
            background: var(--success-bg);
            border-color: rgba(23, 107, 59, 0.24);
            color: var(--success-text);
        }

        .alert.error {
            background: var(--danger-bg);
            border-color: rgba(162, 58, 39, 0.24);
            color: var(--danger-text);
        }

        /* ================= BOOKINGS ================= */

        .booking-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(340px, 1fr));
            gap: 24px;
        }

        .booking-card {
            position: relative;
            overflow: hidden;
            background: #ffffff;
            border: 2px solid rgba(30, 74, 58, 0.24);
            border-radius: 24px;
            padding: 24px;
            box-shadow: 0 18px 45px rgba(24, 37, 31, 0.10);
            transition: 0.22s ease;
            color: var(--text);
        }

        .booking-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: #ffffff;
            border-bottom: 1px solid rgba(30, 74, 58, 0.18);
        }

        .booking-card:hover {
            transform: translateY(-2px);
            border-color: rgba(30, 74, 58, 0.42);
            box-shadow: 0 22px 55px rgba(24, 37, 31, 0.14);
        }

        .booking-title {
            font-size: 1.45rem;
            font-weight: 900;
            color: var(--forest-dark);
            margin-bottom: 18px;
            padding-top: 4px;
            letter-spacing: -0.03em;
            line-height: 1.25;
        }

        .booking-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            padding: 11px 0;
            border-bottom: 1px solid rgba(30, 74, 58, 0.13);
        }

        .booking-row:last-child {
            border-bottom: none;
        }

        .booking-label {
            color: var(--text-soft);
            font-weight: 850;
            font-size: 0.9rem;
            min-width: 125px;
        }

        .booking-value {
            color: var(--text);
            font-weight: 900;
            font-size: 0.9rem;
            text-align: right;
            word-break: break-word;
            max-width: 58%;
        }

        /* ================= BADGES ================= */

        .status-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 7px 12px;
            border-radius: 999px;
            font-size: 0.74rem;
            font-weight: 900;
            letter-spacing: 0.45px;
            text-transform: uppercase;
            border: 1px solid transparent;
        }

        .status-confirmed,
        .payment-approved {
            background: var(--success-bg);
            color: var(--success-text);
            border-color: rgba(23, 107, 59, 0.22);
        }

        .status-cancelled {
            background: var(--neutral-bg);
            color: var(--neutral-text);
            border-color: rgba(101, 114, 108, 0.22);
        }

        .payment-pending {
            background: var(--warning-bg);
            color: var(--warning-text);
            border-color: rgba(138, 90, 0, 0.22);
        }

        .payment-rejected {
            background: var(--danger-bg);
            color: #9C3127;
            border-color: rgba(156, 49, 39, 0.22);
        }

        .ticket-type-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 0.74rem;
            font-weight: 900;
            letter-spacing: 0.45px;
            text-transform: uppercase;
            background: #ffffff;
            color: var(--forest-dark);
            border: 1px solid rgba(30, 74, 58, 0.32);
            box-shadow: none;
        }

        .dash-text {
            color: var(--muted);
            font-weight: 900;
        }

        /* ================= BUTTONS ================= */

        .actions {
            margin-top: 20px;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 16px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 900;
            font-size: 0.88rem;
            cursor: pointer;
            transition: 0.22s ease;
            min-height: 44px;
        }

        .btn:hover {
            transform: translateY(-1px);
        }

        .btn-primary {
            background: #ffffff;
            color: var(--forest-dark);
            border: 2px solid rgba(30, 74, 58, 0.32);
            box-shadow: none;
        }

        .btn-primary:hover {
            background: var(--forest-soft);
            border-color: rgba(30, 74, 58, 0.48);
            box-shadow: 0 12px 28px rgba(30, 74, 58, 0.12);
        }

        .btn-secondary {
            background: #ffffff;
            color: var(--forest-dark);
            border: 2px solid rgba(30, 74, 58, 0.24);
            box-shadow: none;
        }

        .btn-secondary:hover {
            background: var(--forest-soft);
            border-color: rgba(30, 74, 58, 0.42);
        }

        .btn-danger {
            background: #ffffff;
            color: var(--danger-text);
            border: 2px solid rgba(162, 58, 39, 0.28);
            box-shadow: none;
        }

        .btn-danger:hover {
            background: var(--danger-bg);
            border-color: rgba(162, 58, 39, 0.45);
        }

        button.btn {
            font-family: inherit;
        }

        /* ================= EMPTY BOX ================= */

        .empty-box {
            text-align: center;
            padding: 55px 24px;
            background: #ffffff;
            border: 2px solid rgba(30, 74, 58, 0.24);
            border-radius: 24px;
            box-shadow: 0 18px 45px rgba(24, 37, 31, 0.10);
        }

        .empty-box h2 {
            font-size: 2rem;
            margin-bottom: 10px;
            color: var(--forest-dark);
            font-weight: 900;
            letter-spacing: -0.04em;
        }

        .empty-box p {
            color: var(--text-soft);
            margin-bottom: 22px;
            font-weight: 650;
        }

        /* ================= RESPONSIVE ================= */

        @media (max-width: 900px) {
            .eh-navbar-inner {
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: auto;
                padding: 14px 0;
            }

            .eh-nav-links {
                justify-content: center;
            }

            .eh-brand {
                justify-content: center;
            }
        }

        @media (max-width: 768px) {
            .container {
                width: 94%;
                margin-top: 30px;
            }

            .page-title {
                font-size: 2rem;
            }

            .booking-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 4px;
            }

            .booking-value {
                max-width: 100%;
                text-align: left;
            }

            .actions {
                flex-direction: column;
            }

            .btn,
            .actions form,
            .actions form button {
                width: 100%;
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

            .booking-grid {
                grid-template-columns: 1fr;
            }

            .booking-card {
                padding: 22px;
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
        <div class="page-title">My Bookings</div>
        <div class="page-subtitle">
            Welcome<%= userName != null ? ", " + userName : "" %>. Here you can track payments and view your approved tickets.
        </div>
    </div>

    <% if ("paymentPending".equals(msg)) { %>
        <div class="alert success">
            Payment submitted successfully. Your booking is now waiting for admin approval.
        </div>
    <% } %>

    <% if ("cancelled".equals(msg)) { %>
        <div class="alert success">
            Booking cancelled successfully.
        </div>
    <% } %>

    <% if ("error".equals(msg) || error != null) { %>
        <div class="alert error">
            Something went wrong. Please try again.
        </div>
    <% } %>

    <% if (bookings.isEmpty()) { %>

        <div class="empty-box">
            <h2>No bookings yet</h2>
            <p>You have not booked any events yet.</p>

            <a class="btn btn-primary" href="<%= request.getContextPath() %>/event?action=list">
                Browse Events
            </a>
        </div>

    <% } else { %>

        <div class="booking-grid">
            <%
                for (Booking b : bookings) {
                    String bookingStatusClass = "status-confirmed";
                    if ("CANCELLED".equalsIgnoreCase(b.getStatus())) {
                        bookingStatusClass = "status-cancelled";
                    }

                    String paymentStatusClass = "payment-pending";
                    if ("APPROVED".equalsIgnoreCase(b.getPaymentStatus())) {
                        paymentStatusClass = "payment-approved";
                    } else if ("REJECTED".equalsIgnoreCase(b.getPaymentStatus())) {
                        paymentStatusClass = "payment-rejected";
                    }
            %>

            <div class="booking-card">
                <div class="booking-title"><%= b.getEventTitle() %></div>

                <div class="booking-row">
                    <div class="booking-label">Booking ID</div>
                    <div class="booking-value"><%= b.getBookingId() %></div>
                </div>

                <div class="booking-row">
                    <div class="booking-label">Event ID</div>
                    <div class="booking-value"><%= b.getEventId() %></div>
                </div>

                <div class="booking-row">
                    <div class="booking-label">Ticket Type</div>
                    <div class="booking-value">
                        <%
                            String ttn = b.getTicketTypeName();

                            if (ttn != null && !ttn.trim().isEmpty()) {
                        %>
                            <span class="ticket-type-pill"><%= ttn %></span>
                        <% } else { %>
                            <span class="dash-text">—</span>
                        <% } %>
                    </div>
                </div>

                <div class="booking-row">
                    <div class="booking-label">Number of Tickets</div>
                    <div class="booking-value"><%= b.getNumberOfTickets() %></div>
                </div>

                <div class="booking-row">
                    <div class="booking-label">Total Amount</div>
                    <div class="booking-value">LKR <%= String.format("%.2f", b.getTotalAmount()) %></div>
                </div>

                <div class="booking-row">
                    <div class="booking-label">Booking Date</div>
                    <div class="booking-value"><%= b.getBookingDate() %></div>
                </div>

                <div class="booking-row">
                    <div class="booking-label">Booking Status</div>
                    <div class="booking-value">
                        <span class="status-pill <%= bookingStatusClass %>"><%= b.getStatus() %></span>
                    </div>
                </div>

                <div class="booking-row">
                    <div class="booking-label">Payment Status</div>
                    <div class="booking-value">
                        <span class="status-pill <%= paymentStatusClass %>"><%= b.getPaymentStatus() %></span>
                    </div>
                </div>

                <div class="booking-row">
                    <div class="booking-label">Payment Reference</div>
                    <div class="booking-value">
                        <%= (b.getPaymentReference() == null || b.getPaymentReference().trim().isEmpty())
                                ? "-"
                                : b.getPaymentReference() %>
                    </div>
                </div>

                <div class="actions">
                    <% if ("APPROVED".equalsIgnoreCase(b.getPaymentStatus())
                            && !"CANCELLED".equalsIgnoreCase(b.getStatus())) { %>

                        <a class="btn btn-primary"
                           href="<%= request.getContextPath() %>/ticket?action=viewTickets&bookingId=<%= b.getBookingId() %>">
                            <i class="fa-solid fa-ticket"></i>
                            View Tickets
                        </a>

                        <a class="btn btn-secondary"
                           href="<%= request.getContextPath() %>/ticket?action=downloadPdf&bookingId=<%= b.getBookingId() %>">
                            <i class="fa-solid fa-file-pdf"></i>
                            Download PDF
                        </a>

                    <% } %>

                    <% if ("PENDING".equalsIgnoreCase(b.getPaymentStatus())
                            && !"CANCELLED".equalsIgnoreCase(b.getStatus())) { %>

                        <a class="btn btn-secondary"
                           href="<%= request.getContextPath() %>/ticket?action=viewTickets&bookingId=<%= b.getBookingId() %>">
                            Check Ticket Status
                        </a>

                    <% } %>

                    <% if (!"CANCELLED".equalsIgnoreCase(b.getStatus())
                            && !"APPROVED".equalsIgnoreCase(b.getPaymentStatus())) { %>

                        <form method="post" action="<%= request.getContextPath() %>/booking" style="display:inline;">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">

                            <button type="submit" class="btn btn-danger"
                                    onclick="return confirm('Are you sure you want to cancel this booking?');">
                                Cancel Booking
                            </button>
                        </form>

                    <% } %>
                </div>
            </div>

            <% } %>
        </div>

    <% } %>
</div>

</body>
</html>