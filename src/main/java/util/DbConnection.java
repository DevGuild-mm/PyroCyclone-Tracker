package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DbConnection {
    private static Connection connection = null;

    public static Connection openConnection() {
        try {
            // mysql-connector-j 8.3.0 uses com.mysql.cj.jdbc.Driver
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
            } catch (ClassNotFoundException e) {
                Class.forName("com.mysql.jdbc.Driver");
            }
            connection = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/your_database_name",
                    "your_username",
                    "your_password"
            );
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return connection;
    }
}