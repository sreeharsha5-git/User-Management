<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="title" value="Home"/>
    <jsp:param name="page" value="home"/>
</jsp:include>

<section class="mb-5">
    <p class="eyebrow mb-2">Dashboard</p>
    <h1 class="hero-title">Hello, <span id="welcomeName">&nbsp;</span></h1>
    <p class="hero-sub" id="heroSub"></p>
</section>

<div id="pageAlert"></div>

<div class="row g-4">

    <%-- Visible to everyone: the logged-in person's OWN details --%>
    <div class="col-lg-7">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-label">Your details</div>
                <div class="detail-row"><span class="detail-label">Full name</span><span class="detail-value" id="dName">-</span></div>
                <div class="detail-row"><span class="detail-label">Email</span><span class="detail-value" id="dEmail">-</span></div>
                <div class="detail-row"><span class="detail-label">Phone</span><span class="detail-value" id="dPhone">-</span></div>
                <div class="detail-row"><span class="detail-label">Role</span><span class="detail-value"><span id="dRole" class="pill pill-user">-</span></span></div>
            </div>
        </div>
    </div>

    <div class="col-lg-5">
        <div class="card h-100">
            <div class="card-body d-flex flex-column">
                <div class="card-label">Security</div>
                <h5 class="fw-semibold mb-1">Password</h5>
                <p class="text-muted">Keep your account safe by using a strong password that you do not use anywhere else.</p>
                <div class="mt-auto">
                    <button id="changePasswordBtn" type="button" class="btn btn-ink">Change password</button>
                </div>
            </div>
        </div>
    </div>

    <%-- Administrators only --%>
    <div class="col-lg-4 admin-only role-hidden">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-label">Total users</div>
                <div class="stat-number" id="totalUsers">-</div>
            </div>
        </div>
    </div>
    <div class="col-lg-8 admin-only role-hidden">
        <div class="card h-100">
            <div class="card-body d-flex flex-column justify-content-center">
                <div class="card-label">Administration</div>
                <h5 class="fw-semibold mb-1">Manage users</h5>
                <p class="text-muted">Add people, update their details, remove accounts or import many users from an Excel file.</p>
                <div><a href="${pageContext.request.contextPath}/users.jsp" class="btn btn-outline-ink">Open user management</a></div>
            </div>
        </div>
    </div>
</div>

<!-- Change password modal -->
<div class="modal fade" id="passwordModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <form id="passwordForm" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Change password</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="passwordAlert"></div>
                <div class="mb-3">
                    <label for="currentPassword" class="form-label">Current password</label>
                    <input type="password" class="form-control" id="currentPassword" autocomplete="current-password" required>
                </div>
                <div class="mb-3">
                    <label for="newPassword" class="form-label">New password</label>
                    <input type="password" class="form-control" id="newPassword" minlength="6" autocomplete="new-password" required>
                    <div class="form-text">At least 6 characters.</div>
                </div>
                <div class="mb-1">
                    <label for="confirmPassword" class="form-label">Confirm new password</label>
                    <input type="password" class="form-control" id="confirmPassword" minlength="6" autocomplete="new-password" required>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-ink" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" id="passwordSubmitBtn" class="btn btn-ink">Update password</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/includes/footer.jsp"/>
