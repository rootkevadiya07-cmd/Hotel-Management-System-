<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Staff, java.util.List" %>
<%
    request.setAttribute("pageTitle", "Hotel Staff & Roster Management");
    List<Staff> staffList = (List<Staff>) request.getAttribute("staffList");
    Integer activeCount = (Integer) request.getAttribute("activeCount");
    if (activeCount == null) activeCount = 0;

    String roleFilter = (String) request.getAttribute("roleFilter");
    String shiftFilter = (String) request.getAttribute("shiftFilter");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
%>
<jsp:include page="header.jsp" />

<!-- SUMMARY & FILTER BAR -->
<div class="row g-4 mb-4">
    <div class="col-md-4">
        <div class="custom-card p-3 mb-0 d-flex align-items-center justify-content-between">
            <div>
                <div class="text-muted text-uppercase fw-bold" style="font-size: 0.72rem;">Active On-Duty Personnel</div>
                <h3 class="fw-bold my-1 text-primary"><%= activeCount %></h3>
                <small class="text-success"><i class="fa-solid fa-circle-check me-1"></i>Shift Ready</small>
            </div>
            <div class="icon-bubble bg-primary-subtle text-primary">
                <i class="fa-solid fa-users-gear"></i>
            </div>
        </div>
    </div>
    <div class="col-md-8 d-flex align-items-center justify-content-md-end">
        <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addStaffModal">
            <i class="fa-solid fa-user-plus me-1"></i> Add New Staff Member
        </button>
    </div>
</div>

<div class="custom-card p-3 mb-4">
    <form action="<%= request.getContextPath() %>/admin/staff" method="GET" class="row g-2 align-items-center">
        <div class="col-md-3">
            <input type="text" name="searchKeyword" class="form-control" placeholder="Search staff name, email, phone..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
        </div>
        <div class="col-md-3">
            <select name="roleFilter" class="form-select">
                <option value="ALL">All Roles</option>
                <option value="General Manager" <%= "General Manager".equals(roleFilter) ? "selected" : "" %>>General Manager</option>
                <option value="Front Desk Receptionist" <%= "Front Desk Receptionist".equals(roleFilter) ? "selected" : "" %>>Front Desk Receptionist</option>
                <option value="Front Desk Supervisor" <%= "Front Desk Supervisor".equals(roleFilter) ? "selected" : "" %>>Front Desk Supervisor</option>
                <option value="Housekeeping Lead" <%= "Housekeeping Lead".equals(roleFilter) ? "selected" : "" %>>Housekeeping Lead</option>
                <option value="Executive Chef" <%= "Executive Chef".equals(roleFilter) ? "selected" : "" %>>Executive Chef</option>
                <option value="Security Officer" <%= "Security Officer".equals(roleFilter) ? "selected" : "" %>>Security Officer</option>
            </select>
        </div>
        <div class="col-md-2">
            <select name="shiftFilter" class="form-select">
                <option value="ALL">All Shifts</option>
                <option value="Morning" <%= "Morning".equals(shiftFilter) ? "selected" : "" %>>Morning</option>
                <option value="Evening" <%= "Evening".equals(shiftFilter) ? "selected" : "" %>>Evening</option>
                <option value="Night" <%= "Night".equals(shiftFilter) ? "selected" : "" %>>Night</option>
            </select>
        </div>
        <div class="col-md-2">
            <select name="statusFilter" class="form-select">
                <option value="ALL">All Statuses</option>
                <option value="Active" <%= "Active".equals(statusFilter) ? "selected" : "" %>>Active</option>
                <option value="On Leave" <%= "On Leave".equals(statusFilter) ? "selected" : "" %>>On Leave</option>
                <option value="Terminated" <%= "Terminated".equals(statusFilter) ? "selected" : "" %>>Terminated</option>
            </select>
        </div>
        <div class="col-md-2 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100"><i class="fa-solid fa-filter me-1"></i>Filter</button>
            <a href="<%= request.getContextPath() %>/admin/staff" class="btn btn-outline-secondary"><i class="fa-solid fa-rotate-right"></i></a>
        </div>
    </form>
</div>

