package com.harsha.service;

import com.harsha.dao.UserDAO;
import com.harsha.model.ImportResult;
import com.harsha.model.User;
import com.harsha.util.ValidationUtil;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * Reads an .xlsx file with Apache POI, validates every row, and saves the good rows through the DAO.
 *
 * Steps:
 *   1. open the workbook (XSSFWorkbook = .xlsx format)
 *   2. check the header row  (Name | Email | Phone)
 *   3. for each row: read cells -> validate -> skip duplicates inside the file
 *   4. ask the DB which emails already exist -> skip those too
 *   5. insert the remaining rows in one transaction (UserDAO.insertUsersBatch)
 *
 * A bad row NEVER stops the import: it is counted and reported in ImportResult.
 */
public class ExcelImportService {

    private static final Logger LOG = Logger.getLogger(ExcelImportService.class.getName());

    private static final int MAX_ROWS = 1000;
    /** Imported users need some password because the column is NOT NULL. Documented in the README. */
    private static final String DEFAULT_PASSWORD = "Welcome@123";

    private final UserDAO userDAO;

    public ExcelImportService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    /**
     * @throws IllegalArgumentException when the FILE itself is unusable (corrupt, empty, wrong header...)
     * @throws SQLException             on a database failure (the transaction is rolled back)
     */
    public ImportResult importUsers(InputStream fileStream) throws SQLException {
        ImportResult result = new ImportResult();
        List<User> validUsers = new ArrayList<>();

        try (Workbook workbook = openWorkbook(fileStream)) {
            readRows(workbook, result, validUsers);
        } catch (IOException e) {
            LOG.log(Level.WARNING, "Could not close workbook", e);   // reading already finished; just log
        }

        saveNewUsers(result, validUsers);

        result.setSuccess(result.getSuccessful() > 0);
        result.setMessage(String.format("Imported %d of %d rows (%d failed, %d duplicates skipped)",
                result.getSuccessful(), result.getTotalRows(), result.getFailed(), result.getDuplicates()));
        return result;
    }

    private Workbook openWorkbook(InputStream fileStream) {
        try {
            return new XSSFWorkbook(fileStream);
        } catch (IOException | RuntimeException e) {
            LOG.log(Level.WARNING, "Invalid Excel upload", e);
            throw new IllegalArgumentException("Invalid or corrupted Excel file. Please upload a valid .xlsx file");
        }
    }

    private void readRows(Workbook workbook, ImportResult result, List<User> validUsers) {
        if (workbook.getNumberOfSheets() == 0) {
            throw new IllegalArgumentException("The Excel file has no sheets");
        }
        Sheet sheet = workbook.getSheetAt(0);                 // first sheet only
        DataFormatter formatter = new DataFormatter();        // reads ANY cell type as text (a phone typed as a number stays 9876543210)

        Row header = sheet.getRow(0);
        if (header == null || sheet.getLastRowNum() < 1) {
            throw new IllegalArgumentException("The Excel file is empty. Expected a header row (Name | Email | Phone) and at least one user row");
        }
        if (!hasExpectedHeader(header, formatter)) {
            throw new IllegalArgumentException("Invalid header row. First row must be: Name | Email | Phone");
        }
        if (sheet.getLastRowNum() > MAX_ROWS) {
            throw new IllegalArgumentException("Too many rows. Maximum is " + MAX_ROWS + " users per import");
        }

        Set<String> emailsInFile = new HashSet<>();

        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            String name = cellText(row, 0, formatter);
            String email = cellText(row, 1, formatter);
            String phone = cellText(row, 2, formatter);

            if (name.isEmpty() && email.isEmpty() && phone.isEmpty()) {
                continue;                                     // completely blank row: ignore
            }
            result.setTotalRows(result.getTotalRows() + 1);
            int excelRowNumber = i + 1;                       // POI rows start at 0; Excel shows 1

            List<String> problems = ValidationUtil.validateUser(name, email, phone);
            if (!problems.isEmpty()) {
                result.setFailed(result.getFailed() + 1);
                result.getErrors().add("Row " + excelRowNumber + ": " + String.join(", ", problems));
                continue;
            }

            String cleanEmail = email.toLowerCase(Locale.ROOT);
            if (!emailsInFile.add(cleanEmail)) {              // add() returns false if it was already there
                result.setDuplicates(result.getDuplicates() + 1);
                result.getDuplicateEmails().add(cleanEmail);
                continue;
            }
            validUsers.add(new User(name, cleanEmail, DEFAULT_PASSWORD,
                    ValidationUtil.normalizePhone(phone), "USER"));
        }

        if (result.getTotalRows() == 0) {
            throw new IllegalArgumentException("The Excel file contains no user rows");
        }
    }

    private void saveNewUsers(ImportResult result, List<User> validUsers) throws SQLException {
        if (validUsers.isEmpty()) {
            return;
        }
        Set<String> existingEmails = userDAO.getAllEmails();
        List<User> toInsert = new ArrayList<>();
        for (User user : validUsers) {
            if (existingEmails.contains(user.getEmail())) {
                result.setDuplicates(result.getDuplicates() + 1);
                result.getDuplicateEmails().add(user.getEmail());
            } else {
                toInsert.add(user);
            }
        }
        userDAO.insertUsersBatch(toInsert);                   // one transaction; rolls back on failure
        result.setSuccessful(toInsert.size());
    }

    private boolean hasExpectedHeader(Row header, DataFormatter formatter) {
        return cellText(header, 0, formatter).equalsIgnoreCase("name")
                && cellText(header, 1, formatter).equalsIgnoreCase("email")
                && cellText(header, 2, formatter).equalsIgnoreCase("phone");
    }

    /** Safe cell read: missing row/cell gives "" instead of a NullPointerException. */
    private String cellText(Row row, int columnIndex, DataFormatter formatter) {
        if (row == null) {
            return "";
        }
        return formatter.formatCellValue(row.getCell(columnIndex)).trim();
    }
}
