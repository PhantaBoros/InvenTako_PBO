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
    <%-- jsPDF + html2canvas untuk download struk (teknologi sama seperti dashboard) --%>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>

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
                                <%-- Tombol Lihat Detail — trigger AJAX modal --%>
                                <button onclick="lihatDetail(<%= trx.getId() %>)"
                                    class="text-[#0044ff] hover:bg-blue-100 px-3 py-1.5 rounded text-xs font-semibold border border-blue-200 transition-colors">
                                    Lihat Detail
                                </button>
                            </td>
                        </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>

        </main>
    </div>

    <%-- ============================================================
         MODAL DETAIL TRANSAKSI
         ============================================================ --%>
    <div id="detailModal" class="hidden fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-lg flex flex-col max-h-[90vh]">

            <%-- Header Modal --%>
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-blue-50 rounded-full flex items-center justify-center">
                        <i data-lucide="receipt" class="w-5 h-5 text-[#0044ff]"></i>
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-slate-900">Detail Transaksi</h2>
                        <p class="text-xs text-slate-400" id="modalNoNota">—</p>
                    </div>
                </div>
                <button onclick="closeDetailModal()" class="text-slate-400 hover:text-red-500 transition-colors">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <%-- Loading State --%>
            <div id="modalLoading" class="flex-1 flex items-center justify-center py-12">
                <div class="flex flex-col items-center gap-3 text-slate-400">
                    <i data-lucide="loader" class="w-8 h-8 animate-spin"></i>
                    <p class="text-sm">Memuat data...</p>
                </div>
            </div>

            <%-- Content (tersembunyi saat loading) --%>
            <div id="modalContent" class="hidden flex-1 overflow-y-auto px-6 py-4 flex flex-col gap-4">

                <%-- Info Header Transaksi --%>
                <div class="grid grid-cols-2 gap-3">
                    <div class="bg-slate-50 rounded-lg p-3">
                        <p class="text-xs font-bold uppercase text-slate-400 mb-1">Tanggal</p>
                        <p class="text-sm font-semibold text-slate-800" id="modalTanggal">—</p>
                    </div>
                    <div class="bg-slate-50 rounded-lg p-3">
                        <p class="text-xs font-bold uppercase text-slate-400 mb-1">Kasir</p>
                        <p class="text-sm font-semibold text-slate-800" id="modalKasir">—</p>
                    </div>
                    <div class="bg-slate-50 rounded-lg p-3">
                        <p class="text-xs font-bold uppercase text-slate-400 mb-1">Uang Tunai</p>
                        <p class="text-sm font-semibold text-slate-800" id="modalUangTunai">—</p>
                    </div>
                    <div class="bg-slate-50 rounded-lg p-3">
                        <p class="text-xs font-bold uppercase text-slate-400 mb-1">Kembalian</p>
                        <p class="text-sm font-semibold text-slate-800" id="modalKembalian">—</p>
                    </div>
                </div>

                <%-- Tabel Item Belanja --%>
                <div>
                    <h3 class="text-sm font-bold text-slate-700 mb-2 flex items-center gap-2">
                        <i data-lucide="shopping-cart" class="w-4 h-4 text-[#0044ff]"></i>
                        Daftar Item
                    </h3>
                    <div class="border border-slate-200 rounded-lg overflow-hidden">
                        <table class="w-full text-left border-collapse text-sm">
                            <thead>
                                <tr class="bg-slate-100 border-b border-slate-200">
                                    <th class="py-2 px-3 font-semibold text-slate-600 text-xs">Nama Barang</th>
                                    <th class="py-2 px-3 font-semibold text-slate-600 text-xs text-center">Qty</th>
                                    <th class="py-2 px-3 font-semibold text-slate-600 text-xs text-right">Harga</th>
                                    <th class="py-2 px-3 font-semibold text-slate-600 text-xs text-right">Subtotal</th>
                                </tr>
                            </thead>
                            <tbody id="modalItemsBody">
                                <!-- diisi via JS -->
                            </tbody>
                        </table>
                    </div>
                </div>

                <%-- Total --%>
                <div class="flex items-center justify-between bg-[#0044ff]/5 border border-[#0044ff]/20 rounded-lg px-4 py-3">
                    <span class="text-sm font-bold text-slate-700">Total Belanja</span>
                    <span class="text-lg font-extrabold text-[#0044ff]" id="modalTotal">—</span>
                </div>

            </div>

            <%-- Footer Tombol --%>
            <div id="modalFooter" class="hidden border-t border-slate-100 px-6 py-4 flex gap-3">
                <button onclick="closeDetailModal()"
                    class="flex-1 px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold rounded-lg transition-colors text-sm">
                    Tutup
                </button>
                <button id="btnDownloadStruk" onclick="downloadStruk()"
                    class="flex-1 px-4 py-2.5 bg-[#0044ff] hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors text-sm flex items-center justify-center gap-2">
                    <i data-lucide="download" class="w-4 h-4"></i>
                    Download Struk
                </button>
            </div>

        </div>
    </div>

    <%-- ============================================================
         STRUK PRINT AREA — hidden off-screen, di-capture oleh html2canvas
         (Teknologi sama persis seperti dashboard: screenshot HTML -> PDF)
         ============================================================ --%>
    <div id="strukPrintArea" style="position:fixed; left:-9999px; top:0; width:320px; background:#fff; padding:24px; font-family:'Inter',sans-serif;">
        <div style="text-align:center; margin-bottom:12px;">
            <div style="font-size:20px; font-weight:800; color:#0044ff; letter-spacing:-0.5px;">InvenTako</div>
            <div style="font-size:11px; color:#94a3b8; margin-top:2px;">Struk Pembelian</div>
        </div>
        <div style="border-top:2px solid #e2e8f0; margin-bottom:12px;"></div>
        <div style="font-size:11px; color:#475569; margin-bottom:10px; line-height:1.8;">
            <div><span style="display:inline-block;width:80px;font-weight:600;">No. Nota</span>: <span id="sp_noNota"></span></div>
            <div><span style="display:inline-block;width:80px;font-weight:600;">Tanggal</span>: <span id="sp_tanggal"></span></div>
            <div><span style="display:inline-block;width:80px;font-weight:600;">Kasir</span>: <span id="sp_kasir"></span></div>
            <div><span style="display:inline-block;width:80px;font-weight:600;">Status</span>: <span id="sp_status"></span></div>
        </div>
        <div style="border-top:1px dashed #cbd5e1; margin-bottom:8px;"></div>
        <table style="width:100%; font-size:11px; border-collapse:collapse; margin-bottom:8px;">
            <thead>
                <tr style="font-weight:700; color:#1e293b; border-bottom:1px solid #e2e8f0;">
                    <td style="padding:4px 0;">Barang</td>
                    <td style="padding:4px 4px; text-align:center;">Qty</td>
                    <td style="padding:4px 0; text-align:right;">Harga</td>
                    <td style="padding:4px 0; text-align:right;">Subtotal</td>
                </tr>
            </thead>
            <tbody id="sp_items"></tbody>
        </table>
        <div style="border-top:1px dashed #cbd5e1; margin-bottom:10px;"></div>
        <div style="font-size:11px; color:#475569; line-height:1.9;">
            <div style="display:flex; justify-content:space-between;"><span>Uang Tunai</span><span id="sp_tunai"></span></div>
            <div style="display:flex; justify-content:space-between;"><span>Kembalian</span><span id="sp_kembalian"></span></div>
        </div>
        <div style="border-top:2px solid #e2e8f0; margin:10px 0;"></div>
        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:800; color:#0044ff;">
            <span>TOTAL</span><span id="sp_total"></span>
        </div>
        <div style="border-top:2px solid #e2e8f0; margin:10px 0;"></div>
        <div style="text-align:center; font-size:10px; color:#94a3b8; line-height:1.8;">
            <div>Terima kasih telah berbelanja!</div>
            <div>InvenTako &mdash; Powered by PBO Project</div>
        </div>
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

        // ── Logout ─────────────────────────────────────────────────
        function confirmLogout() { document.getElementById('logoutConfirmModal').classList.remove('hidden'); }
        function cancelLogout()  { document.getElementById('logoutConfirmModal').classList.add('hidden'); }

        // ── State detail transaksi yang sedang dibuka ───────────────
        let currentTrx = null;

        // ── Helper: format angka ke Rupiah ──────────────────────────
        function rupiah(n) {
            return 'Rp ' + Number(n).toLocaleString('id-ID');
        }

        // ── Buka modal & fetch detail via AJAX ──────────────────────
        function lihatDetail(id) {
            currentTrx = null;
            document.getElementById('modalLoading').classList.remove('hidden');
            document.getElementById('modalContent').classList.add('hidden');
            document.getElementById('modalFooter').classList.add('hidden');
            document.getElementById('modalNoNota').textContent = '—';
            document.getElementById('detailModal').classList.remove('hidden');
            lucide.createIcons();

            fetch('${pageContext.request.contextPath}/manager/history/detail?id=' + id)
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    if (data.error) {
                        closeDetailModal();
                        return;
                    }
                    currentTrx = data;
                    renderModal(data);
                })
                .catch(function() { closeDetailModal(); });
        }

        // ── Render data ke dalam modal ──────────────────────────────
        function renderModal(data) {
            document.getElementById('modalNoNota').textContent    = data.noNota;
            document.getElementById('modalTanggal').textContent   = data.tanggal;
            document.getElementById('modalKasir').textContent     = data.kasir;
            document.getElementById('modalUangTunai').textContent = rupiah(data.uangTunai);
            document.getElementById('modalKembalian').textContent = rupiah(data.kembalian);
            document.getElementById('modalTotal').textContent     = rupiah(data.totalBelanja);

            const tbody = document.getElementById('modalItemsBody');
            tbody.innerHTML = '';
            if (!data.items || data.items.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" class="text-center py-4 text-slate-400 text-xs">Tidak ada item</td></tr>';
            } else {
                data.items.forEach(function(item) {
                    const tr = document.createElement('tr');
                    tr.className = 'border-b border-slate-100 last:border-0';
                    tr.innerHTML =
                        '<td class="py-2 px-3 text-slate-800">' + item.namaBarang + '</td>' +
                        '<td class="py-2 px-3 text-center text-slate-600">' + item.qty + '</td>' +
                        '<td class="py-2 px-3 text-right text-slate-600">' + rupiah(item.hargaSatuan) + '</td>' +
                        '<td class="py-2 px-3 text-right font-semibold text-slate-800">' + rupiah(item.subtotal) + '</td>';
                    tbody.appendChild(tr);
                });
            }

            document.getElementById('modalLoading').classList.add('hidden');
            document.getElementById('modalContent').classList.remove('hidden');
            document.getElementById('modalFooter').classList.remove('hidden');
            lucide.createIcons();
        }

        // ── Tutup modal ─────────────────────────────────────────────
        function closeDetailModal() {
            document.getElementById('detailModal').classList.add('hidden');
            currentTrx = null;
        }

        // ── Download Struk — html2canvas + jsPDF ────────────────────
        // Teknologi identik dengan dashboard: screenshot elemen HTML -> PDF
        async function downloadStruk() {
            if (!currentTrx) return;

            // 1. Isi template struk (#strukPrintArea) dengan data transaksi
            document.getElementById('sp_noNota').textContent    = currentTrx.noNota;
            document.getElementById('sp_tanggal').textContent   = currentTrx.tanggal;
            document.getElementById('sp_kasir').textContent     = currentTrx.kasir;
            document.getElementById('sp_status').textContent    = currentTrx.status;
            document.getElementById('sp_tunai').textContent     = rupiah(currentTrx.uangTunai);
            document.getElementById('sp_kembalian').textContent = rupiah(currentTrx.kembalian);
            document.getElementById('sp_total').textContent     = rupiah(currentTrx.totalBelanja);

            const spItems = document.getElementById('sp_items');
            spItems.innerHTML = '';
            (currentTrx.items || []).forEach(function(item) {
                const tr = document.createElement('tr');
                tr.style.borderBottom = '1px solid #f1f5f9';
                tr.innerHTML =
                    '<td style="padding:3px 0; color:#1e293b;">' + item.namaBarang + '</td>' +
                    '<td style="padding:3px 4px; text-align:center; color:#475569;">' + item.qty + '</td>' +
                    '<td style="padding:3px 0; text-align:right; color:#475569;">' + rupiah(item.hargaSatuan) + '</td>' +
                    '<td style="padding:3px 0; text-align:right; font-weight:600; color:#1e293b;">' + rupiah(item.subtotal) + '</td>';
                spItems.appendChild(tr);
            });

            // 2. Ubah tombol jadi loading (sama persis seperti dashboard)
            const btn  = document.getElementById('btnDownloadStruk');
            const orig = btn.innerHTML;
            btn.innerHTML = '<i data-lucide="loader" class="w-4 h-4 animate-spin"></i> Menyusun...';
            btn.disabled  = true;
            lucide.createIcons();

            try {
                // 3. Capture elemen struk dengan html2canvas
                const strukEl = document.getElementById('strukPrintArea');
                const canvas  = await html2canvas(strukEl, {
                    scale: 3,
                    backgroundColor: '#ffffff',
                    useCORS: true
                });
                const imgData = canvas.toDataURL('image/png');

                // 4. Buat PDF A5 portrait & sisipkan gambar (sama seperti dashboard)
                const { jsPDF } = window.jspdf;
                const pdf   = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a5' });
                const pageW = pdf.internal.pageSize.getWidth();
                const pageH = pdf.internal.pageSize.getHeight();
                const imgW  = pageW - 20;
                const imgH  = (canvas.height * imgW) / canvas.width;
                const posX  = 10;
                const posY  = 10;

                // Multi-page jika konten melebihi satu halaman
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

                pdf.save('Struk-' + currentTrx.noNota + '.pdf');
            } catch (e) {
                console.error('Gagal download struk:', e);
            } finally {
                btn.innerHTML = orig;
                btn.disabled  = false;
                lucide.createIcons();
            }
        }

        // Tutup modal jika klik backdrop
        document.getElementById('detailModal').addEventListener('click', function(e) {
            if (e.target === this) closeDetailModal();
        });

    </script>

</body>
</html>
