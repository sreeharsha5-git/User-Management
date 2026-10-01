package com.harsha.config;

import com.harsha.exception.ApiExceptionMapper;
import com.harsha.resource.AuthResource;
import com.harsha.resource.UserResource;
import jakarta.ws.rs.ApplicationPath;
import org.glassfish.jersey.media.multipart.MultiPartFeature;
import org.glassfish.jersey.server.ResourceConfig;

/**
 * Configures Jersey.
 *
 * @ApplicationPath("/api") means every REST URL starts with /api
 * (e.g. /api/users). Tomcat finds this class automatically at startup,
 * so no servlet mapping is needed in web.xml.
 */
@ApplicationPath("/api")
public class JerseyConfig extends ResourceConfig {

    public JerseyConfig() {
        register(AuthResource.class);       // /api/auth/...
        register(UserResource.class);       // /api/users/...
        register(ApiExceptionMapper.class); // turns exceptions into JSON error responses
        register(MultiPartFeature.class);   // enables multipart/form-data (Excel upload)
    }
}
