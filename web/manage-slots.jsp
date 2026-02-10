<%@page import="com.mindlink.model.Slot"%>
<%@page import="java.util.List"%>
<%@page import="com.mindlink.model.User"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. Security check: Ensure user is logged in and is a counselor
    User user = (User) session.getAttribute("user");
    if (user == null || !"counselor".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Data Retrieval: Get the list passed from GetSlotsServlet
    List<Slot> slotList = (List<Slot>) request.getAttribute("slotList");
    
    // If a user tries to access this JSP directly without going through the Servlet
    if (slotList == null) {
        response.sendRedirect("manage-slots");
        return;
    }

    // 3. Setup Date Formatters
    SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
    SimpleDateFormat isoDate = new SimpleDateFormat("yyyy-MM-dd"); 
    SimpleDateFormat isoTime = new SimpleDateFormat("HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Slots | MindLink</title>
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
                        <span class="icon has-text-link"><i class="fas fa-chevron-left"></i></span>
                    </a>
                    <div class="ml-3">
                        <h1 class="title">My Availability Slots</h1>
                        <p class="subtitle is-6">Create and manage your consultation hours</p>
                    </div>
                </div>
                <div class="level-right">
                    <button class="button is-link js-modal-trigger" data-target="modal-open-slot">
                        <span class="icon"><i class="fas fa-calendar-plus"></i></span>
                        <span>Open New Slot</span>
                    </button>
                </div>
            </div>

            <%-- Success/Error Alerts --%>
            <% String status = request.getParameter("status"); %>
            <% if ("created".equals(status)) { %>
                <div class="notification is-success">Slot created successfully!</div>
            <% } else if ("updated".equals(status)) { %>
                <div class="notification is-success">Slot updated successfully!</div>
            <% } else if ("deleted".equals(status)) { %>
                <div class="notification is-success">Slot deleted successfully!</div>
            <% } else if ("error".equals(status)) { %>
                <div class="notification is-danger">An error occurred. Please try again.</div>
            <% } %>

            <div class="box">
                <table class="table is-fullwidth is-striped is-hoverable">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Start Time</th>
                            <th>End Time</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (slotList.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="5" class="has-text-centered">No slots created yet.</td>
                            </tr>
                        <%
                            } else {
                                for (Slot s : slotList) {
                                    String dDate = (s.getStartTime() != null) ? dateFmt.format(s.getStartTime()) : "-";
                                    String dStart = (s.getStartTime() != null) ? timeFmt.format(s.getStartTime()) : "-";
                                    String dEnd = (s.getEndTime() != null) ? timeFmt.format(s.getEndTime()) : "-";
                                    
                                    String rawDate = (s.getStartTime() != null) ? isoDate.format(s.getStartTime()) : "";
                                    String rawStart = (s.getStartTime() != null) ? isoTime.format(s.getStartTime()) : "";
                                    String rawEnd = (s.getEndTime() != null) ? isoTime.format(s.getEndTime()) : "";
                        %>
                        <tr>
                            <td><%= dDate %></td>
                            <td><%= dStart %></td>
                            <td><%= dEnd %></td>
                            <td>
                                <% if(s.isAvailable()) { %>
                                    <span class="tag is-success is-light">Available</span>
                                <% } else { %>
                                    <span class="tag is-danger is-light">Booked</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="buttons">
                                    <button class="button is-small is-link js-modal-trigger" 
                                            data-target="modal-edit-slot"
                                            data-id="<%= s.getId() %>"
                                            data-date="<%= rawDate %>"
                                            data-start="<%= rawStart %>"
                                            data-end="<%= rawEnd %>"
                                            <%= !s.isAvailable() ? "disabled" : "" %>>
                                        <span class="icon is-small"><i class="fas fa-edit"></i></span> <span>Edit</span>
                                    </button>
                                    
                                    <form action="DeleteSlotServlet" method="POST" style="display:inline;" onsubmit="return confirm('Delete this slot?');">
                                        <input type="hidden" name="slotId" value="<%= s.getId() %>">
                                        <button type="submit" class="button is-small is-danger" <%= !s.isAvailable() ? "disabled" : "" %>>
                                            <span class="icon is-small"><i class="fas fa-times"></i></span> <span>Remove</span>
                                        </button>
                                    </form>
                                </div>
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

    <%-- Modals remain the same as your original code --%>
    <div id="modal-open-slot" class="modal">
        <div class="modal-background"></div>
        <div class="modal-card">
            <header class="modal-card-head has-background-link">
                <p class="modal-card-title has-text-white">Open New Slot</p>
                <button class="delete" aria-label="close"></button>
            </header>
            <form action="CreateSlotServlet" method="POST">
                <section class="modal-card-body">
                    <div class="field">
                        <label class="label">Date</label>
                        <div class="control"><input class="input" type="date" name="slotDate" required></div>
                    </div>
                    <div class="columns">
                        <div class="column">
                            <label class="label">Start Time</label>
                            <input class="input" type="time" name="startTime" required>
                        </div>
                        <div class="column">
                            <label class="label">End Time</label>
                            <input class="input" type="time" name="endTime" required>
                        </div>
                    </div>
                </section>
                <footer class="modal-card-foot">
                    <button type="submit" class="button is-link">Create Slot</button>
                    <button type="button" class="button modal-cancel">Cancel</button>
                </footer>
            </form>
        </div>
    </div>

    <div id="modal-edit-slot" class="modal">
        <div class="modal-background"></div>
        <div class="modal-card">
            <header class="modal-card-head has-background-link">
                <p class="modal-card-title has-text-white">Update Slot</p>
                <button class="delete" aria-label="close"></button>
            </header>
            <form action="UpdateSlotServlet" method="POST">
                <section class="modal-card-body">
                    <input type="hidden" name="slotId" id="edit-slot-id">
                    <div class="field">
                        <label class="label">Date</label>
                        <input class="input" type="date" name="slotDate" id="edit-slot-date" required>
                    </div>
                    <div class="columns">
                        <div class="column">
                            <label class="label">Start Time</label>
                            <input class="input" type="time" name="startTime" id="edit-slot-start" required>
                        </div>
                        <div class="column">
                            <label class="label">End Time</label>
                            <input class="input" type="time" name="endTime" id="edit-slot-end" required>
                        </div>
                    </div>
                </section>
                <footer class="modal-card-foot">
                    <button type="submit" class="button is-link">Update Changes</button>
                    <button type="button" class="button modal-cancel">Cancel</button>
                </footer>
            </form>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", () => {
            const triggers = document.querySelectorAll(".js-modal-trigger");
            const closeBtns = document.querySelectorAll(".delete, .modal-cancel, .modal-background");

            triggers.forEach(trigger => {
                trigger.addEventListener("click", () => {
                    const modalId = trigger.dataset.target;
                    const modal = document.getElementById(modalId);
                    
                    if(modalId === "modal-edit-slot") {
                        document.getElementById("edit-slot-id").value = trigger.dataset.id;
                        document.getElementById("edit-slot-date").value = trigger.dataset.date;
                        document.getElementById("edit-slot-start").value = trigger.dataset.start;
                        document.getElementById("edit-slot-end").value = trigger.dataset.end;
                    }
                    modal.classList.add("is-active");
                });
            });

            closeBtns.forEach(btn => {
                btn.addEventListener("click", () => {
                    document.querySelectorAll(".modal").forEach(m => m.classList.remove("is-active"));
                });
            });
        });
    </script>
</body>
</html>