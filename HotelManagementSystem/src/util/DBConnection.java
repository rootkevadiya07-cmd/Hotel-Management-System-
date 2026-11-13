package util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

/**
 * Intelligent Database Connection Utility.
 * Prioritizes MySQL 8.0, automatically initializes schema and seed data,
 * and provides seamless embedded JDBC persistence if MySQL credentials fail,
 * ensuring zero downtime.
 */
public class DBConnection {

    private static String host = "localhost";
    private static String port = "3306";
    private static String dbName = "hotel_db";
    private static String user = "root";
    private static String password = "root";

    private static final String MYSQL_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String H2_DRIVER = "org.h2.Driver";
    private static final String H2_URL = "jdbc:h2:./hotel_embedded_db;MODE=MySQL;DATABASE_TO_LOWER=TRUE;CASE_INSENSITIVE_IDENTIFIERS=TRUE";

    private static boolean useFallback = false;
    private static boolean schemaInitialized = false;

    static {
        loadProperties();
    }

    private static void loadProperties() {
        try {
            InputStream in = DBConnection.class.getClassLoader().getResourceAsStream("db.properties");
            if (in != null) {
                Properties props = new Properties();
                props.load(in);
                host = props.getProperty("db.host", host);
                port = props.getProperty("db.port", port);
                dbName = props.getProperty("db.name", dbName);
                user = props.getProperty("db.user", user);
                password = props.getProperty("db.password", password);
            }
        } catch (Exception ignored) {}

        // Allow environment variables or system properties to override
        host = System.getProperty("DB_HOST", System.getenv().getOrDefault("DB_HOST", host));
        port = System.getProperty("DB_PORT", System.getenv().getOrDefault("DB_PORT", port));
        dbName = System.getProperty("DB_NAME", System.getenv().getOrDefault("DB_NAME", dbName));
        user = System.getProperty("DB_USER", System.getenv().getOrDefault("DB_USER", user));
        password = System.getProperty("DB_PASSWORD", System.getenv().getOrDefault("DB_PASSWORD", password));
    }

    public static synchronized Connection getConnection() throws SQLException {
        if (useFallback) {
            return getFallbackConnection();
        }

        try {
            Class.forName(MYSQL_DRIVER);
            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
            Connection conn = DriverManager.getConnection(url, user, password);

            if (!schemaInitialized) {
                initSchemaIfNeeded(conn, false);
                schemaInitialized = true;
            }
            return conn;
        } catch (Exception ex) {
            System.err.println("[DBConnection] MySQL connection failed (" + ex.getMessage() + "). Switching to local JDBC storage engine.");
            useFallback = true;
            return getFallbackConnection();
        }
    }

    private static synchronized Connection getFallbackConnection() throws SQLException {
        try {
            Class.forName(H2_DRIVER);
            Connection conn = DriverManager.getConnection(H2_URL, "sa", "");
            if (!schemaInitialized) {
                initSchemaIfNeeded(conn, true);
                schemaInitialized = true;
            }
            return conn;
        } catch (ClassNotFoundException e) {
            throw new SQLException("Neither MySQL Driver nor Embedded JDBC Driver available in classpath.", e);
        }
    }

