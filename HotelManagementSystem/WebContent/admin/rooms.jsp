<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Room, java.util.List" %>
<%
    request.setAttribute("pageTitle", "Room Management");
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    String typeFilter = (String) request.getAttribute("typeFilter");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
%>
<jsp:include page="header.jsp" />

<!-- FILTER BAR & ADD ACTION -->
<div class="custom-card p-3 mb-4">
    <form action="<%= request.getContextPath() %>/admin/rooms" method="GET" class="row g-2 align-items-center">
        <div class="col-md-3">
            <input type="text" name="searchKeyword" class="form-control" placeholder="Search room # or amenity..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
        </div>
        <div class="col-md-3">
            <select name="typeFilter" class="form-select">
                <option value="ALL">All Room Types</option>
                <option value="Single Room" <%= "Single Room".equals(typeFilter) ? "selected" : "" %>>Single Room</option>
                <option value="Double Room" <%= "Double Room".equals(typeFilter) ? "selected" : "" %>>Double Room</option>
                <option value="Deluxe Room" <%= "Deluxe Room".equals(typeFilter) ? "selected" : "" %>>Deluxe Room</option>
                <option value="Suite Room" <%= "Suite Room".equals(typeFilter) ? "selected" : "" %>>Suite Room</option>
            </select>
        </div>
        <div class="col-md-2">
            <select name="statusFilter" class="form-select">
                <option value="ALL">All Statuses</option>
                <option value="Available" <%= "Available".equals(statusFilter) ? "selected" : "" %>>Available</option>
                <option value="Occupied" <%= "Occupied".equals(statusFilter) ? "selected" : "" %>>Occupied</option>
                <option value="Maintenance" <%= "Maintenance".equals(statusFilter) ? "selected" : "" %>>Maintenance</option>
            </select>
        </div>
        <div class="col-md-2 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100"><i class="fa-solid fa-filter me-1"></i>Filter</button>
            <a href="<%= request.getContextPath() %>/admin/rooms" class="btn btn-outline-secondary" title="Reset Filters"><i class="fa-solid fa-rotate-right"></i></a>
        </div>
        <div class="col-md-2 text-md-end">
            <button type="button" class="btn btn-success w-100" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                <i class="fa-solid fa-plus me-1"></i> Add Room
            </button>
        </div>
    </form>
</div>

