package com.harsha.exception;

/** Thrown by the DAO when MySQL rejects an INSERT/UPDATE because the email already exists. */
public class DuplicateEmailException extends Exception {

    private static final long serialVersionUID = 1L;

    public DuplicateEmailException(String email) {
        super("A user with email '" + email + "' already exists");
    }
}
