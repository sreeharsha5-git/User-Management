# User Management System

A traditional Java web application: **JSP + Bootstrap + jQuery (AJAX) → Jersey REST API → DAO/JDBC → MySQL**,
with **session-based security** and **bulk user import from Excel (Apache POI)**.

Built for a technical assessment. Deliberately simple: no Spring, Hibernate, JPA, React, JWT or Docker.

## Features

- Login / logout with an HTTP session (30 min inactivity timeout); `AuthFilter` protects pages **and** REST endpoints
- **Two roles with different screens**
  - **User:** a simple home screen - "Hello, name", their own details (name, email, phone), **change password**, sign out. They cannot see, add, edit or delete anyone else (API returns 403, `users.jsp` redirects to home).
  - **Admin:** everything above plus the **Users** page: user grid, **Add, Edit (incl. role), Delete**, search, and **Excel bulk import**
- Classic, clean UI (Bootstrap + custom CSS, Inter font): split-screen sign-in, minimal top bar, card layout, quiet table
- JSON error responses with proper HTTP status codes (400/401/403/404/409/415/500), no stack traces shown to users
- `PreparedStatement` everywhere (SQL-injection safe); transaction + rollback for bulk insert
- Safety rules: an admin cannot delete themselves or remove their own admin role; the admin role is re-checked in MySQL on every API call

### Who can do what

| Action | User | Admin |
|---|---|---|
| Sign in / sign out | yes | yes |
| See own details | yes | yes |
| Change own password | yes | yes |
| List / view other users | no (403) | yes |
| Add / edit / delete users, change roles | no (403) | yes |
| Import users from Excel | no (403) | yes |

## Technology stack

| Layer     | Technology |
|-----------|------------|
| Frontend  | JSP, HTML, Bootstrap 5 (CDN), jQuery 3 (CDN), AJAX |
| REST API  | Jersey 3.1 (JAX-RS, `jakarta.ws.rs`) + Jackson (JSON) + jersey-media-multipart |
| Backend   | Java 17+, Servlet Filter (`jakarta.servlet`), JDBC |
| Excel     | Apache POI 5.3 (`poi-ooxml`) |
| Database  | MySQL 8 (Connector/J 8.4) |
| Build     | Maven, WAR packaging |
| Server    | Apache Tomcat 11 (Jakarta EE 11 / Servlet 6.1) |

> Everything uses `jakarta.*` (Tomcat 10+). Nothing uses `javax.*`.

## Architecture

```
Browser
  │  JSP page + Bootstrap + jQuery
  ▼
AJAX (JSON, or multipart/form-data for the Excel file)
  ▼
AuthFilter  ── no session? → 401 JSON (API)  /  redirect to login.jsp (pages)
  ▼
Jersey REST API   (AuthResource, UserResource)
  ▼
ExcelImportService (only for /api/users/import, uses Apache POI)
  ▼
UserDAO  ──  PreparedStatement
  ▼
JDBC  ──►  MySQL (user_management.users)
```

```
src/main/java/com/harsha
├── config      DatabaseConnection (JDBC), JerseyConfig (@ApplicationPath("/api"))
├── model       User, ImportResult
├── dao         UserDAO              (all SQL lives here)
├── resource    AuthResource, UserResource   (REST endpoints)
├── service     ExcelImportService   (Apache POI + validation + duplicates)
├── filter      AuthFilter           (session check)
├── exception   ApiExceptionMapper, DuplicateEmailException
└── util        ValidationUtil, ApiResponse
src/main/webapp
├── login.jsp, home.jsp, users.jsp
├── WEB-INF/includes/header.jsp, footer.jsp, WEB-INF/web.xml
├── css/style.css
└── js/app.js            (loadUsers, saveUser, editUser, deleteUser, importUsers, loginUser ...)
```

## Database setup

1. Install MySQL 8 and make sure it is running.
2. Run the script:
   ```
   mysql -u root -p < database/schema.sql
   ```
   (or open `database/schema.sql` in MySQL Workbench and execute it)

