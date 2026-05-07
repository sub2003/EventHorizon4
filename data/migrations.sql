-- ============================================================
-- EventHorizon – Payment & Ticket System Migration
-- Run this against your eventhorizon_db database.
-- ============================================================

-- 1. Add payment columns to the bookings table
ALTER TABLE bookings
    ADD COLUMN IF NOT EXISTS payment_status    VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    ADD COLUMN IF NOT EXISTS payment_reference VARCHAR(150) NULL;

-- 2. Existing/future CONFIRMED bookings that had no payment system
--    are backfilled as APPROVED so they still show correctly.
UPDATE bookings SET payment_status = 'APPROVED' WHERE status = 'CONFIRMED';

-- 3. Create tickets table
CREATE TABLE IF NOT EXISTS tickets (
    ticket_id   VARCHAR(40)  NOT NULL PRIMARY KEY,  -- UUID
    booking_id  VARCHAR(20)  NOT NULL,
    event_id    VARCHAR(20)  NOT NULL,
    customer_id VARCHAR(20)  NOT NULL,
    qr_token    VARCHAR(255) NOT NULL UNIQUE,        -- HMAC-SHA256 signature
    is_used     TINYINT(1)   NOT NULL DEFAULT 0,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
