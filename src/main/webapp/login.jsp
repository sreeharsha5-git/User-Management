<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1">

    <title>Sign in - User Management</title>

    <!-- Google Font -->
    <link rel="preconnect"
          href="https://fonts.googleapis.com">

    <link rel="preconnect"
          href="https://fonts.gstatic.com"
          crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <!-- Existing CSS -->
    <link href="${pageContext.request.contextPath}/css/style.css"
          rel="stylesheet">


    <style>

        /* =========================================================
           LOGIN PAGE
        ========================================================= */

        * {
            box-sizing: border-box;
        }

        body[data-page="login"] {

            min-height: 100vh;

            margin: 0;

            font-family: "Inter", sans-serif;

            background:
                radial-gradient(
                    circle at 10% 20%,
                    rgba(59, 130, 246, 0.14),
                    transparent 30%
                ),

                radial-gradient(
                    circle at 90% 80%,
                    rgba(99, 102, 241, 0.14),
                    transparent 30%
                ),

                linear-gradient(
                    135deg,
                    #f8fafc 0%,
                    #eef4ff 100%
                );

            color: #0f172a;

            overflow-x: hidden;
        }


        /* =========================================================
           MAIN WRAPPER
        ========================================================= */

        .auth-wrap {

            min-height: 100vh;

            width: 100%;

            display: grid;

            grid-template-columns: 1fr 1fr;

            overflow: hidden;
        }


        /* =========================================================
           LEFT BRAND SECTION
        ========================================================= */

        .auth-brand {

            min-height: 100vh;

            padding: 55px 70px;

            display: flex;

            flex-direction: column;

            justify-content: space-between;

            position: relative;

            overflow: hidden;

            color: white;

            background:
                radial-gradient(
                    circle at 20% 20%,
                    rgba(96, 165, 250, 0.28),
                    transparent 30%
                ),

                radial-gradient(
                    circle at 80% 80%,
                    rgba(129, 140, 248, 0.22),
                    transparent 35%
                ),

                linear-gradient(
                    145deg,
                    #0f172a,
                    #172554,
                    #1e3a8a
                );

            animation:
                brandReveal
                0.8s
                cubic-bezier(.22, 1, .36, 1)
                both;
        }


        /* Decorative circles */

        .auth-brand::before {

            content: "";

            position: absolute;

            width: 350px;

            height: 350px;

            border-radius: 50%;

            border: 1px solid rgba(255,255,255,0.08);

            top: -120px;

            right: -100px;
        }


        .auth-brand::after {

            content: "";

            position: absolute;

            width: 450px;

            height: 450px;

            border-radius: 50%;

            border: 1px solid rgba(255,255,255,0.06);

            bottom: -250px;

            left: -180px;
        }


        /* =========================================================
           BRAND
        ========================================================= */

        .brand {

            display: flex;

            align-items: center;

            gap: 12px;

            font-size: 17px;

            font-weight: 700;

            position: relative;

            z-index: 2;
        }


        .brand-mark {

            width: 44px;

            height: 44px;

            display: inline-flex;

            align-items: center;

            justify-content: center;

            border-radius: 14px;

            color: white;

            font-size: 16px;

            font-weight: 800;

            background:
                linear-gradient(
                    135deg,
                    #3b82f6,
                    #6366f1
                );

            box-shadow:
                0 10px 25px rgba(37, 99, 235, 0.30);

            transition:
                transform 0.3s ease,
                box-shadow 0.3s ease;
        }


        .brand:hover .brand-mark {

            transform:
                rotate(-5deg)
                scale(1.08);

            box-shadow:
                0 15px 35px rgba(59,130,246,0.40);
        }


        /* =========================================================
           BRAND CONTENT
        ========================================================= */

        .auth-brand > div:nth-child(2) {

            position: relative;

            z-index: 2;

            max-width: 520px;
        }


        .auth-headline {

            font-size: clamp(38px, 4vw, 62px);

            line-height: 1.05;

            font-weight: 800;

            letter-spacing: -2.5px;

            margin-bottom: 22px;

            color: white;

            animation:
                textReveal
                0.8s
                ease
                0.35s
                both;
        }


        .auth-copy {

            max-width: 480px;

            font-size: 16px;

            line-height: 1.7;

            color: rgba(255,255,255,0.68);

            margin: 0;

            animation:
                textReveal
                0.8s
                ease
                0.5s
                both;
        }


        .auth-foot {

            position: relative;

            z-index: 2;

            font-size: 13px;

            color: rgba(255,255,255,0.45);

            animation:
                fadeIn
                0.8s
                ease
                0.8s
                both;
        }


        /* =========================================================
           RIGHT LOGIN SECTION
        ========================================================= */

        .auth-panel {

            min-height: 100vh;

            display: flex;

            align-items: center;

            justify-content: center;

            padding: 40px;

            position: relative;

            animation:
                panelReveal
                0.8s
                cubic-bezier(.22, 1, .36, 1)
                0.1s
                both;
        }


        /* =========================================================
           LOGIN CARD
        ========================================================= */

        .auth-card {

            width: 100%;

            max-width: 440px;

            padding: 42px;

            border-radius: 26px;

            background:
                rgba(255,255,255,0.88);

            border:
                1px solid rgba(255,255,255,0.90);

            box-shadow:
                0 25px 70px rgba(15,23,42,0.12),
                0 5px 20px rgba(59,130,246,0.06);

            backdrop-filter: blur(20px);

            -webkit-backdrop-filter: blur(20px);

            position: relative;

            overflow: hidden;

            animation:
                cardReveal
                0.9s
                cubic-bezier(.22, 1, .36, 1)
                0.2s
                both;

            transition:
                transform 0.35s ease,
                box-shadow 0.35s ease;
        }


        /* Top gradient line */

        .auth-card::before {

            content: "";

            position: absolute;

            top: 0;

            left: 0;

            right: 0;

            height: 4px;

            background:
                linear-gradient(
                    90deg,
                    #2563eb,
                    #4f46e5,
                    #7c3aed
                );
        }


        .auth-card:hover {

            transform: translateY(-6px);

            box-shadow:
                0 35px 85px rgba(15,23,42,0.15),
                0 10px 30px rgba(59,130,246,0.10);
        }


        /* =========================================================
           LOGIN HEADING
        ========================================================= */

        .auth-card h2 {

            font-size: 32px;

            font-weight: 800;

            letter-spacing: -1.2px;

            color: #0f172a;

            margin-bottom: 8px !important;

            animation:
                textReveal
                0.7s
                ease
                0.35s
                both;
        }


        .auth-card > p {

            font-size: 14px;

            color: #64748b !important;

            line-height: 1.6;

            animation:
                textReveal
                0.7s
                ease
                0.45s
                both;
        }


        /* =========================================================
           FORM
        ========================================================= */

        #loginForm {

            animation:
                formReveal
                0.8s
                ease
                0.4s
                both;
        }


        /* =========================================================
           LABELS
        ========================================================= */

        #loginForm .form-label {

            display: block;

            font-size: 13px;

            font-weight: 600;

            color: #334155;

            margin-bottom: 8px;

            transition:
                color 0.2s ease;
        }


        /* =========================================================
           INPUTS
        ========================================================= */

        #loginForm .form-control {

            width: 100%;

            height: 56px;

            padding:
                0 17px;

            border:
                1.5px solid #dbe3ef !important;

            border-radius: 15px !important;

            background:
                rgba(248,250,252,0.85) !important;

            color: #0f172a !important;

            font-size: 15px;

            box-shadow: none;

            outline: none;

            transition:
                border-color 0.25s ease,
                box-shadow 0.25s ease,
                background 0.25s ease,
                transform 0.2s ease;
        }


        #loginForm .form-control::placeholder {

            color: #94a3b8;

            transition:
                color 0.2s ease;
        }


        #loginForm .form-control:hover {

            background: white !important;

            border-color: #b8c7dc !important;

            transform:
                translateY(-1px);
        }


        #loginForm .form-control:focus {

            background: white !important;

            border-color: #4f46e5 !important;

            box-shadow:
                0 0 0 4px rgba(79,70,229,0.10),
                0 8px 20px rgba(15,23,42,0.05) !important;

            transform:
                translateY(-1px);
        }


        #loginForm .form-control:focus::placeholder {

            color: #cbd5e1;
        }


        /* =========================================================
           LOGIN BUTTON
        ========================================================= */

        #loginBtn {

            width: 100%;

            height: 56px;

            margin-top: 4px;

            border: none !important;

            border-radius: 15px !important;

            position: relative;

            overflow: hidden;

            background:
                linear-gradient(
                    135deg,
                    #2563eb 0%,
                    #4f46e5 55%,
                    #6366f1 100%
                ) !important;

            color: white !important;

            font-size: 15px;

            font-weight: 700;

            letter-spacing: 0.1px;

            box-shadow:
                0 12px 28px rgba(37,99,235,0.25);

            transition:
                transform 0.25s ease,
                box-shadow 0.25s ease,
                filter 0.25s ease;
        }


        /* Button shine */

        #loginBtn::before {

            content: "";

            position: absolute;

            top: 0;

            left: -120%;

            width: 80%;

            height: 100%;

            background:
                linear-gradient(
                    90deg,
                    transparent,
                    rgba(255,255,255,0.22),
                    transparent
                );

            transform: skewX(-20deg);

            transition:
                left 0.6s ease;
        }


        #loginBtn:hover {

            transform:
                translateY(-3px);

            filter:
                brightness(1.06);

            box-shadow:
                0 17px 35px rgba(37,99,235,0.34);
        }


        #loginBtn:hover::before {

            left: 140%;
        }


        #loginBtn:active {

            transform:
                translateY(0)
                scale(0.98);

            box-shadow:
                0 7px 16px rgba(37,99,235,0.20);
        }


        /* Keep text above shine */

        #loginBtn {

            isolation: isolate;
        }


        #loginBtn::after {

            content: "";

            position: absolute;

            inset: 0;

            z-index: -1;
        }


        /* =========================================================
           ALERT
        ========================================================= */

        #loginAlert {

            border-radius: 13px;

            font-size: 14px;

            animation:
                alertReveal
                0.35s
                ease
                both;
        }


        /* =========================================================
           ANIMATIONS
        ========================================================= */

        @keyframes brandReveal {

            from {

                opacity: 0;

                transform:
                    translateX(-40px);
            }

            to {

                opacity: 1;

                transform:
                    translateX(0);
            }
        }


        @keyframes panelReveal {

            from {

                opacity: 0;

                transform:
                    translateX(40px);
            }

            to {

                opacity: 1;

                transform:
                    translateX(0);
            }
        }


        @keyframes cardReveal {

            from {

                opacity: 0;

                transform:
                    translateY(25px)
                    scale(0.97);
            }

            to {

                opacity: 1;

                transform:
                    translateY(0)
                    scale(1);
            }
        }


        @keyframes textReveal {

            from {

                opacity: 0;

                transform:
                    translateY(12px);
            }

            to {

                opacity: 1;

                transform:
                    translateY(0);
            }
        }


        @keyframes formReveal {

            from {

                opacity: 0;

                transform:
                    translateY(15px);
            }

            to {

                opacity: 1;

                transform:
                    translateY(0);
            }
        }


        @keyframes fadeIn {

            from {

                opacity: 0;
            }

            to {

                opacity: 1;
            }
        }


        @keyframes alertReveal {

            from {

                opacity: 0;

                transform:
                    translateY(-8px);
            }

            to {

                opacity: 1;

                transform:
                    translateY(0);
            }
        }


        /* =========================================================
           MOBILE
        ========================================================= */

        @media (max-width: 991px) {

            .auth-wrap {

                grid-template-columns: 1fr;
            }


            .auth-brand {

                display: none;
            }


            .auth-panel {

                min-height: 100vh;

                padding: 25px 18px;
            }


            .auth-card {

                max-width: 460px;

                padding: 35px 28px;

                border-radius: 22px;
            }


            .auth-card:hover {

                transform: none;
            }
        }


        @media (max-width: 480px) {

            .auth-panel {

                padding: 16px;
            }


            .auth-card {

                padding: 30px 22px;

                border-radius: 20px;
            }


            .auth-card h2 {

                font-size: 28px;
            }


            #loginForm .form-control,
            #loginBtn {

                height: 53px;
            }
        }


        /* =========================================================
           ACCESSIBILITY
        ========================================================= */

        @media (prefers-reduced-motion: reduce) {

            *,
            *::before,
            *::after {

                animation-duration: 0.01ms !important;

                animation-iteration-count: 1 !important;

                transition-duration: 0.01ms !important;
            }
        }

    </style>