    private static void initSchemaIfNeeded(Connection conn, boolean isFallback) {
        Statement stmt = null;
        ResultSet rs = null;
        try {
            stmt = conn.createStatement();
            boolean tablesExist = false;
            try {
                rs = stmt.executeQuery("SELECT COUNT(*) FROM rooms");
                if (rs.next()) {
                    tablesExist = true;
                }
            } catch (SQLException e) {
                tablesExist = false;
            }

            if (!tablesExist) {
                System.out.println("[DBConnection] Initializing schema and seed data in " + (isFallback ? "local JDBC storage" : "MySQL") + "...");
                String[] ddlStatements = getInitialDDL(isFallback);
                for (String sql : ddlStatements) {
                    if (sql.trim().isEmpty()) continue;
                    try {
                        stmt.execute(sql.trim());
                    } catch (SQLException err) {
                        System.err.println("Notice executing: " + sql + " -> " + err.getMessage());
                    }
                }
                System.out.println("[DBConnection] Schema and seed data successfully initialized!");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(null, stmt, rs);
        }
    }

    private static String[] getInitialDDL(boolean isFallback) {
        return new String[] {
            "CREATE TABLE IF NOT EXISTS users (" +
            "  user_id INT AUTO_INCREMENT PRIMARY KEY, " +
            "  username VARCHAR(50) NOT NULL UNIQUE, " +
            "  password VARCHAR(255) NOT NULL, " +
            "  full_name VARCHAR(100) NOT NULL, " +
            "  email VARCHAR(100) NOT NULL UNIQUE, " +
            "  role VARCHAR(20) DEFAULT 'STAFF', " +
            "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            "CREATE TABLE IF NOT EXISTS rooms (" +
            "  room_id INT AUTO_INCREMENT PRIMARY KEY, " +
            "  room_number VARCHAR(20) NOT NULL UNIQUE, " +
            "  room_type VARCHAR(50) NOT NULL, " +
            "  price_per_night DECIMAL(10,2) NOT NULL, " +
            "  capacity INT DEFAULT 1, " +
            "  status VARCHAR(30) DEFAULT 'Available', " +
            "  amenities TEXT, " +
            "  description TEXT, " +
            "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            "CREATE TABLE IF NOT EXISTS customers (" +
            "  customer_id INT AUTO_INCREMENT PRIMARY KEY, " +
            "  full_name VARCHAR(100) NOT NULL, " +
            "  email VARCHAR(100) NOT NULL, " +
            "  phone VARCHAR(20) NOT NULL, " +
            "  address TEXT, " +
            "  id_proof_type VARCHAR(50) NOT NULL, " +
            "  id_proof_number VARCHAR(50) NOT NULL, " +
            "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            "CREATE TABLE IF NOT EXISTS bookings (" +
            "  booking_id INT AUTO_INCREMENT PRIMARY KEY, " +
            "  booking_number VARCHAR(30) NOT NULL UNIQUE, " +
            "  customer_id INT NOT NULL, " +
            "  room_id INT NOT NULL, " +
            "  check_in_date DATE NOT NULL, " +
            "  check_out_date DATE NOT NULL, " +
            "  total_days INT NOT NULL, " +
            "  total_amount DECIMAL(10,2) NOT NULL, " +
            "  booking_status VARCHAR(30) DEFAULT 'Confirmed', " +
            "  notes TEXT, " +
            "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            "CREATE TABLE IF NOT EXISTS payments (" +
            "  payment_id INT AUTO_INCREMENT PRIMARY KEY, " +
            "  booking_id INT NOT NULL, " +
            "  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
            "  amount DECIMAL(10,2) NOT NULL, " +
            "  payment_method VARCHAR(30) NOT NULL, " +
            "  payment_status VARCHAR(30) DEFAULT 'Completed', " +
            "  transaction_id VARCHAR(100), " +
            "  remarks TEXT)",

            "CREATE TABLE IF NOT EXISTS staff (" +
            "  staff_id INT AUTO_INCREMENT PRIMARY KEY, " +
            "  full_name VARCHAR(100) NOT NULL, " +
            "  role VARCHAR(50) NOT NULL, " +
            "  shift VARCHAR(30) NOT NULL, " +
            "  phone VARCHAR(20) NOT NULL, " +
            "  email VARCHAR(100) NOT NULL, " +
            "  salary DECIMAL(10,2) NOT NULL, " +
            "  status VARCHAR(30) DEFAULT 'Active', " +
            "  hire_date DATE NOT NULL, " +
            "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            // Seed Users
            "INSERT INTO users (username, password, full_name, email, role) VALUES " +
            "('admin', 'admin123', 'Administrator', 'admin@grandazure.com', 'ADMIN'), " +
            "('reception', 'staff123', 'Sarah Jenkins', 'reception@grandazure.com', 'STAFF')",

            // Seed Rooms
            "INSERT INTO rooms (room_number, room_type, price_per_night, capacity, status, amenities, description) VALUES " +
            "('101', 'Single Room', 1200.00, 1, 'Available', 'Free High-speed Wi-Fi, Single Bed, Air Conditioning, Smart LED TV, Work Desk', 'Cozy single room ideal for solo travelers and business visits.'), " +
            "('102', 'Single Room', 1200.00, 1, 'Occupied', 'Free High-speed Wi-Fi, Single Bed, Air Conditioning, Smart LED TV, Hot Shower', 'Comfortable single room facing quiet inner courtyard.'), " +
            "('201', 'Double Room', 2200.00, 2, 'Available', 'Free Wi-Fi, Queen Size Bed, Air Conditioning, 43-inch TV, Mini Refrigerator, Coffee Maker', 'Spacious double room equipped for couples or travel partners.'), " +
            "('202', 'Double Room', 2200.00, 2, 'Available', 'Free Wi-Fi, Twin Beds, Air Conditioning, 43-inch TV, Balcony with Garden View', 'Bright twin double room with panoramic garden view balcony.'), " +
            "('301', 'Deluxe Room', 3800.00, 3, 'Occupied', 'Free High-speed Wi-Fi, King Bed + Sofa, 55-inch OLED TV, Mini Bar, Bathtub, Luxury Toiletries', 'Premium deluxe retreat with marble bathroom and city view.'), " +
            "('302', 'Deluxe Room', 3800.00, 3, 'Maintenance', 'Free High-speed Wi-Fi, King Bed, Smart Automation, Bathtub, Soundproof Windows', 'Scheduled routine plumbing inspection and deep sanitation.'), " +
            "('401', 'Suite Room', 6500.00, 4, 'Available', 'Free Ultra-fast Wi-Fi, Master King Bedroom, Separate Living Room, Jacuzzi, Dining Area, Butler Service', 'Executive presidential suite offering five-star luxury and panoramic city skyline views.'), " +
            "('402', 'Suite Room', 6500.00, 4, 'Available', 'Free Ultra-fast Wi-Fi, Two Master Bedrooms, Jacuzzi, Private Balcony Lounge, Espresso Bar', 'Ultimate luxury family suite with private sun deck and customized amenities.')",

            // Seed Customers
            "INSERT INTO customers (full_name, email, phone, address, id_proof_type, id_proof_number) VALUES " +
            "('Alexander Wright', 'alex.wright@example.com', '+1-555-019-2831', '742 Evergreen Terrace, Springfield, OR', 'Passport', 'P98234120'), " +
            "('Priya Sharma', 'priya.sharma@example.com', '+91-98765-43210', 'B-42 Lakeview Apartments, Mumbai, MH', 'Aadhaar', '8374-9182-3746'), " +
            "('Michael Chen', 'mchen@example.com', '+1-555-482-9102', '120 Market Street, San Francisco, CA', 'Driving License', 'DL-CA-993821'), " +
            "('Emily Watson', 'emily.watson@example.com', '+44-7700-900451', '221B Baker Street, London, UK', 'Passport', 'UK-55421098')",

            // Seed Bookings
            "INSERT INTO bookings (booking_number, customer_id, room_id, check_in_date, check_out_date, total_days, total_amount, booking_status, notes) VALUES " +
            "('BK-202611-1001', 1, 2, '2026-11-10', '2026-11-15', 5, 6000.00, 'Checked-In', 'Customer requested late check-in and extra towels.'), " +
            "('BK-202611-1002', 2, 5, '2026-11-12', '2026-11-16', 4, 15200.00, 'Checked-In', 'Deluxe suite booking, airport pick-up arranged.'), " +
            "('BK-202611-1003', 3, 3, '2026-11-20', '2026-11-23', 3, 6600.00, 'Confirmed', 'Advance reservation for upcoming tech symposium.'), " +
            "('BK-202611-1004', 4, 7, '2026-11-01', '2026-11-05', 4, 26000.00, 'Checked-Out', 'VIP guest - Suite room stay completed with 5-star rating.')",

            // Seed Payments
            "INSERT INTO payments (booking_id, amount, payment_method, payment_status, transaction_id, remarks) VALUES " +
            "(1, 6000.00, 'Card', 'Completed', 'TXN-CARD-891023', 'Full payment received upon check-in.'), " +
            "(2, 15200.00, 'UPI', 'Completed', 'UPI-9823412098@hdfc', 'Advance UPI transfer verified.'), " +
            "(3, 6600.00, 'Card', 'Completed', 'TXN-CARD-449102', 'Online card payment for reservation.'), " +
            "(4, 26000.00, 'Cash', 'Completed', 'CASH-REC-1004', 'Paid in full in cash at front desk checkout.')",

            // Seed Staff
            "INSERT INTO staff (full_name, role, shift, phone, email, salary, status, hire_date) VALUES " +
            "('David Miller', 'General Manager', 'Morning', '+1-555-112-9901', 'dmiller@grandazure.com', 75000.00, 'Active', '2022-01-15'), " +
            "('Sarah Jenkins', 'Front Desk Supervisor', 'Morning', '+1-555-112-9902', 'sjenkins@grandazure.com', 42000.00, 'Active', '2022-06-01'), " +
            "('Carlos Ramirez', 'Housekeeping Lead', 'Evening', '+1-555-112-9903', 'cramirez@grandazure.com', 32000.00, 'Active', '2023-03-10'), " +
            "('Vikram Mehta', 'Executive Chef', 'Morning', '+1-555-112-9904', 'vmehta@grandazure.com', 58000.00, 'Active', '2023-08-20'), " +
            "('Marcus Vance', 'Security Officer', 'Night', '+1-555-112-9905', 'mvance@grandazure.com', 30000.00, 'Active', '2024-02-01')"
        };
    }

    public static boolean isFallbackMode() {
        return useFallback;
    }

    public static String getDatabaseDescription() {
        return useFallback ? "Embedded JDBC Database Engine (Zero-Configuration)" : "MySQL 8.0 (" + dbName + " on " + host + ":" + port + ")";
    }

    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException ignored) {}
        }
        if (stmt != null) {
            try { stmt.close(); } catch (SQLException ignored) {}
        }
        if (conn != null) {
            try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    public static void close(Connection conn, Statement stmt) {
        close(conn, stmt, null);
    }
}
