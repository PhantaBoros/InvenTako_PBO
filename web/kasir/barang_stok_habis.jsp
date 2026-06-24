<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="controller.KasirHelper"%>
<%@page import="dao.ProductDAO"%>
<%@page import="model.Product"%>
<%@page import="model.User"%>
<%
    User user = KasirHelper.requireKasirUser(request, response);
    if (user == null) {
        return;
    }

    ProductDAO productDAO = new ProductDAO();
    List<Product> outOfStockList = productDAO.getOutOfStock(user.getManagerId());
    String userName = KasirHelper.getDisplayName(user);
    String initials = KasirHelper.getInitials(userName);
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Barang Stok Habis | InvenTako</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background:
                radial-gradient(circle at top left, rgba(255, 99, 71, 0.08), transparent 28%),
                radial-gradient(circle at bottom right, rgba(0,68,255,0.05), transparent 30%),
                #ffffff;
        }
    </style>
</head>
<body class="min-h-screen text-slate-800">
    <header class="fixed top-0 left-0 right-0 z-50 flex items-center justify-between border-b border-slate-200 bg-white/95 backdrop-blur px-6 py-4 shadow-sm">
        <div class="flex items-center gap-6">
            <div class="text-3xl font-extrabold text-[#0044ff] tracking-tight">InvenTako</div>
            <nav class="hidden sm:flex items-center gap-2 rounded-full border border-slate-200 bg-slate-50 p-1">
                <a href="${pageContext.request.contextPath}/kasir/transaksi.jsp" class="rounded-full px-4 py-2 text-sm font-semibold text-slate-500 hover:text-slate-900">Transaksi</a>
                <a href="${pageContext.request.contextPath}/kasir/riwayat_transaksi.jsp" class="rounded-full px-4 py-2 text-sm font-semibold text-slate-500 hover:text-slate-900">Riwayat Transaksi</a>
                <a href="${pageContext.request.contextPath}/kasir/barang_stok_habis.jsp" class="rounded-full bg-[#0044ff] px-4 py-2 text-sm font-semibold text-white shadow-sm">Stok Barang Habis</a>
            </nav>
        </div>
        <button type="button" onclick="openProfileModal()" class="flex items-center gap-3 text-[#0044ff] cursor-pointer hover:opacity-80 transition-opacity">
            <div class="flex h-11 w-11 items-center justify-center rounded-full border-2 border-[#0044ff] text-[#0044ff] text-sm font-bold bg-blue-50 tracking-wider"><%= initials %></div>
            <span class="text-lg font-medium"><%= userName %></span>
        </button>
    </header>

    <div class="pt-28 px-6 py-6 max-w-7xl mx-auto">
        <div class="mb-6">
            <h1 class="text-3xl font-bold text-slate-900">Daftar Barang yang Sudah Habis</h1>
        </div>

        <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
            <table class="w-full border-collapse text-left">
                <thead>
                    <tr class="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-[0.18em] text-slate-400">
                        <th class="px-5 py-4 font-semibold">Barang</th>
                        <th class="px-5 py-4 font-semibold">Kategori</th>
                        <th class="px-5 py-4 font-semibold">Harga</th>
                        <th class="px-5 py-4 font-semibold">Stok</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (outOfStockList.isEmpty()) { %>
                    <tr>
                        <td colspan="4" class="px-5 py-16 text-center text-slate-500">Tidak ada barang stok habis saat ini.</td>
                    </tr>
                    <% } else {
                        for (Product product : outOfStockList) { %>
                    <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                        <td class="px-5 py-4">
                            <div>
                                <p class="text-sm font-semibold text-slate-900"><%= product.getNama() %></p>
                                <p class="text-xs text-slate-400"><%= product.getKode() %></p>
                            </div>
                        </td>
                        <td class="px-5 py-4 text-sm text-slate-600"><%= product.getKategori() != null ? product.getKategori() : "-" %></td>
                        <td class="px-5 py-4 text-sm text-slate-700">Rp <%= String.format("%,d", product.getHarga()).replace(',', '.') %></td>
                        <td class="px-5 py-4">
                            <span class="inline-flex rounded-full bg-rose-100 px-3 py-1 text-xs font-semibold text-rose-700">Habis</span>
                        </td>
                    </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>
    </div>

    <%@ include file="_profilModal.jspf" %>
    <script src="${pageContext.request.contextPath}/assets/js/kasir-transaksi.js"></script>
</body>
</html>