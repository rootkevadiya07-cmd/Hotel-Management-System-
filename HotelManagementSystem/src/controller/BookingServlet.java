package controller;

import dao.CustomerDAO;
import dao.RoomDAO;
import model.Booking;
import model.Customer;
import model.Room;
import service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * Controller handling room reservations, date overlap validation,
 * booking search/filtering, and cancellation.
 */
@WebServlet(name = "BookingServlet", urlPatterns = {"/admin/bookings", "/book"})
public class BookingServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final dao.BookingDAO bookingDAO = new dao.BookingDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            if ("cancel".equalsIgnoreCase(action)) {
                handleCancelBooking(request, response);
            } else if ("checkAvailability".equalsIgnoreCase(action)) {
                handleCheckAvailability(request, response);
            } else {
                handleListBookings(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            handleListBookings(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "create";

        try {
            if ("create".equalsIgnoreCase(action)) {
                handleCreateAdminBooking(request, response);
            } else if ("publicBook".equalsIgnoreCase(action)) {
                handlePublicCustomerBooking(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/bookings");
            }
        } catch (IllegalStateException | IllegalArgumentException e) {
            if ("publicBook".equalsIgnoreCase(action)) {
                response.sendRedirect(request.getContextPath() + "/index.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            } else {
                request.setAttribute("errorMessage", e.getMessage());
                handleListBookings(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if ("publicBook".equalsIgnoreCase(action)) {
                response.sendRedirect(request.getContextPath() + "/index.jsp?error=Internal%20booking%20error");
            } else {
                request.setAttribute("errorMessage", "Failed to process booking: " + e.getMessage());
                handleListBookings(request, response);
            }
        }
    }

    private void handleListBookings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String statusFilter = request.getParameter("statusFilter");
        String searchKeyword = request.getParameter("searchKeyword");

        List<Booking> bookings = bookingDAO.getBookingsFiltered(statusFilter, searchKeyword);
        List<Room> allRooms = roomDAO.getAllRooms();
        List<Customer> allCustomers = customerDAO.getAllCustomers();

        request.setAttribute("bookings", bookings);
        request.setAttribute("rooms", allRooms);
        request.setAttribute("customers", allCustomers);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("searchKeyword", searchKeyword);

        request.getRequestDispatcher("/admin/bookings.jsp").forward(request, response);
    }

    private void handleCreateAdminBooking(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String custParam = request.getParameter("customerId");
        int customerId = 0;

        if (custParam != null && !custParam.trim().isEmpty() && !"new".equalsIgnoreCase(custParam)) {
            customerId = Integer.parseInt(custParam);
        } else {
            // Quick inline customer registration
            String qName = request.getParameter("quickFullName");
            String qPhone = request.getParameter("quickPhone");
            String qEmail = request.getParameter("quickEmail");
            String qAddress = request.getParameter("quickAddress");
            String qIdType = request.getParameter("quickIdType");
            String qIdNum = request.getParameter("quickIdNumber");

            if (qName == null || qName.trim().isEmpty() || qPhone == null || qPhone.trim().isEmpty()) {
                throw new IllegalArgumentException("Guest full name and phone number are required for booking.");
            }

            Customer existing = customerDAO.findByPhone(qPhone.trim());
            if (existing != null) {
                customerId = existing.getCustomerId();
            } else {
                Customer newC = new Customer(
                    qName.trim(),
                    qEmail != null ? qEmail.trim() : "",
                    qPhone.trim(),
                    qAddress != null ? qAddress.trim() : "",
                    qIdType != null ? qIdType : "Passport",
                    qIdNum != null ? qIdNum.trim() : "NA"
                );
                customerId = customerDAO.addCustomer(newC);
            }
        }

        int roomId = Integer.parseInt(request.getParameter("roomId"));
        Date checkIn = Date.valueOf(request.getParameter("checkInDate"));
        Date checkOut = Date.valueOf(request.getParameter("checkOutDate"));
        String notes = request.getParameter("notes");

        String initPayStr = request.getParameter("initialPayment");
        double initialPayment = (initPayStr != null && !initPayStr.trim().isEmpty()) ? Double.parseDouble(initPayStr) : 0.0;
        String paymentMethod = request.getParameter("paymentMethod");

        Booking booking = bookingService.processBooking(customerId, roomId, checkIn, checkOut, notes, initialPayment, paymentMethod);

        response.sendRedirect(request.getContextPath() + "/admin/bookings?msg=Booking%20created%20successfully!%20Ref:%20" + booking.getBookingNumber());
    }

    private void handlePublicCustomerBooking(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String idProofType = request.getParameter("idProofType");
        String idProofNumber = request.getParameter("idProofNumber");

        int roomId = Integer.parseInt(request.getParameter("roomId"));
        Date checkIn = Date.valueOf(request.getParameter("checkInDate"));
        Date checkOut = Date.valueOf(request.getParameter("checkOutDate"));
        String notes = request.getParameter("notes");

        Customer existing = customerDAO.findByPhone(phone);
        int customerId;
        if (existing != null) {
            customerId = existing.getCustomerId();
        } else {
            Customer newCust = new Customer(fullName, email, phone, address, idProofType, idProofNumber);
            customerId = customerDAO.addCustomer(newCust);
            if (customerId <= 0) {
                throw new RuntimeException("Failed to register guest details.");
            }
        }

        Booking booking = bookingService.processBooking(customerId, roomId, checkIn, checkOut, notes, 0.0, "Cash");
        response.sendRedirect(request.getContextPath() + "/index.jsp?booked=true&ref=" + booking.getBookingNumber());
    }

    private void handleCancelBooking(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int bookingId = Integer.parseInt(request.getParameter("id"));
        boolean cancelled = bookingService.cancelBooking(bookingId);
        if (cancelled) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings?msg=Booking%20cancelled%20successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/bookings?error=Failed%20to%20cancel%20booking");
        }
    }

    private void handleCheckAvailability(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String checkInStr = request.getParameter("checkIn");
        String checkOutStr = request.getParameter("checkOut");
        String roomType = request.getParameter("roomType");

        response.setContentType("application/json;charset=UTF-8");
        if (checkInStr == null || checkOutStr == null) {
            response.getWriter().write("[]");
            return;
        }

        try {
            Date checkIn = Date.valueOf(checkInStr);
            Date checkOut = Date.valueOf(checkOutStr);
            List<Room> availableRooms = roomDAO.findAvailableRooms(checkIn, checkOut, roomType);

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < availableRooms.size(); i++) {
                Room r = availableRooms.get(i);
                json.append("{")
                    .append("\"roomId\":").append(r.getRoomId()).append(",")
                    .append("\"roomNumber\":\"").append(r.getRoomNumber()).append("\",")
                    .append("\"roomType\":\"").append(r.getRoomType()).append("\",")
                    .append("\"price\":").append(r.getPricePerNight()).append(",")
                    .append("\"capacity\":").append(r.getCapacity())
                    .append("}");
                if (i < availableRooms.size() - 1) json.append(",");
            }
            json.append("]");
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            response.getWriter().write("[]");
        }
    }
}
