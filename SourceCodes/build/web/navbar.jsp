<%-- 
    Document   : navbar
    Created on : Jan 14, 2026, 7:49:17 AM
    Author     : nikza
--%>

<%@page import="com.mindlink.model.User"%>
<%@page import="com.mindlink.utils.DBConnection"%>
<%@page import="java.sql.*"%>
<%
    User navUser = (User) session.getAttribute("user");
    String displayRole = "";
    String dbFullName = "User"; // Default fallback

    if (navUser != null) {
        displayRole = navUser.getRole().substring(0, 1).toUpperCase() + navUser.getRole().substring(1);
        
        Connection navConn = null;
        try {
            navConn = DBConnection.getConnection();
            String tableName = navUser.getRole().equals("student") ? "students" : "counselors";
            
            // Query the specific table (students or counselors) using the user_id
            String navSql = "SELECT full_name FROM " + tableName + " WHERE user_id = ?";
            PreparedStatement navPs = navConn.prepareStatement(navSql);
            navPs.setInt(1, navUser.getId());
            ResultSet navRs = navPs.executeQuery();
            
            if (navRs.next()) {
                dbFullName = navRs.getString("full_name");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (navConn != null) try { navConn.close(); } catch (SQLException e) {}
        }
    }
%>
<nav class="navbar is-link">
  <div class="container">
    <div class="navbar-brand">
      <a class="navbar-item has-text-weight-bold has-text-white" href="<%= navUser != null ? navUser.getRole() : "login" %>-dashboard.jsp">
        <svg width="24" height="24" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 8px; vertical-align: middle;">
            <path d="M39.7146 25.3658C38.8362 23.5454 38.859 22.0063 38.8848 20.2587C38.8921 19.7637 38.8997 19.2519 38.8871 18.7124C38.8286 16.3645 38.0608 14.0823 36.6756 12.1389C35.1586 10.2889 33.1693 8.83941 30.8971 7.9286C28.014 6.65481 24.8731 5.99658 21.6945 6.00001C17.532 6.00001 13.5401 7.57402 10.5968 10.3758C7.65352 13.1775 6 16.9775 6 20.9397C6 25.7069 8.81421 29.3845 12.4667 32.1144V38.5626C13.5031 40.6709 17.4128 42.1661 19.697 41.9852C24.548 41.9852 25.4041 39.2689 25.4041 39.2689V37.8458C25.4041 37.8458 38.245 42.0576 38.245 31.9665C38.245 31.9665 41.6265 31.4504 41.9689 29.5761C42.3113 27.7019 39.7146 25.3658 39.7146 25.3658Z" fill="white"/>
        </svg>
        MindLink
      </a>
    </div>
    <div class="navbar-end">
      <% if (navUser != null) { %>
        <div class="navbar-item has-text-white mr-4">
          <span class="tag is-link is-light mr-2"><%= displayRole %></span>
          <strong class="has-text-white"><%= dbFullName %></strong> 
        </div>
        <a class="navbar-item has-text-white" href="LogoutServlet">Logout</a>
      <% } else { %>
        <a class="navbar-item has-text-white" href="login.jsp">Login</a>
      <% } %>
    </div>
  </div>
</nav>