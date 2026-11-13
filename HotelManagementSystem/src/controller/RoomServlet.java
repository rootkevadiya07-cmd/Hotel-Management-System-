package controller;

import model.Room;
import service.RoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Controller managing Room CRUD, filtering, and availability toggles.
 */
@WebServlet(name = "RoomServlet", urlPatterns = {"/admin/rooms"})
public class RoomServlet extends HttpServlet {

    private final RoomService roomService = new RoomService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "delete":
                    handleDeleteRoom(request, response);
                    break;
                case "list":
                default:
                    handleListRooms(request, response);
                    break;
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            handleListRooms(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "add";

        try {
            if ("add".equalsIgnoreCase(action)) {
                handleAddRoom(request, response);
            } else if ("update".equalsIgnoreCase(action)) {
                handleUpdateRoom(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/rooms");
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());
            handleListRooms(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Failed to save room: " + e.getMessage());
            handleListRooms(request, response);
        }
    }

    private void handleListRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String typeFilter = request.getParameter("typeFilter");
        String statusFilter = request.getParameter("statusFilter");
        String searchKeyword = request.getParameter("searchKeyword");

        List<Room> rooms = roomService.getFilteredRooms(typeFilter, statusFilter, searchKeyword);
        request.setAttribute("rooms", rooms);
        request.setAttribute("typeFilter", typeFilter);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("searchKeyword", searchKeyword);

        request.getRequestDispatcher("/admin/rooms.jsp").forward(request, response);
    }

    private void handleAddRoom(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String roomNumber = request.getParameter("roomNumber");
        String roomType = request.getParameter("roomType");
        double price = Double.parseDouble(request.getParameter("pricePerNight"));
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        String status = request.getParameter("status");
        String amenities = request.getParameter("amenities");
        String description = request.getParameter("description");

        Room room = new Room(roomNumber, roomType, price, capacity, status, amenities, description);
        roomService.createRoom(room);

        response.sendRedirect(request.getContextPath() + "/admin/rooms?msg=Room%20added%20successfully");
    }

    private void handleUpdateRoom(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        int roomId = Integer.parseInt(request.getParameter("roomId"));
        String roomNumber = request.getParameter("roomNumber");
        String roomType = request.getParameter("roomType");
        double price = Double.parseDouble(request.getParameter("pricePerNight"));
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        String status = request.getParameter("status");
        String amenities = request.getParameter("amenities");
        String description = request.getParameter("description");

        Room room = new Room(roomId, roomNumber, roomType, price, capacity, status, amenities, description, null);
        roomService.updateRoom(room);

        response.sendRedirect(request.getContextPath() + "/admin/rooms?msg=Room%20updated%20successfully");
    }

    private void handleDeleteRoom(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int roomId = Integer.parseInt(request.getParameter("id"));
        boolean success = roomService.deleteRoom(roomId);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/rooms?msg=Room%20deleted%20successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/rooms?error=Cannot%20delete%20room%20associated%20with%20existing%20bookings");
        }
    }
}
