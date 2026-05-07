package com.eventhorizon.servlet;

import com.eventhorizon.model.Admin;
import com.eventhorizon.model.Booking;
import com.eventhorizon.model.Event;
import com.eventhorizon.model.EventTicketType;
import com.eventhorizon.service.BookingService;
import com.eventhorizon.service.EventService;
import com.eventhorizon.service.EventTicketTypeService;
import com.eventhorizon.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class BookingServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final EventService eventService = new EventService();
    private final EventTicketTypeService ticketTypeService = new EventTicketTypeService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String action = req.getParameter("action");

        switch (action == null ? "" : action) {

            case "myBookings":
                if (session == null) {
                    resp.sendRedirect(req.getContextPath() + "/login.jsp");
                    return;
                }
                requireCustomer(session, req, resp);
                if (resp.isCommitted()) return;

                String customerId = (String) session.getAttribute("userId");
                req.setAttribute("bookings", bookingService.getBookingsByCustomer(customerId));
                req.getRequestDispatcher("/myBookings.jsp").forward(req, resp);
                break;

            case "allBookings":
                if (session == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
                    return;
                }
                requireBookingAdmin(session, req, resp);
                if (resp.isCommitted()) return;

                req.setAttribute("bookings", bookingService.getAllBookings());
                req.getRequestDispatcher("/admin/bookings.jsp").forward(req, resp);
                break;

            case "eventBookings":
                if (session == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
                    return;
                }
                requireBookingAdmin(session, req, resp);
                if (resp.isCommitted()) return;

                req.setAttribute("bookings", bookingService.getBookingsByEvent(req.getParameter("eventId")));
                req.getRequestDispatcher("/admin/bookings.jsp").forward(req, resp);
                break;

            case "checkout":
                if (session == null) {
                    resp.sendRedirect(req.getContextPath() + "/login.jsp");
                    return;
                }
                requireCustomer(session, req, resp);
                if (resp.isCommitted()) return;

                handleCheckoutPage(req, resp);
                break;

            case "pendingPayments":
                if (session == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
                    return;
                }
                requireBookingAdmin(session, req, resp);
                if (resp.isCommitted()) return;

                req.setAttribute("pendingBookings", bookingService.getPendingBookings());
                req.getRequestDispatcher("/admin/managePayments.jsp").forward(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String action = req.getParameter("action");

        if (session == null) {
            if ("approvePayment".equals(action)
                    || "rejectPayment".equals(action)
                    || "deleteBookingPermanently".equals(action)) {
                resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
            }
            return;
        }

        switch (action == null ? "" : action) {

            case "confirmPayment":
                requireCustomer(session, req, resp);
                if (resp.isCommitted()) return;

                handleConfirmPayment(req, resp, session);
                break;

            case "cancel":
                handleCancel(req, resp, session);
                break;

            case "approvePayment":
                requireBookingAdmin(session, req, resp);
                if (resp.isCommitted()) return;

                handleApprovePayment(req, resp, session);
                break;

            case "rejectPayment":
                requireBookingAdmin(session, req, resp);
                if (resp.isCommitted()) return;

                handleRejectPayment(req, resp, session);
                break;

            case "deleteBookingPermanently":
                requireBookingAdmin(session, req, resp);
                if (resp.isCommitted()) return;

                handleDeleteBookingPermanently(req, resp, session);
                break;

            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
        }
    }

    private void handleCheckoutPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String eventId = req.getParameter("eventId");
        String ticketTypeIdParam = req.getParameter("ticketTypeId");
        String ticketsParam = req.getParameter("tickets");

        int tickets = 1;
        int ticketTypeId = 0;

        try {
            tickets = Integer.parseInt(ticketsParam);
            if (tickets <= 0) tickets = 1;
        } catch (Exception ignored) {
            tickets = 1;
        }

        try {
            ticketTypeId = Integer.parseInt(ticketTypeIdParam);
        } catch (Exception ignored) {
            ticketTypeId = 0;
        }

        Event event = eventService.getEventById(eventId);
        EventTicketType ticketType = ticketTypeService.getById(ticketTypeId);

        if (event == null || ticketType == null || !eventId.equals(ticketType.getEventId())) {
            resp.sendRedirect(req.getContextPath() + "/event?action=list");
            return;
        }

        if (!"ACTIVE".equalsIgnoreCase(event.getStatus())) {
            resp.sendRedirect(req.getContextPath() + "/event?action=view&id=" + eventId + "&error=inactive");
            return;
        }

        if (ticketType.getAvailableSeats() < tickets) {
            resp.sendRedirect(req.getContextPath() + "/event?action=view&id=" + eventId + "&error=noSeats");
            return;
        }

        req.setAttribute("event", event);
        req.setAttribute("ticketType", ticketType);
        req.setAttribute("tickets", tickets);
        req.setAttribute("total", ticketType.getPrice() * tickets);
        req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
    }

    private void handleConfirmPayment(HttpServletRequest req, HttpServletResponse resp,
                                      HttpSession session) throws IOException {

        String customerId = (String) session.getAttribute("userId");
        String eventId = req.getParameter("eventId");
        String paymentReference = req.getParameter("paymentReference");

        int tickets;
        int ticketTypeId;

        try {
            tickets = Integer.parseInt(req.getParameter("numberOfTickets"));
            if (tickets <= 0) tickets = 1;
        } catch (Exception e) {
            tickets = 1;
        }

        try {
            ticketTypeId = Integer.parseInt(req.getParameter("ticketTypeId"));
        } catch (Exception e) {
            ticketTypeId = 0;
        }

        if (paymentReference == null || paymentReference.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/booking?action=checkout&eventId="
                    + eventId + "&ticketTypeId=" + ticketTypeId + "&tickets=" + tickets + "&error=noReference");
            return;
        }

        String bookingId = bookingService.createBooking(customerId, eventId, ticketTypeId, tickets, paymentReference);

        if (bookingId != null) {
            resp.sendRedirect(req.getContextPath() + "/booking?action=myBookings&msg=paymentPending&id=" + bookingId);
        } else {
            resp.sendRedirect(req.getContextPath() + "/event?action=view&id=" + eventId + "&error=bookingFailed");
        }
    }

    private void handleCancel(HttpServletRequest req, HttpServletResponse resp,
                              HttpSession session) throws IOException {

        String bookingId = req.getParameter("bookingId");
        String role = (String) session.getAttribute("role");
        String currentUserId = (String) session.getAttribute("userId");

        if (bookingId == null || bookingId.trim().isEmpty()) {
            if ("ADMIN".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/booking?action=allBookings&error=invalidBooking");
            } else {
                resp.sendRedirect(req.getContextPath() + "/booking?action=myBookings&error=invalidBooking");
            }
            return;
        }

        if ("ADMIN".equals(role)) {
            String permission = (String) session.getAttribute("adminPermission");
            if (!UserService.hasBookingAccess(permission)) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=noBookingPermission");
                return;
            }
        } else {
            Booking booking = bookingService.getBookingById(bookingId);
            if (booking == null || !currentUserId.equals(booking.getCustomerId())) {
                resp.sendRedirect(req.getContextPath() + "/booking?action=myBookings&error=unauthorized");
                return;
            }
        }

        boolean ok = bookingService.cancelBooking(bookingId);

        if ("ADMIN".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/booking?action=allBookings&msg=" + (ok ? "cancelled" : "error"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/booking?action=myBookings&msg=" + (ok ? "cancelled" : "error"));
        }
    }

    private void handleApprovePayment(HttpServletRequest req, HttpServletResponse resp,
                                      HttpSession session) throws IOException {

        String permission = (String) session.getAttribute("adminPermission");
        if (permission == null) permission = Admin.CORE_ADMIN;

        if (!UserService.hasBookingAccess(permission)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=noBookingPermission");
            return;
        }

        String bookingId = req.getParameter("bookingId");
        boolean ok = bookingService.approveBooking(bookingId);

        resp.sendRedirect(req.getContextPath()
                + "/booking?action=pendingPayments&msg=" + (ok ? "approved" : "error"));
    }

    private void handleRejectPayment(HttpServletRequest req, HttpServletResponse resp,
                                     HttpSession session) throws IOException {

        String permission = (String) session.getAttribute("adminPermission");
        if (permission == null) permission = Admin.CORE_ADMIN;

        if (!UserService.hasBookingAccess(permission)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=noBookingPermission");
            return;
        }

        String bookingId = req.getParameter("bookingId");
        boolean ok = bookingService.rejectBooking(bookingId);

        resp.sendRedirect(req.getContextPath()
                + "/booking?action=pendingPayments&msg=" + (ok ? "rejected" : "error"));
    }

    private void handleDeleteBookingPermanently(HttpServletRequest req, HttpServletResponse resp,
                                                HttpSession session) throws IOException {

        String permission = (String) session.getAttribute("adminPermission");
        if (permission == null) permission = Admin.CORE_ADMIN;

        if (!UserService.hasBookingAccess(permission)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=noBookingPermission");
            return;
        }

        String bookingId = req.getParameter("bookingId");
        boolean ok = bookingService.deleteBookingPermanently(bookingId);

        resp.sendRedirect(req.getContextPath()
                + "/booking?action=allBookings&msg=" + (ok ? "deleted" : "error"));
    }

    private void requireCustomer(HttpSession session, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        if (!"CUSTOMER".equals(session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    private void requireBookingAdmin(HttpSession session, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        if (!"ADMIN".equals(session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
            return;
        }

        String permission = (String) session.getAttribute("adminPermission");
        if (permission == null) permission = Admin.CORE_ADMIN;

        if (!UserService.hasBookingAccess(permission)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=noBookingPermission");
        }
    }
}