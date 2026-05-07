package com.eventhorizon.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    private static final String LOCAL_URL =
            "jdbc:mysql://localhost:3307/eventhorizon_db"
                    + "?useSSL=false&allowPublicKeyRetrieval=true"
                    + "&serverTimezone=Asia/Colombo";

    private static final String LOCAL_USERNAME = "root";
    private static final String LOCAL_PASSWORD = "";


    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found: " + e.getMessage());
        }

        String host = System.getenv("MYSQLHOST");

        if (host != null && !host.trim().isEmpty()) {
            String port = System.getenv("MYSQLPORT");
            String database = System.getenv("MYSQLDATABASE");
            String username = System.getenv("MYSQLUSER");
            String password = System.getenv("MYSQLPASSWORD");

            if (port == null || database == null || username == null || password == null) {
                throw new SQLException("Railway MySQL environment variables are missing.");
            }

            String railwayUrl =
                    "jdbc:mysql://" + host + ":" + port + "/" + database
                            + "?useSSL=false&allowPublicKeyRetrieval=true"
                            + "&serverTimezone=UTC";

            return DriverManager.getConnection(railwayUrl, username, password);
        }

        return DriverManager.getConnection(LOCAL_URL, LOCAL_USERNAME, LOCAL_PASSWORD);
    }

    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("DB connection failed: " + e.getMessage());
            return false;
        }
    }
}