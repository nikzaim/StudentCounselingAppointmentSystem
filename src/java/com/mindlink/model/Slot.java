/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mindlink.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 *
 * @author nikza
 */
public class Slot implements Serializable {
    private int id;
    private int counselorId;
    private Timestamp startTime;
    private Timestamp endTime;
    private boolean available;

    // Formatting Helpers
    private static final SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM yyyy");
    private static final SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
    private static final SimpleDateFormat isoDate = new SimpleDateFormat("yyyy-MM-dd");
    private static final SimpleDateFormat isoTime = new SimpleDateFormat("HH:mm");

    public String getDisplayDate() { return startTime != null ? dateFmt.format(startTime) : "-"; }
    public String getDisplayStart() { return startTime != null ? timeFmt.format(startTime) : "-"; }
    public String getDisplayEnd() { return endTime != null ? timeFmt.format(endTime) : "-"; }
    
    public String getRawDate() { return startTime != null ? isoDate.format(startTime) : ""; }
    public String getRawStart() { return startTime != null ? isoTime.format(startTime) : ""; }
    public String getRawEnd() { return endTime != null ? isoTime.format(endTime) : ""; }

    // Standard Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCounselorId() { return counselorId; }
    public void setCounselorId(int counselorId) { this.counselorId = counselorId; }
    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }
    public Timestamp getEndTime() { return endTime; }
    public void setEndTime(Timestamp endTime) { this.endTime = endTime; }
    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }
}
