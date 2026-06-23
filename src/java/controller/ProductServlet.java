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
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.Product;
import model.User;

@WebServlet(name = "ProductServlet", urlPatterns = {"/ProductServlet"})
public class ProductServlet extends HttpServlet {

    // Helper: ambil managerId dari session, redirect ke login jika tidak ada
    private int getManagerId(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return -1;
        }
        User user = (User) session.getAttribute("user");
        return user.getId();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        int managerId = getManagerId(request, response);
        if (managerId == -1) return;

        String success = request.getParameter("success");
        String error   = request.getParameter("error");
        
        if (success != null) request.setAttribute("successMessage", success);
        if (error   != null) request.setAttribute("errorMessage",   error);
        
        ProductDAO dao = new ProductDAO();
        request.setAttribute("productList", dao.getAll(managerId));
        
        request.getRequestDispatcher("/manager/kelola_barang.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        int managerId = getManagerId(request, response);
        if (managerId == -1) return;

        String action = request.getParameter("action");
        String base   = request.getContextPath() + "/manager/barang";
        ProductDAO dao = new ProductDAO();

        //Add Product
        if ("add".equals(action)) {
            String kode     = request.getParameter("kode");
            String nama     = request.getParameter("nama");
            String kategori = request.getParameter("kategori");
            long harga      = Long.parseLong(request.getParameter("harga"));
            int stok        = Integer.parseInt(request.getParameter("stok"));
            
            Product p = new Product(0, kode, nama, kategori, harga, stok, managerId);
            boolean berhasil = dao.insert(p);
            
            if (berhasil) {
                response.sendRedirect(base + "?success=Barang+berhasil+ditambahkan");
            } else {
                response.sendRedirect(base + "?error=Gagal+menambahkan+barang");
            }

        //Edit Product
        } else if ("edit".equals(action)) {
            int id          = Integer.parseInt(request.getParameter("productId"));
            String kode     = request.getParameter("kode");
            String nama     = request.getParameter("nama");
            String kategori = request.getParameter("kategori");
            long harga      = Long.parseLong(request.getParameter("harga"));
            int stok        = Integer.parseInt(request.getParameter("stok"));
            
            Product p = new Product(id, kode, nama, kategori, harga, stok, managerId);
            boolean berhasil = dao.update(p);
            
            if (berhasil) {
                response.sendRedirect(base + "?success=Barang+berhasil+diperbarui");
            } else {
                response.sendRedirect(base + "?error=Gagal+memperbarui+barang");
            }

        //Delete Product
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("productId"));
            boolean berhasil = dao.delete(id, managerId);
            
            if (berhasil) {
                response.sendRedirect(base + "?success=Barang+berhasil+dihapus");
            } else {
                response.sendRedirect(base + "?error=Gagal+menghapus+barang");
            }

        //Default
        } else {
            response.sendRedirect(base);
        }
    } 
}