</head>


<body
    data-page="login"
    data-context="${pageContext.request.contextPath}">


<div class="auth-wrap">


    <!-- =========================================================
         LEFT BRAND SECTION
    ========================================================= -->

    <aside class="auth-brand">

    <!-- Brand -->

    <div class="brand">

        <div class="login-logo">

            <img
                src="${pageContext.request.contextPath}/images/logo.png"
                class="login-brand-logo">

        </div>

        <span>
            User Management
        </span>

    </div>

        <!-- Main Content -->

        <div>

            <h1 class="auth-headline">
                Manage your people, simply.
            </h1>

            <p class="auth-copy">
                One secure place to add, organise and look after
                every account in your organisation.
            </p>

        </div>


        <!-- Footer -->

        <div class="auth-foot">

            &copy; User Management System

        </div>


    </aside>


    <!-- =========================================================
         LOGIN SECTION
    ========================================================= -->

    <section class="auth-panel">


        <div class="auth-card">


            <!-- Mobile Brand -->

            <div class="brand d-lg-none mb-4">

                <span class="brand-mark">
                    UM
                </span>

                <span>
                    User Management
                </span>

            </div>


            <!-- Heading -->

            <h2 class="mb-1">
                Sign in
            </h2>


            <p class="text-muted mb-4">
                Enter your email and password to continue.
            </p>


            <!-- Login Alert -->

            <div id="loginAlert"></div>


            <!-- =================================================
                 LOGIN FORM
            ================================================= -->

            <form
                id="loginForm"
                novalidate>


                <!-- Email -->

                <div class="mb-3">

                    <label
                        for="email"
                        class="form-label">

                        Email

                    </label>

                    <input
                        type="email"
                        class="form-control"
                        id="email"
                        placeholder="you@company.com"
                        autocomplete="username"
                        required
                        autofocus>

                </div>


                <!-- Password -->

                <div class="mb-4">

                    <label
                        for="password"
                        class="form-label">

                        Password

                    </label>

                    <input
                        type="password"
                        class="form-control"
                        id="password"
                        placeholder="Your password"
                        autocomplete="current-password"
                        required>

                </div>


                <!-- Submit -->

                <button
                    type="submit"
                    id="loginBtn"
                    class="btn btn-ink w-100 py-2">

                    Sign in

                </button>


            </form>


        </div>


    </section>


</div>


<!-- =========================================================
     SCRIPTS
========================================================= -->

<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script src="${pageContext.request.contextPath}/js/app.js"></script>


</body>

</html>