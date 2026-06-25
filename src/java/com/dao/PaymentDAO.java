package com.dao;

import com.connection.DBConnection;
import java.sql.*;

public class PaymentDAO {

    public boolean savePayment(
            String orderId,
            String method,
            double amount) {

        try {

            Connection conn =
                    DBConnection.getConnection();

            String sql =
                    "INSERT INTO payments(order_id,method,amount,status) VALUES(?,?,?,?)";

            PreparedStatement ps =
                    conn.prepareStatement(sql);

            ps.setString(1, orderId);
            ps.setString(2, method);
            ps.setDouble(3, amount);
            ps.setString(4, "PAID");

            return ps.executeUpdate() > 0;

        } catch(Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}