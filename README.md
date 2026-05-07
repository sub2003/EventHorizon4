# EventHorizon

<p align="center">
  <img src="https://img.shields.io/badge/Java-Full%20Stack%20Web%20Application-6C63FF?style=for-the-badge" alt="Java Full Stack Web Application" />
  <img src="https://img.shields.io/badge/JSP%20%7C%20Servlets%20%7C%20JDBC-0E1530?style=for-the-badge" alt="JSP Servlets JDBC" />
  <img src="https://img.shields.io/badge/MySQL-Database-1D3557?style=for-the-badge" alt="MySQL Database" />
  <img src="https://img.shields.io/badge/Admin%20%2F%20Customer-Separate%20Tables-2A9D8F?style=for-the-badge" alt="Admin Customer Separate Tables" />
  <img src="https://img.shields.io/badge/Dedicated-Admin%20Login-E76F51?style=for-the-badge" alt="Dedicated Admin Login" />
  <img src="https://img.shields.io/badge/OpenPDF-PDF%20Tickets-E76F51?style=for-the-badge" alt="OpenPDF PDF Tickets" />
  <img src="https://img.shields.io/badge/ZXing-QR%20Verification-2A9D8F?style=for-the-badge" alt="ZXing QR Verification" />
  <img src="https://img.shields.io/badge/Railway-Cloud%20Deployment-6C63FF?style=for-the-badge" alt="Railway Cloud Deployment" />
</p>

<p align="center">
  <strong>Professional Event Booking, Ticketing, and Administration Platform</strong><br />
  A full-stack Java web application designed for event discovery, booking management, manual payment verification, digital ticket generation, downloadable PDF tickets, QR-based validation, separate customer/admin account management, and permission-based administration.
</p>

<p align="center">
  <a href="https://www.eventhorizonapp.online/">
    <img src="https://img.shields.io/badge/Live%20Demo-eventhorizonapp.online-6C63FF?style=for-the-badge" alt="Live Demo" />
  </a>
</p>

---

## Table of Contents

