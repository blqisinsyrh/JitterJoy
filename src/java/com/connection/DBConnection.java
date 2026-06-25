package com.connection;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String USER = "root";
    private static final String PASSWORD = "";

    // Main database name used by db.jsp / local XAMPP setup.
    private static final String[] URLS = {
        "jdbc:mysql://localhost:3307/JJ?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
        "jdbc:mysql://localhost:3307/JJ?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
        "jdbc:mysql://localhost:3307/JJ?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
    };

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Exception lastError = null;

            for (String url : URLS) {
                try {
                    return DriverManager.getConnection(url, USER, PASSWORD);
                } catch (Exception e) {
                    lastError = e;
                }
            }

            if (lastError != null) {
                lastError.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
