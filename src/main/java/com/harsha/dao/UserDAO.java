package com.harsha.dao;

import com.harsha.config.DatabaseConnection;
import com.harsha.exception.DuplicateEmailException;
import com.harsha.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * DAO = Data Access Object. The ONLY class that talks to MySQL.
 * Resources call these methods and never write SQL themselves.
 *
 * WHY PreparedStatement? The SQL text contains placeholders (?) and the values are sent
 * separately, so user input is always treated as DATA and never as SQL code.
 * This prevents SQL injection, e.g. an email of  ' OR '1'='1  cannot change the query.
 *
 * Every method opens its own Connection with try-with-resources, which closes the
 * Connection / PreparedStatement / ResultSet automatically, even when an exception happens.
 */
public class UserDAO {

    private static final String COLUMNS = "id, name, email, phone, role"; // password is NOT loaded for lists

    /** Used by login. Returns the user INCLUDING the password, or null if the email is unknown. */
    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT id, name, email, password, phone, role FROM users WHERE email = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = mapRow(rs);
                    user.setPassword(rs.getString("password"));
                    return user;
                }
            }
        }
        return null;
    }

    public List<User> getAllUsers() throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM users ORDER BY id";
        List<User> users = new ArrayList<>();
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(mapRow(rs));
            }
        }
        return users;
    }

    public User getUserById(int id) throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM users WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public int countUsers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Inserts one user. MySQL generates the id (AUTO_INCREMENT) and we read it back into the object. */
    public void insertUser(User user) throws SQLException, DuplicateEmailException {
        String sql = "INSERT INTO users(name, email, password, phone, role) VALUES(?,?,?,?,?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getRole());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    user.setId(keys.getInt(1));
                }
            }
        } catch (SQLIntegrityConstraintViolationException e) {
            // Thrown when the UNIQUE constraint on email is violated (MySQL error 1062)
            throw new DuplicateEmailException(user.getEmail());
        }
    }

    /** @return true if a row was updated, false if no user has that id */
    public boolean updateUser(User user) throws SQLException, DuplicateEmailException {
        String sql = "UPDATE users SET name = ?, email = ?, phone = ?, role = ? WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getRole());
            ps.setInt(5, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLIntegrityConstraintViolationException e) {
            throw new DuplicateEmailException(user.getEmail());
        }
    }

    /** Current password of a user (used to verify "current password" when changing it). Null if no such user. */
    public String getPasswordById(int id) throws SQLException {
        String sql = "SELECT password FROM users WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    /** @return true if the password was changed, false if no user has that id */
    public boolean updatePassword(int id, String newPassword) throws SQLException {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    /** @return true if a row was deleted, false if no user has that id */
    public boolean deleteUser(int id) throws SQLException {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    /** All existing emails (lower case). The Excel import uses this to detect duplicates. */
    public Set<String> getAllEmails() throws SQLException {
        String sql = "SELECT email FROM users";
        Set<String> emails = new HashSet<>();
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                emails.add(rs.getString(1).toLowerCase());
            }
        }
        return emails;
    }

    /**
     * Bulk insert in ONE TRANSACTION using a JDBC batch.
     *  - setAutoCommit(false): nothing is permanent until commit()
     *  - addBatch()/executeBatch(): sends all rows together (faster than one-by-one)
     *  - commit(): saves everything
     *  - rollback(): if ANY row fails, undo ALL of them, so we never end up half-imported
     */
    public void insertUsersBatch(List<User> users) throws SQLException {
        if (users.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO users(name, email, password, phone, role) VALUES(?,?,?,?,?)";
        try (Connection con = DatabaseConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                for (User user : users) {
                    ps.setString(1, user.getName());
                    ps.setString(2, user.getEmail());
                    ps.setString(3, user.getPassword());
                    ps.setString(4, user.getPhone());
                    ps.setString(5, user.getRole());
                    ps.addBatch();
                }
                ps.executeBatch();
                con.commit();
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        }
    }

    /** Converts the current ResultSet row into a User object (password is not included). */
    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setName(rs.getString("name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setRole(rs.getString("role"));
        return user;
    }
}
