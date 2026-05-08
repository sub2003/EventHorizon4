<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.eventhorizon.service.IssueService" %>
<%
    int navIssueCount = 0;
    String navRole = (String) session.getAttribute("role");
    Object navUserIdObj = session.getAttribute("userId");
    if ("CUSTOMER".equals(navRole) && navUserIdObj != null) {
        try {
            String numericPart = String.valueOf(navUserIdObj).replaceAll("\\D+", "");
            if (!numericPart.isEmpty()) {
                navIssueCount = new IssueService().countIssuesWithRepliesByUser(Integer.parseInt(numericPart));
            }
        } catch (Exception ignored) { }
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
    <title>Events – EventHorizon</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
    .eh-navbar {
        position: sticky;
        top: 0;
        z-index: 1000;
        width: 100%;
        background: linear-gradient(90deg, #060b1f, #0b1434);
        border-bottom: 1px solid rgba(130, 90, 255, 0.22);
        backdrop-filter: blur(12px);
    }

    .eh-navbar-inner {
        width: min(94%, 1400px);
        margin: 0 auto;
        padding: 16px 0;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
    }

    .eh-brand {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        text-decoration: none;
        color: #e8ecff;
        font-weight: 800;
        letter-spacing: 0.6px;
        font-size: 1.55rem;
    }

    .eh-brand i {
        color: #7c5cff;
        font-size: 1.1rem;
    }

    .eh-nav-links {
        list-style: none;
        display: flex;
        align-items: center;
        gap: 10px;
        margin: 0;
        padding: 0;
        flex-wrap: wrap;
        justify-content: flex-end;
    }

    .eh-nav-links li {
        list-style: none;
    }

    .eh-nav-link,
    .eh-nav-bell,
    .eh-nav-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        min-height: 40px;
        padding: 10px 14px;
        border-radius: 12px;
        text-decoration: none;
        font-size: 0.92rem;
        font-weight: 700;
        transition: 0.22s ease;
        border: 1px solid transparent;
    }

    .eh-nav-link {
        color: #d9defa;
    }

    .eh-nav-link:hover {
        color: #ffffff;
        background: rgba(255,255,255,0.05);
    }

    .eh-nav-link.active {
        color: #ffffff;
        background: linear-gradient(135deg, rgba(124,92,255,0.24), rgba(43,192,255,0.18));
        border-color: rgba(124,92,255,0.28);
        box-shadow: 0 8px 20px rgba(124,92,255,0.12);
    }

    .eh-nav-bell {
        position: relative;
        color: #d9defa;
        width: 42px;
        padding: 0;
        background: rgba(255,255,255,0.05);
        border-color: rgba(255,255,255,0.08);
    }

    .eh-nav-bell:hover,
    .eh-nav-bell.active {
        color: #ffffff;
        border-color: rgba(124,92,255,0.35);
        background: linear-gradient(135deg, rgba(124,92,255,0.24), rgba(43,192,255,0.18));
        box-shadow: 0 8px 18px rgba(124,92,255,0.14);
    }

    .eh-nav-bell i {
        font-size: 1rem;
    }

    .eh-bell-badge {
        position: absolute;
        top: -6px;
        right: -6px;
        min-width: 18px;
        height: 18px;
        padding: 0 5px;
        border-radius: 999px;
        background: linear-gradient(135deg, #ff5d73, #ff7b54);
        color: #fff;
        font-size: 0.68rem;
        font-weight: 800;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 6px 14px rgba(255,93,115,0.3);
    }

    .eh-nav-btn {
        color: #ffffff;
        background: linear-gradient(135deg, #7c5cff, #9b6bff);
        box-shadow: 0 10px 20px rgba(124,92,255,0.18);
    }

    .eh-nav-btn:hover {
        transform: translateY(-1px);
        opacity: 0.95;
    }

    @media (max-width: 900px) {
        .eh-navbar-inner {
            flex-direction: column;
            align-items: stretch;
        }

        .eh-nav-links {
            justify-content: center;
        }

        .eh-brand {
            justify-content: center;
        }
    }


        /* EventHorizon shared light navbar/footer override */

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


    </style>

    <style>
        .events-hero {
            position: relative;
            padding-top: 10px;
        }

        .events-hero::before {
            content: "";
            position: absolute;
            top: 30px;
            left: 50%;
            transform: translateX(-50%);
            width: 540px;
            height: 220px;
            background: radial-gradient(circle, rgba(124,58,237,0.18) 0%, rgba(6,182,212,0.10) 35%, rgba(0,0,0,0) 75%);
            filter: blur(18px);
            pointer-events: none;
            z-index: 0;
        }

        .section-header {
            position: relative;
            z-index: 1;
        }

        .search-panel {
            position: relative;
            z-index: 1;
            max-width: 1020px;
            margin: 34px auto 38px auto;
            padding: 20px;
            border-radius: 26px;
            background: linear-gradient(135deg, rgba(14,20,38,0.96), rgba(20,26,48,0.88));
            border: 1px solid rgba(148,163,184,0.10);
            box-shadow:
                    0 0 0 1px rgba(255,255,255,0.02) inset,
                    0 18px 40px rgba(2,6,23,0.34),
                    0 0 30px rgba(124,58,237,0.12);
            backdrop-filter: blur(14px);
            animation: fadeSlideDown 0.8s ease;
            overflow: hidden;
        }

        .search-panel::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, rgba(124,58,237,0.08), rgba(56,189,248,0.05), rgba(255,255,255,0.01));
            pointer-events: none;
        }

        .search-form {
            position: relative;
            display: flex;
            gap: 14px;
            justify-content: center;
            align-items: center;
            flex-wrap: wrap;
            z-index: 1;
        }

        .search-input,
        .search-select {
            background: rgba(255,255,255,0.04);
            color: #ffffff;
            border: 1px solid rgba(148,163,184,0.12);
            border-radius: 16px;
            padding: 15px 17px;
            font-size: 15px;
            outline: none;
            transition: all 0.28s ease;
            box-shadow: 0 0 0 rgba(0,0,0,0);
        }

        .search-input {
            flex: 1;
            min-width: 290px;
            max-width: 440px;
        }

        .search-input::placeholder {
            color: #94a3b8;
        }

        .search-select {
            min-width: 230px;
            cursor: pointer;
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            background-image:
                    linear-gradient(45deg, transparent 50%, #c4b5fd 50%),
                    linear-gradient(135deg, #c4b5fd 50%, transparent 50%);
            background-position:
                    calc(100% - 22px) calc(50% - 3px),
                    calc(100% - 16px) calc(50% - 3px);
            background-size: 6px 6px, 6px 6px;
            background-repeat: no-repeat;
            padding-right: 44px;
        }

        .search-select option {
            background: #14143a;
            color: #ffffff;
        }

        .search-input:focus,
        .search-select:focus {
            border-color: rgba(56, 189, 248, 0.55);
            box-shadow:
                    0 0 0 4px rgba(56,189,248,0.08),
                    0 10px 24px rgba(56,189,248,0.08);
            transform: translateY(-2px);
            background: rgba(255,255,255,0.065);
        }

        .search-btn {
            border: none;
            border-radius: 16px;
            padding: 15px 28px;
            font-size: 15px;
            font-weight: 700;
            color: white;
            cursor: pointer;
            background: linear-gradient(90deg, #7c3aed, #8b5cf6, #38bdf8);
            background-size: 220% 220%;
            transition: transform 0.25s ease, box-shadow 0.28s ease;
            animation: gradientMove 5s ease infinite;
            letter-spacing: 0.2px;
            box-shadow: 0 10px 24px rgba(124,58,237,0.26);
        }

        .search-btn:hover {
            transform: translateY(-3px) scale(1.03);
            box-shadow: 0 14px 28px rgba(124,58,237,0.34);
        }

        .search-btn:active {
            transform: translateY(-1px) scale(1.01);
        }

        .filter-summary {
            text-align: center;
            margin: 0 0 26px 0;
            color: var(--text-muted);
            font-size: 0.96rem;
            animation: fadeIn 0.7s ease;
        }

        .filter-summary strong {
            color: #ffffff;
            font-weight: 700;
        }

        .clear-link {
            color: var(--accent-blue);
            text-decoration: none;
            font-weight: 700;
            margin-left: 8px;
            transition: color 0.25s ease, text-shadow 0.25s ease;
        }

        .clear-link:hover {
            color: #67e8f9;
            text-shadow: 0 0 12px rgba(103,232,249,0.35);
        }

        .events-grid .card {
            animation: fadeUp 0.65s ease both;
            transition: transform 0.30s ease, box-shadow 0.30s ease, border-color 0.30s ease;
            border: 1px solid rgba(148,163,184,0.08);
            overflow: hidden;
            position: relative;
            background: linear-gradient(180deg, rgba(13,18,34,0.98), rgba(10,15,30,0.98));
            border-radius: 18px;
            box-shadow: 0 14px 30px rgba(2,6,23,0.34);
        }

        .events-grid .card::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(180deg, rgba(124,58,237,0.04), rgba(6,182,212,0.02), transparent);
            pointer-events: none;
        }

        .events-grid .card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(2,6,23,0.45);
            border-color: rgba(124,58,237,0.18);
        }

        .card-img-placeholder img,
        .card-img-placeholder div {
            transition: transform 0.45s ease, filter 0.45s ease;
        }

        .card:hover .card-img-placeholder img,
        .card:hover .card-img-placeholder div {
            transform: scale(1.05);
            filter: saturate(1.05);
        }

        .card-category {
            box-shadow: 0 0 0 1px rgba(255,255,255,0.06) inset;
            backdrop-filter: blur(8px);
        }

        .card-title {
            transition: color 0.25s ease;
        }

        .card:hover .card-title {
            color: #c4b5fd;
        }

        .empty-state {
            animation: fadeIn 0.8s ease;
        }

        .empty-state .emoji {
            display: inline-block;
            animation: floaty 2.8s ease-in-out infinite;
        }

        @keyframes fadeSlideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes fadeUp {
            from {
                opacity: 0;
                transform: translateY(28px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to   { opacity: 1; }
        }

        @keyframes gradientMove {
            0%   { background-position: 0% 50%; }
            50%  { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        @keyframes floaty {
            0%, 100% { transform: translateY(0); }
            50%      { transform: translateY(-8px); }
        }

        @media (max-width: 768px) {
            .search-panel {
                padding: 16px;
                border-radius: 20px;
            }

            .search-input,
            .search-select,
            .search-btn {
                width: 100%;
                max-width: 100%;
            }

            .events-hero::before {
                width: 320px;
                height: 180px;
            }
        }
    </style>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,600..900,40,0..1&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

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


<!-- FINAL MATCHING LIGHT THEME OVERRIDE - fixes purple icons, dark blocks, and low-contrast text -->
<style>
    :root {
        --linen: #FAF8F4 !important;
        --linen-deep: #F1EBDD !important;
        --paper: #FFFFFF !important;
        --forest: #1E4A3A !important;
        --forest-dark: #123528 !important;
        --forest-soft: #E8F1EC !important;
        --sage: #72887A !important;
        --text: #18251F !important;
        --text-soft: #52635A !important;
        --muted: #6F7F76 !important;
        --border: rgba(30, 74, 58, 0.16) !important;
        --border-strong: rgba(30, 74, 58, 0.30) !important;
        --accent-purple: #1E4A3A !important;
        --accent-teal: #1E4A3A !important;
        --accent-blue: #1E4A3A !important;
        --bg: #FAF8F4 !important;
        --bg-card: #FFFFFF !important;
        --text-primary: #18251F !important;
        --text-muted: #52635A !important;
    }

    html, body {
        color: var(--text) !important;
        background:
            radial-gradient(circle at top left, rgba(30, 74, 58, 0.08), transparent 32%),
            radial-gradient(circle at top right, rgba(176, 141, 101, 0.09), transparent 30%),
            linear-gradient(180deg, #ffffff 0%, #FAF8F4 52%, #F7F3EA 100%) !important;
    }

    body::before {
        content: "" !important;
        position: fixed !important;
        inset: 0 !important;
        z-index: -10 !important;
        pointer-events: none !important;
        background-image:
            radial-gradient(circle at 1px 1px, rgba(30, 74, 58, 0.10) 1.2px, transparent 1.4px),
            linear-gradient(135deg, rgba(30, 74, 58, 0.035) 25%, transparent 25%),
            linear-gradient(45deg, rgba(176, 141, 101, 0.035) 25%, transparent 25%) !important;
        background-size: 34px 34px, 88px 88px, 88px 88px !important;
        background-position: 0 0, 0 0, 44px 44px !important;
        opacity: 0.72 !important;
    }

    .eh-navbar,
    .navbar {
        background: rgba(250, 248, 244, 0.96) !important;
        border-bottom: 1px solid var(--border) !important;
        box-shadow: 0 10px 28px rgba(24, 37, 31, 0.05) !important;
        backdrop-filter: blur(18px) !important;
        -webkit-backdrop-filter: blur(18px) !important;
    }

    .eh-brand,
    .navbar-brand,
    .brand {
        color: var(--forest-dark) !important;
        letter-spacing: 1.8px !important;
        font-weight: 900 !important;
    }

    .eh-brand-mark,
    .auth-brand-mark,
    .mini-footer-icon,
    .event-detail-icon,
    .profile-avatar,
    .card-img-placeholder div,
    .empty-state .emoji {
        background: linear-gradient(135deg, var(--forest), var(--forest-dark)) !important;
        color: #ffffff !important;
        border: none !important;
        box-shadow: 0 14px 30px rgba(30, 74, 58, 0.22) !important;
    }

    .eh-brand-mark i,
    .auth-brand-mark i,
    .mini-footer-icon i,
    .profile-avatar i,
    .event-detail-icon i,
    .eh-brand i,
    .fa-leaf,
    .fa-hexagon {
        color: #ffffff !important;
    }

    .eh-nav-link,
    .navbar-links a,
    .nav-links a {
        color: var(--text-soft) !important;
        background: transparent !important;
        border-color: transparent !important;
        font-weight: 850 !important;
    }

    .eh-nav-link:hover,
    .eh-nav-link.active,
    .navbar-links a:hover,
    .navbar-links a.active,
    .nav-links a:hover,
    .nav-links a.active,
    .eh-nav-bell:hover,
    .eh-nav-bell.active {
        color: var(--forest) !important;
        background: var(--forest-soft) !important;
        border-color: var(--border) !important;
        box-shadow: none !important;
    }

    .eh-nav-btn,
    .btn-nav,
    .eh-nav-btn-outline.active,
    .btn-primary {
        background: linear-gradient(135deg, var(--forest), var(--forest-dark)) !important;
        color: #ffffff !important;
        box-shadow: 0 14px 30px rgba(30, 74, 58, 0.22) !important;
    }

    .eh-nav-btn i,
    .btn-primary i,
    .btn-nav i {
        color: #ffffff !important;
    }

    .eh-nav-btn-outline,
    .btn-secondary,
    .btn-outline {
        color: var(--forest) !important;
        background: var(--forest-soft) !important;
        border-color: var(--border-strong) !important;
    }

    .auth-wrapper,
    .container,
    .events-hero,
    .page-shell {
        color: var(--text) !important;
    }

    .auth-card,
    .card,
    .booking-card,
    .profile-card,
    .detail-card,
    .booking-panel,
    .checkout-card,
    .summary,
    .form-panel,
    .side-panel,
    .empty-box,
    .event-meta-item,
    .description-box {
        background: rgba(255, 255, 255, 0.95) !important;
        color: var(--text) !important;
        border: 1px solid var(--border) !important;
        box-shadow: 0 18px 50px rgba(24, 37, 31, 0.09) !important;
    }

    .page-title,
    .section-title,
    .card-title,
    .booking-title,
    .event-detail-title,
    .detail-title,
    .auth-logo,
    .auth-logo span,
    .profile-name,
    .summary-title,
    .panel-title,
    .bank-value,
    .s-value,
    .total-amount,
    h1, h2, h3, h4 {
        color: var(--forest-dark) !important;
        text-shadow: none !important;
    }

    .page-subtitle,
    .section-header p,
    .card-meta,
    .card-meta span,
    .event-description,
    .booking-label,
    .booking-value,
    .profile-email,
    .form-label,
    label,
    .hint,
    .step-text,
    .bank-label,
    .mini-footer-text,
    p,
    .auth-subtitle {
        color: var(--text-soft) !important;
        text-shadow: none !important;
    }

    .booking-value,
    .s-value,
    .bank-value,
    .step-text strong,
    .description-box p,
    .event-meta-item span {
        color: var(--text) !important;
        font-weight: 800 !important;
    }

    input,
    select,
    textarea,
    .form-control,
    .search-input,
    .search-select {
        background: rgba(255, 255, 255, 0.98) !important;
        color: var(--text) !important;
        border: 1px solid rgba(30, 74, 58, 0.25) !important;
        box-shadow: none !important;
    }

    input::placeholder,
    textarea::placeholder,
    .search-input::placeholder {
        color: #7E9086 !important;
    }

    input:focus,
    select:focus,
    textarea:focus,
    .form-control:focus,
    .search-input:focus,
    .search-select:focus {
        border-color: rgba(30, 74, 58, 0.52) !important;
        box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.10) !important;
    }

    .search-panel,
    .events-search-panel {
        background: rgba(255, 255, 255, 0.94) !important;
        border: 1px solid var(--border) !important;
        box-shadow: 0 18px 50px rgba(24, 37, 31, 0.09) !important;
    }

    .search-panel::before,
    .events-hero::before,
    .auth-logo::before {
        display: none !important;
    }

    .search-btn,
    .btn-primary,
    button[type="submit"] {
        background: linear-gradient(135deg, var(--forest), var(--forest-dark)) !important;
        color: #ffffff !important;
    }

    .card-category,
    .ticket-type-pill,
    .type-badge,
    .role-pill,
    .badge,
    .bank-badge {
        background: var(--forest-soft) !important;
        color: var(--forest-dark) !important;
        border: 1px solid var(--border-strong) !important;
    }

    .status-confirmed,
    .payment-approved,
    .badge-success,
    .badge-available {
        background: rgba(30, 122, 74, 0.12) !important;
        color: #17613B !important;
    }

    .payment-pending,
    .alert-warning {
        background: rgba(183, 121, 31, 0.12) !important;
        color: #76520F !important;
        border-color: rgba(183, 121, 31, 0.26) !important;
    }

    .status-cancelled {
        background: rgba(120, 130, 125, 0.14) !important;
        color: #65726C !important;
    }

    .payment-rejected,
    .badge-danger {
        background: rgba(192, 57, 43, 0.12) !important;
        color: #9C3127 !important;
    }

    .seats-bar-fill,
    .progress-fill {
        background: linear-gradient(90deg, var(--forest), var(--sage)) !important;
    }

    .mini-footer,
    .footer {
        background: rgba(250, 248, 244, 0.96) !important;
        color: var(--muted) !important;
        border-top: 1px solid var(--border) !important;
    }

    .footer-brand,
    .mini-footer-name {
        color: var(--forest-dark) !important;
    }
</style>
</head>
<body class="events-page">

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
                <a href="${pageContext.request.contextPath}/event?action=list" class="eh-nav-link active">
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

<div class="container events-hero">
    <div class="section-header">
        <h2 class="section-title">Upcoming <span>Events</span></h2>
        <div class="section-divider"></div>
        <p style="color:var(--text-muted);margin-top:12px;font-size:0.95rem;">
            Browse and book tickets for the hottest events in Sri Lanka
        </p>
    </div>

    <div class="search-panel">
        <form action="${pageContext.request.contextPath}/event" method="get" class="search-form">
            <input type="hidden" name="action" value="list">

            <input type="text"
                   name="keyword"
                   class="search-input"
                   placeholder="Search by title or venue..."
                   value="${keyword}">

            <select name="category" class="search-select">
                <option value="">All Categories</option>
                <option value="Concert" ${category == 'Concert' ? 'selected' : ''}>Concert</option>
                <option value="Sports" ${category == 'Sports' ? 'selected' : ''}>Sports</option>
                <option value="Technology" ${category == 'Technology' ? 'selected' : ''}>Technology</option>
                <option value="Cultural" ${category == 'Cultural' ? 'selected' : ''}>Cultural</option>
                <option value="Theater" ${category == 'Theater' ? 'selected' : ''}>Theater</option>
                <option value="Comedy" ${category == 'Comedy' ? 'selected' : ''}>Comedy</option>
            </select>

            <button type="submit" class="search-btn"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
        </form>
    </div>

    <c:if test="${not empty keyword or not empty category}">
        <div class="filter-summary">
            Showing results
            <c:if test="${not empty keyword}">
                for <strong>${keyword}</strong>
            </c:if>
            <c:if test="${not empty category}">
                in <strong>${category}</strong>
            </c:if>
            <a href="${pageContext.request.contextPath}/event?action=list" class="clear-link">Clear Filters</a>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${not empty events}">
            <div class="events-grid">
                <c:forEach var="event" items="${events}" varStatus="status">
                    <div class="card" style="animation-delay:${status.index * 0.08}s;">

                        <div class="card-img-placeholder" style="overflow:hidden;">
                            <img src="${pageContext.request.contextPath}/event?action=image&id=${event.eventId}"
                                 alt="${event.title}"
                                 style="width:100%; height:220px; object-fit:cover; display:block;"
                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">

                            <div style="display:none; width:100%; height:220px; align-items:center; justify-content:center; font-size:3rem;">
                                <c:choose>
                                    <c:when test="${event.category == 'Concert'}"><i class="fa-solid fa-leaf"></i></c:when>
                                    <c:when test="${event.category == 'Sports'}"><i class="fa-solid fa-leaf"></i></c:when>
                                    <c:when test="${event.category == 'Technology'}"><i class="fa-solid fa-leaf"></i></c:when>
                                    <c:when test="${event.category == 'Cultural'}"><i class="fa-solid fa-leaf"></i></c:when>
                                    <c:when test="${event.category == 'Theater'}"><i class="fa-solid fa-leaf"></i></c:when>
                                    <c:when test="${event.category == 'Comedy'}"><i class="fa-solid fa-leaf"></i></c:when>
                                    <c:otherwise><i class="fa-solid fa-leaf"></i></c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="card-body">
                            <div class="card-category">${event.category}</div>
                            <div class="card-title">${event.title}</div>

                            <div class="card-meta">
                                <span><i class="fa-regular fa-calendar"></i> ${event.date} at ${event.time}</span>
                                <span><i class="fa-solid fa-location-dot"></i> ${event.venue}</span>
                                <span><i class="fa-solid fa-chair"></i> ${event.availableSeats} seats left</span>
                            </div>

                            <c:if test="${not empty event.description}">
                                <p style="color:var(--text-muted); margin-top:10px; font-size:0.9rem; line-height:1.5;">
                                    ${event.description}
                                </p>
                            </c:if>

                            <div class="seats-bar">
                                <div class="seats-bar-fill"
                                     data-pct="${(event.availableSeats * 100) / event.totalSeats}">
                                </div>
                            </div>
                        </div>

                        <div class="card-footer">
                            <div class="price">LKR ${event.ticketPrice}</div>
                            <a href="${pageContext.request.contextPath}/event?action=view&id=${event.eventId}"
                               class="btn btn-primary btn-sm">
                                View Details
                            </a>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>

        <c:otherwise>
            <div class="empty-state">
                <span class="emoji"><i class="fa-solid fa-leaf"></i></span>
                <h3>No Events Found</h3>
                <p>Try a different title, venue, or category.</p>
                <a href="${pageContext.request.contextPath}/event?action=list"
                   class="btn btn-outline"
                   style="margin-top:16px;">
                    Show All Events
                </a>
            </div>
        </c:otherwise>
    </c:choose>
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

<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
