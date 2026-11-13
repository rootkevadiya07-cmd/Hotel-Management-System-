<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.DashboardStats, model.Booking, java.util.List, java.util.Map" %>
<%
    request.setAttribute("pageTitle", "Business Intelligence & Reports");
    DashboardStats stats = (DashboardStats) request.getAttribute("stats");
    if (stats == null) stats = new DashboardStats();

    List<Map<String, Object>> dailyBookings = (List<Map<String, Object>>) request.getAttribute("dailyBookings");
    List<Map<String, Object>> monthlyRevenue = (List<Map<String, Object>>) request.getAttribute("monthlyRevenue");
    List<Map<String, Object>> paymentBreakdown = (List<Map<String, Object>>) request.getAttribute("paymentBreakdown");
    List<Map<String, Object>> roomOccupancy = (List<Map<String, Object>>) request.getAttribute("roomOccupancy");
    List<Booking> allBookings = (List<Booking>) request.getAttribute("allBookings");
%>
<jsp:include page="header.jsp" />

<!-- SUMMARY OVERVIEW CARDS -->
<div class="row g-4 mb-4">
    <div class="col-md-3">
        <div class="metric-card">
            <div class="metric-lbl">Total Rooms Tracked</div>
            <div class="metric-val text-primary"><%= stats.getTotalRooms() %></div>
            <div class="text-muted small mt-2">Available: <strong class="text-success"><%= stats.getAvailableRooms() %></strong> &bull; Occupied: <strong class="text-danger"><%= stats.getOccupiedRooms() %></strong></div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="metric-card">
            <div class="metric-lbl">Occupancy Rate</div>
            <div class="metric-val text-info"><%= String.format("%.1f", stats.getOccupancyRate()) %>%</div>
            <div class="text-muted small mt-2">Maintenance: <strong class="text-warning"><%= stats.getMaintenanceRooms() %></strong></div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="metric-card">
            <div class="metric-lbl">Total Stays Booked</div>
            <div class="metric-val text-dark"><%= stats.getTotalBookings() %></div>
            <div class="text-muted small mt-2">Across <%= stats.getTotalCustomers() %> registered guests</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="metric-card">
            <div class="metric-lbl">All-Time Revenue</div>
            <div class="metric-val text-success">₹<%= String.format("%,.2f", stats.getTotalRevenue()) %></div>
            <div class="text-muted small mt-2">Recorded & reconciled</div>
        </div>
    </div>
</div>

<!-- CHARTS ROW -->
<div class="row g-4 mb-4">
    <!-- Monthly Revenue Bar Chart -->
    <div class="col-lg-8">
        <div class="custom-card p-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0"><i class="fa-solid fa-chart-column text-primary me-2"></i>Monthly Revenue Trends</h5>
                <span class="badge bg-primary-subtle text-primary">Last 6 Months</span>
            </div>
            <div style="height: 280px;">
                <canvas id="revenueChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Payment Methods Breakdown Doughnut Chart -->
    <div class="col-lg-4">
        <div class="custom-card p-4">
            <h5 class="fw-bold mb-3"><i class="fa-solid fa-chart-pie text-warning me-2"></i>Payment Channels</h5>
            <div style="height: 280px;" class="d-flex align-items-center justify-content-center">
                <canvas id="paymentPieChart"></canvas>
            </div>
        </div>
    </div>
</div>

