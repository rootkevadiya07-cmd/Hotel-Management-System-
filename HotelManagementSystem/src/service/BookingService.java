package service;

import dao.BookingDAO;
import dao.CustomerDAO;
import dao.PaymentDAO;
import dao.RoomDAO;
import model.Booking;
import model.Customer;
import model.Payment;
import model.Room;

import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Random;

/**
 * Service orchestrating business logic for room bookings, stay duration calculation,
 * overlapping conflict prevention, unique ID generation, and check-in/check-out lifecycle.
 */
public class BookingService {

    private final BookingDAO bookingDAO;
    private final RoomDAO roomDAO;
    private final CustomerDAO customerDAO;
    private final PaymentDAO paymentDAO;

    public BookingService() {
        this.bookingDAO = new BookingDAO();
        this.roomDAO = new RoomDAO();
        this.customerDAO = new CustomerDAO();
        this.paymentDAO = new PaymentDAO();
    }

    /**
     * Calculates total nights between check-in and check-out dates.
     * Guaranteed minimum of 1 day for same-day stays.
     */
    public int calculateTotalDays(Date checkIn, Date checkOut) {
        if (checkIn == null || checkOut == null) {
            return 1;
        }
        LocalDate start = checkIn.toLocalDate();
        LocalDate end = checkOut.toLocalDate();
        long days = ChronoUnit.DAYS.between(start, end);
        return days <= 0 ? 1 : (int) days;
    }

    /**
     * Calculates total room cost based on room price and number of nights.
     */
    public double calculateTotalCost(double pricePerNight, int totalDays) {
        return Math.round(pricePerNight * totalDays * 100.0) / 100.0;
    }

    /**
     * Generates a unique, professional human-readable booking reference.
     * Example: BK-202611-7X9Q
     */
    public String generateBookingNumber() {
        LocalDate now = LocalDate.now();
        String yearMonth = String.format("%04d%02d", now.getYear(), now.getMonthValue());
        String chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        Random random = new Random();
        StringBuilder sb = new StringBuilder("BK-").append(yearMonth).append("-");
        for (int i = 0; i < 4; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }

    /**
     * Checks if a room can be safely booked without double-booking conflict.
     */
    public boolean isRoomAvailable(int roomId, Date checkIn, Date checkOut, Integer excludeBookingId) {
        // First verify room is not in maintenance
        Room room = roomDAO.findById(roomId);
        if (room == null || "Maintenance".equalsIgnoreCase(room.getStatus())) {
            return false;
        }
        // Verify no overlapping bookings exist in database
        return bookingDAO.isRoomAvailable(roomId, checkIn, checkOut, excludeBookingId);
    }

    /**
     * Creates a new booking with full business validation.
     * Throws IllegalArgumentException if input is invalid or dates overlap.
     */
    public Booking processBooking(int customerId, int roomId, Date checkIn, Date checkOut, String notes, double initialPayment, String paymentMethod) {
        if (checkIn == null || checkOut == null) {
            throw new IllegalArgumentException("Check-in and Check-out dates are required.");
        }
        if (checkOut.before(checkIn)) {
            throw new IllegalArgumentException("Check-out date cannot be earlier than check-in date.");
        }

        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            throw new IllegalArgumentException("Selected customer does not exist.");
        }

        Room room = roomDAO.findById(roomId);
        if (room == null) {
            throw new IllegalArgumentException("Selected room does not exist.");
        }

        // Strict double-booking check
        if (!isRoomAvailable(roomId, checkIn, checkOut, null)) {
            throw new IllegalStateException("Room " + room.getRoomNumber() + " is already booked for the selected dates. Double-booking prevented.");
        }

        int totalDays = calculateTotalDays(checkIn, checkOut);
        double totalCost = calculateTotalCost(room.getPricePerNight(), totalDays);
        String bookingNumber = generateBookingNumber();

        Booking booking = new Booking();
        booking.setBookingNumber(bookingNumber);
        booking.setCustomerId(customerId);
        booking.setRoomId(roomId);
        booking.setCheckInDate(checkIn);
        booking.setCheckOutDate(checkOut);
        booking.setTotalDays(totalDays);
        booking.setTotalAmount(totalCost);
        booking.setBookingStatus("Confirmed");
        booking.setNotes(notes);

        int newBookingId = bookingDAO.createBooking(booking);
        if (newBookingId <= 0) {
            throw new RuntimeException("Failed to persist booking in database.");
        }
        booking.setBookingId(newBookingId);

        // Record initial payment if provided
        if (initialPayment > 0) {
            Payment payment = new Payment();
            payment.setBookingId(newBookingId);
            payment.setAmount(initialPayment);
            payment.setPaymentMethod(paymentMethod != null ? paymentMethod : "Cash");
            payment.setPaymentStatus("Completed");
            payment.setTransactionId("INIT-" + System.currentTimeMillis());
            payment.setRemarks("Advance / Initial payment upon booking creation.");
            paymentDAO.recordPayment(payment);
        }

        return booking;
    }

    /**
     * Executes Customer Check-In:
     * Updates booking status to 'Checked-In' and marks room status to 'Occupied'.
     */
    public boolean checkInGuest(int bookingId) {
        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        if ("Cancelled".equalsIgnoreCase(booking.getBookingStatus())) {
            throw new IllegalStateException("Cannot check in a cancelled booking.");
        }
        if ("Checked-Out".equalsIgnoreCase(booking.getBookingStatus())) {
            throw new IllegalStateException("Guest has already checked out.");
        }

        boolean statusUpdated = bookingDAO.updateStatus(bookingId, "Checked-In");
        if (statusUpdated) {
            roomDAO.updateRoomStatus(booking.getRoomId(), "Occupied");
        }
        return statusUpdated;
    }

    /**
     * Executes Customer Check-Out:
     * Updates booking status to 'Checked-Out' and frees the room status to 'Available'.
     */
    public boolean checkOutGuest(int bookingId) {
        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found.");
        }

        boolean statusUpdated = bookingDAO.updateStatus(bookingId, "Checked-Out");
        if (statusUpdated) {
            roomDAO.updateRoomStatus(booking.getRoomId(), "Available");
        }
        return statusUpdated;
    }

    /**
     * Cancels a booking and frees the room if it was reserved.
     */
    public boolean cancelBooking(int bookingId) {
        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found.");
        }

        boolean statusUpdated = bookingDAO.updateStatus(bookingId, "Cancelled");
        if (statusUpdated) {
            // If room was currently Occupied by this booking, restore it to Available
            roomDAO.updateRoomStatus(booking.getRoomId(), "Available");
        }
        return statusUpdated;
    }
}
