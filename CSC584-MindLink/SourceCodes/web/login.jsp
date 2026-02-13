<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login | MindLink</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Rethink+Sans:wght@400;700&display=swap" rel="stylesheet" />
    <script defer src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"></script>
    <style> * { font-family: "Rethink Sans", sans-serif; } </style>
  </head>
  <body class="has-background-light">
    <section class="section">
      <div class="container">
        <div class="columns is-centered">
          <div class="column is-4-desktop is-6-tablet is-12-mobile">
            <div class="has-text-centered mb-5">
              <h1 class="title has-text-link">MindLink</h1>
            </div>

            <div class="card">
              <header class="card-header has-background-link">
                <p class="card-header-title has-text-white">User Login</p>
              </header>

              <div class="card-content">
                <form action="LoginServlet" method="POST">
                  
                  <% if ("success".equals(request.getParameter("registration"))) { %>
                    <div class="notification is-success is-light">
                        <button class="delete"></button>
                        Registration successful! Please login with your new credentials.
                    </div>
                  <% } %>

                  <% if ("invalid".equals(request.getParameter("error"))) { %>
                    <div class="notification is-danger is-light">
                        <button class="delete"></button>
                        Invalid username, password, or role selection.
                    </div>
                  <% } %>

                  <% if ("unauthorized".equals(request.getParameter("error"))) { %>
                    <div class="notification is-warning is-light">
                        <button class="delete"></button>
                        Please login first to access that page.
                    </div>
                  <% } %>

                  <div class="field">
                    <label class="label">Username</label>
                    <div class="control has-icons-left">
                      <input class="input" type="text" name="username" placeholder="Username" required />
                      <span class="icon is-small is-left"><i class="fas fa-user"></i></span>
                    </div>
                  </div>

                  <div class="field">
                    <label class="label">Password</label>
                    <div class="control has-icons-left">
                      <input class="input" type="password" name="password" placeholder="*******" required />
                      <span class="icon is-small is-left"><i class="fas fa-key"></i></span>
                    </div>
                  </div>

                  <div class="field">
                    <label class="label">Login As</label>
                    <div class="control has-icons-left">
                      <div class="select is-fullwidth">
                        <select name="role">
                          <option value="student">Student</option>
                          <option value="counselor">Counselor</option>
                          <option value="admin">Administrator</option>
                        </select>
                      </div>
                      <span class="icon is-small is-left"><i class="fas fa-users"></i></span>
                    </div>
                  </div>

                  <div class="field mt-5">
                    <button type="submit" class="button is-link is-fullwidth">
                      <strong>Login to Dashboard</strong>
                    </button>
                  </div>
                </form>
              </div>

              <footer class="card-footer p-4 has-text-centered">
                <p class="is-size-7 is-fullwidth">New user? <a href="registration.jsp" class="has-text-link has-text-weight-bold">Create an account</a></p>
              </footer>
            </div>
          </div>
        </div>
      </div>
    </section>

    <script>
      // JavaScript to make the notification "delete" buttons work
      document.addEventListener('DOMContentLoaded', () => {
        (document.querySelectorAll('.notification .delete') || []).forEach(($delete) => {
          const $notification = $delete.parentNode;
          $delete.addEventListener('click', () => {
            $notification.parentNode.removeChild($notification);
          });
        });
      });
    </script>
  </body>
</html>