<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        * { box-sizing: border-box; }

        html, body {
            width: 100%;
            min-height: 100%;
            margin: 0;
        }

        body {
            min-height: 100vh;
            display: grid;
            place-items: center;
            overflow: hidden;
            background:
                radial-gradient(circle at 20% 20%, rgba(59,130,246,.20), transparent 32%),
                radial-gradient(circle at 80% 80%, rgba(124,58,237,.18), transparent 32%),
                #061328;
            color: #fff;
            font-family: Inter, system-ui, sans-serif;
        }

        .splash {
            width: min(420px, calc(100% - 40px));
            text-align: center;
            animation: splashIn .9s cubic-bezier(.2,.8,.2,1) both;
        }

        .logo-wrap {
            width: 112px;
            height: 112px;
            margin: 0 auto 28px;
            position: relative;
            display: grid;
            place-items: center;
        }

        .logo-ring {
            position: absolute;
            inset: 0;
            border: 1px solid rgba(255,255,255,.16);
            border-radius: 32px;
            animation: ringPulse 2s ease-in-out infinite;
        }

        .logo {
            width: 82px;
            height: 82px;
            display: grid;
            place-items: center;
            border-radius: 24px;
            background: linear-gradient(135deg, #3b82f6, #6366f1 55%, #8b5cf6);
            font-size: 24px;
            font-weight: 800;
            letter-spacing: .03em;
            box-shadow: 0 24px 70px rgba(59,130,246,.32);
            animation: logoFloat 2s ease-in-out infinite;
        }

        h1 {
            margin: 0;
            font-size: clamp(25px, 6vw, 34px);
            letter-spacing: -.04em;
        }

        p {
            margin: 10px 0 0;
            color: #94a3b8;
            font-size: 14px;
        }

        .loading {
            width: min(280px, 100%);
            margin: 30px auto 0;
        }

        .loading-label {
            display: flex;
            justify-content: space-between;
            margin-bottom: 9px;
            color: #64748b;
            font-size: 11px;
        }

        .progress {
            height: 5px;
            overflow: hidden;
            border-radius: 99px;
            background: rgba(255,255,255,.09);
        }

        .progress span {
            display: block;
            width: 0;
            height: 100%;
            border-radius: inherit;
            background: linear-gradient(90deg, #3b82f6, #8b5cf6);
            animation: progress 2.1s linear forwards;
        }

        .dots {
            display: flex;
            justify-content: center;
            gap: 5px;
            margin-top: 17px;
        }

        .dots span {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            background: #64748b;
            animation: dot 1.1s ease-in-out infinite;
        }

        .dots span:nth-child(2) { animation-delay: .15s; }
        .dots span:nth-child(3) { animation-delay: .30s; }

        body.exit .splash {
            animation: splashOut .55s ease forwards;
        }

        @keyframes splashIn {
            from { opacity: 0; transform: translateY(18px) scale(.97); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        @keyframes splashOut {
            to { opacity: 0; transform: translateY(-12px) scale(.98); }
        }

        @keyframes logoFloat {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-7px); }
        }

        @keyframes ringPulse {
            0%, 100% { transform: scale(.96); opacity: .45; }
            50% { transform: scale(1.08); opacity: 1; }
        }

        @keyframes progress {
            to { width: 100%; }
        }

        @keyframes dot {
            0%, 100% { opacity: .3; transform: translateY(0); }
            50% { opacity: 1; transform: translateY(-3px); }
        }

        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after {
                animation-duration: .01ms !important;
                animation-iteration-count: 1 !important;
            }
        }
    </style>
</head>

<body>
<div class="splash">
    <div class="logo-wrap">
        <div class="logo-ring"></div>
        <div class="logo">UM</div>
    </div>

    <h1>User Management</h1>
    <p>Manage your people, simply.</p>

    <div class="loading">
        <div class="loading-label">
            <span>Preparing workspace</span>
            <span>100%</span>
        </div>
        <div class="progress"><span></span></div>
    </div>

    <div class="dots">
        <span></span><span></span><span></span>
    </div>
</div>

<script>
    window.setTimeout(function () {
        document.body.classList.add('exit');

        window.setTimeout(function () {
            window.location.href = 'login.jsp';
        }, 500);
    }, 2200);
</script>
</body>
</html>
