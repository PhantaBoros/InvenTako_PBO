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

/**
 *
 * @author Muhammad Sabiq AZ
 */
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
