<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sign in - User Management</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
</head>
<body data-page="login" data-context="${pageContext.request.contextPath}">

<div class="auth-wrap">

    <aside class="auth-brand">
        <div class="brand"><span class="brand-mark">UM</span><span>User Management</span></div>
        <div>
            <h1 class="auth-headline">Manage your people, simply.</h1>
            <p class="auth-copy">One secure place to add, organise and look after every account in your organisation.</p>
        </div>
        <div class="auth-foot">&copy; User Management System</div>
    </aside>

    <section class="auth-panel">
        <div class="auth-card">
            <div class="brand d-lg-none mb-4"><span class="brand-mark">UM</span><span>User Management</span></div>

            <h2 class="mb-1">Sign in</h2>
            <p class="text-muted mb-4">Enter your email and password to continue.</p>

            <div id="loginAlert"></div>

            <form id="loginForm" novalidate>
                <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" class="form-control" id="email" placeholder="you@company.com" autocomplete="username" required autofocus>
                </div>
                <div class="mb-4">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" class="form-control" id="password" placeholder="Your password" autocomplete="current-password" required>
                </div>
                <button type="submit" id="loginBtn" class="btn btn-ink w-100 py-2">Sign in</button>
            </form>
        </div>
    </section>
</div>

<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
