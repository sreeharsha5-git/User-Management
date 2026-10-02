/* ==========================================================================
   USER MANAGEMENT SYSTEM - CLIENT SIDE
   jQuery + AJAX
   ========================================================================== */

var CONTEXT = $('body').data('context') || '';
var API = CONTEXT + '/api';
var currentUser = null;

/* --------------------------------------------------------------------------
   Helpers
   -------------------------------------------------------------------------- */

function showAlert(selector, type, message) {
    var $alert = $('<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert"></div>');
    $alert.append(document.createTextNode(message));
    $alert.append('<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>');
    $(selector).empty().append($alert);
}

function errorMessage(xhr) {
    if (xhr.responseJSON && xhr.responseJSON.message) {
        return xhr.responseJSON.message;
    }

    if (xhr.status === 0) {
        return 'Cannot reach the server. Is the application running?';
    }

    return 'Unexpected error (HTTP ' + xhr.status + ').';
}

function apiJson(method, path, data) {
    return $.ajax({
        url: API + path,
        method: method,
        contentType: 'application/json; charset=UTF-8',
        dataType: 'json',
        data: data ? JSON.stringify(data) : undefined
    });
}

function isAdmin() {
    return currentUser !== null && currentUser.role === 'ADMIN';
}

function initialOf(name) {
    return name ? name.trim().charAt(0).toUpperCase() : '?';
}

/* --------------------------------------------------------------------------
   Client-side notifications
   These are UI notifications stored in localStorage. They do not require a
   backend notifications table.
   -------------------------------------------------------------------------- */

function notificationStorageKey() {
    return 'um_notifications_' + (currentUser && currentUser.id ? currentUser.id : 'guest');
}

function getNotifications() {
    try {
        return JSON.parse(localStorage.getItem(notificationStorageKey()) || '[]');
    } catch (e) {
        return [];
    }
}

function saveNotifications(items) {
    localStorage.setItem(notificationStorageKey(), JSON.stringify(items.slice(0, 30)));
}

function addNotification(title, message, type) {
    if (!currentUser) return;

    var items = getNotifications();

    items.unshift({
        id: Date.now() + Math.random(),
        title: title,
        message: message,
        type: type || 'blue',
        time: new Date().toISOString(),
        read: false
    });

    saveNotifications(items);
    renderNotifications();
}

function addWelcomeNotification() {
    if (!currentUser) return;

    var items = getNotifications();
    var todayKey = new Date().toISOString().slice(0, 10);
    var alreadyExists = items.some(function (item) {
        return item.type === 'welcome' && item.time && item.time.slice(0, 10) === todayKey;
    });

    if (!alreadyExists) {
        items.unshift({
            id: Date.now() + Math.random(),
            title: 'Welcome back',
            message: 'You signed in successfully.',
            type: 'blue',
            time: new Date().toISOString(),
            read: false,
            welcome: true
        });
        saveNotifications(items);
    }
}

function relativeTime(iso) {
    var time = new Date(iso).getTime();
    var diff = Math.max(0, Date.now() - time);
    var seconds = Math.floor(diff / 1000);

    if (seconds < 60) return 'Just now';

    var minutes = Math.floor(seconds / 60);
    if (minutes < 60) return minutes + (minutes === 1 ? ' minute ago' : ' minutes ago');

    var hours = Math.floor(minutes / 60);
    if (hours < 24) return hours + (hours === 1 ? ' hour ago' : ' hours ago');

    var days = Math.floor(hours / 24);
    return days + (days === 1 ? ' day ago' : ' days ago');
}

function notificationIcon(type) {
    if (type === 'green') {
        return '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m5 12 4 4L19 6"/></svg>';
    }

    if (type === 'red') {
        return '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3v10"/><path d="M12 17v.1"/><circle cx="12" cy="12" r="9"/></svg>';
    }

    if (type === 'purple') {
        return '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16v14H4z"/><path d="M8 9h8M8 13h5"/></svg>';
    }

    return '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"/><path d="M10 21h4"/></svg>';
}

function renderNotifications() {
    var $list = $('#notificationList');
    if (!$list.length) return;

    var items = getNotifications();
    var unread = items.filter(function (item) { return !item.read; }).length;

    $('#notificationCount').text(unread);
    $('#notificationDot').toggle(unread > 0);

    $list.empty();

    if (!items.length) {
        $list.append(
            '<div class="notification-empty">' +
                '<div class="notification-empty-icon">✓</div>' +
                '<strong>You\'re all caught up</strong>' +
                '<span>No new notifications.</span>' +
            '</div>'
        );
        return;
    }

    items.slice(0, 8).forEach(function (item) {
        var $item = $('<div class="notification-item"></div>');
        if (!item.read) $item.addClass('unread');

        var $icon = $('<div class="notification-item-icon"></div>')
            .addClass('notification-' + (item.type || 'blue'))
            .html(notificationIcon(item.type));

        var $content = $('<div class="notification-content"></div>');
        $('<strong></strong>').text(item.title).appendTo($content);
        $('<span></span>').text(item.message).appendTo($content);
        $('<small></small>').text(relativeTime(item.time)).appendTo($content);

        $item.append($icon).append($content);
        $list.append($item);
    });
}

