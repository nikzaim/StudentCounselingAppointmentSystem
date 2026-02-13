/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mindlink.dao;

import com.mindlink.model.Slot;
import com.mindlink.utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author nikza
 */
public class SlotDAO {

    // Helper to find the Counselor Table ID from the User Table ID
    private int getCounselorIdByUserId(Connection conn, int userId) throws SQLException {
        String sql = "SELECT ID FROM COUNSELORS WHERE USER_ID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("ID");
            }
        }
        return -1;
    }

    public List<Slot> getSlotsByUserId(int userId) {
        List<Slot> slots = new ArrayList<>();
        String sql = "SELECT s.* FROM counseling_slots s JOIN counselors c ON s.counselor_id = c.id " +
                     "WHERE c.user_id = ? ORDER BY s.start_time DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Slot slot = new Slot();
                    slot.setId(rs.getInt("id"));
                    slot.setCounselorId(rs.getInt("counselor_id"));
                    slot.setStartTime(rs.getTimestamp("start_time"));
                    slot.setEndTime(rs.getTimestamp("end_time"));
                    slot.setAvailable(rs.getBoolean("is_available"));
                    slots.add(slot);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return slots;
    }

    public boolean createSlot(int userId, String startStr, String endStr) {
        try (Connection conn = DBConnection.getConnection()) {
            int counselorId = getCounselorIdByUserId(conn, userId);
            if (counselorId == -1) return false;

            String sql = "INSERT INTO counseling_slots (counselor_id, start_time, end_time, is_available) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, counselorId);
                ps.setTimestamp(2, Timestamp.valueOf(startStr));
                ps.setTimestamp(3, Timestamp.valueOf(endStr));
                ps.setBoolean(4, true);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateSlot(int userId, int slotId, String startStr, String endStr) {
        try (Connection conn = DBConnection.getConnection()) {
            int counselorId = getCounselorIdByUserId(conn, userId);
            String sql = "UPDATE counseling_slots SET start_time = ?, end_time = ? " +
                         "WHERE id = ? AND counselor_id = ? AND is_available = true";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setTimestamp(1, Timestamp.valueOf(startStr));
                ps.setTimestamp(2, Timestamp.valueOf(endStr));
                ps.setInt(3, slotId);
                ps.setInt(4, counselorId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean deleteSlot(int userId, int slotId) {
        try (Connection conn = DBConnection.getConnection()) {
            int counselorId = getCounselorIdByUserId(conn, userId);
            String sql = "DELETE FROM counseling_slots WHERE id = ? AND counselor_id = ? AND is_available = true";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, slotId);
                ps.setInt(2, counselorId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}
