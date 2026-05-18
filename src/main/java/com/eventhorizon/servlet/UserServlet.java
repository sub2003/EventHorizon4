package com.eventhorizon.servlet;

import com.eventhorizon.model.Admin;
import com.eventhorizon.model.User;
import com.eventhorizon.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class UserServlet extends HttpServlet {


    private final UserService userService = new UserService();


    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)   //Handles from submissions
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "register":
                handleRegister(req, resp);
                break;

            case "login":
                handleCustomerLogin(req, resp);
                break;

            case "adminLogin":
                handleAdminLogin(req, resp);
                break;

            case "logout":
                handleLogout(req, resp);
                break;

            case "update":
                handleUpdateProfile(req, resp);
                break;

            case "selfDelete":
                handleSelfDelete(req, resp);
                break;

            case "adminUpdate":
                requireFullAccessAdmin(req, resp);
                if (resp.isCommitted()) return;
                handleAdminUpdate(req, resp);
                break;

            case "delete":
                requireFullAccessAdmin(req, resp);
                if (resp.isCommitted()) return;
                handleDelete(req, resp);
                break;

            case "requestAdmin":
                requireRequestAdminAccess(req, resp);
                if (resp.isCommitted()) return;
                handleRequestAdmin(req, resp);
                break;

            case "requestPublicAdmin":
                resp.sendRedirect(req.getContextPath() + "/register.jsp?error=notAllowed");
                break;

            case "approveAdminRequest":
                requireFullAccessAdmin(req, resp);
                if (resp.isCommitted()) return;
                handleApproveAdminRequest(req, resp);
                break;

            case "rejectAdminRequest":
                requireFullAccessAdmin(req, resp);
                if (resp.isCommitted()) return;
                handleRejectAdminRequest(req, resp);
                break;

            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)  // Handles URL based requests
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "logout":
                handleLogout(req, resp);
                return;

            case "list":
                requireFullAccessAdmin(req, resp);
                if (resp.isCommitted()) return;

                req.setAttribute("users", userService.getAllUsers());
                req.getRequestDispatcher("/admin/users.jsp").forward(req, resp);
                return;

            case "addAdminForm":
                requireRequestAdminAccess(req, resp);
                if (resp.isCommitted()) return;

                req.getRequestDispatcher("/admin/addAdmin.jsp").forward(req, resp);
                return;

            case "listAdminRequests":
                requireFullAccessAdmin(req, resp);
                if (resp.isCommitted()) return;

                req.setAttribute("adminRequests", userService.getPendingAdminRequests());
                req.getRequestDispatcher("/admin/adminRequests.jsp").forward(req, resp);
                return;

            default:
                resp.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {   //Gets customer registration details from the form and sends them to UserService to create a customer account.

        String name = trim(req.getParameter("name"));
        String email = trim(req.getParameter("email"));
        String password = trim(req.getParameter("password"));
        String phone = trim(req.getParameter("phone"));

        boolean created = userService.registerCustomer(name, email, password, phone);

        if (created) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?msg=registered");
        } else {
            resp.sendRedirect(req.getContextPath() + "/register.jsp?error=registerFailed");
        }
    }

    private void handleCustomerLogin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {    //Checks customer email and password. If correct, it creates a customer session and redirects to the event list page.

        String email = trim(req.getParameter("email"));
        String password = trim(req.getParameter("password"));

        User user = userService.loginCustomer(email, password);

        if (user != null && "CUSTOMER".equalsIgnoreCase(user.getRole())) {
            createCustomerSession(req, user);
            resp.sendRedirect(req.getContextPath() + "/event?action=list");
        } else {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=invalid");
        }
    }

    private void handleAdminLogin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //  Checks admin email and password. If correct, it creates an admin session and redirects to the admin dashboard.

        String email = trim(req.getParameter("email"));
        String password = trim(req.getParameter("password"));

        Admin admin = userService.loginAdmin(email, password);

        if (admin != null) {
            createAdminSession(req, admin);
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/login.jsp?error=invalid");
        }
    }

    private void createCustomerSession(HttpServletRequest req, User user) {   //Stores customer details in the session after login. It also removes admin-related session values because this user is a customer.
        HttpSession session = req.getSession(true);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("userName", user.getName());
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("userPhone", user.getPhone());
        session.setAttribute("role", user.getRole());

        session.removeAttribute("adminPermission");
        session.removeAttribute("canManageEvents");
        session.removeAttribute("canManageBookings");
        session.removeAttribute("hasFullAccess");
        session.removeAttribute("canRequestAdmins");

        session.setMaxInactiveInterval(30 * 60);
    }

    private void createAdminSession(HttpServletRequest req, Admin admin) { //Stores admin details and permission values in the session after admin login. These permissions decide what the admin can access.
        HttpSession session = req.getSession(true);

        String permission = admin.getAdminPermission();

        session.setAttribute("userId", admin.getUserId());
        session.setAttribute("userName", admin.getName());
        session.setAttribute("userEmail", admin.getEmail());
        session.setAttribute("userPhone", admin.getPhone());
        session.setAttribute("role", admin.getRole());
        session.setAttribute("adminPermission", permission);
        session.setAttribute("canManageEvents", admin.canManageEvents());
        session.setAttribute("canManageBookings", admin.canManageBookings());
        session.setAttribute("hasFullAccess", UserService.hasFullAccess(permission));
        session.setAttribute("canRequestAdmins", UserService.canRequestAdmin(permission));

        session.setMaxInactiveInterval(30 * 60);
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //  Destroys the current session and redirects the user to the correct login page. Admins go to admin login, customers go to customer login.

        HttpSession session = req.getSession(false);
        boolean wasAdmin = false;

        if (session != null) {
            Object role = session.getAttribute("role");
            wasAdmin = role != null && "ADMIN".equalsIgnoreCase(String.valueOf(role));
            session.invalidate();
        }

        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        if (wasAdmin) {
            resp.sendRedirect(req.getContextPath() + "/admin/login.jsp?msg=logout");
        } else {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?msg=logout");
        }
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //Allows the logged-in user to update their own name, phone, and password. If successful, it updates the session values too.

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");
        String name = trim(req.getParameter("name"));
        String phone = trim(req.getParameter("phone"));
        String password = trim(req.getParameter("password"));

        boolean success = userService.updateUser(userId, name, phone, password);

        if (success) {
            session.setAttribute("userName", name);
            session.setAttribute("userPhone", phone);
            resp.sendRedirect(req.getContextPath() + "/profile.jsp?msg=updated");
        } else {
            if ("ADMIN".equalsIgnoreCase(role)) {
                resp.sendRedirect(req.getContextPath() + "/profile.jsp?error=updateFailed");
            } else {
                resp.sendRedirect(req.getContextPath() + "/profile.jsp?error=updateFailed");
            }
        }
    }

    private void handleSelfDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //Allows only customers to delete their own account. After deletion, it logs them out and redirects to the login page.

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String currentUserId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");
        String adminPermission = (String) session.getAttribute("adminPermission");

        if (!"CUSTOMER".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/profile.jsp?error=deleteNotAllowed");
            return;
        }

        boolean deleted = userService.deleteUser(currentUserId, currentUserId, role, adminPermission);

        if (deleted) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login.jsp?msg=accountDeleted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/profile.jsp?error=deleteFailed");
        }
    }

    private void handleAdminUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //Allows a core admin to update another user’s details, including role and admin permission. If the admin updates their own account, the session is also updated.

        HttpSession session = req.getSession(false);
        String currentAdminId = (String) session.getAttribute("userId");

        String userId = trim(req.getParameter("userId"));
        String name = trim(req.getParameter("name"));
        String email = trim(req.getParameter("email"));
        String phone = trim(req.getParameter("phone"));
        String password = trim(req.getParameter("password"));
        String role = trim(req.getParameter("role"));
        String adminPermission = trim(req.getParameter("adminPermission"));

        boolean success = userService.updateUserByAdmin(
                userId, name, email, phone, password, role, currentAdminId, adminPermission
        );

        if (success) {
            if (currentAdminId != null && currentAdminId.equals(userId)) {
                session.setAttribute("userName", name);
                session.setAttribute("userEmail", email);
                session.setAttribute("userPhone", phone);
                session.setAttribute("role", role.toUpperCase());

                if ("ADMIN".equalsIgnoreCase(role)) {
                    String normalizedPermission = userService.getAdminPermission(userId);
                    session.setAttribute("adminPermission", normalizedPermission);
                    session.setAttribute("canManageEvents", UserService.hasEventAccess(normalizedPermission));
                    session.setAttribute("canManageBookings", UserService.hasBookingAccess(normalizedPermission));
                    session.setAttribute("hasFullAccess", UserService.hasFullAccess(normalizedPermission));
                    session.setAttribute("canRequestAdmins", UserService.canRequestAdmin(normalizedPermission));
                }
            }
            resp.sendRedirect(req.getContextPath() + "/user?action=list&msg=updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/user?action=list&error=updateFailed");
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //Allows a core admin to delete a selected user account.

        HttpSession session = req.getSession(false);
        String currentAdminId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");
        String adminPermission = (String) session.getAttribute("adminPermission");
        String userId = trim(req.getParameter("userId"));

        boolean deleted = userService.deleteUser(userId, currentAdminId, role, adminPermission);

        if (deleted) {
            resp.sendRedirect(req.getContextPath() + "/user?action=list&msg=deleted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/user?action=list&error=deleteFailed");
        }
    }

    private void handleRequestAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //Allows an admin with request permission to submit a request to create a new admin account.

        HttpSession session = req.getSession(false);
        String requesterAdminId = (String) session.getAttribute("userId");

        String name = trim(req.getParameter("name"));
        String email = trim(req.getParameter("email"));
        String password = trim(req.getParameter("password"));
        String phone = trim(req.getParameter("phone"));
        String permission = trim(req.getParameter("adminPermission"));

        boolean created = userService.submitAdminRequest(
                requesterAdminId, name, email, password, phone, permission
        );

        if (created) {
            resp.sendRedirect(req.getContextPath() + "/user?action=addAdminForm&msg=requestSubmitted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/user?action=addAdminForm&error=requestFailed");
        }
    }

    private void handleApproveAdminRequest(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //Allows a core admin to approve a pending admin request. After approval, the requested admin account is created/activated.

        HttpSession session = req.getSession(false);
        String approverAdminId = (String) session.getAttribute("userId");
        String requestId = trim(req.getParameter("requestId"));

        boolean approved = userService.approveAdminRequest(requestId, approverAdminId);

        if (approved) {
            resp.sendRedirect(req.getContextPath() + "/user?action=listAdminRequests&msg=approved");
        } else {
            resp.sendRedirect(req.getContextPath() + "/user?action=listAdminRequests&error=approveFailed");
        }
    }

    private void handleRejectAdminRequest(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //Allows a core admin to reject a pending admin request.

        HttpSession session = req.getSession(false);
        String approverAdminId = (String) session.getAttribute("userId");
        String requestId = trim(req.getParameter("requestId"));

        boolean rejected = userService.rejectAdminRequest(requestId, approverAdminId);

        if (rejected) {
            resp.sendRedirect(req.getContextPath() + "/user?action=listAdminRequests&msg=rejected");
        } else {
            resp.sendRedirect(req.getContextPath() + "/user?action=listAdminRequests&error=rejectFailed");
        }
    }

    private void requireFullAccessAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException { //Checks whether the logged-in user is an admin with full/core access. If not, it redirects them away.

        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
            return;
        }

        String permission = (String) session.getAttribute("adminPermission");
        if (!UserService.hasFullAccess(permission)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=noCoreAccess");
        }
    }

    private void requireRequestAdminAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {  //Checks whether the logged-in admin has permission to request/create admin accounts. If not, it redirects them away.

        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
            return;
        }

        String permission = (String) session.getAttribute("adminPermission");
        if (!UserService.canRequestAdmin(permission)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=noRequestPermission");
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    } //Removes extra spaces from input values. If the value is null, it returns null instead of causing an error.
}
