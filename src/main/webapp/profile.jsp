<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.eventhorizon.service.IssueService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String role = (String) session.getAttribute("role");

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
    <title>My Profile – EventHorizon</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
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

        /* ================= PROFILE PAGE ================= */

        .profile-shell {
            width: min(92%, 760px);
            margin: 0 auto;
            padding: 42px 0 70px;
        }

        .page-title {
            color: var(--forest-dark);
            font-size: clamp(2rem, 4vw, 2.6rem);
            font-weight: 900;
            letter-spacing: -0.05em;
            line-height: 1.1;
            margin-bottom: 28px;
            text-align: center;
        }

        .profile-card {
            background: #ffffff;
            border: 2px solid rgba(30, 74, 58, 0.20);
            border-radius: 28px;
            padding: 34px;
            box-shadow: var(--shadow-premium);
            color: var(--text);
        }

        .profile-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .profile-avatar {
            width: 86px;
            height: 86px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            color: #ffffff;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            margin-bottom: 14px;
            box-shadow: 0 16px 34px rgba(30, 74, 58, 0.24);
        }

        .profile-avatar i {
            color: #ffffff;
        }

        .profile-name {
            color: var(--forest-dark);
            font-size: 1.22rem;
            font-weight: 900;
            margin-bottom: 4px;
        }

        .profile-email {
            color: var(--text-soft);
            font-size: 0.9rem;
            font-weight: 650;
            margin-bottom: 10px;
        }

        .role-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #ffffff;
            color: var(--forest-dark);
            border: 1px solid var(--border-strong);
            border-radius: 999px;
            padding: 7px 14px;
            font-size: 0.74rem;
            font-weight: 900;
            letter-spacing: 0.6px;
            text-transform: uppercase;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            color: var(--forest-dark);
            font-size: 0.78rem;
            font-weight: 900;
            letter-spacing: 0.7px;
            text-transform: uppercase;
            margin-bottom: 9px;
        }

        .form-control {
            width: 100%;
            min-height: 48px;
            border-radius: 14px;
            border: 1px solid var(--border-strong);
            background: #ffffff;
            color: var(--text);
            padding: 12px 15px;
            font-size: 0.95rem;
            font-weight: 700;
            outline: none;
            transition: 0.2s ease;
        }

        .form-control:focus {
            border-color: rgba(30, 74, 58, 0.52);
            box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.10);
        }

        .form-control::placeholder {
            color: #7E9086;
            font-weight: 600;
        }

        .btn {
            min-height: 48px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            border-radius: 14px;
            padding: 13px 20px;
            border: none;
            font-size: 0.92rem;
            font-weight: 900;
            cursor: pointer;
            transition: 0.22s ease;
            text-decoration: none;
            font-family: inherit;
        }

        .btn:hover {
            transform: translateY(-1px);
        }

        .btn-block {
            width: 100%;
        }

        .btn-primary {
            color: #ffffff;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
        }

        .btn-primary:hover {
            box-shadow: 0 18px 42px rgba(30, 74, 58, 0.30);
        }

        .btn-outline {
            color: var(--forest-dark);
            background: #ffffff;
            border: 2px solid rgba(30, 74, 58, 0.28);
            box-shadow: none;
        }

        .btn-outline:hover {
            background: var(--forest-soft);
            border-color: rgba(30, 74, 58, 0.44);
        }

        .danger-zone {
            margin-top: 24px;
            background: #ffffff;
            border: 2px solid rgba(162, 58, 39, 0.22);
            border-radius: 24px;
            padding: 26px;
            box-shadow: 0 18px 45px rgba(162, 58, 39, 0.07);
        }

        .danger-zone h3 {
            margin: 0 0 10px 0;
            color: var(--danger-text);
            font-size: 1.15rem;
            font-weight: 900;
        }

        .danger-zone p {
            margin: 0 0 18px 0;
            color: var(--text-soft);
            line-height: 1.7;
            font-weight: 650;
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

        .profile-bottom-action {
            text-align: center;
            margin-top: 24px;
        }

        /* ================= ALERTS ================= */

        .alert {
            border-radius: 14px;
            padding: 14px 16px;
            margin-bottom: 18px;
            font-size: 0.9rem;
            font-weight: 800;
            line-height: 1.5;
        }

        .alert-success {
            background: var(--success-bg);
            color: var(--success-text);
            border: 1px solid rgba(23, 107, 59, 0.22);
        }

        .alert-danger {
            background: var(--danger-bg);
            color: var(--danger-text);
            border: 1px solid rgba(162, 58, 39, 0.22);
        }

        /* ================= FOOTER ================= */

        .eh-container {
            width: min(92%, 1240px);
            margin: 0 auto;
        }

        .eh-footer {
            position: relative;
            overflow: hidden;
            background: linear-gradient(180deg, #FAF8F4 0%, #F1EBDD 100%);
            color: var(--muted);
            border-top: 1px solid var(--border);
        }

        .eh-footer::before {
            content: "";
            position: absolute;
            inset: 0;
            z-index: 0;
            pointer-events: none;
            background-image:
                radial-gradient(circle at 18% 18%, rgba(30, 74, 58, 0.14), transparent 24%),
                radial-gradient(circle at 82% 12%, rgba(176, 141, 101, 0.16), transparent 26%),
                repeating-linear-gradient(45deg, rgba(30, 74, 58, 0.055) 0px, rgba(30, 74, 58, 0.055) 1px, transparent 1px, transparent 18px),
                repeating-linear-gradient(-45deg, rgba(176, 141, 101, 0.050) 0px, rgba(176, 141, 101, 0.050) 1px, transparent 1px, transparent 22px),
                radial-gradient(circle at 1px 1px, rgba(30, 74, 58, 0.16) 1.15px, transparent 1.35px);
            background-size: 100% 100%, 100% 100%, 42px 42px, 52px 52px, 28px 28px;
            opacity: 0.95;
        }

        .eh-footer > * {
            position: relative;
            z-index: 2;
        }

        .eh-footer-grid {
            display: grid;
            grid-template-columns: 1.5fr 1fr 1fr 1fr;
            gap: 48px;
            padding: 70px 0 56px;
        }

        .eh-footer-brand {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 18px;
        }

        .eh-footer-brand-mark {
            width: 40px;
            height: 40px;
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.22);
            flex-shrink: 0;
        }

        .eh-footer-brand-mark i {
            color: #ffffff;
        }

        .eh-footer-logo {
            margin: 0;
            color: var(--forest-dark);
            font-size: 1.3rem;
            font-weight: 900;
            letter-spacing: 2px;
        }

        .eh-footer-logo span {
            color: var(--forest);
        }

        .eh-footer-text {
            max-width: 320px;
            color: var(--muted);
            font-size: 0.9rem;
            font-weight: 550;
            line-height: 1.8;
        }

        .eh-footer-col h4 {
            margin-bottom: 20px;
            color: var(--forest-dark);
            font-size: 0.74rem;
            font-weight: 900;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        .eh-footer-col ul {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 11px;
        }

        .eh-footer-col ul li a {
            color: var(--muted);
            font-size: 0.9rem;
            font-weight: 650;
            transition: 0.2s ease;
        }

        .eh-footer-col ul li a:hover {
            color: var(--forest);
        }

        .eh-footer-bottom {
            border-top: 1px solid var(--border);
            background: rgba(255, 255, 255, 0.52);
        }

        .eh-footer-bottom-inner {
            min-height: 62px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            color: var(--muted);
            font-size: 0.82rem;
            font-weight: 650;
        }

        /* ================= RESPONSIVE ================= */

        @media (max-width: 1100px) {
            .eh-footer-grid {
                grid-template-columns: 1fr 1fr;
            }
        }

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
            .profile-shell {
                width: 94%;
                padding-top: 32px;
            }

            .profile-card,
            .danger-zone {
                padding: 24px;
            }

            .eh-footer-grid {
                grid-template-columns: 1fr;
                gap: 32px;
            }

            .eh-footer-bottom-inner {
                flex-direction: column;
                justify-content: center;
                text-align: center;
                padding: 18px 0;
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

            .page-title {
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
                    <a href="${pageContext.request.contextPath}/profile.jsp" class="eh-nav-link active">
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
                    <a href="${pageContext.request.contextPath}/profile.jsp" class="eh-nav-link active">
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

<main class="profile-shell">
    <h1 class="page-title">
        <i class="fa-regular fa-user"></i>
        My Profile
    </h1>

    <c:if test="${param.msg == 'updated'}">
        <div class="alert alert-success" data-auto-dismiss>
            ✅ Profile updated successfully.
        </div>
    </c:if>

    <c:if test="${param.error == 'updateFailed'}">
        <div class="alert alert-danger" data-auto-dismiss>
            ❌ Update failed. Please try again.
        </div>
    </c:if>

    <c:if test="${param.error == 'deleteFailed'}">
        <div class="alert alert-danger" data-auto-dismiss>
            ❌ Account deletion failed. Please try again.
        </div>
    </c:if>

    <c:if test="${param.error == 'notAllowed'}">
        <div class="alert alert-danger" data-auto-dismiss>
            ❌ You are not allowed to perform that action.
        </div>
    </c:if>

    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <i class="fa-regular fa-user"></i>
            </div>

            <div class="profile-name">
                ${sessionScope.userName}
            </div>

            <div class="profile-email">
                ${sessionScope.userEmail}
            </div>

            <span class="role-badge">
                ${sessionScope.role}
            </span>
        </div>

        <form action="${pageContext.request.contextPath}/user" method="post" class="needs-validation">
            <input type="hidden" name="action" value="update">

            <div class="form-group">
                <label class="form-label" for="name">Full Name</label>

                <input type="text"
                       id="name"
                       name="name"
                       class="form-control"
                       value="${sessionScope.userName}"
                       required>
            </div>

            <div class="form-group">
                <label class="form-label" for="phone">Phone Number</label>

                <input type="tel"
                       id="phone"
                       name="phone"
                       class="form-control"
                       value="${sessionScope.userPhone}"
                       placeholder="07X XXX XXXX"
                       required>
            </div>

            <div class="form-group">
                <label class="form-label" for="password">New Password</label>

                <input type="password"
                       id="password"
                       name="password"
                       class="form-control"
                       placeholder="Enter a new password">
            </div>

            <button type="submit" class="btn btn-primary btn-block">
                <i class="fa-solid fa-floppy-disk"></i>
                Save Changes
            </button>
        </form>
    </div>

    <% if ("CUSTOMER".equals(role)) { %>
        <div class="danger-zone">
            <h3>
                <i class="fa-solid fa-triangle-exclamation"></i>
                Delete My Account
            </h3>

            <p>
                This action is permanent. Your account and related booking records may be removed and cannot be recovered.
            </p>

            <form action="${pageContext.request.contextPath}/user" method="post"
                  onsubmit="return confirm('Are you sure you want to delete your account? This action cannot be undone.');">
                <input type="hidden" name="action" value="selfDelete">

                <button type="submit" class="btn btn-danger">
                    <i class="fa-solid fa-trash"></i>
                    Delete My Account
                </button>
            </form>
        </div>
    <% } %>

    <div class="profile-bottom-action">
        <% if ("CUSTOMER".equals(role)) { %>
            <% if (ehCustomerLogged) { %>
                <a href="${pageContext.request.contextPath}/booking?action=myBookings" class="btn btn-outline">
                    <i class="fa-solid fa-ticket"></i>
                    View My Bookings
                </a>
            <% } %>
        <% } else if ("ADMIN".equals(role)) { %>
            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline">
                <i class="fa-solid fa-gauge-high"></i>
                Go to Dashboard
            </a>
        <% } %>
    </div>
</main>

<footer class="eh-footer">
    <div class="eh-container eh-footer-grid">
        <div class="eh-footer-col">
            <div class="eh-footer-brand">
                <span class="eh-footer-brand-mark">
                    <i class="fa-solid fa-leaf"></i>
                </span>

                <h2 class="eh-footer-logo">
                    EVENT<span>HORIZON</span>
                </h2>
            </div>

            <p class="eh-footer-text">
                EventHorizon helps you discover, explore, and book unforgettable
                experiences with a fast, secure, and modern platform.
            </p>
        </div>

        <div class="eh-footer-col">
            <h4>Quick Links</h4>

            <ul>
                <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                <li><a href="${pageContext.request.contextPath}/event?action=list">Events</a></li>

                <% if (ehCustomerLogged) { %>
                    <li><a href="${pageContext.request.contextPath}/booking?action=myBookings">My Bookings</a></li>
                <% } %>

                <% if (ehAdminLogged) { %>
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp">Dashboard</a></li>
                <% } %>

                <% if (ehCustomerLogged || ehAdminLogged) { %>
                    <li><a href="${pageContext.request.contextPath}/profile.jsp">Profile</a></li>
                <% } %>
            </ul>
        </div>

        <div class="eh-footer-col">
            <h4>Company</h4>

            <ul>
                <li><a href="${pageContext.request.contextPath}/aboutUs.jsp">About Us</a></li>
                <li><a href="${pageContext.request.contextPath}/contacts.jsp">Contact</a></li>
                <li><a href="${pageContext.request.contextPath}/privacyPolicy.jsp">Privacy Policy</a></li>
                <li><a href="${pageContext.request.contextPath}/termsConditions.jsp">Terms &amp; Conditions</a></li>
            </ul>
        </div>

        <div class="eh-footer-col">
            <h4>Support</h4>

            <ul>
                <li><a href="${pageContext.request.contextPath}/faqs.jsp">Help Center</a></li>
                <li><a href="${pageContext.request.contextPath}/faqs.jsp">FAQs</a></li>
                <li><a href="${pageContext.request.contextPath}/ticketPolicy.jsp">Ticket Policy</a></li>

                <% if (ehCustomerLogged || ehAdminLogged) { %>
                    <li><a href="${pageContext.request.contextPath}/IssueServlet?action=report">Report an Issue</a></li>
                <% } else { %>
                    <li><a href="${pageContext.request.contextPath}/contacts.jsp">Contact Support</a></li>
                <% } %>
            </ul>
        </div>
    </div>

    <div class="eh-footer-bottom">
        <div class="eh-container eh-footer-bottom-inner">
            <p>© 2026 EventHorizon. All rights reserved.</p>
            <p>Designed for modern event experiences.</p>
        </div>
    </div>
</footer>

<script src="${pageContext.request.contextPath}/js/main.js"></script>

</body>
</html>