package controller;

import dao.BookingDAO;
import dao.PaymentDAO;
import dao.ReportDAO;
import dao.RoomDAO;
import model.Booking;
import model.DashboardStats;
import model.Payment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Controller feeding real-time analytics, room occupancy KPIs, and recent activity
 * to the Admin Dashboard view.
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/admin/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        DashboardStats stats = reportDAO.getDashboardStats();
        List<Booking> recentBookings = bookingDAO.getRecentBookings(6);
        List<Payment> recentPayments = paymentDAO.getAllPayments();
        if (recentPayments.size() > 5) {
            recentPayments = recentPayments.subList(0, 5);
        }
        List<Map<String, Object>> roomTypeStats = reportDAO.getRoomTypeOccupancyReport();
        List<Map<String, Object>> dailyBookings = reportDAO.getDailyBookingsReport(7);

        request.setAttribute("stats", stats);
        request.setAttribute("recentBookings", recentBookings);
        request.setAttribute("recentPayments", recentPayments);
        request.setAttribute("roomTypeStats", roomTypeStats);
        request.setAttribute("dailyBookings", dailyBookings);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