function markNotificationsRead() {
    var items = getNotifications();
    items.forEach(function (item) { item.read = true; });
    saveNotifications(items);
    renderNotifications();
}

/* --------------------------------------------------------------------------
   Global session handling
   -------------------------------------------------------------------------- */

$(document).ajaxError(function (event, xhr, settings) {
    var url = settings.url || '';
    var isAuthCall = url.indexOf('/auth/login') !== -1 ||
                     url.indexOf('/auth/logout') !== -1;

    if (xhr.status === 401 && !isAuthCall) {
        window.location.href = CONTEXT + '/login.jsp';
    }
});

/* --------------------------------------------------------------------------
   Login / logout
   -------------------------------------------------------------------------- */

function loginUser(event) {
    event.preventDefault();

    var $button = $('#loginBtn').prop('disabled', true);

    apiJson('POST', '/auth/login', {
        email: $('#email').val().trim(),
        password: $('#password').val()
    }).done(function () {
        window.location.href = CONTEXT + '/home.jsp';
    }).fail(function (xhr) {
        showAlert('#loginAlert', 'danger', errorMessage(xhr));
        $button.prop('disabled', false);
    });
}

function logoutUser() {
    apiJson('POST', '/auth/logout').always(function () {
        window.location.href = CONTEXT + '/login.jsp';
    });
}

/* --------------------------------------------------------------------------
   Current user / profile
   -------------------------------------------------------------------------- */

function syncProfileUI() {
    if (!currentUser) return;

    var initial = initialOf(currentUser.name);
    var roleText = currentUser.role === 'ADMIN' ? 'Administrator' : 'User';

    $('#navUserName').text(currentUser.name);
    $('#navAvatar').text(initial);
    $('#navUserRole').text(roleText);

    $('#profileMenuAvatar').text(initial);
    $('#profileMenuName').text(currentUser.name);
    $('#profileMenuRole').text(roleText);

    if (isAdmin()) {
        $('.admin-only').removeClass('role-hidden');
    } else {
        $('.admin-only').addClass('role-hidden');
    }
}

function loadCurrentUser() {
    return apiJson('GET', '/auth/me').done(function (user) {
        currentUser = user;
        syncProfileUI();
        addWelcomeNotification();
        renderNotifications();
    });
}

/* --------------------------------------------------------------------------
   Home
   -------------------------------------------------------------------------- */

function loadHome() {
    $('#welcomeName').text(currentUser.name);
    $('#dName').text(currentUser.name);
    $('#dEmail').text(currentUser.email);
    $('#dPhone').text(currentUser.phone || 'Not provided');

    $('#dRole')
        .text(isAdmin() ? 'Administrator' : 'User')
        .removeClass('pill-admin pill-user')
        .addClass(isAdmin() ? 'pill-admin' : 'pill-user');

    $('#heroSub').text(
        isAdmin()
            ? 'You have administrator access. Here is an overview of your workspace.'
            : 'Here are your account details.'
    );

    if (isAdmin()) {
        apiJson('GET', '/users/count').done(function (result) {
            $('#totalUsers').text(result.count);
        });
    }
}

function openPasswordModal() {
    $('#passwordForm')[0].reset();
    $('#passwordAlert').empty();
    bootstrap.Modal.getOrCreateInstance('#passwordModal').show();
}

function changePassword(event) {
    event.preventDefault();

    var current = $('#currentPassword').val();
    var next = $('#newPassword').val();
    var repeat = $('#confirmPassword').val();

    if (next !== repeat) {
        showAlert('#passwordAlert', 'danger',
            'The new password and its confirmation do not match.');
        return;
    }

    var $button = $('#passwordSubmitBtn').prop('disabled', true);

    apiJson('POST', '/auth/change-password', {
        currentPassword: current,
        newPassword: next
    }).done(function () {
        bootstrap.Modal.getOrCreateInstance('#passwordModal').hide();

        addNotification(
            'Password updated',
            'Your account password was changed successfully.',
            'green'
        );

        showAlert('#pageAlert', 'success',
            'Your password was changed successfully. You are still signed in.');
    }).fail(function (xhr) {
        showAlert('#passwordAlert', 'danger', errorMessage(xhr));
    }).always(function () {
        $button.prop('disabled', false);
    });
}

