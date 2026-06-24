/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import database.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.security.MessageDigest;
import model.Admin;
import model.Kasir;
import model.Manager;
import model.User;
/**
 *
 * @author Muhammad Sabiq AZ
 */
public class UserDAO {
    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            System.out.println("Error hashing password: " + e.getMessage());
            return password; // fallback: kembalikan plain text jika gagal
        }
    }
    // Fungsi untuk mengecek apakah email sudah terdaftar di database
    public boolean cekEmailAda(String email) {
        boolean ada = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT id FROM users WHERE email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ada = true;
            }
        } catch (Exception e) {
            System.out.println("Error di cekEmailAda: " + e.getMessage());
        }
        return ada;
    }

    public User login(String email, String password) {
        User user = null;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT * FROM users WHERE email=? AND password=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, hashPassword(password));
            
            ResultSet rs = ps.executeQuery();
            
            // Kalau data ketemu, masukkan ke objek turunan yang sesuai (Polymorphism)
            if (rs.next()) {
                String role = rs.getString("role");
                
                if ("manager".equals(role)) {
                    user = new Manager();
                } else if ("kasir".equals(role)) {
                    user = new Kasir();
                } else if ("admin".equals(role)) {
                    user = new Admin();
                }

                if (user != null) {
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setRole(role);
                    user.setShift(rs.getString("shift"));
                    user.setManagerId(rs.getInt("manager_id"));
                    user.setStatus(rs.getString("status"));
                }
            }
        } catch (Exception e) {
            System.out.println("Error di login: " + e.getMessage());
        }
        return user;
    }

    public boolean register(User u) {
        boolean berhasil = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            // Manager register dengan status 'pending', harus di-approve admin
            String sql = "INSERT INTO users (username, email, password, role, status) VALUES (?, ?, ?, ?, 'pending')";
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setString(1, u.getUsername());
            ps.setString(2, u.getEmail());
            ps.setString(3, hashPassword(u.getPassword()));
            ps.setString(4, u.getRole());
            
            int jumlahBaris = ps.executeUpdate();
            if (jumlahBaris > 0) {
                berhasil = true;
            }
        } catch (Exception e) {
            System.out.println("Error di register: " + e.getMessage());
        }
        return berhasil;
    }

    // Tambah kasir dan langsung assign ke manager (toko) yang menambahkan
    public boolean tambahKasir(User u) {
        boolean berhasil = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "INSERT INTO users (username, email, password, role, shift, manager_id) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setString(1, u.getUsername());
            ps.setString(2, u.getEmail());
            ps.setString(3, hashPassword(u.getPassword()));
            ps.setString(4, u.getRole());
            ps.setString(5, u.getShift());
            ps.setInt(6, u.getManagerId());
            
            int jumlahBaris = ps.executeUpdate();
            if (jumlahBaris > 0) {
                berhasil = true;
            }
        } catch (Exception e) {
            System.out.println("Error di tambahKasir: " + e.getMessage());
        }
        return berhasil;
    }

    // Ambil hanya kasir yang terdaftar di toko manager ini
    public List<Kasir> getAllKasir(int managerId) {
        List<Kasir> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT * FROM users WHERE role = 'kasir' AND manager_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, managerId);
            ResultSet rs = ps.executeQuery();
            
            // Looping untuk memasukkan data dari database ke dalam List
            while (rs.next()) {
                Kasir k = new Kasir();
                k.setId(rs.getInt("id"));
                k.setUsername(rs.getString("username"));
                k.setEmail(rs.getString("email"));
                k.setRole(rs.getString("role"));
                k.setShift(rs.getString("shift"));
                k.setManagerId(rs.getInt("manager_id"));
                
                list.add(k);
            }
        } catch (Exception e) {
            System.out.println("Error di getAllKasir: " + e.getMessage());
        }
        return list;
    }

    // Hapus kasir hanya jika kasir tersebut terdaftar di toko manager ini
    public boolean deleteKasir(int id, int managerId) {
        boolean berhasil = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "DELETE FROM users WHERE id=? AND role='kasir' AND manager_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.setInt(2, managerId);
            int jumlahBaris = ps.executeUpdate();
            if (jumlahBaris > 0) {
                berhasil = true;
            }
        } catch (Exception e) {
            System.out.println("Error di deleteKasir: " + e.getMessage());
        }
        return berhasil;
    }

    // Ambil semua user dengan status pending (untuk admin approve/decline)
    public List<User> getPendingUsers() {
        List<User> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT * FROM users WHERE status='pending' ORDER BY id DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                String roleStr = rs.getString("role");
                User u = null;
                if ("manager".equals(roleStr)) {
                    u = new Manager();
                } else if ("kasir".equals(roleStr)) {
                    u = new Kasir();
                } else if ("admin".equals(roleStr)) {
                    u = new Admin();
                }
                
                if (u != null) {
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setRole(roleStr);
                    u.setStatus(rs.getString("status"));
                    
                    list.add(u);
                }
            }
        } catch (Exception e) {
            System.out.println("Error di getPendingUsers: " + e.getMessage());
        }
        return list;
    }

    // Update status user (approve atau decline)
    public boolean updateUserStatus(int id, String status) {
        boolean berhasil = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            // Jika decline, hapus user; jika approve, ubah status jadi 'approved'
            if ("decline".equals(status)) {
                String sql = "DELETE FROM users WHERE id=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, id);
                int jumlahBaris = ps.executeUpdate();
                if (jumlahBaris > 0) {
                    berhasil = true;
                }
            } else if ("approved".equals(status)) {
                String sql = "UPDATE users SET status=? WHERE id=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, "approved");
                ps.setInt(2, id);
                int jumlahBaris = ps.executeUpdate();
                if (jumlahBaris > 0) {
                    berhasil = true;
                }
            }
        } catch (Exception e) {
            System.out.println("Error di updateUserStatus: " + e.getMessage());
        }
        return berhasil;
    }
}
