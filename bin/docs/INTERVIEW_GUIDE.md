# Interview Preparation Guide — User Management System

Based on the code in this repository. Read it together with the source: every answer below points at a real class.

---

## A. 30-second explanation
"It's a User Management web application in traditional Java. The browser pages are JSP with Bootstrap and jQuery; they call a REST API built with Jersey using AJAX. The API uses a DAO with JDBC to read and write MySQL. Login creates an HTTP session, and a servlet Filter blocks anything that isn't logged in. The user grid supports add, update and delete, and an admin can bulk-import users from an Excel file, which I read with Apache POI, validate, and insert in one transaction. The grid then refreshes by AJAX without reloading the page."

## B. 1-minute explanation
Add: "Layers are separate: JSP/jQuery for UI, `UserResource`/`AuthResource` for REST, `ExcelImportService` for the Excel logic, `UserDAO` for SQL. I used `PreparedStatement` to avoid SQL injection. Errors come back as JSON with proper status codes — 400 validation, 401 not logged in, 403 not admin, 404 unknown id, 409 duplicate email, 415 wrong file type. Duplicates and invalid rows in the Excel file don't crash the import; they are counted and reported back. Passwords are plain text because the assessment allowed a prototype, and I know production needs BCrypt."

## C. Architecture
```
Browser (JSP + Bootstrap + jQuery) → AJAX → AuthFilter → Jersey (Resource) → [Service] → DAO → JDBC → MySQL
```
| Piece | Class / file | Job |
|---|---|---|
| UI | `login.jsp`, `home.jsp`, `users.jsp`, `js/app.js` | pages, jQuery events, AJAX calls, DOM updates |
| Security | `filter/AuthFilter` | blocks unauthenticated requests |
| REST | `resource/AuthResource`, `UserResource` | URLs, HTTP methods, status codes, JSON |
| Business logic | `service/ExcelImportService`, `util/ValidationUtil` | read Excel, validate, detect duplicates |
| Data access | `dao/UserDAO` | all SQL |
| Config | `config/JerseyConfig`, `DatabaseConnection` | register Jersey, open JDBC connections |
| Errors | `exception/ApiExceptionMapper` | exception → JSON + status code |

Why layers? Each class has one job, so SQL is never in JSP/JS, and I can change one layer without touching the others.

