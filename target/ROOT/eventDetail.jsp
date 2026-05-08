<!-- eventDetail.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventhorizon.model.EventTicketType" %>
<%@ page import="com.eventhorizon.service.IssueService" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    List<EventTicketType> ticketTypes = (List<EventTicketType>) request.getAttribute("ticketTypes");
    if (ticketTypes == null) {
        ticketTypes = new java.util.ArrayList<EventTicketType>();
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
    <title>${event.title} – EventHorizon</title>

    <link rel="stylesheet" href="css/style.css">

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
            --linen-warm: #F6F1E8;
            --paper: #FFFFFF;

            --forest: #1E4A3A;
            --forest-dark: #123528;
            --forest-deep: #0E2A20;
            --forest-soft: #E8F1EC;

            --sage: #72887A;
            --clay: #B08D65;

            --text: #18251F;
            --text-primary: #18251F;
            --text-soft: #52635A;
            --text-muted: #52635A;
            --muted: #6F7F76;

            --bg: #FAF8F4;
            --bg-card: #FFFFFF;

            --border: rgba(30, 74, 58, 0.16);
            --border-strong: rgba(30, 74, 58, 0.30);

            --accent-purple: #1E4A3A;
            --accent-teal: #1E4A3A;
            --accent-blue: #1E4A3A;

            --radius: 22px;

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
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
            line-height: 1.6;
            min-height: 100vh;
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

        .container {
            width: min(92%, 1240px);
            margin: 0 auto;
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

        /* ================= PAGE LAYOUT ================= */

        .back-link {
            color: var(--text-soft);
            font-size: 0.9rem;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .back-link:hover {
            color: var(--forest);
        }

        .event-detail-layout {
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 32px;
            margin-top: 24px;
            align-items: start;
        }

        .event-detail-hero {
            background: rgba(255, 255, 255, 0.96);
            color: var(--text);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 34px;
            box-shadow: var(--shadow-soft);
            display: flex;
            align-items: center;
            gap: 26px;
        }

        .event-detail-icon {
            width: 96px;
            height: 96px;
            border-radius: 24px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            color: #ffffff;
            font-size: 2.4rem;
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.22);
            flex-shrink: 0;
        }

        .card-category {
            width: fit-content;
            background: var(--forest-soft);
            color: var(--forest-dark);
            border: 1px solid var(--border-strong);
            border-radius: 999px;
            padding: 6px 14px;
            font-size: 0.74rem;
            font-weight: 900;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-bottom: 12px;
        }

        .event-detail-title {
            color: var(--forest-dark);
            font-size: clamp(1.8rem, 3vw, 2.6rem);
            font-weight: 900;
            letter-spacing: -0.04em;
            line-height: 1.1;
            margin-bottom: 14px;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 7px 12px;
            border-radius: 999px;
            font-size: 0.72rem;
            font-weight: 900;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            border: 1px solid transparent;
        }

        .badge-success {
            background: rgba(30, 122, 74, 0.12);
            color: #17613B;
            border-color: rgba(30, 122, 74, 0.22);
        }

        .badge-danger {
            background: rgba(192, 57, 43, 0.12);
            color: #9C3127;
            border-color: rgba(192, 57, 43, 0.22);
        }

        .event-meta-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-top: 24px;
        }

        .event-meta-item {
            background: rgba(255, 255, 255, 0.96);
            color: var(--text);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 18px;
            box-shadow: 0 12px 34px rgba(24, 37, 31, 0.06);
        }

        .event-meta-item label {
            display: block;
            color: var(--text-soft);
            font-size: 0.76rem;
            font-weight: 900;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-bottom: 6px;
        }

        .event-meta-item span {
            color: var(--text);
            font-size: 0.95rem;
            font-weight: 900;
        }

        .description-box {
            background: rgba(255, 255, 255, 0.96);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px;
            margin-top: 18px;
            box-shadow: 0 12px 34px rgba(24, 37, 31, 0.06);
        }

        .description-box h3 {
            margin-bottom: 12px;
            color: var(--forest-dark);
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 0.8rem;
            font-weight: 900;
        }

        .description-box p {
            color: var(--text-soft);
            line-height: 1.8;
            font-weight: 600;
        }

        /* ================= BOOKING CARD ================= */

        .booking-card {
            position: sticky;
            top: 100px;
            background: rgba(255, 255, 255, 0.97);
            color: var(--text);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 28px;
            box-shadow: var(--shadow-soft);
        }

        .booking-price {
            color: var(--forest-dark);
            font-size: 1.75rem;
            font-weight: 900;
            letter-spacing: -0.04em;
            line-height: 1.1;
        }

        .booking-price small {
            color: var(--text-soft);
            font-size: 0.78rem;
            font-weight: 800;
            letter-spacing: 0;
        }

        .seats-bar {
            width: 100%;
            height: 8px;
            border-radius: 999px;
            overflow: hidden;
            background: #E2E8E3;
        }

        .seats-bar-fill {
            height: 100%;
            border-radius: inherit;
            background: linear-gradient(90deg, var(--forest), var(--sage));
            width: 0%;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-label {
            display: block;
            color: var(--forest-dark);
            font-size: 0.78rem;
            font-weight: 900;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-bottom: 10px;
        }

        .form-control {
            width: 100%;
            min-height: 44px;
            border-radius: 10px;
            border: 1px solid var(--border-strong);
            background: #ffffff;
            color: var(--text);
            padding: 10px 14px;
            font-size: 0.95rem;
            font-weight: 700;
            outline: none;
        }

        .form-control:focus {
            border-color: rgba(30, 74, 58, 0.52);
            box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.10);
        }

        .ticket-type-grid {
            display: grid;
            gap: 12px;
            margin-bottom: 18px;
        }

        .ticket-type-card {
            position: relative;
            border: 1px solid rgba(30, 74, 58, 0.18);
            background: #ffffff;
            color: var(--text);
            border-radius: 14px;
            padding: 14px;
            transition: 0.2s ease;
            cursor: pointer;
        }

        .ticket-type-card:hover {
            border-color: rgba(30, 74, 58, 0.38);
            background: #F5FAF7;
        }

        .ticket-type-card.selected {
            border-color: rgba(30, 74, 58, 0.55);
            background: #E8F1EC;
            box-shadow: 0 0 0 3px rgba(30, 74, 58, 0.08);
        }

        .ticket-type-radio {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }

        .ticket-type-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 12px;
            margin-bottom: 10px;
        }

        .ticket-type-name {
            color: var(--forest-dark);
            font-size: 1rem;
            font-weight: 900;
        }

        .ticket-type-price {
            color: var(--forest-dark);
            font-size: 1rem;
            font-weight: 900;
            white-space: nowrap;
        }

        .ticket-type-meta {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            color: var(--text-soft);
            font-size: 0.86rem;
            font-weight: 650;
            flex-wrap: wrap;
        }

        .ticket-type-meta span {
            color: var(--text-soft);
        }

        .ticket-type-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 0.72rem;
            font-weight: 900;
            letter-spacing: 0.4px;
            text-transform: uppercase;
        }

        .badge-available {
            background: rgba(30, 122, 74, 0.12);
            color: #17613B;
        }

        .badge-soldout {
            background: rgba(192, 57, 43, 0.12);
            color: #9C3127;
        }

        .booking-summary-box {
            background: #E8F1EC;
            border: 1px solid rgba(30, 74, 58, 0.22);
            border-radius: 12px;
            padding: 14px;
            margin-bottom: 16px;
        }

        .summary-label {
            font-size: 0.8rem;
            color: var(--text-soft);
            font-weight: 750;
        }

        #selectedTypeName {
            font-size: 1rem;
            color: var(--forest-dark);
            font-weight: 900;
            margin-top: 4px;
        }

        #totalAmount {
            font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
            font-size: 1.3rem;
            color: var(--forest-dark);
            font-weight: 900;
            margin-top: 2px;
        }

        .btn {
            width: 100%;
            min-height: 46px;
            border-radius: 13px;
            border: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 0.92rem;
            font-weight: 900;
            cursor: pointer;
            transition: 0.22s ease;
            text-decoration: none;
        }

        .btn-primary {
            color: #ffffff;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
        }

        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 18px 42px rgba(30, 74, 58, 0.30);
        }

        .btn-secondary {
            color: var(--forest);
            background: var(--forest-soft);
            border: 1px solid var(--border-strong);
            box-shadow: none;
        }

        .btn-block {
            width: 100%;
        }

        .alert {
            border-radius: 12px;
            padding: 14px;
            font-size: 0.88rem;
            font-weight: 750;
            line-height: 1.5;
        }

        .alert-info {
            background: var(--forest-soft);
            color: var(--forest-dark);
            border: 1px solid var(--border-strong);
        }

        .alert-danger {
            background: #FFF0EC;
            color: #A23A27;
            border: 1px solid rgba(162, 58, 39, 0.22);
        }

        .alert-warning {
            background: #FFF7E3;
            color: #8A5A00;
            border: 1px solid rgba(138, 90, 0, 0.22);
        }

        /* ================= FOOTER / GENERAL COMPATIBILITY OVERRIDES ================= */

        input,
        select,
        textarea {
            background: #ffffff;
            color: var(--text);
            border: 1px solid var(--border-strong);
        }

        input::placeholder,
        textarea::placeholder {
            color: #7E9086;
        }

        h1,
        h2,
        h3,
        h4,
        h5,
        h6 {
            color: var(--forest-dark);
            text-shadow: none;
        }

        p,
        li,
        label {
            text-shadow: none;
        }

        strong {
            color: var(--forest);
        }

        /* ================= RESPONSIVE ================= */

        @media (max-width: 1100px) {
            .event-detail-layout {
                grid-template-columns: 1fr;
            }

            .booking-card {
                position: static;
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

            .event-detail-hero {
                flex-direction: column;
                align-items: flex-start;
                padding: 26px;
            }

            .event-meta-grid {
                grid-template-columns: 1fr;
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

<div class="container" style="padding-top:32px;padding-bottom:60px;">

    <a href="event?action=list" class="back-link">
        <i class="fa-solid fa-arrow-left"></i>
        Back to Events
    </a>

    <div class="event-detail-layout">

        <div>
            <div class="event-detail-hero">
                <div class="event-detail-icon">
                    <c:choose>
                        <c:when test="${event.category == 'Concert'}">🎵</c:when>
                        <c:when test="${event.category == 'Sports'}">⚽</c:when>
                        <c:when test="${event.category == 'Technology'}">💻</c:when>
                        <c:when test="${event.category == 'Cultural'}">🎭</c:when>
                        <c:when test="${event.category == 'Theater'}">🎬</c:when>
                        <c:otherwise>🎟️</c:otherwise>
                    </c:choose>
                </div>

                <div>
                    <div class="card-category">${event.category}</div>

                    <h1 class="event-detail-title">${event.title}</h1>

                    <c:if test="${event.status == 'CANCELLED'}">
                        <span class="badge badge-danger">CANCELLED</span>
                    </c:if>

                    <c:if test="${event.status == 'ACTIVE'}">
                        <span class="badge badge-success">ACTIVE</span>
                    </c:if>
                </div>
            </div>

            <div class="event-meta-grid">
                <div class="event-meta-item">
                    <label>📅 Date</label>
                    <span>${event.date}</span>
                </div>

                <div class="event-meta-item">
                    <label>⏰ Time</label>
                    <span>${event.time}</span>
                </div>

                <div class="event-meta-item">
                    <label>📍 Venue</label>
                    <span>${event.venue}</span>
                </div>

                <div class="event-meta-item">
                    <label>💺 Available Seats</label>
                    <span>${event.availableSeats} / ${event.totalSeats}</span>
                </div>
            </div>

            <div class="description-box">
                <h3>About This Event</h3>
                <p>${event.description}</p>
            </div>
        </div>

        <div>
            <div class="booking-card">
                <div class="booking-price">
                    LKR ${event.ticketPrice}
                    <small>/ starting from</small>
                </div>

                <div class="seats-bar" style="margin-top:12px;">
                    <div class="seats-bar-fill"
                         data-pct="${event.totalSeats > 0 ? (event.availableSeats * 100) / event.totalSeats : 0}">
                    </div>
                </div>

                <p style="font-size:0.8rem;color:var(--text-soft);margin-bottom:20px;font-weight:700;">
                    ${event.availableSeats} seats remaining in total
                </p>

                <c:choose>
                    <c:when test="${event.status == 'CANCELLED'}">
                        <div class="alert alert-danger">This event has been cancelled.</div>
                    </c:when>

                    <c:when test="${event.availableSeats == 0}">
                        <div class="alert alert-warning">Sold Out!</div>
                    </c:when>

                    <c:when test="${empty sessionScope.userId}">
                        <div class="alert alert-info" style="margin-bottom:16px;">
                            Please log in to book tickets.
                        </div>

                        <a href="login.jsp" class="btn btn-primary btn-block">
                            🔑 Login to Book
                        </a>
                    </c:when>

                    <c:when test="${sessionScope.role == 'CUSTOMER'}">
                        <form action="booking" method="get" id="bookingForm">
                            <input type="hidden" name="action" value="checkout">
                            <input type="hidden" name="eventId" value="${event.eventId}">

                            <div class="form-group">
                                <label class="form-label">Select Ticket Type</label>

                                <div class="ticket-type-grid" id="ticketTypeGrid">
                                    <%
                                        int typeIndex = 0;

                                        for (EventTicketType type : ticketTypes) {
                                            boolean available = type.getAvailableSeats() > 0;
                                    %>
                                        <label class="ticket-type-card <%= (available && typeIndex == 0) ? "selected" : "" %>"
                                               data-price="<%= type.getPrice() %>"
                                               data-available="<%= type.getAvailableSeats() %>"
                                               onclick="selectTicketCard(this)">

                                            <input
                                                class="ticket-type-radio"
                                                type="radio"
                                                name="ticketTypeId"
                                                value="<%= type.getTicketTypeId() %>"
                                                <%= (available && typeIndex == 0) ? "checked" : "" %>
                                                <%= !available ? "disabled" : "" %> >

                                            <div class="ticket-type-top">
                                                <div class="ticket-type-name"><%= type.getTypeName() %></div>

                                                <div class="ticket-type-price">
                                                    LKR <%= String.format("%.2f", type.getPrice()) %>
                                                </div>
                                            </div>

                                            <div class="ticket-type-meta">
                                                <span>
                                                    <%= type.getAvailableSeats() %> / <%= type.getTotalSeats() %> seats available
                                                </span>

                                                <span class="ticket-type-badge <%= available ? "badge-available" : "badge-soldout" %>">
                                                    <%= available ? "Available" : "Sold Out" %>
                                                </span>
                                            </div>
                                        </label>
                                    <%
                                            typeIndex++;
                                        }
                                    %>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="numberOfTickets">
                                    Number of Tickets
                                </label>

                                <input type="number"
                                       id="numberOfTickets"
                                       name="tickets"
                                       class="form-control"
                                       value="1"
                                       min="1"
                                       max="1"
                                       required>
                            </div>

                            <div class="booking-summary-box">
                                <div class="summary-label">Selected Type</div>
                                <div id="selectedTypeName">Select a ticket type</div>

                                <div class="summary-label" style="margin-top:10px;">Total Amount</div>
                                <div id="totalAmount">LKR 0.00</div>
                            </div>

                            <button type="submit" class="btn btn-primary btn-block" id="checkoutBtn">
                                🎟️ Proceed to Checkout
                            </button>
                        </form>
                    </c:when>

                    <c:when test="${sessionScope.role == 'ADMIN'}">
                        <div class="alert alert-warning" style="margin-bottom:16px;">
                            Admin accounts cannot book tickets.
                        </div>

                        <a href="admin/dashboard.jsp" class="btn btn-secondary btn-block">
                            Go to Dashboard
                        </a>
                    </c:when>

                    <c:otherwise>
                        <div class="alert alert-info" style="margin-bottom:16px;">
                            Please log in to continue.
                        </div>

                        <a href="login.jsp" class="btn btn-primary btn-block">
                            🔑 Login
                        </a>
                    </c:otherwise>
                </c:choose>

                <% if ("bookingFailed".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-danger" style="margin-top:12px;">
                        ❌ Booking failed. Please try again. Seats may have just changed or the booking transaction did not complete.
                    </div>
                <% } %>

                <% if ("inactive".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-warning" style="margin-top:12px;">
                        ⚠ This event is not active for booking.
                    </div>
                <% } %>

                <% if ("noSeats".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-danger" style="margin-top:12px;">
                        ❌ Not enough seats available for your request.
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<script src="js/main.js"></script>

<script>
    function selectTicketCard(card) {
        const radio = card.querySelector('input[type="radio"]');

        if (!radio || radio.disabled) {
            return;
        }

        document.querySelectorAll('.ticket-type-card').forEach(function (c) {
            c.classList.remove('selected');
        });

        card.classList.add('selected');
        radio.checked = true;

        updateBookingSummary();
    }

    function updateBookingSummary() {
        const selected = document.querySelector('.ticket-type-radio:checked');
        const qtyInput = document.getElementById('numberOfTickets');
        const totalAmount = document.getElementById('totalAmount');
        const selectedTypeName = document.getElementById('selectedTypeName');
        const checkoutBtn = document.getElementById('checkoutBtn');

        if (!selected || !qtyInput || !totalAmount || !selectedTypeName) {
            return;
        }

        const card = selected.closest('.ticket-type-card');
        const price = parseFloat(card.getAttribute('data-price') || '0');
        const available = parseInt(card.getAttribute('data-available') || '0', 10);
        const nameEl = card.querySelector('.ticket-type-name');

        qtyInput.max = available > 0 ? available : 1;

        let qty = parseInt(qtyInput.value || '1', 10);

        if (isNaN(qty) || qty < 1) {
            qty = 1;
            qtyInput.value = 1;
        }

        if (qty > available && available > 0) {
            qty = available;
            qtyInput.value = available;
        }

        selectedTypeName.textContent = nameEl ? nameEl.textContent : 'Selected Ticket';
        totalAmount.textContent = 'LKR ' + (price * qty).toFixed(2);

        if (checkoutBtn) {
            checkoutBtn.disabled = available <= 0;
        }
    }

    (function () {
        const qtyInput = document.getElementById('numberOfTickets');

        if (qtyInput) {
            qtyInput.addEventListener('input', updateBookingSummary);
        }

        const firstAvailable = document.querySelector('.ticket-type-radio:not([disabled])');

        if (firstAvailable) {
            firstAvailable.checked = true;
            selectTicketCard(firstAvailable.closest('.ticket-type-card'));
        }

        document.querySelectorAll('.seats-bar-fill').forEach(function (bar) {
            const pct = parseFloat(bar.getAttribute('data-pct') || '0');
            const safePct = Math.max(0, Math.min(100, pct));
            bar.style.width = safePct + '%';
        });
    })();
</script>

</body>
</html>