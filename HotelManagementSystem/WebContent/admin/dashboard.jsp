<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.DashboardStats, model.Booking, model.Payment, util.DBConnection, java.util.List, java.util.Map" %>
<%
    request.setAttribute("pageTitle", "Executive Dashboard");
    DashboardStats stats = (DashboardStats) request.getAttribute("stats");
    if (stats == null) stats = new DashboardStats();

    List<Booking> recentBookings = (List<Booking>) request.getAttribute("recentBookings");
    List<Payment> recentPayments = (List<Payment>) request.getAttribute("recentPayments");
    String dbStatus = DBConnection.getDatabaseDescription();
    boolean isFallback = DBConnection.isFallbackMode();
%>
<jsp:include page="header.jsp" />

<!-- SYSTEM STATUS BANNER -->
<div class="custom-card px-3 py-2 mb-4 d-flex align-items-center justify-content-between">
    <div class="d-flex align-items-center gap-2" style="font-size: 0.88rem;">
        <i class="fa-solid fa-server <%= isFallback ? "text-warning" : "text-success" %>"></i>
        <span>Database Engine: <strong><%= dbStatus %></strong></span>
    </div>
    <div>
        <span class="badge <%= isFallback ? "bg-warning text-dark" : "bg-success" %>">
            <i class="fa-solid fa-circle-check me-1"></i><%= isFallback ? "Zero-Config Fallback Active" : "Live MySQL Connection" %>
        </span>
    </div>
</div>

<!-- METRICS CARDS ROW -->
<div class="row g-4 mb-4">
    <!-- Total Rooms -->
    <div class="col-xl-3 col-sm-6">
        <div class="metric-card">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <div class="metric-lbl">Total Rooms</div>
                    <div class="metric-val"><%= stats.getTotalRooms() %></div>
                </div>
                <div class="icon-bubble bg-primary-subtle text-primary">
                    <i class="fa-solid fa-hotel"></i>
                </div>
            </div>
            <div class="mt-3 text-muted" style="font-size: 0.8rem;">
                <span class="text-secondary"><i class="fa-solid fa-layer-group me-1"></i>4 Distinct Categories</span>
            </div>
        </div>
    </div>

    <!-- Available Rooms -->
    <div class="col-xl-3 col-sm-6">
        <div class="metric-card">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <div class="metric-lbl">Available Rooms</div>
                    <div class="metric-val text-success"><%= stats.getAvailableRooms() %></div>
                </div>
                <div class="icon-bubble bg-success-subtle text-success">
                    <i class="fa-solid fa-door-open"></i>
                </div>
            </div>
            <div class="mt-3 text-muted" style="font-size: 0.8rem;">
                <span class="text-success fw-semibold"><i class="fa-solid fa-check-circle me-1"></i>Ready for Check-in</span>
            </div>
        </div>
    </div>

    <!-- Occupied Rooms -->
    <div class="col-xl-3 col-sm-6">
        <div class="metric-card">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <div class="metric-lbl">Occupied Rooms</div>
                    <div class="metric-val text-danger"><%= stats.getOccupiedRooms() %></div>
                </div>
                <div class="icon-bubble bg-danger-subtle text-danger">
                    <i class="fa-solid fa-user-lock"></i>
                </div>
            </div>
            <div class="mt-3 text-muted" style="font-size: 0.8rem;">
                <span class="text-muted"><%= String.format("%.1f", stats.getOccupancyRate()) %>% Current Occupancy</span>
            </div>
        </div>
    </div>

    <!-- Total Revenue -->
    <div class="col-xl-3 col-sm-6">
        <div class="metric-card">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <div class="metric-lbl">Total Revenue</div>
                    <div class="metric-val text-primary">₹<%= String.format("%,.2f", stats.getTotalRevenue()) %></div>
                </div>
                <div class="icon-bubble bg-warning-subtle text-warning">
                    <i class="fa-solid fa-indian-rupee-sign"></i>
                </div>
            </div>
            <div class="mt-3 text-muted" style="font-size: 0.8rem;">
                <span class="text-success fw-semibold"><i class="fa-solid fa-arrow-trend-up me-1"></i>Verified Ledger</span>
            </div>
        </div>
    </div>
