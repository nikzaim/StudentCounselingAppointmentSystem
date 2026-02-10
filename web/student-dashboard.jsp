<%@page import="com.mindlink.model.User"%>
<%@page import="java.sql.*"%>
<%@page import="com.mindlink.utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. Session Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"student".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    // 2. Database Fetching Logic (Old School JDBC Style)
    String fullName = "Student";
    int upcomingCount = 0;
    int completedCount = 0;
    
    Connection conn = null;
    PreparedStatement psName = null;
    ResultSet rsName = null;

    try {
        conn = DBConnection.getConnection();
        
        // Fetch Student Full Name
        psName = conn.prepareStatement("SELECT full_name FROM students WHERE user_id = ?");
        psName.setInt(1, user.getId());
        rsName = psName.executeQuery();
        if(rsName.next()) fullName = rsName.getString("full_name");
        request.setAttribute("fullName", fullName);
        rsName.close(); psName.close();

        // Fetch Upcoming Sessions Count
        PreparedStatement psUpcoming = conn.prepareStatement(
            "SELECT COUNT(*) FROM appointments a JOIN students s ON a.student_id = s.id " +
            "WHERE s.user_id = ? AND a.status IN ('CONFIRMED', 'PENDING')"
        );
        psUpcoming.setInt(1, user.getId());
        ResultSet rsUp = psUpcoming.executeQuery();
        if(rsUp.next()) upcomingCount = rsUp.getInt(1);

        // Fetch Completed Sessions Count
        PreparedStatement psCompleted = conn.prepareStatement(
            "SELECT COUNT(*) FROM appointments a JOIN students s ON a.student_id = s.id " +
            "WHERE s.user_id = ? AND a.status = 'COMPLETED'"
        );
        psCompleted.setInt(1, user.getId());
        ResultSet rsComp = psCompleted.executeQuery();
        if(rsComp.next()) completedCount = rsComp.getInt(1);
        
    } catch (Exception e) { 
        e.printStackTrace(); 
    } finally {
        // Manually closing resources since try-with-resources failed
        if (rsName != null) try { rsName.close(); } catch (SQLException e) {}
        if (psName != null) try { psName.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" href="assets/logo.svg" type="image/svg+xml" />
    <title>Student Dashboard | MindLink</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Rethink+Sans:ital,wght@0,400..800;1,400..800&display=swap" rel="stylesheet" />
    <style>
      * { font-family: "Rethink Sans", sans-serif; }
    </style>
    <script defer src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"></script>
  </head>
  <body class="has-background-light">
    <%@include file="navbar.jsp" %>

    <section class="section">
      <div class="container">
        <h1 class="title">Student Portal</h1>
        <div class="columns">
          <div class="column is-3">
            <aside class="menu box">
              <p class="menu-label">General</p>
              <ul class="menu-list">
                <li><a class="is-active has-background-link">Dashboard</a></li>
                <li><a href="student-profile.jsp">My Profile</a></li>
              </ul>
              <p class="menu-label">Appointments</p>
              <ul class="menu-list">
                <li><a href="manage-appointments.jsp">Book Session</a></li>
                <li><a href="appointment-history.jsp">History</a></li>
              </ul>
            </aside>
          </div>
          <div class="column is-9">
            
            <% if (upcomingCount > 0) { %>
                <div class="notification is-info is-light">
                    Welcome back, <strong><%= fullName %>!</strong> You have <strong><%= upcomingCount %></strong> upcoming or pending session(s).
                </div>
            <% } else { %>
                <div class="notification is-warning is-light">
                    Welcome, <strong><%= fullName %>!</strong> You have no sessions scheduled. <a href="manage-appointments.jsp">Book one now?</a>
                </div>
            <% } %>

            <div class="columns">
              <div class="column">
                <div class="box has-text-centered">
                  <p class="heading">Upcoming Sessions</p>
                  <p class="title has-text-link"><%= upcomingCount %></p>
                </div>
              </div>
              <div class="column">
                <div class="box has-text-centered">
                  <p class="heading">Completed</p>
                  <p class="title"><%= completedCount %></p>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>
    </section>
  </body>
</html>