/* --------------------------------------------------------------------------
   Users
   -------------------------------------------------------------------------- */

function loadUsers() {
    return apiJson('GET', '/users').done(function (users) {
        var $body = $('#usersTableBody').empty();

        $('#userCount').text(users.length);

        if (users.length === 0) {
            $body.append(
                '<tr><td colspan="6" class="text-center text-muted py-5">' +
                'No users found</td></tr>'
            );
            return;
        }

        $.each(users, function (index, user) {
            var isSelf = currentUser && user.id === currentUser.id;
            var $row = $('<tr></tr>');

            $('<td class="cell-muted"></td>')
                .attr('data-label', 'ID')
                .text(user.id)
                .appendTo($row);

            $('<td class="cell-strong"></td>')
                .attr('data-label', 'Name')
                .text(user.name)
                .appendTo($row);

            $('<td></td>')
                .attr('data-label', 'Email')
                .text(user.email)
                .appendTo($row);

            $('<td class="cell-muted"></td>')
                .attr('data-label', 'Phone')
                .text(user.phone || '-')
                .appendTo($row);

            var $pill = $('<span class="pill"></span>')
                .addClass(user.role === 'ADMIN' ? 'pill-admin' : 'pill-user')
                .text(user.role === 'ADMIN' ? 'Admin' : 'User');

            $('<td></td>')
                .attr('data-label', 'Role')
                .append($pill)
                .appendTo($row);

            var $actions = $('<td class="text-end text-nowrap table-actions"></td>')
                .attr('data-label', 'Actions');

            $('<button type="button" class="btn btn-sm btn-quiet btn-edit">Edit</button>')
                .attr('data-id', user.id)
                .appendTo($actions);

            var $delete = $('<button type="button" class="btn btn-sm btn-quiet-danger btn-delete ms-1">Delete</button>')
                .attr('data-id', user.id);

            if (isSelf) {
                $delete
                    .prop('disabled', true)
                    .attr('title', 'You cannot delete your own account');
            }

            $actions.append($delete);
            $row.append($actions);
            $body.append($row);
        });

        applySearch();
    }).fail(function (xhr) {
        showAlert('#pageAlert', 'danger',
            'Could not load users: ' + errorMessage(xhr));
    });
}

function applySearch() {
    var query = ($('#userSearch').val() || '').toLowerCase().trim();

    $('#usersTableBody tr').each(function () {
        $(this).toggle(
            query === '' ||
            $(this).text().toLowerCase().indexOf(query) !== -1
        );
    });
}
/* ----------------------- NAVBAR SEARCH ----------------------- */

$('#globalSearch').on('input', function () {

    var query = $(this).val();

    // If we are already on Users page,
    // use navbar search to filter the table directly.
    if (page === 'users') {

        $('#userSearch').val(query);

        applySearch();

    }

});

$('#globalSearch').on('keydown', function (event) {

    if (event.key === 'Enter') {

        var query = $(this).val().trim();

        if (query === '') {
            return;
        }

        // If already on Users page, just filter.
        if (page === 'users') {

            $('#userSearch').val(query);

            applySearch();

            return;

        }

        // From Home page, open Users page with search value.
        window.location.href =
            CONTEXT + '/users.jsp?search=' + encodeURIComponent(query);

    }

});

function openAddModal() {
    $('#userForm')[0].reset();
    $('#userId').val('');
    $('#userRole').val('USER').prop('disabled', false);
    $('#userModalTitle').text('Add user');
    $('#passwordGroup').show();
    $('#userPassword').prop('required', true);
    $('#modalAlert').empty();

    bootstrap.Modal.getOrCreateInstance('#userModal').show();
}

function editUser(id) {
    apiJson('GET', '/users/' + id).done(function (user) {
        $('#userForm')[0].reset();
        $('#userId').val(user.id);
        $('#userName').val(user.name);
        $('#userEmail').val(user.email);
        $('#userPhone').val(user.phone || '');

        $('#userRole')
            .val(user.role)
            .prop('disabled', currentUser && user.id === currentUser.id);

        $('#userModalTitle').text('Edit user');
        $('#passwordGroup').hide();
        $('#userPassword').prop('required', false);
        $('#modalAlert').empty();

        bootstrap.Modal.getOrCreateInstance('#userModal').show();
    }).fail(function (xhr) {
        showAlert('#pageAlert', 'danger', errorMessage(xhr));
    });
}

