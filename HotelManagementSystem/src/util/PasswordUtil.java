package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Utility for hashing and verifying passwords using SHA-256.
 */
public class PasswordUtil {

    public static String hashPassword(String plainPassword) {
        if (plainPassword == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plainPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    public static boolean checkPassword(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) return false;
        // Direct match (for initial seed data convenience)
        if (plainPassword.equals(storedPassword)) return true;
        // SHA-256 comparison
        return hashPassword(plainPassword).equalsIgnoreCase(storedPassword);
    }
}
