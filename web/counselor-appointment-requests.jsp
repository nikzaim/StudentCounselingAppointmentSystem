<%@page import="com.mindlink.model.User"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.mindlink.utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"counselor".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Appointment Requests | MindLink</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Rethink+Sans:wght@400;700&display=swap" rel="stylesheet" />
    <style> * { font-family: "Rethink Sans", sans-serif; } </style>
    <script defer src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"></script>
</head>
<body class="has-background-light">
    <%@include file="navbar.jsp" %>
    <section class="section">
        <div class="container">
            <div class="level">
                <div class="level-left">
                  <a href="counselor-dashboard.jsp" class="is-flex is-align-items-center is-justify-content-center has-background-white" style="width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0" title="Back to Dashboard">
                    <span class="icon has-text-link">
                      <i class="fas fa-chevron-left"></i>
                    </span>
                  </a>
                  <div class="mb-0 ml-3">
                    <h1 class="title">Appointment Requests</h1>
                    <p class="subtitle is-6">Review and respond to student appointment requests</p>
                  </div>
                </div>
              </div>
            
            <% if (request.getParameter("msg") != null) { 
                String msg = request.getParameter("msg");
                String color = msg.equals("success") ? "is-success" : "is-danger";
                String text = msg.equals("success") ? "Status updated!" : "Action failed.";
            %>
                <div class="notification <%= color %> is-light"><%= text %></div>
            <% } %>

            <div class="box">
                <table class="table is-fullwidth is-striped">
                    <thead>
                        <tr>
                            <th>Student</th>
                            <th>Issue</th>
                            <th>Slot</th>
                            <th>Status</th>
                            <th class="has-text-centered">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            try {
                                conn = DBConnection.getConnection();
                                String sql = "SELECT a.id, st.full_name, a.issue_type, a.status, s.start_time, s.end_time " +
                                             "FROM appointments a " +
                                             "JOIN counseling_slots s ON a.slot_id = s.id " +
                                             "JOIN students st ON a.student_id = st.id " +
                                             "WHERE s.counselor_id = (SELECT id FROM counselors WHERE user_id = ?) " +
                                             "AND a.status IN ('PENDING', 'CONFIRMED') " +
                                             "ORDER BY s.start_time ASC";

                                ps = conn.prepareStatement(sql);
                                ps.setInt(1, user.getId());
                                rs = ps.executeQuery();
                                SimpleDateFormat fmt = new SimpleDateFormat("dd MMM, hh:mm a");

                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                                    String status = rs.getString("status");
                        %>
                        <tr>
                            <td><strong><%= rs.getString("full_name") %></strong></td>
                            <td><%= rs.getString("issue_type") %></td>
                            <td><%= fmt.format(rs.getTimestamp("start_time")) %></td>
                            <td>
                                <span class="tag <%= status.equals("CONFIRMED") ? "is-success" : "is-warning" %> is-light">
                                    <%= status %>
                                </span>
                            </td>
                            <td class="has-text-centered">
                                <form action="HandleAppointmentServlet" method="POST" style="display:inline;">
                                    <input type="hidden" name="appId" value="<%= rs.getInt("id") %>">
                                    <% if (status.equalsIgnoreCase("PENDING")) { %>
                                        <button name="action" value="CONFIRMED" class="button is-small is-success">
                                            <span class="icon is-small"><i class="fas fa-check"></i></span>
                                            <span>Accept</span>
                                        </button>
                                        <button name="action" value="REJECTED" class="button is-small is-danger">
                                            <span class="icon is-small"><i class="fas fa-times"></i></span>
                                            <span>Decline</span>
                                        </button>
                                    <% } else if (status.equalsIgnoreCase("CONFIRMED")) { %>
                                        <button name="action" value="COMPLETED" class="button is-small is-link">Mark Completed</button>
                                    <% } %>
                                </form>
                            </td>
                        </tr>
                        <% 
                                } 
                                if(!hasData) {
                                    out.println("<tr><td colspan='5' class='has-text-centered'>No pending requests.</td></tr>");
                                }
                            } catch(Exception e) { 
                                e.printStackTrace(); 
                                out.println("Error: " + e.getMessage());
                            } finally {
                                // Manual closing for older Java versions
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                if (conn != null) try { conn.close(); } catch (SQLException e) {}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
</body>
</html>