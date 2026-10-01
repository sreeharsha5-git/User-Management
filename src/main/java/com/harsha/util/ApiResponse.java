package com.harsha.util;

import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.LinkedHashMap;
import java.util.Map;

/** Small helper that builds the JSON bodies {"success":..., "message":...} used by the whole API. */
public final class ApiResponse {

    private ApiResponse() { }

    public static Response error(Response.Status status, String message) {
        return error(status.getStatusCode(), message);
    }

    public static Response error(int status, String message) {
        return Response.status(status).type(MediaType.APPLICATION_JSON)
                .entity(body(false, message)).build();
    }

    public static Response ok(String message) {
        return Response.ok(body(true, message)).build();
    }

    public static Map<String, Object> body(boolean success, String message) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("success", success);
        map.put("message", message);
        return map;
    }
}
