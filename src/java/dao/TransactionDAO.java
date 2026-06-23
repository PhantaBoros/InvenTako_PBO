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
import model.Transaction;
import model.TransactionDetail;

public class TransactionDAO {
    // Get all Transactions milik toko manager ini
    // Filter: kasir yang melakukan transaksi harus punya manager_id yang sama
    public List<Transaction> getAll(int managerId) {
        List<Transaction> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT t.*, u.username AS kasir_name "
                       + "FROM transactions t "
                       + "LEFT JOIN users u ON t.kasir_id = u.id "
                       + "WHERE u.manager_id = ? "
                       + "ORDER BY t.tanggal DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, managerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setNoNota(rs.getString("no_nota"));
                t.setTanggal(rs.getString("tanggal"));
                t.setTotalBelanja(rs.getLong("total_belanja"));
                t.setUangTunai(rs.getLong("uang_tunai"));
                t.setKembalian(rs.getLong("kembalian"));
                t.setStatus(rs.getString("status"));
                t.setKasirName(rs.getString("kasir_name"));
                
                list.add(t);
            }
        } catch (Exception e) {
            System.out.println("Error di getAll Transaction: " + e.getMessage());
        }
        return list;
    }

    // Search Transactions — hanya dalam lingkup toko manager ini
    public List<Transaction> search(String noNota, String tanggal, int managerId) {
        List<Transaction> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT t.*, u.username AS kasir_name "
                       + "FROM transactions t "
                       + "LEFT JOIN users u ON t.kasir_id = u.id "
                       + "WHERE u.manager_id = ?";
            
            // Tambahkan filter jika tidak kosong
            if (noNota != null && !noNota.isEmpty()) {
                sql += " AND t.no_nota LIKE ?";
            }
            if (tanggal != null && !tanggal.isEmpty()) {
                sql += " AND DATE(t.tanggal) = ?";
            }
            sql += " ORDER BY t.tanggal DESC";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            
            // Atur urutan tanda tanya (?)
            int paramIndex = 1;
            ps.setInt(paramIndex++, managerId);
            if (noNota != null && !noNota.isEmpty()) {
                ps.setString(paramIndex++, "%" + noNota + "%");
            }
            if (tanggal != null && !tanggal.isEmpty()) {
                ps.setString(paramIndex, tanggal);
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setNoNota(rs.getString("no_nota"));
                t.setTanggal(rs.getString("tanggal"));
                t.setTotalBelanja(rs.getLong("total_belanja"));
                t.setUangTunai(rs.getLong("uang_tunai"));
                t.setKembalian(rs.getLong("kembalian"));
                t.setStatus(rs.getString("status"));
                t.setKasirName(rs.getString("kasir_name"));
                
                list.add(t);
            }
        } catch (Exception e) {
            System.out.println("Error di search Transaction: " + e.getMessage());
        }
        return list;
    }

    // Total pendapatan hanya dari kasir di toko manager ini
    public long getTotalRevenue(int managerId) {
        long total = 0;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT COALESCE(SUM(t.total_belanja), 0) "
                       + "FROM transactions t "
                       + "LEFT JOIN users u ON t.kasir_id = u.id "
                       + "WHERE u.manager_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, managerId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                total = rs.getLong(1);
            }
        } catch (Exception e) {
            System.out.println("Error di getTotalRevenue: " + e.getMessage());
        }
        return total;
    }

    // Jumlah transaksi hanya dari kasir di toko manager ini
    public int getTotalCount(int managerId) {
        int count = 0;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT COUNT(*) "
                       + "FROM transactions t "
                       + "LEFT JOIN users u ON t.kasir_id = u.id "
                       + "WHERE u.manager_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, managerId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            System.out.println("Error di getTotalCount: " + e.getMessage());
        }
        return count;
    }

    // Top Products — hanya dari transaksi kasir di toko manager ini
    public List<Object[]> getTopProducts(int limit, int managerId) {
        List<Object[]> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT td.nama_barang, SUM(td.qty) AS total_qty "
                       + "FROM transaction_details td "
                       + "JOIN transactions t ON td.transaction_id = t.id "
                       + "JOIN users u ON t.kasir_id = u.id "
                       + "WHERE u.manager_id = ? "
                       + "GROUP BY td.nama_barang "
                       + "ORDER BY total_qty DESC "
                       + "LIMIT ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, managerId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Object[] data = new Object[2];
                data[0] = rs.getString("nama_barang");
                data[1] = rs.getLong("total_qty");
                list.add(data);
            }
        } catch (Exception e) {
            System.out.println("Error di getTopProducts: " + e.getMessage());
        }
        return list;
    }

    // Data transaksi per shift — untuk chart dashboard
    public List<Object[]> getShiftData(int managerId) {
        List<Object[]> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT "
                       + "CASE "
                       + "  WHEN HOUR(t.tanggal) >= 6  AND HOUR(t.tanggal) < 12 THEN 'Pagi' "
                       + "  WHEN HOUR(t.tanggal) >= 12 AND HOUR(t.tanggal) < 17 THEN 'Siang' "
                       + "  WHEN HOUR(t.tanggal) >= 17 AND HOUR(t.tanggal) < 21 THEN 'Sore' "
                       + "  ELSE 'Malam' "
                       + "END AS shift_name, "
                       + "COUNT(*) AS jumlah "
                       + "FROM transactions t "
                       + "JOIN users u ON t.kasir_id = u.id "
                       + "WHERE u.manager_id = ? "
                       + "GROUP BY shift_name "
                       + "ORDER BY FIELD(shift_name, 'Pagi', 'Siang', 'Sore', 'Malam')";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, managerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Object[] data = new Object[2];
                data[0] = rs.getString("shift_name");
                data[1] = rs.getInt("jumlah");
                list.add(data);
            }
        } catch (Exception e) {
            System.out.println("Error di getShiftData: " + e.getMessage());
        }
        return list;
    }

    // Ambil satu transaksi berdasarkan id — divalidasi juga bahwa kasir milik manager ini
    public Transaction getById(int id, int managerId) {
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT t.*, u.username AS kasir_name "
                       + "FROM transactions t "
                       + "LEFT JOIN users u ON t.kasir_id = u.id "
                       + "WHERE t.id = ? AND u.manager_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.setInt(2, managerId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setNoNota(rs.getString("no_nota"));
                t.setTanggal(rs.getString("tanggal"));
                t.setTotalBelanja(rs.getLong("total_belanja"));
                t.setUangTunai(rs.getLong("uang_tunai"));
                t.setKembalian(rs.getLong("kembalian"));
                t.setStatus(rs.getString("status"));
                t.setKasirName(rs.getString("kasir_name"));
                return t;
            }
        } catch (Exception e) {
            System.out.println("Error di getById Transaction: " + e.getMessage());
        }
        return null;
    }

    // Get All Detail Transactions (tidak perlu filter manager — sudah lewat transaction_id)
    public List<TransactionDetail> getDetailByTransactionId(int transactionId) {
        List<TransactionDetail> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT * FROM transaction_details WHERE transaction_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, transactionId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                TransactionDetail td = new TransactionDetail();
                td.setId(rs.getInt("id"));
                td.setTransactionId(rs.getInt("transaction_id"));
                td.setNamaBarang(rs.getString("nama_barang"));
                td.setQty(rs.getInt("qty"));
                td.setHargaSatuan(rs.getLong("harga_satuan"));
                td.setSubtotal(rs.getLong("subtotal"));
                
                list.add(td);
            }
        } catch (Exception e) {
            System.out.println("Error di getDetailByTransactionId: " + e.getMessage());
        }
        return list;
    }
}
