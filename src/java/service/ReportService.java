package service;

import dao.ProductDAO;
import dao.TransactionDAO;
import java.util.List;
import model.Transaction;

// Service untuk ngambil semua data laporan di dashboard
public class ReportService {

    private final TransactionDAO transactionDAO;
    private final ProductDAO     productDAO;

    public ReportService() {
        this.transactionDAO = new TransactionDAO();
        this.productDAO     = new ProductDAO();
    }

    // Total pendapatan toko
    public long getTotalRevenue(int managerId) {
        return transactionDAO.getTotalRevenue(managerId);
    }

    // Jumlah transaksi
    public int getTotalTransaksi(int managerId) {
        return transactionDAO.getTotalCount(managerId);
    }

    // Jumlah jenis barang
    public int getTotalBarang(int managerId) {
        return productDAO.getAll(managerId).size();
    }

    // Total stok semua barang
    public int getTotalStok(int managerId) {
        return productDAO.getTotalStok(managerId);
    }

    // Barang terlaris (untuk bar chart)
    public List<Object[]> getTopProducts(int limit, int managerId) {
        return transactionDAO.getTopProducts(limit, managerId);
    }

    // Data transaksi per shift (untuk pie chart)
    public List<Object[]> getShiftData(int managerId) {
        return transactionDAO.getShiftData(managerId);
    }

    // Semua transaksi (untuk tabel riwayat)
    public List<Transaction> getAllTransaksi(int managerId) {
        return transactionDAO.getAll(managerId);
    }

    // Kumpulin semua data dashboard jadi satu objek
    public ReportData generateLaporan(int managerId) {
        ReportData data = new ReportData();
        data.totalRevenue    = getTotalRevenue(managerId);
        data.totalTransaksi  = getTotalTransaksi(managerId);
        data.totalBarang     = getTotalBarang(managerId);
        data.totalStok       = getTotalStok(managerId);
        data.topProducts     = getTopProducts(3, managerId);
        data.shiftData       = getShiftData(managerId);
        data.transactionList = getAllTransaksi(managerId);
        return data;
    }

    // Objek yang nampung semua data laporan
    public static class ReportData {
        public long              totalRevenue;
        public int               totalTransaksi;
        public int               totalBarang;
        public int               totalStok;
        public List<Object[]>    topProducts;
        public List<Object[]>    shiftData;
        public List<Transaction> transactionList;
    }
}
