<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Booking, model.Room, model.Customer, java.util.List" %>
<%
    request.setAttribute("pageTitle", "Room Bookings & Schedule");
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
%>
<jsp:include page="header.jsp" />

<!-- FILTER BAR & NEW BOOKING ACTION -->
<div class="custom-card p-3 mb-4">
    <form action="<%= request.getContextPath() %>/admin/bookings" method="GET" class="row g-2 align-items-center">
        <div class="col-md-5">
            <div class="input-group">
                <span class="input-group-text bg-white"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                <input type="text" name="searchKeyword" class="form-control" placeholder="Search booking ref, guest name, phone or room #..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
            </div>
        </div>
        <div class="col-md-3">
            <select name="statusFilter" class="form-select">
                <option value="ALL">All Booking Statuses</option>
                <option value="Confirmed" <%= "Confirmed".equals(statusFilter) ? "selected" : "" %>>Confirmed</option>
                <option value="Checked-In" <%= "Checked-In".equals(statusFilter) ? "selected" : "" %>>Checked-In</option>
                <option value="Checked-Out" <%= "Checked-Out".equals(statusFilter) ? "selected" : "" %>>Checked-Out</option>
                <option value="Cancelled" <%= "Cancelled".equals(statusFilter) ? "selected" : "" %>>Cancelled</option>
            </select>
        </div>
        <div class="col-md-2 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100"><i class="fa-solid fa-filter me-1"></i>Filter</button>
            <a href="<%= request.getContextPath() %>/admin/bookings" class="btn btn-outline-secondary" title="Reset Filters"><i class="fa-solid fa-rotate-right"></i></a>
        </div>
        <div class="col-md-2 text-md-end">
            <button type="button" class="btn btn-success w-100" data-bs-toggle="modal" data-bs-target="#newBookingModal">
                <i class="fa-solid fa-plus me-1"></i> New Booking
            </button>
        </div>
    </form>
</div>