```sql
CREATE DATABASE IF NOT EXISTS user_management;
USE user_management;

CREATE TABLE IF NOT EXISTS users (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    phone      VARCHAR(20),
    role       VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Test accounts created by the script:

| Role  | Email            | Password   |
|-------|------------------|------------|
| ADMIN | admin@gmail.com  | admin123   |
| USER  | user@gmail.com   | user123    |

## Configuration

Edit `src/main/resources/db.properties` and set your MySQL password:

```properties
db.url=jdbc:mysql://localhost:3306/user_management?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
db.user=root
db.password=YOUR_PASSWORD
```

`db.properties` is git-ignored so your password is never pushed; `db.properties.example` is the committed template.
Environment variables `DB_URL`, `DB_USER`, `DB_PASSWORD` override the file if set.

> Bootstrap and jQuery are loaded from a CDN, so the browser needs internet access.

## How to run (Eclipse + Tomcat 11)

Requirements: **JDK 17+**, **Maven**, **Tomcat 11**, **MySQL 8**, Eclipse IDE for Enterprise Java and Web Developers.

1. `File → Import → Maven → Existing Maven Projects` → select this folder.
2. Right-click the project → `Maven → Update Project` (Alt+F5) and tick *Force Update*.
3. Make sure Eclipse uses a JDK 17+ (`Window → Preferences → Java → Installed JREs`).
4. Add the server: `Window → Preferences → Server → Runtime Environments → Add → Apache Tomcat v11.0`
   (if v11.0 is missing, update Eclipse to a recent release, or use the command-line option below).
5. Right-click the project → `Run As → Run on Server` → pick Tomcat 11.
6. Open **http://localhost:8080/user-management/** (check the context path in the Eclipse *Servers* tab if the page is not found).

**Alternative without Eclipse server integration**

```
mvn clean package
copy target/user-management.war  →  <TOMCAT_HOME>/webapps/
<TOMCAT_HOME>/bin/startup.bat   (or startup.sh)
```
Then open http://localhost:8080/user-management/

## API endpoints

All endpoints except `POST /api/auth/login` need a logged-in session (otherwise `401`).
Everything under `/api/users` is **admin only** (normal users get `403`).

| Method | URL | Who | Purpose | Success | Errors |
|--------|-----|-----|---------|---------|--------|
| POST   | `/api/auth/login`  | public | body `{"email","password"}` | 200 | 400 missing fields, 401 wrong credentials |
| POST   | `/api/auth/logout` | any user | destroy session | 200 | |
| GET    | `/api/auth/me`     | any user | own details (id, name, email, phone, role) | 200 | 401 |
| POST   | `/api/auth/change-password` | any user | body `{"currentPassword","newPassword"}` - changes own password, session stays valid | 200 | 400 wrong current / too short / same as old |
| GET    | `/api/users`       | admin | list users | 200 | 403 |
| GET    | `/api/users/count` | admin | `{"count":n}` | 200 | 403 |
| GET    | `/api/users/{id}`  | admin | one user | 200 | 403, 404 |
| POST   | `/api/users`       | admin | create (`name,email,password,phone,role`) | 201 | 400 validation, 403, 409 duplicate email |
| PUT    | `/api/users/{id}`  | admin | update (`name,email,phone,role`) | 200 | 400, 403, 404, 409 |
| DELETE | `/api/users/{id}`  | admin | delete | 200 | 403 (not admin / own account), 404 |
| POST   | `/api/users/import`| admin | multipart, part name `file` (`.xlsx`) | 200 + summary | 400 bad/empty file, 403, 415 wrong type |

Import response:

```json
{
  "success": true,
  "message": "Imported 3 of 8 rows (3 failed, 2 duplicates skipped)",
  "totalRows": 8, "successful": 3, "failed": 3, "duplicates": 2,
  "errors": ["Row 4: Email is invalid", "Row 7: Name is required", "Row 8: Phone is invalid (7-15 digits, optional leading +)"],
  "duplicateEmails": ["anil@gmail.com", "admin@gmail.com"]
}
```

## Excel format

| Name   | Email            | Phone      |
|--------|------------------|------------|
| Harsha | harsha@gmail.com | 9876543210 |
| Rahul  | rahul@gmail.com  | 9876543211 |
| Priya  | priya@gmail.com  | 9876543212 |

- First sheet, row 1 = header exactly `Name | Email | Phone`. **No ID column** (MySQL generates ids).
- Name and Email required; email must look like an email; phone optional (7–15 digits, optional `+`).
- Blank rows are ignored. Maximum 1000 rows per import.
- Imported users get the default password `Welcome@123` and role `USER`.
- All rows that pass validation and are not duplicates are inserted in **one transaction**.

Ready-made files are in `sample-data/`:

| File | Purpose | Expected result |
|------|---------|-----------------|
| `sample-users.xlsx` | 3 valid users | 3 imported |
| `sample-users-with-errors.xlsx` | mix of good/bad rows | 8 rows: 3 imported, 3 failed (rows 4, 7, 8), 2 duplicates (in-file + existing admin) |
| `empty-users.xlsx` | header only | 400 "file is empty" |
| `not-an-excel.txt` | wrong type | 415 (rename it to `.xlsx` to get 400 "invalid or corrupted") |

## Testing checklist

**As admin** (`admin@gmail.com` / `admin123`):

1. Correct login -> Home page ("Hello, Admin", total users, Users menu visible). 2. Wrong password -> red error, stays on login page.
3. Users page: grid shows seeded users; Add user (try role User and Admin) -> appears in grid; Edit -> changes appear; Delete -> confirm -> removed. Search box filters the grid.
4. Duplicate email -> "already exists" (409). Bad email / empty name -> 400 message.
5. Your own Delete button is disabled; your own role dropdown is disabled when editing yourself.
6. Import `sample-users.xlsx` -> 3 imported **and the grid updates without a refresh**; import again -> 3 duplicates.
7. Import `sample-users-with-errors.xlsx`, `empty-users.xlsx`, `not-an-excel.txt` -> results as in the table below.
8. Change password on the Home page (wrong current password -> error; mismatch -> error; success -> still signed in). Sign out and sign in with the new password.

**As normal user** (`user@gmail.com` / `user123`):

9. Home shows only "Hello, Test User" + own details + Change password + Sign out. No Users menu, no total.
10. Open `/users.jsp` directly -> redirected to Home. Open `/api/users` -> `403` JSON. `POST /api/users/import` -> `403`.

**Security:**

11. Without logging in, open `/home.jsp`, `/users.jsp` (redirect to login) and `/api/users` (`401`).
12. Sign out, then Back button / open `/home.jsp` -> login page again.
13. `GET /api/users/9999` as admin -> 404 JSON.

Quick API checks with curl (cookie jar keeps the session):
```
curl -c c.txt -H "Content-Type: application/json" -d '{"email":"admin@gmail.com","password":"admin123"}' http://localhost:8080/user-management/api/auth/login
curl -b c.txt http://localhost:8080/user-management/api/users
curl -b c.txt -F "file=@sample-data/sample-users.xlsx" http://localhost:8080/user-management/api/users/import
```

## Known limitations

- Passwords are stored in **plain text** (explicitly acceptable for this assessment prototype).
- A new JDBC connection is opened per query (no connection pool).
- An admin cannot reset another user's password (users change their own); the session id is not rotated after a password change.
- No CSRF protection; no rate limiting / account lockout.
- Duplicate check for imports is "read existing emails, then insert"; the `UNIQUE` index remains the final safety net.
- Whole import is all-or-nothing for the valid rows (a DB failure rolls everything back).
- Whole file is read in memory (fine for ≤ 1000 rows).
- Bootstrap/jQuery come from a CDN (need internet).
- Not covered by automated tests.

## Production improvements

- Hash passwords with **BCrypt** (salted, slow) instead of plain text.
- Use a connection pool (Tomcat JDBC pool via JNDI `DataSource`, or HikariCP).
- HTTPS, `Secure`/`SameSite` session cookie, CSRF tokens, login throttling.
- Pagination / search / sorting for the user grid; async import for very large files.
- Proper role-based authorization on every endpoint; audit log.
- Unit tests (JUnit) for DAO/validation, integration tests for the REST API.
- Externalised configuration and CI build.
