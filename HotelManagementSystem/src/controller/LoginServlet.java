package controller;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller handling user authentication (Login).
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If already logged in, redirect directly to dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please provide both username and password.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.authenticate(username.trim(), password.trim());

        if (user != null) {
            // Authentication successful: create session
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("userName", user.getFullName());

            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else {
            // Invalid credentials
            request.setAttribute("errorMessage", "Invalid username or password. Please try again.");
            request.setAttribute("enteredUsername", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
