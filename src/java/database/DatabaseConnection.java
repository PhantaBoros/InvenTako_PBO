/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package database;

import java.sql.Connection;
import java.sql.DriverManager;

public class DatabaseConnection {
    private static final String URL  = "jdbc:mysql://localhost:3306/inventakoo";
    private static final String USER = "root";
    private static final String PASS = "";

    public static Connection getConnection() {
        Connection conn = null;
        try {
            // Wajib didaftarkan agar Apache Tomcat mengenali driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Membuka jalan/koneksi ke database
            conn = DriverManager.getConnection(URL, USER, PASS);
            
            // Pesan ini akan muncul di output NetBeans bawah kalau koneksinya sukses
            System.out.println("Koneksi Database Berhasil!");
            
        } catch (Exception e) {
            System.out.println("Koneksi Database Gagal: " + e.getMessage());
        }
        return conn;
    }
}
