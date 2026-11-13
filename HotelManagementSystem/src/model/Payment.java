package model;

import java.sql.Timestamp;

/**
 * Model representing a payment transaction.
 */
public class Payment {
    private int paymentId;
    private int bookingId;
    private Timestamp paymentDate;
    private double amount;
    private String paymentMethod; // 'Cash', 'UPI', 'Card'
    private String paymentStatus; // 'Completed', 'Pending', 'Refunded'
    private String transactionId;
    private String remarks;

    // Enriched fields for convenience in presentation layer
    private String bookingNumber;
    private String customerName;
    private String roomNumber;

    public Payment() {
    }

    public Payment(int paymentId, int bookingId, Timestamp paymentDate, double amount, String paymentMethod, String paymentStatus, String transactionId, String remarks) {
        this.paymentId = paymentId;
        this.bookingId = bookingId;
        this.paymentDate = paymentDate;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
        this.transactionId = transactionId;
        this.remarks = remarks;
    }

    public Payment(int bookingId, double amount, String paymentMethod, String paymentStatus, String transactionId, String remarks) {
        this.bookingId = bookingId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
        this.transactionId = transactionId;
        this.remarks = remarks;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public Timestamp getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Timestamp paymentDate) {
        this.paymentDate = paymentDate;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public String getBookingNumber() {
        return bookingNumber;
    }

    public void setBookingNumber(String bookingNumber) {
        this.bookingNumber = bookingNumber;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }
}
