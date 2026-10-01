package com.harsha.resource;

import com.harsha.dao.UserDAO;
import com.harsha.exception.DuplicateEmailException;
import com.harsha.filter.AuthFilter;
import com.harsha.model.ImportResult;
import com.harsha.model.User;
import com.harsha.service.ExcelImportService;
import com.harsha.util.ApiResponse;
import com.harsha.util.ValidationUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import org.glassfish.jersey.media.multipart.FormDataContentDisposition;
import org.glassfish.jersey.media.multipart.FormDataParam;

/**
 * REST API for MANAGING users. Base URL: /api/users
 *
 * EVERY endpoint here is ADMIN ONLY. A normal user gets 403 Forbidden, so they can never
 * list, view, create, change or delete other users (they only see their own profile via /api/auth/me).
 *
 *   GET    /api/users          list all users
 *   GET    /api/users/count    number of users
 *   GET    /api/users/{id}     one user
 *   POST   /api/users          create user (admin chooses USER or ADMIN role)
 *   PUT    /api/users/{id}     update name / email / phone / role
 *   DELETE /api/users/{id}     delete user
 *   POST   /api/users/import   bulk import from .xlsx
 *
 * Annotations: @Path = URL, @GET/@POST/@PUT/@DELETE = HTTP method, @PathParam = value from the URL,
 * @Consumes = request body type, @Produces = response body type.
 * Exceptions thrown here are converted to JSON errors by ApiExceptionMapper.
 */
@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
public class UserResource {

    private static final String ROLE_ADMIN = "ADMIN";
    private static final String ROLE_USER = "USER";

    @Context
    private HttpServletRequest request;

    private final UserDAO userDAO = new UserDAO();
    private final ExcelImportService importService = new ExcelImportService(userDAO);

    @GET
    public Response getAllUsers() throws SQLException {
        Response denied = requireAdmin();
        if (denied != null) {
            return denied;
        }
        return Response.ok(userDAO.getAllUsers()).build();                               // 200
    }

    @GET
    @Path("/count")
    public Response getUserCount() throws SQLException {
        Response denied = requireAdmin();
        if (denied != null) {
            return denied;
        }
        return Response.ok(Map.of("count", userDAO.countUsers())).build();
    }

