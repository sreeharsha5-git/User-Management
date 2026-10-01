/* ============================================================================
 * User Management System - client side logic (jQuery + AJAX)
 * The same file is loaded on every page; <body data-page="..."> tells it which
 * page it is running on (login | home | users).
 *
 * Role rules in the UI:
 *   - everyone sees "home" with THEIR OWN details + change password + sign out
 *   - only ADMIN sees the Users menu, the total-users card and the users page
 * (The server enforces the same rules; hiding things here is only for a clean UI.)
 * ========================================================================== */

var CONTEXT = $('body').data('context') || '';   // e.g. "/user-management"
var API = CONTEXT + '/api';                      // base URL of the Jersey REST API
var currentUser = null;                          // filled by loadCurrentUser()

/* ---------------------------- helpers ---------------------------- */

/** Shows a Bootstrap alert inside the element matching `selector`. Text is inserted safely (no HTML). */
function showAlert(selector, type, message) {
    var $alert = $('<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert"></div>');
    $alert.append(document.createTextNode(message));
    $alert.append('<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>');
    $(selector).empty().append($alert);
}

/** Picks the best error text from a failed AJAX call. */
function errorMessage(xhr) {
    if (xhr.responseJSON && xhr.responseJSON.message) {
        return xhr.responseJSON.message;
    }
    if (xhr.status === 0) {
        return 'Cannot reach the server. Is Tomcat running?';
    }
    return 'Unexpected error (HTTP ' + xhr.status + ').';
}

/** Wrapper for JSON requests: apiJson('POST', '/users', {...}) */
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

/** Global handler: if the session expired (401) on any API call, go back to the login page. */
$(document).ajaxError(function (event, xhr, settings) {
    var isAuthCall = settings.url.indexOf('/auth/login') !== -1 || settings.url.indexOf('/auth/logout') !== -1;
    if (xhr.status === 401 && !isAuthCall) {
        window.location.href = CONTEXT + '/login.jsp';
    }
});

/* ----------------------- login / logout / session ----------------------- */

