package com.dao;

import com.connection.DBConnection;
import com.model.User;
import java.sql.*;

public class UserDAO {

    // 1. FUNGSI UNTUK DAFTAR PENGGUNA BARU
    public boolean register(User user) {
        try {
            Connection conn = DBConnection.getConnection();

            String sql = "INSERT INTO users(username, email, password) VALUES(?,?,?)";

            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());

            return ps.executeUpdate() > 0;

        } catch(Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 2. FUNGSI UNTUK LOG MASUK (MENYOKONG USERNAME ATAU EMAIL)
    public User login(String usernameOrEmail, String password) {
        try {
            Connection conn = DBConnection.getConnection();

            // Menyemak kolum username ATAU email
            String sql = "SELECT * FROM users WHERE (username=? OR email=?) AND password=?";

            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, usernameOrEmail); // Semak kolum username
            ps.setString(2, usernameOrEmail); // Semak kolum email
            ps.setString(3, password);        // Semak kolum password

            ResultSet rs = ps.executeQuery();

            if(rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                return user;
            }

        } catch(Exception e) {
            e.printStackTrace();
        }

        return null;
    }
} // Pastikan kurungan penutup kelas ini ada!