<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser != null) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        return;
    }
    String error = (String) request.getAttribute("errorMessage");
    String urlError = request.getParameter("error");
    if (error == null && "session_expired".equals(urlError)) {
        error = "Your session has expired. Please log in to continue.";
    }
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff & Admin Portal - Grand Azure Hotel</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome 6 Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', system-ui, sans-serif;
            padding: 1.5rem;
        }
        .login-card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3), 0 8px 10px -6px rgba(0, 0, 0, 0.3);
            width: 100%;
            max-width: 440px;
            padding: 2.5rem;
            position: relative;
            overflow: hidden;
        }
        .login-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: linear-gradient(90deg, #2563eb, #3b82f6, #f59e0b);
        }
        .brand-icon {
            width: 56px;
            height: 56px;
            background: #eff6ff;
            color: #2563eb;
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.75rem;
            margin-bottom: 1rem;
        }
        .form-control {
            border-radius: 10px;
            padding: 0.75rem 1rem;
        }
        .btn-primary {
            background-color: #2563eb;
            border-color: #2563eb;
            border-radius: 10px;
            padding: 0.75rem;
            font-weight: 600;
        }
        .btn-primary:hover {
            background-color: #1d4ed8;
            border-color: #1d4ed8;
        }
        .demo-box {
            background-color: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 10px;
            padding: 0.85rem;
            font-size: 0.82rem;
        }
        .demo-pill {
            cursor: pointer;
            background-color: #e2e8f0;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: 600;
        }
        .demo-pill:hover {
            background-color: #cbd5e1;
        }
    </style>
</head>
<body>

<div class="login-card">
    <div class="text-center mb-4">
        <div class="brand-icon">
            <i class="fa-solid fa-hotel"></i>
        </div>
        <h4 class="fw-bold text-dark mb-1">Grand Azure Portal</h4>
        <p class="text-muted small">Sign in to manage hotel operations and bookings</p>
    </div>

    <% if (error != null) { %>
        <div class="alert alert-danger py-2 small d-flex align-items-center gap-2 mb-3" role="alert">
            <i class="fa-solid fa-circle-exclamation"></i>
            <div><%= error %></div>
        </div>
    <% } %>

    <% if ("logged_out".equals(msg)) { %>
        <div class="alert alert-success py-2 small d-flex align-items-center gap-2 mb-3" role="alert">
            <i class="fa-solid fa-circle-check"></i>
            <div>You have signed out successfully.</div>
        </div>
    <% } %>

    <form action="<%= request.getContextPath() %>/login" method="POST">
        <div class="mb-3">
            <label class="form-label fw-semibold text-secondary small">Username</label>
            <div class="input-group">
                <span class="input-group-text bg-light text-muted border-end-0"><i class="fa-solid fa-user"></i></span>
                <input type="text" name="username" id="loginUsername" class="form-control border-start-0" placeholder="Enter username" required value="<%= request.getAttribute("enteredUsername") != null ? request.getAttribute("enteredUsername") : "" %>">
            </div>
        </div>

        <div class="mb-4">
            <label class="form-label fw-semibold text-secondary small">Password</label>
            <div class="input-group">
                <span class="input-group-text bg-light text-muted border-end-0"><i class="fa-solid fa-lock"></i></span>
                <input type="password" name="password" id="loginPassword" class="form-control border-start-0" placeholder="Enter password" required>
            </div>
        </div>

        <button type="submit" class="btn btn-primary w-100 mb-3">
            <i class="fa-solid fa-right-to-bracket me-2"></i>Sign In to Dashboard
        </button>
    </form>

    <!-- DEMO CREDENTIALS HELPER -->
    <div class="demo-box mb-3 text-muted">
        <div class="fw-bold text-dark mb-1"><i class="fa-solid fa-key text-warning me-1"></i>Sample Credentials:</div>
        <div class="d-flex justify-content-between align-items-center mb-1">
            <span>Admin:</span>
            <span><span class="demo-pill" onclick="fillCreds('admin', 'admin123')">admin / admin123</span></span>
        </div>
        <div class="d-flex justify-content-between align-items-center">
            <span>Staff / Front Desk:</span>
            <span><span class="demo-pill" onclick="fillCreds('reception', 'staff123')">reception / staff123</span></span>
        </div>
    </div>

    <div class="text-center">
        <a href="<%= request.getContextPath() %>/index.jsp" class="text-muted text-decoration-none small">
            <i class="fa-solid fa-arrow-left me-1"></i>Back to Public Website
        </a>
    </div>
</div>

<script>
function fillCreds(u, p) {
    document.getElementById('loginUsername').value = u;
    document.getElementById('loginPassword').value = p;
}
</script>

</body>
</html>
