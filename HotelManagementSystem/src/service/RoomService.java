package service;

import dao.RoomDAO;
import model.Room;

import java.util.List;

/**
 * Service managing business validations for Room configuration and inventory.
 */
public class RoomService {

    private final RoomDAO roomDAO;

    public RoomService() {
        this.roomDAO = new RoomDAO();
    }

    public boolean createRoom(Room room) {
        validateRoom(room);
        Room existing = roomDAO.findByRoomNumber(room.getRoomNumber());
        if (existing != null) {
            throw new IllegalArgumentException("Room number '" + room.getRoomNumber() + "' already exists.");
        }
        return roomDAO.addRoom(room);
    }

    public boolean updateRoom(Room room) {
        validateRoom(room);
        Room existing = roomDAO.findByRoomNumber(room.getRoomNumber());
        if (existing != null && existing.getRoomId() != room.getRoomId()) {
            throw new IllegalArgumentException("Room number '" + room.getRoomNumber() + "' is already assigned to another room.");
        }
        return roomDAO.updateRoom(room);
    }

    public boolean deleteRoom(int roomId) {
        return roomDAO.deleteRoom(roomId);
    }

    public Room getRoomById(int roomId) {
        return roomDAO.findById(roomId);
    }

    public List<Room> getAllRooms() {
        return roomDAO.getAllRooms();
    }

    public List<Room> getFilteredRooms(String type, String status, String keyword) {
        return roomDAO.getRoomsFiltered(type, status, keyword);
    }

    private void validateRoom(Room room) {
        if (room == null) {
            throw new IllegalArgumentException("Room object cannot be null.");
        }
        if (room.getRoomNumber() == null || room.getRoomNumber().trim().isEmpty()) {
            throw new IllegalArgumentException("Room number cannot be empty.");
        }
        if (room.getRoomType() == null || room.getRoomType().trim().isEmpty()) {
            throw new IllegalArgumentException("Room type cannot be empty.");
        }
        if (room.getPricePerNight() <= 0) {
            throw new IllegalArgumentException("Price per night must be greater than zero.");
        }
        if (room.getCapacity() <= 0) {
            throw new IllegalArgumentException("Capacity must be at least 1 guest.");
        }
    }
}
