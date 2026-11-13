package dao;

import model.Booking;
import util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Room Bookings.
 * Handles reservation lifecycle, overlap validation, and customer/room joined queries.
 */
public class BookingDAO {

    public int createBooking(Booking booking) {
        String sql = "INSERT INTO bookings (booking_number, customer_id, room_id, check_in_date, check_out_date, total_days, total_amount, booking_status, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, booking.getBookingNumber());
            ps.setInt(2, booking.getCustomerId());
            ps.setInt(3, booking.getRoomId());
            ps.setDate(4, booking.getCheckInDate());
            ps.setDate(5, booking.getCheckOutDate());
            ps.setInt(6, booking.getTotalDays());
            ps.setDouble(7, booking.getTotalAmount());
            ps.setString(8, booking.getBookingStatus() != null ? booking.getBookingStatus() : "Confirmed");
            ps.setString(9, booking.getNotes());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return -1;
    }

    public boolean updateStatus(int bookingId, String status) {
        String sql = "UPDATE bookings SET booking_status = ? WHERE booking_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, bookingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Checks if a room has any overlapping active reservation between checkIn and checkOut.
     * Prevents double bookings.
     * @param roomId Target room ID
     * @param checkIn Requested check-in date
     * @param checkOut Requested check-out date
     * @param excludeBookingId Optional booking ID to exclude when rescheduling an existing booking
     * @return true if room is strictly free, false if booked/overlapping
     */
    public boolean isRoomAvailable(int roomId, Date checkIn, Date checkOut, Integer excludeBookingId) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM bookings ");
        sql.append("WHERE room_id = ? ");
        sql.append("  AND booking_status IN ('Confirmed', 'Checked-In') ");
        sql.append("  AND check_in_date < ? ");
        sql.append("  AND check_out_date > ? ");
        if (excludeBookingId != null && excludeBookingId > 0) {
            sql.append("  AND booking_id != ? ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            ps.setInt(idx++, roomId);
            ps.setDate(idx++, checkOut);
            ps.setDate(idx++, checkIn);
            if (excludeBookingId != null && excludeBookingId > 0) {
                ps.setInt(idx++, excludeBookingId);
            }

            rs = ps.executeQuery();
            if (rs.next()) {
                int conflictCount = rs.getInt(1);
                return conflictCount == 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return false;
    }

    public Booking findById(int bookingId) {
        String sql = "SELECT b.*, " +
                     "       c.full_name AS customer_name, c.email AS customer_email, c.phone AS customer_phone, c.address AS customer_address, c.id_proof_number AS customer_id_proof, " +
                     "       r.room_number, r.room_type, r.price_per_night, " +
                     "       COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.booking_id = b.booking_id AND p.payment_status = 'Completed'), 0.0) AS paid_amount " +
                     "FROM bookings b " +
                     "JOIN customers c ON b.customer_id = c.customer_id " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "WHERE b.booking_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookingId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToBooking(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    public Booking findByBookingNumber(String bookingNumber) {
        String sql = "SELECT b.*, " +
                     "       c.full_name AS customer_name, c.email AS customer_email, c.phone AS customer_phone, c.address AS customer_address, c.id_proof_number AS customer_id_proof, " +
                     "       r.room_number, r.room_type, r.price_per_night, " +
                     "       COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.booking_id = b.booking_id AND p.payment_status = 'Completed'), 0.0) AS paid_amount " +
                     "FROM bookings b " +
                     "JOIN customers c ON b.customer_id = c.customer_id " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "WHERE b.booking_number = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, bookingNumber);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToBooking(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    public List<Booking> getAllBookings() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.*, " +
                     "       c.full_name AS customer_name, c.email AS customer_email, c.phone AS customer_phone, c.address AS customer_address, c.id_proof_number AS customer_id_proof, " +
                     "       r.room_number, r.room_type, r.price_per_night, " +
                     "       COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.booking_id = b.booking_id AND p.payment_status = 'Completed'), 0.0) AS paid_amount " +
                     "FROM bookings b " +
                     "JOIN customers c ON b.customer_id = c.customer_id " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "ORDER BY b.booking_id DESC";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                list.add(mapResultSetToBooking(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return list;
    }

    public List<Booking> getBookingsFiltered(String status, String keyword) {
        List<Booking> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT b.*, ");
        sql.append("       c.full_name AS customer_name, c.email AS customer_email, c.phone AS customer_phone, c.address AS customer_address, c.id_proof_number AS customer_id_proof, ");
        sql.append("       r.room_number, r.room_type, r.price_per_night, ");
        sql.append("       COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.booking_id = b.booking_id AND p.payment_status = 'Completed'), 0.0) AS paid_amount ");
        sql.append("FROM bookings b ");
        sql.append("JOIN customers c ON b.customer_id = c.customer_id ");
        sql.append("JOIN rooms r ON b.room_id = r.room_id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND b.booking_status = ? ");
            params.add(status.trim());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (b.booking_number LIKE ? OR c.full_name LIKE ? OR c.phone LIKE ? OR r.room_number LIKE ?) ");
            String term = "%" + keyword.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
            params.add(term);
        }

        sql.append(" ORDER BY b.booking_id DESC");

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
                list.add(mapResultSetToBooking(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    public List<Booking> getRecentBookings(int limit) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.*, " +
                     "       c.full_name AS customer_name, c.email AS customer_email, c.phone AS customer_phone, c.address AS customer_address, c.id_proof_number AS customer_id_proof, " +
                     "       r.room_number, r.room_type, r.price_per_night, " +
                     "       COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.booking_id = b.booking_id AND p.payment_status = 'Completed'), 0.0) AS paid_amount " +
                     "FROM bookings b " +
                     "JOIN customers c ON b.customer_id = c.customer_id " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "ORDER BY b.booking_id DESC LIMIT ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToBooking(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    private Booking mapResultSetToBooking(ResultSet rs) throws SQLException {
        Booking b = new Booking(
            rs.getInt("booking_id"),
            rs.getString("booking_number"),
            rs.getInt("customer_id"),
            rs.getInt("room_id"),
            rs.getDate("check_in_date"),
            rs.getDate("check_out_date"),
            rs.getInt("total_days"),
            rs.getDouble("total_amount"),
            rs.getString("booking_status"),
            rs.getString("notes"),
            rs.getTimestamp("created_at")
        );

        b.setCustomerName(rs.getString("customer_name"));
        b.setCustomerEmail(rs.getString("customer_email"));
        b.setCustomerPhone(rs.getString("customer_phone"));
        b.setCustomerAddress(rs.getString("customer_address"));
        b.setCustomerIdProof(rs.getString("customer_id_proof"));
        b.setRoomNumber(rs.getString("room_number"));
        b.setRoomType(rs.getString("room_type"));
        b.setPricePerNight(rs.getDouble("price_per_night"));
        b.setPaidAmount(rs.getDouble("paid_amount"));

        return b;
    }
}
