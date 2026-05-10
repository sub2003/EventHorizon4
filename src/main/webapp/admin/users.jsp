<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventhorizon.model.User" %>
<%@ page import="com.eventhorizon.model.Admin" %>
<%@ page import="com.eventhorizon.service.UserService" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"ADMIN".equals(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }

    List<User> users = (List<User>) request.getAttribute("users");

    if (users == null) {
        UserService userService = new UserService();
        users = userService.getAllUsers();
    }

    String currentAdminId = (String) session.getAttribute("userId");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - EventHorizon Admin</title>
<script>
        function toggleEditPanel(userId) {
            var target = document.getElementById("edit-" + userId);
            var allPanels = document.querySelectorAll(".edit-row");

            allPanels.forEach(function(panel) {
                if (panel !== target) {
                    panel.classList.remove("active");
                }
            });

            if (target) {
                target.classList.toggle("active");
            }
        }

        function confirmDelete(userId) {
            return confirm("Are you sure you want to delete user " + userId + "?");
        }

        function filterUsers() {
            var searchValue = document.getElementById("userSearch").value.toLowerCase().trim();
            var roleValue = document.getElementById("roleFilter").value.toLowerCase();
            var rows = document.querySelectorAll(".data-row");
            var visibleCount = 0;

            rows.forEach(function(row) {
                var userId = (row.getAttribute("data-user-id") || "").toLowerCase();
                var name = (row.getAttribute("data-name") || "").toLowerCase();
                var email = (row.getAttribute("data-email") || "").toLowerCase();
                var phone = (row.getAttribute("data-phone") || "").toLowerCase();
                var role = (row.getAttribute("data-role") || "").toLowerCase();

                var matchesSearch =
                    userId.includes(searchValue) ||
                    name.includes(searchValue) ||
                    email.includes(searchValue) ||
                    phone.includes(searchValue);

                var matchesRole = (roleValue === "all" || role === roleValue);

                var editRow = document.getElementById("edit-" + row.getAttribute("data-user-id"));

                if (matchesSearch && matchesRole) {
                    row.style.display = "";
                    visibleCount++;
                } else {
                    row.style.display = "none";
                    if (editRow) {
                        editRow.style.display = "none";
                        editRow.classList.remove("active");
                    }
                }
            });

            document.getElementById("resultCount").innerText = visibleCount + " user(s) found";

            var noResults = document.getElementById("noResults");
            noResults.style.display = visibleCount === 0 ? "block" : "none";
        }

        function clearFilters() {
            document.getElementById("userSearch").value = "";
            document.getElementById("roleFilter").value = "all";
            filterUsers();
        }

        function togglePermissionField(userId) {
            var roleSelect = document.getElementById("role-" + userId);
            var permissionWrap = document.getElementById("permission-wrap-" + userId);

            if (!roleSelect || !permissionWrap) return;

            if (roleSelect.value === "ADMIN") {
                permissionWrap.style.display = "block";
            } else {
                permissionWrap.style.display = "none";
            }
        }

        window.addEventListener("DOMContentLoaded", function() {
            filterUsers();

            var roleSelects = document.querySelectorAll(".role-select");
            roleSelects.forEach(function(select) {
                var userId = select.getAttribute("data-user-id");
                togglePermissionField(userId);
            });
        });
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

    <div class="topbar">
        <div class="title-block">
            <h1>Manage Users</h1>
            <p>Search users, review roles, and open one edit panel at a time</p>
        </div>

        <div class="top-actions">
            <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="btn btn-outline"><i class="fa-solid fa-chart-line"></i> Dashboard</a>
            <a href="<%=request.getContextPath()%>/user?action=listAdminRequests" class="btn btn-primary"><i class="fa-solid fa-user-check"></i> Admin Requests</a>
        </div>
    </div>

    <div class="alert-wrap">
        <% if ("updated".equals(msg)) { %>
            <div class="alert alert-success">User updated successfully.</div>
        <% } else if ("deleted".equals(msg)) { %>
            <div class="alert alert-success">User deleted successfully.</div>
        <% } %>

        <% if ("updateFailed".equals(error)) { %>
            <div class="alert alert-error">Failed to update user. Check required fields and email uniqueness.</div>
        <% } else if ("deleteFailed".equals(error)) { %>
            <div class="alert alert-error">Failed to delete user. The system blocked the operation or related data caused an issue.</div>
        <% } %>
    </div>

    <div class="panel">
        <div class="toolbar">
            <div class="search-group">
                <div class="search-box">
                    <input
                        type="text"
                        id="userSearch"
                        class="search-input"
                        placeholder="Search by User ID, name, email, or phone..."
                        onkeyup="filterUsers()">
                </div>

                <div class="filter-box">
                    <select id="roleFilter" class="filter-select" onchange="filterUsers()">
                        <option value="all">All Roles</option>
                        <option value="admin">Admins Only</option>
                        <option value="customer">Customers Only</option>
                    </select>
                </div>

                <button type="button" class="btn btn-outline" onclick="clearFilters()"><i class="fa-solid fa-rotate-left"></i> Clear</button>
            </div>

            <div class="result-count" id="resultCount">0 user(s) found</div>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>User ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Role</th>
                    <th>Permission</th>
                    <th style="min-width: 220px;">Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (users == null || users.isEmpty()) { %>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">No users found.</div>
                        </td>
                    </tr>
                <% } else { %>
                    <% for (User user : users) { %>
                        <%
                            boolean isAdmin = "ADMIN".equals(user.getRole());
                            String permissionValue = Admin.CORE_ADMIN;
                            String permissionLabel = "Not Applicable";

                            if (isAdmin && user instanceof Admin) {
                                Admin adminUser = (Admin) user;
                                permissionValue = adminUser.getAdminPermission();
                                permissionLabel = adminUser.getPermissionLabel();
                            }
                        %>

                        <tr class="data-row"
                            data-user-id="<%= user.getUserId() %>"
                            data-name="<%= user.getName() %>"
                            data-email="<%= user.getEmail() %>"
                            data-phone="<%= user.getPhone() %>"
                            data-role="<%= user.getRole() %>">
                            <td class="user-id"><%= user.getUserId() %></td>
                            <td class="user-name"><%= user.getName() %></td>
                            <td class="user-email"><%= user.getEmail() %></td>
                            <td class="user-phone"><%= user.getPhone() %></td>
                            <td>
                                <% if (isAdmin) { %>
                                    <span class="badge badge-admin">Admin</span>
                                <% } else { %>
                                    <span class="badge badge-customer">Customer</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (isAdmin) { %>
                                    <span class="permission-badge"><%= permissionLabel %></span>
                                <% } else { %>
                                    <span class="permission-muted">Not Applicable</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-group">
                                    <button type="button"
                                            class="btn btn-edit"
                                            onclick="toggleEditPanel('<%= user.getUserId() %>')">
                                        <i class="fa-solid fa-pen-to-square"></i> Edit
                                    </button>

                                    <form method="post"
                                          action="<%=request.getContextPath()%>/user"
                                          style="margin:0;"
                                          onsubmit="return confirmDelete('<%= user.getUserId() %>');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                        <button type="submit"
                                                class="btn btn-delete"
                                                <%= user.getUserId().equals(currentAdminId) ? "disabled title='You cannot delete your own account.'" : "" %>>
                                            <i class="fa-solid fa-trash"></i> Delete
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>

                        <tr id="edit-<%= user.getUserId() %>" class="edit-row">
                            <td colspan="7" class="edit-cell">
                                <div class="edit-box">
                                    <div class="edit-title">Edit User - <%= user.getUserId() %></div>

                                    <form method="post" action="<%=request.getContextPath()%>/user">
                                        <input type="hidden" name="action" value="adminUpdate">
                                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">

                                        <div class="form-grid">
                                            <div class="form-group">
                                                <label>Name</label>
                                                <input type="text"
                                                       name="name"
                                                       value="<%= user.getName() %>"
                                                       required>
                                            </div>

                                            <div class="form-group">
                                                <label>Email</label>
                                                <input type="email"
                                                       name="email"
                                                       value="<%= user.getEmail() %>"
                                                       required>
                                            </div>

                                            <div class="form-group">
                                                <label>Phone</label>
                                                <input type="text"
                                                       name="phone"
                                                       value="<%= user.getPhone() %>"
                                                       required>
                                            </div>

                                            <div class="form-group">
                                                <label>New Password</label>
                                                <input type="text"
                                                       name="password"
                                                       placeholder="Leave blank to keep current password">
                                            </div>

                                            <div class="form-group">
                                                <label>Role</label>
                                                <select name="role"
                                                        id="role-<%= user.getUserId() %>"
                                                        class="role-select"
                                                        data-user-id="<%= user.getUserId() %>"
                                                        onchange="togglePermissionField('<%= user.getUserId() %>')"
                                                        required
                                                    <%= user.getUserId().equals(currentAdminId) ? "disabled" : "" %>>
                                                    <option value="ADMIN" <%= "ADMIN".equals(user.getRole()) ? "selected" : "" %>>ADMIN</option>
                                                    <option value="CUSTOMER" <%= "CUSTOMER".equals(user.getRole()) ? "selected" : "" %>>CUSTOMER</option>
                                                </select>

                                                <% if (user.getUserId().equals(currentAdminId)) { %>
                                                    <input type="hidden" name="role" value="ADMIN">
                                                <% } %>
                                            </div>

                                            <div class="form-group permission-group"
                                                 id="permission-wrap-<%= user.getUserId() %>"
                                                 style="<%= isAdmin ? "display:block;" : "display:none;" %>">
                                                <label>Admin Permission</label>
                                                <select name="adminPermission"
                                                        <%= ("CUSTOMER".equals(user.getRole())) ? "" : "" %>>
                                                    <option value="CORE_ADMIN" <%= "CORE_ADMIN".equals(permissionValue) ? "selected" : "" %>>Core Admin</option>
                                                    <option value="EVENTS_BOOKINGS_REQUEST_ADMIN" <%= "EVENTS_BOOKINGS_REQUEST_ADMIN".equals(permissionValue) ? "selected" : "" %>>Events + Bookings + New Admin Requests</option>
                                                    <option value="EVENTS_ONLY" <%= "EVENTS_ONLY".equals(permissionValue) ? "selected" : "" %>>Events only</option>
                                                    <option value="BOOKINGS_ONLY" <%= "BOOKINGS_ONLY".equals(permissionValue) ? "selected" : "" %>>Bookings only</option>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="form-actions">
                                            <button type="submit" class="btn btn-save"><i class="fa-solid fa-floppy-disk"></i> Save Changes</button>
                                            <button type="button"
                                                    class="btn btn-cancel"
                                                    onclick="toggleEditPanel('<%= user.getUserId() %>')">
                                                <i class="fa-solid fa-xmark"></i> Cancel
                                            </button>
                                        </div>

                                        <% if (user.getUserId().equals(currentAdminId)) { %>
                                            <div class="note">
                                                Your own admin account cannot be downgraded or deleted from this page.
                                            </div>
                                        <% } %>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                <% } %>
                </tbody>
            </table>
        </div>

        <div id="noResults" class="no-results">
            No matching users found for your search.
        </div>
    </div>
</div>
</body>
</html>