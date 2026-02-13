<%@page import="com.mindlink.model.Counselor"%>
<%@page import="java.util.List"%>
<%@page import="com.mindlink.model.User"%>
<%@page import="java.sql.*"%>
<%@page import="com.mindlink.utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security check
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    // Redirect to Servlet if data is missing
    List<Counselor> counselorList = (List<Counselor>) request.getAttribute("counselorList");
    if (counselorList == null) {
        response.sendRedirect("manage-counselors");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Counselors | MindLink</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Rethink+Sans:ital,wght@0,400..800;1,400..800&display=swap" rel="stylesheet" />
    <style> * { font-family: "Rethink Sans", sans-serif; } </style>
    <script defer src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"></script>
</head>
<body class="has-background-light">
    <nav class="navbar is-link">
        <div class="container">
            <div class="navbar-brand">
                <a class="navbar-item has-text-weight-bold has-text-white" href="admin-dashboard.jsp">MindLink</a>
            </div>
            <div class="navbar-end"><a class="navbar-item has-text-white" href="LogoutServlet">Logout</a></div>
        </div>
    </nav>

    <section class="section">
        <div class="container">
            <% if ("success".equals(request.getParameter("status"))) { %>
                <div class="notification is-success">Password updated successfully!</div>
            <% } %>

            <div class="level">
                <div class="level-left">
                  <a href="admin-dashboard.jsp" class="is-flex is-align-items-center is-justify-content-center has-background-white" style="width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0" title="Back to Dashboard">
                    <span class="icon has-text-link">
                      <i class="fas fa-chevron-left"></i>
                    </span>
                  </a>
                  <div class="mb-0 ml-3">
                    <h1 class="title">Manage Counselors</h1>
                  </div>
                </div>
            </div>

            <div class="box">
                <div class="is-flex is-justify-content-space-between is-align-items-center mb-4">
                    <h3 class="subtitle is-5">Counselor List</h3>
<!--                    <div class="field">
                        <div class="control has-icons-left">
                        <input class="input" type="text" id="search-input" placeholder="Search..." />
                        <span class="icon is-left"><i class="fas fa-search"></i></span>
                        </div>
                    </div>-->
                </div>

                <div class="table-container">
                    <table class="table is-fullwidth is-striped is-hoverable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Full Name</th>
                                <th>Specialization</th>
                                <th>Office</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (Counselor c : counselorList) {
                            %>
                            <tr>
                                <td><%= c.getUserId() %></td>
                                <td><strong><%= c.getFullName() %></strong></td>
                                <td><%= c.getSpecialization() != null ? c.getSpecialization() : "-" %></td>
                                <td><%= c.getOfficeLocation() != null ? c.getOfficeLocation() : "-" %></td>
                                <td><%= c.getEmail() != null ? c.getEmail() : "-" %></td>
                                <td><%= c.getPhoneNumber() != null ? c.getPhoneNumber() : "-" %></td>
                                <td>
                                    <button class="button is-small is-warning js-modal-trigger" 
                                            data-target="modal-reset-password" 
                                            data-id="<%= c.getUserId() %>" 
                                            data-name="<%= c.getFullName() %>">
                                        <span class="icon is-small"><i class="fas fa-key"></i></span>
                                        <span>Reset Password</span>
                                    </button>
                                </td>
                            </tr>
                            <% 
                                } 
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </section>

    <div id="modal-reset-password" class="modal">
        <div class="modal-background"></div>
        <div class="modal-card">
            <header class="modal-card-head has-background-link">
                <p class="modal-card-title has-text-white">Reset Password</p>
                <button class="delete" aria-label="close" type="button"></button>
            </header>
            <form action="AdminResetPasswordServlet" method="POST">
                <section class="modal-card-body">
                    <input type="hidden" name="targetUserId" id="modal-input-id">
                    <input type="hidden" name="sourcePage" value="manage-counselors">
                    <!--<input type="hidden" name="sourcePage" value="manage-counselors.jsp">-->
                    
                    <p class="mb-4">Resetting password for: <strong id="display-name"></strong></p>
                    
                    <div class="field">
                        <label class="label">New Password</label>
                        <div class="control has-icons-left">
                            <input class="input" type="password" name="newPassword" required minlength="6">
                            <span class="icon is-left"><i class="fas fa-lock"></i></span>
                        </div>
                    </div>
                </section>
                <footer class="modal-card-foot">
                    <button type="submit" class="button is-link">Confirm Reset</button>
                    <button type="button" class="button modal-cancel">Cancel</button>
                </footer>
            </form>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", () => {
            // Modal Logic
            const triggers = document.querySelectorAll(".js-modal-trigger");
            const modal = document.getElementById("modal-reset-password");
            const closeBtns = document.querySelectorAll(".delete, .modal-cancel, .modal-background");

            triggers.forEach(trigger => {
                trigger.addEventListener("click", () => {
                    document.getElementById("display-name").textContent = trigger.dataset.name;
                    document.getElementById("modal-input-id").value = trigger.dataset.id;
                    modal.classList.add("is-active");
                });
            });

            closeBtns.forEach(btn => {
                btn.addEventListener("click", () => modal.classList.remove("is-active"));
            });

            // Search Logic
            const searchInput = document.getElementById("search-input");
            const rows = document.querySelectorAll("tbody tr");
            searchInput.addEventListener("keyup", () => {
                const term = searchInput.value.toLowerCase();
                rows.forEach(row => {
                    row.style.display = row.innerText.toLowerCase().includes(term) ? "" : "none";
                });
            });
        });
    </script>
</body>
</html>