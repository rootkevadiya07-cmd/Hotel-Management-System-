package controller;

import dao.BookingDAO;
import dao.PaymentDAO;
import dao.ReportDAO;
import dao.RoomDAO;
import model.Booking;
import model.DashboardStats;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Controller compiling business intelligence reports, occupancy metrics,
 * revenue charts, and transaction ledgers.
 */
@WebServlet(name = "ReportServlet", urlPatterns = {"/admin/reports"})
public class ReportServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        DashboardStats stats = reportDAO.getDashboardStats();
        List<Map<String, Object>> dailyBookings = reportDAO.getDailyBookingsReport(14);
        List<Map<String, Object>> monthlyRevenue = reportDAO.getMonthlyRevenueReport(6);
        List<Map<String, Object>> paymentBreakdown = reportDAO.getPaymentMethodBreakdown();
        List<Map<String, Object>> roomOccupancy = reportDAO.getRoomTypeOccupancyReport();
        List<Booking> allBookings = bookingDAO.getAllBookings();

        request.setAttribute("stats", stats);
        request.setAttribute("dailyBookings", dailyBookings);
        request.setAttribute("monthlyRevenue", monthlyRevenue);
        request.setAttribute("paymentBreakdown", paymentBreakdown);
        request.setAttribute("roomOccupancy", roomOccupancy);
        request.setAttribute("allBookings", allBookings);

        request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
    }
}