<!-- ROOMS TABLE -->
<div class="custom-card">
    <div class="custom-card-header">
        <h5><i class="fa-solid fa-door-closed text-primary me-2"></i>Hotel Rooms Inventory (<%= rooms != null ? rooms.size() : 0 %>)</h5>
    </div>
    <div class="table-responsive">
        <table class="table custom-table table-hover">
            <thead>
                <tr>
                    <th>Room #</th>
                    <th>Category</th>
                    <th>Price / Night</th>
                    <th>Max Guests</th>
                    <th>Status</th>
                    <th>Amenities</th>
                    <th class="text-end">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (rooms != null && !rooms.isEmpty()) {
                    for (Room r : rooms) {
                        String badgeClass = "badge-available";
                        if ("Occupied".equalsIgnoreCase(r.getStatus())) badgeClass = "badge-occupied";
                        else if ("Maintenance".equalsIgnoreCase(r.getStatus())) badgeClass = "badge-maintenance";
                %>
                <tr>
                    <td>
                        <strong class="text-primary fs-6"><%= r.getRoomNumber() %></strong>
                    </td>
                    <td>
                        <span class="fw-semibold"><%= r.getRoomType() %></span>
                    </td>
                    <td>
                        <strong class="text-dark">₹<%= String.format("%,.2f", r.getPricePerNight()) %></strong>
                    </td>
                    <td>
                        <i class="fa-solid fa-user-group text-muted me-1"></i><%= r.getCapacity() %>
                    </td>
                    <td>
                        <span class="badge-status <%= badgeClass %>">
                            <i class="fa-solid fa-circle" style="font-size: 0.45rem;"></i>
                            <%= r.getStatus() %>
                        </span>
                    </td>
                    <td style="max-width: 280px;">
                        <small class="text-muted d-block text-truncate" title="<%= r.getAmenities() %>">
                            <%= r.getAmenities() != null ? r.getAmenities() : "Standard amenities" %>
                        </small>
                    </td>
                    <td class="text-end">
                        <div class="btn-group btn-group-sm">
                            <button type="button" class="btn btn-outline-primary btn-edit-room" title="Edit Room"
                                data-id="<%= r.getRoomId() %>"
                                data-number="<%= r.getRoomNumber() %>"
                                data-type="<%= r.getRoomType() %>"
                                data-price="<%= r.getPricePerNight() %>"
                                data-capacity="<%= r.getCapacity() %>"
                                data-status="<%= r.getStatus() %>"
                                data-amenities="<%= r.getAmenities() != null ? r.getAmenities().replace("\"", "&quot;") : "" %>"
                                data-description="<%= r.getDescription() != null ? r.getDescription().replace("\"", "&quot;") : "" %>"
                                data-bs-toggle="modal" data-bs-target="#editRoomModal">
                                <i class="fa-solid fa-pen-to-square"></i>
                            </button>
                            <a href="<%= request.getContextPath() %>/admin/rooms?action=delete&id=<%= r.getRoomId() %>" 
                               class="btn btn-outline-danger" title="Delete Room" 
                               onclick="return confirm('Are you sure you want to delete Room <%= r.getRoomNumber() %>?');">
                                <i class="fa-solid fa-trash-can"></i>
                            </a>
                        </div>
                    </td>
                </tr>
                <%  }
                } else { %>
                <tr>
                    <td colspan="7" class="text-center py-4 text-muted">No rooms found matching the criteria.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- ADD ROOM MODAL -->
<div class="modal fade" id="addRoomModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/rooms" method="POST">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-door-open text-primary me-2"></i>Add New Hotel Room</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Room Number *</label>
                        <input type="text" name="roomNumber" class="form-control" placeholder="e.g. 105, 204" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Room Category *</label>
                        <select name="roomType" class="form-select" required>
                            <option value="Single Room">Single Room</option>
                            <option value="Double Room">Double Room</option>
                            <option value="Deluxe Room">Deluxe Room</option>
                            <option value="Suite Room">Suite Room</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Price per Night (₹) *</label>
                        <input type="number" step="0.01" name="pricePerNight" class="form-control" placeholder="1500.00" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Max Guests / Capacity *</label>
                        <input type="number" name="capacity" class="form-control" value="2" min="1" max="10" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Initial Status *</label>
                        <select name="status" class="form-select" required>
                            <option value="Available">Available</option>
                            <option value="Occupied">Occupied</option>
                            <option value="Maintenance">Maintenance</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Amenities (comma-separated)</label>
                        <input type="text" name="amenities" class="form-control" placeholder="Free Wi-Fi, King Bed, AC, Smart LED TV, Mini Refrigerator">
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Description</label>
                        <textarea name="description" class="form-control" rows="2" placeholder="Brief summary of room highlights, view, layout..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-save me-1"></i>Save Room</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- EDIT ROOM MODAL -->
<div class="modal fade" id="editRoomModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/rooms" method="POST">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="roomId" id="editRoomId">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-pen-to-square text-primary me-2"></i>Edit Room Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Room Number *</label>
                        <input type="text" name="roomNumber" id="editRoomNumber" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Room Category *</label>
                        <select name="roomType" id="editRoomType" class="form-select" required>
                            <option value="Single Room">Single Room</option>
                            <option value="Double Room">Double Room</option>
                            <option value="Deluxe Room">Deluxe Room</option>
                            <option value="Suite Room">Suite Room</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Price per Night (₹) *</label>
                        <input type="number" step="0.01" name="pricePerNight" id="editPricePerNight" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Max Capacity *</label>
                        <input type="number" name="capacity" id="editCapacity" class="form-control" min="1" max="10" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Status *</label>
                        <select name="status" id="editStatus" class="form-select" required>
                            <option value="Available">Available</option>
                            <option value="Occupied">Occupied</option>
                            <option value="Maintenance">Maintenance</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Amenities</label>
                        <input type="text" name="amenities" id="editAmenities" class="form-control">
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Description</label>
                        <textarea name="description" id="editDescription" class="form-control" rows="2"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check me-1"></i>Update Room</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
