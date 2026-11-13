<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.RoomDAO, model.Room, java.util.List" %>
<%
    RoomDAO roomDAO = new RoomDAO();
    List<Room> allRooms = roomDAO.getAllRooms();
    String bookedRef = request.getParameter("ref");
    String bookedSuccess = request.getParameter("booked");
    String bookingError = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Grand Azure Hotel & Luxury Suites</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome 6 Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-navy: #0f172a;
            --accent-gold: #f59e0b;
            --brand-blue: #2563eb;
        }
        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            color: #1e293b;
            background-color: #f8fafc;
        }
        .hero-banner {
            background: linear-gradient(rgba(15, 23, 42, 0.82), rgba(15, 23, 42, 0.92)),
                        url('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1600&q=80') center/cover no-repeat;
            color: #ffffff;
            padding: 5rem 1rem 4rem;
            position: relative;
        }
        .luxury-badge {
            display: inline-block;
            background-color: rgba(245, 158, 11, 0.15);
            color: #f59e0b;
            border: 1px solid rgba(245, 158, 11, 0.3);
            border-radius: 50px;
            padding: 0.35rem 1rem;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 1rem;
        }
        .booking-card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
            margin-top: -3.5rem;
            padding: 2.5rem;
            border: 1px solid #e2e8f0;
            position: relative;
            z-index: 10;
        }
        .room-card {
            background: #ffffff;
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .room-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 20px -3px rgba(0, 0, 0, 0.1);
        }
        .room-badge {
            position: absolute;
            top: 1rem;
            right: 1rem;
            z-index: 2;
        }
        .feature-icon-box {
            width: 60px;
            height: 60px;
            border-radius: 14px;
            background: #eff6ff;
            color: #2563eb;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>

<!-- TOP NAVIGATION -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top py-3" style="background-color: var(--primary-navy) !important;">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold fs-4" href="index.jsp">
            <i class="fa-solid fa-hotel text-warning"></i>
            <span>Grand Azure</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navContent">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navContent">
            <ul class="navbar-nav ms-auto align-items-lg-center gap-2">
                <li class="nav-item"><a class="nav-link text-white fw-semibold" href="#rooms">Rooms & Suites</a></li>
                <li class="nav-item"><a class="nav-link text-white fw-semibold" href="#amenities">Hotel Amenities</a></li>
                <li class="nav-item"><a class="nav-link text-white fw-semibold" href="#book">Book Stay</a></li>
                <li class="nav-item ms-lg-3">
                    <a href="login.jsp" class="btn btn-outline-light btn-sm px-3">
                        <i class="fa-solid fa-user-shield me-1"></i> Staff Login
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- HERO BANNER -->
<section class="hero-banner text-center">
    <div class="container py-4">
        <span class="luxury-badge"><i class="fa-solid fa-star me-1"></i> Five-Star Luxury Hospitality</span>
        <h1 class="display-4 fw-bold mb-3">Experience Elegance, Comfort & Serenity</h1>
        <p class="lead text-light opacity-75 mx-auto mb-4" style="max-width: 700px;">
            Discover unmatched luxury at Grand Azure. World-class suites, personalized concierge, and tranquil coastal vistas tailored for your perfect escape.
        </p>
        <a href="#book" class="btn btn-warning btn-lg fw-bold px-4 py-2 text-dark shadow">
            <i class="fa-solid fa-calendar-check me-2"></i> Reserve Your Stay
        </a>
    </div>
</section>

<!-- MAIN RESERVATION BOOKING FORM -->
<div class="container" id="book">
    <div class="booking-card">
        <% if ("true".equals(bookedSuccess) && bookedRef != null) { %>
            <div class="alert alert-success alert-dismissible fade show p-4 mb-4" role="alert">
                <h4 class="alert-heading fw-bold"><i class="fa-solid fa-circle-check me-2"></i>Reservation Confirmed!</h4>
                <p class="mb-1">Thank you for choosing Grand Azure Hotel. Your booking reference number is:</p>
                <div class="fs-4 fw-bold text-success my-2"><%= bookedRef %></div>
                <small class="text-muted">A confirmation SMS and email have been dispatched. Present this reference code upon check-in at front desk.</small>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <% if (bookingError != null) { %>
            <div class="alert alert-danger alert-dismissible fade show p-3 mb-4" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i>
                <strong>Booking Notice:</strong> <%= bookingError %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="text-center mb-4">
            <h3 class="fw-bold text-dark">Book Your Luxury Stay</h3>
            <p class="text-muted small">Select your travel dates, room type, and enter guest details for instant booking</p>
        </div>

        <form action="<%= request.getContextPath() %>/book" method="POST" class="booking-calc-form">
            <input type="hidden" name="action" value="publicBook">

            <div class="row g-3">
                <!-- Room Selection -->
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Choose Room *</label>
                    <select name="roomId" id="publicRoomSelect" class="form-select" required>
                        <option value="">-- Select Room --</option>
                        <% if (allRooms != null) {
                            for (Room r : allRooms) { %>
                            <option value="<%= r.getRoomId() %>" data-price="<%= r.getPricePerNight() %>" <%= "Maintenance".equalsIgnoreCase(r.getStatus()) ? "disabled" : "" %>>
                                Room <%= r.getRoomNumber() %> - <%= r.getRoomType() %> (₹<%= String.format("%.2f", r.getPricePerNight()) %>/night)
                            </option>
                        <%  }
                        } %>
                    </select>
                </div>

                <!-- Check-in & Check-out Dates -->
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Check-In Date *</label>
                    <input type="date" name="checkInDate" class="form-control" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Check-Out Date *</label>
                    <input type="date" name="checkOutDate" class="form-control" required>
                </div>

                <!-- Dynamic Cost Calculation Banner -->
                <div class="col-12">
                    <div class="p-3 bg-light rounded border d-flex justify-content-between align-items-center">
                        <div>
                            <span class="text-muted small me-3">Duration: <strong class="calc-days-display text-dark">1 night</strong></span>
                            <span class="text-muted small">Price/Night: <strong class="calc-price-display text-dark">₹0.00</strong></span>
                        </div>
                        <div class="text-end">
                            <span class="text-muted small text-uppercase fw-semibold me-2">Estimated Total:</span>
                            <span class="fs-4 fw-bold text-primary calc-total-display">₹0.00</span>
                        </div>
                    </div>
                </div>

                <!-- Guest Info -->
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Full Name *</label>
                    <input type="text" name="fullName" class="form-control" placeholder="John Doe" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Phone Number *</label>
                    <input type="tel" name="phone" class="form-control" placeholder="+91 98765 43210" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Email Address *</label>
                    <input type="email" name="email" class="form-control" placeholder="john@example.com" required>
                </div>

                <div class="col-md-4">
                    <label class="form-label fw-semibold">ID Proof Type *</label>
                    <select name="idProofType" class="form-select" required>
                        <option value="Passport">Passport</option>
                        <option value="Aadhaar">Aadhaar</option>
                        <option value="Driving License">Driving License</option>
                        <option value="National ID">National ID</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">ID Proof Number *</label>
                    <input type="text" name="idProofNumber" class="form-control" placeholder="ID Number" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Residential Address</label>
                    <input type="text" name="address" class="form-control" placeholder="City, State, Country">
                </div>

                <div class="col-12">
                    <label class="form-label fw-semibold">Special Requests (Optional)</label>
                    <input type="text" name="notes" class="form-control" placeholder="e.g. Airport pickup, quiet corner room, extra pillows...">
                </div>

                <div class="col-12 text-center mt-4">
                    <button type="submit" class="btn btn-primary btn-lg px-5 fw-bold shadow-sm">
                        <i class="fa-solid fa-lock me-2"></i> Confirm Instant Reservation
                    </button>
                    <div class="text-muted small mt-2">
                        <i class="fa-solid fa-shield-halved text-success me-1"></i> Overlap-Free Booking Engine &bull; Pay at Hotel Check-In
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- ROOMS CATEGORIES SHOWCASE -->
<section class="container py-5 mt-5" id="rooms">
    <div class="text-center mb-5">
        <span class="text-primary text-uppercase fw-bold" style="font-size: 0.85rem; letter-spacing: 1px;">Accommodations</span>
        <h2 class="fw-bold mt-1">Our Handcrafted Rooms & Suites</h2>
        <p class="text-muted mx-auto" style="max-width: 650px;">
            Each room is thoughtfully designed to provide unparalleled relaxation with soundproof windows, luxury bedding, and smart in-room amenities.
        </p>
    </div>

    <div class="row g-4">
        <!-- Single Room -->
        <div class="col-lg-3 col-md-6">
            <div class="room-card position-relative">
                <div class="p-4 flex-grow-1">
                    <span class="badge bg-secondary mb-2">Solo & Business</span>
                    <h4 class="fw-bold">Single Room</h4>
                    <p class="text-muted small">Ideal for solo travelers seeking peaceful sanctuary and focused work desk spaces.</p>
                    <div class="d-flex align-items-baseline gap-1 my-3">
                        <span class="fs-4 fw-bold text-primary">₹1,200</span>
                        <span class="text-muted small">/ night</span>
                    </div>
                    <ul class="list-unstyled small text-muted mb-4">
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Single Bed with Plush Linen</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Free High-Speed Wi-Fi</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Air Conditioning & LED TV</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>En-suite Hot Rain Shower</li>
                    </ul>
                </div>
                <div class="p-4 pt-0">
                    <a href="#book" class="btn btn-outline-primary w-100 fw-semibold" onclick="selectRoomCategory('Single Room')">Select Room</a>
                </div>
            </div>
        </div>

        <!-- Double Room -->
        <div class="col-lg-3 col-md-6">
            <div class="room-card position-relative">
                <div class="p-4 flex-grow-1">
                    <span class="badge bg-info mb-2 text-dark">Couples & Duos</span>
                    <h4 class="fw-bold">Double Room</h4>
                    <p class="text-muted small">Expansive double room with queen-size bed or twin beds facing garden views.</p>
                    <div class="d-flex align-items-baseline gap-1 my-3">
                        <span class="fs-4 fw-bold text-primary">₹2,200</span>
                        <span class="text-muted small">/ night</span>
                    </div>
                    <ul class="list-unstyled small text-muted mb-4">
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Queen Bed or Twin Beds</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Mini Refrigerator & Coffee</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>43" Smart LED TV</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Private Garden View Balcony</li>
                    </ul>
                </div>
                <div class="p-4 pt-0">
                    <a href="#book" class="btn btn-outline-primary w-100 fw-semibold" onclick="selectRoomCategory('Double Room')">Select Room</a>
                </div>
            </div>
        </div>

        <!-- Deluxe Room -->
        <div class="col-lg-3 col-md-6">
            <div class="room-card position-relative border-primary">
                <div class="p-4 flex-grow-1">
                    <span class="badge bg-primary mb-2">Most Popular</span>
                    <h4 class="fw-bold">Deluxe Room</h4>
                    <p class="text-muted small">Lavish retreat featuring marble bathroom, bathtub, and breathtaking skyline views.</p>
                    <div class="d-flex align-items-baseline gap-1 my-3">
                        <span class="fs-4 fw-bold text-primary">₹3,800</span>
                        <span class="text-muted small">/ night</span>
                    </div>
                    <ul class="list-unstyled small text-muted mb-4">
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>King Bed & Lounger Sofa</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Deep Soaking Bathtub</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>55" OLED Smart TV & Mini Bar</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Luxury Toiletries & Bathrobes</li>
                    </ul>
                </div>
                <div class="p-4 pt-0">
                    <a href="#book" class="btn btn-primary w-100 fw-semibold" onclick="selectRoomCategory('Deluxe Room')">Select Room</a>
                </div>
            </div>
        </div>

        <!-- Suite Room -->
        <div class="col-lg-3 col-md-6">
            <div class="room-card position-relative">
                <div class="p-4 flex-grow-1">
                    <span class="badge bg-warning mb-2 text-dark"><i class="fa-solid fa-crown me-1"></i>Presidential</span>
                    <h4 class="fw-bold">Suite Room</h4>
                    <p class="text-muted small">Five-star luxury suite with master bedroom, private jacuzzi, and separate dining salon.</p>
                    <div class="d-flex align-items-baseline gap-1 my-3">
                        <span class="fs-4 fw-bold text-primary">₹6,500</span>
                        <span class="text-muted small">/ night</span>
                    </div>
                    <ul class="list-unstyled small text-muted mb-4">
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Master King Bed & Living Room</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Private Jacuzzi Spa</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>Espresso Bar & Dining Table</li>
                        <li class="mb-2"><i class="fa-solid fa-check text-success me-2"></i>24/7 Dedicated Butler Service</li>
                    </ul>
                </div>
                <div class="p-4 pt-0">
                    <a href="#book" class="btn btn-outline-primary w-100 fw-semibold" onclick="selectRoomCategory('Suite Room')">Select Room</a>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- HOTEL AMENITIES -->
<section class="bg-white py-5 border-top border-bottom" id="amenities">
    <div class="container py-4">
        <div class="text-center mb-5">
            <span class="text-primary text-uppercase fw-bold" style="font-size: 0.85rem; letter-spacing: 1px;">World-Class Amenities</span>
            <h2 class="fw-bold mt-1">Designed for Your Total Comfort</h2>
        </div>

        <div class="row g-4 text-center">
            <div class="col-md-4">
                <div class="p-3">
                    <div class="feature-icon-box"><i class="fa-solid fa-utensils"></i></div>
                    <h5 class="fw-bold">Gourmet Dining</h5>
                    <p class="text-muted small">Multi-cuisine fine dining led by executive master chefs with 24-hour in-room service.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-3">
                    <div class="feature-icon-box"><i class="fa-solid fa-spa"></i></div>
                    <h5 class="fw-bold">Wellness & Jacuzzi Spa</h5>
                    <p class="text-muted small">Rejuvenate your senses with holistic massages, aroma steam therapy, and hot jacuzzis.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-3">
                    <div class="feature-icon-box"><i class="fa-solid fa-van-shuttle"></i></div>
                    <h5 class="fw-bold">Airport Chauffeur</h5>
                    <p class="text-muted small">Seamless pickup and drop services in executive luxury vehicles directly from the airport.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- FOOTER -->
<footer class="bg-dark text-white py-5" style="background-color: var(--primary-navy) !important;">
    <div class="container">
        <div class="row g-4">
            <div class="col-md-6">
                <h4 class="fw-bold d-flex align-items-center gap-2 mb-3">
                    <i class="fa-solid fa-hotel text-warning"></i> Grand Azure Hotel
                </h4>
                <p class="text-light opacity-75 small mb-2">
                    Premier hospitality experience providing five-star luxury suites, gourmet catering, and seamless front-desk services.
                </p>
                <div class="text-light opacity-75 small">
                    <i class="fa-solid fa-location-dot me-2 text-warning"></i>42 Marine Drive, Promenade Bay, Mumbai - 400020<br>
                    <i class="fa-solid fa-phone me-2 text-warning"></i>+91 22 2849 5500 &bull; reservations@grandazure.com
                </div>
            </div>
            <div class="col-md-6 text-md-end d-flex flex-column justify-content-between">
                <div>
                    <h6 class="text-uppercase fw-bold text-warning mb-3">Management Portal</h6>
                    <a href="login.jsp" class="btn btn-outline-light btn-sm px-4">
                        <i class="fa-solid fa-lock me-1"></i> Employee & Admin Sign In
                    </a>
                </div>
                <div class="text-light opacity-50 small mt-4">
                    &copy; 2026 Grand Azure Luxury Hotel System. Built entirely in Java & JDBC.
                </div>
            </div>
        </div>
    </div>
</footer>

<!-- Bootstrap 5 Bundle JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- Project Main JS -->
<script src="js/main.js"></script>

<script>
function selectRoomCategory(category) {
    const select = document.getElementById('publicRoomSelect');
    if (!select) return;
    for (let i = 0; i < select.options.length; i++) {
        if (select.options[i].text.includes(category)) {
            select.selectedIndex = i;
            select.dispatchEvent(new Event('change'));
            break;
        }
    }
}
</script>

</body>
</html>