</div>

<!-- SECONDARY STATS & QUICK ACTIONS -->
<div class="row g-4 mb-4">
    <!-- Total Customers -->
    <div class="col-md-4">
        <div class="custom-card p-4 d-flex align-items-center justify-content-between mb-0">
            <div>
                <div class="text-muted text-uppercase fw-bold" style="font-size: 0.75rem;">Registered Guests</div>
                <h3 class="fw-bold my-1"><%= stats.getTotalCustomers() %></h3>
                <a href="<%= request.getContextPath() %>/admin/customers" class="text-primary text-decoration-none fw-semibold" style="font-size: 0.85rem;">
                    Manage Guest Profiles <i class="fa-solid fa-arrow-right ms-1"></i>
                </a>
            </div>
            <div class="icon-bubble bg-info-subtle text-info">
                <i class="fa-solid fa-users"></i>
            </div>
        </div>
    </div>

    <!-- Total Active Staff -->
    <div class="col-md-4">
        <div class="custom-card p-4 d-flex align-items-center justify-content-between mb-0">
            <div>
                <div class="text-muted text-uppercase fw-bold" style="font-size: 0.75rem;">Active Staff</div>
                <h3 class="fw-bold my-1"><%= stats.getTotalStaff() %></h3>
                <a href="<%= request.getContextPath() %>/admin/staff" class="text-primary text-decoration-none fw-semibold" style="font-size: 0.85rem;">
                    View Staff Directory <i class="fa-solid fa-arrow-right ms-1"></i>
                </a>
            </div>
            <div class="icon-bubble bg-secondary-subtle text-dark">
                <i class="fa-solid fa-user-tie"></i>
            </div>
        </div>
    </div>

    <!-- Quick Actions Panel -->
    <div class="col-md-4">
        <div class="custom-card p-4 mb-0 d-flex flex-column justify-content-center">
            <div class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.75rem;">Quick Operations</div>
            <div class="d-flex gap-2">
                <a href="<%= request.getContextPath() %>/admin/bookings" class="btn btn-primary btn-sm flex-fill">
                    <i class="fa-solid fa-plus me-1"></i> New Booking
                </a>
                <a href="<%= request.getContextPath() %>/admin/rooms" class="btn btn-outline-secondary btn-sm flex-fill">
                    <i class="fa-solid fa-door-open me-1"></i> Add Room
                </a>
            </div>
        </div>
    </div>
</div>

