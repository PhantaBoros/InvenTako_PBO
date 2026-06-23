<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="controller.KasirHelper"%>
<%@page import="dao.TransactionDAO"%>
<%@page import="model.Transaction"%>
<%@page import="model.User"%>
<%
    User user = KasirHelper.requireKasirUser(request, response);
    if (user == null) {
        return;
    }

    TransactionDAO dao = new TransactionDAO();
    List<Transaction> transactionList = dao.getByKasirId(user.getId());
    String userName = KasirHelper.getDisplayName(user);
    String initials = KasirHelper.getInitials(userName);
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Riwayat Transaksi Kasir | InvenTako</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background: radial-gradient(circle at top left, rgba(0,68,255,0.07), transparent 30%), #fff; }
    </style>
</head>
<body class="min-h-screen text-slate-800">
    <header class="fixed top-0 left-0 right-0 z-50 flex items-center justify-between border-b border-slate-200 bg-white/95 backdrop-blur px-6 py-4 shadow-sm">
        <div class="flex items-center gap-6">
            <div class="text-3xl font-extrabold text-[#0044ff] tracking-tight">InvenTako</div>
            <nav class="hidden sm:flex items-center gap-2 rounded-full border border-slate-200 bg-slate-50 p-1">
                <a href="${pageContext.request.contextPath}/kasir/transaksi.jsp" class="rounded-full px-4 py-2 text-sm font-semibold text-slate-500 hover:text-slate-900">Transaksi</a>
                <a href="${pageContext.request.contextPath}/kasir/riwayat_transaksi.jsp" class="rounded-full bg-[#0044ff] px-4 py-2 text-sm font-semibold text-white shadow-sm">Riwayat Transaksi</a>
                <a href="${pageContext.request.contextPath}/kasir/barang_stok_habis.jsp" class="rounded-full px-4 py-2 text-sm font-semibold text-slate-500 hover:text-slate-900">Stok Barang Habis</a>
            </nav>
        </div>
        <button type="button" onclick="openProfileModal()" class="flex items-center gap-3 text-[#0044ff] cursor-pointer hover:opacity-80 transition-opacity">
            <div class="flex h-11 w-11 items-center justify-center rounded-full border-2 border-[#0044ff] text-[#0044ff] text-sm font-bold bg-blue-50 tracking-wider"><%= initials %></div>
            <span class="text-lg font-medium"><%= userName %></span>
        </button>
    </header>

    <div class="pt-28 px-6 py-6 max-w-7xl mx-auto">
        <div class="mb-6">
            <h1 class="text-3xl font-bold text-slate-900">Riwayat Transaksi</h1>
            <p class="mt-2 text-slate-600">Daftar transaksi yang sudah diproses oleh kasir ini.</p>
        </div>

        <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
            <table class="w-full border-collapse text-left">
                <thead>
                    <tr class="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-[0.18em] text-slate-400">
                        <th class="px-5 py-4 font-semibold">No Nota</th>
                        <th class="px-5 py-4 font-semibold">Tanggal</th>
                        <th class="px-5 py-4 font-semibold">Total</th>
                        <th class="px-5 py-4 font-semibold">Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (transactionList == null || transactionList.isEmpty()) { %>
                    <tr><td colspan="4" class="px-5 py-16 text-center text-slate-500">Belum ada transaksi.</td></tr>
                    <% } else {
                        for (Transaction trx : transactionList) { %>
                    <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                        <td class="px-5 py-4 font-medium text-slate-900"><%= trx.getNoNota() %></td>
                        <td class="px-5 py-4 text-sm text-slate-600"><%= trx.getTanggal() %></td>
                        <td class="px-5 py-4 text-sm text-slate-700">Rp <%= String.format("%,d", trx.getTotalBelanja()).replace(',', '.') %></td>
                        <td class="px-5 py-4 text-sm text-emerald-600 font-semibold"><%= trx.getStatus() %></td>
                    </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>
    </div>

    <%@ include file="_profileModal.jspf" %>
    <script src="${pageContext.request.contextPath}/assets/js/kasir-transaksi.js"></script>
</body>
</html>