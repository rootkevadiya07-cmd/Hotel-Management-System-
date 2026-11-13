package controller;

import dao.CustomerDAO;
import model.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Controller managing customer guest profiles, ID proof verification records, and directory searches.
 */
@WebServlet(name = "CustomerServlet", urlPatterns = {"/admin/customers"})
public class CustomerServlet extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "delete":
                    handleDeleteCustomer(request, response);
                    break;
                case "list":
                default:
                    handleListCustomers(request, response);
                    break;
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            handleListCustomers(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "add";

        try {
            if ("add".equalsIgnoreCase(action)) {
                handleAddCustomer(request, response);
            } else if ("update".equalsIgnoreCase(action)) {
                handleUpdateCustomer(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/customers");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Customer operation failed: " + e.getMessage());
            handleListCustomers(request, response);
        }
    }

    private void handleListCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchKeyword = request.getParameter("searchKeyword");
        List<Customer> customers;
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            customers = customerDAO.searchCustomers(searchKeyword);
        } else {
            customers = customerDAO.getAllCustomers();
        }

        request.setAttribute("customers", customers);
        request.setAttribute("searchKeyword", searchKeyword);
        request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
    }

    private void handleAddCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String idProofType = request.getParameter("idProofType");
        String idProofNumber = request.getParameter("idProofNumber");

        Customer customer = new Customer(fullName, email, phone, address, idProofType, idProofNumber);
        int generatedId = customerDAO.addCustomer(customer);

        if (generatedId > 0) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?msg=Customer%20registered%20successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=Failed%20to%20register%20customer");
        }
    }

    private void handleUpdateCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int customerId = Integer.parseInt(request.getParameter("customerId"));
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String idProofType = request.getParameter("idProofType");
        String idProofNumber = request.getParameter("idProofNumber");

        Customer customer = new Customer(fullName, email, phone, address, idProofType, idProofNumber);
        customer.setCustomerId(customerId);

        boolean updated = customerDAO.updateCustomer(customer);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?msg=Customer%20updated%20successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=Failed%20to%20update%20customer");
        }
    }

    private void handleDeleteCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int customerId = Integer.parseInt(request.getParameter("id"));
        boolean deleted = customerDAO.deleteCustomer(customerId);
        if (deleted) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?msg=Customer%20deleted%20successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=Cannot%20delete%20customer%20with%20existing%20bookings");
        }
    }
}
