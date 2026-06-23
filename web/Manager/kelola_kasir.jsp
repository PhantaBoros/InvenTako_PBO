<%-- 
    Document   : kelola_kasir
    Created on : 12 Jun 2026, 14.29.46
    Author     : Muhammad Sabiq AZ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%
    List<?> kasirList = (List<?>) request.getAttribute("kasirList");
    String errorMessage   = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Kasir | InvenTako</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-white text-slate-800" style="height:100vh; overflow:hidden;">

    <!-- Header (fixed) -->
    <header class="fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-6 py-4 border-b border-slate-200 bg-white shadow-sm">
        <div class="text-3xl font-extrabold text-[#0044ff] tracking-tight">InvenTako</div>
        <div class="flex items-center gap-2 text-[#0044ff] cursor-pointer hover:text-blue-800 transition-colors" onclick="confirmLogout()">
            <i data-lucide="log-out" class="w-6 h-6"></i>
            <span class="text-base font-semibold uppercase">Logout</span>
        </div>
    </header>

    <!-- Sidebar (fixed) -->
    <aside class="fixed top-[65px] left-0 bottom-0 w-56 border-r border-slate-200 py-6 flex flex-col gap-1 bg-white z-40">
        <a href="${pageContext.request.contextPath}/manager/dashboard" class="flex items-center gap-3 px-6 py-3 text-black hover:bg-slate-50 transition-colors">
            <i data-lucide="layout-grid" class="w-5 h-5"></i>
            <span class="font-medium">Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/manager/barang" class="flex items-center gap-3 px-6 py-3 text-black hover:bg-slate-50 transition-colors">
            <i data-lucide="book-marked" class="w-5 h-5"></i>
            <span class="font-medium">Kelola Barang</span>
        </a>
        <a href="${pageContext.request.contextPath}/manager/kasir" class="flex items-center gap-3 px-6 py-3 bg-[#0044ff] text-white">
            <i data-lucide="users" class="w-5 h-5"></i>
            <span class="font-medium">Kelola Kasir</span>
        </a>
        <a href="${pageContext.request.contextPath}/manager/history" class="flex items-center gap-3 px-6 py-3 text-black hover:bg-slate-50 transition-colors">
            <i data-lucide="history" class="w-5 h-5"></i>
            <span class="font-medium">Riwayat Transaksi</span>
        </a>
    </aside>

    <!-- Main area: posisi fixed-height, tidak scroll sendiri -->
    <main class="absolute left-56 right-0 flex flex-col" style="top:65px; bottom:0; overflow:hidden;">

        <!-- Sticky top: judul + alert (tidak ikut scroll) -->
        <div class="flex-none px-8 pt-8 pb-4 bg-white">
            <h1 class="text-2xl font-bold text-black mb-4">Kelola Akun Kasir</h1>

            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="flex items-center gap-3 bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 mb-3 text-sm font-medium">
                <i data-lucide="alert-circle" class="w-4 h-4 flex-shrink-0"></i>
                <span><%= errorMessage %></span>
            </div>
            <% } %>
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="flex items-center gap-3 bg-green-50 border border-green-200 text-green-700 rounded-lg px-4 py-3 mb-3 text-sm font-medium">
                <i data-lucide="check-circle" class="w-4 h-4 flex-shrink-0"></i>
                <span><%= successMessage %></span>
            </div>
            <% } %>
        </div>

        <!-- Dua kolom dengan scroll independen masing-masing -->
        <div class="flex-1 flex gap-8 px-8 pb-8 overflow-hidden min-h-0">

            <!-- Kolom Kiri: Form Tambah Kasir — scroll sendiri -->
            <div class="w-80 flex-shrink-0 overflow-y-auto">
                <div class="bg-white border border-slate-200 rounded-xl p-6 shadow-sm">
                    <h2 class="text-base font-bold text-slate-900 mb-5 flex items-center gap-2">
                        <i data-lucide="user-plus" class="w-4 h-4 text-[#0044ff]"></i>
                        Tambah Akun Kasir
                    </h2>
                    <form action="${pageContext.request.contextPath}/manager/kasir" method="POST" class="flex flex-col gap-4">
                        <input type="hidden" name="action" value="tambahKasir">
                        <div>
                            <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Username</label>
                            <input type="text" name="username" required
                                class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20 focus:border-[#0044ff]"
                                placeholder="kasir01">
                        </div>
                        <div>
                            <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Email</label>
                            <input type="email" name="email" required
                                class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20 focus:border-[#0044ff]"
                                placeholder="kasir01@gmail.com">
                        </div>
                        <div>
                            <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Password</label>
                            <input type="password" name="password" required
                                class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20 focus:border-[#0044ff]"
                                placeholder="••••••••">
                        </div>
                        <div>
                            <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Shift</label>
                            <select name="shift" required
                                class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20 focus:border-[#0044ff]">
                                <option value="pagi">Pagi (06.00 – 12.00)</option>
                                <option value="siang">Siang (12.00 – 17.00)</option>
                                <option value="sore">Sore (17.00 – 21.00)</option>
                                <option value="malem">Malam (21.00 – 06.00)</option>
                            </select>
                        </div>
                        <button type="submit"
                            class="mt-2 w-full bg-[#0044ff] hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2">
                            <i data-lucide="user-plus" class="w-4 h-4"></i>
                            Buat Akun Kasir
                        </button>
                    </form>
                </div>
            </div>

            <!-- Kolom Kanan: Daftar Kasir — scroll sendiri -->
            <div class="flex-1 flex flex-col overflow-hidden min-h-0">
                <h2 class="flex-none text-base font-bold text-black mb-4">
                    Daftar Akun Kasir
                    <% if (kasirList != null) { %>
                    <span class="ml-2 text-sm font-normal text-slate-500">(<%= kasirList.size() %> akun)</span>
                    <% } %>
                </h2>
                <!-- Wrapper tabel dengan scroll hanya di body -->
                <div class="flex-1 border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col min-h-0">
                    <!-- Header tabel (sticky, tidak scroll) -->
                    <table class="w-full text-left border-collapse flex-shrink-0">
                        <thead>
                            <tr class="bg-slate-100 border-b border-slate-200">
                                <th class="py-3 px-4 font-semibold text-slate-700 text-sm w-10">No</th>
                                <th class="py-3 px-4 font-semibold text-slate-700 text-sm">Username</th>
                                <th class="py-3 px-4 font-semibold text-slate-700 text-sm">Email</th>
                                <th class="py-3 px-4 font-semibold text-slate-700 text-sm">Shift</th>
                                <th class="py-3 px-4 font-semibold text-slate-700 text-sm text-center">Aksi</th>
                            </tr>
                        </thead>
                    </table>
                    <!-- Body tabel (hanya ini yang scroll) -->
                    <div class="flex-1 overflow-y-auto">
                        <table class="w-full text-left border-collapse">
                            <tbody>
                                <% if (kasirList == null || kasirList.isEmpty()) { %>
                                <tr>
                                    <td colspan="5" class="text-center py-16 text-slate-400">
                                        <i data-lucide="users" class="w-10 h-10 mx-auto mb-2 opacity-30"></i>
                                        <p>Belum ada akun kasir yang terdaftar.</p>
                                    </td>
                                </tr>
                                <% } else {
                                    int no = 1;
                                    for (Object objKasir : kasirList) {
                                        model.Kasir k = (model.Kasir) objKasir;
                                %>
                                <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                                    <td class="py-3 px-4 text-sm text-slate-400 w-10"><%= no++ %></td>
                                    <td class="py-3 px-4 text-sm font-medium text-slate-800">
                                        <div class="flex items-center gap-2">
                                            <div class="w-7 h-7 rounded-full bg-[#0044ff]/10 flex items-center justify-center text-[#0044ff] font-bold text-xs">
                                                <%= k.getUsername().substring(0,1).toUpperCase() %>
                                            </div>
                                            <%= k.getUsername() %>
                                        </div>
                                    </td>
                                    <td class="py-3 px-4 text-sm text-slate-600"><%= k.getEmail() %></td>
                                    <td class="py-3 px-4 text-sm">
                                        <%
                                            String shiftLabel = "";
                                            String shiftClass = "";
                                            if ("pagi".equals(k.getShift()))       { shiftLabel = "Pagi";  shiftClass = "bg-yellow-50 text-yellow-700 border-yellow-200"; }
                                            else if ("siang".equals(k.getShift())) { shiftLabel = "Siang"; shiftClass = "bg-orange-50 text-orange-700 border-orange-200"; }
                                            else if ("sore".equals(k.getShift()))  { shiftLabel = "Sore";  shiftClass = "bg-purple-50 text-purple-700 border-purple-200"; }
                                            else if ("malem".equals(k.getShift())) { shiftLabel = "Malam"; shiftClass = "bg-slate-100 text-slate-700 border-slate-200"; }
                                        %>
                                        <span class="inline-block border px-2 py-0.5 rounded text-xs font-semibold <%= shiftClass %>"><%= shiftLabel %></span>
                                    </td>
                                    <td class="py-3 px-4 text-sm text-center">
                                        <form action="${pageContext.request.contextPath}/manager/kasir" method="POST"
                                              onsubmit="return confirm('Yakin hapus akun kasir <%= k.getUsername() %>?');">
                                            <input type="hidden" name="action"   value="hapusKasir"/>
                                            <input type="hidden" name="id"       value="<%= k.getId() %>"/>
                                            <button type="submit"
                                                class="inline-flex items-center gap-1 text-red-500 hover:text-red-700 border border-red-200 hover:border-red-400 px-3 py-1.5 rounded text-xs font-semibold transition-colors">
                                                <i data-lucide="trash-2" class="w-3 h-3"></i> Hapus
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <%  }
                                   } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- Logout Modal -->
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
