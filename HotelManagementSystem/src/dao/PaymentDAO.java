package dao;

import model.Payment;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Payment transactions.
 */
public class PaymentDAO {

    public boolean recordPayment(Payment payment) {
        String sql = "INSERT INTO payments (booking_id, amount, payment_method, payment_status, transaction_id, remarks) VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, payment.getBookingId());
            ps.setDouble(2, payment.getAmount());
            ps.setString(3, payment.getPaymentMethod());
            ps.setString(4, payment.getPaymentStatus() != null ? payment.getPaymentStatus() : "Completed");
            ps.setString(5, payment.getTransactionId());
            ps.setString(6, payment.getRemarks());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    public List<Payment> getPaymentsByBookingId(int bookingId) {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT p.*, b.booking_number, c.full_name AS customer_name, r.room_number " +
                     "FROM payments p " +
                     "JOIN bookings b ON p.booking_id = b.booking_id " +
                     "JOIN customers c ON b.customer_id = c.customer_id " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "WHERE p.booking_id = ? ORDER BY p.payment_id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookingId);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToPayment(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    public List<Payment> getAllPayments() {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT p.*, b.booking_number, c.full_name AS customer_name, r.room_number " +
                     "FROM payments p " +
                     "JOIN bookings b ON p.booking_id = b.booking_id " +
                     "JOIN customers c ON b.customer_id = c.customer_id " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "ORDER BY p.payment_id DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                list.add(mapResultSetToPayment(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return list;
    }

    public List<Payment> getPaymentsFiltered(String method, String status, String keyword) {
        List<Payment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.*, b.booking_number, c.full_name AS customer_name, r.room_number ");
        sql.append("FROM payments p ");
        sql.append("JOIN bookings b ON p.booking_id = b.booking_id ");
        sql.append("JOIN customers c ON b.customer_id = c.customer_id ");
        sql.append("JOIN rooms r ON b.room_id = r.room_id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (method != null && !method.trim().isEmpty() && !"ALL".equalsIgnoreCase(method)) {
            sql.append(" AND p.payment_method = ? ");
            params.add(method.trim());
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND p.payment_status = ? ");
            params.add(status.trim());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (b.booking_number LIKE ? OR c.full_name LIKE ? OR p.transaction_id LIKE ?) ");
            String term = "%" + keyword.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        sql.append(" ORDER BY p.payment_id DESC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToPayment(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    public double getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(amount), 0.0) FROM payments WHERE payment_status = 'Completed'";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return 0.0;
    }

    private Payment mapResultSetToPayment(ResultSet rs) throws SQLException {
        Payment p = new Payment(
            rs.getInt("payment_id"),
            rs.getInt("booking_id"),
            rs.getTimestamp("payment_date"),
            rs.getDouble("amount"),
            rs.getString("payment_method"),
            rs.getString("payment_status"),
            rs.getString("transaction_id"),
            rs.getString("remarks")
        );
        p.setBookingNumber(rs.getString("booking_number"));
        p.setCustomerName(rs.getString("customer_name"));
        p.setRoomNumber(rs.getString("room_number"));
        return p;
    }
}
