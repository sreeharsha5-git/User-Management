package com.harsha.filter;

import com.harsha.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;

/**
 * Session-based access control. Runs BEFORE every request (urlPatterns = "/*").
 *
 *   Request -> AuthFilter -> is there a logged-in user in the HTTP session?
 *                              YES -> continue to the page / REST API
 *                              NO  -> API request: 401 JSON,  page request: redirect to login.jsp
 *
 * This is AUTHENTICATION ("who are you?"). Checking the user's role (e.g. only ADMIN may import)
 * is AUTHORIZATION ("what may you do?") and is done in UserResource.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = "/*")
public class AuthFilter implements Filter {

    /** Name of the session attribute that holds the logged-in User. */
    public static final String SESSION_USER = "user";

    // Resources that anyone may open without logging in
    private static final Set<String> PUBLIC_PATHS =
            Set.of("/login.jsp", "/error.html", "/favicon.ico", "/api/auth/login");
    private static final String[] PUBLIC_PREFIXES = {"/css/", "/js/"};

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String path = pathWithinApp(request);
        String contextPath = request.getContextPath();

        // getSession(false) = "give me the session if it exists, do NOT create a new one"
        HttpSession session = request.getSession(false);
        boolean loggedIn = session != null && session.getAttribute(SESSION_USER) != null;

        // Application root "/" -> send to the right page
        if (path.isEmpty() || path.equals("/")) {
            response.sendRedirect(contextPath + (loggedIn ? "/home.jsp" : "/login.jsp"));
            return;
        }

        if (isPublic(path)) {
            // A logged-in user does not need the login page again
            if (loggedIn && path.equals("/login.jsp")) {
                response.sendRedirect(contextPath + "/home.jsp");
                return;
            }
            chain.doFilter(request, response);
            return;
        }

        if (loggedIn) {
            // Page-level authorization: users.jsp is for administrators only.
            // (The REST API enforces the same rule again in UserResource.requireAdmin().)
            User sessionUser = (User) session.getAttribute(SESSION_USER);
            if (path.equals("/users.jsp") && !"ADMIN".equals(sessionUser.getRole())) {
                response.sendRedirect(contextPath + "/home.jsp");
                return;
            }
            // Stop the browser caching protected pages, so the Back button after logout
            // cannot show an old page from cache.
            response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            chain.doFilter(request, response);
            return;
        }

        // Not logged in
        if (path.startsWith("/api/")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);   // 401
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"Authentication required. Please log in.\"}");
        } else {
            response.sendRedirect(contextPath + "/login.jsp");
        }
    }

    /** URL path without the context path, e.g. "/api/users/5" or "/home.jsp". */
    private String pathWithinApp(HttpServletRequest request) {
        String servletPath = request.getServletPath() == null ? "" : request.getServletPath();
        String pathInfo = request.getPathInfo() == null ? "" : request.getPathInfo();
        return servletPath + pathInfo;
    }

    private boolean isPublic(String path) {
        if (PUBLIC_PATHS.contains(path)) {
            return true;
        }
        for (String prefix : PUBLIC_PREFIXES) {
            if (path.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }
}
