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

    String fullName = "Counselor";
    int pendingRequests = 0;
    int availableSlots = 0;
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        
        // Fetch Counselor Full Name
        ps = conn.prepareStatement("SELECT full_name FROM counselors WHERE user_id = ?");
        ps.setInt(1, user.getId());
        rs = ps.executeQuery();
        if(rs.next()) fullName = rs.getString("full_name");
        request.setAttribute("fullName", fullName);
        rs.close(); ps.close();

        // Count Pending Requests
        ps = conn.prepareStatement(
            "SELECT COUNT(*) FROM appointments a JOIN counseling_slots cs ON a.slot_id = cs.id " +
            "WHERE cs.counselor_id = (SELECT id FROM counselors WHERE user_id = ?) " +
            "AND a.status = 'PENDING'"
        );
        ps.setInt(1, user.getId());
        rs = ps.executeQuery();
        if(rs.next()) pendingRequests = rs.getInt(1);
        rs.close(); ps.close();

        // Count Available Slots
        ps = conn.prepareStatement(
            "SELECT COUNT(*) FROM counseling_slots WHERE counselor_id = (SELECT id FROM counselors WHERE user_id = ?) " +
            "AND is_available = TRUE AND start_time > CURRENT_TIMESTAMP"
        );
        ps.setInt(1, user.getId());
        rs = ps.executeQuery();
        if(rs.next()) availableSlots = rs.getInt(1);
        
    } catch (Exception e) { 
        e.printStackTrace(); 
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" href="assets/logo.svg" type="image/svg+xml" />
    <title>Counselor Dashboard | MindLink</title>
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
        <h1 class="title">Counselor Portal</h1>
        <div class="columns">
          <div class="column is-3">
            <aside class="menu box">
              <p class="menu-label">General</p>
              <ul class="menu-list">
                <li><a class="is-active has-background-link">Dashboard</a></li>
                <li><a href="counselor-profile.jsp">My Profile</a></li>
              </ul>
              <p class="menu-label">Management</p>
              <ul class="menu-list">
                <li><a href="counselor-appointment-requests.jsp">Appointment Requests</a></li>
                <li><a href="manage-slots.jsp">Manage Slots</a></li>
              </ul>
            </aside>
          </div>
          <div class="column is-9">
            
            <% if (pendingRequests > 0) { %>
                <div class="notification is-info is-light">
                    Welcome back, <strong><%= fullName %>!</strong> You have <strong><%= pendingRequests %></strong> pending appointment request(s).
                </div>
            <% } else { %>
                <div class="notification is-success is-light">
                    Welcome back, <strong><%= fullName %>!</strong> All requests are currently cleared.
                </div>
            <% } %>

            <div class="columns">
              <div class="column">
                <div class="box has-text-centered">
                  <p class="heading">Pending Requests</p>
                  <p class="title has-text-warning"><%= pendingRequests %></p>
                </div>
              </div>
              <div class="column">
                <div class="box has-text-centered">
                  <p class="heading">Available Slots</p>
                  <p class="title has-text-link"><%= availableSlots %></p>
                </div>
              </div>
            </div>

            <div class="box">
              <h2 class="subtitle">Counselor Statistics</h2>
              <p>Performance metrics and analytics for <strong><%= fullName %></strong>.</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  </body>
</html>