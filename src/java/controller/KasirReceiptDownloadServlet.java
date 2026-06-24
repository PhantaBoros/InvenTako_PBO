package controller;

import dao.TransactionDAO;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Transaction;
import model.TransactionDetail;
import model.User;

@WebServlet(name = "KasirReceiptDownloadServlet", urlPatterns = {"/kasir/receipt-pdf"})
public class KasirReceiptDownloadServlet extends HttpServlet {

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

        byte[] pdfBytes = buildReceiptPdf(transaction, details, paymentMethod);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=receipt-" + transaction.getNoNota() + ".pdf");
        response.setContentLength(pdfBytes.length);
        response.getOutputStream().write(pdfBytes);
    }

    private byte[] buildReceiptPdf(Transaction transaction, List<TransactionDetail> details, String paymentMethod) throws IOException {
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(new Locale("id", "ID"));
        symbols.setGroupingSeparator('.');
        DecimalFormat formatter = new DecimalFormat("#,###", symbols);

        List<String> lines = new ArrayList<>();
        lines.add("INVENTAKO");
        lines.add("");
        lines.add("No Transaksi: " + safeText(transaction.getNoNota()));
        lines.add("Tanggal: " + safeText(transaction.getTanggal()));
        lines.add("");

        for (TransactionDetail detail : details) {
            lines.add(safeText(detail.getNamaBarang()));
            lines.add(detail.getQty() + " x Rp " + formatter.format(detail.getHargaSatuan()) + " = Rp " + formatter.format(detail.getSubtotal()));
            lines.add("");
        }

        lines.add("TOTAL: Rp " + formatter.format(transaction.getTotalBelanja()));
        lines.add("Bayar: Rp " + formatter.format(transaction.getUangTunai()));
        lines.add("");
        lines.add("Metode Pembayaran: " + safeText(paymentMethod.toUpperCase(Locale.ROOT)));

        StringBuilder content = new StringBuilder();
        content.append("BT\n");
        content.append("/F1 18 Tf\n");
        content.append("72 780 Td\n");
        content.append("(INVENTAKO) Tj\n");
        content.append("/F1 11 Tf\n");
        content.append("0 -22 Td\n");

        for (int i = 2; i < lines.size(); i++) {
            String line = lines.get(i);
            if (line.isEmpty()) {
                content.append("0 -12 Td\n");
                continue;
            }

            if (line.startsWith("TOTAL:")) {
                content.append("/F2 13 Tf\n");
            } else {
                content.append("/F1 11 Tf\n");
            }

            content.append("(").append(escapePdfText(line)).append(") Tj\n");
            content.append("0 -16 Td\n");
        }
        content.append("ET\n");

        return buildSimplePdf(content.toString());
    }

    private byte[] buildSimplePdf(String contentStream) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        List<Integer> offsets = new ArrayList<>();

        writeAscii(out, "%PDF-1.4\n");

        offsets.add(out.size());
        writeAscii(out, "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n");

        offsets.add(out.size());
        writeAscii(out, "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n");

        offsets.add(out.size());
        writeAscii(out, "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R /F2 5 0 R >> >> /Contents 6 0 R >>\nendobj\n");

        offsets.add(out.size());
        writeAscii(out, "4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n");

        offsets.add(out.size());
        writeAscii(out, "5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n");

        byte[] contentBytes = contentStream.getBytes(StandardCharsets.ISO_8859_1);
        offsets.add(out.size());
        writeAscii(out, "6 0 obj\n<< /Length " + contentBytes.length + " >>\nstream\n");
        out.write(contentBytes);
        writeAscii(out, "endstream\nendobj\n");

        int xrefStart = out.size();
        writeAscii(out, "xref\n0 7\n0000000000 65535 f \n");
        for (Integer offset : offsets) {
            writeAscii(out, String.format(Locale.ROOT, "%010d 00000 n \n", offset));
        }
        writeAscii(out, "trailer\n<< /Size 7 /Root 1 0 R >>\nstartxref\n" + xrefStart + "\n%%EOF");

        return out.toByteArray();
    }

    private void writeAscii(ByteArrayOutputStream out, String value) throws IOException {
        out.write(value.getBytes(StandardCharsets.US_ASCII));
    }

    private String escapePdfText(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("(", "\\(")
                .replace(")", "\\)");
    }

    private String safeText(String value) {
        return value == null ? "" : value;
    }
}