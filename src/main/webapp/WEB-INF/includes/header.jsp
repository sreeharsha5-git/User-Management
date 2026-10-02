<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1">

    <title>
        ${param.title} - User Management
    </title>


    <!-- ============================================================
         GOOGLE FONT
         ============================================================ -->

    <link
        rel="preconnect"
        href="https://fonts.googleapis.com">

    <link
        rel="preconnect"
        href="https://fonts.gstatic.com"
        crossorigin>

    <link
        href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
        rel="stylesheet">


    <!-- ============================================================
         BOOTSTRAP
         ============================================================ -->

    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet">


    <!-- ============================================================
         APPLICATION CSS
         ============================================================ -->

    <link
        href="${pageContext.request.contextPath}/css/style.css"
        rel="stylesheet">


    <!-- ============================================================
         DIRECT TOPBAR DROPDOWN FIX
         ============================================================ -->

    <style>

        /*
         * These rules guarantee that the two menus are above
         * the rest of the dashboard when opened.
         */

        .notification-wrapper,
        .profile-dropdown {
            position: relative !important;
            z-index: 10000 !important;
        }

        .notification-menu,
        .profile-menu {
            z-index: 10001 !important;
            pointer-events: auto !important;
        }

        .notification-menu.show,
        .profile-menu.show {
            display: block !important;
            opacity: 1 !important;
            visibility: visible !important;
            pointer-events: auto !important;
            transform: translateY(0) !important;
        }

    </style>

</head>


<body
    data-page="${param.page}"
    data-context="${pageContext.request.contextPath}">


<!-- ================================================================
     MOBILE SIDEBAR OVERLAY
     ================================================================ -->

<div
    class="sidebar-overlay"
    id="sidebarOverlay">
</div>


<!-- ================================================================
     SIDEBAR
     ================================================================ -->

<aside
    class="app-sidebar"
    id="appSidebar">


    <!-- ============================================================
         SIDEBAR BRAND
         ============================================================ -->

    <div class="sidebar-brand">

        <a
            href="${pageContext.request.contextPath}/home.jsp"
            class="sidebar-brand-link">

           <span class="brand-mark logo-container">

    <img
        src="${pageContext.request.contextPath}/images/logo.png"
        alt="User Management Logo"
        class="brand-logo">
            </span>

            <span class="brand-text">

                <strong>
                    User
                </strong>

                <span>
                    Management
                </span>

            </span>

        </a>


        <!-- Mobile close button -->

        <button
            type="button"
            class="sidebar-close d-lg-none"
            id="sidebarClose"
            aria-label="Close navigation">

            ×

        </button>

    </div>


    <!-- ============================================================
         SIDEBAR NAVIGATION
         ============================================================ -->

    <nav class="sidebar-nav">


        <!-- Dashboard -->

        <a
            href="${pageContext.request.contextPath}/home.jsp"
            class="sidebar-link ${param.page == 'home' ? 'active' : ''}">

            <span class="sidebar-icon">

                <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true">

                    <path
                        d="M3 10.5 12 3l9 7.5"/>

                    <path
                        d="M5.5 9.5V21h13V9.5"/>

                    <path
                        d="M9.5 21v-6h5v6"/>

                </svg>

            </span>


            <span>
                Dashboard
            </span>

        </a>


        <!-- ========================================================
             USERS
             Admin only
             ======================================================== -->

        <a
            href="${pageContext.request.contextPath}/users.jsp"
            class="sidebar-link admin-only role-hidden ${param.page == 'users' ? 'active' : ''}">

            <span class="sidebar-icon">

                <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true">

                    <circle
                        cx="9"
                        cy="8"
                        r="3"/>

                    <path
                        d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6"/>

                    <circle
                        cx="17"
                        cy="9"
                        r="2.3"/>

                    <path
                        d="M16 14.5c2.8.3 5 2.6 5 5.5"/>

                </svg>

            </span>


            <span>
                Users
            </span>

        </a>

    </nav>


    <!-- ============================================================
         SIDEBAR BOTTOM
         ============================================================ -->

    <div class="sidebar-bottom">

        <div class="sidebar-divider"></div>


        <!-- Existing logout button -->

        <button
            type="button"
            id="logoutBtn"
            class="sidebar-logout">

            <span class="sidebar-icon">

                <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true">

                    <path
                        d="M10 5H5v14h5"/>

                    <path
                        d="m14 8 4 4-4 4"/>

                    <path
                        d="M18 12H9"/>

                </svg>

            </span>


            <span>
                Sign out
            </span>

        </button>

    </div>

