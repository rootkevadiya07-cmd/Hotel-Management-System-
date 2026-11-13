-- =======================================================
-- HOTEL MANAGEMENT SYSTEM - DATABASE SCHEMA & SEED DATA
-- Database: MySQL 8.0+
-- =======================================================

DROP DATABASE IF EXISTS hotel_db;
CREATE DATABASE hotel_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hotel_db;

-- 1. USERS TABLE (Authentication & Role Management)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL DEFAULT 'STAFF',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. ROOMS TABLE (Inventory & Room Configuration)
CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    room_type VARCHAR(50) NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL,
    capacity INT NOT NULL DEFAULT 1,
    status VARCHAR(30) NOT NULL DEFAULT 'Available',
    amenities TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. CUSTOMERS TABLE (Guest Profiles & ID Verification)
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    id_proof_type VARCHAR(50) NOT NULL,
    id_proof_number VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. BOOKINGS TABLE (Reservations & Stay Schedule)
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_days INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    booking_status VARCHAR(30) NOT NULL DEFAULT 'Confirmed',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_booking_room FOREIGN KEY (room_id) 
        REFERENCES rooms(room_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. PAYMENTS TABLE (Billing & Transaction Ledgers)
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(30) NOT NULL DEFAULT 'Completed',
    transaction_id VARCHAR(100),
    remarks TEXT,
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) 
        REFERENCES bookings(booking_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. STAFF TABLE (Hotel Staff Directory & Payroll)
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    shift VARCHAR(30) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Active',
    hire_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =======================================================
-- SEED DATA
-- =======================================================

-- Admin & Staff Users (Passwords stored as SHA-256 hashed or plaintext checked)
-- admin123 SHA-256 = 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
-- staff123 SHA-256 = 19ac1204ee7447db0c20986ebf45811c750b2c159ccaa1451f1f5093e1176b6b
INSERT INTO users (username, password, full_name, email, role) VALUES
('admin', 'admin123', 'Administrator', 'admin@grandazure.com', 'ADMIN'),
('reception', 'staff123', 'Sarah Jenkins', 'reception@grandazure.com', 'STAFF');

-- Sample Rooms
INSERT INTO rooms (room_number, room_type, price_per_night, capacity, status, amenities, description) VALUES
('101', 'Single Room', 1200.00, 1, 'Available', 'Free High-speed Wi-Fi, Single Bed, Air Conditioning, Smart LED TV, Work Desk', 'Cozy single room ideal for solo travelers and business visits.'),
('102', 'Single Room', 1200.00, 1, 'Occupied', 'Free High-speed Wi-Fi, Single Bed, Air Conditioning, Smart LED TV, Hot Shower', 'Comfortable single room facing quiet inner courtyard.'),
('201', 'Double Room', 2200.00, 2, 'Available', 'Free Wi-Fi, Queen Size Bed, Air Conditioning, 43-inch TV, Mini Refrigerator, Coffee Maker', 'Spacious double room equipped for couples or travel partners.'),
('202', 'Double Room', 2200.00, 2, 'Available', 'Free Wi-Fi, Twin Beds, Air Conditioning, 43-inch TV, Balcony with Garden View', 'Bright twin double room with panoramic garden view balcony.'),
('301', 'Deluxe Room', 3800.00, 3, 'Occupied', 'Free High-speed Wi-Fi, King Bed + Sofa, 55-inch OLED TV, Mini Bar, Bathtub, Luxury Toiletries', 'Premium deluxe retreat with marble bathroom and city view.'),
('302', 'Deluxe Room', 3800.00, 3, 'Maintenance', 'Free High-speed Wi-Fi, King Bed, Smart Automation, Bathtub, Soundproof Windows', 'Scheduled routine plumbing inspection and deep sanitation.'),
('401', 'Suite Room', 6500.00, 4, 'Available', 'Free Ultra-fast Wi-Fi, Master King Bedroom, Separate Living Room, Jacuzzi, Dining Area, Butler Service', 'Executive presidential suite offering five-star luxury and panoramic city skyline views.'),
('402', 'Suite Room', 6500.00, 4, 'Available', 'Free Ultra-fast Wi-Fi, Two Master Bedrooms, Jacuzzi, Private Balcony Lounge, Espresso Bar', 'Ultimate luxury family suite with private sun deck and customized amenities.');

-- Sample Customers
INSERT INTO customers (full_name, email, phone, address, id_proof_type, id_proof_number) VALUES
('Alexander Wright', 'alex.wright@example.com', '+1-555-019-2831', '742 Evergreen Terrace, Springfield, OR', 'Passport', 'P98234120'),
('Priya Sharma', 'priya.sharma@example.com', '+91-98765-43210', 'B-42 Lakeview Apartments, Mumbai, MH', 'Aadhaar', '8374-9182-3746'),
('Michael Chen', 'mchen@example.com', '+1-555-482-9102', '120 Market Street, San Francisco, CA', 'Driving License', 'DL-CA-993821'),
('Emily Watson', 'emily.watson@example.com', '+44-7700-900451', '221B Baker Street, London, UK', 'Passport', 'UK-55421098');

-- Sample Bookings
INSERT INTO bookings (booking_number, customer_id, room_id, check_in_date, check_out_date, total_days, total_amount, booking_status, notes) VALUES
('BK-202611-1001', 1, 2, '2026-11-10', '2026-11-15', 5, 6000.00, 'Checked-In', 'Customer requested late check-in and extra towels.'),
('BK-202611-1002', 2, 5, '2026-11-12', '2026-11-16', 4, 15200.00, 'Checked-In', 'Deluxe suite booking, airport pick-up arranged.'),
('BK-202611-1003', 3, 3, '2026-11-20', '2026-11-23', 3, 6600.00, 'Confirmed', 'Advance reservation for upcoming tech symposium.'),
('BK-202611-1004', 4, 7, '2026-11-01', '2026-11-05', 4, 26000.00, 'Checked-Out', 'VIP guest - Suite room stay completed with 5-star rating.');

-- Sample Payments
INSERT INTO payments (booking_id, payment_date, amount, payment_method, payment_status, transaction_id, remarks) VALUES
(1, '2026-11-10 14:30:00', 6000.00, 'Card', 'Completed', 'TXN-CARD-891023', 'Full payment received upon check-in.'),
(2, '2026-11-12 11:15:00', 15200.00, 'UPI', 'Completed', 'UPI-9823412098@hdfc', 'Advance UPI transfer verified.'),
(3, '2026-11-13 09:00:00', 6600.00, 'Card', 'Completed', 'TXN-CARD-449102', 'Online card payment for reservation.'),
(4, '2026-11-01 16:45:00', 26000.00, 'Cash', 'Completed', 'CASH-REC-1004', 'Paid in full in cash at front desk checkout.');

-- Sample Staff Members
INSERT INTO staff (full_name, role, shift, phone, email, salary, status, hire_date) VALUES
('David Miller', 'General Manager', 'Morning', '+1-555-112-9901', 'dmiller@grandazure.com', 75000.00, 'Active', '2022-01-15'),
('Sarah Jenkins', 'Front Desk Supervisor', 'Morning', '+1-555-112-9902', 'sjenkins@grandazure.com', 42000.00, 'Active', '2022-06-01'),
('Carlos Ramirez', 'Housekeeping Lead', 'Evening', '+1-555-112-9903', 'cramirez@grandazure.com', 32000.00, 'Active', '2023-03-10'),
('Vikram Mehta', 'Executive Chef', 'Morning', '+1-555-112-9904', 'vmehta@grandazure.com', 58000.00, 'Active', '2023-08-20'),
('Marcus Vance', 'Security Officer', 'Night', '+1-555-112-9905', 'mvance@grandazure.com', 30000.00, 'Active', '2024-02-01');
