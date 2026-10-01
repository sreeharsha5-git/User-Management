package com.harsha.exception;

import com.harsha.util.ApiResponse;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Last line of defence: converts any exception thrown by a resource into a clean JSON response.
 * The user only sees a friendly message - the full stack trace goes to the server log.
 */
public class ApiExceptionMapper implements ExceptionMapper<Throwable> {

    private static final Logger LOG = Logger.getLogger(ApiExceptionMapper.class.getName());

    @Override
    public Response toResponse(Throwable ex) {
        if (ex instanceof DuplicateEmailException) {
            return ApiResponse.error(Response.Status.CONFLICT, ex.getMessage());           // 409
        }
        if (ex instanceof WebApplicationException) {                                        // 404 / 405 / 415 ...
            int status = ((WebApplicationException) ex).getResponse().getStatus();
            Response.Status known = Response.Status.fromStatusCode(status);
            String text = (known != null) ? known.getReasonPhrase() : "Request failed";
            return ApiResponse.error(status, text);
        }
        if (ex instanceof SQLException) {
            LOG.log(Level.SEVERE, "Database error", ex);
            return ApiResponse.error(Response.Status.INTERNAL_SERVER_ERROR,
                    "A database error occurred. Please try again later.");                 // 500
        }
        LOG.log(Level.SEVERE, "Unexpected error", ex);
        return ApiResponse.error(Response.Status.INTERNAL_SERVER_ERROR, "Internal server error");
    }
}
