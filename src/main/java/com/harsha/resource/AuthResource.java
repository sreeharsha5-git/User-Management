package com.harsha.resource;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.harsha.dao.UserDAO;
import com.harsha.filter.AuthFilter;
import com.harsha.model.User;
import com.harsha.util.ApiResponse;
import com.harsha.util.ValidationUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Login / logout / "my profile" / change-password endpoints.
 *   POST /api/auth/login             (public)
 *   POST /api/auth/logout
 *   GET  /api/auth/me                the logged-in user's own details
 *   POST /api/auth/change-password   the logged-in user changes their own password
 *
 * These are available to EVERY logged-in user (admin or normal user), but each user can only
 * ever touch their OWN account: the user id always comes from the session, never from the request.
 */
@Path("/auth")
@Produces(MediaType.APPLICATION_JSON)
public class AuthResource {

    /** Shape of the JSON sent by the login form: {"email":"...","password":"..."} */
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class LoginRequest {
        public String email;
        public String password;
    }

    /** Shape of the change-password form: {"currentPassword":"...","newPassword":"..."} */
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ChangePasswordRequest {
        public String currentPassword;
        public String newPassword;
    }

    private static final int MIN_PASSWORD_LENGTH = 6;
    private static final int MAX_PASSWORD_LENGTH = 100;

    // Jersey injects the current servlet request, which gives us access to the HTTP session
    @Context
    private HttpServletRequest request;

    private final UserDAO userDAO = new UserDAO();

    @POST
    @Path("/login")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response login(LoginRequest credentials) throws SQLException {
        if (credentials == null
                || ValidationUtil.isBlank(credentials.email)
                || ValidationUtil.isBlank(credentials.password)) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, "Email and password are required"); // 400
        }

        User user = userDAO.findByEmail(credentials.email.trim().toLowerCase());

        // Same message for "unknown email" and "wrong password" so attackers cannot tell which one failed
        if (user == null || !user.getPassword().equals(credentials.password)) {
            return ApiResponse.error(Response.Status.UNAUTHORIZED, "Invalid email or password");       // 401
        }

        // Discard any old session and create a fresh one (prevents "session fixation" attacks)
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(30 * 60);          // 30 minutes of inactivity

        user.setPassword(null);                           // never keep the password in the session
        session.setAttribute(AuthFilter.SESSION_USER, user);

        Map<String, Object> body = ApiResponse.body(true, "Login successful");
        body.put("user", user);
        return Response.ok(body).build();
    }

    @POST
    @Path("/logout")
    public Response logout() {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();                         // destroys the session on the server
        }
        return ApiResponse.ok("Logged out");
    }

    /**
     * Returns the logged-in user's own details. The data is re-read from MySQL (not just taken from the
     * session) so name/phone/role changes made by an admin show up, and a deleted account is logged out.
     */
    @GET
    @Path("/me")
    public Response me() throws SQLException {
        User sessionUser = sessionUser();
        if (sessionUser == null) {
            return ApiResponse.error(Response.Status.UNAUTHORIZED, "Not logged in");
        }
        User fresh = userDAO.getUserById(sessionUser.getId());
        if (fresh == null) {                              // account was deleted while logged in
            request.getSession().invalidate();
            return ApiResponse.error(Response.Status.UNAUTHORIZED, "This account no longer exists");
        }
        request.getSession().setAttribute(AuthFilter.SESSION_USER, fresh);   // refresh the session copy

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("id", fresh.getId());
        body.put("name", fresh.getName());
        body.put("email", fresh.getEmail());
        body.put("phone", fresh.getPhone());
        body.put("role", fresh.getRole());
        return Response.ok(body).build();
    }

    /** A logged-in user changes THEIR OWN password. The session stays valid afterwards. */
    @POST
    @Path("/change-password")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response changePassword(ChangePasswordRequest input) throws SQLException {
        User sessionUser = sessionUser();
        if (sessionUser == null) {
            return ApiResponse.error(Response.Status.UNAUTHORIZED, "Not logged in");
        }
        if (input == null || ValidationUtil.isBlank(input.currentPassword) || ValidationUtil.isBlank(input.newPassword)) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, "Current password and new password are required");
        }
        if (input.newPassword.length() < MIN_PASSWORD_LENGTH || input.newPassword.length() > MAX_PASSWORD_LENGTH) {
            return ApiResponse.error(Response.Status.BAD_REQUEST,
                    "New password must be between " + MIN_PASSWORD_LENGTH + " and " + MAX_PASSWORD_LENGTH + " characters");
        }

        String storedPassword = userDAO.getPasswordById(sessionUser.getId());
        if (storedPassword == null) {
            return ApiResponse.error(Response.Status.UNAUTHORIZED, "This account no longer exists");
        }
        // 400 (not 401) on purpose: the user IS logged in, they just typed the wrong current password
        if (!storedPassword.equals(input.currentPassword)) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, "Current password is incorrect");
        }
        if (storedPassword.equals(input.newPassword)) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, "New password must be different from the current password");
        }

        userDAO.updatePassword(sessionUser.getId(), input.newPassword);
        return ApiResponse.ok("Password changed successfully");
    }

    private User sessionUser() {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute(AuthFilter.SESSION_USER);
    }
}
