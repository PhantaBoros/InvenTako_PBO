package dao;

import database.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;
import model.Product;
import model.Transaction;
import model.TransactionDetail;

public class TransactionDAO {
    private String lastCheckoutError;

    public String getLastCheckoutError() {
        return lastCheckoutError;
    }

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

    public Transaction getById(int transactionId, int managerId) {
        Transaction transaction = null;
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT t.*, u.username AS kasir_name "
                       + "FROM transactions t "
                       + "LEFT JOIN users u ON t.kasir_id = u.id "
                       + "WHERE t.id = ? AND u.manager_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, transactionId);
            ps.setInt(2, managerId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                transaction = new Transaction();
                transaction.setId(rs.getInt("id"));
                transaction.setNoNota(rs.getString("no_nota"));
                transaction.setTanggal(rs.getString("tanggal"));
                transaction.setTotalBelanja(rs.getLong("total_belanja"));
                transaction.setUangTunai(rs.getLong("uang_tunai"));
                transaction.setKembalian(rs.getLong("kembalian"));
                transaction.setStatus(rs.getString("status"));
                transaction.setKasirName(rs.getString("kasir_name"));
            }
        } catch (Exception e) {
            System.out.println("Error di getById Transaction: " + e.getMessage());
        }
        return transaction;
    }

    public int checkout(int kasirId, int managerId, String paymentMethod, List<CartItem> cartItems) {
        lastCheckoutError = null;
        if (cartItems == null || cartItems.isEmpty()) {
            lastCheckoutError = "Keranjang kosong.";
            return -1;
        }

        Connection conn = null;
        PreparedStatement selectProductPs = null;
        PreparedStatement insertTransactionPs = null;
        PreparedStatement insertDetailPs = null;
        PreparedStatement updateStockPs = null;
        ResultSet productRs = null;
        ResultSet generatedKeys = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            String selectProductSql = "SELECT * FROM products WHERE id = ? AND manager_id = ?";
            selectProductPs = conn.prepareStatement(selectProductSql);

            List<Product> products = new ArrayList<>();
            long subtotal = 0;

            for (CartItem item : cartItems) {
                if (item == null || item.getQty() <= 0) {
                    throw new SQLException("Item transaksi tidak valid.");
                }

                selectProductPs.clearParameters();
                selectProductPs.setInt(1, item.getProductId());
                selectProductPs.setInt(2, managerId);
                productRs = selectProductPs.executeQuery();

                if (!productRs.next()) {
                    lastCheckoutError = "Produk tidak ditemukan.";
                    throw new SQLException("Produk tidak ditemukan.");
                }

                Product product = new Product();
                product.setId(productRs.getInt("id"));
                product.setKode(productRs.getString("kode"));
                product.setNama(productRs.getString("nama"));
                product.setKategori(productRs.getString("kategori"));
                product.setHarga(productRs.getLong("harga"));
                product.setStok(productRs.getInt("stok"));
                product.setManagerId(productRs.getInt("manager_id"));

                if (item.getQty() > product.getStok()) {
                    lastCheckoutError = "Stok barang telah habis.";
                    throw new SQLException("Stok tidak cukup untuk barang: " + product.getNama());
                }

                products.add(product);
                subtotal += product.getHarga() * item.getQty();

                productRs.close();
                productRs = null;
            }

            long ppn = Math.round(subtotal * 0.11);
            long totalBelanja = subtotal + ppn;
            long uangTunai = totalBelanja;
            long kembalian = 0;

            String noNota = "NT-" + System.currentTimeMillis();
            String status = "selesai";
            String payment = paymentMethod == null ? "tunai" : paymentMethod.toLowerCase();

            String insertTransactionSql = "INSERT INTO transactions (no_nota, total_belanja, uang_tunai, kembalian, status, kasir_id) VALUES (?, ?, ?, ?, ?, ?)";
            insertTransactionPs = conn.prepareStatement(insertTransactionSql, Statement.RETURN_GENERATED_KEYS);
            insertTransactionPs.setString(1, noNota);
            insertTransactionPs.setLong(2, totalBelanja);
            insertTransactionPs.setLong(3, uangTunai);
            insertTransactionPs.setLong(4, kembalian);
            insertTransactionPs.setString(5, status);
            insertTransactionPs.setInt(6, kasirId);

            int inserted = insertTransactionPs.executeUpdate();
            if (inserted == 0) {
                throw new SQLException("Gagal menyimpan transaksi.");
            }

            generatedKeys = insertTransactionPs.getGeneratedKeys();
            if (!generatedKeys.next()) {
                throw new SQLException("ID transaksi tidak ditemukan.");
            }

            int transactionId = generatedKeys.getInt(1);

            String insertDetailSql = "INSERT INTO transaction_details (transaction_id, nama_barang, qty, harga_satuan, subtotal) VALUES (?, ?, ?, ?, ?)";
            insertDetailPs = conn.prepareStatement(insertDetailSql);

            String updateStockSql = "UPDATE products SET stok = ? WHERE id = ? AND manager_id = ?";
            updateStockPs = conn.prepareStatement(updateStockSql);

            for (int i = 0; i < products.size(); i++) {
                Product product = products.get(i);
                CartItem item = cartItems.get(i);
                long itemSubtotal = product.getHarga() * item.getQty();

                insertDetailPs.setInt(1, transactionId);
                insertDetailPs.setString(2, product.getNama());
                insertDetailPs.setInt(3, item.getQty());
                insertDetailPs.setLong(4, product.getHarga());
                insertDetailPs.setLong(5, itemSubtotal);
                insertDetailPs.addBatch();

                updateStockPs.setInt(1, product.getStok() - item.getQty());
                updateStockPs.setInt(2, product.getId());
                updateStockPs.setInt(3, managerId);
                updateStockPs.addBatch();
            }

            insertDetailPs.executeBatch();
            updateStockPs.executeBatch();
            conn.commit();
            return transactionId;
        } catch (Exception e) {
            if (lastCheckoutError == null || lastCheckoutError.trim().isEmpty()) {
                if (e.getMessage() != null && e.getMessage().toLowerCase().contains("stok")) {
                    lastCheckoutError = "Stok barang telah habis.";
                } else {
                    lastCheckoutError = e.getMessage() != null ? e.getMessage() : "Gagal menyimpan transaksi.";
                }
            }
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception rollbackException) {
                System.out.println("Error rollback checkout: " + rollbackException.getMessage());
            }
            System.out.println("Error di checkout Transaction: " + e.getMessage());
            return -1;
        } finally {
            try {
                if (productRs != null) {
                    productRs.close();
                }
            } catch (Exception ignored) {
            }
            try {
                if (generatedKeys != null) {
                    generatedKeys.close();
                }
            } catch (Exception ignored) {
            }
            try {
                if (selectProductPs != null) {
                    selectProductPs.close();
                }
            } catch (Exception ignored) {
            }
            try {
                if (insertTransactionPs != null) {
                    insertTransactionPs.close();
                }
            } catch (Exception ignored) {
            }
            try {
                if (insertDetailPs != null) {
                    insertDetailPs.close();
                }
            } catch (Exception ignored) {
            }
            try {
                if (updateStockPs != null) {
                    updateStockPs.close();
                }
            } catch (Exception ignored) {
            }
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {
            }
        }
    }

    public List<Transaction> search(String noNota, String tanggal, int managerId) {
        List<Transaction> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT t.*, u.username AS kasir_name "
                       + "FROM transactions t "
                       + "LEFT JOIN users u ON t.kasir_id = u.id "
                       + "WHERE u.manager_id = ?";

            if (noNota != null && !noNota.isEmpty()) {
                sql += " AND t.no_nota LIKE ?";
            }
            if (tanggal != null && !tanggal.isEmpty()) {
                sql += " AND DATE(t.tanggal) = ?";
            }
            sql += " ORDER BY t.tanggal DESC";

            PreparedStatement ps = conn.prepareStatement(sql);
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

    public List<Transaction> getByKasirId(int kasirId) {
        List<Transaction> list = new ArrayList<>();
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT t.*, u.username AS kasir_name "
                       + "FROM transactions t "
                       + "LEFT JOIN users u ON t.kasir_id = u.id "
                       + "WHERE t.kasir_id = ? "
                       + "ORDER BY t.tanggal DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, kasirId);
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
            System.out.println("Error di getByKasirId Transaction: " + e.getMessage());
        }
        return list;
    }
}
