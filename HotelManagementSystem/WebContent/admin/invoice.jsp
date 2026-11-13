<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Booking, model.Payment, java.util.List" %>
<%
    request.setAttribute("pageTitle", "Guest Folio & Invoice");
    Booking booking = (Booking) request.getAttribute("booking");
    List<Payment> payments = (List<Payment>) request.getAttribute("payments");

    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/admin/bookings");
        return;
    }

    double baseTotal = booking.getTotalAmount();
    double gstRate = 0.12; // 12% Hotel GST
    double gstAmount = Math.round(baseTotal * gstRate * 100.0) / 100.0;
    double grandTotal = baseTotal; // Room charge already configured as total contract price or with tax
    double paidTotal = booking.getPaidAmount();
    double balanceDue = booking.getRemainingBalance();
%>
<jsp:include page="header.jsp" />

<!-- ACTION CONTROLS (Hidden during print) -->
<div class="d-flex justify-content-between align-items-center mb-4 no-print">
    <a href="<%= request.getContextPath() %>/admin/bookings" class="btn btn-outline-secondary">
        <i class="fa-solid fa-arrow-left me-1"></i> Back to Bookings
    </a>
    <div class="d-flex gap-2">
        <% if (balanceDue > 0 && !"Cancelled".equalsIgnoreCase(booking.getBookingStatus())) { %>
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#payBalanceModal">
                <i class="fa-solid fa-credit-card me-1"></i> Settle Balance (₹<%= String.format("%.2f", balanceDue) %>)
            </button>
        <% } %>
        <button type="button" class="btn btn-dark" onclick="window.print()">
            <i class="fa-solid fa-print me-1"></i> Print Invoice
        </button>
    </div>
</div>