- [Overview](#overview)
- [Live Deployment](#live-deployment)
- [Technology Stack](#technology-stack)
- [Core Capabilities](#core-capabilities)
- [System Architecture](#system-architecture)
- [Functional Modules](#functional-modules)
- [Admin Permission Model](#admin-permission-model)
- [Customer and Admin Account Separation](#customer-and-admin-account-separation)
- [Multi-Ticket-Type Support](#multi-ticket-type-support)
- [Digital Ticketing and QR Verification](#digital-ticketing-and-qr-verification)
- [Downloadable PDF Ticket Feature](#downloadable-pdf-ticket-feature)
- [Business Logic](#business-logic)
- [Project Structure](#project-structure)
- [Deployment Summary](#deployment-summary)
- [Local Development Setup](#local-development-setup)
- [Project Highlights](#project-highlights)
- [Future Improvements](#future-improvements)
- [Status](#status)

---

## Overview

**EventHorizon** is a full-stack event booking platform built with **Java, JSP, Servlets, JDBC, and MySQL**. The system provides a complete customer-facing booking experience and a structured administration workflow for managing events, bookings, customers, admins, payments, tickets, and admin access levels. The latest version separates customer accounts and admin accounts into dedicated database tables and provides separate login pages for customers and administrators.

The application is designed as a realistic academic full-stack project with a strong focus on:

- clean layered architecture
- role-based and permission-based access control
- separate customer and admin authentication flows
- database-backed workflows
- production-style deployment
- professional user interface design
- realistic event booking and ticket validation logic
- downloadable PDF ticket generation
- QR-based ticket verification

Unlike a simple CRUD system, EventHorizon connects multiple workflows together: customers browse and book events, submit payment references, admins verify payments, tickets are generated after approval, customers can download official PDF tickets, and QR codes are validated through backend token verification. Customer accounts and admin accounts are now handled separately at the database and login level, improving clarity, security, and maintainability.

---

## Live Deployment

| Environment | URL | Status |
|---|---|---|
| Production | `https://www.eventhorizonapp.online/` | Active |
| Railway Default | `https://glistening-light-production-f277.up.railway.app/` | Active |

---

## Technology Stack

| Category | Technologies |
|---|---|
| Backend | Java, Java Servlets, JDBC |
| Frontend | JSP, HTML, CSS, JavaScript |
| Database | MySQL with separate `customers` and `admins` tables |
| Build Tool | Maven |
| Runtime Server | Apache Tomcat |
| Development Tools | IntelliJ IDEA, Git, GitHub, XAMPP, MySQL Workbench |
| Deployment | Railway, Railway MySQL |
| Temporary Public Testing | ngrok |
| PDF Ticket Generation | OpenPDF |
| QR Code Generation | ZXing |

---

## Core Capabilities

### Customer Features

- Customer registration and dedicated customer login
- Session-based authentication
- Browse active events
- Search events by title, venue, or category
- View detailed event information
- Select ticket types and quantities
- Submit booking requests
- Enter manual payment reference details
- View personal booking history
- Track booking and payment status
- Access approved digital tickets
- Download approved tickets as PDF files
- Use QR-based ticket verification links
- Update customer profile details
- Cancel bookings when allowed

### Admin Features

- Dedicated admin login page
- Dedicated admin dashboard
- Permission-aware navigation and dashboard modules
- Add, update, cancel, and delete events
- Configure multiple ticket types per event
- Manage event images and event details
- View and manage customer bookings
- Approve or reject payment submissions
- Control ticket availability through payment approval
- Generate tickets after approved payments
- Verify QR-based ticket tokens
- Manage users based on permission level
- Handle admin access requests
- Work under categorized admin roles

---

## System Architecture

EventHorizon follows a layered architecture that separates presentation, request handling, business logic, and database access.

| Layer | Responsibility |
|---|---|
| Model Layer | Represents domain entities such as `User`, `Admin`, `Customer`, `Event`, `Booking`, `Ticket`, and `EventTicketType` |
| View Layer | JSP pages for customer interfaces, admin dashboards, forms, lists, and status pages |
| Controller Layer | Servlets that handle routing, validation, request processing, and response forwarding |
| Service Layer | Business logic for authentication, events, bookings, tickets, payments, users, and admin workflows |
| Data Access Layer | JDBC-based database operations using MySQL, including separated `customers` and `admins` account tables |
| Deployment Layer | Railway-hosted application and MySQL database environment |

### Architecture Benefits

- Clear separation of concerns
- Clear separation between customer accounts and admin accounts
- Easier debugging and maintenance
- More readable code organization
- Reusable service-level logic
- Scalable structure for future features
- Better alignment with real-world Java web development practices

---

## Functional Modules

| Module | Responsibility | Primary Access |
|---|---|---|
| Authentication Module | Customer registration, customer login, admin login, logout, session handling, and role validation | Customers / Admins |
| Event Browsing Module | Display active events, event details, search, and filtering | Customers |
| Booking Module | Create bookings, submit payment references, cancel bookings, and track history | Customers |
| Payment Review Module | Review submitted payment references and approve or reject bookings | Admins |
| Ticket Module | Generate tickets, display ticket details, download PDF tickets, and validate QR tokens | Customers / Admins |
| Ticket Type Module | Manage VIP, Standard, Early Bird, and other ticket categories | Admins |
| Event Management Module | Create, edit, cancel, delete, and manage event data | Event Admins |
| User Management Module | View and manage separated customer and admin accounts | Full Access Admins |
| Admin Request Module | Submit, review, approve, or reject new admin access requests | Full Access Admins |
| Issue / Support Module | Allow users to report issues and receive admin responses | Customers / Admins |

---

## Admin Permission Model

EventHorizon includes a permission-based admin system that controls which dashboard modules and actions each admin can access.

| Permission Type | Access Scope |
|---|---|
| Events Only | Create, update, cancel, and manage events |
| Bookings Only | View bookings, approve payments, reject payments, and manage booking records |
| Events + Bookings | Combined access to event and booking workflows |
| Full Access | Complete administrative control, including users and admin requests |
| Core Admin | Highest-level control over the system and admin management workflows |

### Purpose of Permission Control

- Prevents unnecessary access to sensitive modules
- Supports clear separation of responsibilities
- Makes the admin dashboard more secure and organized
- Reflects realistic organizational access control
- Reduces accidental changes by limited-access admins

---

## Customer and Admin Account Separation

EventHorizon now separates customer accounts and admin accounts into different database tables instead of storing both account types in one shared `users` table.

### Database Separation

| Table | Purpose | Example ID Format |
|---|---|---|
| `customers` | Stores registered customer accounts | `USR001` |
| `admins` | Stores administrator accounts and permission levels | `ADM001` |
| `users_legacy_before_customer_admin_split` | Backup of the previous combined users table | Legacy records |

### Login Separation

| Login Type | Page | Purpose |
|---|---|---|
| Customer Login | `/login.jsp` | Allows customers to sign in, browse events, book tickets, view bookings, and download approved tickets |
| Admin Login | `/admin/login.jsp` | Allows only administrators to access the admin dashboard and permission-based management modules |

### Separation Benefits

- Keeps customer and admin records clearly organized
- Prevents customer login and admin login from being handled through the same interface
- Makes admin access more controlled and easier to protect
- Improves database clarity for reports, debugging, and future scaling
- Supports better enterprise-style authentication design

---

## Multi-Ticket-Type Support

EventHorizon supports multiple ticket categories for a single event. This makes the booking flow closer to real event ticketing platforms.

### Supported Ticket Type Details

Each event can include ticket types such as:

- VIP
- Standard
- Early Bird
- General Admission

Each ticket type can maintain its own:

- price
- total seat count
- available seat count
- booking relationship
- ticket generation data

### Ticket Type Workflow

1. Admin creates an event.
2. Admin defines one or more ticket types.
3. Customer selects a ticket type during booking.
4. The system calculates the total amount based on selected ticket type and quantity.
5. Available seats are updated according to the selected ticket category.
6. Ticket details are preserved in booking and ticket records.

---

## Digital Ticketing and QR Verification

A major feature of EventHorizon is its database-backed digital ticketing and QR verification workflow.

### Ticket Generation Flow

1. Customer creates a booking.
2. Customer submits a payment reference.
3. Admin reviews the payment reference.
4. Admin approves the booking if the payment is valid.
5. The system generates approved ticket records.
6. Each ticket receives a unique verification token.
7. A QR code is generated using the verification link.
8. The customer can view the ticket and download it as a PDF file.

### QR Verification Flow

1. The QR code is scanned.
2. The verification endpoint receives the ticket token.
3. The backend checks the token against the database.
4. If the ticket exists and is approved, the system displays a valid result.
5. If the token is unknown, forged, expired, rejected, already used, or not approved, the system displays an invalid or not-approved result.

### Security Advantage

QR validation is based on backend database verification, not just the QR image itself. This prevents external or fake QR codes from being accepted as valid system tickets.

---

## Downloadable PDF Ticket Feature

EventHorizon supports downloadable PDF tickets for approved bookings. This feature allows customers to download an official digital ticket after the admin approves their submitted payment reference.

The PDF ticket feature improves the professionalism of the system by allowing customers to keep a digital copy of their approved ticket. It also supports event entrance verification through a QR code and backend token validation.

### PDF Ticket Generation Flow

1. Customer creates a booking.
2. Customer submits a manual payment reference.
3. Admin reviews the payment reference.
4. Admin approves the payment.
5. The system generates ticket records with secure QR tokens.
6. Customer opens the booking or ticket page.
7. Customer clicks the **Download PDF Ticket** button.
8. The system generates a PDF ticket dynamically.
9. The PDF file is downloaded to the customer’s device.

### PDF Ticket Content

Each generated PDF ticket includes:

- EventHorizon branding
- Official digital ticket title
- Event name
- Ticket number
- Ticket ID
- Booking ID
- Event ID
- Customer ID
- Ticket type
- Number of tickets
- Total amount
- Booking date
- Payment status
- Ticket status
- Event date and time
- Venue
- Category
- QR code for verification
- Secure ticket token

### Security and Validation

PDF tickets are generated only for approved bookings. A customer cannot download a valid PDF ticket before payment approval.

The QR code inside the PDF ticket is connected to the backend verification system, so the ticket can be checked against the database.

This means edited PDFs, screenshots, copied QR codes, or fake QR codes cannot be trusted unless the backend verification confirms that the ticket exists and belongs to an approved booking.

### Libraries Used for PDF Tickets

| Library | Purpose |
|---|---|
| OpenPDF | Generates downloadable PDF ticket files |
| ZXing | Generates QR codes for ticket verification |

### Main Files Involved in PDF Ticket Feature

```text
pom.xml
src/main/java/com/eventhorizon/servlet/TicketServlet.java
src/main/java/com/eventhorizon/service/TicketService.java
src/main/java/com/eventhorizon/service/BookingService.java
src/main/webapp/myBookings.jsp
src/main/webapp/viewTickets.jsp
```

### Example PDF Ticket URL

```text
/ticket?action=downloadPdf&bookingId=BKG009
```

---

## Business Logic

### Event Logic

- Events include title, category, date, time, venue, description, image, and status.
- Only active events are shown to customers.
- Admins can create, update, cancel, or delete events depending on permission.
- Event availability is connected to ticket type seat availability.

### Booking Logic

- Each booking belongs to a customer.
- Each booking is linked to an event and selected ticket type.
- Booking total is calculated based on ticket type price and quantity.
- Seat availability is reduced when a booking is created.
- Seats can be restored when bookings are cancelled or rejected.
- Booking status and payment status are tracked separately for clearer workflow control.

### Payment Logic

- Customers submit manual payment references.
- Admins review payment references from the dashboard.
- Valid payments can be approved.
- Invalid payments can be rejected.
- Ticket generation depends on payment approval.

### Ticket Logic

- Tickets are created only after admin payment approval.
- Each ticket receives a secure token.
- Tickets can be viewed by approved customers.
- Approved tickets can be downloaded as PDF files.
- Each PDF ticket includes booking, event, payment, and ticket details.
- Each PDF ticket includes a QR code for verification.
- QR verification is handled through backend database validation.
- Ticket validity is checked using database records.
- Ticket status supports approved, valid, already-used, and not-approved verification outcomes.

### Admin Workflow Logic

- Admin access can be request-based.
- Admin accounts are stored separately from customer accounts.
- Requests remain pending until reviewed.
- Approved requests grant permission-specific access.
- Admin dashboard modules are shown based on permission level.
- Full access and core admin roles provide broader management capabilities.

---

## Project Structure

```text
EventHorizon/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/eventhorizon/
│       │       ├── model/
│       │       │   ├── User.java
│       │       │   ├── Admin.java
│       │       │   ├── Customer.java
│       │       │   ├── Event.java
│       │       │   ├── Booking.java
│       │       │   ├── Ticket.java
│       │       │   └── EventTicketType.java
│       │       ├── service/
│       │       │   ├── UserService.java
│       │       │   ├── EventService.java
│       │       │   ├── BookingService.java
│       │       │   ├── TicketService.java
│       │       │   ├── EventTicketTypeService.java
│       │       │   └── IssueService.java
│       │       ├── servlet/
│       │       │   ├── UserServlet.java
│       │       │   ├── EventServlet.java
│       │       │   ├── BookingServlet.java
│       │       │   ├── TicketServlet.java
│       │       │   └── IssueServlet.java
│       │       └── util/
│       │           └── DatabaseConnection.java
│       ├── resources/
│       └── webapp/
│           ├── admin/
│           │   ├── login.jsp
│           │   ├── dashboard.jsp
│           │   ├── events.jsp
│           │   ├── addEvent.jsp
│           │   ├── editEvent.jsp
│           │   ├── bookings.jsp
│           │   ├── managePayments.jsp
│           │   ├── users.jsp
│           │   ├── addAdmin.jsp
│           │   ├── adminRequests.jsp
│           │   ├── issues.jsp
│           │   ├── issueDetails.jsp
│           │   ├── scanTicket.jsp
│           │   └── layout.jsp
│           ├── css/
│           │   ├── style.css
│           │   ├── admin.css
│           │   └── dashboard.css
│           ├── js/
│           ├── images/
│           ├── WEB-INF/
│           │   └── web.xml
│           ├── index.jsp
│           ├── events.jsp
│           ├── eventDetail.jsp
│           ├── checkout.jsp
│           ├── myBookings.jsp
│           ├── viewTickets.jsp
│           ├── verifyTicket.jsp
│           ├── profile.jsp
│           ├── login.jsp
│           ├── register.jsp
│           ├── aboutUs.jsp
│           ├── contacts.jsp
│           ├── faqs.jsp
│           ├── reportIssue.jsp
│           ├── issueDetailsCustomer.jsp
│           ├── privacyPolicy.jsp
│           ├── ticketPolicy.jsp
│           └── termsConditions.jsp
├── database/
│   └── 01_split_users_into_customers_and_admins.sql
├── pom.xml
├── Dockerfile
├── README.md
└── .gitignore
```

### Important File Responsibilities

| File | Responsibility |
|---|---|
| `UserServlet.java` | Handles customer registration/login, dedicated admin login, logout, profile updates, admin requests, and account management routing |
| `UserService.java` | Handles separated customer/admin authentication, registration, admin request approval, account listing, profile updates, and permission checks |
| `BookingServlet.java` | Handles checkout, booking creation, cancellation, payment approval, and booking routing |
| `BookingService.java` | Contains booking business logic, seat updates, payment approval, rejection, and ticket generation trigger |
| `TicketServlet.java` | Handles ticket viewing, QR image generation, QR verification, admin scan page routing, and downloadable PDF ticket generation |
| `TicketService.java` | Generates tickets, creates QR tokens, retrieves tickets, and verifies ticket validity |
| `EventTicketTypeService.java` | Manages multiple ticket types, prices, total seats, and available seats |
| `DatabaseConnection.java` | Handles local and Railway MySQL database connection logic |
| `pom.xml` | Manages Maven build settings and dependencies such as Servlet API, MySQL, JavaMail, ZXing, and OpenPDF |

---

## Deployment Summary

| Component | Description |
|---|---|
| Hosting Platform | Railway |
| Application Runtime | Apache Tomcat |
| Backend | Java Servlets and JSP |
| Database | Railway MySQL |
| Configuration | Environment variables |
| Public Domain | `https://www.eventhorizonapp.online/` |
| Default Railway URL | `https://glistening-light-production-f277.up.railway.app/` |
| Database Access | JDBC |
| Build Method | Maven WAR deployment |

### Environment Variables

The deployed application can be configured with database environment variables such as:

```text
MYSQLHOST=
MYSQLPORT=
MYSQLDATABASE=
MYSQLUSER=
MYSQLPASSWORD=
```

The application can use these variables to connect to the Railway MySQL database in production. The production database contains separated account tables for `customers` and `admins`, while legacy user data can be preserved in a backup table during migration.

For ticket security, the application can also use a ticket secret environment variable:

```text
TICKET_HMAC_SECRET=
```

If this value is not configured, the application can use the default development secret defined in the ticket service.

---

## Local Development Setup

### Prerequisites

- Java JDK
- Apache Maven
- Apache Tomcat
- MySQL Server or XAMPP
- IntelliJ IDEA
- Git

### Basic Setup Steps

1. Clone the repository.

```bash
git clone <repository-url>
```

2. Open the project in IntelliJ IDEA.

3. Configure the MySQL database.

4. Run the account separation migration if the database still uses the old combined `users` table.

```sql
SOURCE database/01_split_users_into_customers_and_admins.sql;
```

5. Update database connection settings for the local environment.

6. Build the project using Maven.

```bash
mvn clean package
```

7. Deploy the generated WAR file to Apache Tomcat.

8. Open the application in the browser.

```text
http://localhost:8080/EventHorizon
```

Customer login:

```text
http://localhost:8080/EventHorizon/login.jsp
```

Admin login:

```text
http://localhost:8080/EventHorizon/admin/login.jsp
```

### Maven Dependency Notes

The project uses Maven dependencies for:

- Servlet and JSP support
- JSTL support
- MySQL database connection
- Email support
- QR code generation using ZXing
- PDF ticket generation using OpenPDF

If IntelliJ does not recognize OpenPDF or ZXing classes, reload Maven:

```text
Right click pom.xml → Maven → Reload Project
```

Or run:

```bash
mvn -U clean package
```

---

## Project Highlights

- Full-stack Java web application
- Professional event booking workflow
- Clean JSP, Servlet, JDBC, and MySQL integration
- Separate customer and admin database tables
- Dedicated customer and admin login pages
- Customer and admin role separation
- Permission-based admin dashboard
- Multi-ticket-type support
- Manual payment approval workflow
- Digital ticket generation
- Downloadable PDF ticket support
- QR-based ticket verification
- Database-backed validation logic
- Railway cloud deployment
- Custom domain integration
- Structured and scalable project architecture

---

## Future Improvements

- Password hashing and stronger credential security
- Online payment gateway integration
- Email notification improvements
- Advanced analytics dashboard
- Better image storage strategy
- Audit logging for admin actions
- Automated booking expiry handling
- Enhanced customer notification system
- Downloadable invoice generation
- More advanced QR scan history tracking
- Email delivery of approved PDF tickets
- Admin-side ticket scan history reports

---

## Status

The project is actively maintained as a full-stack academic web application and continues to evolve with improved UI, better workflow handling, stronger admin access control, digital ticketing, QR verification, and downloadable PDF ticket generation.

The latest completed account-management improvement is the separation of customer and admin accounts into dedicated database tables with separate customer and admin login pages. The downloadable PDF ticket system is also completed, allowing approved customers to download official EventHorizon PDF tickets containing event details, booking details, payment status, ticket status, and QR-based verification support.

---
