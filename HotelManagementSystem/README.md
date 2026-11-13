# Grand Azure - Hotel Management System (HMS)

A complete, enterprise-grade **Hotel Management System** with a modern, responsive frontend (Bootstrap 5, Chart.js, FontAwesome) and a backend engineered strictly in **Pure Java** (Java Servlets, JSP, JDBC, MySQL, Apache Tomcat).

---

## 1. Technology Stack

* **Frontend:** HTML5, CSS3, JavaScript (ES6+), Bootstrap 5.3, FontAwesome 6, Chart.js.
* **Backend (Java Only):**
  * Core Java (JDK 17+)
  * Java Servlets (`jakarta.servlet.http.HttpServlet`)
  * JavaServer Pages (JSP)
  * Java Database Connectivity (JDBC) with `PreparedStatement` & Connection Pooling
  * Apache Tomcat 10.x / 11.x (Jakarta EE standard)
  * MySQL 8.0+ Database Server
* **Architecture:** Strict Model-View-Controller (MVC) and Data Access Object (DAO) design patterns.

---

## 2. Directory Structure

```text
HotelManagementSystem/
├── .classpath                              # Eclipse IDE Classpath Configuration
├── .project                                # Eclipse IDE Project Metadata
├── .settings/                              # Eclipse Facet & Web Component Metadata
├── build.bat                               # Windows 1-Click Java Compilation Script
├── compile.ps1                             # PowerShell Source Compiler Script
├── pom.xml                                 # Maven Dependency & Build Descriptor
├── README.md                               # Complete Documentation & Setup Guide
├── database/
│   └── hotel_management.sql               # MySQL Schema Creation & Seed Data Script
├── src/
│   ├── controller/                         # Java Servlets (HTTP Handlers & MVC Controllers)
│   │   ├── AuthFilter.java                 # Session Authentication Security Filter
│   │   ├── BookingServlet.java             # Room Reservation & Availability Controller
│   │   ├── CheckInOutServlet.java          # Check-in and Check-out Lifecycle Controller
│   │   ├── CustomerServlet.java            # Guest Profile Management Controller
│   │   ├── DashboardServlet.java           # Executive Dashboard Analytics Controller
│   │   ├── LoginServlet.java               # Authentication & Session Login Handler
│   │   ├── LogoutServlet.java              # Session Invalidation & Logout Handler
│   │   ├── PaymentServlet.java             # Billing, Payment & Invoice Controller
│   │   ├── ReportServlet.java              # Business Intelligence & Reports Controller
│   │   ├── RoomServlet.java                # Room Inventory CRUD Controller
│   │   └── StaffServlet.java               # Hotel Staff Directory Controller
│   ├── dao/                                # Data Access Objects (Raw SQL & PreparedStatements)
│   │   ├── BookingDAO.java                 # Reservation SQL Queries & Overlap Prevention
│   │   ├── CustomerDAO.java                # Guest SQL CRUD Operations
│   │   ├── PaymentDAO.java                 # Payment & Financial Ledgers SQL
│   │   ├── ReportDAO.java                  # Aggregation, Metrics & KPI Queries
│   │   ├── RoomDAO.java                    # Room Inventory SQL Operations
│   │   ├── StaffDAO.java                   # Staff Roster SQL Operations
│   │   └── UserDAO.java                    # User Authentication & Security Queries
│   ├── model/                              # Plain Old Java Objects (POJO Data Entities)
│   │   ├── Booking.java                    # Reservation Entity with Stay Schedule
│   │   ├── Customer.java                   # Guest Profile & ID Verification Entity
│   │   ├── DashboardStats.java             # Dashboard Aggregated Metrics POJO
│   │   ├── Payment.java                    # Financial Transaction Entity
│   │   ├── Room.java                       # Room Inventory Entity
│   │   ├── Staff.java                      # Employee & Payroll Entity
│   │   └── User.java                       # User Account Entity
│   ├── service/                            # Core Business Logic Layer
│   │   ├── BookingService.java             # Cost Calculation, Date Overlap Prevention & State Flow
│   │   ├── PaymentService.java             # Payment Rules, Txn IDs & Balance Reconciliation
│   │   └── RoomService.java                # Room Inventory Validations
│   ├── test/                               # Verification & Unit Validation Suite
│   │   └── SystemValidationTest.java       # Automated Business Logic Test Runner
│   └── util/                               # Core Utilities
│       ├── DBConnection.java               # MySQL JDBC Driver & Connection Management
│       └── PasswordUtil.java               # SHA-256 Cryptographic Password Hashing
└── WebContent/                             # Dynamic Web Module Document Base
    ├── css/
    │   └── style.css                       # Modern UI Stylesheet & Print Media Rules
    ├── js/
    │   └── main.js                         # Dynamic Cost Calculations, Clock & Modals
    ├── admin/                              # Administration & Management Views (JSP)
    │   ├── header.jsp                      # Sidebar Navigation & Top Navbar
    │   ├── footer.jsp                      # Shared Scripts & Modals
    │   ├── dashboard.jsp                   # Executive Dashboard KPI Cards & Activity
    │   ├── rooms.jsp                       # Room Inventory Management & Filters
    │   ├── customers.jsp                   # Guest Profile Directory & Search
    │   ├── bookings.jsp                    # Reservation Management & Booking Modals
    │   ├── payments.jsp                    # Payment Records & Direct Payment Modals
    │   ├── invoice.jsp                     # Printable Five-Star Guest Folio / Tax Invoice
    │   ├── staff.jsp                       # Staff Directory, Shift Roster & Payroll
    │   └── reports.jsp                     # Monthly Revenue & Occupancy Charts (Chart.js)
    ├── index.jsp                           # Public Guest Portal & Instant Reservation
    ├── login.jsp                           # Administrative & Staff Sign-In Portal
    └── WEB-INF/
        ├── classes/                        # Compiled Java Bytecode Classes
        ├── lib/                            # JDBC Connector & Embedded Tomcat Libraries
        │   ├── mysql-connector-j-8.3.0.jar
        │   └── tomcat-embed-core-10.1.30.jar
        └── web.xml                         # Deployment Descriptor (Filters & Sessions)
```

