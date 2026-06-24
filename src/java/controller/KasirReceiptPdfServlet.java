package controller;

import dao.TransactionDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Transaction;
import model.TransactionDetail;
import model.User;

@WebServlet(name = "KasirReceiptPdfServlet", urlPatterns = {"/kasir/receipt"})
public class KasirReceiptPdfServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = KasirHelper.requireKasirUser(request, response);
        if (user == null) {
            return;
        }

        Integer transactionId = KasirHelper.parseRequiredIntParameter(request, response, "id", "/kasir/transaksi.jsp?error=Transaksi+tidak+ditemukan");
        if (transactionId == null) {
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        Transaction transaction = dao.getById(transactionId.intValue(), user.getManagerId());
        if (transaction == null) {
            response.sendRedirect(request.getContextPath() + "/kasir/transaksi.jsp?error=Transaksi+tidak+ditemukan");
            return;
        }

        List<TransactionDetail> details = dao.getDetailByTransactionId(transactionId.intValue());
        String paymentMethod = KasirHelper.normalizePaymentMethod(request.getParameter("paymentMethod"));

        request.setAttribute("transaction", transaction);
        request.setAttribute("details", details);
        request.setAttribute("paymentMethod", paymentMethod);

        request.getRequestDispatcher("/kasir/receipt.jsp").forward(request, response);
    }
}