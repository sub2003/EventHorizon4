<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.eventhorizon.service.IssueService" %>

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
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>Report an Issue — EventHorizon Support</title>

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

            --warning-bg: #FFF7E3;
            --warning-text: #76520F;

            --danger-bg: #FFF0EC;
            --danger-text: #A23A27;

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

        .eh-nav-bell:hover,
        .eh-nav-bell.active {
            color: var(--forest-dark);
            background: #ffffff;
            border-color: var(--border-strong);
            box-shadow: 0 8px 18px rgba(24, 37, 31, 0.06);
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

        /* ================= HERO ================= */

        .hero {
            position: relative;
            text-align: center;
            padding: 74px 24px 48px;
        }

        .hero::before {
            content: "";
            position: absolute;
            top: 24px;
            left: 50%;
            transform: translateX(-50%);
            width: min(680px, 90%);
            height: 260px;
            background:
                radial-gradient(ellipse, rgba(30, 74, 58, 0.14) 0%, rgba(176, 141, 101, 0.10) 38%, transparent 72%);
            pointer-events: none;
            z-index: -1;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #ffffff;
            border: 1px solid var(--border-strong);
            color: var(--forest-dark);
            padding: 7px 16px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 900;
            letter-spacing: 0.5px;
            margin-bottom: 20px;
            box-shadow: 0 10px 24px rgba(24, 37, 31, 0.06);
        }

        .hero-badge i {
            color: var(--forest);
        }

        .hero h1 {
            color: var(--forest-dark);
            font-size: clamp(2rem, 5vw, 3.3rem);
            font-weight: 900;
            line-height: 1.08;
            margin-bottom: 14px;
            letter-spacing: -0.06em;
        }

        .hero h1 span {
            color: var(--forest);
        }

        .hero p {
            color: var(--text-soft);
            max-width: 640px;
            margin: 0 auto;
            line-height: 1.8;
            font-weight: 650;
        }

        /* ================= LAYOUT ================= */

        .page-wrap {
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 28px;
            max-width: 1120px;
            margin: 0 auto;
            padding: 0 24px 80px;
        }

        /* ================= CARDS ================= */

        .card,
        .contact-card,
        .emergency-card {
            background: #ffffff;
            border: 2px solid rgba(30, 74, 58, 0.18);
            border-radius: 24px;
            box-shadow: var(--shadow-soft);
            color: var(--text);
        }

        .card {
            padding: 32px;
        }

        .card-title {
            font-size: 1rem;
            font-weight: 900;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--forest-dark);
            letter-spacing: -0.01em;
        }

        .card-title i {
            color: var(--forest);
            font-size: 0.95rem;
        }

        /* ================= FORM ================= */

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            font-size: 0.8rem;
            font-weight: 900;
            color: var(--forest-dark);
            margin-bottom: 8px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        label span.req {
            color: var(--danger-text);
            margin-left: 3px;
        }

        input[type="text"],
        input[type="email"],
        input[type="tel"],
        input[type="number"],
        select,
        textarea {
            width: 100%;
            background: #ffffff;
            border: 1px solid var(--border-strong);
            border-radius: 12px;
            color: var(--text);
            padding: 13px 14px;
            font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
            font-size: 0.92rem;
            font-weight: 650;
            transition: border-color 0.2s, box-shadow 0.2s;
            outline: none;
        }

        input:focus,
        select:focus,
        textarea:focus {
            border-color: rgba(30, 74, 58, 0.52);
            box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.10);
        }

        input::placeholder,
        textarea::placeholder {
            color: #7E9086;
            font-weight: 600;
        }

        select option {
            background: #ffffff;
            color: var(--text);
        }

        textarea {
            resize: vertical;
            min-height: 125px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .optional-text {
            color: var(--muted);
            font-size: 0.72rem;
            font-weight: 800;
            text-transform: none;
        }

        .routing-hint {
            font-size: 0.78rem;
            color: var(--text-soft);
            margin-top: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
            font-weight: 750;
        }

        .chip {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: var(--forest-soft);
            color: var(--forest-dark);
            border: 1px solid var(--border-strong);
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 0.74rem;
            font-weight: 900;
        }

        /* ================= PRIORITY ================= */

        .priority-group {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .priority-btn {
            flex: 1;
            min-width: 110px;
            padding: 11px;
            border-radius: 12px;
            cursor: pointer;
            border: 1.5px solid var(--border);
            background: #ffffff;
            color: var(--text-soft);
            font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
            font-size: 0.84rem;
            font-weight: 900;
            text-align: center;
            transition: all 0.2s;
        }

        .priority-btn:hover {
            border-color: var(--border-strong);
            color: var(--forest-dark);
            background: var(--forest-soft);
        }

        .priority-btn.selected-low {
            border-color: rgba(23, 107, 59, 0.28);
            color: var(--success-text);
            background: var(--success-bg);
        }

        .priority-btn.selected-medium {
            border-color: rgba(138, 90, 0, 0.28);
            color: var(--warning-text);
            background: var(--warning-bg);
        }

        .priority-btn.selected-high {
            border-color: rgba(162, 58, 39, 0.28);
            color: var(--danger-text);
            background: var(--danger-bg);
        }

        input[name="priority"] {
            display: none;
        }

        .btn-submit {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            border: none;
            border-radius: 14px;
            color: #ffffff;
            font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
            font-size: 0.98rem;
            font-weight: 900;
            cursor: pointer;
            margin-top: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
            transition: 0.22s ease;
        }

        .btn-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 18px 42px rgba(30, 74, 58, 0.30);
        }

        /* ================= ALERTS ================= */

        .alert {
            padding: 14px 18px;
            border-radius: 14px;
            margin-bottom: 22px;
            font-size: 0.9rem;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            font-weight: 750;
        }

        .alert-success {
            background: var(--success-bg);
            border: 1px solid rgba(23, 107, 59, 0.24);
            color: var(--success-text);
        }

        .alert-error {
            background: var(--danger-bg);
            border: 1px solid rgba(162, 58, 39, 0.24);
            color: var(--danger-text);
        }

        .alert i {
            margin-top: 2px;
        }

        /* ================= MY ISSUE NOTIFICATIONS ================= */

        .issue-list {
            display: grid;
            gap: 14px;
        }

        .issue-notification-card {
            display: block;
            text-decoration: none;
            color: inherit;
            background: #FAF8F4;
            border: 1px solid rgba(30, 74, 58, 0.16);
            border-radius: 14px;
            padding: 16px;
            transition: 0.22s ease;
        }

        .issue-notification-card:hover {
            background: #ffffff;
            border-color: var(--border-strong);
            box-shadow: 0 12px 28px rgba(24, 37, 31, 0.08);
            transform: translateY(-1px);
        }

        .issue-notification-top {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: flex-start;
            flex-wrap: wrap;
        }

        .issue-notification-title {
            color: var(--forest-dark);
            font-weight: 900;
            margin-bottom: 6px;
        }

        .issue-notification-category {
            font-size: 0.82rem;
            color: var(--text-soft);
            font-weight: 700;
        }

        .issue-actions {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
        }

        .view-message-text {
            font-size: 0.76rem;
            color: var(--forest-dark);
            font-weight: 900;
        }

        .empty-notification {
            background: #FAF8F4;
            border: 1px dashed rgba(30, 74, 58, 0.28);
            border-radius: 14px;
            padding: 20px;
            color: var(--text-soft);
            text-align: center;
            font-weight: 650;
        }

        /* ================= SIDEBAR ================= */

        .contact-section {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .contact-card,
        .emergency-card {
            padding: 22px;
        }

        .contact-card h3,
        .emergency-card h3 {
            font-size: 0.82rem;
            font-weight: 900;
            margin-bottom: 16px;
            color: var(--forest-dark);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .contact-card h3 i,
        .emergency-card h3 i {
            color: var(--forest);
            margin-right: 6px;
        }

        .contact-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 12px 0;
            border-bottom: 1px solid rgba(30, 74, 58, 0.12);
        }

        .contact-item:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        .contact-icon {
            width: 38px;
            height: 38px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.85rem;
            flex-shrink: 0;
            background: var(--forest-soft);
            color: var(--forest-dark);
            border: 1px solid var(--border);
        }

        .contact-info small {
            display: block;
            font-size: 0.73rem;
            color: var(--text-soft);
            margin-bottom: 2px;
            font-weight: 850;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }

        .contact-info a,
        .contact-info span {
            font-size: 0.88rem;
            color: var(--text);
            text-decoration: none;
            font-weight: 800;
            word-break: break-word;
        }

        .contact-info a:hover {
            color: var(--forest);
        }

        .emergency-card {
            background:
                radial-gradient(circle at top right, rgba(162, 58, 39, 0.08), transparent 42%),
                #ffffff;
            border-color: rgba(162, 58, 39, 0.20);
        }

        .emergency-card h3 {
            color: var(--danger-text);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .emergency-card h3 i {
            color: var(--danger-text);
        }

        .emergency-note {
            font-size: 0.8rem;
            color: var(--text-soft);
            margin-top: 12px;
            line-height: 1.7;
            font-weight: 650;
        }

        .emergency-note strong {
            color: var(--forest-dark);
            font-weight: 900;
        }

        .cat-guide {
            display: flex;
            flex-direction: column;
            gap: 9px;
        }

        .cat-row {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            font-size: 0.82rem;
            color: var(--text-soft);
            padding: 10px 12px;
            background: #FAF8F4;
            border: 1px solid rgba(30, 74, 58, 0.12);
            border-radius: 12px;
            line-height: 1.55;
            font-weight: 650;
        }

        .cat-dot {
            width: 9px;
            height: 9px;
            border-radius: 50%;
            flex-shrink: 0;
            margin-top: 6px;
            background: var(--forest);
        }

        .cat-row strong {
            color: var(--forest-dark);
            font-weight: 900;
        }

        /* ================= FOOTER ================= */

        footer {
            text-align: center;
            padding: 28px;
            border-top: 1px solid var(--border);
            color: var(--muted);
            font-size: 0.82rem;
            font-weight: 650;
            background: rgba(250, 248, 244, 0.96);
        }

        footer a {
            color: var(--forest-dark);
            font-weight: 850;
            text-decoration: none;
        }

        footer a:hover {
            text-decoration: underline;
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

        @media (max-width: 860px) {
            .page-wrap {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 540px) {
            .form-row {
                grid-template-columns: 1fr;
            }

            .card {
                padding: 24px;
            }

            .hero {
                padding-top: 54px;
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

            .priority-btn {
                min-width: 100%;
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
                    <a href="${pageContext.request.contextPath}/IssueServlet?action=myIssues" class="eh-nav-bell active" title="Issue notifications">
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

<div class="hero">
    <div class="hero-badge">
        <i class="fas fa-headset"></i>
        EventHorizon Support Center
    </div>

    <h1>Report an <span>Issue</span></h1>

    <p>
        Having trouble with a booking, payment, or event? Fill in the form below and we will route your issue directly to the right team.
    </p>
</div>

<div class="page-wrap">

    <div>
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <span>${sessionScope.successMsg}</span>
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <span>${sessionScope.errorMsg}</span>
            </div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <div class="card">
            <div class="card-title">
                <i class="fas fa-file-alt"></i>
                Submit Your Issue
            </div>

            <form action="${pageContext.request.contextPath}/IssueServlet" method="post" id="issueForm">
                <input type="hidden" name="action" value="submit" />

                <div class="form-group">
                    <label>Issue Category <span class="req">*</span></label>

                    <select name="category" id="categorySelect" required onchange="updateRouting()">
                        <option value="" disabled selected>— Select a category —</option>

                        <optgroup label="📦 Booking &amp; Payments">
                            <option value="Booking Problem">Booking Problem</option>
                            <option value="Payment Verification Issue">Payment Verification Issue</option>
                            <option value="Ticket Not Received">Ticket Not Received</option>
                            <option value="QR Code Not Working">QR Code Not Working</option>
                            <option value="Refund Request">Refund Request</option>
                            <option value="Seat Availability Problem">Seat Availability Problem</option>
                        </optgroup>

                        <optgroup label="🎪 Events">
                            <option value="Event Information Error">Event Information Error</option>
                            <option value="Event Cancellation Complaint">Event Cancellation Complaint</option>
                        </optgroup>

                        <optgroup label="👤 Account &amp; Technical">
                            <option value="Account Login Problem">Account Login Problem</option>
                            <option value="Profile / Registration Problem">Profile / Registration Problem</option>
                            <option value="Website Technical Issue">Website Technical Issue</option>
                        </optgroup>

                        <optgroup label="💬 General">
                            <option value="General Inquiry">General Inquiry</option>
                            <option value="Other">Other</option>
                        </optgroup>
                    </select>

                    <div class="routing-hint" id="routingHint" style="display:none;">
                        <i class="fas fa-arrow-right" style="font-size:.7rem;"></i>
                        Will be routed to:
                        <span class="chip" id="routingLabel"></span>
                    </div>
                </div>

                <div class="form-group">
                    <label>Subject <span class="req">*</span></label>
                    <input type="text" name="subject" placeholder="Brief title of your issue" required maxlength="255" />
                </div>

                <div class="form-group">
                    <label>Description <span class="req">*</span></label>
                    <textarea name="description" placeholder="Please describe your issue in detail — what happened, when, and any steps you have already tried." required></textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Booking ID <span class="optional-text">(optional)</span></label>
                        <input type="number" name="bookingId" placeholder="e.g. 1042" min="1" />
                    </div>

                    <div class="form-group">
                        <label>Ticket ID <span class="optional-text">(optional)</span></label>
                        <input type="number" name="ticketId" placeholder="e.g. 5821" min="1" />
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Your Email <span class="req">*</span></label>
                        <input type="email"
                               name="customerEmail"
                               placeholder="you@email.com"
                               required
                               value="${sessionScope.user != null ? sessionScope.user.email : ''}" />
                    </div>

                    <div class="form-group">
                        <label>Phone Number <span class="optional-text">(optional)</span></label>
                        <input type="tel" name="customerPhone" placeholder="+94 7X XXX XXXX" />
                    </div>
                </div>

                <div class="form-group">
                    <label>Priority</label>

                    <input type="hidden" name="priority" id="priorityInput" value="MEDIUM" />

                    <div class="priority-group">
                        <button type="button" class="priority-btn" data-val="LOW" onclick="setPriority(this)">
                            🟢 Low
                        </button>

                        <button type="button" class="priority-btn selected-medium" data-val="MEDIUM" onclick="setPriority(this)" id="defaultPriority">
                            🟡 Medium
                        </button>

                        <button type="button" class="priority-btn" data-val="HIGH" onclick="setPriority(this)">
                            🔴 High
                        </button>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fas fa-paper-plane"></i>
                    Submit Issue
                </button>
            </form>
        </div>

        <div class="card" id="my-issues" style="margin-top:18px;">
            <div class="card-title">
                <i class="fas fa-bell"></i>
                My Issue Notifications
            </div>

            <c:choose>
                <c:when test="${not empty myIssues}">
                    <div class="issue-list">
                        <c:forEach var="issue" items="${myIssues}">
                            <a href="${pageContext.request.contextPath}/IssueServlet?action=myIssueDetail&id=${issue.issueId}"
                               class="issue-notification-card">

                                <div class="issue-notification-top">
                                    <div>
                                        <div class="issue-notification-title">
                                            #${issue.issueId} — ${issue.subject}
                                        </div>

                                        <div class="issue-notification-category">
                                            ${issue.category}
                                        </div>
                                    </div>

                                    <div class="issue-actions">
                                        <span class="chip">${issue.status}</span>
                                        <span class="view-message-text">View Messages</span>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="empty-notification">
                        No issue notifications yet. When admins reply to your support requests, they will appear here.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="contact-section">

        <div class="contact-card">
            <h3>
                <i class="fas fa-address-book"></i>
                Authority Contacts
            </h3>

            <div class="contact-item">
                <div class="contact-icon">
                    <i class="fas fa-phone"></i>
                </div>

                <div class="contact-info">
                    <small>Support Hotline</small>
                    <a href="tel:+94711234567">+94 71 123 4567</a>
                </div>
            </div>

            <div class="contact-item">
                <div class="contact-icon">
                    <i class="fas fa-envelope"></i>
                </div>

                <div class="contact-info">
                    <small>General Support</small>
                    <a href="mailto:support@eventhorizon.lk">support@eventhorizon.lk</a>
                </div>
            </div>

            <div class="contact-item">
                <div class="contact-icon">
                    <i class="fas fa-ticket-alt"></i>
                </div>

                <div class="contact-info">
                    <small>Booking Support</small>
                    <a href="mailto:bookings@eventhorizon.lk">bookings@eventhorizon.lk</a>
                </div>
            </div>

            <div class="contact-item">
                <div class="contact-icon">
                    <i class="fas fa-calendar-days"></i>
                </div>

                <div class="contact-info">
                    <small>Events Support</small>
                    <a href="mailto:events@eventhorizon.lk">events@eventhorizon.lk</a>
                </div>
            </div>

            <div class="contact-item">
                <div class="contact-icon">
                    <i class="fas fa-clock"></i>
                </div>

                <div class="contact-info">
                    <small>Support Hours</small>
                    <span>Mon – Sat, 8:00 AM – 8:00 PM</span>
                </div>
            </div>
        </div>

        <div class="emergency-card">
            <h3>
                <i class="fas fa-exclamation-triangle"></i>
                Emergency Support
            </h3>

            <div class="contact-item" style="border-color:rgba(162,58,39,0.18);">
                <div class="contact-icon" style="background:var(--danger-bg);color:var(--danger-text);border-color:rgba(162,58,39,0.18);">
                    <i class="fas fa-phone-alt"></i>
                </div>

                <div class="contact-info">
                    <small>24/7 Emergency Line</small>
                    <a href="tel:+94777654321" style="color:var(--danger-text);">+94 77 765 4321</a>
                </div>
            </div>

            <p class="emergency-note">
                Use the emergency line only for <strong>event-day critical issues</strong> such as venue access, immediate safety concerns, or event cancellations.
            </p>
        </div>

        <div class="contact-card">
            <h3>
                <i class="fas fa-route"></i>
                How We Route Issues
            </h3>

            <div class="cat-guide">
                <div class="cat-row">
                    <div class="cat-dot"></div>
                    <div>
                        <strong>Bookings Team</strong> — Payments, tickets, refunds, QR codes
                    </div>
                </div>

                <div class="cat-row">
                    <div class="cat-dot"></div>
                    <div>
                        <strong>Events Team</strong> — Event info, venue, cancellations
                    </div>
                </div>

                <div class="cat-row">
                    <div class="cat-dot"></div>
                    <div>
                        <strong>Core Admin</strong> — Account, login, technical, general
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<footer>
    &copy; 2025 EventHorizon. All rights reserved.
    &nbsp;|&nbsp;
    <a href="${pageContext.request.contextPath}/faq.jsp">FAQ</a>
    &nbsp;|&nbsp;
    <a href="${pageContext.request.contextPath}/ticketPolicy.jsp">Ticket Policy</a>
</footer>

<script>
    const btns = document.querySelectorAll('.priority-btn');

    function setPriority(btn) {
        btns.forEach(function (b) {
            b.className = 'priority-btn';
        });

        const val = btn.dataset.val;

        btn.classList.add('selected-' + val.toLowerCase());
        document.getElementById('priorityInput').value = val;
    }

    const routingMap = {
        "Booking Problem": "Bookings Team",
        "Payment Verification Issue": "Bookings Team",
        "Ticket Not Received": "Bookings Team",
        "QR Code Not Working": "Bookings Team",
        "Refund Request": "Bookings Team",
        "Seat Availability Problem": "Bookings Team",
        "Event Information Error": "Events Team",
        "Event Cancellation Complaint": "Events Team",
        "Account Login Problem": "Core Admin",
        "Profile / Registration Problem": "Core Admin",
        "Website Technical Issue": "Core Admin",
        "General Inquiry": "Core Admin",
        "Other": "Core Admin"
    };

    function updateRouting() {
        const cat = document.getElementById('categorySelect').value;
        const hint = document.getElementById('routingHint');
        const label = document.getElementById('routingLabel');

        if (cat && routingMap[cat]) {
            label.textContent = routingMap[cat];
            hint.style.display = 'flex';
        } else {
            hint.style.display = 'none';
        }
    }
</script>

</body>
</html>