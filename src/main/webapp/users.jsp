<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="title" value="Users"/>
    <jsp:param name="page" value="users"/>
</jsp:include>

<section class="users-page-header mb-4">
    <div>
        <p class="eyebrow mb-2">Administration</p>
        <h1 class="page-title mb-1">Users</h1>
        <p class="text-muted mb-0">Add, edit, remove and import the people who can sign in.</p>
    </div>

    <div class="page-actions">
        <a href="${pageContext.request.contextPath}/api/users/export"
           class="btn btn-outline-success" id="downloadExcelBtn">
            <span class="btn-icon">↓</span>
            Download Excel
        </a>

        <button id="importBtn" type="button" class="btn btn-outline-ink"
                data-bs-toggle="modal" data-bs-target="#importModal">
            Import Excel
        </button>

        <button id="addUserBtn" type="button" class="btn btn-ink">
            <span class="btn-plus">+</span>
            Add user
        </button>
    </div>
</section>

<div id="pageAlert"></div>

<div class="card users-card">
    <div class="card-toolbar">
        <div class="toolbar-title">
            <strong>User directory</strong>
            <span id="userCount">0</span>
        </div>

        <div class="search-box">
            <svg viewBox="0 0 24 24" aria-hidden="true">
                <circle cx="11" cy="11" r="6.5"/>
                <path d="m16 16 4 4"/>
            </svg>
            <input type="search" id="userSearch" class="form-control search-input"
                   placeholder="Search name, email or phone" autocomplete="off">
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover align-middle users-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Role</th>
                    <th class="text-end">Actions</th>
                </tr>
            </thead>
            <tbody id="usersTableBody">
                <tr>
                    <td colspan="6" class="text-center text-muted py-5">Loading...</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<div class="modal fade" id="userModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <form id="userForm" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="userModalTitle">Add user</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body">
                <div id="modalAlert"></div>
                <input type="hidden" id="userId">

                <div class="mb-3">
                    <label for="userName" class="form-label">Name</label>
                    <input type="text" class="form-control" id="userName" maxlength="100" required>
                </div>

                <div class="mb-3">
                    <label for="userEmail" class="form-label">Email</label>
                    <input type="email" class="form-control" id="userEmail" maxlength="100" required>
                </div>

                <div class="mb-3" id="passwordGroup">
                    <label for="userPassword" class="form-label">Password</label>
                    <input type="password" class="form-control" id="userPassword"
                           minlength="6" autocomplete="new-password">
                    <div class="form-text">
                        Minimum 6 characters. The user can change it after signing in.
                    </div>
                </div>

                <div class="mb-3">
                    <label for="userPhone" class="form-label">Phone</label>
                    <input type="text" class="form-control" id="userPhone" maxlength="20">
                </div>

                <div class="mb-1">
                    <label for="userRole" class="form-label">Role</label>
                    <select class="form-select" id="userRole">
                        <option value="USER">User - can only see their own details</option>
                        <option value="ADMIN">Administrator - can manage all users</option>
                    </select>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline-ink" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn btn-ink">Save</button>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="importModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <form id="importForm" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Import users from Excel</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body">
                <p class="text-muted">
                    Upload an <strong>.xlsx</strong> file. The first row must be:
                    <code>Name | Email | Phone</code>.
                    Do not include an ID column.
                    Imported users get the default password
                    <code>Welcome@123</code> and the User role.
                </p>

                <div id="importAlert"></div>
                <input type="file" class="form-control mb-3" id="excelFile" accept=".xlsx">
                <div id="importResult"></div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline-ink" data-bs-dismiss="modal">Close</button>
                <button type="submit" id="importSubmitBtn" class="btn btn-ink">
                    Upload &amp; import
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/includes/footer.jsp"/>
