/**
 * Hotel Management System - Core Frontend JavaScript
 */

document.addEventListener('DOMContentLoaded', function () {
    initLiveClock();
    initDatePickers();
    initDynamicPricing();
    initAutoDismissAlerts();
    initEditModalHandlers();
});

// 1. Live Clock for Top Navbar
function initLiveClock() {
    const clockEl = document.getElementById('liveClock');
    if (!clockEl) return;

    function updateTime() {
        const now = new Date();
        const options = {
            weekday: 'short',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        };
        clockEl.textContent = now.toLocaleDateString('en-US', options);
    }
    updateTime();
    setInterval(updateTime, 1000);
}

// 2. Date Constraints (Prevent past dates and guarantee checkout > checkin)
function initDatePickers() {
    const today = new Date().toISOString().split('T')[0];

    const checkInInputs = document.querySelectorAll('input[type="date"][name="checkInDate"]');
    const checkOutInputs = document.querySelectorAll('input[type="date"][name="checkOutDate"]');

    checkInInputs.forEach(inInput => {
        if (!inInput.value) {
            inInput.value = today;
        }
        inInput.setAttribute('min', today);

        inInput.addEventListener('change', function () {
            const form = inInput.closest('form');
            if (!form) return;
            const outInput = form.querySelector('input[type="date"][name="checkOutDate"]');
            if (outInput) {
                outInput.setAttribute('min', inInput.value);
                if (outInput.value && outInput.value < inInput.value) {
                    outInput.value = inInput.value;
                }
            }
            triggerCostRecalculation(form);
        });
    });

    checkOutInputs.forEach(outInput => {
        if (!outInput.value) {
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            outInput.value = tomorrow.toISOString().split('T')[0];
        }
        outInput.setAttribute('min', today);

        outInput.addEventListener('change', function () {
            const form = outInput.closest('form');
            if (form) {
                triggerCostRecalculation(form);
            }
        });
    });
}

// 3. Dynamic Cost Calculation in Booking Forms
function initDynamicPricing() {
    const roomSelects = document.querySelectorAll('select[name="roomId"]');
    roomSelects.forEach(select => {
        select.addEventListener('change', function () {
            const form = select.closest('form');
            if (form) triggerCostRecalculation(form);
        });
    });

    // Run initial computation for default selected options
    document.querySelectorAll('.booking-calc-form').forEach(form => {
        triggerCostRecalculation(form);
    });
}

function triggerCostRecalculation(form) {
    if (!form) return;

    const checkInInput = form.querySelector('input[name="checkInDate"]');
    const checkOutInput = form.querySelector('input[name="checkOutDate"]');
    const roomSelect = form.querySelector('select[name="roomId"]');

    const daysDisplay = form.querySelector('.calc-days-display');
    const priceDisplay = form.querySelector('.calc-price-display');
    const totalDisplay = form.querySelector('.calc-total-display');

    if (!checkInInput || !checkOutInput || !roomSelect) return;

    const inDate = new Date(checkInInput.value);
    const outDate = new Date(checkOutInput.value);

    let days = 1;
    if (!isNaN(inDate.getTime()) && !isNaN(outDate.getTime())) {
        const diffTime = outDate.getTime() - inDate.getTime();
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        days = diffDays > 0 ? diffDays : 1;
    }

    let pricePerNight = 0.0;
    const selectedOption = roomSelect.options[roomSelect.selectedIndex];
    if (selectedOption && selectedOption.dataset.price) {
        pricePerNight = parseFloat(selectedOption.dataset.price);
    }

    const total = days * pricePerNight;

    if (daysDisplay) daysDisplay.textContent = days + (days === 1 ? ' night' : ' nights');
    if (priceDisplay) priceDisplay.textContent = '₹' + pricePerNight.toFixed(2);
    if (totalDisplay) totalDisplay.textContent = '₹' + total.toFixed(2);
}

// 4. Auto-dismiss Alert banners
function initAutoDismissAlerts() {
    const alerts = document.querySelectorAll('.alert-dismissible');
    alerts.forEach(alert => {
        setTimeout(() => {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
            if (bsAlert) bsAlert.close();
        }, 6000);
    });
}

// 5. Data-Attribute based Edit Modal Population (immune to string escaping errors)
function initEditModalHandlers() {
    document.addEventListener('click', function(e) {
        // Edit Room
        const roomBtn = e.target.closest('.btn-edit-room');
        if (roomBtn) {
            const d = roomBtn.dataset;
            setVal('editRoomId', d.id);
            setVal('editRoomNumber', d.number);
            setVal('editRoomType', d.type);
            setVal('editPricePerNight', d.price);
            setVal('editCapacity', d.capacity);
            setVal('editStatus', d.status);
            setVal('editAmenities', d.amenities);
            setVal('editDescription', d.description);
        }

        // Edit Customer
        const custBtn = e.target.closest('.btn-edit-customer');
        if (custBtn) {
            const d = custBtn.dataset;
            setVal('editCustomerId', d.id);
            setVal('editFullName', d.name);
            setVal('editEmail', d.email);
            setVal('editPhone', d.phone);
            setVal('editAddress', d.address);
            setVal('editIdProofType', d.idtype);
            setVal('editIdProofNumber', d.idnumber);
        }

        // Edit Staff
        const staffBtn = e.target.closest('.btn-edit-staff');
        if (staffBtn) {
            const d = staffBtn.dataset;
            setVal('editStaffId', d.id);
            setVal('editStaffFullName', d.name);
            setVal('editStaffRole', d.role);
            setVal('editStaffShift', d.shift);
            setVal('editStaffPhone', d.phone);
            setVal('editStaffEmail', d.email);
            setVal('editStaffSalary', d.salary);
            setVal('editStaffStatus', d.status);
            setVal('editStaffHireDate', d.hiredate);
        }
    });
}

function setVal(id, val) {
    const el = document.getElementById(id);
    if (el) el.value = (val !== undefined && val !== null) ? val : '';
}

// 6. Open Payment Modal for Booking
function openPaymentModal(bookingId, bookingNumber, balance) {
    const idInput = document.getElementById('payBookingId');
    const numDisplay = document.getElementById('payBookingNumber');
    const amountInput = document.getElementById('payAmount');

    if (idInput) idInput.value = bookingId;
    if (numDisplay) numDisplay.textContent = bookingNumber;
    if (amountInput) amountInput.value = balance > 0 ? parseFloat(balance).toFixed(2) : '0.00';
}
