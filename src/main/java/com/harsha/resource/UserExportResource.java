package com.harsha.resource;

import com.harsha.dao.UserDAO;
import com.harsha.model.User;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.ByteArrayOutputStream;
import java.util.List;

@Path("/users")
public class UserExportResource {

    private final UserDAO userDAO = new UserDAO();

    @GET
    @Path("/export")
    @Produces("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    public Response exportUsers() {

        try {
            List<User> users = userDAO.getAllRegularUsers();

            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Users");

            // Header style
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            // Header row
            Row header = sheet.createRow(0);

            String[] columns = {
                "ID",
                "Name",
                "Email",
                "Phone",
                "Role"
            };

            for (int i = 0; i < columns.length; i++) {
                Cell cell = header.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
            }

            // Data rows
            int rowIndex = 1;

            for (User user : users) {

                Row row = sheet.createRow(rowIndex++);

                row.createCell(0).setCellValue(user.getId());
                row.createCell(1).setCellValue(user.getName());
                row.createCell(2).setCellValue(user.getEmail());
                row.createCell(3).setCellValue(user.getPhone());
                row.createCell(4).setCellValue(user.getRole());
            }

            // Adjust column widths
            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            ByteArrayOutputStream outputStream =
                    new ByteArrayOutputStream();

            workbook.write(outputStream);
            workbook.close();

            byte[] excelFile = outputStream.toByteArray();

            return Response.ok(excelFile)
                    .type("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                    .header(
                        "Content-Disposition",
                        "attachment; filename=\"users.xlsx\""
                    )
                    .build();

        } catch (Exception e) {

            e.printStackTrace();

            return Response.serverError()
                    .entity("Failed to generate Excel file")
                    .type(MediaType.TEXT_PLAIN)
                    .build();
        }
    }
}