<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession currentSession = request.getSession(false);
    if (currentSession != null && "ADMIN".equals(currentSession.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login | EventHorizon</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --linen: #FAF8F4;
            --surface: #FFFFFF;
            --surface-soft: #F4F8F5;
            --forest: #1E4A3A;
            --forest-dark: #123428;
            --sage: #6F8D7D;
            --mint: #DDECE4;
            --border: #D7E3DC;
            --text: #10231B;
            --muted: #5C6F65;
            --danger: #B23B2E;
            --danger-soft: #FBEAE7;
            --success: #1E6B45;
            --success-soft: #E8F6EE;
            --shadow: 0 22px 60px rgba(20, 43, 33, 0.16);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            color: var(--text);
            background:
                    radial-gradient(circle at 12% 10%, rgba(30, 74, 58, 0.10), transparent 28%),
                    radial-gradient(circle at 88% 18%, rgba(176, 141, 101, 0.12), transparent 26%),
                    linear-gradient(135deg, #F8F6EF 0%, #EDF5EF 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 32px 18px;
        }

        .auth-shell {
            width: min(1040px, 100%);
            display: grid;
            grid-template-columns: 1.05fr 0.95fr;
            background: rgba(255, 255, 255, 0.84);
            border: 1px solid rgba(215, 227, 220, 0.95);
            border-radius: 32px;
            box-shadow: var(--shadow);
            overflow: hidden;
            backdrop-filter: blur(16px);
        }

        .brand-panel {
            position: relative;
            padding: 52px;
            background:
                    linear-gradient(145deg, rgba(18, 52, 40, 0.94), rgba(30, 74, 58, 0.86)),
                    radial-gradient(circle at 20% 20%, rgba(255,255,255,0.18), transparent 36%);
            color: #fff;
            min-height: 560px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .brand-panel::after {
            content: "";
            position: absolute;
            inset: 0;
            background-image:
                    linear-gradient(135deg, rgba(255,255,255,0.06) 25%, transparent 25%),
                    linear-gradient(225deg, rgba(255,255,255,0.05) 25%, transparent 25%);
            background-size: 34px 34px;
            opacity: 0.34;
            pointer-events: none;
        }

        .brand-content, .security-list { position: relative; z-index: 1; }

        .brand-mark {
            width: 64px;
            height: 64px;
            border-radius: 22px;
            display: grid;
            place-items: center;
            background: rgba(255, 255, 255, 0.14);
            border: 1px solid rgba(255, 255, 255, 0.22);
            box-shadow: 0 16px 34px rgba(0,0,0,0.18);
            margin-bottom: 24px;
        }

        .brand-mark i { font-size: 28px; color: #DCECE4; }

        .brand-panel h1 {
            margin: 0;
            font-size: clamp(2rem, 4vw, 3.35rem);
            line-height: 1;
            letter-spacing: -0.06em;
        }

        .brand-panel p {
            margin: 20px 0 0;
            color: rgba(255,255,255,0.82);
            max-width: 450px;
            line-height: 1.7;
            font-size: 1rem;
        }

        .security-list {
            display: grid;
            gap: 14px;
        }

        .security-item {
            display: flex;
            gap: 12px;
            align-items: center;
            padding: 14px 16px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.10);
            border: 1px solid rgba(255, 255, 255, 0.16);
            color: rgba(255,255,255,0.88);
            font-weight: 700;
            font-size: 0.9rem;
        }

        .form-panel {
            padding: 52px;
            background: rgba(255,255,255,0.92);
            display: flex;
            align-items: center;
        }

        .form-card { width: 100%; }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 999px;
            color: var(--forest);
            background: var(--mint);
            font-weight: 800;
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 18px;
        }

        .form-card h2 {
            margin: 0;
            color: var(--forest-dark);
            font-size: 2.15rem;
            letter-spacing: -0.045em;
        }

        .subtitle {
            margin: 12px 0 28px;
            color: var(--muted);
            line-height: 1.65;
            font-weight: 600;
        }

        .alert {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            padding: 14px 16px;
            border-radius: 16px;
            margin-bottom: 18px;
            font-weight: 700;
            line-height: 1.45;
        }

        .alert-danger {
            background: var(--danger-soft);
            color: var(--danger);
            border: 1px solid rgba(178, 59, 46, 0.24);
        }

        .alert-success {
            background: var(--success-soft);
            color: var(--success);
            border: 1px solid rgba(30, 107, 69, 0.22);
        }

        .form-group { margin-bottom: 18px; }

        .form-label {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.88rem;
            font-weight: 800;
            color: var(--forest-dark);
            margin-bottom: 8px;
        }

        .form-control {
            width: 100%;
            height: 52px;
            padding: 0 16px;
            border-radius: 16px;
            border: 1px solid var(--border);
            background: #FCFEFC;
            color: var(--text);
            outline: none;
            font: inherit;
            font-weight: 600;
            transition: border-color .2s ease, box-shadow .2s ease, transform .2s ease;
        }

        .form-control:focus {
            border-color: var(--forest);
            box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.12);
            transform: translateY(-1px);
        }

        .btn {
            width: 100%;
            height: 54px;
            border: 0;
            border-radius: 17px;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            color: #fff;
            font-weight: 900;
            font-size: 1rem;
            cursor: pointer;
            box-shadow: 0 18px 34px rgba(30, 74, 58, 0.24);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: transform .2s ease, box-shadow .2s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 24px 42px rgba(30, 74, 58, 0.30);
        }

        .small-note {
            margin: 20px 0 0;
            padding: 14px 16px;
            border-radius: 16px;
            background: var(--surface-soft);
            border: 1px solid var(--border);
            color: var(--muted);
            font-size: 0.86rem;
            line-height: 1.55;
            font-weight: 600;
        }

        .small-note strong { color: var(--forest-dark); }

        @media (max-width: 860px) {
            .auth-shell { grid-template-columns: 1fr; }
            .brand-panel { min-height: auto; padding: 34px; gap: 40px; }
            .form-panel { padding: 34px; }
        }
    </style>
</head>
<body>
<div class="auth-shell">
    <section class="brand-panel">
        <div class="brand-content">
            <div class="brand-mark"><i class="fa-solid fa-leaf"></i></div>
            <h1>EventHorizon Admin</h1>
            <p>Protected administration entrance for event management, payment review, ticket scanning, issue handling, users, and admin access requests.</p>
        </div>

        <div class="security-list">
            <div class="security-item"><i class="fa-solid fa-user-shield"></i> Admin-only authentication</div>
            <div class="security-item"><i class="fa-solid fa-lock"></i> Permission-based dashboard access</div>
            <div class="security-item"><i class="fa-solid fa-qrcode"></i> Secure ticket verification tools</div>
        </div>
    </section>

    <section class="form-panel">
        <div class="form-card">
            <div class="eyebrow"><i class="fa-solid fa-shield-halved"></i> Admin Portal</div>
            <h2>Sign in as Admin</h2>
            <p class="subtitle">Use your authorized EventHorizon admin account. Customer accounts cannot sign in here.</p>

            <% if ("invalid".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-xmark"></i>
                <span>Invalid admin email or password.</span>
            </div>
            <% } %>

            <% if ("logout".equals(request.getParameter("msg"))) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i>
                <span>You have successfully logged out from the admin portal.</span>
            </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/user" method="post" autocomplete="off">
                <input type="hidden" name="action" value="adminLogin">

                <div class="form-group">
                    <label class="form-label" for="email"><i class="fa-solid fa-envelope"></i> Admin Email</label>
                    <input type="email" id="email" name="email" class="form-control" placeholder="admin@eventhorizon.com" required autofocus>
                </div>

                <div class="form-group">
                    <label class="form-label" for="password"><i class="fa-solid fa-key"></i> Password</label>
                    <input type="password" id="password" name="password" class="form-control" placeholder="Enter admin password" required>
                </div>

                <button type="submit" class="btn">
                    <i class="fa-solid fa-arrow-right-to-bracket"></i>
                    Enter Admin Dashboard
                </button>
            </form>

            <div class="small-note">
                <strong>Direct URL only:</strong> this page is not shown in the public navigation. Admins can access it by typing <strong>/admin/login.jsp</strong> in the browser address bar.
            </div>
        </div>
    </section>
</div>
</body>
</html>
