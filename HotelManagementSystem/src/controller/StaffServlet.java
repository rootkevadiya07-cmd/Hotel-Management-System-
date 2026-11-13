package controller;

import dao.StaffDAO;
import model.Staff;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * Controller managing hotel staff members, roles, shift rotations, and payroll info.
 */
@WebServlet(name = "StaffServlet", urlPatterns = {"/admin/staff"})
public class StaffServlet extends HttpServlet {

    private final StaffDAO staffDAO = new StaffDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "delete":
                    handleDeleteStaff(request, response);
                    break;
                case "list":
                default:
                    handleListStaff(request, response);
                    break;
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            handleListStaff(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "add";

        try {
            if ("add".equalsIgnoreCase(action)) {
                handleAddStaff(request, response);
            } else if ("update".equalsIgnoreCase(action)) {
                handleUpdateStaff(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/staff");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Staff operation failed: " + e.getMessage());
            handleListStaff(request, response);
        }
    }

    private void handleListStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String roleFilter = request.getParameter("roleFilter");
        String shiftFilter = request.getParameter("shiftFilter");
        String statusFilter = request.getParameter("statusFilter");
        String searchKeyword = request.getParameter("searchKeyword");

        List<Staff> staffList = staffDAO.getStaffFiltered(roleFilter, shiftFilter, statusFilter, searchKeyword);
        int activeCount = staffDAO.getTotalStaffCount();

        request.setAttribute("staffList", staffList);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("roleFilter", roleFilter);
        request.setAttribute("shiftFilter", shiftFilter);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("searchKeyword", searchKeyword);

        request.getRequestDispatcher("/admin/staff.jsp").forward(request, response);
    }

    private void handleAddStaff(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String fullName = request.getParameter("fullName");
        String role = request.getParameter("role");
        String shift = request.getParameter("shift");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        double salary = Double.parseDouble(request.getParameter("salary"));
        String status = request.getParameter("status");
        String hireDateStr = request.getParameter("hireDate");
        Date hireDate = (hireDateStr != null && !hireDateStr.trim().isEmpty())
                ? Date.valueOf(hireDateStr)
                : new Date(System.currentTimeMillis());

        Staff staff = new Staff(fullName, role, shift, phone, email, salary, status, hireDate);
        boolean added = staffDAO.addStaff(staff);

        if (added) {
            response.sendRedirect(request.getContextPath() + "/admin/staff?msg=Staff%20member%20added%20successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/staff?error=Failed%20to%20add%20staff%20member");
        }
    }

    private void handleUpdateStaff(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int staffId = Integer.parseInt(request.getParameter("staffId"));
        String fullName = request.getParameter("fullName");
        String role = request.getParameter("role");
        String shift = request.getParameter("shift");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        double salary = Double.parseDouble(request.getParameter("salary"));
        String status = request.getParameter("status");
        Date hireDate = Date.valueOf(request.getParameter("hireDate"));

        Staff staff = new Staff(staffId, fullName, role, shift, phone, email, salary, status, hireDate, null);
        boolean updated = staffDAO.updateStaff(staff);

        if (updated) {
            response.sendRedirect(request.getContextPath() + "/admin/staff?msg=Staff%20details%20updated%20successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/staff?error=Failed%20to%20update%20staff");
        }
    }

    private void handleDeleteStaff(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int staffId = Integer.parseInt(request.getParameter("id"));
        boolean deleted = staffDAO.deleteStaff(staffId);
        if (deleted) {
            response.sendRedirect(request.getContextPath() + "/admin/staff?msg=Staff%20record%20deleted%20successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/staff?error=Failed%20to%20delete%20staff%20record");
        }
    }
}
