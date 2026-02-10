<%@page import="com.mindlink.model.Student"%>
<%@page import="java.util.List"%>
<%@page import="com.mindlink.model.User"%>
<%@page import="java.sql.*"%>
<%@page import="com.mindlink.utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    // Ensure data is present (if user visits JSP directly, redirect to Servlet)
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    if (studentList == null) {
        response.sendRedirect("manage-students");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>My Profile | MindLink</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
        <link href="https://fonts.googleapis.com/css2?family=Rethink+Sans:ital,wght@0,400..800;1,400..800&display=swap" rel="stylesheet" />
        <style>
          * { font-family: "Rethink Sans", sans-serif; }
          .initial-avatar {
            background-color: #3273dc;
            color: white; width: 128px; height: 128px;
            border-radius: 50%; display: flex; align-items: center;
            justify-content: center; font-size: 3rem; font-weight: bold; margin: 0 auto;
          }
        </style>
        <script defer src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"></script>
    </head>
    <body class="has-background-light">
        <%@include file="navbar.jsp" %>

        <section class="section">
          <div class="container">
            <% if ("success".equals(request.getParameter("status"))) { %>
                <div class="notification is-success">Password reset successfully!</div>
            <% } %>

            <div class="level">
                <div class="level-left">
                  <a href="admin-dashboard.jsp" class="is-flex is-align-items-center is-justify-content-center has-background-white" style="width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0" title="Back to Dashboard">
                    <span class="icon has-text-link">
                      <i class="fas fa-chevron-left"></i>
                    </span>
                  </a>
                  <div class="mb-0 ml-3">
                    <h1 class="title">Manage Students</h1>
                  </div>
                </div>
            </div>

            <div class="box">
                <div class="is-flex is-justify-content-space-between is-align-items-center mb-4">
                    <h3 class="subtitle is-5">Student List</h3>
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
                      <th>User ID</th>
                      <th>Full Name</th>
                      <th>Student ID Card</th>
                      <th>Major</th>
                      <th>Email</th>
                      <th>Phone</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                        <%
                            for (Student s : studentList) {
                        %>
                        <tr>
                          <td><%= s.getUserId() %></td>
                          <td><strong><%= s.getFullName() %></strong></td>
                          <td><%= s.getStudentIdCard() != null ? s.getStudentIdCard() : "-" %></td>
                          <td><%= s.getMajor() != null ? s.getMajor() : "-" %></td>
                          <td><%= s.getEmail() != null ? s.getEmail() : "-" %></td>
                          <td><%= s.getPhoneNumber() != null ? s.getPhoneNumber() : "-" %></td>
                          <td>
                            <button class="button is-small is-warning js-modal-trigger" 
                                    data-target="modal-reset-password" 
                                    data-user-id="<%= s.getUserId() %>" 
                                    data-student-name="<%= s.getFullName() %>">
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
            </header>
            <section class="modal-card-body">
              <form id="resetForm" action="AdminResetPasswordServlet" method="POST">
                <input type="hidden" name="targetUserId" id="modal-input-user-id">
                <input type="hidden" name="sourcePage" value="manage-students">
                <!--<input type="hidden" name="sourcePage" value="manage-students.jsp">-->
                
                <p class="mb-4">Resetting password for: <strong id="modal-display-name"></strong></p>
                
                <div class="field">
                  <label class="label">New Password</label>
                  <input class="input" type="password" name="newPassword" id="new-password" required>
                </div>
              </form>
            </section>
            <footer class="modal-card-foot">
              <button class="button is-link" onclick="document.getElementById('resetForm').submit()">Confirm Reset</button>
              <button class="button" onclick="this.closest('.modal').classList.remove('is-active')">Cancel</button>
            </footer>
          </div>
        </div>

        <script>
          // Updated Modal script to handle data passing
          document.querySelectorAll(".js-modal-trigger").forEach($trigger => {
            $trigger.addEventListener("click", () => {
              const target = document.getElementById($trigger.dataset.target);
              document.getElementById("modal-display-name").textContent = $trigger.dataset.studentName;
              document.getElementById("modal-input-user-id").value = $trigger.dataset.userId;
              target.classList.add("is-active");
            });
          });
        </script>
    </body>
</html>