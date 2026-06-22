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

/**
 *
 * @author Muhammad Sabiq AZ
 */
@WebServlet(name = "ManagerServlet", urlPatterns = {"/manager/dashboard", "/manager/barang", "/manager/kasir","/manager/history", "/manager/history/detail"})
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
        //Route Kasir
        } else if ("/manager/kasir".equals(path)) {
            String success = request.getParameter("success");
            String error   = request.getParameter("error");

            if (success != null) request.setAttribute("successMessage", success);
            if (error   != null) request.setAttribute("errorMessage",   error);

            UserDAO dao = new UserDAO();
            request.setAttribute("kasirList", dao.getAllKasir(managerId));
            request.getRequestDispatcher("/manager/kelola_kasir.jsp").forward(request, response);
        //Default
        } else {
            response.sendRedirect(request.getContextPath() + "/manager/dashboard");
        }
    }
}
