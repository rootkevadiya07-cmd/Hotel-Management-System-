package controller;

import service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Controller executing guest check-in and check-out workflows,
 * synchronizing room availability states and routing to bill generation.
 */
@WebServlet(name = "CheckInOutServlet", urlPatterns = {"/admin/checkinout"})
public class CheckInOutServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");

        if (idStr == null || action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }

        try {
            int bookingId = Integer.parseInt(idStr);

            if ("checkin".equalsIgnoreCase(action)) {
                bookingService.checkInGuest(bookingId);
                response.sendRedirect(request.getContextPath() + "/admin/bookings?msg=Guest%20checked%20in%20successfully!%20Room%20marked%20as%20Occupied.");
            } else if ("checkout".equalsIgnoreCase(action)) {
                bookingService.checkOutGuest(bookingId);
                // Redirect directly to the invoice review page so staff can settle balance and print bill
                response.sendRedirect(request.getContextPath() + "/admin/invoice?bookingId=" + bookingId + "&msg=Guest%20checked%20out%20successfully!%20Room%20freed.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/bookings");
            }
        } catch (IllegalStateException | IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=Failed%20to%20update%20check-in/check-out%20status");
        }
    }
}
