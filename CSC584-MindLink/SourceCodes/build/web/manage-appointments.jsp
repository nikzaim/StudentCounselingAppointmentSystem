<%@page import="java.util.List"%>
<%@page import="com.mindlink.model.User"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.mindlink.utils.DBConnection"%>
<%@page import="com.mindlink.model.Appointment" %>
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Appointments | MindLink</title>
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
                    <a href="student-dashboard.jsp" class="is-flex is-align-items-center is-justify-content-center has-background-white" style="width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0" title="Back to Dashboard">
                        <span class="icon has-text-link"><i class="fas fa-chevron-left"></i></span>
                    </a>
                   
                    <div class="ml-3">
                        <h1 class="title">My Appointments</h1>
                        <p class="subtitle is-6">Manage your counseling sessions</p>
                    </div>
                </div>
                <div class="level-right">
                    <button class="button is-link js-modal-trigger" data-target="modal-book-appointment">
                        <span class="icon"><i class="fas fa-plus"></i></span>
                        <span>Book New Appointment</span>
                    </button>
                </div>
            </div>

            <%-- Notification area for success/error --%>
            <% if ("success".equals(request.getParameter("status"))) { %>
                <div class="notification is-success">Appointment booked successfully!</div>
            <% } else if ("cancelled".equals(request.getParameter("status"))) { %>
                <div class="notification is-success">Appointment cancelled successfully!.</div>
            <% } else if ("error".equals(request.getParameter("status"))) { %>
                <div class="notification is-danger">Something went wrong. Please try again.</div>
            <% } %>

            <div class="box">
                <table class="table is-fullwidth is-striped is-hoverable">
                    <thead>
                        <tr>
                            <th>Counselor</th>
                            <th>Date & Time</th>
                            <th>Issue Type</th>
                            <th>Description</th>
                            <th>Status</th>
                            <th class="has-text-centered">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // Get the list from the request attribute (set by the Servlet)
                            List<Appointment> appointmentList = 
                                (List<Appointment>) request.getAttribute("appointmentList");

                            if (appointmentList == null) {
                                response.sendRedirect("manage-appointments");
                                return;
                            }

                            SimpleDateFormat dateTimeFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

                            if (appointmentList.isEmpty()) {
                        %>
                            <tr><td colspan="6" class="has-text-centered">No appointments found.</td></tr>
                        <%
                            } else {
                                for (Appointment app : appointmentList) {
                                    String status = app.getStatus();
                                    String statusClass = "is-light ";
                                    if(status.equalsIgnoreCase("confirmed") || status.equalsIgnoreCase("completed")) 
                                        statusClass += "is-success";
                                    else if(status.equalsIgnoreCase("pending")) 
                                        statusClass += "is-warning";
                                    else 
                                        statusClass += "is-danger";
                        %>
                            <tr>
                                <td><strong><%= app.getCounselorName() %></strong></td>
                                <td><%= dateTimeFmt.format(app.getStartTime()) %></td>
                                <td><%= app.getIssueType() %></td>
                                <td class="is-size-7"><%= app.getDescription() != null ? app.getDescription() : "-" %></td>
                                <td><span class="tag <%= statusClass %>"><%= status.toUpperCase() %></span></td>
                                <td class="has-text-centered">
                                    <% if(status.equalsIgnoreCase("pending")) { %>
                                        <form action="CancelAppointmentServlet" method="POST" onsubmit="return confirm('Are you sure?');">
                                            <input type="hidden" name="appointmentId" value="<%= app.getId() %>">
                                            <button type="submit" class="button is-small is-danger">
                                                <span class="icon is-small"><i class="fas fa-times"></i></span>
                                                <span>Cancel</span>
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <span class="is-size-7 has-text-grey">No Actions</span>
                                    <% } %>
                                </td>
                            </tr>
                        <% 
                                }
                            } 
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <div id="modal-book-appointment" class="modal">
        <div class="modal-background"></div>
        <div class="modal-card">
            <header class="modal-card-head has-background-link">
                <p class="modal-card-title has-text-white">Book New Appointment</p>
                <button class="delete" aria-label="close"></button>
            </header>
            <form action="BookAppointmentServlet" method="POST">
                <section class="modal-card-body">
                    <div class="field">
                        <label class="label">Select Counselor</label>
                        <div class="control">
                            <div class="select is-fullwidth">
                                <select id="counselor-select" name="counselorId" required>
                                    <option value="">-- Choose a Counselor --</option>
                                    <%
                                        // Dynamic Counselor list with specialization in data attribute
                                        Connection conn = DBConnection.getConnection();
                                        String cSql = "SELECT id, full_name, specialization FROM counselors";
                                        Statement st = conn.createStatement();
                                        ResultSet rsC = st.executeQuery(cSql);
                                        while(rsC.next()) {
                                    %>
                                    <option value="<%= rsC.getInt("id") %>" data-spec="<%= rsC.getString("specialization") %>">
                                        <%= rsC.getString("full_name") %> (<%= rsC.getString("specialization") %>)
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="field">
                        <label class="label">Available Slot</label>
                        <div class="control">
                            <div class="select is-fullwidth">
                                <select id="slot-select" name="slotId" required disabled>
                                    <option value="">-- Select Counselor First --</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="field">
                        <label class="label">Issue Type</label>
                        <div class="control">
                            <div class="select is-fullwidth">
                                <select name="issueType" id="issue-type-select" required>
                                    <option value="Academic Stress">Academic Stress</option>
                                    <option value="Career Guidance">Career Guidance</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="field">
                        <label class="label">Brief Description</label>
                        <div class="control">
                            <textarea class="textarea" name="description" placeholder="Describe your concern..."></textarea>
                        </div>
                    </div>
                </section>
                <footer class="modal-card-foot">
                    <button type="submit" class="button is-link">Confirm Booking</button>
                    <button type="button" class="button modal-cancel">Cancel</button>
                </footer>
            </form>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", () => {
            // Modal Toggling Logic
            const triggers = document.querySelectorAll(".js-modal-trigger");
            const closeBtns = document.querySelectorAll(".delete, .modal-cancel, .modal-background");
            
            triggers.forEach(t => t.addEventListener("click", () => {
                document.getElementById(t.dataset.target).classList.add("is-active");
            }));

            closeBtns.forEach(b => b.addEventListener("click", () => {
                document.querySelectorAll(".modal").forEach(m => m.classList.remove("is-active"));
            }));

            // Counselor Selection Change Logic
            const counselorSelect = document.getElementById("counselor-select");
            const slotSelect = document.getElementById("slot-select");
            const issueSelect = document.getElementById("issue-type-select");

            counselorSelect.addEventListener("change", async function() {
                const counselorId = this.value;
                const selectedOption = this.options[this.selectedIndex];
                const spec = selectedOption.getAttribute("data-spec");

                // 1. Auto-set Issue Type based on counselor's specialty
                if(spec) {
                    issueSelect.value = spec;
                }

                // 2. Clear and Disable Slot Select if no counselor
                slotSelect.innerHTML = '<option value="">-- Select a Slot --</option>';
                if (!counselorId) {
                    slotSelect.disabled = true;
                    return;
                }

                // 3. Fetch Slots via AJAX (Calling our no-Gson Servlet)
                try {
                    const response = await fetch('GetAvailableSlotsServlet?counselorId=' + counselorId);
                    const slots = await response.json();
                    
                    if (slots.length === 0) {
                        slotSelect.innerHTML = '<option value="">No slots available</option>';
                        slotSelect.disabled = true;
                    } else {
                        slots.forEach(slot => {
                            const opt = document.createElement('option');
                            opt.value = slot.id;
                            opt.textContent = slot.timeLabel;
                            slotSelect.appendChild(opt);
                        });
                        slotSelect.disabled = false;
                    }
                } catch (e) {
                    console.error("AJAX Error:", e);
                    slotSelect.innerHTML = '<option value="">Error loading slots</option>';
                }
            });
        });
    </script>
</body>
</html>