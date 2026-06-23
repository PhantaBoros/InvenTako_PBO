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
import model.Product;

public class ProductDAO {
    // Ambil semua produk milik manager tertentu
    public List<Product> getAll(int managerId) {
        List<Product> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT * FROM products WHERE manager_id = ? ORDER BY nama ASC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, managerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setKode(rs.getString("kode"));
                p.setNama(rs.getString("nama"));
                p.setKategori(rs.getString("kategori"));
                p.setHarga(rs.getLong("harga"));
                p.setStok(rs.getInt("stok"));
                p.setManagerId(rs.getInt("manager_id"));
                
                list.add(p);
            }
        } catch (Exception e) {
            System.out.println("Error di getAll Produk: " + e.getMessage());
        }
        return list;
    }

    // Cek apakah kode barang sudah ada di toko manager ini
    public boolean isKodeExists(String kode, int managerId) {
        boolean exists = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM products WHERE kode = ? AND manager_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, kode);
            ps.setInt(2, managerId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            System.out.println("Error di isKodeExists: " + e.getMessage());
        }
        return exists;
    }

    // Cek duplikat kode, tapi abaikan barang yang sedang diedit (excludeId)
    public boolean isKodeExistsExcept(String kode, int managerId, int excludeId) {
        boolean exists = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM products WHERE kode = ? AND manager_id = ? AND id != ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, kode);
            ps.setInt(2, managerId);
            ps.setInt(3, excludeId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            System.out.println("Error di isKodeExistsExcept: " + e.getMessage());
        }
        return exists;
    }

    // Insert produk baru, otomatis set manager_id
    public boolean insert(Product p) {
        boolean berhasil = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "INSERT INTO products (kode, nama, kategori, harga, stok, manager_id) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setString(1, p.getKode());
            ps.setString(2, p.getNama());
            ps.setString(3, p.getKategori());
            ps.setLong(4, p.getHarga());
            ps.setInt(5, p.getStok());
            ps.setInt(6, p.getManagerId());
            
            int jumlahBaris = ps.executeUpdate();
            if (jumlahBaris > 0) {
                berhasil = true;
            }
        } catch (Exception e) {
            System.out.println("Error di insert Produk: " + e.getMessage());
        }
        return berhasil;
    }

    // Update produk — hanya bisa edit barang milik manager sendiri
    public boolean update(Product p) {
        boolean berhasil = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "UPDATE products SET kode=?, nama=?, kategori=?, harga=?, stok=? WHERE id=? AND manager_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setString(1, p.getKode());
            ps.setString(2, p.getNama());
            ps.setString(3, p.getKategori());
            ps.setLong(4, p.getHarga());
            ps.setInt(5, p.getStok());
            ps.setInt(6, p.getId());
            ps.setInt(7, p.getManagerId());
            
            int jumlahBaris = ps.executeUpdate();
            if (jumlahBaris > 0) {
                berhasil = true;
            }
        } catch (Exception e) {
            System.out.println("Error di update Produk: " + e.getMessage());
        }
        return berhasil;
    }

    // Delete produk — hanya bisa hapus barang milik manager sendiri
    public boolean delete(int id, int managerId) {
        boolean berhasil = false;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "DELETE FROM products WHERE id=? AND manager_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.setInt(2, managerId);
            
            int jumlahBaris = ps.executeUpdate();
            if (jumlahBaris > 0) {
                berhasil = true;
            }
        } catch (Exception e) {
            System.out.println("Error di delete Produk: " + e.getMessage());
        }
        return berhasil;
    }

    // Hitung total stok hanya untuk toko manager tersebut
    public int getTotalStok(int managerId) {
        int total = 0;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT COALESCE(SUM(stok), 0) FROM products WHERE manager_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, managerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (Exception e) {
            System.out.println("Error di getTotalStok: " + e.getMessage());
        }
        return total;
    }
}
