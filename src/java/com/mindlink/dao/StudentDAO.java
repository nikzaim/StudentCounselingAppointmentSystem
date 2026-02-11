/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mindlink.dao;

import com.mindlink.model.Student;
import com.mindlink.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author nikza
 */
public class StudentDAO {
    public boolean registerStudent(String username, String password, String fullName, String idCard, String major) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // 1. Insert into users table
            String sqlUser = "INSERT INTO users (username, password, role) VALUES (?, ?, 'student')";
            PreparedStatement psUser = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, username);
            psUser.setString(2, password);
            psUser.executeUpdate();

            // Get the generated user_id
            ResultSet rs = psUser.getGeneratedKeys();
            if (rs.next()) {
                int userId = rs.getInt(1);

                // 2. Insert into students table
                String sqlStudent = "INSERT INTO students (user_id, student_id_card, full_name, major) VALUES (?, ?, ?, ?)";
                PreparedStatement psStudent = conn.prepareStatement(sqlStudent);
                psStudent.setInt(1, userId);
                psStudent.setString(2, idCard);
                psStudent.setString(3, fullName);
                psStudent.setString(4, major);
                psStudent.executeUpdate();
            }

            conn.commit(); // Save changes
            return true;
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
            e.printStackTrace();
            return false;
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    public boolean updateStudentProfile(int userId, String fullName, String email, String phone, String major, String bio) {
        String sql = "UPDATE students SET full_name = ?, email = ?, phone_number = ?, "
                   + "major = ?, bio = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, (email == null || email.trim().isEmpty()) ? null : email);
            ps.setString(3, (phone == null || phone.trim().isEmpty()) ? null : phone);
            ps.setString(4, (major == null || major.trim().isEmpty()) ? null : major);
            ps.setString(5, (bio == null || bio.trim().isEmpty()) ? null : bio);
            ps.setInt(6, userId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Student> getAllStudents() {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT user_id, full_name, student_id_card, major, email, phone_number FROM students";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Student s = new Student();
                s.setUserId(rs.getInt("user_id"));
                s.setFullName(rs.getString("full_name"));
                s.setStudentIdCard(rs.getString("student_id_card"));
                s.setMajor(rs.getString("major"));
                s.setEmail(rs.getString("email"));
                s.setPhoneNumber(rs.getString("phone_number"));
                students.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return students;
    }
}
