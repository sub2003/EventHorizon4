<!-- editEvent.jsp -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventhorizon.model.Admin" %>
<%@ page import="com.eventhorizon.service.UserService" %>
<%@ page import="com.eventhorizon.service.EventService" %>
<%@ page import="com.eventhorizon.service.EventTicketTypeService" %>
<%@ page import="com.eventhorizon.model.Event" %>
<%@ page import="com.eventhorizon.model.EventTicketType" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String adminPermission = (String) session.getAttribute("adminPermission");
    if (adminPermission == null || adminPermission.trim().isEmpty()) adminPermission = Admin.CORE_ADMIN;

    if (session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role")) || !UserService.hasEventAccess(adminPermission)) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }

    String eventId = request.getParameter("eventId");
    if (eventId == null || eventId.trim().isEmpty()) {
        eventId = request.getParameter("id");
    }

    EventService eventService = new EventService();
    EventTicketTypeService eventTicketTypeService = new EventTicketTypeService();

    Event event = eventService.getEventById(eventId);
    if (event == null) {
        response.sendRedirect(request.getContextPath() + "/event?action=adminList");
        return;
    }

    List<EventTicketType> ticketTypes = eventTicketTypeService.getByEvent(eventId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Event - EventHorizon Admin</title>
<script>
        function previewSelectedImage(input) {
            const preview = document.getElementById("selectedImagePreview");
            const placeholder = document.getElementById("selectedImagePlaceholder");

            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    preview.style.display = "block";
                    placeholder.style.display = "none";
                };
                reader.readAsDataURL(input.files[0]);
            } else {
                preview.style.display = "none";
                placeholder.style.display = "flex";
            }
        }

        function addTicketTypeRow(defaultName, defaultPrice, defaultSeats) {
            const list = document.getElementById("ticketTypeList");
            const row = document.createElement("div");
            row.className = "ticket-row";

            row.innerHTML =
                '<div class="mini-group">' +
                    '<label>Type Name</label>' +
                    '<input type="text" name="typeName" required placeholder="e.g. VIP, Standard, Gold" value="' + (defaultName || '') + '">' +
                '</div>' +
                '<div class="mini-group">' +
                    '<label>Price (LKR)</label>' +
                    '<input type="number" name="typePrice" step="0.01" min="0" required placeholder="0.00" value="' + (defaultPrice || '') + '">' +
                '</div>' +
                '<div class="mini-group">' +
                    '<label>Total Seats</label>' +
                    '<input type="number" name="typeSeats" min="1" required placeholder="Enter seats" value="' + (defaultSeats || '') + '">' +
                '</div>' +
                '<div class="ticket-actions">' +
                    '<button type="button" class="btn btn-remove-type" onclick="removeTicketTypeRow(this)">Remove</button>' +
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
                    if (!foundPrice || val < minPrice) {
                        minPrice = val;
                    }
                    foundPrice = true;
                }
            });

            seatInputs.forEach(function(input) {
                const val = parseInt(input.value || "0", 10);
                if (!isNaN(val) && val > 0) {
                    totalSeats += val;
                }
            });

            document.getElementById("summaryMinPrice").innerText = "LKR " + minPrice.toFixed(2);
            document.getElementById("summaryTotalSeats").innerText = totalSeats;
        }

        document.addEventListener("input", function (e) {
            if (e.target && (e.target.name === "typePrice" || e.target.name === "typeSeats")) {
                updateTicketSummary();
            }
        });

        window.onload = function () {
            updateTicketSummary();
        };
    </script>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,600..900,40,0..1&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css?v=20260501">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin.css?v=20260501">
