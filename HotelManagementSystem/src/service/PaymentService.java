package service;

import dao.BookingDAO;
import dao.PaymentDAO;
import model.Booking;
import model.Payment;

import java.util.List;
import java.util.UUID;

/**
 * Service managing billing, payment processing, transaction records, and invoice reconciliation.
 */
public class PaymentService {

    private final PaymentDAO paymentDAO;
    private final BookingDAO bookingDAO;

    public PaymentService() {
        this.paymentDAO = new PaymentDAO();
        this.bookingDAO = new BookingDAO();
    }

    public boolean processPayment(int bookingId, double amount, String paymentMethod, String transactionId, String remarks) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Payment amount must be greater than zero.");
        }
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "Cash";
        }

        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found.");
        }

        if (transactionId == null || transactionId.trim().isEmpty()) {
            transactionId = "TXN-" + paymentMethod.toUpperCase() + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }

        Payment payment = new Payment();
        payment.setBookingId(bookingId);
        payment.setAmount(amount);
        payment.setPaymentMethod(paymentMethod);
        payment.setPaymentStatus("Completed");
        payment.setTransactionId(transactionId);
        payment.setRemarks(remarks != null ? remarks : "Payment recorded via Admin/Front Desk.");

        return paymentDAO.recordPayment(payment);
    }

    public List<Payment> getPaymentsForBooking(int bookingId) {
        return paymentDAO.getPaymentsByBookingId(bookingId);
    }

    public List<Payment> getAllPayments() {
        return paymentDAO.getAllPayments();
    }

    public List<Payment> getFilteredPayments(String method, String status, String keyword) {
        return paymentDAO.getPaymentsFiltered(method, status, keyword);
    }
}
