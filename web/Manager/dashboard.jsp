<%-- 
    Document   : dashboard
    Created on : 12 Jun 2026, 14.29.01
    Author     : Muhammad Sabiq AZ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%--
    Model yang dibutuhkan:
    - com.inventako.model.Transaction (semua field)
    - com.inventako.model.Product (untuk top product chart)

    Servlet Contract:
    - request.setAttribute("transactionList",  List<Transaction>)
    - request.setAttribute("topProductList",   List<Object[]>) — [namaBarang, totalQty]
    - request.setAttribute("hourlyData",       List<Object[]>) — [jam, jumlahTransaksi]
    - request.setAttribute("totalRevenue",     Long)
    - request.setAttribute("totalCount",       Integer)
    - request.setAttribute("totalBarang",      Integer)
    - request.setAttribute("totalStok",        Integer)
    - request.setAttribute("managerName",      String)
    - Endpoint history  : ManagerServlet?action=history
    - Endpoint export   : ManagerServlet?action=exportPdf
--%>
<%
    Object totalRevenueAttr = request.getAttribute("totalRevenue");
    Object totalCountAttr   = request.getAttribute("totalCount");
    Object totalBarangAttr  = request.getAttribute("totalBarang");
    Object totalStokAttr    = request.getAttribute("totalStok");
    List<?> transactionList = (List<?>) request.getAttribute("transactionList");
    String managerName      = (String) request.getAttribute("managerName");

    long totalRevenue = totalRevenueAttr != null ? ((Number) totalRevenueAttr).longValue() : 0L;
    int  totalCount   = totalCountAttr   != null ? ((Number) totalCountAttr).intValue()    : 0;
    int  totalBarang  = totalBarangAttr  != null ? ((Number) totalBarangAttr).intValue()   : 0;
    int  totalStok    = totalStokAttr    != null ? ((Number) totalStokAttr).intValue()     : 0;
    if (managerName == null) managerName = "Manager";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Manager | InvenTako</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <%-- Chart.js untuk visualisasi data --%>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <%-- jsPDF untuk export PDF --%>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-white min-h-screen flex flex-col text-slate-800">

    <header class="fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-6 py-4 border-b border-slate-200 bg-white shadow-sm">
        <div class="text-3xl font-extrabold text-[#0044ff] tracking-tight">InvenTako</div>
        <div class="flex items-center gap-4">
            <span class="text-sm font-medium text-slate-500">Selamat datang, <strong class="text-slate-800"><%= managerName %></strong></span>
            <div class="flex items-center gap-2 text-[#0044ff] cursor-pointer hover:text-blue-800 transition-colors" onclick="confirmLogout()">
                <i data-lucide="log-out" class="w-5 h-5"></i>
                <span class="text-sm font-semibold uppercase">Logout</span>
            </div>
        </div>
    </header>

    <div class="flex flex-1 overflow-hidden pt-20">

        <aside class="fixed top-20 left-0 bottom-0 w-56 border-r border-slate-200 py-6 flex flex-col gap-1 bg-white z-40">
            <a href="${pageContext.request.contextPath}/manager/dashboard" class="flex items-center gap-3 px-6 py-3 bg-[#0044ff] text-white">
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
            <a href="${pageContext.request.contextPath}/manager/history" class="flex items-center gap-3 px-6 py-3 text-black hover:bg-slate-50 transition-colors">
                <i data-lucide="history" class="w-5 h-5"></i>
                <span class="font-medium">Riwayat Transaksi</span>
            </a>
        </aside>

        <main class="flex-1 p-8 overflow-y-auto bg-white ml-56" id="dashboardContent">

            <!-- Export Area: Stat Cards + Charts (yang di-capture saat export PDF) -->
            <div id="exportArea" class="bg-white">

                <!-- Header Export -->
                <div class="mb-6 hidden" id="exportHeader">
                    <h1 class="text-2xl font-extrabold text-[#0044ff]">InvenTako</h1>
                    <p class="text-slate-500 text-sm">Laporan Dashboard</p>
                </div>

                <!-- Stat Cards -->
                <div class="grid grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                    <div class="p-6 border border-slate-200 rounded-lg shadow-sm bg-white">
                        <p class="text-slate-500 font-bold text-sm mb-2">Total Barang</p>
                        <p class="text-2xl font-bold text-black"><%= totalBarang %></p>
                    </div>
                    <div class="p-6 border border-slate-200 rounded-lg shadow-sm bg-white">
                        <p class="text-slate-500 font-bold text-sm mb-2">Total Stok</p>
                        <p class="text-2xl font-bold text-black"><%= totalStok %></p>
                    </div>
                    <div class="p-6 border border-slate-200 rounded-lg shadow-sm bg-white">
                        <p class="text-slate-500 font-bold text-sm mb-2">Total Transaksi</p>
                        <p class="text-2xl font-bold text-black"><%= totalCount %></p>
                    </div>
                    <div class="p-6 border border-slate-200 rounded-lg shadow-sm bg-white">
                        <p class="text-slate-500 font-bold text-sm mb-2">Total Pendapatan</p>
                        <p class="text-2xl font-bold text-[#0044ff]">Rp <%= String.format("%,d", totalRevenue).replace(',', '.') %></p>
                    </div>
                </div>

                <!-- Charts Section -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-4">

                    <%-- Canvas: Barang Terlaris — diisi oleh Chart.js dengan data dari Servlet --%>
                    <div class="p-6 border border-slate-200 rounded-lg shadow-sm bg-white">
                        <h2 class="text-base font-bold text-black mb-4">Barang Terlaris</h2>
                        <div class="relative h-64">
                            <canvas id="chartTopProducts"></canvas>
                        </div>
                    </div>

                    <%-- Canvas: Waktu Transaksi Tersibuk — diisi oleh Chart.js dengan data dari Servlet --%>
                    <div class="p-6 border border-slate-200 rounded-lg shadow-sm bg-white">
                        <h2 class="text-base font-bold text-black mb-4">Waktu Tersibuk (per Jam)</h2>
                        <div class="relative h-64">
                            <canvas id="chartHourly"></canvas>
                        </div>
                    </div>
                </div>

            </div><!-- /exportArea -->

            <!-- Action Buttons -->
            <div class="flex gap-4 mb-8">
                <a href="${pageContext.request.contextPath}/manager/barang"
                   class="bg-[#0044ff] hover:bg-blue-700 text-white px-5 py-2 rounded-md font-medium transition-colors shadow-sm">
                    + Kelola Barang
                </a>
                <button id="btnExportPdf" onclick="exportDashboardPdf()"
                    class="flex items-center gap-2 bg-slate-700 hover:bg-slate-900 text-white px-5 py-2 rounded-md font-medium transition-colors shadow-sm">
                    <i data-lucide="download" class="w-4 h-4"></i> Export PDF
                </button>
            </div>

            <!-- Riwayat Transaksi Terbaru -->
            <div class="mb-8">
                <div class="flex items-center justify-between mb-3">
                    <h2 class="text-base font-bold text-black">Riwayat Transaksi Terbaru</h2>
                    <a href="${pageContext.request.contextPath}/manager/history" class="text-sm text-[#0044ff] font-medium hover:underline">Lihat Semua</a>
                </div>
                <div class="border border-slate-200 rounded-md bg-white shadow-sm overflow-hidden">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-slate-200 border-b border-slate-200">
                                <th class="py-3 px-4 font-semibold text-slate-800 text-sm">No. Nota</th>
                                <th class="py-3 px-4 font-semibold text-slate-800 text-sm">Tanggal</th>
                                <th class="py-3 px-4 font-semibold text-slate-800 text-sm">Total</th>
                                <th class="py-3 px-4 font-semibold text-slate-800 text-sm">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (transactionList == null || transactionList.isEmpty()) { %>
                            <tr><td colspan="4" class="text-center py-6 text-slate-500">Belum ada transaksi.</td></tr>
                            <% } else {
                                int limit = 0;
                                for (Object objTrx : transactionList) {
                                    if (limit++ >= 5) break;
                                    model.Transaction trx = (model.Transaction) objTrx;
                                    String status = trx.getStatus() != null ? trx.getStatus() : "Selesai";
                            %>
                            <tr class="border-b border-slate-200 hover:bg-slate-50 transition-colors">
                                <td class="py-3 px-4 text-sm text-slate-800"><%= trx.getNoNota() %></td>
                                <td class="py-3 px-4 text-sm text-slate-800"><%= trx.getTanggal() %></td>
                                <td class="py-3 px-4 text-sm text-slate-800">Rp <%= String.format("%,d", trx.getTotalBelanja()).replace(',', '.') %></td>
                                <td class="py-3 px-4 text-sm">
                                    <span class="bg-green-100 text-green-700 px-2 py-1 rounded text-xs font-semibold"><%= status %></span>
                                </td>
                            </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
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
            <p class="text-slate-600 mb-6">Apakah Anda yakin ingin keluar dari aplikasi?</p>
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

        // ============================================================
        // DATA CHART — Di-inject dari JSP (server-side)
        // Servlet set: request.setAttribute("topProductList", List<Object[]>)
        //              request.setAttribute("hourlyData",     List<Object[]>)
        // ============================================================

        <%-- Data Barang Terlaris --%>
        const topProductLabels = [
            <% List<?> topProductList = (List<?>) request.getAttribute("topProductList");
               if (topProductList != null && !topProductList.isEmpty()) {
                   int i = 0;
                   for (Object row : topProductList) {
                       Object[] arr = (Object[]) row;
                       i++;
            %>
            "<%= arr[0] %>"<%= i < topProductList.size() ? "," : "" %>
            <%  }
               } %>
        ];
        const topProductData = [
            <% if (topProductList != null && !topProductList.isEmpty()) {
                   int i = 0;
                   for (Object row : topProductList) {
                       Object[] arr = (Object[]) row;
                       i++;
            %>
            <%= arr[1] %><%= i < topProductList.size() ? "," : "" %>
            <%  }
               } %>
        ];

        <%-- Data Waktu Tersibuk --%>
        const hourlyLabels = [];
        const hourlyData   = [];
        for (let h = 0; h < 24; h++) { hourlyLabels.push(h + ':00'); hourlyData.push(0); }

        <%  List<?> hourlyList = (List<?>) request.getAttribute("hourlyData");
            if (hourlyList != null && !hourlyList.isEmpty()) {
                for (Object row : hourlyList) {
                    Object[] arr = (Object[]) row; %>
        hourlyData[<%= arr[0] %>] = <%= arr[1] %>;
        <%      }
            } %>

        // ============================================================
        // RENDER CHART — Canvas: chartTopProducts
        // ============================================================
        new Chart(document.getElementById('chartTopProducts'), {
            type: 'bar',
            data: {
                labels: topProductLabels.length > 0 ? topProductLabels : ['Belum ada data'],
                datasets: [{
                    label: 'Terjual (unit)',
                    data: topProductData.length > 0 ? topProductData : [0],
                    backgroundColor: 'rgba(0, 68, 255, 0.75)',
                    borderRadius: 6,
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
            }
        });

        // ============================================================
        // RENDER CHART — Canvas: chartHourly (Pie Chart)
        // Hanya tampilkan jam yang ada transaksinya
        // ============================================================
        const pieColors = [
            '#0044ff','#3366ff','#6688ff','#99aaff',
            '#0033cc','#0055ee','#4477ff','#7799ff',
            '#2255dd','#5577ee','#88aaff','#aabbff',
            '#001188','#003399','#0044bb','#1155cc',
            '#2266dd','#3377ee','#4488ff','#6699ff',
            '#0022aa','#0033bb','#1144cc','#2255dd'
        ];

        // Filter hanya jam yang ada transaksinya
        const pieLabels = [];
        const pieData   = [];
        const pieClrs   = [];
        for (let h = 0; h < 24; h++) {
            if (hourlyData[h] > 0) {
                pieLabels.push(h + ':00');
                pieData.push(hourlyData[h]);
                pieClrs.push(pieColors[h % pieColors.length]);
            }
        }

        new Chart(document.getElementById('chartHourly'), {
            type: 'pie',
            data: {
                labels: pieLabels.length > 0 ? pieLabels : ['Belum ada data'],
                datasets: [{
                    label: 'Jumlah Transaksi',
                    data: pieData.length > 0 ? pieData : [1],
                    backgroundColor: pieLabels.length > 0 ? pieClrs : ['#e2e8f0'],
                    borderColor: '#ffffff',
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'right',
                        labels: {
                            boxWidth: 12,
                            font: { size: 11 }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(ctx) {
                                const total = ctx.dataset.data.reduce((a, b) => a + b, 0);
                                const pct   = ((ctx.parsed / total) * 100).toFixed(1);
                                return ' ' + ctx.label + ': ' + ctx.parsed + ' transaksi (' + pct + '%)';
                            }
                        }
                    }
                }
            }
        });

        // ============================================================
        // EXPORT PDF — Hanya capture stat cards + grafik (exportArea)
        // ============================================================
        async function exportDashboardPdf() {
            const btn  = document.getElementById('btnExportPdf');
            const orig = btn.innerHTML;
            btn.innerHTML = '<i data-lucide="loader" class="w-4 h-4 animate-spin"></i> Menyusun...';
            btn.disabled  = true;
            lucide.createIcons();

            // Tampilkan header export sementara
            const exportHeader = document.getElementById('exportHeader');
            exportHeader.classList.remove('hidden');

            try {
                const exportArea = document.getElementById('exportArea');
                const canvas     = await html2canvas(exportArea, {
                    scale: 2,
                    backgroundColor: '#ffffff',
                    useCORS: true
                });
                const imgData  = canvas.toDataURL('image/png');
                const { jsPDF } = window.jspdf;
                const pdf = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });
                const pageW  = pdf.internal.pageSize.getWidth();
                const pageH  = pdf.internal.pageSize.getHeight();
                const imgW   = pageW - 20;   // margin kiri-kanan 10mm
                const imgH   = (canvas.height * imgW) / canvas.width;
                const posX   = 10;
                const posY   = 10;

                // Jika tinggi gambar melebihi halaman, bagi ke multi-page
                if (imgH <= pageH - 20) {
                    pdf.addImage(imgData, 'PNG', posX, posY, imgW, imgH);
                } else {
                    let remainingH = imgH;
                    let offsetY    = 0;
                    while (remainingH > 0) {
                        const sliceH = Math.min(remainingH, pageH - 20);
                        pdf.addImage(imgData, 'PNG', posX, posY - offsetY, imgW, imgH);
                        remainingH -= sliceH;
                        offsetY    += sliceH;
                        if (remainingH > 0) pdf.addPage();
                    }
                }

                pdf.save('Dashboard-InvenTako.pdf');
            } catch (e) {
                alert('Gagal export PDF: ' + e.message);
            } finally {
                exportHeader.classList.add('hidden');
                btn.innerHTML = orig;
                btn.disabled  = false;
                lucide.createIcons();
            }
        }
    </script>

</body>
</html>