</head>
<body>
<div class="page">
    <div class="hero">
        <h1>Edit Event</h1>
        <p>Update event details and ticket types with the same admin dashboard style.</p>

        <div class="actions">
            <a href="<%=request.getContextPath()%>/event?action=adminList" class="btn btn-outline">Back to Events</a>
            <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="btn btn-outline">Dashboard</a>
        </div>
    </div>

    <div class="panel">
        <div class="panel-head">
            <h2>Edit <%= event.getTitle() %></h2>
        </div>

        <div class="panel-body">
            <form action="<%=request.getContextPath()%>/event" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="eventId" value="<%= event.getEventId() %>">

                <div class="form-grid">
                    <div class="form-group span-2">
                        <label>Event Title</label>
                        <input type="text" name="title" value="<%= event.getTitle() %>" required>
                    </div>

                    <div class="form-group">
                        <label>Category</label>
                        <select name="category" required>
                            <option value="Concert" <%= "Concert".equals(event.getCategory()) ? "selected" : "" %>>Concert</option>
                            <option value="Sports" <%= "Sports".equals(event.getCategory()) ? "selected" : "" %>>Sports</option>
                            <option value="Technology" <%= "Technology".equals(event.getCategory()) ? "selected" : "" %>>Technology</option>
                            <option value="Cultural" <%= "Cultural".equals(event.getCategory()) ? "selected" : "" %>>Cultural</option>
                            <option value="Music" <%= "Music".equals(event.getCategory()) ? "selected" : "" %>>Music</option>
                            <option value="Conference" <%= "Conference".equals(event.getCategory()) ? "selected" : "" %>>Conference</option>
                            <option value="Workshop" <%= "Workshop".equals(event.getCategory()) ? "selected" : "" %>>Workshop</option>
                            <option value="Exhibition" <%= "Exhibition".equals(event.getCategory()) ? "selected" : "" %>>Exhibition</option>
                            <option value="Festival" <%= "Festival".equals(event.getCategory()) ? "selected" : "" %>>Festival</option>
                            <option value="Seminar" <%= "Seminar".equals(event.getCategory()) ? "selected" : "" %>>Seminar</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Venue</label>
                        <input type="text" name="venue" value="<%= event.getVenue() %>" required>
                    </div>

                    <div class="form-group">
                        <label>Date</label>
                        <input type="date" name="date" value="<%= event.getDate() %>" required>
                    </div>

                    <div class="form-group">
                        <label>Time</label>
                        <input type="time" name="time" value="<%= event.getTime() %>" required>
                    </div>

                    <div class="form-group span-2">
                        <label>Current Image</label>

                        <img
                            src="<%=request.getContextPath()%>/event?action=image&id=<%= event.getEventId() %>"
                            alt="Current event image"
                            class="current-image"
                            onerror="this.style.display='none'; document.getElementById('currentImagePlaceholder').style.display='flex';">

                        <div id="currentImagePlaceholder" class="placeholder" style="display:none;">
                            No Image
                        </div>

                        <div class="preview-note">This image is loaded from the database.</div>
                    </div>

                    <div class="form-group span-2">
                        <label>Replace Image</label>
                        <input type="file" name="eventImage" accept="image/*" onchange="previewSelectedImage(this)">

                        <img id="selectedImagePreview" class="current-image" style="display:none; margin-top:12px;" alt="Selected image preview">
                        <div id="selectedImagePlaceholder" class="preview-note">Choose a new image only if you want to replace the current one.</div>
                    </div>

                    <div class="form-group span-2">
                        <label>Description</label>
                        <textarea name="description" required><%= event.getDescription() == null ? "" : event.getDescription() %></textarea>
                    </div>

                    <div class="form-group span-2">
                        <label>Ticket Types</label>

                        <div class="ticket-types-box">
                            <div class="ticket-types-head">
                                <div>
                                    <div class="ticket-types-title">Per-event ticket categories</div>
                                    <div class="ticket-types-sub">Update your VIP, Standard, Gold, Early Bird, or other ticket type rows here.</div>
                                </div>

                                <button type="button" class="btn btn-add-type" onclick="addTicketTypeRow('', '', '')">
                                    + Add Ticket Type
                                </button>
                            </div>

                            <div id="ticketTypeList" class="ticket-type-list">
                                <% if (ticketTypes != null && !ticketTypes.isEmpty()) { %>
                                    <% for (EventTicketType type : ticketTypes) { %>
                                        <div class="ticket-row">
                                            <div class="mini-group">
                                                <label>Type Name</label>
                                                <input type="text" name="typeName" required value="<%= type.getTypeName() %>" placeholder="e.g. VIP, Standard, Gold">
                                            </div>
                                            <div class="mini-group">
                                                <label>Price (LKR)</label>
                                                <input type="number" name="typePrice" step="0.01" min="0" required value="<%= String.format("%.2f", type.getPrice()) %>" placeholder="0.00">
                                            </div>
                                            <div class="mini-group">
                                                <label>Total Seats</label>
                                                <input type="number" name="typeSeats" min="1" required value="<%= type.getTotalSeats() %>" placeholder="Enter seats">
                                            </div>
                                            <div class="ticket-actions">
                                                <button type="button" class="btn btn-remove-type" onclick="removeTicketTypeRow(this)">Remove</button>
                                            </div>
                                        </div>
                                    <% } %>
                                <% } else { %>
                                    <div class="ticket-row">
                                        <div class="mini-group">
                                            <label>Type Name</label>
                                            <input type="text" name="typeName" required value="Standard" placeholder="e.g. VIP, Standard, Gold">
                                        </div>
                                        <div class="mini-group">
                                            <label>Price (LKR)</label>
                                            <input type="number" name="typePrice" step="0.01" min="0" required value="<%= String.format("%.2f", event.getTicketPrice()) %>" placeholder="0.00">
                                        </div>
                                        <div class="mini-group">
                                            <label>Total Seats</label>
                                            <input type="number" name="typeSeats" min="1" required value="<%= event.getTotalSeats() %>" placeholder="Enter seats">
                                        </div>
                                        <div class="ticket-actions">
                                            <button type="button" class="btn btn-remove-type" onclick="removeTicketTypeRow(this)">Remove</button>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        </div>

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
                    </div>
                </div>

                <div class="info-box">
                    Current event summary: <strong><%= event.getAvailableSeats() %> available / <%= event.getTotalSeats() %> total</strong>
                    &nbsp;|&nbsp;
                    Status: <strong><%= event.getStatus() %></strong>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                    <a href="<%=request.getContextPath()%>/event?action=adminList" class="btn btn-outline">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>