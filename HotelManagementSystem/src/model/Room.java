package model;

import java.sql.Timestamp;

/**
 * Model representing a hotel room.
 */
public class Room {
    private int roomId;
    private String roomNumber;
    private String roomType; // 'Single Room', 'Double Room', 'Deluxe Room', 'Suite Room'
    private double pricePerNight;
    private int capacity;
    private String status; // 'Available', 'Occupied', 'Maintenance'
    private String amenities;
    private String description;
    private Timestamp createdAt;

    public Room() {
    }

    public Room(int roomId, String roomNumber, String roomType, double pricePerNight, int capacity, String status, String amenities, String description, Timestamp createdAt) {
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.pricePerNight = pricePerNight;
        this.capacity = capacity;
        this.status = status;
        this.amenities = amenities;
        this.description = description;
        this.createdAt = createdAt;
    }

    public Room(String roomNumber, String roomType, double pricePerNight, int capacity, String status, String amenities, String description) {
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.pricePerNight = pricePerNight;
        this.capacity = capacity;
        this.status = status;
        this.amenities = amenities;
        this.description = description;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public double getPricePerNight() {
        return pricePerNight;
    }

    public void setPricePerNight(double pricePerNight) {
        this.pricePerNight = pricePerNight;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAmenities() {
        return amenities;
    }

    public void setAmenities(String amenities) {
        this.amenities = amenities;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isAvailable() {
        return "Available".equalsIgnoreCase(this.status);
    }
}
