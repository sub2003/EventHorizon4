<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userId") == null ||
        !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Events – EventHorizon Admin</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,600..900,40,0..1&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css?v=20260501">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin.css?v=20260501">
</head>
<body>

<nav class="navbar">
    <a href="${pageContext.request.contextPath}/index.jsp" class="navbar-brand"><span>EVENTHORIZON</span></a>
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/index.jsp">← Public Site</a></li>
        <li><a href="${pageContext.request.contextPath}/user?action=logout" class="btn-nav">Logout</a></li>
    </ul>
</nav>

<div class="admin-wrapper">
    <aside class="sidebar">
        <div class="sidebar-title">Admin Panel</div>
        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="sidebar-link">
            <span>📊</span> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/event?action=adminList" class="sidebar-link active">
            <span>🎟️</span> Manage Events
        </a>
        <a href="${pageContext.request.contextPath}/admin/bookings.jsp" class="sidebar-link">
            <span>📋</span> All Bookings
        </a>
        <a href="${pageContext.request.contextPath}/user?action=list" class="sidebar-link">
            <span>👥</span> Manage Users
        </a>
        <a href="${pageContext.request.contextPath}/admin/addEvent.jsp" class="sidebar-link">
            <span>➕</span> Add New Event
        </a>
    </aside>

    <main class="admin-content">
        <div class="page-header">
            <h1 class="page-title">🎟️ Manage Events</h1>
            <a href="${pageContext.request.contextPath}/admin/addEvent.jsp" class="btn btn-primary">
                ➕ Add New Event
            </a>
        </div>

        <c:if test="${param.msg == 'updated'}">
            <div class="alert alert-success" data-auto-dismiss>✅ Event updated successfully.</div>
        </c:if>
        <c:if test="${param.msg == 'deleted'}">
            <div class="alert alert-success" data-auto-dismiss>✅ Event deleted successfully.</div>
        </c:if>
        <c:if test="${param.msg == 'cancelled'}">
            <div class="alert alert-info" data-auto-dismiss>⚠️ Event cancelled successfully.</div>
        </c:if>
        <c:if test="${param.msg == 'error'}">
            <div class="alert alert-danger" data-auto-dismiss>❌ Something went wrong.</div>
        </c:if>

        <c:choose>
            <c:when test="${not empty events}">
                <div class="table-wrapper">
                    <table class="table" style="width:100%;">
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
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="event" items="${events}">
                                <tr>
                                    <td>${event.eventId}</td>

                                    <td>
                                        <img src="${pageContext.request.contextPath}/event?action=image&id=${event.eventId}"
                                             alt="${event.title}"
                                             style="width:80px;height:55px;object-fit:cover;border-radius:8px;"
                                             onerror="this.style.display='none'; this.nextElementSibling.style.display='inline-block';">

                                        <span style="display:none;font-size:1.5rem;"><i class="fa-solid fa-leaf"></i></span>
                                    </td>

                                    <td>${event.title}</td>
                                    <td>${event.category}</td>
                                    <td>${event.date}</td>
                                    <td>${event.time}</td>
                                    <td>${event.venue}</td>
                                    <td>LKR ${event.ticketPrice}</td>
                                    <td>${event.totalSeats}</td>
                                    <td>${event.availableSeats}</td>
                                    <td>${event.status}</td>

                                    <td>
                                        <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                            <a href="${pageContext.request.contextPath}/admin/editEvent.jsp?id=${event.eventId}"
                                               class="btn btn-outline btn-sm">
                                                ✏️ Edit
                                            </a>

                                            <form action="${pageContext.request.contextPath}/event"
                                                  method="post"
                                                  style="display:inline;">
                                                <input type="hidden" name="action" value="cancel">
                                                <input type="hidden" name="eventId" value="${event.eventId}">
                                                <button type="submit"
                                                        class="btn btn-outline btn-sm"
                                                        onclick="return confirm('Are you sure you want to cancel this event?');">
                                                    Cancel
                                                </button>
                                            </form>

                                            <form action="${pageContext.request.contextPath}/event"
                                                  method="post"
                                                  style="display:inline;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="eventId" value="${event.eventId}">
                                                <button type="submit"
                                                        class="btn btn-danger btn-sm"
                                                        onclick="return confirm('Are you sure you want to delete this event?');">
                                                    Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>

            <c:otherwise>
                <div class="empty-state">
                    <span class="emoji">📭</span>
                    <h3>No Events Found</h3>
                    <p>There are no events in the system yet.</p>
                    <a href="${pageContext.request.contextPath}/admin/addEvent.jsp" class="btn btn-primary" style="margin-top:16px;">
                        Add First Event
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>