---

## 3. Database Configuration (MySQL)

### Step 1: Execute Database SQL Script
1. Open **MySQL Workbench** or your terminal CLI (`mysql -u root -p`).
2. Run the script located at `database/hotel_management.sql`:
   ```sql
   source /path/to/HotelManagementSystem/database/hotel_management.sql;
   ```
   *(Or in MySQL Workbench: File -> Open SQL Script -> Select `hotel_management.sql` -> Click the Execute Lightning Bolt icon).*

This creates the database `hotel_db` and all 6 relational tables with primary keys, foreign key constraints, and realistic seed data:
* `users`: Authentication records for Admin & Reception staff.
* `rooms`: Room numbers, categories, nightly pricing, capacity, amenities.
* `customers`: Guest profiles, phones, emails, and verified government ID proofs.
* `bookings`: Reservations linked to customers and rooms with stay dates and calculated totals.
* `payments`: Transaction ledgers linked to bookings (Cash, UPI, Card).
* `staff`: Hotel staff directory, shifts, salaries, and employment statuses.

### Step 2: Configure JDBC Connection Credentials
Open `src/util/DBConnection.java`:
```java
private static final String DEFAULT_HOST = "localhost";
private static final String DEFAULT_PORT = "3306";
private static final String DEFAULT_DB   = "hotel_db";
private static final String DEFAULT_USER = "root";
private static final String DEFAULT_PASS = "your_mysql_password"; // Set your password here
```
*Note: You can also pass credentials through environment variables (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`) without changing the code.*

---

## 4. Default Sample Login Credentials

| Role | Username | Password | Purpose |
| :--- | :--- | :--- | :--- |
| **System Administrator** | `admin` | `admin123` | Full access to Dashboard, Rooms, Bookings, Payments, Staff, Reports |
| **Front Desk Staff** | `reception` | `staff123` | Front desk reservations, check-in, check-out, bill collection |

*(On `login.jsp`, interactive sample credential pills are provided for 1-click auto-fill).*

---

## 5. How to Run the Application

### Option A: Running in Eclipse IDE (Recommended for Dynamic Web Projects)
1. **Open Eclipse IDE for Enterprise Java and Web Developers**.
2. Go to **File** &rarr; **Import...** &rarr; **General** &rarr; **Existing Projects into Workspace**.
3. Browse to `C:\Users\Rahul Prasad\.gemini\antigravity\scratch\HotelManagementSystem` and click **Finish**.
4. Configure Apache Tomcat Server:
   * In Eclipse, open the **Servers** tab &rarr; **New Server** &rarr; select **Apache Tomcat v10.1** (or 10.0).
   * Point to your local Tomcat installation directory.
5. Add the Project to Tomcat:
   * Right-click Tomcat in the Servers view &rarr; **Add and Remove...** &rarr; Move `HotelManagementSystem` to the right side.
6. Run:
   * Right-click the project &rarr; **Run As** &rarr; **Run on Server**.
   * Open your browser at: `http://localhost:8080/HotelManagementSystem/`

---

### Option B: Running in IntelliJ IDEA
1. Open **IntelliJ IDEA**.
2. Click **Open** &rarr; select `C:\Users\Rahul Prasad\.gemini\antigravity\scratch\HotelManagementSystem`.
3. If prompted to open as a Maven project, select **Open as Maven Project** (using the included `pom.xml`).
4. Configure Tomcat Server:
   * Click **Add Configuration...** &rarr; **+** &rarr; **Tomcat Server** &rarr; **Local**.
   * Under **Deployment** tab &rarr; click **+** &rarr; select **Artifact: `HotelManagementSystem:war exploded`** (Application context: `/HotelManagementSystem`).
5. Click **Run** or **Debug**.
6. Access in browser: `http://localhost:8080/HotelManagementSystem/`

---

### Option C: Manual Command-Line Compilation & Standalone Tomcat
1. Compile the project anytime by running `build.bat` in the project root:
   ```cmd
   build.bat
   ```
2. Copy the entire `HotelManagementSystem` directory into your Tomcat's `webapps/` folder, or build a WAR using Maven:
   ```cmd
   mvn clean package
   ```
   Deploy the generated `target/HotelManagementSystem.war` into `tomcat/webapps/`.
3. Start Tomcat using `tomcat/bin/startup.bat`.
4. Open: `http://localhost:8080/HotelManagementSystem/`

---

## 6. Purpose of Every Java Class

### Model Layer (`src/model/`)
* **`User.java`**: Holds account credentials, role (`ADMIN` or `STAFF`), full name, and creation timestamp.
* **`Room.java`**: Represents a hotel room entity including number, category (`Single Room`, `Double Room`, `Deluxe Room`, `Suite Room`), price per night, guest capacity, status (`Available`, `Occupied`, `Maintenance`), amenities, and description.
* **`Customer.java`**: Represents a guest profile with personal information, contact number, email, address, and government-issued ID proof details (`Passport`, `Aadhaar`, `Driving License`, `National ID`).
* **`Booking.java`**: Represents room reservations, check-in/out dates, computed nights, total bill amount, booking status (`Confirmed`, `Checked-In`, `Checked-Out`, `Cancelled`), notes, and joined presentation fields.
* **`Payment.java`**: Represents payment transactions including amount, date, method (`Cash`, `UPI`, `Card`), payment status (`Completed`, `Pending`), transaction ID, and booking reference.
* **`Staff.java`**: Represents hotel staff members with department roles, shift assignments (`Morning`, `Evening`, `Night`), contact details, monthly salary, and employment status.
* **`DashboardStats.java`**: Encapsulates calculated real-time KPI metrics (room totals, availability counts, occupancy rate %, revenue, pending check-ins/outs).

### Utility Layer (`src/util/`)
* **`DBConnection.java`**: Manages MySQL connection lifecycle with automatic driver loading, environment variable overrides, fallback connection attempts, and connection cleanup (`close()`).
* **`PasswordUtil.java`**: Provides SHA-256 cryptographic password hashing and verification to safeguard credentials against unauthorized access.

### Data Access Object (DAO) Layer (`src/dao/`)
* **`UserDAO.java`**: Handles database user authentication via parameterized queries and SHA-256 hash checks.
* **`RoomDAO.java`**: Executes room inventory CRUD, category and status filtering, and **date-range availability queries excluding overlapping bookings**.
* **`CustomerDAO.java`**: Handles guest profile creation, updates, deletions, and multi-field keyword search across name, phone, email, and ID proof number.
* **`BookingDAO.java`**: Handles reservation creation, status transitions, joined presentation queries, and **mathematical overlap prevention checking (`isRoomAvailable`)**.
* **`PaymentDAO.java`**: Inserts payment transaction records, aggregates total hotel revenue, filters payments by method/status, and retrieves booking transaction histories.
* **`StaffDAO.java`**: Executes hotel staff CRUD operations, shift queries, active staff counts, and employee directory filtering.
* **`ReportDAO.java`**: Generates aggregated business intelligence data including daily booking counts, monthly revenue trends, room category occupancy ratios, and payment method breakdowns.

### Service Layer (`src/service/`)
* **`BookingService.java`**: Core business logic orchestrator that:
  * Computes total stay duration (nights) with a 1-night same-day minimum.
  * Calculates total cost (`nights * pricePerNight`).
  * Enforces **strict double-booking prevention** via `bookingDAO.isRoomAvailable(...)`.
  * Generates unique, human-readable booking references (e.g., `BK-202611-XXXX`).
  * Coordinates guest check-in (marks booking `Checked-In`, sets room to `Occupied`).
  * Coordinates guest check-out (marks booking `Checked-Out`, frees room to `Available`).
  * Coordinates reservation cancellation and room release.
* **`RoomService.java`**: Enforces room validation rules (positive pricing, capacity limits, room number uniqueness).
* **`PaymentService.java`**: Validates payment amounts, verifies payment methods, generates unique transaction references, and persists payments.

### Controller / Servlet Layer (`src/controller/`)
* **`AuthFilter.java`**: Intercepts all `/admin/*` requests, ensuring unauthenticated requests are redirected to `/login.jsp?error=session_expired`.
* **`LoginServlet.java`**: Processes sign-in submissions, validates credentials against `UserDAO`, and initializes secure HTTP sessions.
* **`LogoutServlet.java`**: Clears user session attributes, calls `session.invalidate()`, and redirects to login.
* **`DashboardServlet.java`**: Gathers all dashboard KPIs, recent bookings, recent payments, and forwards them to `admin/dashboard.jsp`.
* **`RoomServlet.java`**: Handles room additions, edits, deletions, and category/status filter requests.
* **`CustomerServlet.java`**: Handles guest registration, profile updates, and live directory searches.
* **`BookingServlet.java`**: Manages reservation creation, public customer bookings from `index.jsp`, cancellations, and AJAX availability inquiries.
* **`CheckInOutServlet.java`**: Handles 1-click check-in and check-out actions, transitioning room statuses and routing directly to final bill settlement.
* **`PaymentServlet.java`**: Manages payment listings, records new transactions, and renders the comprehensive printable guest invoice (`/admin/invoice`).
* **`StaffServlet.java`**: Handles staff member onboarding, roster updates, salary records, and shift schedules.
* **`ReportServlet.java`**: Compiles multi-month revenue trends, daily booking volumes, and occupancy distribution for interactive Chart.js visualization.

---

## 7. Mathematical Double-Booking Prevention

To strictly prevent overlapping reservations and double-bookings, the system utilizes the standard mathematical interval intersection formula:

$$\max(\text{start}_1, \text{start}_2) < \min(\text{end}_1, \text{end}_2) \iff \text{check\_in}_1 < \text{check\_out}_2 \;\land\; \text{check\_out}_1 > \text{check\_in}_2$$

Implemented in `BookingDAO.java`:
```sql
SELECT COUNT(*) FROM bookings
WHERE room_id = ?
  AND booking_status IN ('Confirmed', 'Checked-In')
  AND check_in_date < ?  -- Requested Check-Out
  AND check_out_date > ? -- Requested Check-In
```
If the count is greater than 0, the room is already reserved for the requested dates, preventing double booking at both the service and database query levels.
