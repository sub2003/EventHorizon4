package com.eventhorizon.servlet;

import com.eventhorizon.model.Booking;
import com.eventhorizon.model.Event;
import com.eventhorizon.model.Ticket;
import com.eventhorizon.service.BookingService;
import com.eventhorizon.service.EventService;
import com.eventhorizon.service.TicketService;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.lowagie.text.Chunk;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TicketServlet extends HttpServlet {

    private static final String PUBLIC_BASE_URL =
            "https://glistening-light-production-f277.up.railway.app";

    private final TicketService ticketService = new TicketService();
    private final BookingService bookingService = new BookingService();
    private final EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "viewTickets":
                if (session == null) {
                    resp.sendRedirect(req.getContextPath() + "/login.jsp");
                    return;
                }
                handleViewTickets(req, resp, session);
                break;

            case "downloadPdf":
                if (session == null) {
                    resp.sendRedirect(req.getContextPath() + "/login.jsp");
                    return;
                }
                handleDownloadPdf(req, resp, session);
                break;

            case "qr":
                if (session == null) {
                    resp.sendRedirect(req.getContextPath() + "/login.jsp");
                    return;
                }
                handleQrImage(req, resp, session);
                break;

            case "verify":
                handlePublicVerifyPage(req, resp);
                break;

            case "scanPage":
                if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
                    resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
                    return;
                }
                req.getRequestDispatcher("/admin/scanTicket.jsp").forward(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            if (!"ADMIN".equals(session.getAttribute("role"))) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            handleAdminVerify(req, resp);
            return;
        }

        resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
    }

    private void handleViewTickets(HttpServletRequest req, HttpServletResponse resp, HttpSession session)
            throws ServletException, IOException {

        String bookingId = req.getParameter("bookingId");
        String customerId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");

        if (bookingId == null || bookingId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/booking?action=myBookings");
            return;
        }

        Booking booking = bookingService.getBookingById(bookingId);
        if (booking == null) {
            resp.sendRedirect(req.getContextPath() + "/booking?action=myBookings");
            return;
        }

        if (!"ADMIN".equals(role)) {
            if (!customerId.equals(booking.getCustomerId())) {
                resp.sendRedirect(req.getContextPath() + "/booking?action=myBookings");
                return;
            }

            if (!"APPROVED".equalsIgnoreCase(booking.getPaymentStatus())) {
                req.setAttribute("paymentPending", true);
                req.setAttribute("booking", booking);
                req.getRequestDispatcher("/viewTickets.jsp").forward(req, resp);
                return;
            }
        }

        List<Ticket> tickets = ticketService.getTicketsByBooking(bookingId);
        req.setAttribute("tickets", tickets);
        req.setAttribute("booking", booking);
        req.setAttribute("bookingId", bookingId);
        req.getRequestDispatcher("/viewTickets.jsp").forward(req, resp);
    }

    private void handleDownloadPdf(HttpServletRequest req, HttpServletResponse resp, HttpSession session)
            throws IOException {

        String bookingId = req.getParameter("bookingId");
        String currentUserId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");

        if (bookingId == null || bookingId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/booking?action=myBookings&error=invalidBooking");
            return;
        }

        Booking booking = bookingService.getBookingById(bookingId);
        if (booking == null) {
            resp.sendRedirect(req.getContextPath() + "/booking?action=myBookings&error=invalidBooking");
            return;
        }

        if (!"ADMIN".equals(role) && !currentUserId.equals(booking.getCustomerId())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You cannot download this ticket.");
            return;
        }

        if (!"APPROVED".equalsIgnoreCase(booking.getPaymentStatus())
                || !"CONFIRMED".equalsIgnoreCase(booking.getStatus())) {
            resp.sendRedirect(req.getContextPath()
                    + "/ticket?action=viewTickets&bookingId="
                    + url(bookingId)
                    + "&error=ticketNotApproved");
            return;
        }

        List<Ticket> tickets = ticketService.getTicketsByBooking(bookingId);
        if (tickets == null || tickets.isEmpty()) {
            resp.sendRedirect(req.getContextPath()
                    + "/ticket?action=viewTickets&bookingId="
                    + url(bookingId)
                    + "&error=noTickets");
            return;
        }

        Event event = eventService.getEventById(booking.getEventId());

        resp.reset();
        resp.setContentType("application/pdf");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"EventHorizon_Ticket_" + safeFileName(bookingId) + ".pdf\"");

        try {
            buildTicketPdf(resp, booking, event, tickets);
        } catch (Exception e) {
            e.printStackTrace();
            if (!resp.isCommitted()) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "PDF ticket generation failed");
            }
        }
    }

    private void buildTicketPdf(HttpServletResponse resp, Booking booking, Event event, List<Ticket> tickets)
            throws DocumentException, IOException {

        Document document = new Document(PageSize.A4, 42, 42, 36, 36);
        PdfWriter.getInstance(document, resp.getOutputStream());
        document.open();

        int number = 1;
        for (Ticket ticket : tickets) {
            if (number > 1) {
                document.newPage();
            }

            addPdfHeader(document);
            addTicketTitle(document, booking, number, tickets.size());
            addTicketDetailsTable(document, booking, event, ticket);
            addQrSection(document, ticket);
            addFooterNote(document);

            number++;
        }

        document.close();
    }

    private void addPdfHeader(Document document) throws DocumentException {
        Font brandFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 24, new Color(30, 74, 58));
        Font subFont = FontFactory.getFont(FontFactory.HELVETICA, 11, new Color(82, 99, 90));

        Paragraph brand = new Paragraph("EVENTHORIZON", brandFont);
        brand.setAlignment(Element.ALIGN_CENTER);
        brand.setSpacingAfter(4);
        document.add(brand);

        Paragraph subtitle = new Paragraph("Official Digital Event Ticket", subFont);
        subtitle.setAlignment(Element.ALIGN_CENTER);
        subtitle.setSpacingAfter(18);
        document.add(subtitle);
    }

    private void addTicketTitle(Document document, Booking booking, int number, int total) throws DocumentException {
        Font eventFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, new Color(24, 37, 31));
        Font smallFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, new Color(176, 141, 101));

        Paragraph eventTitle = new Paragraph(safe(booking.getEventTitle()), eventFont);
        eventTitle.setAlignment(Element.ALIGN_CENTER);
        eventTitle.setSpacingAfter(6);
        document.add(eventTitle);

        Paragraph ticketCounter = new Paragraph("Ticket " + number + " of " + total, smallFont);
        ticketCounter.setAlignment(Element.ALIGN_CENTER);
        ticketCounter.setSpacingAfter(16);
        document.add(ticketCounter);
    }

    private void addTicketDetailsTable(Document document, Booking booking, Event event, Ticket ticket)
            throws DocumentException {

        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{32, 68});
        table.setSpacingAfter(20);

        addRow(table, "Ticket ID", ticket.getTicketId());
        addRow(table, "Booking ID", booking.getBookingId());
        addRow(table, "Event ID", booking.getEventId());
        addRow(table, "Customer ID", booking.getCustomerId());
        addRow(table, "Ticket Type", safe(ticket.getTicketTypeName(), booking.getTicketTypeName()));
        addRow(table, "Number of Tickets", String.valueOf(booking.getNumberOfTickets()));
        addRow(table, "Total Amount", "LKR " + String.format("%.2f", booking.getTotalAmount()));
        addRow(table, "Booking Date", booking.getBookingDate());
        addRow(table, "Payment Status", booking.getPaymentStatus());
        addRow(table, "Ticket Status", ticket.isUsed() ? "USED" : "VALID / APPROVED");

        if (event != null) {
            addRow(table, "Event Date", event.getDate());
            addRow(table, "Event Time", event.getTime());
            addRow(table, "Venue", event.getVenue());
            addRow(table, "Category", event.getCategory());
        }

        document.add(table);
    }

    private void addQrSection(Document document, Ticket ticket) throws DocumentException, IOException {
        Font labelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, new Color(30, 74, 58));
        Font tokenFont = FontFactory.getFont(FontFactory.COURIER, 8, new Color(82, 99, 90));

        Paragraph scanTitle = new Paragraph("Scan QR Code to Verify Ticket", labelFont);
        scanTitle.setAlignment(Element.ALIGN_CENTER);
        scanTitle.setSpacingAfter(10);
        document.add(scanTitle);

        Image qr = createQrPdfImage(ticket.getQrToken());
        qr.scaleAbsolute(170, 170);
        qr.setAlignment(Element.ALIGN_CENTER);
        document.add(qr);

        Paragraph token = new Paragraph("Token: " + safe(ticket.getQrToken()), tokenFont);
        token.setAlignment(Element.ALIGN_CENTER);
        token.setSpacingBefore(8);
        token.setSpacingAfter(16);
        document.add(token);
    }

    private void addFooterNote(Document document) throws DocumentException {
        Font noteFont = FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 9, new Color(111, 127, 118));
        Paragraph note = new Paragraph(
                "This ticket is valid only after successful system verification. "
                        + "Screenshots, edited PDFs, or copied QR codes may be rejected at the entrance.",
                noteFont
        );
        note.setAlignment(Element.ALIGN_CENTER);
        note.setSpacingBefore(14);
        document.add(note);
    }

    private void addRow(PdfPTable table, String label, String value) {
        Font labelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, new Color(30, 74, 58));
        Font valueFont = FontFactory.getFont(FontFactory.HELVETICA, 10, new Color(24, 37, 31));

        PdfPCell labelCell = new PdfPCell(new Phrase(label, labelFont));
        labelCell.setPadding(9);
        labelCell.setBorderColor(new Color(210, 220, 214));
        labelCell.setBackgroundColor(new Color(232, 241, 236));
        table.addCell(labelCell);

        PdfPCell valueCell = new PdfPCell(new Phrase(safe(value), valueFont));
        valueCell.setPadding(9);
        valueCell.setBorderColor(new Color(210, 220, 214));
        valueCell.setBackgroundColor(Color.WHITE);
        table.addCell(valueCell);
    }

    private Image createQrPdfImage(String token) throws IOException, DocumentException {
        try {
            String qrData = buildVerifyUrl(token);

            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.MARGIN, 1);

            BitMatrix matrix = new MultiFormatWriter().encode(
                    qrData,
                    BarcodeFormat.QR_CODE,
                    360,
                    360,
                    hints
            );

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(matrix, "PNG", baos);
            return Image.getInstance(baos.toByteArray());

        } catch (Exception e) {
            if (e instanceof IOException) throw (IOException) e;
            if (e instanceof DocumentException) throw (DocumentException) e;
            throw new IOException("QR creation failed", e);
        }
    }

    private void handleQrImage(HttpServletRequest req, HttpServletResponse resp, HttpSession session)
            throws IOException {

        String token = req.getParameter("token");
        String role = (String) session.getAttribute("role");
        String currentUserId = (String) session.getAttribute("userId");

        if (token == null || token.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing token");
            return;
        }

        boolean allowed = false;

        if ("ADMIN".equals(role)) {
            allowed = true;
        } else {
            List<Ticket> myTickets = ticketService.getTicketsByCustomer(currentUserId);
            for (Ticket t : myTickets) {
                if (token.equals(t.getQrToken())) {
                    allowed = true;
                    break;
                }
            }
        }

        if (!allowed) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            String qrData = buildVerifyUrl(token);

            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.MARGIN, 1);

            BitMatrix matrix = new MultiFormatWriter().encode(
                    qrData,
                    BarcodeFormat.QR_CODE,
                    320,
                    320,
                    hints
            );

            resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
            resp.setHeader("Pragma", "no-cache");
            resp.setDateHeader("Expires", 0);

            resp.setContentType("image/png");
            MatrixToImageWriter.writeToStream(matrix, "PNG", resp.getOutputStream());
            resp.getOutputStream().flush();

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "QR generation failed");
        }
    }

    private void handlePublicVerifyPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token = req.getParameter("token");

        Ticket ticket = ticketService.getTicketByToken(token);
        Booking booking = null;
        boolean approved = false;

        if (ticket != null) {
            booking = bookingService.getBookingById(ticket.getBookingId());

            if (booking != null
                    && "APPROVED".equalsIgnoreCase(booking.getPaymentStatus())
                    && "CONFIRMED".equalsIgnoreCase(booking.getStatus())) {
                approved = true;
            }
        }

        req.setAttribute("ticket", ticket);
        req.setAttribute("booking", booking);
        req.setAttribute("approved", approved);
        req.setAttribute("scannedToken", token);
        req.getRequestDispatcher("/verifyTicket.jsp").forward(req, resp);
    }

    private void handleAdminVerify(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String qrToken = req.getParameter("token");
        if (qrToken == null || qrToken.isBlank()) {
            qrToken = req.getParameter("qrToken");
        }

        TicketService.VerifyResult result = ticketService.verifyAndRedeemTicket(qrToken);

        String message;
        switch (result) {
            case VALID:
                message = "Approved";
                break;
            case ALREADY_USED:
                message = "Already used";
                break;
            default:
                message = "Not approved";
                break;
        }

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.print("{\"result\":\"" + message + "\"}");
        out.flush();
    }

    private String buildVerifyUrl(String token) throws IOException {
        return PUBLIC_BASE_URL
                + "/ticket?action=verify&token="
                + URLEncoder.encode(safe(token), StandardCharsets.UTF_8.name());
    }

    private String url(String value) throws IOException {
        return URLEncoder.encode(safe(value), StandardCharsets.UTF_8.name());
    }

    private String safe(String value) {
        return value == null || value.trim().isEmpty() ? "-" : value.trim();
    }

    private String safe(String first, String fallback) {
        if (first != null && !first.trim().isEmpty()) return first.trim();
        return safe(fallback);
    }

    private String safeFileName(String value) {
        if (value == null || value.trim().isEmpty()) return "ticket";
        return value.replaceAll("[^A-Za-z0-9_-]", "_");
    }
}
