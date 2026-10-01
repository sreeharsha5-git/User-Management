package com.harsha.config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Creates JDBC connections to MySQL.
 *
 * Settings come from db.properties (on the classpath). Environment variables
 * DB_URL, DB_USER and DB_PASSWORD override the file if they are set.
 *
 * Every call to getConnection() opens a NEW connection and the caller closes it
 * (try-with-resources). That is simple and easy to explain; a production app
 * would use a connection pool (e.g. Tomcat JDBC pool / HikariCP).
 */
public final class DatabaseConnection {

    private static final Properties SETTINGS = new Properties();

    static {
        try (InputStream in = DatabaseConnection.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            if (in != null) {
                SETTINGS.load(in);
            }
            // Load the MySQL driver class explicitly so it also works inside a WAR.
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (IOException | ClassNotFoundException e) {
            throw new ExceptionInInitializerError("Cannot initialise database settings: " + e.getMessage());
        }
    }

    private DatabaseConnection() { }

    private static String setting(String envName, String propertyName) {
        String fromEnv = System.getenv(envName);
        return (fromEnv != null && !fromEnv.isBlank()) ? fromEnv : SETTINGS.getProperty(propertyName);
    }

    public static Connection getConnection() throws SQLException {
        String url = setting("DB_URL", "db.url");
        String user = setting("DB_USER", "db.user");
        String password = setting("DB_PASSWORD", "db.password");
        if (url == null) {
            throw new SQLException("db.url is not configured (see src/main/resources/db.properties)");
        }
        return DriverManager.getConnection(url, user, password);
    }
}
