package dao;

import model.Room;
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
 * Data Access Object for Room entity operations.
 */
public class RoomDAO {

    public boolean addRoom(Room room) {
        String sql = "INSERT INTO rooms (room_number, room_type, price_per_night, capacity, status, amenities, description) VALUES (?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getRoomType());
            ps.setDouble(3, room.getPricePerNight());
            ps.setInt(4, room.getCapacity());
            ps.setString(5, room.getStatus() != null ? room.getStatus() : "Available");
            ps.setString(6, room.getAmenities());
            ps.setString(7, room.getDescription());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    public boolean updateRoom(Room room) {
        String sql = "UPDATE rooms SET room_number = ?, room_type = ?, price_per_night = ?, capacity = ?, status = ?, amenities = ?, description = ? WHERE room_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getRoomType());
            ps.setDouble(3, room.getPricePerNight());
            ps.setInt(4, room.getCapacity());
            ps.setString(5, room.getStatus());
            ps.setString(6, room.getAmenities());
            ps.setString(7, room.getDescription());
            ps.setInt(8, room.getRoomId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    public boolean deleteRoom(int roomId) {
        String sql = "DELETE FROM rooms WHERE room_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    public Room findById(int roomId) {
        String sql = "SELECT * FROM rooms WHERE room_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roomId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToRoom(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    public Room findByRoomNumber(String roomNumber) {
        String sql = "SELECT * FROM rooms WHERE room_number = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, roomNumber);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToRoom(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    public List<Room> getAllRooms() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT * FROM rooms ORDER BY room_number ASC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return rooms;
    }

    public List<Room> getRoomsFiltered(String type, String status, String keyword) {
        List<Room> rooms = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM rooms WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (type != null && !type.trim().isEmpty() && !"ALL".equalsIgnoreCase(type)) {
            sql.append(" AND room_type = ? ");
            params.add(type.trim());
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND status = ? ");
            params.add(status.trim());
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (room_number LIKE ? OR description LIKE ? OR amenities LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        sql.append(" ORDER BY room_number ASC");

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
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return rooms;
    }

    public boolean updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE rooms SET status = ? WHERE room_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, roomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Finds available rooms for a given stay interval and optional room type,
     * ensuring overlapping reservations are strictly excluded.
     */
    public List<Room> findAvailableRooms(Date checkIn, Date checkOut, String roomType) {
        List<Room> rooms = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.* FROM rooms r ");
        sql.append("WHERE r.status != 'Maintenance' ");

        if (roomType != null && !roomType.trim().isEmpty() && !"ALL".equalsIgnoreCase(roomType)) {
            sql.append("AND r.room_type = ? ");
        }

        sql.append("AND r.room_id NOT IN ( ");
        sql.append("    SELECT b.room_id FROM bookings b ");
        sql.append("    WHERE b.booking_status IN ('Confirmed', 'Checked-In') ");
        sql.append("      AND b.check_in_date < ? ");
        sql.append("      AND b.check_out_date > ? ");
        sql.append(") ");
        sql.append("ORDER BY r.price_per_night ASC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());

            int idx = 1;
            if (roomType != null && !roomType.trim().isEmpty() && !"ALL".equalsIgnoreCase(roomType)) {
                ps.setString(idx++, roomType.trim());
            }
            ps.setDate(idx++, checkOut);
            ps.setDate(idx++, checkIn);

            rs = ps.executeQuery();
            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return rooms;
    }

    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        return new Room(
            rs.getInt("room_id"),
            rs.getString("room_number"),
            rs.getString("room_type"),
            rs.getDouble("price_per_night"),
            rs.getInt("capacity"),
            rs.getString("status"),
            rs.getString("amenities"),
            rs.getString("description"),
            rs.getTimestamp("created_at")
        );
    }
}
