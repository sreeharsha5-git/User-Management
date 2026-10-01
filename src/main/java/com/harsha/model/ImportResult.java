package com.harsha.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Summary returned to the browser after an Excel import.
 * Invariant: totalRows = successful + failed + duplicates.
 */
public class ImportResult {

    private boolean success;
    private String message;
    private int totalRows;       // non-empty data rows found in the sheet
    private int successful;      // rows saved to MySQL
    private int failed;          // rows rejected by validation
    private int duplicates;      // rows skipped because the email already exists (in the file or in the DB)
    private List<String> errors = new ArrayList<>();          // e.g. "Row 4: Email is invalid"
    private List<String> duplicateEmails = new ArrayList<>(); // the emails that were skipped

    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public int getTotalRows() { return totalRows; }
    public void setTotalRows(int totalRows) { this.totalRows = totalRows; }

    public int getSuccessful() { return successful; }
    public void setSuccessful(int successful) { this.successful = successful; }

    public int getFailed() { return failed; }
    public void setFailed(int failed) { this.failed = failed; }

    public int getDuplicates() { return duplicates; }
    public void setDuplicates(int duplicates) { this.duplicates = duplicates; }

    public List<String> getErrors() { return errors; }
    public void setErrors(List<String> errors) { this.errors = errors; }

    public List<String> getDuplicateEmails() { return duplicateEmails; }
    public void setDuplicateEmails(List<String> duplicateEmails) { this.duplicateEmails = duplicateEmails; }
}