</aside>


<!-- ================================================================
     APPLICATION SHELL
     ================================================================ -->

<div class="app-shell">


    <!-- ============================================================
         TOP BAR
         ============================================================ -->

    <header class="app-topbar">


        <!-- ========================================================
             LEFT SIDE
             ======================================================== -->

        <div class="topbar-left">


            <!-- Mobile hamburger -->

            <button
                type="button"
                class="menu-toggle"
                id="menuToggle"
                aria-label="Open navigation">

                <span></span>
                <span></span>
                <span></span>

            </button>


            <!-- Mobile page title -->

            <div class="mobile-page-title">
                ${param.title}
            </div>

        </div>


        <!-- ========================================================
             SEARCH
             ======================================================== -->


        <!-- ========================================================
             TOP RIGHT
             ======================================================== -->

        <div class="topbar-right">


            <!-- ====================================================
                 NOTIFICATIONS
                 ==================================================== -->

            <div
                class="notification-wrapper"
                id="notificationWrapper">


                <!-- Notification button -->

                <button
                    type="button"
                    class="notification-btn"
                    id="notificationBtn"
                    aria-label="Notifications"
                    aria-expanded="false"
                    onclick="toggleNotifications(event)">


                    <svg
                        viewBox="0 0 24 24"
                        aria-hidden="true">

                        <path
                            d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"/>

                        <path
                            d="M10 21h4"/>

                    </svg>


                    <!-- Red unread indicator -->

                    <span
                        class="notification-dot"
                        id="notificationDot">
                    </span>

                </button>


                <!-- =================================================
                     NOTIFICATION DROPDOWN
                     ================================================= -->

                <div
                    class="notification-menu"
                    id="notificationMenu">


                    <!-- Notification header -->

                    <div class="notification-header">

                        <div>

                            <strong>
                                Notifications
                            </strong>

                            <span>
                                Recent account activity
                            </span>

                        </div>


                        <span
                            class="notification-count"
                            id="notificationCount">

                            2

                        </span>

                    </div>


                    <!-- Notification list -->

                    <div class="notification-list">


                        <!-- Notification 1 -->

                        <div class="notification-item">

                            <div
                                class="notification-item-icon notification-blue">

                                <svg
                                    viewBox="0 0 24 24"
                                    aria-hidden="true">

                                    <path
                                        d="M12 3a7 7 0 0 0-7 7c0 4-2 5-2 7h18c0-2-2-3-2-7a7 7 0 0 0-7-7"/>

                                    <path
                                        d="M9 21h6"/>

                                </svg>

                            </div>


                            <div class="notification-content">

                                <strong>
                                    Welcome back
                                </strong>

                                <span>
                                    You're signed in successfully.
                                </span>

                                <small>
                                    Just now
                                </small>

                            </div>

                        </div>


                        <!-- Notification 2 -->

                        <div class="notification-item">

                            <div
                                class="notification-item-icon notification-green">

                                <svg
                                    viewBox="0 0 24 24"
                                    aria-hidden="true">

                                    <path
                                        d="m5 12 4 4L19 6"/>

                                </svg>

                            </div>


                            <div class="notification-content">

                                <strong>
                                    Account active
                                </strong>

                                <span>
                                    Your session is active and secure.
                                </span>

                                <small>
                                    Today
                                </small>

                            </div>

                        </div>

                    </div>


                    <!-- Notification footer -->

                    <div class="notification-footer">

                        <button
                            type="button"
                            id="markNotificationsRead"
                            onclick="markNotificationsAsRead(event)">

                            Mark all as read

                        </button>

                    </div>

                </div>

            </div>


            <!-- ====================================================
                 PROFILE
                 ==================================================== -->

            <div
                class="profile-dropdown"
                id="profileDropdown">


                <!-- =================================================
                     PROFILE TRIGGER
                     ================================================= -->

                <button
                    type="button"
                    class="profile-trigger"
                    id="profileTrigger"
                    aria-expanded="false"
                    aria-haspopup="true"
                    onclick="toggleProfile(event)">


                    <!-- Avatar -->

                    <span
                        class="avatar"
                        id="navAvatar">

                        &nbsp;

                    </span>


                    <!-- User information -->

                    <span
                        class="user-menu-info d-none d-md-flex">


                        <span
                            class="topbar-name"
                            id="navUserName">

                        </span>


                        <span
                            class="topbar-role"
                            id="navUserRole">

                            Administrator

                        </span>


                    </span>


                    <!-- Chevron -->

                    <span
                        class="user-menu-chevron d-none d-md-inline">

                        <svg
                            viewBox="0 0 24 24"
                            aria-hidden="true">

                            <path
                                d="m6 9 6 6 6-6"/>

                        </svg>

                    </span>

                </button>


                <!-- =================================================
                     PROFILE DROPDOWN
                     ================================================= -->

                <div
                    class="profile-menu"
                    id="profileMenu">


                    <!-- Profile header -->

                    <div
                        class="profile-menu-header">

                        <span
                            class="profile-menu-avatar"
                            id="profileMenuAvatar">

                            S

                        </span>


                        <div>

                            <strong
                                id="profileMenuName">

                                Sree Harsha

                            </strong>


                            <span
                                id="profileMenuRole">

                                Administrator

                            </span>

                        </div>

                    </div>


                    <!-- Divider -->

                    <div
                        class="profile-menu-divider">
                    </div>


                    <!-- =================================================
                         MY PROFILE
                         ================================================= -->

                    <button
    type="button"
    class="profile-menu-item"
    id="profileBtn"
    onclick="goToProfile(event)">


                        <span
                            class="profile-menu-icon">

                            <svg
                                viewBox="0 0 24 24"
                                aria-hidden="true">

                                <circle
                                    cx="12"
                                    cy="8"
                                    r="3"/>

                                <path
                                    d="M5 20c0-3.9 3.1-7 7-7s7 3.1 7 7"/>

                            </svg>

                        </span>


                        <span>
                            My profile
                        </span>

                    </button>


                    <!-- =================================================
                         ACCOUNT SETTINGS
                         ================================================= -->

                 <!--  <button
                        type="button"
                        class="profile-menu-item"
                        id="accountSettingsBtn"
                        onclick="profileAction(event, 'settings')">


                        <span
                            class="profile-menu-icon">

                            <svg
                                viewBox="0 0 24 24"
                                aria-hidden="true">

                                <circle
                                    cx="12"
                                    cy="12"
                                    r="3"/>

                                <path
                                    d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1-1.8 1.8-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.6V20h-2.6v-.1a1.7 1.7 0 0 0-1-1.6 1.7 1.7 0 0 0-1.9.3l-.1.1-1.8-1.8.1-.1a1.7 1.7 0 0 0 .3-1.9 1.7 1.7 0 0 0-1.6-1H6v-2.6h.1a1.7 1.7 0 0 0 1.6-1 1.7 1.7 0 0 0-.3-1.9l-.1-.1 1.8-1.8.1.1a1.7 1.7 0 0 0 1.9.3 1.7 1.7 0 0 0 1-1.6V5h2.6v.1a1.7 1.7 0 0 0 1 1.6 1.7 1.7 0 0 0 1.9-.3l.1-.1 1.8 1.8-.1.1a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.6 1h.1v2.6h-.1a1.7 1.7 0 0 0-1.6 1z"/>

                            </svg>

                        </span>


                        <span>
                            Account settings
                        </span>

                    </button> -->   


                    <!-- Divider -->

                    <div
                        class="profile-menu-divider">
                    </div>


                    <!-- =================================================
                         SIGN OUT
                         ================================================= -->

                    <button
                        type="button"
                        class="profile-menu-item profile-menu-danger"
                        id="profileLogoutBtn"
                        onclick="profileLogout(event)">


                        <span
                            class="profile-menu-icon">

                            <svg
                                viewBox="0 0 24 24"
                                aria-hidden="true">

                                <path
                                    d="M10 5H5v14h5"/>

                                <path
                                    d="m14 8 4 4-4 4"/>

                                <path
                                    d="M18 12H9"/>

                            </svg>

                        </span>


                        <span>
                            Sign out
                        </span>

                    </button>

                </div>

            </div>

        </div>

    </header>


    <!-- ============================================================
         DIRECT DROPDOWN JAVASCRIPT
         ============================================================ -->

    <script>

        /*
         * ============================================================
         * NOTIFICATION MENU
         * ============================================================
         */

        function toggleNotifications(event) {

            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }

            const notificationMenu =
                document.getElementById("notificationMenu");

            const profileMenu =
                document.getElementById("profileMenu");

            const notificationButton =
                document.getElementById("notificationBtn");

            if (!notificationMenu) {
                console.error(
                    "ERROR: #notificationMenu was not found."
                );
                return;
            }


            /*
             * Close profile menu first.
             */

            if (profileMenu) {

                profileMenu.classList.remove("show");

                profileMenu.style.display = "none";
                profileMenu.style.opacity = "0";
                profileMenu.style.visibility = "hidden";

            }


            /*
             * Toggle notification menu.
             */

            const isOpening =
                !notificationMenu.classList.contains("show");


            if (isOpening) {

                notificationMenu.classList.add("show");

                notificationMenu.style.display = "block";
                notificationMenu.style.opacity = "1";
                notificationMenu.style.visibility = "visible";
                notificationMenu.style.pointerEvents = "auto";
                notificationMenu.style.transform =
                    "translateY(0)";

                if (notificationButton) {

                    notificationButton.setAttribute(
                        "aria-expanded",
                        "true"
                    );

                }

            } else {

                notificationMenu.classList.remove("show");

                notificationMenu.style.opacity = "0";
                notificationMenu.style.visibility = "hidden";

                if (notificationButton) {

                    notificationButton.setAttribute(
                        "aria-expanded",
                        "false"
                    );

                }

            }

        }


        /*
         * ============================================================
         * PROFILE MENU
         * ============================================================
         */

        function toggleProfile(event) {

            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }

            const profileMenu =
                document.getElementById("profileMenu");

            const notificationMenu =
                document.getElementById("notificationMenu");

            const profileButton =
                document.getElementById("profileTrigger");

            if (!profileMenu) {

                console.error(
                    "ERROR: #profileMenu was not found."
                );

                return;
            }


            /*
             * Close notification menu first.
             */

            if (notificationMenu) {

                notificationMenu.classList.remove("show");

                notificationMenu.style.display = "none";
                notificationMenu.style.opacity = "0";
                notificationMenu.style.visibility = "hidden";

            }


            /*
             * Toggle profile menu.
             */

            const isOpening =
                !profileMenu.classList.contains("show");


            if (isOpening) {

                profileMenu.classList.add("show");

                profileMenu.style.display = "block";
                profileMenu.style.opacity = "1";
                profileMenu.style.visibility = "visible";
                profileMenu.style.pointerEvents = "auto";
                profileMenu.style.transform =
                    "translateY(0)";

                if (profileButton) {

                    profileButton.setAttribute(
                        "aria-expanded",
                        "true"
                    );

                }

            } else {

                profileMenu.classList.remove("show");

                profileMenu.style.opacity = "0";
                profileMenu.style.visibility = "hidden";

                if (profileButton) {

                    profileButton.setAttribute(
                        "aria-expanded",
                        "false"
                    );

                }

            }

        }


        /*
         * ============================================================
         * MARK NOTIFICATIONS AS READ
         * ============================================================
         */

        function markNotificationsAsRead(event) {

            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }

            const dot =
                document.getElementById("notificationDot");

            const count =
                document.getElementById("notificationCount");

            if (dot) {
                dot.style.display = "none";
            }

            if (count) {
                count.textContent = "0";
            }

        }


        /*
         * ============================================================
         * PROFILE ACTIONS
         * ============================================================
         */

         function goToProfile(event) {

        	    if (event) {
        	        event.preventDefault();
        	        event.stopPropagation();
        	    }

        	    window.location.href =
        	        "${pageContext.request.contextPath}/home.jsp";
        	}


        /*
         * ============================================================
         * PROFILE LOGOUT
         * ============================================================
         */

        function profileLogout(event) {

            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }

            const profileMenu =
                document.getElementById("profileMenu");

            if (profileMenu) {

                profileMenu.classList.remove("show");

                profileMenu.style.opacity = "0";
                profileMenu.style.visibility = "hidden";

            }


            /*
             * Use the existing logout button.
             * app.js already owns the actual logout API call.
             */

            const logoutButton =
                document.getElementById("logoutBtn");

            if (logoutButton) {

                logoutButton.click();

            } else {

                console.error(
                    "ERROR: #logoutBtn was not found."
                );

            }

        }


        /*
         * ============================================================
         * CLICK OUTSIDE
         * ============================================================
         */

        document.addEventListener(
            "click",
            function (event) {

                const profileMenu =
                    document.getElementById("profileMenu");

                const notificationMenu =
                    document.getElementById("notificationMenu");

                const profileButton =
                    document.getElementById("profileTrigger");

                const notificationButton =
                    document.getElementById("notificationBtn");


                /*
                 * PROFILE
                 */

                if (
                    profileMenu &&
                    profileButton &&
                    !profileMenu.contains(event.target) &&
                    !profileButton.contains(event.target)
                ) {

                    profileMenu.classList.remove("show");

                    profileMenu.style.opacity = "0";
                    profileMenu.style.visibility = "hidden";

                    profileButton.setAttribute(
                        "aria-expanded",
                        "false"
                    );

                }


                /*
                 * NOTIFICATIONS
                 */

                if (
                    notificationMenu &&
                    notificationButton &&
                    !notificationMenu.contains(event.target) &&
                    !notificationButton.contains(event.target)
                ) {

                    notificationMenu.classList.remove("show");

                    notificationMenu.style.opacity = "0";
                    notificationMenu.style.visibility = "hidden";

                    notificationButton.setAttribute(
                        "aria-expanded",
                        "false"
                    );

                }

            }
        );


        /*
         * ============================================================
         * ESCAPE KEY
         * ============================================================
         */

        document.addEventListener(
            "keydown",
            function (event) {

                if (event.key !== "Escape") {
                    return;
                }


                const profileMenu =
                    document.getElementById("profileMenu");

                const notificationMenu =
                    document.getElementById("notificationMenu");


                if (profileMenu) {

                    profileMenu.classList.remove("show");

                    profileMenu.style.opacity = "0";
                    profileMenu.style.visibility = "hidden";

                }


                if (notificationMenu) {

                    notificationMenu.classList.remove("show");

                    notificationMenu.style.opacity = "0";
                    notificationMenu.style.visibility = "hidden";

                }

            }
        );

    </script>


    <!-- ============================================================
         PAGE CONTENT STARTS HERE
         ============================================================ -->

    <main class="page">