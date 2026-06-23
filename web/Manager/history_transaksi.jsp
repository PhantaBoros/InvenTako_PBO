<%-- 
    Document   : history_transaksi
    Created on : 12 Jun 2026, 14.29.16
    Author     : Muhammad Sabiq AZ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%--
    Model yang dibutuhkan:
    - com.inventako.model.Transaction (id, noNota, tanggal, totalBelanja, uangTunai, kembalian, status, kasirName)
    - com.inventako.model.TransactionDetail (id, namaBarang, qty, hargaSatuan, subtotal)

    Servlet Contract:
    - request.setAttribute("transactionList", List<Transaction>)
    - request.setAttribute("totalRevenue",    Long)
    - request.setAttribute("totalCount",      Integer)
    - Filter parameter GET: q (no_nota), date (tanggal)
--%>
<%
    List<?> transactionList = (List<?>) request.getAttribute("transactionList");
    Object totalRevenueAttr = request.getAttribute("totalRevenue");
    Object totalCountAttr   = request.getAttribute("totalCount");
    long totalRevenue = totalRevenueAttr != null ? ((Number) totalRevenueAttr).longValue() : 0L;
    int  totalCount   = totalCountAttr   != null ? ((Number) totalCountAttr).intValue()    : 0;
    String filterQ    = request.getParameter("q")    != null ? request.getParameter("q")    : "";
    String filterDate = request.getParameter("date") != null ? request.getParameter("date") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Riwayat Transaksi | InvenTako</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-slate-50 min-h-screen flex flex-col text-slate-800">

    <header class="fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-6 py-4 border-b border-slate-200 bg-white shadow-sm">
        <div class="text-3xl font-extrabold text-[#0044ff] tracking-tight">InvenTako</div>
        <div class="flex items-center gap-2 text-[#0044ff] cursor-pointer hover:text-blue-800 transition-colors" onclick="confirmLogout()">
            <i data-lucide="log-out" class="w-6 h-6"></i>
            <span class="text-base font-semibold uppercase">Logout</span>
        </div>
    </header>

    <div class="flex flex-1 overflow-hidden pt-20">

        <aside class="fixed top-20 left-0 bottom-0 w-56 border-r border-slate-200 py-6 flex flex-col gap-1 bg-white z-40">
            <a href="${pageContext.request.contextPath}/manager/dashboard" class="flex items-center gap-3 px-6 py-3 text-black hover:bg-slate-50 transition-colors">
                <i data-lucide="layout-grid" class="w-5 h-5"></i>
                <span class="font-medium">Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/manager/barang" class="flex items-center gap-3 px-6 py-3 text-black hover:bg-slate-50 transition-colors">
                <i data-lucide="book-marked" class="w-5 h-5"></i>
                <span class="font-medium">Kelola Barang</span>
            </a>
            <a href="${pageContext.request.contextPath}/manager/kasir" class="flex items-center gap-3 px-6 py-3 text-black hover:bg-slate-50 transition-colors">
                <i data-lucide="users" class="w-5 h-5"></i>
                <span class="font-medium">Kelola Kasir</span>
            </a>
            <a href="${pageContext.request.contextPath}/manager/history" class="flex items-center gap-3 px-6 py-3 bg-[#0044ff] text-white">
                <i data-lucide="history" class="w-5 h-5"></i>
                <span class="font-medium">Riwayat Transaksi</span>
            </a>
        </aside>

        <main class="flex-1 p-8 overflow-y-auto ml-56">

            <div class="mb-8">
                <h1 class="text-2xl font-bold text-black">Riwayat Transaksi</h1>
            </div>

            <!-- Stat Cards -->
            <div class="flex gap-6 mb-8 w-1/2">
                <div class="flex-1 p-5 border border-slate-200 rounded-lg shadow-sm bg-white">
                    <div class="flex items-center gap-2 text-slate-500 mb-2">
                        <i data-lucide="wallet" class="w-4 h-4"></i>
                        <p class="font-bold text-sm">Total Pendapatan</p>
                    </div>
                    <p class="text-2xl font-bold text-black mt-1">Rp <%= String.format("%,d", totalRevenue).replace(',', '.') %></p>
                </div>
                <div class="flex-1 p-5 border border-slate-200 rounded-lg shadow-sm bg-white">
                    <div class="flex items-center gap-2 text-slate-500 mb-2">
                        <i data-lucide="receipt" class="w-4 h-4"></i>
                        <p class="font-bold text-sm">Total Transaksi</p>
                    </div>
                    <p class="text-2xl font-bold text-black mt-1">
                        <%= totalCount %> <span class="text-sm font-medium text-slate-500">transaksi</span>
                    </p>
                </div>
            </div>

            <!-- Filter -->
            <div class="bg-white p-4 rounded-t-lg border border-slate-200 border-b-0 flex gap-4 items-center shadow-sm">
                <form action="${pageContext.request.contextPath}/manager/history" method="GET" class="flex gap-4 items-center flex-1">
                    <div class="relative flex-1 max-w-sm">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <i data-lucide="search" class="h-4 w-4 text-slate-400"></i>
                        </div>
                        <input name="q" type="text" value="<%= filterQ %>"
                            class="block w-full pl-10 pr-3 py-2 border border-slate-200 rounded-md bg-slate-50 text-sm focus:outline-none focus:ring-1 focus:ring-[#0044ff]"
                            placeholder="Cari No. Nota...">
                    </div>
                    <div class="relative max-w-xs">
                        <input name="date" type="date" value="<%= filterDate %>"
                            class="block w-full px-3 py-2 border border-slate-200 rounded-md bg-slate-50 text-sm focus:outline-none focus:ring-1 focus:ring-[#0044ff] text-slate-600">
                    </div>
                    <button type="submit" class="bg-[#0044ff] text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700 transition-colors">Filter</button>
                    <% if (!filterQ.isEmpty() || !filterDate.isEmpty()) { %>
                    <a href="${pageContext.request.contextPath}/manager/history"
                       class="text-slate-500 hover:text-slate-700 text-sm font-medium">Reset</a>
                    <% } %>
                </form>
            </div>

            <!-- Tabel Riwayat -->
            <div id="tableContainer" class="border border-slate-200 rounded-b-lg bg-white shadow-sm overflow-hidden mb-6">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-100 border-b border-slate-200">
                            <th class="py-3 px-4 font-semibold text-slate-700 text-sm">No. Nota</th>
                            <th class="py-3 px-4 font-semibold text-slate-700 text-sm">Tanggal &amp; Waktu</th>
                            <th class="py-3 px-4 font-semibold text-slate-700 text-sm">Kasir</th>
                            <th class="py-3 px-4 font-semibold text-slate-700 text-sm">Total Belanja</th>
                            <th class="py-3 px-4 font-semibold text-slate-700 text-sm text-center">Status</th>
                            <th class="py-3 px-4 font-semibold text-slate-700 text-sm text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%-- ============================================================
                             JSP LOOP: Iterasi List<Transaction> dari Servlet
                             ============================================================ --%>
                        <% if (transactionList == null || transactionList.isEmpty()) { %>
                        <tr>
                            <td colspan="6" class="text-center py-10 text-slate-500">
                                Tidak ada transaksi<%= !filterQ.isEmpty() || !filterDate.isEmpty() ? " yang cocok dengan filter." : " yang tercatat." %>
                            </td>
                        </tr>
                        <% } else {
                            for (Object objTrx : transactionList) {
                                model.Transaction trx = (model.Transaction) objTrx;
                                String status    = trx.getStatus()    != null ? trx.getStatus()    : "Selesai";
                                String kasirName = trx.getKasirName() != null ? trx.getKasirName() : "-";
                        %>
                        <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                            <td class="py-3 px-4 text-sm text-slate-600 font-medium"><%= trx.getNoNota() %></td>
                            <td class="py-3 px-4 text-sm text-black"><%= trx.getTanggal() %></td>
                            <td class="py-3 px-4 text-sm text-slate-600"><%= kasirName %></td>
                            <td class="py-3 px-4 text-sm font-bold text-[#0044ff]">
                                Rp <%= String.format("%,d", trx.getTotalBelanja()).replace(',', '.') %>
                            </td>
                            <td class="py-3 px-4 text-sm text-center">
                                <span class="bg-green-100 text-green-700 px-2 py-1 rounded text-xs font-semibold"><%= status %></span>
                            </td>
                            <td class="py-3 px-4 text-sm text-center">
                                <a href="${pageContext.request.contextPath}/manager/history/detail?id=<%= trx.getId() %>"
                                   class="text-[#0044ff] hover:bg-blue-100 px-3 py-1.5 rounded text-xs font-semibold border border-blue-200 transition-colors">
                                    Lihat Detail
                                </a>
                            </td>
                        </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>

        </main>
    </div>

    <!-- Logout Confirm Modal -->
    <div id="logoutConfirmModal" class="hidden fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm">
        <div class="bg-white rounded-xl shadow-2xl p-6 max-w-sm w-full mx-4">
            <div class="flex items-center gap-3 mb-4">
                <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                    <i data-lucide="log-out" class="w-6 h-6 text-red-600"></i>
                </div>
                <h2 class="text-xl font-bold text-slate-900">Logout?</h2>
            </div>
            <p class="text-slate-600 mb-6">Apakah Anda yakin ingin keluar?</p>
            <div class="flex gap-3">
                <button onclick="cancelLogout()" class="flex-1 px-4 py-2.5 bg-slate-200 hover:bg-slate-300 text-slate-900 font-semibold rounded-lg transition-colors">Batal</button>
                <form action="${pageContext.request.contextPath}/AuthServlet" method="POST" class="flex-1">
                    <input type="hidden" name="action" value="logout"/>
                    <button type="submit" class="w-full px-4 py-2.5 bg-red-600 hover:bg-red-700 text-white font-semibold rounded-lg transition-colors flex items-center justify-center gap-2">
                        <i data-lucide="log-out" class="w-4 h-4"></i> Logout
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();
        window.addEventListener('load', () => lucide.createIcons());
        function confirmLogout() { document.getElementById('logoutConfirmModal').classList.remove('hidden'); }
        function cancelLogout()  { document.getElementById('logoutConfirmModal').classList.add('hidden'); }


    </script>

</body>
</html>