<!-- TABLES ROW -->
<div class="row g-4">
    <!-- Recent Bookings Table -->
    <div class="col-xl-8">
        <div class="custom-card">
            <div class="custom-card-header">
                <h5><i class="fa-solid fa-calendar-check text-primary me-2"></i>Recent Room Bookings</h5>
                <a href="<%= request.getContextPath() %>/admin/bookings" class="btn btn-sm btn-outline-primary">View All</a>
            </div>
            <div class="table-responsive">
                <table class="table custom-table table-hover">
                    <thead>
                        <tr>
                            <th>Ref Number</th>
                            <th>Guest Name</th>
                            <th>Room</th>
                            <th>Dates</th>
                            <th>Status</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (recentBookings != null && !recentBookings.isEmpty()) {
                            for (Booking b : recentBookings) {
                                String statusBadgeClass = "badge-confirmed";
                                if ("Checked-In".equalsIgnoreCase(b.getBookingStatus())) statusBadgeClass = "badge-checkedin";
                                else if ("Checked-Out".equalsIgnoreCase(b.getBookingStatus())) statusBadgeClass = "badge-checkedout";
                                else if ("Cancelled".equalsIgnoreCase(b.getBookingStatus())) statusBadgeClass = "badge-cancelled";
                        %>
                        <tr>
                            <td>
                                <strong class="text-primary"><%= b.getBookingNumber() %></strong>
                            </td>
                            <td>
                                <div class="fw-semibold"><%= b.getCustomerName() %></div>
                                <small class="text-muted"><%= b.getCustomerPhone() %></small>
                            </td>
                            <td>
                                <div>Room <%= b.getRoomNumber() %></div>
                                <small class="text-muted"><%= b.getRoomType() %></small>
                            </td>
                            <td>
                                <div style="font-size: 0.85rem;"><%= b.getCheckInDate() %> to <%= b.getCheckOutDate() %></div>
                                <small class="text-muted"><%= b.getTotalDays() %> <%= b.getTotalDays() == 1 ? "night" : "nights" %></small>
                            </td>
                            <td>
                                <span class="badge-status <%= statusBadgeClass %>">
                                    <i class="fa-solid fa-circle" style="font-size: 0.45rem;"></i>
                                    <%= b.getBookingStatus() %>
                                </span>
                            </td>
                            <td class="text-end">
                                <div class="btn-group btn-group-sm">
                                    <a href="<%= request.getContextPath() %>/admin/invoice?bookingId=<%= b.getBookingId() %>" class="btn btn-outline-secondary" title="View Invoice">
                                        <i class="fa-solid fa-file-invoice"></i>
                                    </a>
                                    <% if ("Confirmed".equalsIgnoreCase(b.getBookingStatus())) { %>
                                        <a href="<%= request.getContextPath() %>/admin/checkinout?action=checkin&id=<%= b.getBookingId() %>" class="btn btn-outline-success" title="Check-In Guest" onclick="return confirm('Check-in guest and mark room occupied?');">
                                            <i class="fa-solid fa-key"></i>
                                        </a>
                                    <% } else if ("Checked-In".equalsIgnoreCase(b.getBookingStatus())) { %>
                                        <a href="<%= request.getContextPath() %>/admin/checkinout?action=checkout&id=<%= b.getBookingId() %>" class="btn btn-outline-warning" title="Check-Out Guest" onclick="return confirm('Check-out guest and generate final bill?');">
                                            <i class="fa-solid fa-door-closed"></i>
                                        </a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%  }
                        } else { %>
                        <tr>
                            <td colspan="6" class="text-center py-4 text-muted">No reservations recorded yet.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Recent Payments -->
    <div class="col-xl-4">
        <div class="custom-card">
            <div class="custom-card-header">
                <h5><i class="fa-solid fa-receipt text-warning me-2"></i>Latest Payments</h5>
                <a href="<%= request.getContextPath() %>/admin/payments" class="btn btn-sm btn-outline-secondary">View All</a>
            </div>
            <div class="p-3">
                <% if (recentPayments != null && !recentPayments.isEmpty()) {
                    for (Payment p : recentPayments) { %>
                    <div class="p-3 mb-2 rounded bg-light border d-flex align-items-center justify-content-between">
                        <div>
                            <div class="fw-bold" style="font-size: 0.92rem;"><%= p.getCustomerName() != null ? p.getCustomerName() : "Guest" %></div>
                            <div class="text-muted" style="font-size: 0.78rem;">
                                <%= p.getPaymentMethod() %> &bull; <%= p.getTransactionId() != null ? p.getTransactionId() : "Direct" %>
                            </div>
                        </div>
                        <div class="text-end">
                            <div class="fw-bold text-success">+₹<%= String.format("%,.2f", p.getAmount()) %></div>
                            <small class="badge bg-success-subtle text-success" style="font-size: 0.7rem;"><%= p.getPaymentStatus() %></small>
                        </div>
                    </div>
                <%  }
                } else { %>
                    <p class="text-muted text-center py-4">No recent payments.</p>
                <% } %>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
