<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${param.title} - User Management</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
</head>
<body data-page="${param.page}" data-context="${pageContext.request.contextPath}">

<header class="topbar">
    <div class="container topbar-inner">
        <a class="brand" href="${pageContext.request.contextPath}/home.jsp">
            <span class="brand-mark">UM</span>
            <span>User Management</span>
        </a>

        <%-- Navigation is for administrators only; normal users just see their own page --%>
        <nav class="topnav admin-only role-hidden">
            <a class="topnav-link ${param.page == 'home' ? 'active' : ''}" href="${pageContext.request.contextPath}/home.jsp">Home</a>
            <a class="topnav-link ${param.page == 'users' ? 'active' : ''}" href="${pageContext.request.contextPath}/users.jsp">Users</a>
        </nav>

        <div class="topbar-right">
            <span class="avatar" id="navAvatar">&nbsp;</span>
            <span class="topbar-name d-none d-md-inline" id="navUserName"></span>
            <button id="logoutBtn" type="button" class="btn btn-ghost btn-sm">Sign out</button>
        </div>
    </div>
</header>

<main class="container page">
