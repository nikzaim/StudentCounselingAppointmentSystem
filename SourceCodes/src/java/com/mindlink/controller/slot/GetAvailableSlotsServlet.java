/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mindlink.controller.slot;

import com.mindlink.utils.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author nikza
 */
@WebServlet(name = "GetAvailableSlotsServlet", urlPatterns = {"/GetAvailableSlotsServlet"})
public class GetAvailableSlotsServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet GetAvailableSlotsServlet</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet GetAvailableSlotsServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }
    
    // Simple helper class to structure the JSON
    private class SlotJSON {
        int id;
        String timeLabel;
        SlotJSON(int id, String label) { this.id = id; this.timeLabel = label; }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String counselorIdStr = request.getParameter("counselorId");
        StringBuilder json = new StringBuilder();
        json.append("["); // Start JSON Array

        if (counselorIdStr != null) {
            SimpleDateFormat fmt = new SimpleDateFormat("dd MMM (hh:mm a)");
            
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT id, start_time FROM counseling_slots " +
                             "WHERE counselor_id = ? AND is_available = true " +
                             "AND start_time > CURRENT_TIMESTAMP ORDER BY start_time ASC";
                
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(counselorIdStr));
                ResultSet rs = ps.executeQuery();

                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(","); // Add comma between objects
                    
                    int id = rs.getInt("id");
                    String label = fmt.format(rs.getTimestamp("start_time"));

                    // Manually build JSON Object: {"id": 1, "timeLabel": "25 Jan (09:00 AM)"}
                    json.append("{");
                    json.append("\"id\":").append(id).append(",");
                    json.append("\"timeLabel\":\"").append(label).append("\"");
                    json.append("}");
                    
                    first = false;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        json.append("]"); // End JSON Array

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        processRequest(request, response);
//    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
