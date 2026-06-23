/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Muhammad Sabiq AZ
 */

import dao.ProductDAO;
import dao.TransactionDAO;
import dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.Kasir;
import model.User;

@WebServlet(name = "ManagerServlet", urlPatterns = {
    "/manager/dashboard", "/manager/barang", "/manager/kasir", "/manager/history"
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
            request.setAttribute("hourlyData",      trxDAO.getHourlyData(managerId));
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
}
