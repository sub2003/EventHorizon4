<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.eventhorizon.model.Event" %>
<%@ page import="com.eventhorizon.model.EventTicketType" %>
<%@ page import="com.eventhorizon.service.IssueService" %>

<%
    Event event = (Event) request.getAttribute("event");
    EventTicketType ticketType = (EventTicketType) request.getAttribute("ticketType");
    Integer tickets = (Integer) request.getAttribute("tickets");
    Double total = (Double) request.getAttribute("total");
    String error = request.getParameter("error");
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
    <title>Checkout – EventHorizon</title>

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
            --warning-bg: #FFF7E3;
            --warning-text: #8A5A00;
            --success-bg: #E8F6EE;
            --success-text: #176B3B;

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
            max-width: 1120px;
            margin: 40px auto 70px;
        }

        .breadcrumb {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
            font-size: 0.9rem;
            color: var(--text-soft);
            margin-bottom: 24px;
            font-weight: 750;
        }

        .breadcrumb a {
            color: var(--forest);
            font-weight: 900;
        }

        .breadcrumb a:hover {
            text-decoration: underline;
        }

        .card {
            background: rgba(255, 255, 255, 0.97);
            border: 1px solid var(--border);
            border-radius: 28px;
            overflow: hidden;
            box-shadow: var(--shadow-premium);
            color: var(--text);
        }

        .card-head {
            padding: 28px 32px;
            border-bottom: 1px solid var(--border);
            background:
                radial-gradient(circle at left top, rgba(30, 74, 58, 0.12), transparent 40%),
                linear-gradient(135deg, #ffffff, #F8F4EC);
        }

        .card-head h1 {
            font-size: clamp(1.65rem, 3vw, 2rem);
            font-weight: 900;
            color: var(--forest-dark);
            letter-spacing: -0.04em;
        }

        .card-body {
            padding: 30px;
        }

        .checkout-grid {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            gap: 24px;
            align-items: start;
        }

        /* ================= ORDER SUMMARY ================= */

        .summary {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 14px 36px rgba(24, 37, 31, 0.07);
        }

        .summary-title,
        .panel-title {
            font-size: 0.78rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--forest-dark);
            margin-bottom: 16px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 18px;
            padding: 12px 0;
            border-bottom: 1px solid rgba(30, 74, 58, 0.11);
            flex-wrap: wrap;
        }

        .summary-row:last-child {
            border-bottom: none;
        }

        .s-label {
            color: var(--text-soft);
            font-size: 0.9rem;
            font-weight: 850;
        }

        .s-value {
            color: var(--text);
            font-size: 0.92rem;
            font-weight: 900;
            text-align: right;
            max-width: 62%;
            word-break: break-word;
        }

        .type-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 13px;
            border-radius: 999px;
            font-size: 0.75rem;
            font-weight: 900;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            background: var(--forest-soft);
            color: var(--forest-dark);
            border: 1px solid var(--border-strong);
        }

        .total-row {
            margin-top: 10px;
            padding-top: 18px;
            border-top: 2px solid rgba(30, 74, 58, 0.15);
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .total-label {
            font-size: 0.92rem;
            color: var(--forest-dark);
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.6px;
        }

        .total-amount {
            font-size: clamp(1.55rem, 3vw, 2rem);
            font-weight: 900;
            color: var(--forest-dark);
            letter-spacing: -0.04em;
        }

        /* ================= FORM ================= */

        .form-panel {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 14px 36px rgba(24, 37, 31, 0.07);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 0.78rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            color: var(--forest-dark);
            margin-bottom: 10px;
        }

        .form-group input {
            width: 100%;
            padding: 14px 16px;
            border-radius: 14px;
            border: 1px solid var(--border-strong);
            background: #ffffff;
            color: var(--text);
            font-size: 0.95rem;
            font-weight: 750;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .form-group input:focus {
            border-color: rgba(30, 74, 58, 0.52);
            box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.10);
        }

        .form-group input::placeholder {
            color: #7E9086;
            font-weight: 600;
        }

        .hint {
            margin-top: 8px;
            font-size: 0.86rem;
            color: var(--text-soft);
            line-height: 1.55;
            font-weight: 650;
        }

        .actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 24px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 14px 22px;
            border-radius: 14px;
            border: none;
            font-weight: 900;
            font-size: 0.94rem;
            cursor: pointer;
            text-decoration: none;
            transition: 0.2s ease;
            gap: 8px;
            min-height: 48px;
        }

        .btn:hover {
            transform: translateY(-1px);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            color: #ffffff;
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
        }

        .btn-primary:hover {
            box-shadow: 0 18px 42px rgba(30, 74, 58, 0.30);
        }

        .btn-secondary {
            background: var(--forest-soft);
            color: var(--forest-dark);
            border: 1px solid var(--border-strong);
        }

        /* ================= SIDE PANELS ================= */

        .side-panel {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 22px;
            margin-bottom: 18px;
            box-shadow: 0 14px 36px rgba(24, 37, 31, 0.07);
        }

        .bank-card {
            background:
                radial-gradient(circle at top right, rgba(30, 74, 58, 0.10), transparent 40%),
                #ffffff;
        }

        .bank-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 16px;
        }

        .bank-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 0.68rem;
            font-weight: 900;
            letter-spacing: 0.7px;
            text-transform: uppercase;
            color: var(--forest-dark);
            background: var(--forest-soft);
            border: 1px solid var(--border-strong);
            white-space: nowrap;
        }

        .bank-grid {
            display: grid;
            gap: 12px;
        }

        .bank-item {
            background: #FAF8F4;
            border: 1px solid rgba(30, 74, 58, 0.13);
            border-radius: 14px;
            padding: 14px 16px;
        }

        .bank-label {
            font-size: 0.72rem;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--text-soft);
            font-weight: 900;
            margin-bottom: 8px;
        }

        .bank-value {
            color: var(--forest-dark);
            font-size: 1rem;
            font-weight: 900;
            word-break: break-word;
        }

        .bank-note {
            margin-top: 14px;
            padding: 13px 15px;
            border-radius: 14px;
            background: #FFF7E3;
            border: 1px solid rgba(138, 90, 0, 0.18);
            color: #76520F;
            font-size: 0.86rem;
            font-weight: 700;
            line-height: 1.6;
        }

        .bank-note strong {
            color: #5F3E00;
            font-weight: 900;
        }

        .steps {
            display: grid;
            gap: 12px;
        }

        .step {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 12px 0;
            border-bottom: 1px solid rgba(30, 74, 58, 0.10);
        }

        .step:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        .step-number {
            min-width: 30px;
            height: 30px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.82rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            color: #ffffff;
            box-shadow: 0 8px 18px rgba(30, 74, 58, 0.22);
            flex-shrink: 0;
        }

        .step-text {
            color: var(--text-soft);
            font-size: 0.9rem;
            font-weight: 650;
            line-height: 1.65;
        }

        .step-text strong {
            color: var(--forest-dark);
            font-weight: 900;
        }

        /* ================= ALERT / EMPTY ================= */

        .alert-error {
            background: var(--danger-bg);
            border: 1px solid rgba(162, 58, 39, 0.22);
            color: var(--danger-text);
            border-radius: 14px;
            padding: 14px 16px;
            font-weight: 850;
            margin-bottom: 22px;
        }

        .empty-card {
            text-align: center;
            padding: 52px 28px;
        }

        .empty-card p {
            color: var(--text-soft);
            margin-bottom: 20px;
            font-weight: 750;
        }

        /* ================= RESPONSIVE ================= */

        @media (max-width: 900px) {
            .checkout-grid {
                grid-template-columns: 1fr;
            }

            .s-value {
                max-width: 100%;
                text-align: left;
            }
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

            .container {
                width: 94%;
                margin-top: 26px;
            }

            .card-body {
                padding: 22px;
            }

            .card-head {
                padding: 22px;
            }

            .summary,
            .form-panel,
            .side-panel {
                padding: 20px;
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

            .actions {
                flex-direction: column;
            }

            .btn {
                width: 100%;
            }

            .bank-header {
                align-items: flex-start;
                flex-direction: column;
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
                <a href="${pageContext.request.contextPath}/event?action=list" class="eh-nav-link active">
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

    <div class="breadcrumb">
        <a href="<%= request.getContextPath() %>/event?action=list">Events</a>
        <span>/</span>

        <% if (event != null) { %>
            <a href="<%= request.getContextPath() %>/event?action=view&id=<%= event.getEventId() %>">
                <%= event.getTitle() %>
            </a>
            <span>/</span>
        <% } %>

        <span>Checkout</span>
    </div>

    <% if (event == null || ticketType == null || tickets == null || total == null) { %>

        <div class="card">
            <div class="card-body empty-card">
                <p>Invalid checkout request. Please go back and select a ticket.</p>

                <a class="btn btn-secondary" href="<%= request.getContextPath() %>/event?action=list">
                    ← Back to Events
                </a>
            </div>
        </div>

    <% } else { %>

        <div class="card">
            <div class="card-head">
                <h1>🎟️ Order Checkout</h1>
            </div>

            <div class="card-body">

                <% if ("noReference".equals(error)) { %>
                    <div class="alert-error">
                        ⚠ Payment reference is required. Please enter your transfer/reference number.
                    </div>
                <% } %>

                <div class="checkout-grid">

                    <div>
                        <div class="summary">
                            <div class="summary-title">Order Summary</div>

                            <div class="summary-row">
                                <span class="s-label">Event</span>
                                <span class="s-value"><%= event.getTitle() %></span>
                            </div>

                            <div class="summary-row">
                                <span class="s-label">Venue</span>
                                <span class="s-value"><%= event.getVenue() %></span>
                            </div>

                            <div class="summary-row">
                                <span class="s-label">Date &amp; Time</span>
                                <span class="s-value"><%= event.getDate() %> &nbsp; <%= event.getTime() %></span>
                            </div>

                            <div class="summary-row">
                                <span class="s-label">Ticket Type</span>
                                <span class="s-value">
                                    <span class="type-badge"><%= ticketType.getTypeName() %></span>
                                </span>
                            </div>

                            <div class="summary-row">
                                <span class="s-label">Price per Ticket</span>
                                <span class="s-value">LKR <%= String.format("%.2f", ticketType.getPrice()) %></span>
                            </div>

                            <div class="summary-row">
                                <span class="s-label">Quantity</span>
                                <span class="s-value"><%= tickets %> ticket<%= tickets > 1 ? "s" : "" %></span>
                            </div>

                            <div class="total-row">
                                <span class="total-label">Total Amount</span>
                                <span class="total-amount">LKR <%= String.format("%.2f", total) %></span>
                            </div>
                        </div>

                        <div class="form-panel">
                            <form action="<%= request.getContextPath() %>/booking" method="post">
                                <input type="hidden" name="action" value="confirmPayment">
                                <input type="hidden" name="eventId" value="<%= event.getEventId() %>">
                                <input type="hidden" name="ticketTypeId" value="<%= ticketType.getTicketTypeId() %>">
                                <input type="hidden" name="numberOfTickets" value="<%= tickets %>">

                                <div class="form-group">
                                    <label for="paymentReference">Payment Reference Number</label>

                                    <input type="text"
                                           id="paymentReference"
                                           name="paymentReference"
                                           placeholder="Enter your bank transfer / payment slip reference"
                                           required
                                           autocomplete="off">

                                    <div class="hint">
                                        After completing the transfer, enter the transaction reference number, bank slip number, or payment note ID here.
                                    </div>
                                </div>

                                <div class="actions">
                                    <button type="submit" class="btn btn-primary">
                                        ✅ Confirm Payment Submission
                                    </button>

                                    <a class="btn btn-secondary"
                                       href="<%= request.getContextPath() %>/event?action=view&id=<%= event.getEventId() %>">
                                        ← Go Back
                                    </a>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div>
                        <div class="side-panel bank-card">
                            <div class="bank-header">
                                <div class="panel-title" style="margin-bottom:0;">Bank Transfer Details</div>
                                <span class="bank-badge">Official Payment</span>
                            </div>

                            <div class="bank-grid">
                                <div class="bank-item">
                                    <div class="bank-label">Bank Name</div>
                                    <div class="bank-value">HNB</div>
                                </div>

                                <div class="bank-item">
                                    <div class="bank-label">Account Number</div>
                                    <div class="bank-value">013020763635</div>
                                </div>

                                <div class="bank-item">
                                    <div class="bank-label">Account Name</div>
                                    <div class="bank-value">EventHorizon</div>
                                </div>

                                <div class="bank-item">
                                    <div class="bank-label">Payment Amount</div>
                                    <div class="bank-value">LKR <%= String.format("%.2f", total) %></div>
                                </div>
                            </div>

                            <div class="bank-note">
                                Please transfer the <strong>exact total amount</strong> shown on this page.
                                Keep your bank slip or transaction receipt safe until your booking is approved.
                            </div>
                        </div>

                        <div class="side-panel">
                            <div class="panel-title">Payment Procedure</div>

                            <div class="steps">
                                <div class="step">
                                    <div class="step-number">1</div>
                                    <div class="step-text">
                                        Transfer <strong>LKR <%= String.format("%.2f", total) %></strong> to the bank account shown above.
                                    </div>
                                </div>

                                <div class="step">
                                    <div class="step-number">2</div>
                                    <div class="step-text">
                                        Copy the <strong>transaction reference number</strong> or keep a clear payment slip screenshot.
                                    </div>
                                </div>

                                <div class="step">
                                    <div class="step-number">3</div>
                                    <div class="step-text">
                                        Enter that reference number in the <strong>Payment Reference Number</strong> field on this page.
                                    </div>
                                </div>

                                <div class="step">
                                    <div class="step-number">4</div>
                                    <div class="step-text">
                                        Click <strong>Confirm Payment Submission</strong> to send your booking for admin review.
                                    </div>
                                </div>

                                <div class="step">
                                    <div class="step-number">5</div>
                                    <div class="step-text">
                                        Once approved, your booking will appear in <strong>My Bookings</strong> and your digital tickets will be generated.
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="side-panel">
                            <div class="panel-title">Important Notes</div>

                            <div class="steps">
                                <div class="step">
                                    <div class="step-number">!</div>
                                    <div class="step-text">
                                        Your booking is not fully completed until the payment is reviewed and approved by an admin.
                                    </div>
                                </div>

                                <div class="step">
                                    <div class="step-number">!</div>
                                    <div class="step-text">
                                        Please make sure the payment reference is entered correctly to avoid approval delays.
                                    </div>
                                </div>

                                <div class="step">
                                    <div class="step-number">!</div>
                                    <div class="step-text">
                                        If you pay a different amount or submit a wrong reference number, your booking may be rejected.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

            </div>
        </div>

    <% } %>
</div>

</body>
</html>