    @GET
    @Path("/{id}")
    public Response getUser(@PathParam("id") int id) throws SQLException {
        Response denied = requireAdmin();
        if (denied != null) {
            return denied;
        }
        User user = userDAO.getUserById(id);
        if (user == null) {
            return ApiResponse.error(Response.Status.NOT_FOUND, "User not found with id " + id); // 404
        }
        return Response.ok(user).build();                                                // 200
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createUser(User input) throws SQLException, DuplicateEmailException {
        Response denied = requireAdmin();
        if (denied != null) {
            return denied;
        }
        if (input == null) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, "Request body is required");
        }
        List<String> errors = ValidationUtil.validateUser(input.getName(), input.getEmail(), input.getPhone());
        if (ValidationUtil.isBlank(input.getPassword()) || input.getPassword().length() < 6) {
            errors.add("Password is required (minimum 6 characters)");
        }
        String role = normalizeRole(input.getRole(), ROLE_USER);   // blank role = normal user
        if (role == null) {
            errors.add("Role must be USER or ADMIN");
        }
        if (!errors.isEmpty()) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, String.join("; ", errors)); // 400
        }

        input.setName(input.getName().trim());
        input.setEmail(input.getEmail().trim().toLowerCase());
        input.setPhone(ValidationUtil.normalizePhone(input.getPhone()));
        input.setRole(role);

        userDAO.insertUser(input);              // duplicate email -> 409 via ApiExceptionMapper
        input.setPassword(null);
        return Response.status(Response.Status.CREATED).entity(input).build();           // 201
    }

    @PUT
    @Path("/{id}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updateUser(@PathParam("id") int id, User input) throws SQLException, DuplicateEmailException {
        Response denied = requireAdmin();
        if (denied != null) {
            return denied;
        }
        if (input == null) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, "Request body is required");
        }
        User existing = userDAO.getUserById(id);
        if (existing == null) {
            return ApiResponse.error(Response.Status.NOT_FOUND, "User not found with id " + id);
        }

        List<String> errors = ValidationUtil.validateUser(input.getName(), input.getEmail(), input.getPhone());
        String role = normalizeRole(input.getRole(), existing.getRole());   // blank role = keep the current one
        if (role == null) {
            errors.add("Role must be USER or ADMIN");
        }
        if (!errors.isEmpty()) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, String.join("; ", errors));
        }
        // Safety rule: an admin cannot demote themselves (otherwise the system could end up with no admin)
        User current = sessionUser();
        if (current != null && current.getId() == id && !ROLE_ADMIN.equals(role)) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, "You cannot remove your own administrator role");
        }

        input.setId(id);
        input.setName(input.getName().trim());
        input.setEmail(input.getEmail().trim().toLowerCase());
        input.setPhone(ValidationUtil.normalizePhone(input.getPhone()));
        input.setRole(role);

        userDAO.updateUser(input);
        return Response.ok(userDAO.getUserById(id)).build();                             // 200
    }

    @DELETE
    @Path("/{id}")
    public Response deleteUser(@PathParam("id") int id) throws SQLException {
        Response denied = requireAdmin();
        if (denied != null) {
            return denied;
        }
        User current = sessionUser();
        if (current != null && current.getId() == id) {
            return ApiResponse.error(Response.Status.FORBIDDEN, "You cannot delete your own account"); // 403
        }
        if (!userDAO.deleteUser(id)) {
            return ApiResponse.error(Response.Status.NOT_FOUND, "User not found with id " + id);
        }
        return ApiResponse.ok("User deleted successfully");                              // 200
    }

    /**
     * Excel bulk import. The browser sends multipart/form-data with a part named "file".
     * Jersey gives us the file bytes (InputStream) and the file name (FormDataContentDisposition).
     */
    @POST
    @Path("/import")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public Response importUsers(@FormDataParam("file") InputStream fileStream,
                                @FormDataParam("file") FormDataContentDisposition fileInfo) throws SQLException {

        Response denied = requireAdmin();
        if (denied != null) {
            return denied;
        }
        if (fileStream == null || fileInfo == null || ValidationUtil.isBlank(fileInfo.getFileName())) {
            return ApiResponse.error(Response.Status.BAD_REQUEST, "Please choose an Excel (.xlsx) file to upload");
        }
        if (!fileInfo.getFileName().toLowerCase().endsWith(".xlsx")) {
            return ApiResponse.error(415, "Unsupported file type. Please upload an .xlsx file");        // 415
        }

        try {
            ImportResult result = importService.importUsers(fileStream);
            return Response.ok(result).build();
        } catch (IllegalArgumentException e) {
            // invalid / empty / corrupted workbook, wrong header, too many rows ...
            return ApiResponse.error(Response.Status.BAD_REQUEST, e.getMessage());                      // 400
        }
    }

    /**
     * AUTHORIZATION check used by every method above. Returns null when the caller is an administrator,
     * otherwise the error response to send back (401 / 403).
     * The role is re-read from MySQL on every call (not trusted from the session), so demoting or
     * deleting an admin takes effect immediately.
     */
    private Response requireAdmin() throws SQLException {
        User sessionUser = sessionUser();
        if (sessionUser == null) {
            return ApiResponse.error(Response.Status.UNAUTHORIZED, "Authentication required. Please log in.");
        }
        User fresh = userDAO.getUserById(sessionUser.getId());
        if (fresh == null) {                                   // account deleted while logged in
            request.getSession().invalidate();
            return ApiResponse.error(Response.Status.UNAUTHORIZED, "This account no longer exists");
        }
        if (!ROLE_ADMIN.equals(fresh.getRole())) {
            return ApiResponse.error(Response.Status.FORBIDDEN, "Access denied. Administrator privileges are required"); // 403
        }
        return null;
    }

    /** "user"/"ADMIN" -> upper case; blank -> fallback; anything else -> null (invalid). */
    private String normalizeRole(String role, String fallback) {
        if (ValidationUtil.isBlank(role)) {
            return fallback;
        }
        String upper = role.trim().toUpperCase();
        return (ROLE_ADMIN.equals(upper) || ROLE_USER.equals(upper)) ? upper : null;
    }

    /** The logged-in user stored in the HTTP session by AuthResource.login(). */
    private User sessionUser() {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute(AuthFilter.SESSION_USER);
    }
}