function loginUser(event) {
    event.preventDefault();
    var $button = $('#loginBtn').prop('disabled', true);

    apiJson('POST', '/auth/login', {
        email: $('#email').val().trim(),
        password: $('#password').val()
    }).done(function () {
        window.location.href = CONTEXT + '/home.jsp';       // session cookie is now set
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

/** GET /api/auth/me: who is logged in? Also fills the top bar and reveals admin-only parts. */
function loadCurrentUser() {
    return apiJson('GET', '/auth/me').done(function (user) {
        currentUser = user;
        $('#navUserName').text(user.name);
        $('#navAvatar').text(initialOf(user.name));
        if (isAdmin()) {
            $('.admin-only').removeClass('role-hidden');
        }
    });
}

/* ------------------------------- home ------------------------------- */

function loadHome() {
    $('#welcomeName').text(currentUser.name);
    $('#dName').text(currentUser.name);
    $('#dEmail').text(currentUser.email);
    $('#dPhone').text(currentUser.phone || 'Not provided');
    $('#dRole').text(isAdmin() ? 'Administrator' : 'User')
        .removeClass('pill-admin pill-user')
        .addClass(isAdmin() ? 'pill-admin' : 'pill-user');
    $('#heroSub').text(isAdmin()
        ? 'You have administrator access. Here is an overview of your workspace.'
        : 'Here are your account details.');

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

/** POST /api/auth/change-password. The user stays signed in (session is kept). */
function changePassword(event) {
    event.preventDefault();
    var current = $('#currentPassword').val();
    var next = $('#newPassword').val();
    var repeat = $('#confirmPassword').val();

    if (next !== repeat) {
        showAlert('#passwordAlert', 'danger', 'The new password and its confirmation do not match.');
        return;
    }
    var $button = $('#passwordSubmitBtn').prop('disabled', true);

    apiJson('POST', '/auth/change-password', { currentPassword: current, newPassword: next })
        .done(function () {
            bootstrap.Modal.getOrCreateInstance('#passwordModal').hide();
            showAlert('#pageAlert', 'success', 'Your password was changed successfully. You are still signed in.');
        })
        .fail(function (xhr) {
            showAlert('#passwordAlert', 'danger', errorMessage(xhr));
        })
        .always(function () {
            $button.prop('disabled', false);
        });
}

/* ------------------------- users (admin only) ------------------------- */

/** GET /api/users and rebuild the table body. Called on page load and after every change. */
function loadUsers() {
    return apiJson('GET', '/users').done(function (users) {
        var $body = $('#usersTableBody').empty();
        $('#userCount').text(users.length);

        if (users.length === 0) {
            $body.append('<tr><td colspan="6" class="text-center text-muted py-4">No users found</td></tr>');
            return;
        }

        $.each(users, function (index, user) {
            var isSelf = currentUser && user.id === currentUser.id;
            var $row = $('<tr></tr>');
            // .text() escapes HTML, so a name like <script> cannot run (prevents XSS)
            $row.append($('<td class="cell-muted"></td>').text(user.id));
            $row.append($('<td class="cell-strong"></td>').text(user.name));
            $row.append($('<td></td>').text(user.email));
            $row.append($('<td class="cell-muted"></td>').text(user.phone || '-'));

            var $pill = $('<span class="pill"></span>')
                .addClass(user.role === 'ADMIN' ? 'pill-admin' : 'pill-user')
                .text(user.role === 'ADMIN' ? 'Admin' : 'User');
            $row.append($('<td></td>').append($pill));

            var $actions = $('<td class="text-end text-nowrap"></td>');
            $actions.append($('<button type="button" class="btn btn-sm btn-quiet btn-edit me-1">Edit</button>').attr('data-id', user.id));
            var $delete = $('<button type="button" class="btn btn-sm btn-quiet-danger btn-delete">Delete</button>').attr('data-id', user.id);
            if (isSelf) {
                $delete.prop('disabled', true).attr('title', 'You cannot delete your own account');
            }
            $actions.append($delete);
            $row.append($actions);
            $body.append($row);
        });
        applySearch();
    }).fail(function (xhr) {
        showAlert('#pageAlert', 'danger', 'Could not load users: ' + errorMessage(xhr));
    });
}

/** Client-side filter of the rows already loaded (no extra request). */
function applySearch() {
    var query = ($('#userSearch').val() || '').toLowerCase().trim();
    $('#usersTableBody tr').each(function () {
        $(this).toggle(query === '' || $(this).text().toLowerCase().indexOf(query) !== -1);
    });
}

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

/** GET /api/users/{id}, fill the form, show the modal. */
function editUser(id) {
    apiJson('GET', '/users/' + id).done(function (user) {
        $('#userForm')[0].reset();
        $('#userId').val(user.id);
        $('#userName').val(user.name);
        $('#userEmail').val(user.email);
        $('#userPhone').val(user.phone || '');
        // an admin cannot change their own role (server enforces it too)
        $('#userRole').val(user.role).prop('disabled', currentUser && user.id === currentUser.id);
        $('#userModalTitle').text('Edit user');
        $('#passwordGroup').hide();                       // passwords are not edited here
        $('#userPassword').prop('required', false);
        $('#modalAlert').empty();
        bootstrap.Modal.getOrCreateInstance('#userModal').show();
    }).fail(function (xhr) {
        showAlert('#pageAlert', 'danger', errorMessage(xhr));
    });
}

/** Handles the modal form: POST for a new user, PUT when a user id is present. */
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
        request = apiJson('PUT', '/users/' + id, data);                 // update
    } else {
        data.password = $('#userPassword').val();
        request = apiJson('POST', '/users', data);                      // add
    }

    request.done(function () {
        bootstrap.Modal.getOrCreateInstance('#userModal').hide();
        showAlert('#pageAlert', 'success', id ? 'User updated successfully.' : 'User added successfully.');
        loadUsers();                                                    // refresh only the table
    }).fail(function (xhr) {
        showAlert('#modalAlert', 'danger', errorMessage(xhr));
    });
}

function deleteUser(id) {
    if (!confirm('Are you sure you want to delete this user?')) {
        return;
    }
    apiJson('DELETE', '/users/' + id).done(function () {
        showAlert('#pageAlert', 'success', 'User deleted successfully.');
        loadUsers();
    }).fail(function (xhr) {
        showAlert('#pageAlert', 'danger', errorMessage(xhr));
    });
}

/* --------------------------- excel import --------------------------- */

/** Uploads the chosen .xlsx as multipart/form-data, shows the summary, then refreshes the grid. */
function importUsers(event) {
    event.preventDefault();
    $('#importResult').empty();
    var file = $('#excelFile')[0].files[0];
    if (!file) {
        showAlert('#importAlert', 'warning', 'Please choose an .xlsx file first.');
        return;
    }
    if (!file.name.toLowerCase().endsWith('.xlsx')) {
        showAlert('#importAlert', 'warning', 'Only .xlsx files are supported.');
        return;
    }

    var formData = new FormData();
    formData.append('file', file);                       // part name must match @FormDataParam("file")
    var $button = $('#importSubmitBtn').prop('disabled', true);
    $('#importAlert').empty();

    $.ajax({
        url: API + '/users/import',
        method: 'POST',
        data: formData,
        processData: false,                              // do not turn FormData into a query string
        contentType: false,                              // let the browser set multipart/form-data + boundary
        dataType: 'json'
    }).done(function (result) {
        showImportResult(result);
        $('#excelFile').val('');
        loadUsers();                                     // grid refreshes without a page reload
    }).fail(function (xhr) {
        showAlert('#importAlert', 'danger', errorMessage(xhr));
    }).always(function () {
        $button.prop('disabled', false);
    });
}

function showImportResult(result) {
    var type = 'danger';
    if (result.successful > 0) {
        type = (result.failed > 0 || result.duplicates > 0) ? 'warning' : 'success';
    }
    var $box = $('<div class="alert alert-' + type + ' mb-0"></div>');
    $box.append($('<strong></strong>').text(result.message));

    var $list = $('<ul class="mb-0 mt-2"></ul>');
    $list.append($('<li></li>').text('Total rows: ' + result.totalRows));
    $list.append($('<li></li>').text('Successfully imported: ' + result.successful));
    $list.append($('<li></li>').text('Failed: ' + result.failed));
    $list.append($('<li></li>').text('Duplicates skipped: ' + result.duplicates));
    $box.append($list);

    if (result.errors.length > 0) {
        $box.append($('<div class="mt-2 fw-bold"></div>').text('Failed rows:'));
        var $errors = $('<ul class="mb-0"></ul>');
        $.each(result.errors, function (i, message) { $errors.append($('<li></li>').text(message)); });
        $box.append($errors);
    }
    if (result.duplicateEmails.length > 0) {
        $box.append($('<div class="mt-2 fw-bold"></div>').text('Duplicate emails:'));
        var $dups = $('<ul class="mb-0"></ul>');
        $.each(result.duplicateEmails, function (i, email) { $dups.append($('<li></li>').text(email)); });
        $box.append($dups);
    }
    $('#importResult').empty().append($box);
}

/* ----------------------------- start-up ----------------------------- */

$(function () {
    var page = $('body').data('page');

    if (page === 'login') {
        $('#loginForm').on('submit', loginUser);
        return;
    }

    // every other page is protected
    $('#logoutBtn').on('click', logoutUser);

    loadCurrentUser().done(function () {
        if (page === 'home') {
            $('#changePasswordBtn').on('click', openPasswordModal);
            $('#passwordForm').on('submit', changePassword);
            loadHome();
        }
        if (page === 'users') {
            if (!isAdmin()) {                            // normal users have no business here
                window.location.href = CONTEXT + '/home.jsp';
                return;
            }
            $('#addUserBtn').on('click', openAddModal);
            $('#userForm').on('submit', saveUser);
            $('#importForm').on('submit', importUsers);
            $('#userSearch').on('input', applySearch);
            $('#importModal').on('hidden.bs.modal', function () {
                $('#importResult, #importAlert').empty();
                $('#excelFile').val('');
            });
            // event delegation: works for rows that are created later by loadUsers()
            $('#usersTableBody').on('click', '.btn-edit', function () { editUser($(this).data('id')); });
            $('#usersTableBody').on('click', '.btn-delete', function () { deleteUser($(this).data('id')); });
            loadUsers();
        }
    });
});
