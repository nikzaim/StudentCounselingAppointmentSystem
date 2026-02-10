<%@page import="com.mindlink.model.User"%>
<%@page import="java.sql.*"%>
<%@page import="com.mindlink.utils.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. Session Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    int studentTotal = 0;
    int counselorTotal = 0;
    int appointmentTotal = 0;
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        stmt = conn.createStatement();

        // Count Students
        rs = stmt.executeQuery("SELECT COUNT(*) FROM students");
        if(rs.next()) studentTotal = rs.getInt(1);
        rs.close(); // Close before reusing for next query
        
        // Count Counselors
        rs = stmt.executeQuery("SELECT COUNT(*) FROM counselors");
        if(rs.next()) counselorTotal = rs.getInt(1);
        rs.close();

        // Count All Appointments
        rs = stmt.executeQuery("SELECT COUNT(*) FROM appointments");
        if(rs.next()) appointmentTotal = rs.getInt(1);
        
    } catch (Exception e) { 
        e.printStackTrace(); 
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" href="assets/logo.svg" type="image/svg+xml" />
    <title>Admin Dashboard | MindLink</title>
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
        <h1 class="title">System Administration</h1>
        
        <div class="tile is-ancestor">
          <div class="tile is-parent">
            <article class="tile is-child box has-background-link has-text-white">
              <p class="title has-text-white"><%= studentTotal %></p>
              <p class="subtitle has-text-white">Total Students</p>
            </article>
          </div>
          <div class="tile is-parent">
            <article class="tile is-child box has-background-link has-text-white">
              <p class="title has-text-white"><%= counselorTotal %></p>
              <p class="subtitle has-text-white">Active Counselors</p>
            </article>
          </div>
          <div class="tile is-parent">
            <article class="tile is-child box has-background-link has-text-white">
              <p class="title has-text-white"><%= appointmentTotal %></p>
              <p class="subtitle has-text-white">Total Appointments</p>
            </article>
          </div>
        </div>

        <div class="columns mt-5">
          <div class="column is-6">
            <div class="box">
              <h3 class="label">Recent Feedback Ratings</h3>
              <progress class="progress is-link" value="90" max="100">90%</progress>
              <p>Satisfaction Rate: 4.5/5.0</p>
            </div>
          </div>
          <div class="column is-6">
            <div class="box">
              <h3 class="subtitle">User Management</h3>
              <a href="manage-students.jsp" class="button is-link is-fullwidth mb-2">
                  <span class="icon is-small"><i class="fas fa-user-graduate"></i></span> 
                  <span>Manage Students</span>
              </a>
              <a href="manage-counselors.jsp" class="button is-link is-fullwidth">
                  <span class="icon is-small"><i class="fas fa-user-md"></i></span> 
                  <span>Manage Counselors</span>
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  </body>
</html>