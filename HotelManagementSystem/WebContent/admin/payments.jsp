<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Payment, model.Booking, java.util.List" %>
<%
    request.setAttribute("pageTitle", "Payments & Transaction Ledgers");
    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
    List<Booking> activeBookings = (List<Booking>) request.getAttribute("activeBookings");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    if (totalRevenue == null) totalRevenue = 0.0;

    String methodFilter = (String) request.getAttribute("methodFilter");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
%>
<jsp:include page="header.jsp" />

<!-- REVENUE SUMMARY CARD & ACTIONS -->
<div class="row g-4 mb-4">
    <div class="col-md-6">
        <div class="custom-card p-4 mb-0 d-flex align-items-center justify-content-between">
            <div>
                <div class="text-muted text-uppercase fw-bold" style="font-size: 0.75rem;">Total Collected Revenue</div>
                <h2 class="fw-bold my-1 text-primary">₹<%= String.format("%,.2f", totalRevenue) %></h2>
                <small class="text-success"><i class="fa-solid fa-circle-check me-1"></i>Reconciled Transactions</small>
            </div>
            <div class="icon-bubble bg-success-subtle text-success">
                <i class="fa-solid fa-wallet"></i>
            </div>
        </div>
    </div>
    <div class="col-md-6 d-flex align-items-center justify-content-md-end">
        <button type="button" class="btn btn-success btn-lg" data-bs-toggle="modal" data-bs-target="#directPaymentModal">
            <i class="fa-solid fa-plus me-1"></i> Record New Payment
        </button>
    </div>
</div>

<!-- FILTERS BAR -->
<div class="custom-card p-3 mb-4">
    <form action="<%= request.getContextPath() %>/admin/payments" method="GET" class="row g-2 align-items-center">
        <div class="col-md-4">
            <input type="text" name="searchKeyword" class="form-control" placeholder="Search transaction ID, customer, booking #..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
        </div>
        <div class="col-md-3">
            <select name="methodFilter" class="form-select">
                <option value="ALL">All Payment Methods</option>
                <option value="Cash" <%= "Cash".equals(methodFilter) ? "selected" : "" %>>Cash</option>
                <option value="UPI" <%= "UPI".equals(methodFilter) ? "selected" : "" %>>UPI</option>
                <option value="Card" <%= "Card".equals(methodFilter) ? "selected" : "" %>>Card</option>
            </select>
        </div>
        <div class="col-md-3">
            <select name="statusFilter" class="form-select">
                <option value="ALL">All Statuses</option>
                <option value="Completed" <%= "Completed".equals(statusFilter) ? "selected" : "" %>>Completed</option>
                <option value="Pending" <%= "Pending".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                <option value="Refunded" <%= "Refunded".equals(statusFilter) ? "selected" : "" %>>Refunded</option>
            </select>
        </div>
        <div class="col-md-2 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100"><i class="fa-solid fa-filter me-1"></i>Filter</button>
            <a href="<%= request.getContextPath() %>/admin/payments" class="btn btn-outline-secondary"><i class="fa-solid fa-rotate-right"></i></a>
        </div>
    </form>
</div>

<!-- PAYMENTS LEDGER TABLE -->
<div class="custom-card">
    <div class="custom-card-header">
        <h5><i class="fa-solid fa-receipt text-primary me-2"></i>Payment Transactions (<%= payments != null ? payments.size() : 0 %>)</h5>
    </div>
    <div class="table-responsive">
        <table class="table custom-table table-hover">
            <thead>
                <tr>
                    <th>Txn ID / Ref</th>
                    <th>Date & Time</th>
                    <th>Booking / Guest</th>
                    <th>Room</th>
                    <th>Amount</th>
                    <th>Method</th>
                    <th>Status</th>
                    <th class="text-end">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (payments != null && !payments.isEmpty()) {
                    for (Payment p : payments) {
                        String methodIcon = "fa-solid fa-money-bill-wave text-success";
                        if ("UPI".equalsIgnoreCase(p.getPaymentMethod())) methodIcon = "fa-solid fa-mobile-screen text-info";
                        else if ("Card".equalsIgnoreCase(p.getPaymentMethod())) methodIcon = "fa-solid fa-credit-card text-primary";
                %>
                <tr>
                    <td>
                        <strong class="text-dark"><%= p.getTransactionId() != null ? p.getTransactionId() : ("#PAY-" + p.getPaymentId()) %></strong>
                        <div class="text-muted" style="font-size: 0.72rem;"><%= p.getRemarks() != null ? p.getRemarks() : "" %></div>
                    </td>
                    <td>
                        <div style="font-size: 0.88rem;"><%= p.getPaymentDate() %></div>
                    </td>
                    <td>
                        <div class="fw-bold"><%= p.getCustomerName() != null ? p.getCustomerName() : "Guest" %></div>
                        <small class="text-muted">Ref: <%= p.getBookingNumber() %></small>
                    </td>
                    <td>
                        <span class="badge bg-light text-dark border">Room <%= p.getRoomNumber() %></span>
                    </td>
                    <td>
                        <strong class="text-success fs-6">₹<%= String.format("%,.2f", p.getAmount()) %></strong>
                    </td>
                    <td>
                        <span><i class="<%= methodIcon %> me-1"></i><%= p.getPaymentMethod() %></span>
                    </td>
                    <td>
                        <span class="badge bg-success-subtle text-success">
                            <i class="fa-solid fa-circle-check me-1"></i><%= p.getPaymentStatus() %>
                        </span>
                    </td>
                    <td class="text-end">
                        <a href="<%= request.getContextPath() %>/admin/invoice?bookingId=<%= p.getBookingId() %>" class="btn btn-sm btn-outline-secondary" title="View Full Invoice">
                            <i class="fa-solid fa-file-invoice me-1"></i> Invoice
                        </a>
                    </td>
                </tr>
                <%  }
                } else { %>
                <tr>
                    <td colspan="8" class="text-center py-4 text-muted">No payments found matching the criteria.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- DIRECT PAYMENT MODAL -->
<div class="modal fade" id="directPaymentModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/payments" method="POST">
                <input type="hidden" name="redirectTarget" value="payments">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-wallet text-primary me-2"></i>Record Guest Payment</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <div class="col-12">
                        <label class="form-label fw-semibold">Select Reservation *</label>
                        <select name="bookingId" class="form-select" required>
                            <option value="">-- Choose Booking --</option>
                            <% if (activeBookings != null) {
                                for (Booking b : activeBookings) { %>
                                <option value="<%= b.getBookingId() %>">
                                    <%= b.getBookingNumber() %> - <%= b.getCustomerName() %> (Room <%= b.getRoomNumber() %>) - Due: ₹<%= String.format("%.2f", b.getRemainingBalance()) %>
                                </option>
                            <%  }
                            } %>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Amount to Pay (₹) *</label>
                        <input type="number" step="0.01" name="amount" class="form-control" placeholder="1000.00" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Payment Mode *</label>
                        <select name="paymentMethod" class="form-select" required>
                            <option value="Cash">Cash</option>
                            <option value="UPI">UPI</option>
                            <option value="Card">Card</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Transaction / Reference ID</label>
                        <input type="text" name="transactionId" class="form-control" placeholder="e.g. UPI-REF-1092384">
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Remarks</label>
                        <input type="text" name="remarks" class="form-control" placeholder="e.g. Settlement upon checkout">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check me-1"></i>Record Payment</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
