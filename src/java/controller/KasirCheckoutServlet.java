package controller;

import dao.TransactionDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.CartItem;
import model.User;

@WebServlet(name = "KasirCheckoutServlet", urlPatterns = {"/kasir/checkout"})
public class KasirCheckoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = KasirHelper.requireKasirUser(request, response);
        if (user == null) {
            return;
        }

        String[] productIds = request.getParameterValues("productId");
        String[] qtys = request.getParameterValues("qty");
        String paymentMethod = request.getParameter("paymentMethod");

        List<CartItem> cartItems = new ArrayList<CartItem>();
        if (productIds != null && qtys != null) {
            int itemCount = Math.min(productIds.length, qtys.length);
            for (int i = 0; i < itemCount; i++) {
                try {
                    int productId = Integer.parseInt(productIds[i]);
                    int qty = Integer.parseInt(qtys[i]);
                    cartItems.add(new CartItem(productId, qty));
                } catch (NumberFormatException ignored) {
                }
            }
        }

        TransactionDAO dao = new TransactionDAO();
        String normalizedPaymentMethod = KasirHelper.normalizePaymentMethod(paymentMethod);
        int transactionId = dao.checkout(user.getId(), user.getManagerId(), normalizedPaymentMethod, cartItems);

        if (transactionId > 0) {
            response.sendRedirect(request.getContextPath() + "/kasir/receipt?id=" + transactionId + "&paymentMethod=" + normalizedPaymentMethod);
        } else {
            String errorMessage = dao.getLastCheckoutError();
            if (errorMessage == null || errorMessage.trim().isEmpty()) {
                errorMessage = "Transaksi gagal disimpan";
            }
            response.sendRedirect(request.getContextPath() + "/kasir/transaksi.jsp?error=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));
        }
    }
}