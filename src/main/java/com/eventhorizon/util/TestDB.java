package com.eventhorizon.util;

public class TestDB {
    public static void main(String[] args) {
        if (DatabaseConnection.testConnection()) {
            System.out.println("SUCCESS: Database connected!");
        } else {
            System.out.println("FAILED: Database not connected!");
        }
    }
}