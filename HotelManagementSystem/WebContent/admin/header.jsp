<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String currentUri = request.getRequestURI();
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) pageTitle = "Dashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - Grand Azure Luxury Hotel</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome 6 Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="<%= request.getContextPath() %>/css/style.css" rel="stylesheet">
</head>
<body>

<div class="app-wrapper">
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <a href="<%= request.getContextPath() %>/admin/dashboard" class="sidebar-brand">
            <i class="fa-solid fa-hotel"></i>
            <div>
                <div style="font-size: 1.05rem; font-weight: 700;">Grand Azure</div>
                <div style="font-size: 0.72rem; color: #94a3b8; font-weight: 500;">Hotel Management</div>
            </div>
        </a>

        <div class="sidebar-menu">
            <div class="nav-heading">Main Operations</div>
            <a href="<%= request.getContextPath() %>/admin/dashboard" class="sidebar-link <%= currentUri.contains("dashboard") ? "active" : "" %>">
                <i class="fa-solid fa-chart-pie"></i>
                <span>Dashboard</span>
            </a>
            <a href="<%= request.getContextPath() %>/admin/rooms" class="sidebar-link <%= currentUri.contains("rooms") ? "active" : "" %>">
                <i class="fa-solid fa-door-open"></i>
                <span>Room Management</span>
            </a>
            <a href="<%= request.getContextPath() %>/admin/customers" class="sidebar-link <%= currentUri.contains("customers") ? "active" : "" %>">
                <i class="fa-solid fa-users"></i>
                <span>Customers</span>
            </a>
            <a href="<%= request.getContextPath() %>/admin/bookings" class="sidebar-link <%= currentUri.contains("bookings") ? "active" : "" %>">
                <i class="fa-solid fa-calendar-check"></i>
                <span>Bookings</span>
            </a>

            <div class="nav-heading">Finance & Administration</div>
            <a href="<%= request.getContextPath() %>/admin/payments" class="sidebar-link <%= currentUri.contains("payments") || currentUri.contains("invoice") ? "active" : "" %>">
                <i class="fa-solid fa-file-invoice-dollar"></i>
                <span>Payments & Invoices</span>
            </a>
            <a href="<%= request.getContextPath() %>/admin/staff" class="sidebar-link <%= currentUri.contains("staff") ? "active" : "" %>">
                <i class="fa-solid fa-user-tie"></i>
                <span>Staff Management</span>
            </a>
            <a href="<%= request.getContextPath() %>/admin/reports" class="sidebar-link <%= currentUri.contains("reports") ? "active" : "" %>">
                <i class="fa-solid fa-chart-line"></i>
                <span>Analytics & Reports</span>
            </a>

            <div class="nav-heading">Quick Shortcuts</div>
            <a href="<%= request.getContextPath() %>/index.jsp" target="_blank" class="sidebar-link">
                <i class="fa-solid fa-globe"></i>
                <span>View Public Portal</span>
            </a>
        </div>

        <div class="sidebar-user">
            <div class="d-flex align-items-center gap-2">
                <div class="user-avatar">
                    <%= currentUser != null && currentUser.getFullName() != null ? currentUser.getFullName().substring(0, 1).toUpperCase() : "A" %>
                </div>
                <div>
                    <div style="font-size: 0.88rem; font-weight: 600; color: #ffffff;"><%= currentUser != null ? currentUser.getFullName() : "Admin" %></div>
                    <div style="font-size: 0.72rem; color: #94a3b8;"><%= currentUser != null ? currentUser.getRole() : "STAFF" %></div>
                </div>
            </div>
            <a href="<%= request.getContextPath() %>/logout" class="text-secondary hover-white" title="Logout">
                <i class="fa-solid fa-arrow-right-from-bracket text-light"></i>
            </a>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <!-- TOP NAVBAR -->
        <header class="top-navbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-sm btn-outline-secondary d-lg-none" type="button" onclick="document.querySelector('.sidebar').classList.toggle('show')">
                    <i class="fa-solid fa-bars"></i>
                </button>
                <h4 class="page-title"><%= pageTitle %></h4>
            </div>

            <div class="d-flex align-items-center gap-4">
                <div class="d-none d-md-flex align-items-center gap-2 text-muted" style="font-size: 0.88rem;">
                    <i class="fa-regular fa-clock text-primary"></i>
                    <span id="liveClock">Loading time...</span>
                </div>

                <div class="dropdown">
                    <button class="btn btn-light border dropdown-toggle d-flex align-items-center gap-2" type="button" data-bs-toggle="dropdown">
                        <i class="fa-regular fa-circle-user text-primary"></i>
                        <span><%= currentUser != null ? currentUser.getUsername() : "User" %></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                        <li><h6 class="dropdown-header">Logged in as <%= currentUser != null ? currentUser.getRole() : "User" %></h6></li>
                        <li><a class="dropdown-item" href="<%= request.getContextPath() %>/admin/reports"><i class="fa-solid fa-chart-pie me-2"></i>Reports</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="<%= request.getContextPath() %>/logout"><i class="fa-solid fa-power-off me-2"></i>Sign Out</a></li>
                    </ul>
                </div>
            </div>
        </header>

        <!-- CONTENT BODY -->
        <main class="content-body">
            <!-- Global Flash Messages -->
            <%
                String successMsg = request.getParameter("msg");
                String errorMsg = (String) request.getAttribute("errorMessage");
                if (errorMsg == null) errorMsg = request.getParameter("error");
            %>
            <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
                <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
                    <i class="fa-solid fa-circle-check fs-5"></i>
                    <div><%= successMsg %></div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
                    <i class="fa-solid fa-circle-exclamation fs-5"></i>
                    <div><%= errorMsg %></div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
