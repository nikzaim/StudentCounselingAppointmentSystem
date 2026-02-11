/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mindlink.dao;

import com.mindlink.model.Counselor;
import com.mindlink.utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author nikza
 */
public class CounselorDAO {
    public boolean registerCounselor(String username, String password, String fullName, String specialization, String office) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // 1. Insert into users table
            String sqlUser = "INSERT INTO users (username, password, role) VALUES (?, ?, 'counselor')";
            PreparedStatement psUser = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, username);
            psUser.setString(2, password);
            psUser.executeUpdate();

            ResultSet rs = psUser.getGeneratedKeys();
            if (rs.next()) {
                int userId = rs.getInt(1);

                // 2. Insert into counselors table
                String sqlCounselor = "INSERT INTO counselors (user_id, full_name, specialization, office_location) VALUES (?, ?, ?, ?)";
                PreparedStatement psCounselor = conn.prepareStatement(sqlCounselor);
                psCounselor.setInt(1, userId);
                psCounselor.setString(2, fullName);
                psCounselor.setString(3, specialization);
                psCounselor.setString(4, office);
                psCounselor.executeUpdate();
            }

            conn.commit(); 
            return true;
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
            e.printStackTrace();
            return false;
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    public boolean updateCounselorProfile(int userId, String fullName, String email, String phone, String spec, String office, String bio) {
        String sql = "UPDATE counselors SET full_name=?, email=?, phone_number=?, specialization=?, "
                   + "office_location=?, bio=?, updated_at=CURRENT_TIMESTAMP WHERE user_id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, (email == null || email.isEmpty()) ? null : email);
            ps.setString(3, (phone == null || phone.isEmpty()) ? null : phone);
            ps.setString(4, (spec == null || spec.isEmpty()) ? null : spec);
            ps.setString(5, (office == null || office.isEmpty()) ? null : office);
            ps.setString(6, (bio == null || bio.isEmpty()) ? null : bio);
            ps.setInt(7, userId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Counselor> getAllCounselors() {
        List<Counselor> counselors = new ArrayList<>();
        String sql = "SELECT user_id, full_name, specialization, office_location, email, phone_number FROM counselors";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Counselor c = new Counselor();
                c.setUserId(rs.getInt("user_id"));
                c.setFullName(rs.getString("full_name"));
                c.setSpecialization(rs.getString("specialization"));
                c.setOfficeLocation(rs.getString("office_location"));
                c.setEmail(rs.getString("email"));
                c.setPhoneNumber(rs.getString("phone_number"));
                counselors.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return counselors;
    }
}
