<!-- addEvent.jsp -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventhorizon.model.Admin" %>
<%@ page import="com.eventhorizon.service.UserService" %>
<%@ page import="com.eventhorizon.model.Event" %>
<%
    Object roleObj = session.getAttribute("role");
    String adminPermission = (String) session.getAttribute("adminPermission");
    if (adminPermission == null || adminPermission.trim().isEmpty()) adminPermission = Admin.CORE_ADMIN;

    if (roleObj == null || !"ADMIN".equals(roleObj.toString()) || !UserService.hasEventAccess(adminPermission)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Event> events = (List<Event>) request.getAttribute("events");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Events - EventHorizon Admin</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,600..900,40,0..1&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        *, *::before, *::after {
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
            --gold: #B08D65;
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
            --shadow-card: 0 26px 70px rgba(24, 37, 31, 0.13);
            --radius-xl: 28px;
            --radius-lg: 22px;
            --radius-md: 16px;
        }

        html { scroll-behavior: smooth; }

        body {
            font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(30, 74, 58, 0.08), transparent 32%),
                radial-gradient(circle at top right, rgba(176, 141, 101, 0.10), transparent 30%),
                linear-gradient(180deg, #ffffff 0%, var(--linen) 50%, #F7F3EA 100%);
            color: var(--text);
            min-height: 100vh;
            line-height: 1.6;
            overflow-x: hidden;
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

        a { text-decoration: none; color: inherit; }

        .page {
            width: min(94%, 1500px);
            margin: 0 auto;
            padding: 34px 0 70px;
        }

        /* ================= HEADER ================= */

        .hero {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 24px;
            margin-bottom: 24px;
            padding: 24px 26px;
            background: rgba(255, 255, 255, 0.76);
            border: 1px solid var(--border);
            border-radius: var(--radius-xl);
            box-shadow: 0 14px 38px rgba(24, 37, 31, 0.06);
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 7px 13px;
            border-radius: 999px;
            border: 1px solid var(--border-strong);
            background: #ffffff;
            color: var(--forest-dark);
            font-size: 0.75rem;
            font-weight: 900;
            letter-spacing: 0.6px;
            text-transform: uppercase;
            margin-bottom: 12px;
        }

        .hero-badge i { color: var(--forest); }

        .hero h1 {
            color: var(--forest-dark);
            font-size: clamp(2rem, 4vw, 3rem);
            font-weight: 900;
            letter-spacing: -0.06em;
            line-height: 1.05;
            margin-bottom: 8px;
        }

        .hero p {
            color: var(--text-soft);
            font-size: 0.98rem;
            font-weight: 700;
            max-width: 780px;
        }

        .top-actions,
        .top-actions-left {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 12px;
            flex-wrap: wrap;
        }

        /* ================= BUTTONS ================= */

        .btn,
        button {
            border: none;
            outline: none;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 11px 16px;
            border-radius: 13px;
            font-size: 0.88rem;
            font-weight: 900;
            transition: 0.22s ease;
            font-family: inherit;
            min-height: 42px;
            white-space: nowrap;
        }

        .btn:hover,
        button:hover {
            transform: translateY(-1px);
        }

        .btn-primary,
        .btn-save,
        .btn-add-type {
            color: #ffffff;
            background: linear-gradient(135deg, var(--forest), var(--forest-dark));
            box-shadow: 0 14px 30px rgba(30, 74, 58, 0.24);
        }

        .btn-primary:hover,
        .btn-save:hover,
        .btn-add-type:hover {
            box-shadow: 0 18px 42px rgba(30, 74, 58, 0.30);
        }

        .btn-outline,
        .btn-edit,
        .btn-cancel-event {
            color: var(--forest-dark);
            background: #ffffff;
            border: 1.5px solid var(--border-strong);
            box-shadow: none;
        }

        .btn-outline:hover,
        .btn-edit:hover,
        .btn-cancel-event:hover {
            background: var(--forest-soft);
            border-color: rgba(30, 74, 58, 0.44);
        }

        .btn-delete,
        .btn-remove-type {
            background: #ffffff;
            color: var(--danger-text);
            border: 1.5px solid rgba(162, 58, 39, 0.30);
            box-shadow: none;
        }

        .btn-delete:hover,
        .btn-remove-type:hover {
            background: var(--danger-bg);
            border-color: rgba(162, 58, 39, 0.46);
        }

        /* ================= ALERTS ================= */

        .alert-wrap { margin-bottom: 20px; }

        .alert {
            border-radius: 16px;
            padding: 14px 16px;
            font-size: 0.92rem;
            font-weight: 800;
            border: 1px solid transparent;
            margin-bottom: 12px;
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }

        .alert-success {
            background: var(--success-bg);
            color: var(--success-text);
            border-color: rgba(23, 107, 59, 0.24);
        }

        .alert-error {
            background: var(--danger-bg);
            color: var(--danger-text);
            border-color: rgba(162, 58, 39, 0.24);
        }

        .alert-info {
            background: var(--forest-soft);
            color: var(--forest-dark);
            border-color: var(--border-strong);
        }

        /* ================= PANELS ================= */

        .panel {
            background: rgba(255, 255, 255, 0.98);
            border: 1px solid var(--border);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-card);
            overflow: hidden;
            margin-bottom: 28px;
        }

        .panel-head {
            padding: 24px 28px;
            border-bottom: 1px solid var(--border);
            background:
                radial-gradient(circle at top left, rgba(30, 74, 58, 0.08), transparent 40%),
                linear-gradient(135deg, #ffffff, #FAF8F4);
        }

        .panel-head h2 {
            color: var(--forest-dark);
            font-size: clamp(1.35rem, 2vw, 1.75rem);
            font-weight: 900;
            letter-spacing: -0.04em;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .panel-head h2 i { color: var(--forest); }

        .panel-head p {
            color: var(--text-soft);
            margin-top: 6px;
            font-size: 0.95rem;
            font-weight: 700;
            max-width: 850px;
        }

        .panel-body { padding: 28px; }

        /* ================= EVENT FORM LAYOUT ================= */

        .event-form-layout {
            display: grid;
            grid-template-columns: minmax(0, 1.35fr) minmax(340px, 0.65fr);
            gap: 24px;
            align-items: start;
        }

        .form-card,
        .preview-card,
        .ticket-card-pro {
            background: #ffffff;
            border: 1px solid rgba(30, 74, 58, 0.16);
            border-radius: 22px;
            box-shadow: 0 14px 36px rgba(24, 37, 31, 0.06);
            overflow: hidden;
        }

        .section-head {
            padding: 18px 20px;
            background: var(--forest-soft);
            border-bottom: 1px solid var(--border);
        }

        .section-head h3 {
            color: var(--forest-dark);
            font-size: 0.92rem;
            font-weight: 900;
            letter-spacing: 0.7px;
            text-transform: uppercase;
            display: flex;
            align-items: center;
            gap: 9px;
        }

        .section-head h3 i { color: var(--forest); }

        .section-head p {
            color: var(--text-soft);
            font-size: 0.86rem;
            font-weight: 700;
            margin-top: 5px;
        }

        .section-body { padding: 20px; }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group.span-2 { grid-column: span 2; }

        .form-group label,
        .mini-group label {
            color: var(--forest-dark);
            font-size: 0.78rem;
            font-weight: 900;
            letter-spacing: 0.7px;
            text-transform: uppercase;
        }

        .form-group input,
        .form-group select,
        .form-group textarea,
        .mini-group input,
        .search-input,
        .filter-select {
            width: 100%;
            padding: 13px 15px;
            border-radius: 14px;
            border: 1px solid var(--border-strong);
            background: #ffffff;
            color: var(--text);
            font-size: 0.92rem;
            font-weight: 700;
            outline: none;
            transition: 0.2s ease;
            font-family: inherit;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus,
        .mini-group input:focus,
        .search-input:focus,
        .filter-select:focus {
            border-color: rgba(30, 74, 58, 0.52);
            box-shadow: 0 0 0 4px rgba(30, 74, 58, 0.10);
        }

        input::placeholder,
        textarea::placeholder {
            color: #7E9086;
            font-weight: 600;
        }

        .form-group textarea {
            min-height: 210px;
            resize: vertical;
            line-height: 1.7;
        }

        .image-drop {
            border: 1.5px dashed rgba(30, 74, 58, 0.28);
            background: #FAF8F4;
            border-radius: 18px;
            padding: 16px;
        }

        .image-drop input[type="file"] {
            margin-bottom: 12px;
        }

        .upload-preview {
            width: 100%;
            height: 210px;
            object-fit: cover;
            border-radius: 16px;
            border: 1px solid rgba(30, 74, 58, 0.16);
            background: #ffffff;
            display: none;
            margin-top: 8px;
        }

        .preview-placeholder {
            width: 100%;
            height: 210px;
            border-radius: 16px;
            background:
                radial-gradient(circle at top left, rgba(30, 74, 58, 0.08), transparent 42%),
                #ffffff;
            border: 1px solid rgba(30, 74, 58, 0.14);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            gap: 10px;
            color: var(--text-soft);
            font-weight: 800;
            text-align: center;
            padding: 18px;
        }

        .preview-placeholder i {
            color: var(--forest);
            font-size: 2rem;
        }

        .preview-text {
            color: var(--text-soft);
            font-size: 0.86rem;
            margin-top: 10px;
            line-height: 1.6;
            font-weight: 700;
        }

        /* ================= TICKET TYPES ================= */

        .ticket-section {
            margin-top: 24px;
        }

        .ticket-types-box {
            background: #ffffff;
            border: 1px solid rgba(30, 74, 58, 0.16);
            border-radius: 22px;
            box-shadow: 0 14px 36px rgba(24, 37, 31, 0.06);
            overflow: hidden;
        }

        .ticket-types-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            padding: 20px;
            border-bottom: 1px solid var(--border);
            background:
                radial-gradient(circle at top right, rgba(30, 74, 58, 0.10), transparent 46%),
                var(--forest-soft);
            flex-wrap: wrap;
        }

        .ticket-types-title {
            color: var(--forest-dark);
            font-size: 1rem;
            font-weight: 900;
            display: flex;
            align-items: center;
            gap: 9px;
        }

        .ticket-types-title i { color: var(--forest); }

        .ticket-types-sub {
            color: var(--text-soft);
            font-size: 0.9rem;
            font-weight: 700;
            margin-top: 5px;
            max-width: 760px;
        }

        .ticket-type-list {
            padding: 18px;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .ticket-row {
            display: grid;
            grid-template-columns: minmax(190px, 1.5fr) minmax(140px, 1fr) minmax(140px, 1fr) auto;
            gap: 14px;
            align-items: end;
            padding: 18px;
            border-radius: 18px;
            background: #FAF8F4;
            border: 1px solid rgba(30, 74, 58, 0.14);
            box-shadow: 0 8px 18px rgba(24, 37, 31, 0.04);
        }

        .ticket-row .mini-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .ticket-actions {
            display: flex;
            align-items: end;
            justify-content: flex-end;
            height: 100%;
        }

        .summary-bar {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
            padding: 0 18px 18px;
        }

        .summary-card {
            border-radius: 18px;
            padding: 18px 20px;
            background: #ffffff;
            border: 1px solid rgba(30, 74, 58, 0.16);
        }

        .summary-label {
            color: var(--text-soft);
            font-size: 0.74rem;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            font-weight: 900;
            margin-bottom: 6px;
        }

        .summary-value {
            color: var(--forest-dark);
            font-size: clamp(1.35rem, 3vw, 1.85rem);
            font-weight: 900;
            letter-spacing: -0.04em;
        }

        .ticket-help {
            margin: 0 18px 18px;
        }

        .form-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 24px;
            justify-content: flex-end;
        }

        /* ================= TOOLBAR / TABLE ================= */

        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
            padding: 22px 24px;
            border-bottom: 1px solid var(--border);
            background: rgba(255, 255, 255, 0.82);
        }

        .search-group {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            flex: 1;
        }

        .search-box { flex: 1; min-width: 320px; }
        .filter-select { max-width: 190px; }

        .result-count {
            font-size: 0.9rem;
            color: var(--forest-dark);
            font-weight: 900;
            white-space: nowrap;
            padding: 9px 12px;
            border-radius: 999px;
            background: var(--forest-soft);
            border: 1px solid var(--border);
        }

        .table-wrap { overflow-x: auto; }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1450px;
            background: #ffffff;
            color: var(--text);
        }

        thead th {
            text-align: left;
            padding: 16px 15px;
            font-size: 0.76rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            color: var(--forest-dark);
            background: var(--forest-soft);
            border-bottom: 1px solid var(--border-strong);
        }

        tbody td {
            padding: 17px 15px;
            border-bottom: 1px solid rgba(30, 74, 58, 0.12);
            vertical-align: middle;
            color: var(--text);
            font-weight: 700;
        }

        tbody tr.data-row:hover td { background: #FAF8F4; }

        .event-id,
        .event-title {
            font-weight: 900;
            color: var(--forest-dark);
        }

        .event-desc {
            margin-top: 4px;
            font-size: 0.78rem;
            color: var(--text-soft);
            line-height: 1.5;
            font-weight: 650;
        }

        .muted { color: var(--text-soft); font-weight: 750; }

        .event-image,
        .image-placeholder {
            width: 78px;
            height: 78px;
            border-radius: 16px;
            border: 1px solid rgba(30, 74, 58, 0.16);
            background: #FAF8F4;
        }

        .event-image { object-fit: cover; display: block; }

        .image-placeholder {
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-soft);
            font-size: 0.76rem;
            font-weight: 800;
            text-align: center;
            padding: 8px;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 7px 12px;
            border-radius: 999px;
            font-size: 0.74rem;
            font-weight: 900;
            letter-spacing: 0.4px;
            text-transform: uppercase;
        }

        .status-active {
            color: var(--success-text);
            background: var(--success-bg);
            border: 1px solid rgba(23, 107, 59, 0.22);
        }

        .status-cancelled {
            color: var(--warning-text);
            background: var(--warning-bg);
            border: 1px solid rgba(138, 90, 0, 0.22);
        }

        .action-group {
            display: flex;
            align-items: center;
            gap: 9px;
            flex-wrap: wrap;
        }

        .empty-state,
        .no-results {
            padding: 34px 24px;
            text-align: center;
            color: var(--text-soft);
            font-size: 1rem;
            font-weight: 750;
        }

        .no-results { display: none; border-top: 1px solid var(--border); }

        @media (max-width: 1100px) {
            .event-form-layout { grid-template-columns: 1fr; }
            .form-grid { grid-template-columns: 1fr; }
            .form-group.span-2 { grid-column: span 1; }
            .ticket-row { grid-template-columns: 1fr; }
            .ticket-actions { justify-content: flex-start; }
            .summary-bar { grid-template-columns: 1fr; }
            .filter-select { max-width: none; }
        }

        @media (max-width: 720px) {
            .page { width: 94%; padding-top: 20px; }
            .hero { flex-direction: column; align-items: flex-start; padding: 22px; }
            .top-actions, .top-actions-left { width: 100%; justify-content: flex-start; }
            .top-actions-left .btn { flex: 1; }
            .panel-body { padding: 20px; }
            .toolbar { flex-direction: column; align-items: stretch; }
            .search-box { min-width: 100%; }
            .result-count { width: fit-content; }
            .form-actions { justify-content: stretch; }
            .form-actions .btn { width: 100%; }
        }
    </style>

    <script>
        function filterEvents() {
            var searchValue = document.getElementById("eventSearch").value.toLowerCase().trim();
            var categoryValue = document.getElementById("categoryFilter").value.toLowerCase();
            var statusValue = document.getElementById("statusFilter").value.toLowerCase();

            var rows = document.querySelectorAll(".data-row");
            var visibleCount = 0;

            rows.forEach(function(row) {
                var title = (row.getAttribute("data-title") || "").toLowerCase();
                var category = (row.getAttribute("data-category") || "").toLowerCase();
                var date = (row.getAttribute("data-date") || "").toLowerCase();
                var time = (row.getAttribute("data-time") || "").toLowerCase();
                var venue = (row.getAttribute("data-venue") || "").toLowerCase();
                var status = (row.getAttribute("data-status") || "").toLowerCase();
                var eventId = (row.getAttribute("data-event-id") || "").toLowerCase();
                var description = (row.getAttribute("data-description") || "").toLowerCase();

                var matchesSearch =
                    title.indexOf(searchValue) !== -1 ||
                    category.indexOf(searchValue) !== -1 ||
                    date.indexOf(searchValue) !== -1 ||
                    time.indexOf(searchValue) !== -1 ||
                    venue.indexOf(searchValue) !== -1 ||
                    status.indexOf(searchValue) !== -1 ||
                    eventId.indexOf(searchValue) !== -1 ||
                    description.indexOf(searchValue) !== -1;

                var matchesCategory = (categoryValue === "all" || category === categoryValue);
                var matchesStatus = (statusValue === "all" || status === statusValue);

                row.style.display = (matchesSearch && matchesCategory && matchesStatus) ? "" : "none";
                if (matchesSearch && matchesCategory && matchesStatus) visibleCount++;
            });

            document.getElementById("resultCount").innerText = visibleCount + " event(s) found";
            document.getElementById("noResults").style.display = visibleCount === 0 ? "block" : "none";
        }

        function clearFilters() {
            document.getElementById("eventSearch").value = "";
            document.getElementById("categoryFilter").value = "all";
            document.getElementById("statusFilter").value = "all";
            filterEvents();
        }

        function confirmDelete() {
            return confirm("Delete this event?");
        }

        function confirmCancel() {
            return confirm("Cancel this event?");
        }

        function previewNewEventImage(input) {
            const preview = document.getElementById("newEventPreview");
            const placeholder = document.getElementById("newEventPlaceholder");
            const previewText = document.getElementById("previewText");

            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    preview.style.display = "block";
                    placeholder.style.display = "none";
                    previewText.innerText = "Selected image preview is ready.";
                };
                reader.readAsDataURL(input.files[0]);
            } else {
                preview.style.display = "none";
                placeholder.style.display = "flex";
                previewText.innerText = "Choose an image to preview before saving.";
            }
        }

        function addTicketTypeRow(defaultName, defaultPrice, defaultSeats) {
            const list = document.getElementById("ticketTypeList");
            const row = document.createElement("div");
            row.className = "ticket-row";

            row.innerHTML =
                '<div class="mini-group">' +
                    '<label>Type Name</label>' +
                    '<input type="text" name="typeName" required placeholder="VIP, Standard, Gold" value="' + (defaultName || '') + '">' +
                '</div>' +
                '<div class="mini-group">' +
                    '<label>Price (LKR)</label>' +
                    '<input type="number" name="typePrice" step="0.01" min="0" required placeholder="0.00" value="' + (defaultPrice || '') + '">' +
                '</div>' +
                '<div class="mini-group">' +
                    '<label>Total Seats</label>' +
                    '<input type="number" name="typeSeats" min="1" required placeholder="Seats" value="' + (defaultSeats || '') + '">' +
                '</div>' +
                '<div class="ticket-actions">' +
                    '<button type="button" class="btn btn-remove-type" onclick="removeTicketTypeRow(this)"><i class="fa-solid fa-trash"></i> Remove</button>' +
                '</div>';

            list.appendChild(row);
            updateTicketSummary();
        }

        function removeTicketTypeRow(button) {
            const rows = document.querySelectorAll("#ticketTypeList .ticket-row");
            if (rows.length <= 1) {
                alert("At least one ticket type is required.");
                return;
            }
            button.closest(".ticket-row").remove();
            updateTicketSummary();
        }

        function updateTicketSummary() {
            const priceInputs = document.querySelectorAll('input[name="typePrice"]');
            const seatInputs = document.querySelectorAll('input[name="typeSeats"]');

            let minPrice = 0;
            let totalSeats = 0;
            let foundPrice = false;

            priceInputs.forEach(function(input) {
                const val = parseFloat(input.value || "0");
                if (!isNaN(val) && val >= 0) {
                    if (!foundPrice || val < minPrice) minPrice = val;
                    foundPrice = true;
                }
            });

            seatInputs.forEach(function(input) {
                const val = parseInt(input.value || "0", 10);
                if (!isNaN(val) && val > 0) totalSeats += val;
            });

            document.getElementById("summaryMinPrice").innerText = "LKR " + minPrice.toFixed(2);
            document.getElementById("summaryTotalSeats").innerText = totalSeats;
        }

        window.addEventListener("DOMContentLoaded", function () {
            addTicketTypeRow("Standard", "", "");
            filterEvents();

            document.addEventListener("input", function (e) {
                if (e.target && (e.target.name === "typePrice" || e.target.name === "typeSeats")) {
                    updateTicketSummary();
                }
            });
        });
    </script>
