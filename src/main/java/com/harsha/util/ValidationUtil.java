package com.harsha.util;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/** Validation rules shared by the "Add/Update user" API and the Excel import. */
public final class ValidationUtil {

    // something@something.tld  (basic format check, not a full RFC check)
    private static final Pattern EMAIL = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    // optional +, then 7-15 digits
    private static final Pattern PHONE = Pattern.compile("^\\+?[0-9]{7,15}$");

    private ValidationUtil() { }

    public static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    /** Trims, removes spaces/dashes, and returns null when empty (phone is optional). */
    public static String normalizePhone(String raw) {
        if (isBlank(raw)) {
            return null;
        }
        return raw.trim().replaceAll("[\\s-]", "");
    }

    /** Returns a list of problems. An EMPTY list means the data is valid. */
    public static List<String> validateUser(String name, String email, String phone) {
        List<String> errors = new ArrayList<>();

        if (isBlank(name)) {
            errors.add("Name is required");
        } else if (name.trim().length() > 100) {
            errors.add("Name must be at most 100 characters");
        }

        if (isBlank(email)) {
            errors.add("Email is required");
        } else if (email.trim().length() > 100) {
            errors.add("Email must be at most 100 characters");
        } else if (!EMAIL.matcher(email.trim()).matches()) {
            errors.add("Email is invalid");
        }

        String cleanPhone = normalizePhone(phone);
        if (cleanPhone != null && !PHONE.matcher(cleanPhone).matches()) {
            errors.add("Phone is invalid (7-15 digits, optional leading +)");
        }
        return errors;
    }
}
