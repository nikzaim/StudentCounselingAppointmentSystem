<%@page import="com.mindlink.model.User, com.mindlink.utils.DBConnection, java.sql.*, java.text.SimpleDateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"student".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Appointment History | MindLink</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Rethink+Sans:wght@400;700&display=swap" rel="stylesheet" />
    <script defer src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"></script>
    <style> * { font-family: "Rethink Sans", sans-serif; } </style>
</head>
<body class="has-background-light">
    <%@include file="navbar.jsp" %>
    <section class="section">
        <div class="container">
            <div class="level">
                <div class="level-left">
                  <a href="student-dashboard.jsp" class="is-flex is-align-items-center is-justify-content-center has-background-white" style="width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0" title="Back to Dashboard">
                    <span class="icon has-text-link">
                      <i class="fas fa-chevron-left"></i>
                    </span>
                  </a>
                  <div class="mb-0 ml-3">
                    <h1 class="title">Appointment History</h1>
                    <p class="subtitle is-6">View past sessions and manage feedback</p>
                  </div>
                </div>
            </div>
            <div class="box">
                <table class="table is-fullwidth is-striped">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Counselor</th>
                            <th>Issue Type</th>
                            <th>Status</th>
                            <th class="has-text-centered">Feedback</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn = null;
                            try {
                                conn = DBConnection.getConnection();
                                // Left Join helps detect if feedback exists
                                String sql = "SELECT a.id, c.full_name, a.issue_type, a.status, s.start_time, " +
                                             "f.rating, f.comments " +
                                             "FROM appointments a " +
                                             "JOIN counseling_slots s ON a.slot_id = s.id " +
                                             "JOIN counselors c ON s.counselor_id = c.id " +
                                             "LEFT JOIN feedback f ON a.id = f.appointment_id " +
                                             "WHERE a.student_id = (SELECT id FROM students WHERE user_id = ?) " +
                                             "AND a.status = 'COMPLETED' " +
                                             "ORDER BY s.start_time DESC";
                                
                                PreparedStatement ps = conn.prepareStatement(sql);
                                ps.setInt(1, user.getId());
                                ResultSet rs = ps.executeQuery();
                                SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");

                                while (rs.next()) {
                                    int appId = rs.getInt("id");
                                    int rating = rs.getInt("rating"); // Returns 0 if NULL
                                    String comments = rs.getString("comments");
                        %>
                        <tr>
                            <td><%= sdf.format(rs.getTimestamp("start_time")) %></td>
                            <td><strong><%= rs.getString("full_name") %></strong></td>
                            <td><%= rs.getString("issue_type") %></td>
                            <td><span class="tag is-success is-light">Completed</span></td>
                            <td class="has-text-centered">
                                <% if (rating == 0) { %>
                                    <button class="button is-small is-link js-modal-trigger" 
                                            data-target="modal-rate-<%= appId %>">
                                        <span class="icon is-small"><i class="fas fa-star"></i></span>
                                        <span>Rate Session</span>
                                    </button>
                                <% } else { %>
                                    <button class="button is-small is-info is-light js-modal-trigger" 
                                            data-target="modal-view-<%= appId %>">
                                        <span class="icon is-small"><i class="fas fa-eye"></i></span>
                                        <span>View Feedback</span>
                                    </button>
                                <% } %>
                            </td>
                        </tr>

                        <div id="modal-rate-<%= appId %>" class="modal">
                            <div class="modal-background"></div>
                            <form action="SubmitFeedbackServlet" method="POST">
                                <input type="hidden" name="appId" value="<%= appId %>">
                                <div class="modal-card">
                                    <header class="modal-card-head"><p class="modal-card-title">Rate Session</p></header>
                                    <section class="modal-card-body">
                                        <div class="field">
                                            <label class="label">Rating</label>
                                            <div class="select is-fullwidth">
                                                <select name="rating">
                                                    <option value="5">5 - Excellent</option>
                                                    <option value="4">4 - Very Good</option>
                                                    <option value="3">3 - Good</option>
                                                    <option value="2">2 - Fair</option>
                                                    <option value="1">1 - Poor</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label class="label">Comments</label>
                                            <textarea name="comments" class="textarea" required></textarea>
                                        </div>
                                    </section>
                                    <footer class="modal-card-foot">
                                        <button type="submit" class="button is-link">Submit</button>
                                    </footer>
                                </div>
                            </form>
                        </div>

                        <div id="modal-view-<%= appId %>" class="modal">
                            <div class="modal-background"></div>
                            <div class="modal-card">
                                <header class="modal-card-head"><p class="modal-card-title">Your Feedback</p></header>
                                <section class="modal-card-body">
                                    <p><strong>Rating:</strong> <%= rating %>/5 Stars</p>
                                    <p><strong>Comments:</strong> <%= comments %></p>
                                </section>
                                <footer class="modal-card-foot"><button class="button close-modal">Close</button></footer>
                            </div>
                        </div>
                        <% } } catch(Exception e) { e.printStackTrace(); } finally { if(conn!=null) conn.close(); } %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <script>
        document.querySelectorAll('.js-modal-trigger').forEach(btn => {
            btn.onclick = () => document.getElementById(btn.dataset.target).classList.add('is-active');
        });
        document.querySelectorAll('.modal-background, .close-modal, .delete').forEach(close => {
            close.onclick = () => close.closest('.modal').classList.remove('is-active');
        });
    </script>
</body>
</html>