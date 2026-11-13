package test;

import service.BookingService;
import util.PasswordUtil;

import java.sql.Date;
import java.time.LocalDate;

/**
 * Automated verification suite to validate critical business logic rules,
 * pricing calculations, date algorithms, and security hash routines.
 */
public class SystemValidationTest {

    public static void main(String[] args) {
        System.out.println("==================================================");
        System.out.println("Starting Hotel Management System Unit Verification");
        System.out.println("==================================================");

        int passed = 0;
        int failed = 0;

        // Test 1: Password Hash & Verification
        try {
            String rawPass = "admin123";
            String hash = PasswordUtil.hashPassword(rawPass);
            boolean check1 = PasswordUtil.checkPassword(rawPass, hash);
            boolean check2 = PasswordUtil.checkPassword("wrongPass", hash);
            boolean check3 = PasswordUtil.checkPassword(rawPass, rawPass); // Plaintext fallback check

            if (check1 && !check2 && check3) {
                System.out.println("[PASS] Test 1: Password hashing & verification logic working.");
                passed++;
            } else {
                System.err.println("[FAIL] Test 1: Password verification failed.");
                failed++;
            }
        } catch (Exception e) {
            System.err.println("[FAIL] Test 1 encountered exception: " + e.getMessage());
            failed++;
        }

        // Test 2: Stay Duration Calculation
        try {
            BookingService bookingService = new BookingService();
            Date d1 = Date.valueOf(LocalDate.of(2026, 11, 10));
            Date d2 = Date.valueOf(LocalDate.of(2026, 11, 15));
            int days = bookingService.calculateTotalDays(d1, d2);

            Date sameDay1 = Date.valueOf(LocalDate.of(2026, 11, 10));
            Date sameDay2 = Date.valueOf(LocalDate.of(2026, 11, 10));
            int minDays = bookingService.calculateTotalDays(sameDay1, sameDay2);

            if (days == 5 && minDays == 1) {
                System.out.println("[PASS] Test 2: Stay duration calculation (5 nights, same-day minimum 1 night).");
                passed++;
            } else {
                System.err.println("[FAIL] Test 2: Unexpected days calculation: days=" + days + ", minDays=" + minDays);
                failed++;
            }
        } catch (Exception e) {
            System.err.println("[FAIL] Test 2 encountered exception: " + e.getMessage());
            failed++;
        }

        // Test 3: Total Booking Cost Calculation
        try {
            BookingService bookingService = new BookingService();
            double pricePerNight = 3800.00; // Deluxe room
            int nights = 4;
            double total = bookingService.calculateTotalCost(pricePerNight, nights);

            if (Math.abs(total - 15200.00) < 0.001) {
                System.out.println("[PASS] Test 3: Total cost calculation (₹" + total + " matching expected ₹15,200.00).");
                passed++;
            } else {
                System.err.println("[FAIL] Test 3: Expected 15200.00, got: " + total);
                failed++;
            }
        } catch (Exception e) {
            System.err.println("[FAIL] Test 3 encountered exception: " + e.getMessage());
            failed++;
        }

        // Test 4: Booking Reference Pattern
        try {
            BookingService bookingService = new BookingService();
            String ref1 = bookingService.generateBookingNumber();
            String ref2 = bookingService.generateBookingNumber();

            boolean validFormat = ref1.startsWith("BK-") && ref1.length() >= 14 && !ref1.equals(ref2);
            if (validFormat) {
                System.out.println("[PASS] Test 4: Unique booking reference generation (" + ref1 + ", " + ref2 + ").");
                passed++;
            } else {
                System.err.println("[FAIL] Test 4: Invalid booking reference pattern.");
                failed++;
            }
        } catch (Exception e) {
            System.err.println("[FAIL] Test 4 encountered exception: " + e.getMessage());
            failed++;
        }

        System.out.println("==================================================");
        System.out.println("Verification Summary: " + passed + " Passed, " + failed + " Failed.");
        System.out.println("==================================================");

        if (failed > 0) {
            System.exit(1);
        }
    }
}
