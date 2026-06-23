<%-- 
    Document   : kelola_barang
    Created on : 12 Jun 2026, 14.29.35
    Author     : Muhammad Sabiq AZ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%--
    Model yang dibutuhkan:
    - com.inventako.model.Product (id, kode, nama, kategori, harga, stok)

    Servlet Contract:
    - request.setAttribute("productList",     List<Product>)
    - request.setAttribute("editProduct",     Product)   — isi form edit (optional)
    - request.setAttribute("errorMessage",    String)
    - request.setAttribute("successMessage",  String)
    - Aksi tambah : POST ProductServlet?action=add
    - Aksi edit   : POST ProductServlet?action=edit
    - Aksi hapus  : POST ProductServlet?action=delete  + productId
--%>
<%
    List<?> productList     = (List<?>) request.getAttribute("productList");
    Object  editProductAttr = request.getAttribute("editProduct");
    model.Product editProduct = editProductAttr != null
        ? (model.Product) editProductAttr : null;
    String errorMessage   = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Barang | InvenTako</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-white min-h-screen flex flex-col text-slate-800">

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
            <a href="${pageContext.request.contextPath}/manager/barang" class="flex items-center gap-3 px-6 py-3 bg-[#0044ff] text-white">
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

        <main class="flex-1 p-8 overflow-y-auto bg-white ml-56">

            <div class="flex justify-between items-center mb-6">
                <h1 class="text-2xl font-bold text-black">Kelola Barang</h1>
                <button onclick="openModalTambah()"
                    class="bg-[#0044ff] hover:bg-blue-700 text-white px-5 py-2.5 rounded-md font-medium transition-colors shadow-sm flex items-center gap-2">
                    <i data-lucide="plus" class="w-4 h-4"></i> Tambah Barang
                </button>
            </div>

            <%-- Alert dari Servlet --%>
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="flex items-center gap-3 bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 mb-6 text-sm font-medium">
                <i data-lucide="alert-circle" class="w-4 h-4 flex-shrink-0"></i>
                <span><%= errorMessage %></span>
            </div>
            <% } %>
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="flex items-center gap-3 bg-green-50 border border-green-200 text-green-700 rounded-lg px-4 py-3 mb-6 text-sm font-medium">
                <i data-lucide="check-circle" class="w-4 h-4 flex-shrink-0"></i>
                <span><%= successMessage %></span>
            </div>
            <% } %>

            <!-- Tabel Barang -->
            <div class="border border-slate-200 rounded-md bg-white shadow-sm overflow-hidden">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-200 border-b border-slate-200">
                            <th class="py-3 px-4 font-semibold text-slate-800 text-sm">Kode</th>
                            <th class="py-3 px-4 font-semibold text-slate-800 text-sm">Nama Barang</th>
                            <th class="py-3 px-4 font-semibold text-slate-800 text-sm">Kategori</th>
                            <th class="py-3 px-4 font-semibold text-slate-800 text-sm">Harga</th>
                            <th class="py-3 px-4 font-semibold text-slate-800 text-sm">Stok</th>
                            <th class="py-3 px-4 font-semibold text-slate-800 text-sm">Status</th>
                            <th class="py-3 px-4 font-semibold text-slate-800 text-sm text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%-- ============================================================
                             JSP LOOP: Iterasi List<Product> dari Servlet
                             ============================================================ --%>
                        <% if (productList == null || productList.isEmpty()) { %>
                        <tr>
                            <td colspan="7" class="text-center py-10 text-slate-500">Belum ada barang yang ditambahkan.</td>
                        </tr>
                        <% } else {
                            for (Object objProd : productList) {
                                model.Product p = (model.Product) objProd;
                                String statusClass, statusLabel;
                                if (p.getStok() > 5) {
                                    statusClass = "bg-green-100 text-green-700"; statusLabel = "Tersedia";
                                } else if (p.getStok() > 0) {
                                    statusClass = "bg-amber-100 text-amber-700"; statusLabel = "Menipis";
                                } else {
                                    statusClass = "bg-red-100 text-red-700"; statusLabel = "Habis";
                                }
                        %>
                        <tr class="border-b border-slate-200 hover:bg-slate-50 transition-colors">
                            <td class="py-4 px-4 text-sm text-slate-800"><%= p.getKode() %></td>
                            <td class="py-4 px-4 text-sm font-medium text-slate-800"><%= p.getNama() %></td>
                            <td class="py-4 px-4 text-sm text-slate-800"><%= p.getKategori() %></td>
                            <td class="py-4 px-4 text-sm text-slate-800">Rp <%= String.format("%,d", p.getHarga()).replace(',', '.') %></td>
                            <td class="py-4 px-4 text-sm text-slate-800"><%= p.getStok() %></td>
                            <td class="py-4 px-4 text-sm">
                                <span class="<%= statusClass %> px-2 py-1 rounded text-xs font-semibold"><%= statusLabel %></span>
                            </td>
                            <td class="py-4 px-4 text-sm text-center">
                                <div class="flex items-center justify-center gap-3">
                                    <%-- Tombol Edit: buka modal dengan data produk --%>
                                    <button onclick="openModalEdit('<%= p.getId() %>', '<%= p.getKode() %>', '<%= p.getNama().replace("'", "\\'") %>', '<%= p.getKategori() %>', '<%= p.getHarga() %>', '<%= p.getStok() %>')"
                                        class="text-slate-700 hover:text-black">
                                        <i data-lucide="edit" class="w-4 h-4"></i>
                                    </button>
                                    <%-- Tombol Hapus: form POST ke ProductServlet?action=delete --%>
                                    <form action="${pageContext.request.contextPath}/ProductServlet?action=delete" method="POST"
                                          onsubmit="return confirm('Yakin hapus barang <%= p.getNama() %>?');">
                                        <input type="hidden" name="productId" value="<%= p.getId() %>"/>
                                        <button type="submit" class="text-red-500 hover:text-red-700">
                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>

        </main>
    </div>

    <!-- ============================================================
         MODAL TAMBAH BARANG
         action: POST ProductServlet?action=add
         ============================================================ -->
    <div id="modalTambah" class="hidden fixed inset-0 z-50 items-center justify-center bg-black/40 backdrop-blur-sm p-4">
        <div class="bg-white rounded-xl shadow-2xl p-6 max-w-lg w-full">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-xl font-bold text-slate-900">Tambah Barang Baru</h2>
                <button onclick="closeModal('modalTambah')" class="text-slate-400 hover:text-red-500 transition-colors">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/ProductServlet?action=add" method="POST" class="grid grid-cols-2 gap-4">
                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Kode Barang</label>
                    <input type="text" name="kode" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20"
                        placeholder="PRD-001">
                </div>
                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Kategori</label>
                    <input type="text" name="kategori" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20"
                        placeholder="Minuman">
                </div>
                <div class="col-span-2">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Nama Barang</label>
                    <input type="text" name="nama" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20"
                        placeholder="Nama produk">
                </div>
                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Harga (Rp)</label>
                    <input type="number" name="harga" min="0" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20"
                        placeholder="15000">
                </div>
                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Stok</label>
                    <input type="number" name="stok" min="0" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20"
                        placeholder="100">
                </div>
                <div class="col-span-2 flex gap-3 mt-2">
                    <button type="button" onclick="closeModal('modalTambah')"
                        class="flex-1 px-4 py-2.5 bg-slate-200 hover:bg-slate-300 text-slate-900 font-semibold rounded-lg transition-colors">
                        Batal
                    </button>
                    <button type="submit"
                        class="flex-1 px-4 py-2.5 bg-[#0044ff] hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors">
                        Simpan Barang
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- ============================================================
         MODAL EDIT BARANG
         action: POST ProductServlet?action=edit
         ============================================================ -->
    <div id="modalEdit" class="hidden fixed inset-0 z-50 items-center justify-center bg-black/40 backdrop-blur-sm p-4">
        <div class="bg-white rounded-xl shadow-2xl p-6 max-w-lg w-full">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-xl font-bold text-slate-900">Edit Barang</h2>
                <button onclick="closeModal('modalEdit')" class="text-slate-400 hover:text-red-500 transition-colors">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/ProductServlet?action=edit" method="POST" class="grid grid-cols-2 gap-4">
                <input type="hidden" id="editProductId" name="productId"/>
                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Kode Barang</label>
                    <input type="text" id="editKode" name="kode" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20">
                </div>
                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Kategori</label>
                    <input type="text" id="editKategori" name="kategori" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20">
                </div>
                <div class="col-span-2">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Nama Barang</label>
                    <input type="text" id="editNama" name="nama" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20">
                </div>
                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Harga (Rp)</label>
                    <input type="number" id="editHarga" name="harga" min="0" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20">
                </div>
                <div class="col-span-2 sm:col-span-1">
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-500 mb-1.5">Stok</label>
                    <input type="number" id="editStok" name="stok" min="0" required
                        class="w-full px-4 py-2.5 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#0044ff]/20">
                </div>
                <div class="col-span-2 flex gap-3 mt-2">
                    <button type="button" onclick="closeModal('modalEdit')"
                        class="flex-1 px-4 py-2.5 bg-slate-200 hover:bg-slate-300 text-slate-900 font-semibold rounded-lg transition-colors">
                        Batal
                    </button>
                    <button type="submit"
                        class="flex-1 px-4 py-2.5 bg-[#0044ff] hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors">
                        Simpan Perubahan
                    </button>
                </div>
            </form>
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

        function openModalTambah() {
            document.getElementById('modalTambah').classList.remove('hidden');
            document.getElementById('modalTambah').classList.add('flex');
        }

        function openModalEdit(id, kode, nama, kategori, harga, stok) {
            document.getElementById('editProductId').value = id;
            document.getElementById('editKode').value      = kode;
            document.getElementById('editNama').value      = nama;
            document.getElementById('editKategori').value  = kategori;
            document.getElementById('editHarga').value     = harga;
            document.getElementById('editStok').value      = stok;
            document.getElementById('modalEdit').classList.remove('hidden');
            document.getElementById('modalEdit').classList.add('flex');
        }

        function closeModal(id) {
            document.getElementById(id).classList.add('hidden');
            document.getElementById(id).classList.remove('flex');
        }

        function confirmLogout() { document.getElementById('logoutConfirmModal').classList.remove('hidden'); }
        function cancelLogout()  { document.getElementById('logoutConfirmModal').classList.add('hidden'); }

        <%-- Jika ada editProduct dari Servlet (redirect setelah error edit), buka modal edit langsung --%>
        <% if (editProduct != null) { %>
        window.addEventListener('DOMContentLoaded', () => {
            openModalEdit(
                '<%= editProduct.getId() %>',
                '<%= editProduct.getKode() %>',
                '<%= editProduct.getNama().replace("'", "\\'") %>',
                '<%= editProduct.getKategori() %>',
                '<%= editProduct.getHarga() %>',
                '<%= editProduct.getStok() %>'
            );
        });
        <% } %>
    </script>

</body>
</html>
