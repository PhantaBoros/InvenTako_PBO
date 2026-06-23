/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dao.UserDAO;
import java.io.IOException;
import java.time.LocalTime;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.User;

@WebServlet(name = "AuthServlet", urlPatterns = {"/AuthServlet"})
public class AuthServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        UserDAO dao = new UserDAO();

        //Login
        if ("login".equals(action)) {
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            
            User user = dao.login(email, password);
            
            if (user == null) {
                request.setAttribute("errorMessage", "Email atau password salah!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            } else {
                String role  = user.getRole();
                String shift = user.getShift();

                // Cek apakah akun masih menunggu persetujuan admin
                if ("pending".equals(user.getStatus())) {
                    request.setAttribute("errorMessage", "Akun Anda belum disetujui oleh admin. Silakan tunggu.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }

                // Validasi jam shift untuk kasir
                if ("kasir".equals(role) && !isShiftValid(shift)) {
                    request.setAttribute("errorMessage","Akses ditolak! Shift " + shift + " belum dimulai atau sudah berakhir.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }

                HttpSession s = request.getSession();
                s.setAttribute("user", user);
                s.setAttribute("userRole", role);

                if ("manager".equals(role)) {
                    response.sendRedirect("manager/dashboard");
                } else if ("kasir".equals(role)) {
                    response.sendRedirect("kasir/transaksi.jsp");
                } else if ("admin".equals(role)) {
                    response.sendRedirect("admin/kelola_manager.jsp");
                } else {
                    response.sendRedirect("login.jsp");
                }
            }

        //Logout
        } else if ("logout".equals(action)) {
            HttpSession s = request.getSession(false);
            if (s != null) {
                s.invalidate();
            }
            response.sendRedirect("login.jsp");

        //Register
        } else if ("register".equals(action)) {
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            
            User manager = new User(0, username, email, password, "manager");
            boolean berhasil = dao.register(manager);
            
            if (berhasil == true) {
                request.setAttribute("successMessage", "Registrasi berhasil! Menunggu persetujuan admin.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Registrasi gagal! Email mungkin sudah dipakai.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }

        //Default
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    //Cek jam login kasir
    private boolean isShiftValid(String shift) {
        int jam = LocalTime.now().getHour();
        if (shift == null) return false;
        switch (shift) {
            case "pagi"  : return jam >= 6  && jam < 12;
            case "siang" : return jam >= 12 && jam < 17;
            case "sore"  : return jam >= 17 && jam < 21;
            case "malem" : return jam >= 21 || jam < 6;
            default      : return false;
        }
    }
}
