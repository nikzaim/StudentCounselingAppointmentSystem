<%@page import="com.mindlink.model.User"%>
<%@page import="java.sql.*"%>
<%@page import="com.mindlink.utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. Session Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"counselor".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    // 2. Database Fetching Logic
    String fullName = "";
    String email = "";
    String phoneNumber = "";
    String specialization = "";
    String office = "";
    String bio = "";
    int totalSessions = 0;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        
        // Fetch Counselor Details (Mapping specialization and office)
        ps = conn.prepareStatement("SELECT full_name, email, phone_number, specialization, office_location, bio FROM counselors WHERE user_id = ?");
        ps.setInt(1, user.getId());
        rs = ps.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("full_name") != null ? rs.getString("full_name") : "";
            email = rs.getString("email") != null ? rs.getString("email") : "";
            phoneNumber = rs.getString("phone_number") != null ? rs.getString("phone_number") : "";
            specialization = rs.getString("specialization") != null ? rs.getString("specialization") : "";
            office = rs.getString("office_location") != null ? rs.getString("office_location") : "";
            bio = rs.getString("bio") != null ? rs.getString("bio") : "";
        }
        rs.close(); ps.close();

        // Count Total Sessions handled by this counselor
        ps = conn.prepareStatement("SELECT COUNT(*) FROM appointments a JOIN slots s ON a.slot_id = s.id " +
                                   "WHERE s.counselor_id = (SELECT id FROM counselors WHERE user_id = ?)");
        ps.setInt(1, user.getId());
        rs = ps.executeQuery();
        if(rs.next()) totalSessions = rs.getInt(1);
        
    } catch (Exception e) { 
        e.printStackTrace(); 
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }

    // Set attribute for navbar
    request.setAttribute("fullName", fullName);
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
            <div class="notification is-success">
                <button class="delete" onclick="this.parentElement.style.display='none'"></button>
                Profile updated successfully!
            </div>
        <% } %>

        <div class="is-flex is-align-items-center mb-5">
          <a href="counselor-dashboard.jsp" class="is-flex is-align-items-center is-justify-content-center has-background-white" style="width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0" title="Back to Dashboard">
            <span class="icon has-text-link">
              <i class="fas fa-chevron-left"></i>
            </span>
          </a>
          <h1 class="title mb-0 ml-3">Account Settings</h1>
        </div>

        <div class="columns">
          <div class="column is-4">
            <div class="box has-text-centered">
              <div class="initial-avatar mb-4">
                  <%= fullName.length() > 0 ? fullName.substring(0,1).toUpperCase() : "C" %>
              </div>
              <h3 class="title is-4"><%= fullName %></h3>
              <p class="subtitle is-6">Counselor (ID: <%= user.getId() %>)</p>
              <hr />
              <div class="has-text-left">
                <p class="is-size-7 has-text-grey">Member since: Jan 2026</p>
                <p class="is-size-7 has-text-grey">Total Sessions: <%= totalSessions %></p>
              </div>
            </div>
          </div>

          <div class="column is-8">
            <div class="box">
              <h4 class="subtitle is-5">Professional Information</h4>
              <form action="UpdateProfileServlet" method="POST">
                <div class="columns">
                    <div class="column is-6">
                        <div class="field">
                            <label class="label">Full Name</label>
                            <div class="control">
                                <input class="input" type="text" name="fullName" value="<%= fullName %>" required />
                            </div>
                        </div>
                    </div>
                    <div class="column is-6">
                        <div class="field">
                            <label class="label">Email Address</label>
                            <div class="control">
                                <input class="input" type="email" name="email" value="<%= email %>" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="field">
                    <label class="label">Phone Number</label>
                    <div class="control">
                        <input class="input" type="text" name="phoneNumber" value="<%= phoneNumber %>" />
                    </div>
                </div>

                <div class="field">
                    <label class="label">Specialization</label>
                    <div class="control">
                        <input class="input" type="text" name="specialization" value="<%= specialization %>" />
                    </div>
                </div>

                <div class="field">
                    <label class="label">Office Location</label>
                    <div class="control">
                        <input class="input" type="text" name="office" value="<%= office %>" />
                    </div>
                </div>

                <div class="field">
                    <label class="label">Bio / About Me</label>
                    <div class="control">
                        <textarea class="textarea" name="bio"><%= bio %></textarea>
                    </div>
                </div>

                <div class="mt-5">
                    <button type="submit" class="button is-link">Save Changes</button>
                </div>
            </form>
            </div>

            <div class="box mt-5">
              <h4 class="subtitle is-5">Security</h4>
              <p class="mb-4">Change your password to keep your account secure.</p>
              <button class="button is-warning js-modal-trigger" data-target="modal-change-password">
                <span class="icon"><i class="fas fa-lock"></i></span>
                <span>Change Password</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <div id="modal-change-password" class="modal">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head has-background-link">
          <p class="modal-card-title has-text-white">Change Password</p>
          <button class="delete" aria-label="close"></button>
        </header>
        <section class="modal-card-body">
          <form id="password-form" action="ChangePasswordServlet" method="POST">
            <div class="field">
              <label class="label">New Password</label>
              <div class="control has-icons-left">
                <input class="input" type="password" name="newPassword" id="new-password" placeholder="Enter new password" required />
                <span class="icon is-left"><i class="fas fa-key"></i></span>
              </div>
            </div>

            <div class="field">
              <label class="label">Confirm Password</label>
              <div class="control has-icons-left">
                <input class="input" type="password" id="confirm-password" placeholder="Confirm new password" required />
                <span class="icon is-left"><i class="fas fa-key"></i></span>
              </div>
            </div>

            <div id="password-error" class="notification is-danger is-hidden" style="margin-top: 1rem;">
              <span id="error-message"></span>
            </div>
          </form>
        </section>
        <footer class="modal-card-foot">
          <button type="button" class="button is-link" id="btn-confirm-password">Confirm Password Change</button>
          <button type="button" class="button">Cancel</button>
        </footer>
      </div>
    </div>

    <script>
      document.addEventListener("DOMContentLoaded", () => {
        const openModal = ($el) => $el.classList.add("is-active");
        const closeModal = ($el) => $el.classList.remove("is-active");

        (document.querySelectorAll(".js-modal-trigger") || []).forEach(($trigger) => {
          const $target = document.getElementById($trigger.dataset.target);
          $trigger.addEventListener("click", () => openModal($target));
        });

        (document.querySelectorAll(".modal-background, .delete, .modal-card-foot .button:not(.is-link)") || []).forEach(($close) => {
          const $target = $close.closest(".modal");
          $close.addEventListener("click", () => closeModal($target));
        });

        const confirmBtn = document.getElementById("btn-confirm-password");
        confirmBtn.addEventListener("click", () => {
          const pass = document.getElementById("new-password").value;
          const conf = document.getElementById("confirm-password").value;
          if (pass.length < 6) {
            showError("Password must be at least 6 characters long");
          } else if (pass !== conf) {
            showError("Passwords do not match");
          } else {
            document.getElementById("password-form").submit();
          }
        });

        function showError(message) {
          document.getElementById("error-message").textContent = message;
          document.getElementById("password-error").classList.remove("is-hidden");
        }
      });
    </script>
  </body>
</html>