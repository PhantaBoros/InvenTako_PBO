package controller;

import java.io.IOException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

public final class KasirHelper {

    private static final String LOGIN_PATH = "/login.jsp";
    private static final String KASIR_ROLE = "kasir";

    private KasirHelper() {
    }

    public static User requireKasirUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            redirect(response, request, LOGIN_PATH);
            return null;
        }

        Object userObject = session.getAttribute("user");
        if (!(userObject instanceof User)) {
            redirect(response, request, LOGIN_PATH);
            return null;
        }

        User user = (User) userObject;
        if (!KASIR_ROLE.equals(user.getRole())) {
            redirect(response, request, LOGIN_PATH);
            return null;
        }

        return user;
    }

    public static Integer parseRequiredIntParameter(HttpServletRequest request, HttpServletResponse response, String parameterName, String errorPath) throws IOException {
        String value = request.getParameter(parameterName);
        if (value == null || value.trim().isEmpty()) {
            redirect(response, request, errorPath);
            return null;
        }

        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            redirect(response, request, errorPath);
            return null;
        }
    }

    public static String getDisplayName(User user) {
        if (user == null || isBlank(user.getUsername())) {
            return "User";
        }
        return user.getUsername().trim();
    }

    public static String getInitials(String name) {
        if (isBlank(name)) {
            return "U";
        }

        String[] parts = name.trim().split("\\s+");
        StringBuilder initials = new StringBuilder();

        for (int i = 0; i < parts.length && initials.length() < 2; i++) {
            if (!parts[i].isEmpty()) {
                initials.append(Character.toUpperCase(parts[i].charAt(0)));
            }
        }

        return initials.length() == 0 ? "U" : initials.toString();
    }

    public static String normalizePaymentMethod(String paymentMethod) {
        if (isBlank(paymentMethod)) {
            return "tunai";
        }
        return paymentMethod.trim();
    }

    private static void redirect(HttpServletResponse response, HttpServletRequest request, String path) throws IOException {
        response.sendRedirect(request.getContextPath() + path);
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}