/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mindlink.dao;

import com.mindlink.utils.DBConnection;
import com.mindlink.model.Appointment;
import java.sql.*;
import java.util.List;
import java.util.ArrayList;
/**
 *
 * @author nikza
 */
public class AppointmentDAO {
    public List<Appointment> getAppointmentsByUserId(int userId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, c.full_name, s.start_time " +
                     "FROM appointments a " +
                     "JOIN counseling_slots s ON a.slot_id = s.id " +
                     "JOIN counselors c ON s.counselor_id = c.id " +
                     "JOIN students st ON a.student_id = st.id " +
                     "WHERE st.user_id = ? " +
                     "ORDER BY s.start_time DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Appointment app = new Appointment();
                app.setId(rs.getInt("id"));
                app.setCounselorName(rs.getString("full_name"));
                app.setStartTime(rs.getTimestamp("start_time"));
                app.setIssueType(rs.getString("issue_type"));
                app.setDescription(rs.getString("description"));
                app.setStatus(rs.getString("status"));
                list.add(app);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public boolean bookAppointment(int userId, int slotId, String issueType, String description) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Get the actual student_id
            int actualStudentId = -1;
            String sqlGetId = "SELECT id FROM students WHERE user_id = ?";
            PreparedStatement psGetId = conn.prepareStatement(sqlGetId);
            psGetId.setInt(1, userId);
            ResultSet rs = psGetId.executeQuery();

            if (rs.next()) {
                actualStudentId = rs.getInt("id");
            } else {
                return false;
            }

            // 2. Insert Appointment
            String sqlAppt = "INSERT INTO appointments (student_id, slot_id, issue_type, description, status) VALUES (?, ?, ?, ?, 'PENDING')";
            PreparedStatement psAppt = conn.prepareStatement(sqlAppt);
            psAppt.setInt(1, actualStudentId);
            psAppt.setInt(2, slotId);
            psAppt.setString(3, issueType);
            psAppt.setString(4, description);
            psAppt.executeUpdate();

            // 3. Update Slot Availability
            String sqlSlot = "UPDATE counseling_slots SET is_available = false WHERE id = ?";
            PreparedStatement psSlot = conn.prepareStatement(sqlSlot);
            psSlot.setInt(1, slotId);
            psSlot.executeUpdate();

            conn.commit();
            return true;

        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
    
    public boolean handleAppointmentAction(int appId, String action) {
        Connection conn = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psRelease = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); 

            // 1. Update Status (Works for CANCELLED, REJECTED, ACCEPTED, COMPLETED)
            String sqlUpdate = "UPDATE appointments SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
            psUpdate = conn.prepareStatement(sqlUpdate);
            psUpdate.setString(1, action.toUpperCase());
            psUpdate.setInt(2, appId);
            psUpdate.executeUpdate();

            // 2. Release Slot Logic
            // If the student cancels OR the counselor rejects, the slot becomes available again
            if ("REJECTED".equalsIgnoreCase(action) || "CANCELLED".equalsIgnoreCase(action)) {
                String sqlRelease = "UPDATE counseling_slots SET is_available = true, updated_at = CURRENT_TIMESTAMP " +
                                    "WHERE id = (SELECT slot_id FROM appointments WHERE id = ?)";
                psRelease = conn.prepareStatement(sqlRelease);
                psRelease.setInt(1, appId);
                psRelease.executeUpdate();
            }

            conn.commit(); 
            return true;

        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        } finally {
            if (psUpdate != null) try { psUpdate.close(); } catch (SQLException e) {}
            if (psRelease != null) try { psRelease.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}
