<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>

</main>
<!-- /.page -->

</div>
<!-- /.app-shell -->


<!-- ============================================================
     JQUERY
     ============================================================ -->

<script
    src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js">
</script>


<!-- ============================================================
     BOOTSTRAP
     ============================================================ -->

<script
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js">
</script>


<!-- ============================================================
     APPLICATION JAVASCRIPT
     ============================================================ -->

<script
    src="${pageContext.request.contextPath}/js/app.js">
</script>


<!-- ============================================================
     SIDEBAR ONLY
     
     Dropdown functionality is handled directly inside header.jsp.
     ============================================================ -->

<script>

document.addEventListener("DOMContentLoaded", function () {

    /* ============================================================
       SIDEBAR
       ============================================================ */

    const sidebar =
        document.getElementById("appSidebar");

    const sidebarOverlay =
        document.getElementById("sidebarOverlay");

    const menuToggle =
        document.getElementById("menuToggle");

    const sidebarClose =
        document.getElementById("sidebarClose");


    function openSidebar() {

        if (!sidebar) {
            return;
        }

        sidebar.classList.add("sidebar-open");

        if (sidebarOverlay) {
            sidebarOverlay.classList.add("overlay-visible");
        }

        document.body.classList.add("menu-open");
    }


    function closeSidebar() {

        if (!sidebar) {
            return;
        }

        sidebar.classList.remove("sidebar-open");

        if (sidebarOverlay) {
            sidebarOverlay.classList.remove("overlay-visible");
        }

        document.body.classList.remove("menu-open");
    }


    /* Open sidebar */

    if (menuToggle) {

        menuToggle.addEventListener(
            "click",
            function (event) {

                event.preventDefault();
                event.stopPropagation();

                openSidebar();

            }
        );

    }


    /* Close sidebar */

    if (sidebarClose) {

        sidebarClose.addEventListener(
            "click",
            function () {

                closeSidebar();

            }
        );

    }


    /* Overlay */

    if (sidebarOverlay) {

        sidebarOverlay.addEventListener(
            "click",
            function () {

                closeSidebar();

            }
        );

    }


    /* Close after navigation */

    document
        .querySelectorAll(".sidebar-link")
        .forEach(function (link) {

            link.addEventListener(
                "click",
                function () {

                    closeSidebar();

                }
            );

        });


    /* Close sidebar on desktop */

    window.addEventListener(
        "resize",
        function () {

            if (window.innerWidth >= 992) {

                closeSidebar();

            }

        }
    );

});

</script>


</body>

</html>