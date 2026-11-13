package dao;

import model.DashboardStats;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for analytics, aggregation, dashboard KPIs and audit reports.
 * Engineered with ANSI SQL compatibility across MySQL and embedded JDBC storage.
 */
public class ReportDAO {

    public DashboardStats getDashboardStats() {
        DashboardStats stats = new DashboardStats();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();

            // Rooms counts
            rs = stmt.executeQuery("SELECT " +
                    "COUNT(*) AS total, " +
                    "SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) AS available, " +
                    "SUM(CASE WHEN status = 'Occupied' THEN 1 ELSE 0 END) AS occupied, " +
                    "SUM(CASE WHEN status = 'Maintenance' THEN 1 ELSE 0 END) AS maintenance " +
                    "FROM rooms");
            if (rs.next()) {
                stats.setTotalRooms(rs.getInt("total"));
                stats.setAvailableRooms(rs.getInt("available"));
                stats.setOccupiedRooms(rs.getInt("occupied"));
                stats.setMaintenanceRooms(rs.getInt("maintenance"));
            }
            rs.close();

            // Total Customers
            rs = stmt.executeQuery("SELECT COUNT(*) FROM customers");
            if (rs.next()) {
                stats.setTotalCustomers(rs.getInt(1));
            }
            rs.close();

            // Total Bookings
            rs = stmt.executeQuery("SELECT COUNT(*) FROM bookings");
            if (rs.next()) {
                stats.setTotalBookings(rs.getInt(1));
            }
            rs.close();

            // Total Revenue
            rs = stmt.executeQuery("SELECT COALESCE(SUM(amount), 0.0) FROM payments WHERE payment_status = 'Completed'");
            if (rs.next()) {
                stats.setTotalRevenue(rs.getDouble(1));
            }
            rs.close();

            // Today's Check-ins
            rs = stmt.executeQuery("SELECT COUNT(*) FROM bookings WHERE booking_status IN ('Confirmed', 'Checked-In')");
            if (rs.next()) {
                stats.setTodayCheckIns(rs.getInt(1));
            }
            rs.close();

            // Today's Check-outs
            rs = stmt.executeQuery("SELECT COUNT(*) FROM bookings WHERE booking_status IN ('Checked-Out')");
            if (rs.next()) {
                stats.setTodayCheckOuts(rs.getInt(1));
            }
            rs.close();

            // Active Staff Count
            rs = stmt.executeQuery("SELECT COUNT(*) FROM staff WHERE status = 'Active'");
            if (rs.next()) {
                stats.setTotalStaff(rs.getInt(1));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return stats;
    }

    public List<Map<String, Object>> getDailyBookingsReport(int days) {
        List<Map<String, Object>> report = new ArrayList<>();
        long cutoffMillis = System.currentTimeMillis() - ((long) days * 24L * 60L * 60L * 1000L);
        Timestamp cutoffTime = new Timestamp(cutoffMillis);

        String sql = "SELECT SUBSTRING(CAST(created_at AS VARCHAR(30)), 1, 10) AS booking_date, " +
                     "       COUNT(*) AS count, " +
                     "       COALESCE(SUM(total_amount), 0.0) AS total_val " +
                     "FROM bookings " +
                     "WHERE created_at >= ? " +
                     "GROUP BY SUBSTRING(CAST(created_at AS VARCHAR(30)), 1, 10) " +
                     "ORDER BY booking_date ASC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setTimestamp(1, cutoffTime);
            rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("date", rs.getString("booking_date"));
                row.put("count", rs.getInt("count"));
                row.put("totalValue", rs.getDouble("total_val"));
                report.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return report;
    }

    public List<Map<String, Object>> getMonthlyRevenueReport(int months) {
        List<Map<String, Object>> report = new ArrayList<>();
        String sql = "SELECT SUBSTRING(CAST(payment_date AS VARCHAR(30)), 1, 7) AS month_year, " +
                     "       COUNT(*) AS transaction_count, " +
                     "       COALESCE(SUM(amount), 0.0) AS revenue " +
                     "FROM payments " +
                     "WHERE payment_status = 'Completed' " +
                     "GROUP BY SUBSTRING(CAST(payment_date AS VARCHAR(30)), 1, 7) " +
                     "ORDER BY month_year ASC";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("month", rs.getString("month_year"));
                row.put("transactions", rs.getInt("transaction_count"));
                row.put("revenue", rs.getDouble("revenue"));
                report.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return report;
    }

    public List<Map<String, Object>> getPaymentMethodBreakdown() {
        List<Map<String, Object>> report = new ArrayList<>();
        String sql = "SELECT payment_method, COUNT(*) AS count, COALESCE(SUM(amount), 0.0) AS total_amount " +
                     "FROM payments " +
                     "WHERE payment_status = 'Completed' " +
                     "GROUP BY payment_method";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("method", rs.getString("payment_method"));
                row.put("count", rs.getInt("count"));
                row.put("total", rs.getDouble("total_amount"));
                report.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return report;
    }

    public List<Map<String, Object>> getRoomTypeOccupancyReport() {
        List<Map<String, Object>> report = new ArrayList<>();
        String sql = "SELECT room_type, " +
                     "       COUNT(*) AS total_rooms, " +
                     "       SUM(CASE WHEN status = 'Occupied' THEN 1 ELSE 0 END) AS occupied_rooms, " +
                     "       SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) AS available_rooms " +
                     "FROM rooms " +
                     "GROUP BY room_type";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("type", rs.getString("room_type"));
                row.put("total", rs.getInt("total_rooms"));
                row.put("occupied", rs.getInt("occupied_rooms"));
                row.put("available", rs.getInt("available_rooms"));
                report.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return report;
    }
}
