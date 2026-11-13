<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Customer, java.util.List" %>
<%
    request.setAttribute("pageTitle", "Customer Management");
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
%>
<jsp:include page="header.jsp" />

<!-- SEARCH & REGISTER ACTIONS -->
<div class="custom-card p-3 mb-4">
    <form action="<%= request.getContextPath() %>/admin/customers" method="GET" class="row g-2 align-items-center">
        <div class="col-md-8">
            <div class="input-group">
                <span class="input-group-text bg-white"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                <input type="text" name="searchKeyword" class="form-control" placeholder="Search by name, phone, email, or ID proof number..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
                <button type="submit" class="btn btn-primary">Search</button>
                <% if (searchKeyword != null && !searchKeyword.trim().isEmpty()) { %>
                    <a href="<%= request.getContextPath() %>/admin/customers" class="btn btn-outline-secondary">Clear</a>
                <% } %>
            </div>
        </div>
        <div class="col-md-4 text-md-end">
            <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addCustomerModal">
                <i class="fa-solid fa-user-plus me-1"></i> Register New Customer
            </button>
        </div>
    </form>
</div>

<!-- CUSTOMERS DIRECTORY TABLE -->
<div class="custom-card">
    <div class="custom-card-header">
        <h5><i class="fa-solid fa-address-book text-primary me-2"></i>Guest Directory (<%= customers != null ? customers.size() : 0 %>)</h5>
    </div>
    <div class="table-responsive">
        <table class="table custom-table table-hover">
            <thead>
                <tr>
                    <th>Customer ID</th>
                    <th>Full Name</th>
                    <th>Contact Info</th>
                    <th>ID Verification</th>
                    <th>Address</th>
                    <th class="text-end">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (customers != null && !customers.isEmpty()) {
                    for (Customer c : customers) {
                %>
                <tr>
                    <td>
                        <span class="text-muted fw-bold">#CST-<%= c.getCustomerId() %></span>
                    </td>
                    <td>
                        <div class="fw-bold text-dark"><%= c.getFullName() %></div>
                        <small class="text-muted"><i class="fa-regular fa-envelope me-1"></i><%= c.getEmail() %></small>
                    </td>
                    <td>
                        <div><i class="fa-solid fa-phone text-muted me-1"></i><%= c.getPhone() %></div>
                    </td>
                    <td>
                        <span class="badge bg-light text-dark border">
                            <i class="fa-solid fa-id-card text-primary me-1"></i><%= c.getIdProofType() %>: <%= c.getIdProofNumber() %>
                        </span>
                    </td>
                    <td style="max-width: 250px;">
                        <small class="text-muted d-block text-truncate" title="<%= c.getAddress() %>">
                            <%= c.getAddress() != null ? c.getAddress() : "N/A" %>
                        </small>
                    </td>
                    <td class="text-end">
                        <div class="btn-group btn-group-sm">
                            <button type="button" class="btn btn-outline-primary btn-edit-customer" title="Edit Customer"
                                data-id="<%= c.getCustomerId() %>"
                                data-name="<%= c.getFullName().replace("\"", "&quot;") %>"
                                data-email="<%= c.getEmail().replace("\"", "&quot;") %>"
                                data-phone="<%= c.getPhone().replace("\"", "&quot;") %>"
                                data-address="<%= c.getAddress() != null ? c.getAddress().replace("\"", "&quot;") : "" %>"
                                data-idtype="<%= c.getIdProofType() %>"
                                data-idnumber="<%= c.getIdProofNumber() %>"
                                data-bs-toggle="modal" data-bs-target="#editCustomerModal">
                                <i class="fa-solid fa-pen-to-square"></i>
                            </button>
                            <a href="<%= request.getContextPath() %>/admin/customers?action=delete&id=<%= c.getCustomerId() %>" 
                               class="btn btn-outline-danger" title="Delete Customer" 
                               onclick="return confirm('Delete customer? Note: Customers with existing bookings cannot be deleted.');">
                                <i class="fa-solid fa-trash-can"></i>
                            </a>
                        </div>
                    </td>
                </tr>
                <%  }
                } else { %>
                <tr>
                    <td colspan="6" class="text-center py-4 text-muted">No customers found.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- REGISTER CUSTOMER MODAL -->
<div class="modal fade" id="addCustomerModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/customers" method="POST">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-user-plus text-primary me-2"></i>Register Customer Profile</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Full Name *</label>
                        <input type="text" name="fullName" class="form-control" placeholder="e.g. Robert Johnson" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Email Address *</label>
                        <input type="email" name="email" class="form-control" placeholder="robert@example.com" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Phone Number *</label>
                        <input type="tel" name="phone" class="form-control" placeholder="+91-98765-43210" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">ID Proof Type *</label>
                        <select name="idProofType" class="form-select" required>
                            <option value="Passport">Passport</option>
                            <option value="Aadhaar">Aadhaar</option>
                            <option value="Driving License">Driving License</option>
                            <option value="National ID">National ID</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">ID Proof Number *</label>
                        <input type="text" name="idProofNumber" class="form-control" placeholder="ID document #" required>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Residential Address</label>
                        <textarea name="address" class="form-control" rows="2" placeholder="Street address, city, state, postal code..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check me-1"></i>Save Profile</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- EDIT CUSTOMER MODAL -->
<div class="modal fade" id="editCustomerModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/customers" method="POST">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="customerId" id="editCustomerId">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-pen-to-square text-primary me-2"></i>Edit Customer Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Full Name *</label>
                        <input type="text" name="fullName" id="editFullName" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Email Address *</label>
                        <input type="email" name="email" id="editEmail" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Phone Number *</label>
                        <input type="tel" name="phone" id="editPhone" class="form-control" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">ID Proof Type *</label>
                        <select name="idProofType" id="editIdProofType" class="form-select" required>
                            <option value="Passport">Passport</option>
                            <option value="Aadhaar">Aadhaar</option>
                            <option value="Driving License">Driving License</option>
                            <option value="National ID">National ID</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">ID Proof Number *</label>
                        <input type="text" name="idProofNumber" id="editIdProofNumber" class="form-control" required>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Residential Address</label>
                        <textarea name="address" id="editAddress" class="form-control" rows="2"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-save me-1"></i>Update Customer</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