<!-- INVOICE CONTAINER -->
<div class="custom-card invoice-box p-4 p-md-5 mx-auto" style="max-width: 900px;">
    <!-- HEADER -->
    <div class="row align-items-center pb-4 border-bottom mb-4">
        <div class="col-sm-7">
            <div class="d-flex align-items-center gap-2 mb-2">
                <i class="fa-solid fa-hotel text-primary fs-2"></i>
                <h3 class="fw-bold mb-0 text-dark">GRAND AZURE</h3>
            </div>
            <div class="text-muted" style="font-size: 0.88rem;">
                Luxury Hotel & Executive Suites<br>
                42 Marine Drive, Promenade Bay, Mumbai - 400020<br>
                Tel: +91 22 2849 5500 &bull; reservations@grandazure.com<br>
                GSTIN / Tax ID: 27AAAAA0000A1Z5
            </div>
        </div>
        <div class="col-sm-5 text-sm-end mt-3 mt-sm-0">
            <h4 class="text-uppercase fw-bold text-primary mb-1">TAX INVOICE</h4>
            <div class="text-muted" style="font-size: 0.88rem;">
                <strong>Invoice #:</strong> INV-<%= booking.getBookingId() %><br>
                <strong>Date:</strong> <%= new java.text.SimpleDateFormat("dd MMM yyyy").format(new java.util.Date()) %><br>
                <strong>Booking Ref:</strong> <span class="badge bg-primary text-white"><%= booking.getBookingNumber() %></span><br>
                <strong>Status:</strong> <span class="badge bg-secondary"><%= booking.getBookingStatus() %></span>
            </div>
        </div>
    </div>

    <!-- BILLED TO & STAY SUMMARY -->
    <div class="row mb-4">
        <div class="col-sm-6 mb-3 mb-sm-0">
            <h6 class="text-uppercase text-muted fw-bold mb-2" style="font-size: 0.78rem;">GUEST INFORMATION</h6>
            <div class="fw-bold text-dark fs-5"><%= booking.getCustomerName() %></div>
            <div class="text-muted" style="font-size: 0.9rem;">
                <i class="fa-solid fa-phone me-1"></i> <%= booking.getCustomerPhone() %><br>
                <i class="fa-solid fa-envelope me-1"></i> <%= booking.getCustomerEmail() != null ? booking.getCustomerEmail() : "N/A" %><br>
                <i class="fa-solid fa-id-card me-1"></i> ID Proof: <%= booking.getCustomerIdProof() != null ? booking.getCustomerIdProof() : "Verified on File" %><br>
                <i class="fa-solid fa-location-dot me-1"></i> <%= booking.getCustomerAddress() != null ? booking.getCustomerAddress() : "" %>
            </div>
        </div>
        <div class="col-sm-6 text-sm-end">
            <h6 class="text-uppercase text-muted fw-bold mb-2" style="font-size: 0.78rem;">STAY SCHEDULE</h6>
            <div class="text-dark" style="font-size: 0.92rem;">
                <strong>Room Assigned:</strong> Room <%= booking.getRoomNumber() %> (<%= booking.getRoomType() %>)<br>
                <strong>Check-In Date:</strong> <%= booking.getCheckInDate() %><br>
                <strong>Check-Out Date:</strong> <%= booking.getCheckOutDate() %><br>
                <strong>Stay Duration:</strong> <%= booking.getTotalDays() %> <%= booking.getTotalDays() == 1 ? "Night" : "Nights" %>
            </div>
        </div>
    </div>

    <!-- ITEMIZED CHARGES TABLE -->
    <div class="table-responsive mb-4">
        <table class="table table-bordered">
            <thead class="table-light">
                <tr>
                    <th>Description</th>
                    <th class="text-center">Rate / Night</th>
                    <th class="text-center">Nights</th>
                    <th class="text-end">Amount (₹)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <strong>Room Accommodation Charges</strong>
                        <div class="text-muted small">Category: <%= booking.getRoomType() %> (Room #<%= booking.getRoomNumber() %>)</div>
                    </td>
                    <td class="text-center">₹<%= String.format("%,.2f", booking.getPricePerNight()) %></td>
                    <td class="text-center"><%= booking.getTotalDays() %></td>
                    <td class="text-end fw-semibold">₹<%= String.format("%,.2f", baseTotal) %></td>
                </tr>
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="3" class="text-end">Total Bill Amount:</th>
                    <th class="text-end fs-5 text-primary">₹<%= String.format("%,.2f", baseTotal) %></th>
                </tr>
                <tr>
                    <th colspan="3" class="text-end text-success">Total Amount Paid:</th>
                    <th class="text-end text-success">₹<%= String.format("%,.2f", paidTotal) %></th>
                </tr>
                <tr class="<%= balanceDue > 0 ? "table-danger" : "table-success" %>">
                    <th colspan="3" class="text-end">Remaining Balance Due:</th>
                    <th class="text-end fs-5">₹<%= String.format("%,.2f", balanceDue) %></th>
                </tr>
            </tfoot>
        </table>
    </div>

    <!-- PAYMENT HISTORY BREAKDOWN -->
    <div class="mb-4">
        <h6 class="text-uppercase text-muted fw-bold mb-2" style="font-size: 0.78rem;">TRANSACTION RECEIPTS</h6>
        <% if (payments != null && !payments.isEmpty()) { %>
            <div class="table-responsive">
                <table class="table table-sm table-striped" style="font-size: 0.88rem;">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Method</th>
                            <th>Transaction Ref</th>
                            <th>Status</th>
                            <th class="text-end">Amount Paid</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Payment p : payments) { %>
                        <tr>
                            <td><%= p.getPaymentDate() %></td>
                            <td><%= p.getPaymentMethod() %></td>
                            <td><%= p.getTransactionId() != null ? p.getTransactionId() : "---" %></td>
                            <td><span class="badge bg-success-subtle text-success"><%= p.getPaymentStatus() %></span></td>
                            <td class="text-end fw-bold">₹<%= String.format("%,.2f", p.getAmount()) %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <p class="text-muted small">No payment transactions recorded yet for this reservation.</p>
        <% } %>
    </div>

    <!-- TERMS & SIGNATURE -->
    <div class="row pt-4 border-top mt-5 align-items-end">
        <div class="col-8">
            <h6 class="fw-bold mb-1" style="font-size: 0.82rem;">Terms & Conditions:</h6>
            <p class="text-muted mb-0" style="font-size: 0.75rem;">
                Standard check-out time is 11:00 AM. Keycards must be returned upon departure.<br>
                Thank you for choosing Grand Azure Luxury Hotel. We look forward to welcoming you again!
            </p>
        </div>
        <div class="col-4 text-end">
            <div style="height: 50px;"></div>
            <div class="border-top pt-1 text-center" style="font-size: 0.82rem;">
                <strong>Authorized Signatory</strong><br>
                <small class="text-muted">Grand Azure Accounts</small>
            </div>
        </div>
    </div>
</div>

<!-- SETTLE BALANCE MODAL -->
<div class="modal fade" id="payBalanceModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/payments" method="POST">
                <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                <input type="hidden" name="redirectTarget" value="invoice">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-credit-card text-primary me-2"></i>Settle Outstanding Dues</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Payment Amount (₹) *</label>
                        <input type="number" step="0.01" name="amount" class="form-control" value="<%= String.format("%.2f", balanceDue) %>" required>
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
                        <input type="text" name="transactionId" class="form-control" placeholder="e.g. UPI-REF-992381">
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Remarks</label>
                        <input type="text" name="remarks" class="form-control" value="Final invoice settlement">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check me-1"></i>Confirm Settlement</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
