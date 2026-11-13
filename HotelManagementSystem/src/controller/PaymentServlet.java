package controller;

import dao.BookingDAO;
import dao.PaymentDAO;
import model.Booking;
import model.Payment;
import service.PaymentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Controller managing payment receipts, billing history, and detailed customer invoice generation.
 */
@WebServlet(name = "PaymentServlet", urlPatterns = {"/admin/payments", "/admin/invoice"})
public class PaymentServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/admin/invoice".equalsIgnoreCase(path)) {
            handleInvoiceView(request, response);
            return;
        }

        // Default: /admin/payments list view
        String methodFilter = request.getParameter("methodFilter");
        String statusFilter = request.getParameter("statusFilter");
        String searchKeyword = request.getParameter("searchKeyword");

        List<Payment> payments = paymentDAO.getPaymentsFiltered(methodFilter, statusFilter, searchKeyword);
        List<Booking> activeBookings = bookingDAO.getAllBookings();
        double totalRevenue = paymentDAO.getTotalRevenue();

        request.setAttribute("payments", payments);
        request.setAttribute("activeBookings", activeBookings);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("methodFilter", methodFilter);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("searchKeyword", searchKeyword);

        request.getRequestDispatcher("/admin/payments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            double amount = Double.parseDouble(request.getParameter("amount"));
            String paymentMethod = request.getParameter("paymentMethod");
            String transactionId = request.getParameter("transactionId");
            String remarks = request.getParameter("remarks");

            paymentService.processPayment(bookingId, amount, paymentMethod, transactionId, remarks);

            String redirectTarget = request.getParameter("redirectTarget");
            if ("invoice".equalsIgnoreCase(redirectTarget)) {
                response.sendRedirect(request.getContextPath() + "/admin/invoice?bookingId=" + bookingId + "&msg=Payment%20recorded%20successfully");
            } else if ("bookings".equalsIgnoreCase(redirectTarget)) {
                response.sendRedirect(request.getContextPath() + "/admin/bookings?msg=Payment%20of%20INR%20" + String.format("%.2f", amount) + "%20recorded%20successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/payments?msg=Payment%20recorded%20successfully");
            }
        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/admin/payments?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/payments?error=Failed%20to%20process%20payment");
        }
    }

    private void handleInvoiceView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }

        int bookingId = Integer.parseInt(bookingIdStr.trim());
        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=Booking%20not%20found");
            return;
        }

        List<Payment> paymentHistory = paymentDAO.getPaymentsByBookingId(bookingId);

        request.setAttribute("booking", booking);
        request.setAttribute("payments", paymentHistory);
        request.getRequestDispatcher("/admin/invoice.jsp").forward(request, response);
    }
}
