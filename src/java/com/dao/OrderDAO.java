package com.dao;

import com.connection.DBConnection;
import java.sql.*;

public class OrderDAO {

    public boolean saveOrder(
            String orderId,
            double total) {

        try {

            Connection conn =
                    DBConnection.getConnection();

            String sql =
                    "INSERT INTO orders(order_id,total,status) VALUES(?,?,?)";

            PreparedStatement ps =
                    conn.prepareStatement(sql);

            ps.setString(1, orderId);
            ps.setDouble(2, total);
            ps.setString(3, "PENDING");

            return ps.executeUpdate() > 0;

        } catch(Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}