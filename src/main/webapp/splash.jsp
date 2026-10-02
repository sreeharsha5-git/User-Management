<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Management</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: #0f172a;
            font-family: Arial, sans-serif;
            color: white;
            overflow: hidden;
        }

        .splash {
            text-align: center;
            animation: fadeIn 1.5s ease;
        }

        .logo {
            width: 90px;
            height: 90px;
            margin: auto;
            border-radius: 24px;
            background: linear-gradient(135deg, #3b82f6, #60a5fa);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: bold;
            box-shadow: 0 15px 40px rgba(59, 130, 246, 0.35);
            animation: logoAnimation 1.4s ease infinite alternate;
        }

        h1 {
            margin-top: 25px;
            font-size: 28px;
        }

        p {
            color: #94a3b8;
            margin-top: 8px;
        }

        .loader {
            width: 40px;
            height: 40px;
            margin: 25px auto 0;
            border: 4px solid #334155;
            border-top-color: #3b82f6;
            border-radius: 50%;
            animation: spin 1.0s linear infinite;
        }

        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: scale(0.95);
            }

            to {
                opacity: 1;
                transform: scale(1);
            }
        }

        @keyframes logoAnimation {
            from {
                transform: scale(1);
            }

            to {
                transform: scale(1.08);
            }
        }
    </style>
</head>

<body>

<div class="splash">

    <div class="logo">
        UM
    </div>

    <h1>User Management</h1>

    <p>Manage your people, simply.</p>

    <div class="loader"></div>

</div>

<script>
    setTimeout(function () {
        window.location.href = "login.jsp";
    }, 2000);
</script>

</body>
</html>