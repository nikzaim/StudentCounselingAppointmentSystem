<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" href="assets/logo.svg" type="image/svg+xml" />
    <title>Register | MindLink</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Rethink+Sans:ital,wght@0,400..800;1,400..800&display=swap" rel="stylesheet" />
    <style>
      * { font-family: "Rethink Sans", sans-serif; }
      .tab-content { display: none; }
      .tab-content.is-active { display: block; }
    </style>
    <script defer src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"></script>
  </head>
  <body class="has-background-light">
    <section class="section">
      <div class="container">
        <div class="columns is-centered">
          <div class="column is-6-desktop is-10-tablet">
            <div class="has-text-centered mb-5">
              <h1 class="title has-text-link">MindLink</h1>
              <p class="subtitle is-6">Account Registration</p>
            </div>

            <% if ("fail".equals(request.getParameter("error"))) { %>
              <div class="notification is-danger is-light">
                Registration failed. Username might already exist or database is unavailable.
              </div>
            <% } %>

            <div class="tabs is-centered is-boxed">
              <ul>
                <li class="is-active" data-target="student-form">
                  <a>
                    <span class="icon is-small"><i class="fas fa-user-graduate"></i></span>
                    <span>Student</span>
                  </a>
                </li>
                <li data-target="counselor-form">
                  <a>
                    <span class="icon is-small"><i class="fas fa-user-md"></i></span>
                    <span>Counselor</span>
                  </a>
                </li>
              </ul>
            </div>

            <div class="card">
              <div class="card-content">
                
                <div id="student-form" class="tab-content is-active">
                  <form action="RegistrationServlet" method="POST">
                    <input type="hidden" name="regRole" value="student">
                    
                    <h3 class="subtitle is-5 has-text-link">Student Information</h3>
                    <div class="field">
                      <label class="label">Full Name</label>
                      <input class="input" type="text" name="fullName" placeholder="John Doe" required />
                    </div>
                    <div class="columns">
                      <div class="column">
                        <div class="field">
                          <label class="label">Student ID</label>
                          <input class="input" type="text" name="studentId" placeholder="ID-12345" required />
                        </div>
                      </div>
                      <div class="column">
                        <div class="field">
                          <label class="label">Major (Optional)</label>
                          <div class="select is-fullwidth">
                            <select name="major">
                              <option value="CS">Computer Science</option>
                              <option value="ENG">Engineering</option>
                              <option value="BUS">Business</option>
                            </select>
                          </div>
                        </div>
                      </div>
                    </div>
                    <hr />
                    <div class="field">
                      <label class="label">Username</label>
                      <input class="input" type="text" name="username" placeholder="student_user" required />
                    </div>
                    <div class="field">
                      <label class="label">Password</label>
                      <input class="input" type="password" name="password" placeholder="*******" required />
                    </div>
                    <button type="submit" class="button is-link is-fullwidth mt-4">Register as Student</button>
                  </form>
                </div>

                <div id="counselor-form" class="tab-content">
                  <form action="RegistrationServlet" method="POST">
                    <input type="hidden" name="regRole" value="counselor">

                    <h3 class="subtitle is-5 has-text-link">Counselor Information</h3>
                    <div class="field">
                      <label class="label">Full Name</label>
                      <input class="input" type="text" name="fullName" placeholder="Dr. Jane Smith" required />
                    </div>
                    <div class="field">
                      <label class="label">Specialization</label>
                      <input class="input" type="text" name="specialization" placeholder="e.g., Mental Health, Career" required />
                    </div>
                    <div class="field">
                      <label class="label">Office Location</label>
                      <input class="input" type="text" name="office" placeholder="Building A, Room 302" required />
                    </div>
                    <hr />
                    <div class="field">
                      <label class="label">Username</label>
                      <input class="input" type="text" name="username" placeholder="counselor_user" required />
                    </div>
                    <div class="field">
                      <label class="label">Password</label>
                      <input class="input" type="password" name="password" placeholder="*******" required />
                    </div>
                    <button type="submit" class="button is-link is-fullwidth mt-4">Register as Counselor</button>
                  </form>
                </div>

              </div>
              <footer class="card-footer p-4">
                <p class="is-size-7 is-fullwidth has-text-centered">Already have an account? <a href="login.jsp" class="has-text-link has-text-weight-bold">Login</a></p>
              </footer>
            </div>
          </div>
        </div>
      </div>
    </section>

    <script>
      // Tab switching logic remains the same
      const tabs = document.querySelectorAll(".tabs li");
      const tabContentBoxes = document.querySelectorAll(".tab-content");

      tabs.forEach((tab) => {
        tab.addEventListener("click", () => {
          tabs.forEach((item) => item.classList.remove("is-active"));
          tab.classList.add("is-active");

          const target = tab.dataset.target;
          tabContentBoxes.forEach((box) => {
            if (box.getAttribute("id") === target) {
              box.classList.add("is-active");
            } else {
              box.classList.remove("is-active");
            }
          });
        });
      });
    </script>
  </body>
</html>