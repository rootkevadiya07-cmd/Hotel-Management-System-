package dao;

import model.Staff;
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
 * Data Access Object for Hotel Staff.
 */
public class StaffDAO {

    public boolean addStaff(Staff staff) {
        String sql = "INSERT INTO staff (full_name, role, shift, phone, email, salary, status, hire_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, staff.getFullName());
            ps.setString(2, staff.getRole());
            ps.setString(3, staff.getShift());
            ps.setString(4, staff.getPhone());
            ps.setString(5, staff.getEmail());
            ps.setDouble(6, staff.getSalary());
            ps.setString(7, staff.getStatus() != null ? staff.getStatus() : "Active");
            ps.setDate(8, staff.getHireDate() != null ? staff.getHireDate() : new Date(System.currentTimeMillis()));

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    public boolean updateStaff(Staff staff) {
        String sql = "UPDATE staff SET full_name = ?, role = ?, shift = ?, phone = ?, email = ?, salary = ?, status = ?, hire_date = ? WHERE staff_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, staff.getFullName());
            ps.setString(2, staff.getRole());
            ps.setString(3, staff.getShift());
            ps.setString(4, staff.getPhone());
            ps.setString(5, staff.getEmail());
            ps.setDouble(6, staff.getSalary());
            ps.setString(7, staff.getStatus());
            ps.setDate(8, staff.getHireDate());
            ps.setInt(9, staff.getStaffId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    public boolean deleteStaff(int staffId) {
        String sql = "DELETE FROM staff WHERE staff_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, staffId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    public Staff findById(int staffId) {
        String sql = "SELECT * FROM staff WHERE staff_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, staffId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToStaff(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    public List<Staff> getAllStaff() {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT * FROM staff ORDER BY staff_id DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                list.add(mapResultSetToStaff(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return list;
    }

    public List<Staff> getStaffFiltered(String role, String shift, String status, String keyword) {
        List<Staff> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM staff WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (role != null && !role.trim().isEmpty() && !"ALL".equalsIgnoreCase(role)) {
            sql.append(" AND role = ? ");
            params.add(role.trim());
        }
        if (shift != null && !shift.trim().isEmpty() && !"ALL".equalsIgnoreCase(shift)) {
            sql.append(" AND shift = ? ");
            params.add(shift.trim());
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND status = ? ");
            params.add(status.trim());
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (full_name LIKE ? OR phone LIKE ? OR email LIKE ?) ");
            String term = "%" + keyword.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        sql.append(" ORDER BY staff_id DESC");

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
                list.add(mapResultSetToStaff(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    public int getTotalStaffCount() {
        String sql = "SELECT COUNT(*) FROM staff WHERE status = 'Active'";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return 0;
    }

    private Staff mapResultSetToStaff(ResultSet rs) throws SQLException {
        return new Staff(
            rs.getInt("staff_id"),
            rs.getString("full_name"),
            rs.getString("role"),
            rs.getString("shift"),
            rs.getString("phone"),
            rs.getString("email"),
            rs.getDouble("salary"),
            rs.getString("status"),
            rs.getDate("hire_date"),
            rs.getTimestamp("created_at")
        );
    }
}