## D. Login flow
1. `login.jsp` form → `loginUser()` in `app.js` → `POST /api/auth/login` with JSON `{email,password}`.
2. `AuthFilter` lets `/api/auth/login` through (it's on the public list).
3. `AuthResource.login()` validates input → `UserDAO.findByEmail()` (`SELECT ... WHERE email = ?`).
4. Compares the password; same error message for unknown email and wrong password (don't reveal which).
5. Invalidates any old session, creates a new one (`request.getSession(true)`), stores the user (without password) as `session.setAttribute("user", user)`.
6. Response 200 → JS redirects to `home.jsp`. Tomcat sent a `JSESSIONID` cookie; the browser sends it on every later request.

**Logout:** `POST /api/auth/logout` → `session.invalidate()` → JS redirects to login. Old cookie no longer maps to a session, so the filter rejects it.

## E. CRUD flow (example: Add user)
Add User button → modal form → `saveUser()` → `POST /api/users` JSON → `UserResource.createUser()` → `ValidationUtil.validateUser()` → validates the role (USER or ADMIN, default USER) → `UserDAO.insertUser()` (`INSERT ... VALUES(?,?,?,?,?)`, reads the AUTO_INCREMENT id with `getGeneratedKeys`) → `201 Created` → JS closes modal, shows alert, calls `loadUsers()` → `GET /api/users` → table rebuilt.
- Update: `editUser(id)` does `GET /api/users/{id}` to fill the form; saving does `PUT /api/users/{id}`.
- Delete: `confirm()` → `DELETE /api/users/{id}`; `deleteUser` returns 404 if the id doesn't exist, 403 if you try to delete yourself.

## F. Excel import flow
`Import Excel` modal → `importUsers()` builds `FormData` with the file → `POST /api/users/import` (multipart) → `UserResource.importUsers()`:
1. `requireAdmin()` (else 403), file present (400), name ends with `.xlsx` (415);
2. `ExcelImportService.importUsers()` opens `XSSFWorkbook` (invalid file → 400), checks header `Name | Email | Phone`, max 1000 rows;
3. for each row: read cells with `DataFormatter`, skip fully blank rows, `ValidationUtil` → failed rows go into `errors` ("Row 4: Email is invalid"); duplicate emails inside the file go into `duplicateEmails`;
4. `UserDAO.getAllEmails()` → emails already in MySQL are also counted as duplicates;
5. `UserDAO.insertUsersBatch()` — one transaction: `setAutoCommit(false)` → `addBatch()` for each → `executeBatch()` → `commit()`; on `SQLException` → `rollback()`;
6. returns `ImportResult` JSON (`totalRows, successful, failed, duplicates, errors, duplicateEmails`);
7. JS shows the summary and calls `loadUsers()` → grid refreshes with no browser reload.

Invariant: `totalRows = successful + failed + duplicates`.

## G. Database explanation
One table `users`: `id INT PRIMARY KEY AUTO_INCREMENT`, `name`, `email UNIQUE NOT NULL`, `password`, `phone`, `role`, `created_at`.
- **AUTO_INCREMENT**: MySQL generates ids — that's why the Excel has no ID column.
- **UNIQUE on email**: the database itself guarantees no duplicate emails (last line of defence; the app also checks first).
- **NOT NULL** on required columns; `role` defaults to `'USER'`.

## H. SQL queries used
```sql
SELECT id, name, email, password, phone, role FROM users WHERE email = ?;      -- login
SELECT id, name, email, phone, role FROM users ORDER BY id;                    -- list
SELECT id, name, email, phone, role FROM users WHERE id = ?;                   -- one user
SELECT COUNT(*) FROM users;                                                    -- home page total
INSERT INTO users(name, email, password, phone, role) VALUES(?,?,?,?,?);       -- add / import
UPDATE users SET name = ?, email = ?, phone = ? WHERE id = ?;                  -- update
DELETE FROM users WHERE id = ?;                                                -- delete
SELECT email FROM users;                                                       -- duplicate check for import
```
Be ready to write: `SELECT * FROM users WHERE name LIKE 'A%'`, `SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1`, `ORDER BY created_at DESC LIMIT 5`, an `INNER JOIN` on a made-up `orders` table.

## I. Java questions
- **try-with-resources?** Auto-closes `AutoCloseable` resources (Connection, PreparedStatement, ResultSet, Workbook) even if an exception occurs. Used in every DAO method.
- **Checked vs unchecked exceptions?** `SQLException`, `IOException`, `DuplicateEmailException` are checked (must be declared/caught); `IllegalArgumentException` is unchecked. I use `IllegalArgumentException` for "bad Excel file".
- **Why a POJO `User` with getters/setters?** Encapsulation; Jackson uses them to map JSON ⇄ object.
- **`Set` vs `List`?** `HashSet` for emails: `contains()`/`add()` is O(1) and `add()` returns false for duplicates; `List` for ordered rows.
- **`static` block in `DatabaseConnection`?** Runs once when the class loads — loads the properties and the JDBC driver.
- **`final` class + private constructor** (`ValidationUtil`, `ApiResponse`)? Utility classes are not meant to be instantiated.
- **Why `equals()` for strings, not `==`?** `==` compares references.

## J. JDBC questions
- **What is JDBC?** Java API for talking to relational databases; the MySQL Connector/J jar is the driver.
- **Steps:** get `Connection` → create `PreparedStatement` → set parameters → `executeQuery()` / `executeUpdate()` → read `ResultSet` → close.
- **`Statement` vs `PreparedStatement`?** Prepared: precompiled, parameterised, safe from SQL injection, reusable. `Statement`: string concatenation — unsafe.
- **`ResultSet`?** A cursor over the rows returned by a query; `next()` moves to the next row; `getString("col")` reads a column.
- **`executeQuery` vs `executeUpdate`?** SELECT returns a `ResultSet`; INSERT/UPDATE/DELETE return the affected row count.
- **`getGeneratedKeys()`?** Returns the AUTO_INCREMENT id created by an INSERT.
- **Transaction?** A group of statements that succeed or fail together (ACID). `setAutoCommit(false)`, `commit()`, `rollback()` — used in `insertUsersBatch`.
- **Batch?** `addBatch()` + `executeBatch()` sends many inserts together; faster than one round-trip per row.
- **What if SQL fails?** `SQLException` → `ApiExceptionMapper` logs it and returns a generic 500 JSON; the user never sees SQL or a stack trace. A duplicate key becomes `DuplicateEmailException` → 409.
- **Why no connection pool?** Kept simple; production would use one (opening connections is expensive).
- **How does SQL reach MySQL?** `DriverManager.getConnection(url,user,pass)` opens a TCP connection to port 3306; the driver sends the SQL text + parameters; MySQL parses/executes and returns rows.

## K. JSP questions
- **What is JSP?** HTML with dynamic parts; Tomcat compiles each JSP into a servlet on first request.
- **Why no scriptlets?** Business logic doesn't belong in views. My JSPs only use EL (`${pageContext.request.contextPath}`, `${param.page}`) and `<jsp:include>`; data comes through AJAX.
- **JSP vs servlet?** A JSP *is* a servlet (generated); JSP is better for markup, servlets for logic.
- **`<jsp:include>` vs `<%@ include %>`?** `jsp:include` is dynamic (at request time, can pass `jsp:param`); the directive is static (merged at compile time). I use `jsp:include` for header/footer.
- **Why are header/footer in `WEB-INF`?** Files under `WEB-INF` can't be requested directly by the browser.
- **EL?** `${...}` expression language to read request/session/page data without Java code.
- **Honest note:** the JSPs are mostly static shells; the dynamic data is loaded by AJAX. Navbar name etc. is set with jQuery `.text()` so user-entered data can't inject HTML.

## L. Servlet questions
- **What is a servlet?** Java class that handles HTTP requests inside a container (Tomcat).
- **Lifecycle:** `init()` once → `service()/doGet()/doPost()` per request → `destroy()`.
- **Where are servlets in my app?** Jersey's `ServletContainer` is the servlet mapped to `/api/*` (registered automatically by `@ApplicationPath`); JSPs compile to servlets.
- **`jakarta.servlet` vs `javax.servlet`?** Java EE moved to the Eclipse Foundation → package renamed to `jakarta.*` from Jakarta EE 9. Tomcat 10+/11 only supports `jakarta.*`, so old `javax.*` code won't run.
- **Servlet vs filter?** Servlet produces the response; filter intercepts before/after a servlet.

## M. Session questions
- **What is a session?** Server-side storage for one user across many requests. HTTP is stateless, so a session id cookie (`JSESSIONID`) links requests to it.
- **How is it created?** `request.getSession(true)` in `AuthResource.login()`.
- **What's stored?** The `User` object (password removed) under the key `"user"`.
- **How is it checked?** `AuthFilter`: `request.getSession(false)` then `getAttribute("user") != null`.
- **Timeout?** 30 min inactivity (`web.xml` and `setMaxInactiveInterval`).
- **Logout?** `session.invalidate()`.
- **Session fixation?** After login I invalidate the old session and create a new id.
- **Session vs cookie vs JWT?** Cookie is stored in the browser; session data stays on the server; JWT is a self-contained signed token (not used here, per requirement).

## N. Filter questions
- **What is a filter?** `jakarta.servlet.Filter` that runs before the request reaches a servlet/JSP; it can continue (`chain.doFilter`) or stop (redirect / 401).
- **How is it mapped?** `@WebFilter(urlPatterns = "/*")` — every request.
- **Public resources?** `/login.jsp`, `/api/auth/login`, `/css/*`, `/js/*`, `/error.html`.
- **Why 401 JSON for API but redirect for pages?** AJAX callers need a status code; browsers navigating to a page need to land on the login page. `app.js` also handles a 401 by redirecting to login.
- **Why `no-store` headers?** After logout the Back button must not show a cached protected page.
- **Authentication vs authorization?** Authentication = who are you (login + filter). Authorization = what may you do (only ADMIN may call `/api/users/*` → `UserResource.requireAdmin()` returns 403; `AuthFilter` also redirects non-admins away from `users.jsp`).
- **Is hiding the Users menu / Import button security?** No — it's only UX (`role-hidden` CSS class removed by jQuery for admins); the real check is on the server in `requireAdmin()`.

## O. REST questions
- **What is REST?** Architectural style: resources identified by URLs (`/api/users/5`), operations via HTTP methods, stateless requests, usually JSON.
- **GET/POST/PUT/DELETE?** read / create / update / delete.
- **PUT vs POST?** POST creates (server picks id); PUT updates a known resource, idempotent.
- **Status codes I use:** 200, 201, 400, 401, 403, 404, 409, 415, 500 — each with a JSON `message`.
- **Is it truly stateless?** The API uses the HTTP session for login, so strictly it isn't; with JWT it would be. Acceptable here because the requirement says session-based security.
- **Why JSON?** Lightweight, native to JavaScript, easy for Jackson/jQuery.

## P. Jersey questions
- **What is Jersey?** The reference implementation of JAX-RS (`jakarta.ws.rs`), the Java standard for REST.
- **`@ApplicationPath("/api")`** (in `JerseyConfig`): base URL for all resources.
- **`@Path`** URL of class/method. **`@GET/@POST/@PUT/@DELETE`** HTTP method. **`@PathParam("id")`** value from the URL. **`@Consumes`** accepted request type. **`@Produces`** response type. **`@Context`** injects servlet objects (`HttpServletRequest`).
- **`@FormDataParam`** reads a part of a multipart request (from `jersey-media-multipart`; needs `MultiPartFeature`).
- **How does JSON conversion work?** `jersey-media-json-jackson` registers Jackson; return a `User`/`List<User>` → JSON, receive JSON → `User`.
- **`ExceptionMapper`?** Converts exceptions to responses in one place (`ApiExceptionMapper`).
- **Why `jersey-hk2`?** Jersey 3 needs a dependency-injection implementation at runtime.
- **Jersey 3.x vs 2.x?** 3.x uses `jakarta.*`, 2.x uses `javax.*`.
- **Why `/count` doesn't clash with `/{id}`?** Jersey prefers the literal path over the template.

## Q. AJAX questions
- **What is AJAX?** Asynchronous requests from JavaScript that update part of the page without reloading it.
- **Where used?** Login, load users, add, update, delete, import, current user, logout.
- **Why `contentType: 'application/json'` + `JSON.stringify`?** So Jersey/Jackson can parse the body.
- **Why `processData:false, contentType:false` for the file?** jQuery must not convert `FormData` to a query string, and the browser must set `multipart/form-data; boundary=...` itself.
- **`.done/.fail/.always`?** Promise-style success / error / finally callbacks.
- **What happens when the session expires?** API returns 401 → global `ajaxError` handler redirects to login.

## R. jQuery questions
- **What is jQuery?** Library that simplifies DOM selection/manipulation, events and AJAX.
- **`$(function(){...})`?** Runs when the DOM is ready.
- **Event delegation** (`$('#usersTableBody').on('click', '.btn-edit', ...)`): rows are created dynamically, so the handler is attached to the stable parent.
- **`.text()` vs `.html()`?** `.text()` escapes — I use it for all user data to prevent XSS.
- **Why `event.preventDefault()`?** Stops the browser's normal form submission/page reload so AJAX can handle it.
- **jQuery vs plain JS (`fetch`)?** The assessment requires jQuery; `fetch` is the modern native alternative.

## S. Bootstrap questions
- **What is Bootstrap?** CSS/JS component framework with a 12-column responsive grid.
- **Used for:** navbar, buttons, forms, table (`table-striped`, `table-responsive`), modals (add/edit, import), alerts (success/error messages), grid layout (`container`, `row`, `col-md-*`).
- **How are modals opened?** `data-bs-toggle="modal"` or `bootstrap.Modal.getOrCreateInstance(...).show()`.
- **Why CDN?** Simpler setup; downside is needing internet.

## T. MySQL questions
- Primary key vs unique key; why `email` is UNIQUE; what AUTO_INCREMENT does.
- `VARCHAR` vs `TEXT`; `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`.
- Index: the UNIQUE constraint creates an index, which makes `WHERE email = ?` fast.
- Transaction/ACID, `COMMIT`/`ROLLBACK`; `INNER JOIN` vs `LEFT JOIN`; `GROUP BY ... HAVING`.
- `DELETE` vs `TRUNCATE` vs `DROP`.
- What does error 1062 mean? Duplicate entry for a unique key → mapped to `DuplicateEmailException` → HTTP 409.

## U. Security questions
- **SQL injection:** attacker input like `' OR '1'='1` changes a concatenated query; prevented by `PreparedStatement` (parameters are data, not SQL).
- **XSS:** attacker stores `<script>` as a user name; prevented by inserting values with jQuery `.text()`.
- **Plain-text passwords:** a prototype shortcut — production uses BCrypt (salted, deliberately slow hash); never log or return passwords (`@JsonProperty(access = WRITE_ONLY)` hides the password in JSON).
- **Session security:** HttpOnly cookie, new session on login, timeout, invalidate on logout. Production adds HTTPS + `Secure`/`SameSite` cookies.
- **CSRF:** a malicious site could make the browser send authenticated requests; production would add CSRF tokens. Not implemented here (listed in limitations).
- **Role escalation:** only an admin can create users or set roles (`requireAdmin()` on every `/api/users` endpoint); a normal user gets 403. An admin cannot remove their own admin role or delete themselves, so the system never ends up with no admin.
- **File upload security:** extension check, max 1000 rows, POI parses data only (no macros in `.xlsx`), errors never exposed.
- **Brute force:** not handled → rate limiting / lockout in production.

## V. Scenario-based questions
- **A duplicate email is in the Excel file?** Counted as a duplicate and skipped; others still import.
- **Same email twice in the file?** First one is kept, the second is a duplicate.
- **Email already in the DB?** Detected via `getAllEmails()`; skipped. If two imports ran at the same instant, the UNIQUE index would still reject one and the transaction rolls back.
- **A row is malformed (bad email, missing name)?** Reported as `Row N: ...`; import continues.
- **Phone typed as a number in Excel?** `DataFormatter` reads it as text, so `9876543210` doesn't become `9.87654321E9`.
- **File is empty / not an Excel file / `.txt`?** 400 / 400 / 415 with a clear message.
- **Database goes down mid-request?** `SQLException` → 500 JSON "A database error occurred"; details only in the Tomcat log.
- **Import 100,000 rows?** Currently limited to 1000; for more: streaming POI (SAX), chunked batches, background job + progress.
- **Two admins edit the same user?** Last write wins; production could add a version column (optimistic locking).
- **User opens `/users.jsp` after the session expired?** Filter redirects to login.
- **How would you add pagination?** `LIMIT ? OFFSET ?` in the DAO, `page`/`size` query params, page controls in the UI.
- **How would you add a new field (address)?** Column in MySQL → `User` field → DAO SQL → validation → form + table column.
- **How would you test it?** Manual checklist in README; for automation JUnit for `ValidationUtil`, DAO tests against a test DB, REST tests with curl/Postman.

## W. "Why did you…?" questions
- **…use a DAO?** Keeps SQL in one place, easy to change/test, UI and REST don't know about JDBC.
- **…use JDBC and not Hibernate?** The assessment asked to focus on DB queries; JDBC shows I understand SQL, connections and transactions. (ORMs are a good next step in real projects.)
- **…use Jersey and not plain servlets?** Cleaner REST code with annotations, automatic JSON binding, easy status codes.
- **…use a Filter for security?** One central place that protects every page and API; no need to repeat session checks.
- **…put validation in `ValidationUtil`?** Same rules for manual add/update and Excel import — no duplication.
- **…read existing emails first instead of just catching errors?** Gives a precise duplicate report; the UNIQUE index is still the safety net.
- **…use a transaction for import?** All-or-nothing: the database never ends up half-imported after a failure.
- **…return a summary object?** The admin needs to know exactly which rows failed and why.
- **…use `Welcome@123` for imported users?** The `password` column is NOT NULL and the Excel has no password; documented, and production would send a reset link instead.
- **…make Import admin-only?** Bulk-creating accounts is a privileged action — shows authorization on top of authentication.
- **…use AJAX?** Better UX and demonstrates the required stack; only the changed part of the page updates.
- **…not use Spring?** Out of scope of the assessment; I wanted to show the fundamentals Spring builds on (servlets, filters, JDBC, sessions).
- **What would you improve next?** BCrypt, connection pool, pagination/search, CSRF, automated tests.

## X. Roles, profile and change-password flow (added feature)
- **Two roles:** `ADMIN` and `USER` (column `role`). The login response and `/api/auth/me` return the role; `app.js` shows/hides parts of the UI from it.
- **Normal user screen:** `home.jsp` shows "Hello, name", their own details (name, email, phone) from `GET /api/auth/me`, a Change password button and Sign out. The Users menu and total-users card carry the classes `admin-only role-hidden`, which jQuery only reveals for admins.
- **Why can't a user see other users?** Every method in `UserResource` starts with `requireAdmin()`. It reads the session user id, re-reads the role from MySQL, and returns 401 (account gone) or 403 (not admin). Re-reading from the database means demoting or deleting an admin takes effect immediately, not at next login.
- **`/api/auth/me`** reloads the user from MySQL and refreshes the session copy, so an admin's edits (name, phone, role) show up, and a deleted account is logged out.
- **Change password** (`POST /api/auth/change-password`): the user id comes from the **session**, never from the request, so nobody can change someone else's password. Steps: validate input -> `getPasswordById` -> compare with the current password (wrong -> 400, not 401, because the user IS logged in) -> new password must differ and be 6-100 chars -> `updatePassword` (`UPDATE users SET password = ? WHERE id = ?`). The session is kept, so the user stays signed in.
- **Session handling:** session cookie `JSESSIONID` (HttpOnly), 30 minutes inactivity; expiry -> 401 -> `ajaxError` handler redirects to login.
- **Likely questions:** Why re-check the role in the DB each call? (stale session data). Why 400 for wrong current password? (401 would make the UI think the session expired). Why must a user not be able to pass a user id to change-password? (privilege escalation / IDOR). What would you add for production? (BCrypt, rotate session id after password change, invalidate other sessions, admin password reset, password rules).

---

### Last-minute checklist before the interview
1. MySQL running, `schema.sql` executed, password set in `db.properties`.
2. Tomcat 11 starts; `http://localhost:8080/user-management/` shows login.
3. Log in as admin → import `sample-users.xlsx` → watch the grid update. Practise the walk-through: login → CRUD → import → code (`AuthFilter`, `UserDAO`, `ExcelImportService`).
4. Know where each requirement is in the code (use the tables above).