function saveUser(event) {
    event.preventDefault();

    var id = $('#userId').val();

    var data = {
        name: $('#userName').val().trim(),
        email: $('#userEmail').val().trim(),
        phone: $('#userPhone').val().trim(),
        role: $('#userRole').val()
    };

    var request;

    if (id) {
        request = apiJson('PUT', '/users/' + id, data);
    } else {
        data.password = $('#userPassword').val();
        request = apiJson('POST', '/users', data);
    }

    request.done(function (user) {
        bootstrap.Modal.getOrCreateInstance('#userModal').hide();

        if (id) {
            addNotification(
                'User updated',
                data.name + ' was updated successfully.',
                'purple'
            );
        } else {
            addNotification(
                'User added',
                data.name + ' was added to the directory.',
                'green'
            );
        }

        showAlert('#pageAlert', 'success',
            id ? 'User updated successfully.' : 'User added successfully.');

        loadUsers();
    }).fail(function (xhr) {
        showAlert('#modalAlert', 'danger', errorMessage(xhr));
    });
}

function deleteUser(id) {
    var $row = $('#usersTableBody .btn-delete[data-id="' + id + '"]').closest('tr');
    var deletedName = $row.find('[data-label="Name"]').text() || ('User #' + id);

    if (!confirm('Are you sure you want to delete this user?')) {
        return;
    }

    apiJson('DELETE', '/users/' + id).done(function () {
        addNotification(
            'User deleted',
            deletedName + ' was removed from the directory.',
            'red'
        );

        showAlert('#pageAlert', 'success', 'User deleted successfully.');
        loadUsers();
    }).fail(function (xhr) {
        showAlert('#pageAlert', 'danger', errorMessage(xhr));
    });
}

/* --------------------------------------------------------------------------
   Excel import
   -------------------------------------------------------------------------- */

function importUsers(event) {
    event.preventDefault();

    $('#importResult').empty();

    var file = $('#excelFile')[0].files[0];

    if (!file) {
        showAlert('#importAlert', 'warning',
            'Please choose an .xlsx file first.');
        return;
    }

    if (!file.name.toLowerCase().endsWith('.xlsx')) {
        showAlert('#importAlert', 'warning',
            'Only .xlsx files are supported.');
        return;
    }

    var formData = new FormData();
    formData.append('file', file);

    var $button = $('#importSubmitBtn').prop('disabled', true);
    $('#importAlert').empty();

    $.ajax({
        url: API + '/users/import',
        method: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        dataType: 'json'
    }).done(function (result) {
        showImportResult(result);
        $('#excelFile').val('');

        if (result.successful > 0) {
            addNotification(
                'Excel import completed',
                result.successful + ' user(s) imported successfully.',
                'green'
            );
        }

        loadUsers();
    }).fail(function (xhr) {
        showAlert('#importAlert', 'danger', errorMessage(xhr));
    }).always(function () {
        $button.prop('disabled', false);
    });
}

function showImportResult(result) {
    var type = 'danger';

    if (result.successful > 0) {
        type = (result.failed > 0 || result.duplicates > 0)
            ? 'warning'
            : 'success';
    }

    var $box = $('<div class="alert alert-' + type + ' mb-0"></div>');
    $box.append($('<strong></strong>').text(result.message));

    var $list = $('<ul class="mb-0 mt-2"></ul>');
    $list.append($('<li></li>').text('Total rows: ' + result.totalRows));
    $list.append($('<li></li>').text(
        'Successfully imported: ' + result.successful
    ));
    $list.append($('<li></li>').text('Failed: ' + result.failed));
    $list.append($('<li></li>').text(
        'Duplicates skipped: ' + result.duplicates
    ));
    $box.append($list);

    if (result.errors && result.errors.length > 0) {
        $box.append($('<div class="mt-2 fw-bold"></div>')
            .text('Failed rows:'));

        var $errors = $('<ul class="mb-0"></ul>');
        $.each(result.errors, function (i, message) {
            $errors.append($('<li></li>').text(message));
        });
        $box.append($errors);
    }

    if (result.duplicateEmails && result.duplicateEmails.length > 0) {
        $box.append($('<div class="mt-2 fw-bold"></div>')
            .text('Duplicate emails:'));

        var $dups = $('<ul class="mb-0"></ul>');
        $.each(result.duplicateEmails, function (i, email) {
            $dups.append($('<li></li>').text(email));
        });
        $box.append($dups);
    }

    $('#importResult').empty().append($box);
}

/* --------------------------------------------------------------------------
   UI interactions
   -------------------------------------------------------------------------- */

