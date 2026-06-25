package com.dao;

import com.connection.DBConnection;
import com.model.Menu;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MenuDAO {

    public List<Menu> getAllMenus() {
        List<Menu> list = new ArrayList<>();

        String sql = "SELECT id, item_name, category, price, image, description, status FROM menu WHERE status='Available' ORDER BY category, item_name";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return list;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Menu m = new Menu();
                    m.setId(rs.getInt("id"));
                    m.setName(rs.getString("item_name"));
                    m.setCategory(rs.getString("category"));
                    m.setPrice(rs.getDouble("price"));
                    m.setImage(rs.getString("image"));
                    m.setDescription(rs.getString("description"));
                    m.setStatus(rs.getString("status"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
