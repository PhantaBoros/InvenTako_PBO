/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dao.ProductDAO;
import dao.TransactionDAO;
import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.Kasir;
import model.Transaction;
import model.TransactionDetail;
import model.User;

@WebServlet(name = "ManagerServlet", urlPatterns = {
    "/manager/dashboard", "/manager/barang", "/manager/kasir",
    "/manager/history", "/manager/history/detail"
})
public class ManagerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        int managerId = user.getId();  // ID manager = ID toko
        String path = request.getServletPath();

        //Route Dashboard
        if ("/manager/dashboard".equals(path)) {
            TransactionDAO trxDAO  = new TransactionDAO();
            ProductDAO     prodDAO = new ProductDAO();

            request.setAttribute("transactionList", trxDAO.getAll(managerId));
            request.setAttribute("topProductList",  trxDAO.getTopProducts(3, managerId));
            request.setAttribute("shiftData",       trxDAO.getShiftData(managerId));
            request.setAttribute("totalRevenue",    trxDAO.getTotalRevenue(managerId));
            request.setAttribute("totalCount",      trxDAO.getTotalCount(managerId));

            // Total barang & stok hanya milik toko ini
            int totalBarang = prodDAO.getAll(managerId).size();
            request.setAttribute("totalBarang", totalBarang);
            request.setAttribute("totalStok",   prodDAO.getTotalStok(managerId));
            request.setAttribute("managerName", user.getUsername());

            request.getRequestDispatcher("/manager/dashboard.jsp").forward(request, response);

        //Route Barang
        } else if ("/manager/barang".equals(path)) {
            String success = request.getParameter("success");
            String error   = request.getParameter("error");

            if (success != null) request.setAttribute("successMessage", success);
            if (error   != null) request.setAttribute("errorMessage",   error);

            ProductDAO dao = new ProductDAO();
            request.setAttribute("productList", dao.getAll(managerId));
            request.getRequestDispatcher("/manager/kelola_barang.jsp").forward(request, response);

        //Route Kasir
        } else if ("/manager/kasir".equals(path)) {
            String success = request.getParameter("success");
            String error   = request.getParameter("error");

            if (success != null) request.setAttribute("successMessage", success);
            if (error   != null) request.setAttribute("errorMessage",   error);

            UserDAO dao = new UserDAO();
            request.setAttribute("kasirList", dao.getAllKasir(managerId));
            request.getRequestDispatcher("/manager/kelola_kasir.jsp").forward(request, response);

        //Route History
        } else if ("/manager/history".equals(path)) {
            TransactionDAO dao = new TransactionDAO();
            String query     = request.getParameter("q");
            String dateParam = request.getParameter("date");

            request.setAttribute("transactionList", dao.search(query, dateParam, managerId));
            request.setAttribute("totalRevenue",    dao.getTotalRevenue(managerId));
            request.setAttribute("totalCount",      dao.getTotalCount(managerId));

            request.getRequestDispatcher("/manager/history_transaksi.jsp").forward(request, response);

        //Route History Detail (AJAX — return JSON)
        } else if ("/manager/history/detail".equals(path)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();

            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                out.print("{\"error\":\"id tidak ditemukan\"}");
                return;
            }

            int trxId = Integer.parseInt(idParam);
            TransactionDAO dao = new TransactionDAO();

            // Ambil header transaksi
            Transaction trx = dao.getById(trxId, managerId);
            if (trx == null) {
                out.print("{\"error\":\"Transaksi tidak ditemukan\"}");
                return;
            }

            // Ambil detail item
            List<TransactionDetail> details = dao.getDetailByTransactionId(trxId);

            // Build JSON manual (tanpa library tambahan)
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"id\":").append(trx.getId()).append(",");
            json.append("\"noNota\":\"").append(escapeJson(trx.getNoNota())).append("\",");
            json.append("\"tanggal\":\"").append(escapeJson(trx.getTanggal())).append("\",");
            json.append("\"kasir\":\"").append(escapeJson(trx.getKasirName())).append("\",");
            json.append("\"totalBelanja\":").append(trx.getTotalBelanja()).append(",");
            json.append("\"uangTunai\":").append(trx.getUangTunai()).append(",");
            json.append("\"kembalian\":").append(trx.getKembalian()).append(",");
            json.append("\"status\":\"").append(escapeJson(trx.getStatus())).append("\",");
            json.append("\"items\":[");
            for (int i = 0; i < details.size(); i++) {
                TransactionDetail d = details.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"namaBarang\":\"").append(escapeJson(d.getNamaBarang())).append("\",");
                json.append("\"qty\":").append(d.getQty()).append(",");
                json.append("\"hargaSatuan\":").append(d.getHargaSatuan()).append(",");
                json.append("\"subtotal\":").append(d.getSubtotal());
                json.append("}");
            }
            json.append("]}");

            out.print(json.toString());

        //Default
        } else {
            response.sendRedirect(request.getContextPath() + "/manager/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        int managerId = user.getId();

        String action = request.getParameter("action");

        if ("tambahKasir".equals(action)) {
            String username = request.getParameter("username");
            String email    = request.getParameter("email");
            String password = request.getParameter("password");
            String shift    = request.getParameter("shift");

            Kasir kasir = new Kasir();
            kasir.setUsername(username);
            kasir.setEmail(email);
            kasir.setPassword(password);
            kasir.setShift(shift);
            kasir.setManagerId(managerId);  // assign ke toko manager ini

            UserDAO dao = new UserDAO();
            boolean berhasil = dao.tambahKasir(kasir);

            if (berhasil) {
                response.sendRedirect(request.getContextPath() + "/manager/kasir?success=Kasir+berhasil+ditambahkan");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager/kasir?error=Gagal+menambahkan+kasir");
            }

        } else if ("hapusKasir".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));

            UserDAO dao = new UserDAO();
            boolean berhasil = dao.deleteKasir(id, managerId);  // pastikan kasir milik toko ini

            if (berhasil) {
                response.sendRedirect(request.getContextPath() + "/manager/kasir?success=Kasir+berhasil+dihapus");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager/kasir?error=Gagal+menghapus+kasir");
            }

        } else {
            doGet(request, response);
        }
    }

    /** Escape karakter khusus JSON agar aman disisipkan dalam string JSON */
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", " ");
    }
}