<!-- STAFF TABLE -->
<div class="custom-card">
    <div class="custom-card-header">
        <h5><i class="fa-solid fa-user-group text-primary me-2"></i>Staff Directory (<%= staffList != null ? staffList.size() : 0 %>)</h5>
    </div>
    <div class="table-responsive">
        <table class="table custom-table table-hover">
            <thead>
                <tr>
                    <th>Staff ID</th>
                    <th>Full Name</th>
                    <th>Role & Department</th>
                    <th>Shift</th>
                    <th>Phone & Email</th>
                    <th>Salary (Monthly)</th>
                    <th>Status</th>
                    <th class="text-end">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (staffList != null && !staffList.isEmpty()) {
                    for (Staff s : staffList) {
                        String shiftBadge = "bg-primary-subtle text-primary";
                        if ("Evening".equalsIgnoreCase(s.getShift())) shiftBadge = "bg-warning-subtle text-warning";
                        else if ("Night".equalsIgnoreCase(s.getShift())) shiftBadge = "bg-dark-subtle text-dark";

                        String statusBadge = "bg-success-subtle text-success";
                        if ("On Leave".equalsIgnoreCase(s.getStatus())) statusBadge = "bg-warning-subtle text-warning";
                        else if ("Terminated".equalsIgnoreCase(s.getStatus())) statusBadge = "bg-danger-subtle text-danger";
                %>
                <tr>
                    <td>
                        <span class="text-muted fw-bold">#STF-<%= s.getStaffId() %></span>
                    </td>
                    <td>
                        <div class="fw-bold text-dark"><%= s.getFullName() %></div>
                        <small class="text-muted">Hired: <%= s.getHireDate() %></small>
                    </td>
                    <td>
                        <div class="fw-semibold"><%= s.getRole() %></div>
                    </td>
                    <td>
                        <span class="badge <%= shiftBadge %>"><i class="fa-regular fa-clock me-1"></i><%= s.getShift() %></span>
                    </td>
                    <td>
                        <div><i class="fa-solid fa-phone me-1 text-muted"></i><%= s.getPhone() %></div>
                        <small class="text-muted"><i class="fa-regular fa-envelope me-1"></i><%= s.getEmail() %></small>
                    </td>
                    <td>
                        <strong class="text-dark">₹<%= String.format("%,.2f", s.getSalary()) %></strong>
                    </td>
                    <td>
                        <span class="badge <%= statusBadge %>"><%= s.getStatus() %></span>
                    </td>
                    <td class="text-end">
                        <div class="btn-group btn-group-sm">
                            <button type="button" class="btn btn-outline-primary btn-edit-staff" title="Edit Staff"
                                data-id="<%= s.getStaffId() %>"
                                data-name="<%= s.getFullName().replace("\"", "&quot;") %>"
                                data-role="<%= s.getRole() %>"
                                data-shift="<%= s.getShift() %>"
                                data-phone="<%= s.getPhone() %>"
                                data-email="<%= s.getEmail() %>"
                                data-salary="<%= s.getSalary() %>"
                                data-status="<%= s.getStatus() %>"
                                data-hiredate="<%= s.getHireDate() %>"
                                data-bs-toggle="modal" data-bs-target="#editStaffModal">
                                <i class="fa-solid fa-pen-to-square"></i>
                            </button>
                            <a href="<%= request.getContextPath() %>/admin/staff?action=delete&id=<%= s.getStaffId() %>" 
                               class="btn btn-outline-danger" title="Delete Staff Record" 
                               onclick="return confirm('Remove staff member?');">
                                <i class="fa-solid fa-trash-can"></i>
                            </a>
                        </div>
                    </td>
                </tr>
                <%  }
                } else { %>
                <tr>
                    <td colspan="8" class="text-center py-4 text-muted">No staff members found matching criteria.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- ADD STAFF MODAL -->
<div class="modal fade" id="addStaffModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/staff" method="POST">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-user-plus text-primary me-2"></i>Add Staff Member</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Full Name *</label>
                        <input type="text" name="fullName" class="form-control" placeholder="e.g. Liam Walker" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Assigned Role *</label>
                        <select name="role" class="form-select" required>
                            <option value="Front Desk Receptionist">Front Desk Receptionist</option>
                            <option value="Front Desk Supervisor">Front Desk Supervisor</option>
                            <option value="General Manager">General Manager</option>
                            <option value="Housekeeping Lead">Housekeeping Lead</option>
                            <option value="Executive Chef">Executive Chef</option>
                            <option value="Security Officer">Security Officer</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Shift *</label>
                        <select name="shift" class="form-select" required>
                            <option value="Morning">Morning</option>
                            <option value="Evening">Evening</option>
                            <option value="Night">Night</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Phone Number *</label>
                        <input type="tel" name="phone" class="form-control" placeholder="+91-98765-11223" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Email Address *</label>
                        <input type="email" name="email" class="form-control" placeholder="staff@grandazure.com" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Monthly Salary (₹) *</label>
                        <input type="number" step="0.01" name="salary" class="form-control" placeholder="35000.00" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Employment Status *</label>
                        <select name="status" class="form-select" required>
                            <option value="Active">Active</option>
                            <option value="On Leave">On Leave</option>
                            <option value="Terminated">Terminated</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Hire Date</label>
                        <input type="date" name="hireDate" class="form-control">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check me-1"></i>Save Staff</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- EDIT STAFF MODAL -->
<div class="modal fade" id="editStaffModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/staff" method="POST">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="staffId" id="editStaffId">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-pen-to-square text-primary me-2"></i>Edit Staff Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Full Name *</label>
                        <input type="text" name="fullName" id="editStaffFullName" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Assigned Role *</label>
                        <select name="role" id="editStaffRole" class="form-select" required>
                            <option value="Front Desk Receptionist">Front Desk Receptionist</option>
                            <option value="Front Desk Supervisor">Front Desk Supervisor</option>
                            <option value="General Manager">General Manager</option>
                            <option value="Housekeeping Lead">Housekeeping Lead</option>
                            <option value="Executive Chef">Executive Chef</option>
                            <option value="Security Officer">Security Officer</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Shift *</label>
                        <select name="shift" id="editStaffShift" class="form-select" required>
                            <option value="Morning">Morning</option>
                            <option value="Evening">Evening</option>
                            <option value="Night">Night</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Phone Number *</label>
                        <input type="tel" name="phone" id="editStaffPhone" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Email Address *</label>
                        <input type="email" name="email" id="editStaffEmail" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Monthly Salary (₹) *</label>
                        <input type="number" step="0.01" name="salary" id="editStaffSalary" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Employment Status *</label>
                        <select name="status" id="editStaffStatus" class="form-select" required>
                            <option value="Active">Active</option>
                            <option value="On Leave">On Leave</option>
                            <option value="Terminated">Terminated</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Hire Date *</label>
                        <input type="date" name="hireDate" id="editStaffHireDate" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-save me-1"></i>Update Staff</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
