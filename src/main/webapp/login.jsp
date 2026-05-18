<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login – EventHorizon</title>

<!-- Do not link old css/style.css here because it may bring old dark/purple styles -->

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

        --info-bg: #E8F1EC;
        --info-text: #123528;

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

    /* ================= SAME NAVBAR AS PROFILE PAGE ================= */

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

    .eh-nav-btn-outline {
        color: var(--forest-dark);
        background: #ffffff;
        border-color: var(--border-strong);
    }

    .eh-nav-btn-outline:hover,
    .eh-nav-btn-outline.active {
        background: var(--forest-soft);
        border-color: rgba(30, 74, 58, 0.45);
    }

    /* ================= AUTH PAGE ================= */

    .auth-wrapper {
        width: 100%;
        min-height: calc(100vh - 76px);
        padding: 64px 20px 80px;
        display: flex;
        align-items: flex-start;
        justify-content: center;
    }

    .auth-card {
        width: min(100%, 470px);
        background: #ffffff;
        border: 2px solid rgba(30, 74, 58, 0.20);
        border-radius: 30px;
        padding: 42px;
        box-shadow: var(--shadow-premium);
        color: var(--text);
        position: relative;
        overflow: hidden;
    }

    .auth-card::before {
        content: "";
        position: absolute;
        inset: 0 0 auto 0;
        height: 6px;
        background: linear-gradient(90deg, var(--forest), var(--sage));
    }

    .auth-logo {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 12px;
        color: var(--forest-dark);
        font-weight: 900;
        letter-spacing: 1.8px;
        text-transform: uppercase;
        margin-bottom: 8px;
    }

    .auth-brand-mark {
        width: 44px;
        height: 44px;
        border-radius: 15px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: #ffffff;
        background: linear-gradient(135deg, var(--forest), var(--forest-dark));
        box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
        flex-shrink: 0;
    }

    .auth-brand-mark i {
        color: #ffffff;
    }

    .auth-title {
        color: var(--forest-dark);
        text-align: center;
        font-size: clamp(1.7rem, 4vw, 2.15rem);
        font-weight: 900;
        letter-spacing: -0.05em;
        margin-top: 18px;
        margin-bottom: 6px;
    }

    .auth-title i {
        color: var(--forest);
    }

    .auth-subtitle {
        color: var(--text-soft);
        text-align: center;
        font-size: 0.95rem;
        font-weight: 650;
        margin-bottom: 28px;
    }

    .form-group {
        margin-bottom: 19px;
    }

    .form-label {
        display: flex;
        align-items: center;
        gap: 8px;
        color: var(--forest-dark);
        font-size: 0.78rem;
        font-weight: 900;
        letter-spacing: 0.7px;
        text-transform: uppercase;
        margin-bottom: 9px;
    }

    .form-label i {
        color: var(--forest);
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

    .auth-link-row {
        text-align: center;
        margin-top: 24px;
        color: var(--text-soft);
        font-size: 0.9rem;
        font-weight: 650;
    }

    .auth-link-row a {
        color: var(--forest-dark);
        font-weight: 900;
    }

    .auth-link-row a:hover {
        text-decoration: underline;
    }

    .back-home {
        text-align: center;
        margin-top: 10px;
    }

    .back-home a {
        color: var(--text-soft);
        font-size: 0.85rem;
        font-weight: 750;
    }

    .back-home a:hover {
        color: var(--forest-dark);
    }

    .alert {
        border-radius: 14px;
        padding: 14px 16px;
        margin-bottom: 18px;
        font-size: 0.9rem;
        font-weight: 800;
        line-height: 1.5;
        display: flex;
        align-items: flex-start;
        gap: 10px;
    }

    .alert i {
        margin-top: 2px;
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

    .alert-info {
        background: var(--info-bg);
        color: var(--info-text);
        border: 1px solid var(--border-strong);
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

    @media (max-width: 560px) {
        .auth-wrapper {
            padding: 34px 14px 60px;
        }

        .auth-card {
            padding: 32px 22px;
            border-radius: 24px;
        }

        .eh-nav-link span,
        .eh-nav-btn-outline span {
            display: none;
        }

        .eh-nav-link,
        .eh-nav-btn-outline {
            width: 42px;
            padding: 0;
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

        <li>
            <a href="${pageContext.request.contextPath}/login.jsp" class="eh-nav-link active">
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
    </ul>
</div>


</nav>

<div class="auth-wrapper">
    <div class="auth-card">


    <div class="auth-logo">
        <span class="auth-brand-mark">
            <i class="fa-solid fa-leaf"></i>
        </span>
        <span>EVENTHORIZON</span>
    </div>

    <h1 class="auth-title">
        <i class="fa-solid fa-right-to-bracket"></i>
        Welcome Back
    </h1>

    <p class="auth-subtitle">Sign in to your account</p>

    <% if ("invalid".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger" data-auto-dismiss>
            <i class="fa-solid fa-circle-xmark"></i>
            <span>Invalid email or password.</span>
        </div>
    <% } %>

    <% if ("notVerified".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger" data-auto-dismiss>
            <i class="fa-solid fa-triangle-exclamation"></i>
            <span>Please verify your email before logging in.</span>
        </div>
    <% } %>

    <% if ("invalidToken".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger" data-auto-dismiss>
            <i class="fa-solid fa-link-slash"></i>
            <span>Verification link is invalid or expired.</span>
        </div>
    <% } %>

    <% if ("emailSendFailed".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger" data-auto-dismiss>
            <i class="fa-solid fa-envelope-circle-check"></i>
            <span>Account created, but email could not be sent.</span>
        </div>
    <% } %>

    <% if ("registered".equals(request.getParameter("msg"))) { %>
        <div class="alert alert-success" data-auto-dismiss>
            <i class="fa-solid fa-circle-check"></i>
            <span>Account created successfully. Please log in.</span>
        </div>
    <% } %>

    <% if ("checkEmail".equals(request.getParameter("msg"))) { %>
        <div class="alert alert-info" data-auto-dismiss>
            <i class="fa-solid fa-envelope"></i>
            <span>Registration successful. Check your email to verify your account.</span>
        </div>
    <% } %>

    <% if ("verified".equals(request.getParameter("msg"))) { %>
        <div class="alert alert-success" data-auto-dismiss>
            <i class="fa-solid fa-circle-check"></i>
            <span>Email verified successfully. You can now log in.</span>
        </div>
    <% } %>

    <% if ("logout".equals(request.getParameter("msg"))) { %>
        <div class="alert alert-info" data-auto-dismiss>
            <i class="fa-solid fa-right-from-bracket"></i>
            <span>You have been logged out.</span>
        </div>
    <% } %>

    <% if ("notAllowed".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger" data-auto-dismiss>
            <i class="fa-solid fa-ban"></i>
            <span>That action is not allowed.</span>
        </div>
    <% } %>

    <form action="${pageContext.request.contextPath}/user" method="post" class="needs-validation">
        <input type="hidden" name="action" value="login">

        <div class="form-group">
            <label class="form-label" for="email">
                <i class="fa-solid fa-envelope"></i>
                Email Address
            </label>

            <input type="email"
                   id="email"
                   name="email"
                   class="form-control"
                   placeholder="you@example.com"
                   required>
        </div>

        <div class="form-group">
            <label class="form-label" for="password">
                <i class="fa-solid fa-lock"></i>
                Password
            </label>

            <input type="password"
                   id="password"
                   name="password"
                   class="form-control"
                   placeholder="Enter your password"
                   required>
        </div>

        <button type="submit" class="btn btn-primary btn-block" style="margin-top:8px;">
            <i class="fa-solid fa-arrow-right-to-bracket"></i>
            Sign In
        </button>
    </form>

    <p class="auth-link-row">
        Don't have an account?
        <a href="${pageContext.request.contextPath}/register.jsp">Sign up</a>
    </p>

    <p class="back-home">
        <a href="${pageContext.request.contextPath}/index.jsp">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Home
        </a>
    </p>
</div>


</div>

<script src="${pageContext.request.contextPath}/js/main.js"></script>

</body>
</html>
