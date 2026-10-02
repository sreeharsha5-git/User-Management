<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="title" value="Dashboard"/>
    <jsp:param name="page" value="home"/>
</jsp:include>

<section class="dashboard-hero mb-4">
    <div>
        <p class="eyebrow mb-2">Dashboard</p>
        <h1 class="hero-title">Hello, <span id="welcomeName">there</span></h1>
        <p class="hero-sub mb-0" id="heroSub">Loading your account...</p>
    </div>
    <div class="hero-status">
        <span class="status-dot"></span>
        <span>Account active</span>
    </div>
</section>

<div id="pageAlert"></div>

<div class="row g-4">
    <div class="col-12 col-xl-7">
        <div class="card dashboard-card h-100">
            <div class="card-body">
                <div class="card-label">Your details</div>

                <div class="detail-row">
                    <span class="detail-label">Full name</span>
                    <span class="detail-value" id="dName">-</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Email</span>
                    <span class="detail-value detail-email" id="dEmail">-</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Phone</span>
                    <span class="detail-value" id="dPhone">-</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Role</span>
                    <span class="detail-value">
                        <span id="dRole" class="pill pill-user">-</span>
                    </span>
                </div>
            </div>
        </div>
    </div>

    <div class="col-12 col-xl-5">
        <div class="card dashboard-card security-card h-100">
            <div class="card-body">
                <div class="card-label">Security</div>
                <div class="security-icon">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <rect x="5" y="10" width="14" height="10" rx="2"/>
                        <path d="M8 10V7a4 4 0 0 1 8 0v3"/>
                    </svg>
                </div>
                <h5 class="fw-semibold mb-1">Password</h5>
                <p class="text-muted">Keep your account safe by using a strong password that you do not use anywhere else.</p>
                <button id="changePasswordBtn" type="button" class="btn btn-ink mt-2">
                    Change password
                </button>
            </div>
        </div>
    </div>

    <div class="col-12 col-md-4 admin-only role-hidden">
        <div class="card dashboard-card stat-card h-100">
            <div class="card-body">
                <div class="stat-icon blue">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="9" cy="8" r="3"/>
                        <path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6"/>
                        <circle cx="17" cy="9" r="2.3"/>
                    </svg>
                </div>
                <div class="card-label">Total users</div>
                <div class="stat-number" id="totalUsers">-</div>
                <span class="stat-caption">Registered accounts</span>
            </div>
        </div>
    </div>

    <div class="col-12 col-md-8 admin-only role-hidden">
        <div class="card dashboard-card admin-card h-100">
            <div class="card-body d-flex flex-column justify-content-center">
                <div class="card-label">Administration</div>
                <h5 class="fw-semibold mb-1">Manage users</h5>
                <p class="text-muted">
                    Add people, update their details, remove accounts or import many users from an Excel file.
                </p>
                <div>
                    <a href="${pageContext.request.contextPath}/users.jsp" class="btn btn-outline-ink">
                        Open user management
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

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
                    <input type="password" class="form-control" id="currentPassword"
                           autocomplete="current-password" required>
                </div>

                <div class="mb-3">
                    <label for="newPassword" class="form-label">New password</label>
                    <input type="password" class="form-control" id="newPassword"
                           minlength="6" autocomplete="new-password" required>
                    <div class="form-text">At least 6 characters.</div>
                </div>

                <div class="mb-1">
                    <label for="confirmPassword" class="form-label">Confirm new password</label>
                    <input type="password" class="form-control" id="confirmPassword"
                           minlength="6" autocomplete="new-password" required>
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