</head>
<body>
<div class="page">

    <div class="hero">
        <div>
            <div class="hero-badge"><i class="fa-solid fa-calendar-plus"></i> Event Management</div>
            <h1>Manage Events</h1>
            <p>Add, search, edit, cancel, and delete events with a clear professional admin layout.</p>
        </div>

        <div class="top-actions">
            <div class="top-actions-left">
                <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="btn btn-outline">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>
                <a href="<%=request.getContextPath()%>/user?action=list" class="btn btn-outline">
                    <i class="fa-solid fa-users"></i> Manage Users
                </a>
            </div>
        </div>
    </div>

    <div class="alert-wrap">
        <% if ("added".equals(msg)) { %>
            <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Event added successfully.</div>
        <% } else if ("updated".equals(msg)) { %>
            <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Event updated successfully.</div>
        <% } else if ("deleted".equals(msg)) { %>
            <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Event deleted successfully.</div>
        <% } else if ("cancelled".equals(msg)) { %>
            <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Event cancelled successfully.</div>
        <% } else if ("error".equals(msg) || "error".equals(error)) { %>
            <div class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i> Something went wrong. Please check the form values and try again.</div>
        <% } %>
    </div>

    <div class="panel">
        <div class="panel-head">
            <h2><i class="fa-solid fa-circle-plus"></i> Add New Event</h2>
            <p>Create the main event details, upload an image, and configure multiple ticket types in one clean workflow.</p>
        </div>

        <div class="panel-body">
            <form action="<%=request.getContextPath()%>/event" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="add">

                <div class="event-form-layout">
                    <div class="form-card">
                        <div class="section-head">
                            <h3><i class="fa-solid fa-pen-to-square"></i> Event Information</h3>
                            <p>Use clear, complete details so customers can understand the event before booking.</p>
                        </div>

                        <div class="section-body">
                            <div class="form-grid">
                                <div class="form-group span-2">
                                    <label>Title</label>
                                    <input type="text" name="title" required placeholder="Enter event title">
                                </div>

                                <div class="form-group">
                                    <label>Category</label>
                                    <select name="category" required>
                                        <option value="">Select category</option>
                                        <option value="Concert">Concert</option>
                                        <option value="Technology">Technology</option>
                                        <option value="Sports">Sports</option>
                                        <option value="Cultural">Cultural</option>
                                        <option value="Music">Music</option>
                                        <option value="Conference">Conference</option>
                                        <option value="Workshop">Workshop</option>
                                        <option value="Exhibition">Exhibition</option>
                                        <option value="Festival">Festival</option>
                                        <option value="Seminar">Seminar</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Date</label>
                                    <input type="date" name="date" required>
                                </div>

                                <div class="form-group">
                                    <label>Time</label>
                                    <input type="time" name="time" required>
                                </div>

                                <div class="form-group">
                                    <label>Venue</label>
                                    <input type="text" name="venue" required placeholder="Enter venue">
                                </div>

                                <div class="form-group span-2">
                                    <label>Description</label>
                                    <textarea name="description" required placeholder="Write a detailed event description. Include what customers can expect, special instructions, event highlights, audience type, and important rules."></textarea>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="preview-card">
                        <div class="section-head">
                            <h3><i class="fa-solid fa-image"></i> Event Image</h3>
                            <p>Upload a clean image that represents the event.</p>
                        </div>

                        <div class="section-body">
                            <div class="image-drop">
                                <input type="file" name="eventImage" accept="image/*" onchange="previewNewEventImage(this)">

                                <div id="newEventPlaceholder" class="preview-placeholder">
                                    <i class="fa-regular fa-image"></i>
                                    <span>No image selected yet</span>
                                </div>

                                <img id="newEventPreview" class="upload-preview" alt="New event preview">

                                <div id="previewText" class="preview-text">
                                    Choose an image to preview before saving. Keep it clear and not too busy.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="ticket-section">
                    <div class="ticket-types-box">
                        <div class="ticket-types-head">
                            <div>
                                <div class="ticket-types-title"><i class="fa-solid fa-ticket"></i> Ticket Types</div>
                                <div class="ticket-types-sub">Add Standard, VIP, Gold, Early Bird, or custom ticket categories with separate prices and seat counts.</div>
                            </div>

                            <button type="button" class="btn btn-add-type" onclick="addTicketTypeRow('', '', '')">
                                <i class="fa-solid fa-plus"></i> Add Ticket Type
                            </button>
                        </div>

                        <div id="ticketTypeList" class="ticket-type-list"></div>

                        <div class="summary-bar">
                            <div class="summary-card">
                                <div class="summary-label">Lowest Ticket Price</div>
                                <div class="summary-value" id="summaryMinPrice">LKR 0.00</div>
                            </div>
                            <div class="summary-card">
                                <div class="summary-label">Total Seats Across Types</div>
                                <div class="summary-value" id="summaryTotalSeats">0</div>
                            </div>
                        </div>

                        <div class="alert alert-info ticket-help">
                            <i class="fa-solid fa-circle-info"></i>
                            The event summary price and total seats are calculated automatically from the ticket types you add.
                        </div>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-save">
                        <i class="fa-solid fa-floppy-disk"></i> Add Event
                    </button>
                </div>
            </form>
        </div>
    </div>

    <div class="panel">
        <div class="toolbar">
            <div class="search-group">
                <div class="search-box">
                    <input type="text" id="eventSearch" class="search-input" placeholder="Search by event ID, title, category, venue, date, time, status, or description..." onkeyup="filterEvents()">
                </div>

                <select id="categoryFilter" class="filter-select" onchange="filterEvents()">
                    <option value="all">All Categories</option>
                    <option value="concert">Concert</option>
                    <option value="technology">Technology</option>
                    <option value="sports">Sports</option>
                    <option value="cultural">Cultural</option>
                    <option value="music">Music</option>
                    <option value="conference">Conference</option>
                    <option value="workshop">Workshop</option>
                    <option value="exhibition">Exhibition</option>
                    <option value="festival">Festival</option>
                    <option value="seminar">Seminar</option>
                </select>

                <select id="statusFilter" class="filter-select" onchange="filterEvents()">
                    <option value="all">All Status</option>
                    <option value="active">Active</option>
                    <option value="cancelled">Cancelled</option>
                </select>

                <button type="button" class="btn btn-outline" onclick="clearFilters()">
                    <i class="fa-solid fa-rotate-left"></i> Clear
                </button>
            </div>

            <div class="result-count" id="resultCount">0 event(s) found</div>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Image</th>
                    <th>Title</th>
                    <th>Category</th>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Venue</th>
                    <th>Price</th>
                    <th>Total Seats</th>
                    <th>Available</th>
                    <th>Status</th>
                    <th style="min-width: 260px;">Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (events == null || events.isEmpty()) { %>
                    <tr>
                        <td colspan="12">
                            <div class="empty-state">No events found.</div>
                        </td>
                    </tr>
                <% } else { %>
                    <% for (Event event : events) { %>
                        <%
                            String description = event.getDescription() == null ? "" : event.getDescription();
                            String shortDescription = description.length() > 70 ? description.substring(0, 70) + "..." : description;
                        %>
                        <tr class="data-row"
                            data-event-id="<%= event.getEventId() %>"
                            data-title="<%= event.getTitle() %>"
                            data-category="<%= event.getCategory() %>"
                            data-date="<%= event.getDate() %>"
                            data-time="<%= event.getTime() %>"
                            data-venue="<%= event.getVenue() %>"
                            data-status="<%= event.getStatus() %>"
                            data-description="<%= description %>">

                            <td class="event-id"><%= event.getEventId() %></td>

                            <td>
                                <img class="event-image" src="<%=request.getContextPath()%>/event?action=image&id=<%= event.getEventId() %>" alt="event image" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                <div class="image-placeholder" style="display:none;">No Image</div>
                            </td>

                            <td>
                                <div class="event-title"><%= event.getTitle() %></div>
                                <div class="event-desc"><%= shortDescription %></div>
                            </td>

                            <td class="muted"><%= event.getCategory() %></td>
                            <td class="muted"><%= event.getDate() %></td>
                            <td class="muted"><%= event.getTime() %></td>
                            <td class="muted"><%= event.getVenue() %></td>
                            <td class="muted">LKR <%= String.format("%.2f", event.getTicketPrice()) %></td>
                            <td class="muted"><%= event.getTotalSeats() %></td>
                            <td class="muted"><%= event.getAvailableSeats() %></td>

                            <td>
                                <% if ("ACTIVE".equalsIgnoreCase(event.getStatus())) { %>
                                    <span class="status-badge status-active">Active</span>
                                <% } else { %>
                                    <span class="status-badge status-cancelled"><%= event.getStatus() %></span>
                                <% } %>
                            </td>

                            <td>
                                <div class="action-group">
                                    <a class="btn btn-edit" href="<%=request.getContextPath()%>/admin/editEvent.jsp?eventId=<%= event.getEventId() %>">
                                        <i class="fa-solid fa-pen"></i> Edit
                                    </a>

                                    <form method="post" action="<%=request.getContextPath()%>/event" style="margin:0;" onsubmit="return confirmCancel();">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="eventId" value="<%= event.getEventId() %>">
                                        <button type="submit" class="btn btn-cancel-event"><i class="fa-solid fa-ban"></i> Cancel</button>
                                    </form>

                                    <form method="post" action="<%=request.getContextPath()%>/event" style="margin:0;" onsubmit="return confirmDelete();">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="eventId" value="<%= event.getEventId() %>">
                                        <button type="submit" class="btn btn-delete"><i class="fa-solid fa-trash"></i> Delete</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                <% } %>
                </tbody>
            </table>
        </div>

        <div id="noResults" class="no-results">No matching events found for your search.</div>
    </div>
</div>
</body>
</html>
