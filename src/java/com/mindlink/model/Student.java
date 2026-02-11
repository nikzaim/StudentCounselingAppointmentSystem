/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mindlink.model;

import java.io.Serializable;

/**
 *
 * @author nikza
 */
public class Student implements Serializable {
    private int userId;
    private String fullName;
    private String studentIdCard;
    private String major;
    private String email;
    private String phoneNumber;

    // Constructors
    public Student() {}

    // Getters and Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getStudentIdCard() { return studentIdCard; }
    public void setStudentIdCard(String studentIdCard) { this.studentIdCard = studentIdCard; }

    public String getMajor() { return major; }
    public void setMajor(String major) { this.major = major; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
}