function openSidebar() {
    $('#appSidebar').addClass('sidebar-open');
    $('#sidebarOverlay').addClass('overlay-visible');
    $('body').addClass('menu-open');
}

function closeSidebar() {
    $('#appSidebar').removeClass('sidebar-open');
    $('#sidebarOverlay').removeClass('overlay-visible');
    $('body').removeClass('menu-open');
}

function openProfileMenu() {
    closeNotificationMenu();
    $('#profileMenu').addClass('show');
    $('#profileTrigger').attr('aria-expanded', 'true');
}

function closeProfileMenu() {
    $('#profileMenu').removeClass('show');
    $('#profileTrigger').attr('aria-expanded', 'false');
}

function toggleProfileMenu() {
    if ($('#profileMenu').hasClass('show')) {
        closeProfileMenu();
    } else {
        openProfileMenu();
    }
}

function openNotificationMenu() {
    closeProfileMenu();
    $('#notificationMenu').addClass('show');
    $('#notificationBtn').attr('aria-expanded', 'true');
    renderNotifications();
}

function closeNotificationMenu() {
    $('#notificationMenu').removeClass('show');
    $('#notificationBtn').attr('aria-expanded', 'false');
}

function toggleNotificationMenu() {
    if ($('#notificationMenu').hasClass('show')) {
        closeNotificationMenu();
    } else {
        openNotificationMenu();
    }
}

/* --------------------------------------------------------------------------
   Start-up
   -------------------------------------------------------------------------- */

$(function () {
    var page = $('body').data('page');

    /* Mobile sidebar */
    $(document).on('click', '#menuToggle', function (event) {
        event.preventDefault();
        event.stopPropagation();
        openSidebar();
    });

    $(document).on('click', '#sidebarClose', function (event) {
        event.preventDefault();
        closeSidebar();
    });

    $(document).on('click', '#sidebarOverlay', function () {
        closeSidebar();
    });

    $(document).on('click', '.sidebar-link', function () {
        closeSidebar();
    });

    /* Profile menu - delegated so it still works after dynamic DOM changes */
    $(document).on('click', '#profileTrigger', function (event) {
        event.preventDefault();
        event.stopPropagation();
        toggleProfileMenu();
    });

    /* Notification menu - delegated for reliable click handling */
    $(document).on('click', '#notificationBtn', function (event) {
        event.preventDefault();
        event.stopPropagation();
        toggleNotificationMenu();
    });

    /* Keep dropdowns open while interacting inside them */
    $(document).on('click', '#profileMenu, #notificationMenu', function (event) {
        event.stopPropagation();
    });

    $(document).on('click', '#markNotificationsRead', function (event) {
        event.preventDefault();
        event.stopPropagation();
        markNotificationsRead();
    });

    $(document).on('click', '#profileLogoutBtn', function (event) {
        event.preventDefault();
        event.stopPropagation();
        closeProfileMenu();
        logoutUser();
    });

    $(document).on('click', '#logoutBtn', function () {
        logoutUser();
    });

    /* Close menus when clicking outside */
    $(document).on('click', function () {
        closeProfileMenu();
        closeNotificationMenu();
    });

    /* ESC */
    $(document).on('keydown', function (event) {
        if (event.key === 'Escape') {
            closeProfileMenu();
            closeNotificationMenu();
            closeSidebar();
        }
    });

    /* Resize */
    $(window).on('resize', function () {
        if (window.innerWidth >= 992) {
            closeSidebar();
        }
    });

    /* Login */
    if (page === 'login') {
        $('#loginForm').on('submit', loginUser);
        return;
    }

    loadCurrentUser().done(function () {
        if (page === 'home') {
            $('#changePasswordBtn').on('click', openPasswordModal);
            $('#passwordForm').on('submit', changePassword);
            loadHome();
        }

        if (page === 'users') {
            if (!isAdmin()) {
                window.location.href = CONTEXT + '/home.jsp';
                return;
            }

            $('#addUserBtn').on('click', openAddModal);
            $('#userForm').on('submit', saveUser);
            $('#importForm').on('submit', importUsers);
			$('#userSearch').on('input', function () {

			    $('#globalSearch').val($(this).val());

			    applySearch();

			});
            $('#importModal').on('hidden.bs.modal', function () {
                $('#importResult, #importAlert').empty();
                $('#excelFile').val('');
            });

            $('#usersTableBody').on('click', '.btn-edit', function () {
                editUser($(this).data('id'));
            });

            $('#usersTableBody').on('click', '.btn-delete', function () {
                if (!$(this).prop('disabled')) {
                    deleteUser($(this).data('id'));
                }
            });

            loadUsers();
        }
    });
});
