<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
                ehNavIssueCount = new IssueService()
                        .countIssuesWithRepliesByUser(Integer.parseInt(numericPart));
            }
        } catch (Exception ignored) {
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FAQs | EventHorizon</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,600..900,40,0..1&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

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
            --text-soft: #52635A;
            --muted: #7C8A82;
            --border: rgba(30, 74, 58, 0.14);
            --border-strong: rgba(30, 74, 58, 0.24);
            --shadow-soft: 0 18px 50px rgba(24, 37, 31, 0.09);
            --shadow-premium: 0 30px 90px rgba(24, 37, 31, 0.16);
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            position: relative;
            font-family: 'Inter', sans-serif;
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
            opacity: 0.70;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        .eh-container {
            width: min(92%, 1240px);
            margin: 0 auto;
        }

        .eh-navbar {
            position: sticky;
            top: 0;
            z-index: 1000;
            width: 100%;
            background: rgba(250, 248, 244, 0.94);
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
            background: rgba(255, 255, 255, 0.82);
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

        @media (max-width: 1100px) {
            .eh-footer-grid {
                grid-template-columns: 1fr 1fr;
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
        }


        .page-wrap {
            width: min(92%, 1180px);
            margin: 46px auto 72px;
        }

        .hero-card,
        .section-card,
        .contact-card,
        .faq-card,
        .policy-card {
            position: relative;
            overflow: hidden;
            background: rgba(255, 255, 255, 0.94);
            border: 1px solid var(--border);
            border-radius: 26px;
            box-shadow: var(--shadow-soft);
        }

        .hero-card {
            padding: 44px;
            margin-bottom: 24px;
            background:
                radial-gradient(circle at top left, rgba(30, 74, 58, 0.12), transparent 32%),
                linear-gradient(135deg, rgba(255,255,255,0.98), rgba(232,241,236,0.82));
        }

        .hero-badge,
        .policy-badge {
            width: fit-content;
            margin-bottom: 18px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 10px 18px;
            border-radius: 999px;
            color: var(--forest);
            background: var(--forest-soft);
            border: 1px solid var(--border-strong);
            font-size: 0.78rem;
            font-weight: 900;
            letter-spacing: 1.6px;
            text-transform: uppercase;
        }

        .hero-title {
            font-family: 'Fraunces', serif;
            color: var(--forest-dark);
            font-size: clamp(2.35rem, 4.4vw, 4.4rem);
            font-weight: 900;
            line-height: 1.02;
            letter-spacing: -1.7px;
            margin-bottom: 16px;
        }

        .hero-sub,
        .section-card p,
        .contact-card p,
        .faq-card p,
        .policy-card p,
        .policy-card li,
        .section-card li {
            color: var(--text-soft);
            font-size: 0.98rem;
            font-weight: 600;
            line-height: 1.85;
        }

        .highlight {
            color: var(--forest);
            font-weight: 900;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 22px;
        }

        .section-card,
        .contact-card,
        .faq-card,
        .policy-card {
            padding: 30px;
            margin-bottom: 22px;
        }

        .section-card.full {
            grid-column: 1 / -1;
        }

        .section-card h2,
        .contact-card h2,
        .faq-card h2,
        .policy-card h2 {
            display: flex;
            align-items: center;
            gap: 11px;
            color: var(--forest-dark);
            font-size: 1.35rem;
            font-weight: 900;
            letter-spacing: -0.4px;
            margin-bottom: 12px;
        }

        .section-card h2::before,
        .contact-card h2::before,
        .faq-card h2::before {
            content: "\f06c";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            width: 38px;
            height: 38px;
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: var(--forest);
            background: var(--forest-soft);
            border: 1px solid var(--border);
            flex-shrink: 0;
        }

        .section-card ul,
        .policy-card ul,
        .contact-list {
            margin-left: 22px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-top: 24px;
        }

        .stat-box {
            padding: 22px 16px;
            text-align: center;
            background: rgba(255, 255, 255, 0.74);
            border: 1px solid var(--border);
            border-radius: 20px;
        }

        .stat-icon {
            color: var(--forest);
            font-size: 1.45rem;
            margin-bottom: 10px;
        }

        .stat-number {
            color: var(--forest-dark);
            font-size: 1.5rem;
            font-weight: 900;
            margin-bottom: 4px;
        }

        .stat-label {
            color: var(--muted);
            font-size: 0.82rem;
            font-weight: 850;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .team-note,
        .notice-card {
            background: rgba(232, 241, 236, 0.78);
            border: 1px solid var(--border-strong);
            border-radius: 18px;
            padding: 18px;
            color: var(--forest-dark);
            line-height: 1.8;
            font-weight: 700;
        }

        .policy-card h2 i {
            width: 38px;
            height: 38px;
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: var(--forest);
            background: var(--forest-soft);
            border: 1px solid var(--border);
            flex-shrink: 0;
        }

        @media (max-width: 992px) {
            .grid,
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .hero-card,
            .section-card,
            .contact-card,
            .faq-card,
            .policy-card {
                padding: 24px;
            }
        }

    </style>

    <style>
        /* =========================================================
           EVENTHORIZON FINAL LIGHT THEME OVERRIDE
           Purpose: remove purple/dark theme, keep all text readable,
           and use the same green leaf brand icon style on every page.
        ========================================================= */
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
            --text-primary: #18251F;
            --text-soft: #52635A;
            --text-muted: #52635A;
            --muted: #7C8A82;
            --bg: #FAF8F4;
            --bg-card: #FFFFFF;
            --border: rgba(30, 74, 58, 0.14);
            --border-strong: rgba(30, 74, 58, 0.24);
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

        body,
        body.events-page,
        .auth-wrapper {
            background:
                radial-gradient(circle at top left, rgba(30, 74, 58, 0.08), transparent 32%),
                radial-gradient(circle at top right, rgba(176, 141, 101, 0.10), transparent 30%),
                linear-gradient(180deg, #ffffff 0%, var(--linen) 48%, #F7F3EA 100%) !important;
            color: var(--text) !important;
            font-family: 'Inter', 'Segoe UI', Arial, sans-serif !important;
            -webkit-font-smoothing: antialiased;
        }

        body::before,
        .auth-wrapper::before {
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
            opacity: 0.70;
        }

        /* ---------- Top navigation ---------- */
        .eh-navbar,
        .navbar {
            position: sticky !important;
            top: 0 !important;
            z-index: 1000 !important;
            width: 100% !important;
            background: rgba(250, 248, 244, 0.96) !important;
            border-bottom: 1px solid var(--border) !important;
            backdrop-filter: blur(18px) !important;
            -webkit-backdrop-filter: blur(18px) !important;
            box-shadow: 0 10px 28px rgba(24, 37, 31, 0.05) !important;
        }

        .eh-navbar-inner {
            min-height: 76px !important;
        }

        .eh-navbar-inner {
            width: min(92%, 1240px) !important;
            margin: 0 auto !important;
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;
            gap: 18px !important;
        }

        .eh-brand {
            display: inline-flex !important;
            align-items: center !important;
            gap: 12px !important;
        }

        .eh-brand-text {
            font-size: 1.08rem !important;
        }

        .navbar {
            padding: 0 40px !important;
            min-height: 76px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;
            gap: 18px !important;
        }

        .eh-brand,
        .brand,
        .navbar-brand,
        .auth-logo,
        .footer-brand,
        .mini-footer-brand {
            color: var(--forest-dark) !important;
            font-weight: 900 !important;
            letter-spacing: 1.8px !important;
            text-transform: uppercase !important;
            text-decoration: none !important;
        }

        .eh-brand-mark,
        .eh-icon-mark,
        .mini-footer-icon {
            width: 42px !important;
            height: 42px !important;
            border-radius: 14px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            color: #ffffff !important;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark)) !important;
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24) !important;
            flex-shrink: 0 !important;
        }

        .eh-brand i.fa-hexagon,
        .fa-hexagon {
            display: none !important;
        }

        .navbar .brand,
        .navbar-brand,
        .auth-logo,
        .footer-brand {
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 12px !important;
        }

        .navbar .brand::before,
        .navbar-brand::before,
        .auth-logo::before,
        .footer-brand::before {
            content: "\f06c";
            width: 42px;
            height: 42px;
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            font-size: 1rem;
            letter-spacing: 0;
        }

        .eh-nav-links,
        .nav-links,
        .navbar-links {
            display: flex !important;
            align-items: center !important;
            justify-content: flex-end !important;
            gap: 8px !important;
            flex-wrap: wrap !important;
            list-style: none !important;
            margin: 0 !important;
            padding: 0 !important;
        }

        .eh-nav-link,
        .eh-nav-bell,
        .eh-nav-btn,
        .eh-nav-btn-outline,
        .nav-links a,
        .navbar-links a,
        .btn-nav {
            min-height: 42px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 8px !important;
            padding: 10px 15px !important;
            border-radius: 13px !important;
            border: 1px solid transparent !important;
            font-size: 0.88rem !important;
            font-weight: 800 !important;
            color: var(--text-soft) !important;
            background: transparent !important;
            transition: 0.22s ease !important;
            white-space: nowrap !important;
            text-decoration: none !important;
        }

        .eh-nav-link:hover,
        .eh-nav-link.active,
        .nav-links a:hover,
        .nav-links a.active,
        .navbar-links a:hover,
        .navbar-links a.active {
            color: var(--forest) !important;
            background: var(--forest-soft) !important;
            border-color: var(--border) !important;
        }

        .eh-nav-btn,
        .eh-nav-btn-outline,
        .btn-nav,
        .nav-links a.btn-nav,
        .navbar-links a.btn-nav {
            color: #ffffff !important;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark)) !important;
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24) !important;
        }

        .eh-nav-bell {
            position: relative !important;
            width: 44px !important;
            padding: 0 !important;
            background: rgba(255, 255, 255, 0.86) !important;
            border-color: var(--border) !important;
        }

        .eh-bell-badge {
            background: linear-gradient(135deg, #D94B32, #F08A4C) !important;
            color: #ffffff !important;
        }

        /* ---------- Cards, panels, forms ---------- */
        .auth-card,
        .card,
        .hero-card,
        .section-card,
        .stat-box,
        .team-note,
        .booking-card,
        .summary,
        .checkout-card,
        .ticket-card,
        .profile-card,
        .content-card,
        .info-card,
        .contact-card,
        .faq-card,
        .policy-card,
        .terms-card,
        .support-card,
        .empty-state,
        .event-meta-item,
        .event-detail-hero,
        .mini-ticket,
        .ticket-box,
        .verify-card,
        .details-card,
        .panel,
        .box {
            background: rgba(255, 255, 255, 0.96) !important;
            color: var(--text) !important;
            border: 1px solid var(--border) !important;
            box-shadow: var(--shadow-soft) !important;
        }

        .auth-wrapper {
            min-height: calc(100vh - 76px) !important;
            padding: 82px 20px !important;
            display: flex !important;
            align-items: flex-start !important;
            justify-content: center !important;
        }

        .auth-card {
            border-radius: 28px !important;
            max-width: 460px !important;
            width: min(100%, 460px) !important;
            padding: 42px !important;
        }

        .search-panel {
            background: rgba(255, 255, 255, 0.96) !important;
            border: 1px solid var(--border) !important;
            box-shadow: var(--shadow-premium) !important;
        }

        .search-panel::before,
        .events-hero::before {
            background: radial-gradient(circle, rgba(30, 74, 58, 0.12) 0%, rgba(176, 141, 101, 0.08) 38%, transparent 74%) !important;
        }

        input,
        select,
        textarea,
        .form-control,
        .search-input,
        .search-select {
            background: #ffffff !important;
            color: var(--text) !important;
            border: 1px solid var(--border-strong) !important;
            box-shadow: none !important;
        }

        input::placeholder,
        textarea::placeholder,
        .search-input::placeholder {
            color: #7E8F86 !important;
        }

        .search-select option {
            background: #ffffff !important;
            color: var(--text) !important;
        }

        input:focus,
        select:focus,
        textarea:focus,
        .form-control:focus,
        .search-input:focus,
        .search-select:focus {
            border-color: rgba(30, 74, 58, 0.46) !important;
            box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.10) !important;
        }

        .btn,
        .btn-primary,
        .btn-block,
        .search-btn,
        button[type="submit"],
        .button-primary,
        .submit-btn {
            color: #ffffff !important;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark)) !important;
            border-color: transparent !important;
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24) !important;
            font-weight: 900 !important;
        }

        .btn:hover,
        .btn-primary:hover,
        .search-btn:hover,
        button[type="submit"]:hover {
            transform: translateY(-1px);
            box-shadow: 0 18px 42px rgba(30, 74, 58, 0.30) !important;
        }

        .btn-secondary,
        .btn-outline,
        .button-secondary {
            color: var(--forest) !important;
            background: var(--forest-soft) !important;
            border: 1px solid var(--border-strong) !important;
            box-shadow: none !important;
        }

        /* ---------- Text readability ---------- */
        h1,
        h2,
        h3,
        h4,
        h5,
        h6,
        .hero-title,
        .section-title,
        .section-title span,
        .card-title,
        .page-title,
        .event-detail-title,
        .summary-title,
        .booking-price,
        .total-amount,
        .price,
        .stat-number,
        .auth-logo {
            color: var(--forest-dark) !important;
            text-shadow: none !important;
        }

        p,
        li,
        label,
        .hero-sub,
        .section-card p,
        .section-card ul,
        .section-subtitle,
        .card-meta,
        .card-meta span,
        .card-body p,
        .filter-summary,
        .auth-subtitle,
        .stat-label,
        .footer,
        .mini-footer-text,
        .eh-footer-text,
        .s-label,
        .s-value,
        .breadcrumb,
        .breadcrumb a {
            color: var(--text-soft) !important;
        }

        strong,
        .highlight,
        .filter-summary strong,
        .clear-link,
        .footer strong {
            color: var(--forest) !important;
        }

        .card-category,
        .hero-badge,
        .type-badge,
        .badge,
        .badge-purple {
            background: var(--forest-soft) !important;
            color: var(--forest) !important;
            border: 1px solid var(--border-strong) !important;
            box-shadow: none !important;
        }

        .stat-icon,
        .event-detail-icon,
        .empty-state .emoji,
        .mini-footer-icon i,
        .card-meta i,
        .search-btn i,
        .footer-brand i {
            color: var(--forest) !important;
        }

        .event-detail-icon {
            background: var(--forest-soft) !important;
            border: 1px solid var(--border) !important;
        }

        .events-grid .card {
            background: rgba(255, 255, 255, 0.96) !important;
            border-color: var(--border) !important;
            box-shadow: var(--shadow-soft) !important;
        }

        .events-grid .card::before {
            background: linear-gradient(180deg, rgba(30, 74, 58, 0.04), transparent) !important;
        }

        .card-footer,
        .footer,
        .mini-footer,
        .eh-footer,
        .eh-footer-bottom {
            background: rgba(250, 248, 244, 0.94) !important;
            color: var(--text-soft) !important;
            border-color: var(--border) !important;
        }

        .seats-bar,
        .progress,
        .progress-bar-bg {
            background: #E2E8E3 !important;
        }

        .seats-bar-fill,
        .progress-bar,
        .progress-fill {
            background: linear-gradient(90deg, var(--forest), var(--sage)) !important;
        }

        .alert,
        .alert-info {
            background: var(--forest-soft) !important;
            color: var(--forest-dark) !important;
            border: 1px solid var(--border-strong) !important;
        }

        .alert-danger,
        .alert-error {
            background: #FFF0EC !important;
            color: #A23A27 !important;
            border: 1px solid rgba(162, 58, 39, 0.22) !important;
        }

        .alert-success {
            background: #E8F6EE !important;
            color: #176B3B !important;
            border: 1px solid rgba(23, 107, 59, 0.22) !important;
        }

        .alert-warning {
            background: #FFF7E3 !important;
            color: #8A5A00 !important;
            border: 1px solid rgba(138, 90, 0, 0.22) !important;
        }

        @media (max-width: 768px) {
            .navbar,
            .eh-navbar-inner {
                min-height: auto !important;
                padding: 14px 20px !important;
                flex-direction: column !important;
                justify-content: center !important;
            }

            .eh-nav-links,
            .nav-links,
            .navbar-links {
                justify-content: center !important;
            }

            .auth-card {
                padding: 30px 22px !important;
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
                <a href="${pageContext.request.contextPath}/index.jsp" class="eh-nav-link ">
                    <i class="fa-solid fa-house"></i>
                    <span>Home</span>
                </a>
            </li>

            <li>
                <a href="${pageContext.request.contextPath}/event?action=list" class="eh-nav-link ">
                    <i class="fa-solid fa-calendar-days"></i>
                    <span>Events</span>
                </a>
            </li>

            <% if (ehCustomerLogged) { %>
                <li>
                    <a href="${pageContext.request.contextPath}/booking?action=myBookings" class="eh-nav-link ">
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
                    <a href="${pageContext.request.contextPath}/profile.jsp" class="eh-nav-link ">
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
                    <a href="${pageContext.request.contextPath}/profile.jsp" class="eh-nav-link ">
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

<div class="page-wrap">
    <div class="hero-card">
        <div class="hero-title">Frequently Asked Questions</div>
        <div class="hero-sub">
            Find quick answers about bookings, payments, tickets, QR codes, and using EventHorizon.
        </div>
    </div>

    <div class="faq-card">
        <h2>1. How do I book an event?</h2>
        <p>Open the Events page, select an event, choose your ticket type and quantity, then continue to the booking and payment confirmation process.</p>
    </div>

    <div class="faq-card">
        <h2>2. Is my booking confirmed immediately?</h2>
        <p>No. Bookings may remain pending until the administrator verifies your submitted payment reference or payment proof.</p>
    </div>

    <div class="faq-card">
        <h2>3. How do I know whether my payment is approved?</h2>
        <p>You can check the status from your booking history. Once approved, your booking status and ticket availability will update accordingly.</p>
    </div>

    <div class="faq-card">
        <h2>4. When will I receive my ticket?</h2>
        <p>Tickets become available after payment approval. If your booking is approved, you can open your booking and view the generated ticket details.</p>
    </div>

    <div class="faq-card">
        <h2>5. What is the QR code used for?</h2>
        <p>The QR code is used for ticket verification and event entry checking. Only valid QR codes generated by EventHorizon should be accepted.</p>
    </div>

    <div class="faq-card">
        <h2>6. Can I cancel a booking?</h2>
        <p>Cancellation depends on the current booking status and the platform’s ticket policy. Some bookings may already be processed or approved and may not be reversible.</p>
    </div>

    <div class="faq-card">
        <h2>7. What should I do if I uploaded a wrong payment reference?</h2>
        <p>You should contact support or report the issue through the system as soon as possible so the administrator can review it.</p>
    </div>

    <div class="faq-card">
        <h2>8. Can I edit my profile information?</h2>
        <p>Yes. You can update your profile details from the profile page after logging in.</p>
    </div>

    <div class="faq-card">
        <h2>9. What if tickets are sold out?</h2>
        <p>If the selected ticket type has no available seats left, the system will prevent further booking for that ticket category.</p>
    </div>

    <div class="faq-card">
        <h2>10. How do I report a system problem?</h2>
        <p>You can use the “Report an Issue” option available in the platform to submit a support request.</p>
    </div>
</div>

<footer class="eh-footer">
    <div class="eh-container eh-footer-grid">
        <div class="eh-footer-col">
            <div class="eh-footer-brand">
                <span class="eh-footer-brand-mark">
                    <i class="fa-solid fa-leaf"></i>
                </span>
                <h2 class="eh-footer-logo">EVENT<span>HORIZON</span></h2>
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

</body>
</html>