<!-- ROOM OCCUPANCY & DAILY BOOKINGS TABLES -->
<div class="row g-4 mb-4">
    <!-- Room Occupancy by Category -->
    <div class="col-lg-6">
        <div class="custom-card">
            <div class="custom-card-header">
                <h5><i class="fa-solid fa-door-open text-primary me-2"></i>Occupancy by Room Category</h5>
            </div>
            <div class="table-responsive">
                <table class="table custom-table table-hover">
                    <thead>
                        <tr>
                            <th>Category</th>
                            <th class="text-center">Total Rooms</th>
                            <th class="text-center">Occupied</th>
                            <th class="text-center">Available</th>
                            <th class="text-end">Occupancy %</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (roomOccupancy != null && !roomOccupancy.isEmpty()) {
                            for (Map<String, Object> r : roomOccupancy) {
                                int total = (Integer) r.get("total");
                                int occupied = ((Number) r.get("occupied")).intValue();
                                int avail = ((Number) r.get("available")).intValue();
                                double pct = total > 0 ? ((double) occupied / total) * 100.0 : 0.0;
                        %>
                        <tr>
                            <td><strong><%= r.get("type") %></strong></td>
                            <td class="text-center"><%= total %></td>
                            <td class="text-center text-danger fw-semibold"><%= occupied %></td>
                            <td class="text-center text-success fw-semibold"><%= avail %></td>
                            <td class="text-end">
                                <span class="badge bg-primary-subtle text-primary"><%= String.format("%.0f", pct) %>%</span>
                            </td>
                        </tr>
                        <%  }
                        } else { %>
                        <tr><td colspan="5" class="text-center text-muted">No room statistics available.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Daily Bookings Trend Table -->
    <div class="col-lg-6">
        <div class="custom-card">
            <div class="custom-card-header">
                <h5><i class="fa-solid fa-calendar-day text-primary me-2"></i>Daily Bookings Activity (Recent)</h5>
            </div>
            <div class="table-responsive">
                <table class="table custom-table table-hover">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th class="text-center">Bookings Created</th>
                            <th class="text-end">Booking Value (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (dailyBookings != null && !dailyBookings.isEmpty()) {
                            for (Map<String, Object> d : dailyBookings) {
                        %>
                        <tr>
                            <td><i class="fa-regular fa-calendar me-2 text-muted"></i><%= d.get("date") %></td>
                            <td class="text-center fw-bold"><%= d.get("count") %></td>
                            <td class="text-end fw-semibold text-primary">₹<%= String.format("%,.2f", (Double) d.get("totalValue")) %></td>
                        </tr>
                        <%  }
                        } else { %>
                        <tr><td colspan="3" class="text-center text-muted">No daily booking records in window.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- AUDIT LOG: COMPLETE BOOKINGS ARCHIVE -->
<div class="custom-card">
    <div class="custom-card-header">
        <h5><i class="fa-solid fa-list-check text-primary me-2"></i>Master Reservation & Billing Ledger</h5>
    </div>
    <div class="table-responsive">
        <table class="table custom-table table-hover">
            <thead>
                <tr>
                    <th>Ref #</th>
                    <th>Guest Name</th>
                    <th>Room</th>
                    <th>Stay Window</th>
                    <th>Nights</th>
                    <th>Total (₹)</th>
                    <th>Paid (₹)</th>
                    <th>Balance Due</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <% if (allBookings != null && !allBookings.isEmpty()) {
                    for (Booking b : allBookings) {
                %>
                <tr>
                    <td><strong><%= b.getBookingNumber() %></strong></td>
                    <td><%= b.getCustomerName() %></td>
                    <td>Room <%= b.getRoomNumber() %> (<%= b.getRoomType() %>)</td>
                    <td><%= b.getCheckInDate() %> to <%= b.getCheckOutDate() %></td>
                    <td class="text-center"><%= b.getTotalDays() %></td>
                    <td>₹<%= String.format("%,.2f", b.getTotalAmount()) %></td>
                    <td class="text-success">₹<%= String.format("%,.2f", b.getPaidAmount()) %></td>
                    <td class="<%= b.getRemainingBalance() > 0 ? "text-danger fw-bold" : "text-muted" %>">
                        ₹<%= String.format("%,.2f", b.getRemainingBalance()) %>
                    </td>
                    <td><span class="badge bg-secondary"><%= b.getBookingStatus() %></span></td>
                </tr>
                <%  }
                } else { %>
                <tr><td colspan="9" class="text-center text-muted py-3">No bookings on file.</td></tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- CHART.JS INITIALIZATION SCRIPTS -->
<script>
document.addEventListener('DOMContentLoaded', function () {
    // 1. Monthly Revenue Chart
    <%
        StringBuilder mLabels = new StringBuilder("[");
        StringBuilder mData = new StringBuilder("[");
        if (monthlyRevenue != null) {
            for (int i = 0; i < monthlyRevenue.size(); i++) {
                Map<String, Object> row = monthlyRevenue.get(i);
                mLabels.append("\"").append(row.get("month")).append("\"");
                mData.append(row.get("revenue"));
                if (i < monthlyRevenue.size() - 1) {
                    mLabels.append(",");
                    mData.append(",");
                }
            }
        }
        mLabels.append("]");
        mData.append("]");
    %>
    const revCtx = document.getElementById('revenueChart');
    if (revCtx) {
        new Chart(revCtx, {
            type: 'bar',
            data: {
                labels: <%= mLabels.toString() %>,
                datasets: [{
                    label: 'Revenue (₹)',
                    data: <%= mData.toString() %>,
                    backgroundColor: 'rgba(37, 99, 235, 0.7)',
                    borderColor: 'rgba(37, 99, 235, 1)',
                    borderWidth: 1.5,
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) { return '₹' + value.toLocaleString(); }
                        }
                    }
                }
            }
        });
    }

    // 2. Payment Method Breakdown Chart
    <%
        StringBuilder pLabels = new StringBuilder("[");
        StringBuilder pData = new StringBuilder("[");
        if (paymentBreakdown != null) {
            for (int i = 0; i < paymentBreakdown.size(); i++) {
                Map<String, Object> row = paymentBreakdown.get(i);
                pLabels.append("\"").append(row.get("method")).append("\"");
                pData.append(row.get("total"));
                if (i < paymentBreakdown.size() - 1) {
                    pLabels.append(",");
                    pData.append(",");
                }
            }
        }
        pLabels.append("]");
        pData.append("]");
    %>
    const payCtx = document.getElementById('paymentPieChart');
    if (payCtx) {
        new Chart(payCtx, {
            type: 'doughnut',
            data: {
                labels: <%= pLabels.toString() %>,
                datasets: [{
                    data: <%= pData.toString() %>,
                    backgroundColor: ['#10b981', '#06b6d4', '#6366f1', '#f59e0b']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
    }
});
</script>

<jsp:include page="footer.jsp" />