<!-- BOOKINGS TABLE -->
<div class="custom-card">
    <div class="custom-card-header">
        <h5><i class="fa-solid fa-calendar-days text-primary me-2"></i>Reservations Ledger (<%= bookings != null ? bookings.size() : 0 %>)</h5>
    </div>
    <div class="table-responsive">
        <table class="table custom-table table-hover">
            <thead>
                <tr>
                    <th>Booking Ref</th>
                    <th>Guest Information</th>
                    <th>Room Details</th>
                    <th>Stay Dates</th>
                    <th>Total & Balance</th>
                    <th>Status</th>
                    <th class="text-end">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (bookings != null && !bookings.isEmpty()) {
                    for (Booking b : bookings) {
                        String badgeClass = "badge-confirmed";
                        if ("Checked-In".equalsIgnoreCase(b.getBookingStatus())) badgeClass = "badge-checkedin";
                        else if ("Checked-Out".equalsIgnoreCase(b.getBookingStatus())) badgeClass = "badge-checkedout";
                        else if ("Cancelled".equalsIgnoreCase(b.getBookingStatus())) badgeClass = "badge-cancelled";
                %>
                <tr>
                    <td>
                        <strong class="text-primary fs-6"><%= b.getBookingNumber() %></strong>
                        <div class="text-muted" style="font-size: 0.72rem;"><%= b.getCreatedAt() != null ? b.getCreatedAt().toString().substring(0, 10) : "" %></div>
                    </td>
                    <td>
                        <div class="fw-bold"><%= b.getCustomerName() %></div>
                        <small class="text-muted"><i class="fa-solid fa-phone me-1"></i><%= b.getCustomerPhone() %></small>
                    </td>
                    <td>
                        <span class="badge bg-light text-dark border">Room <%= b.getRoomNumber() %></span>
                        <div class="text-muted" style="font-size: 0.78rem;"><%= b.getRoomType() %></div>
                    </td>
                    <td>
                        <div style="font-size: 0.88rem;"><%= b.getCheckInDate() %> &rarr; <%= b.getCheckOutDate() %></div>
                        <small class="text-muted"><%= b.getTotalDays() %> <%= b.getTotalDays() == 1 ? "night" : "nights" %></small>
                    </td>
                    <td>
                        <div>Total: <strong>₹<%= String.format("%,.2f", b.getTotalAmount()) %></strong></div>
                        <% if (b.getRemainingBalance() > 0) { %>
                            <small class="text-danger fw-semibold">Due: ₹<%= String.format("%,.2f", b.getRemainingBalance()) %></small>
                        <% } else { %>
                            <small class="text-success fw-semibold"><i class="fa-solid fa-check me-1"></i>Paid in Full</small>
                        <% } %>
                    </td>
                    <td>
                        <span class="badge-status <%= badgeClass %>">
                            <i class="fa-solid fa-circle" style="font-size: 0.45rem;"></i>
                            <%= b.getBookingStatus() %>
                        </span>
                    </td>
                    <td class="text-end">
                        <div class="btn-group btn-group-sm">
                            <a href="<%= request.getContextPath() %>/admin/invoice?bookingId=<%= b.getBookingId() %>" class="btn btn-outline-secondary" title="View / Print Invoice">
                                <i class="fa-solid fa-file-invoice"></i>
                            </a>

                            <% if ("Confirmed".equalsIgnoreCase(b.getBookingStatus())) { %>
                                <a href="<%= request.getContextPath() %>/admin/checkinout?action=checkin&id=<%= b.getBookingId() %>" class="btn btn-outline-success" title="Check-In Guest" onclick="return confirm('Confirm guest check-in for room <%= b.getRoomNumber() %>?');">
                                    <i class="fa-solid fa-key"></i>
                                </a>
                            <% } else if ("Checked-In".equalsIgnoreCase(b.getBookingStatus())) { %>
                                <a href="<%= request.getContextPath() %>/admin/checkinout?action=checkout&id=<%= b.getBookingId() %>" class="btn btn-outline-warning" title="Check-Out Guest & Bill" onclick="return confirm('Confirm guest check-out for room <%= b.getRoomNumber() %>?');">
                                    <i class="fa-solid fa-door-closed"></i>
                                </a>
                            <% } %>

                            <% if (b.getRemainingBalance() > 0 && !"Cancelled".equalsIgnoreCase(b.getBookingStatus())) { %>
                                <button type="button" class="btn btn-outline-primary" title="Record Payment"
                                    onclick="openPaymentModal(<%= b.getBookingId() %>, '<%= b.getBookingNumber() %>', <%= b.getRemainingBalance() %>)"
                                    data-bs-toggle="modal" data-bs-target="#recordPaymentModal">
                                    <i class="fa-solid fa-hand-holding-dollar"></i>
                                </button>
                            <% } %>

                            <% if (!"Cancelled".equalsIgnoreCase(b.getBookingStatus()) && !"Checked-Out".equalsIgnoreCase(b.getBookingStatus())) { %>
                                <a href="<%= request.getContextPath() %>/admin/bookings?action=cancel&id=<%= b.getBookingId() %>" class="btn btn-outline-danger" title="Cancel Booking" onclick="return confirm('Are you sure you want to cancel reservation <%= b.getBookingNumber() %>?');">
                                    <i class="fa-solid fa-ban"></i>
                                </a>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <%  }
                } else { %>
                <tr>
                    <td colspan="7" class="text-center py-4 text-muted">No reservations found.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- NEW BOOKING MODAL -->
<div class="modal fade" id="newBookingModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/bookings" method="POST" class="booking-calc-form">
                <input type="hidden" name="action" value="create">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-calendar-plus text-primary me-2"></i>Create New Room Reservation</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <!-- Guest Selection Mode Toggle -->
                    <div class="col-12">
                        <div class="btn-group w-100" role="group">
                            <input type="radio" class="btn-check" name="guestMode" id="modeExisting" autocomplete="off" checked onclick="toggleGuestMode('existing')">
                            <label class="btn btn-outline-primary" for="modeExisting"><i class="fa-solid fa-users me-1"></i>Registered Guest</label>

                            <input type="radio" class="btn-check" name="guestMode" id="modeNew" autocomplete="off" onclick="toggleGuestMode('new')">
                            <label class="btn btn-outline-primary" for="modeNew"><i class="fa-solid fa-user-plus me-1"></i>New Guest (Quick Entry)</label>
                        </div>
                    </div>

                    <!-- Existing Customer Select Box -->
                    <div class="col-md-6" id="existingCustomerBox">
                        <label class="form-label fw-semibold">Select Registered Guest *</label>
                        <select name="customerId" id="existingCustSelect" class="form-select">
                            <option value="">-- Choose Guest --</option>
                            <% if (customers != null) {
                                for (Customer c : customers) { %>
                                <option value="<%= c.getCustomerId() %>"><%= c.getFullName() %> (<%= c.getPhone() %>)</option>
                            <%  }
                            } %>
                        </select>
                    </div>

                    <!-- New Guest Quick Registration Fields -->
                    <div class="col-12 d-none" id="newCustomerBox">
                        <div class="p-3 bg-light rounded border row g-2">
                            <div class="col-12 fw-bold text-dark mb-1"><i class="fa-solid fa-id-card text-primary me-1"></i>New Guest Profile</div>
                            <div class="col-md-6">
                                <input type="text" name="quickFullName" class="form-control" placeholder="Full Name *">
                            </div>
                            <div class="col-md-6">
                                <input type="tel" name="quickPhone" class="form-control" placeholder="Phone Number *">
                            </div>
                            <div class="col-md-6">
                                <input type="email" name="quickEmail" class="form-control" placeholder="Email Address">
                            </div>
                            <div class="col-md-3">
                                <select name="quickIdType" class="form-select">
                                    <option value="Passport">Passport</option>
                                    <option value="Aadhaar">Aadhaar</option>
                                    <option value="Driving License">Driving License</option>
                                    <option value="National ID">National ID</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <input type="text" name="quickIdNumber" class="form-control" placeholder="ID Number">
                            </div>
                        </div>
                    </div>

                    <!-- Room Selection -->
                    <div class="col-md-6" id="roomSelectBox">
                        <label class="form-label fw-semibold">Select Room *</label>
                        <select name="roomId" class="form-select" required>
                            <option value="">-- Choose Room --</option>
                            <% if (rooms != null) {
                                for (Room r : rooms) { %>
                                <option value="<%= r.getRoomId() %>" data-price="<%= r.getPricePerNight() %>" <%= "Maintenance".equalsIgnoreCase(r.getStatus()) ? "disabled" : "" %>>
                                    Room <%= r.getRoomNumber() %> - <%= r.getRoomType() %> (₹<%= String.format("%.2f", r.getPricePerNight()) %>/night) <%= "Maintenance".equalsIgnoreCase(r.getStatus()) ? "[Maintenance]" : "" %>
                                </option>
                            <%  }
                            } %>
                        </select>
                    </div>

                    <!-- Dates Selection -->
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Check-In Date *</label>
                        <input type="date" name="checkInDate" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Check-Out Date *</label>
                        <input type="date" name="checkOutDate" class="form-control" required>
                    </div>

                    <!-- Dynamic Cost Preview Panel -->
                    <div class="col-12">
                        <div class="p-3 bg-light rounded border d-flex justify-content-between align-items-center">
                            <div>
                                <div class="text-muted" style="font-size: 0.85rem;">Calculated Duration: <strong class="calc-days-display text-dark">1 night</strong></div>
                                <div class="text-muted" style="font-size: 0.85rem;">Nightly Rate: <strong class="calc-price-display text-dark">₹0.00</strong></div>
                            </div>
                            <div class="text-end">
                                <div class="text-muted" style="font-size: 0.8rem; text-transform: uppercase; font-weight: 600;">Total Cost</div>
                                <div class="fs-4 fw-bold text-primary calc-total-display">₹0.00</div>
                            </div>
                        </div>
                    </div>

                    <!-- Initial Payment -->
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Initial Advance Payment (Optional, ₹)</label>
                        <input type="number" step="0.01" name="initialPayment" class="form-control" placeholder="0.00">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Payment Method</label>
                        <select name="paymentMethod" class="form-select">
                            <option value="Cash">Cash</option>
                            <option value="UPI">UPI</option>
                            <option value="Card">Card</option>
                        </select>
                    </div>

                    <!-- Notes -->
                    <div class="col-12">
                        <label class="form-label fw-semibold">Special Instructions / Notes</label>
                        <textarea name="notes" class="form-control" rows="2" placeholder="e.g. Early check-in requested, extra bed needed..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check me-1"></i>Confirm Reservation</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- RECORD PAYMENT MODAL -->
<div class="modal fade" id="recordPaymentModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/payments" method="POST">
                <input type="hidden" name="bookingId" id="payBookingId">
                <input type="hidden" name="redirectTarget" value="bookings">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-hand-holding-dollar text-primary me-2"></i>Record Payment</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <div class="col-12">
                        <div class="alert alert-info py-2" style="font-size: 0.9rem;">
                            Booking Ref: <strong id="payBookingNumber">---</strong>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Payment Amount (₹) *</label>
                        <input type="number" step="0.01" name="amount" id="payAmount" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Payment Method *</label>
                        <select name="paymentMethod" class="form-select" required>
                            <option value="Cash">Cash</option>
                            <option value="UPI">UPI</option>
                            <option value="Card">Card</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Transaction / Reference ID</label>
                        <input type="text" name="transactionId" class="form-control" placeholder="e.g. UPI Ref / Card Txn ID">
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Remarks</label>
                        <input type="text" name="remarks" class="form-control" placeholder="Payment remarks...">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check me-1"></i>Submit Payment</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function toggleGuestMode(mode) {
    const exBox = document.getElementById('existingCustomerBox');
    const newBox = document.getElementById('newCustomerBox');
    const exSelect = document.getElementById('existingCustSelect');
    if (mode === 'new') {
        exBox.classList.add('d-none');
        newBox.classList.remove('d-none');
        exSelect.removeAttribute('required');
        exSelect.value = '';
    } else {
        exBox.classList.remove('d-none');
        newBox.classList.add('d-none');
        exSelect.setAttribute('required', 'required');
    }
}
</script>

<jsp:include page="footer.jsp" />
