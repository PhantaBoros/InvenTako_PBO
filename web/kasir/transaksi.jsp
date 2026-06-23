<%-- 
    Document   : transaksi
    Created on : 20 Jun 2026
    Author     : Muhammad Sabiq AZ
    Updated on : 21 Jun 2026
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.LinkedHashSet"%>
<%@page import="java.util.Set"%>
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
    List<Product> productList = productDAO.getAvailable(user.getManagerId());

    Set<String> categorySet = new LinkedHashSet<String>();
    for (Product product : productList) {
        if (product.getKategori() != null && !product.getKategori().trim().isEmpty()) {
            categorySet.add(product.getKategori());
        }
    }

    String userName = KasirHelper.getDisplayName(user);
    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");
    String initials = KasirHelper.getInitials(userName);
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaksi Kasir | InvenTako</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background:
                radial-gradient(circle at top left, rgba(0,68,255,0.07), transparent 30%),
                radial-gradient(circle at bottom right, rgba(15,23,42,0.04), transparent 28%),
                #ffffff;
        }
    </style>
</head>
<body class="min-h-screen text-slate-800">
    <header class="fixed top-0 left-0 right-0 z-50 flex items-center justify-between border-b border-slate-200 bg-white/95 backdrop-blur px-6 py-4 shadow-sm">
        <div class="flex items-center gap-6">
            <div class="text-3xl font-extrabold text-[#0044ff] tracking-tight">InvenTako</div>
            <nav class="hidden sm:flex items-center gap-2 rounded-full border border-slate-200 bg-slate-50 p-1">
                <a href="${pageContext.request.contextPath}/kasir/transaksi.jsp" class="rounded-full bg-[#0044ff] px-4 py-2 text-sm font-semibold text-white shadow-sm">Transaksi</a>
                <a href="${pageContext.request.contextPath}/kasir/riwayat_transaksi.jsp" class="rounded-full px-4 py-2 text-sm font-semibold text-slate-500 hover:text-slate-900">Riwayat Transaksi</a>
                <a href="${pageContext.request.contextPath}/kasir/barang_stok_habis.jsp" class="rounded-full px-4 py-2 text-sm font-semibold text-slate-500 hover:text-slate-900">Stok Barang Habis</a>
            </nav>
        </div>
        <button type="button" onclick="openProfileModal()" class="flex items-center gap-3 text-[#0044ff] cursor-pointer hover:opacity-80 transition-opacity">
            <div class="flex h-11 w-11 items-center justify-center rounded-full border-2 border-[#0044ff] text-[#0044ff] text-sm font-bold bg-blue-50 tracking-wider">
                <%= initials %>
            </div>
            <span class="text-lg font-medium"><%= userName %></span>
        </button>
    </header>

    <div class="flex pt-20 min-h-screen">
        <%@ include file="_sidebar.jspf" %>

        <main class="ml-[270px] flex-1 px-6 py-6 lg:pr-[340px]">
            <div class="mb-5 flex flex-wrap items-start justify-between gap-4">
                <div>
                    <h1 class="text-3xl font-bold text-slate-900">Transaksi Baru</h1>
                    <p class="mt-2 text-lg text-slate-700">Pilih barang dari sidebar untuk memulai</p>
                </div>
            </div>

            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="mb-5 rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-700">
                <%= successMessage %>
            </div>
            <% } %>
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="mb-5 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm font-medium text-rose-700">
                <%= errorMessage %>
            </div>
            <% if (errorMessage.toLowerCase().contains("stok")) { %>
            <script>
                window.addEventListener('DOMContentLoaded', function () {
                    alert('Stok barang telah habis');
                });
            </script>
            <% } %>
            <% } %>

            <section class="mt-10 max-w-4xl">
                <div class="mb-3 flex items-center justify-between">
                    <p class="text-sm font-semibold uppercase tracking-[0.22em] text-slate-400">Daftar Barang</p>
                    <p class="text-sm text-slate-500"><span id="cartItemCountTop">0</span> item</p>
                </div>
                <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
                    <table class="w-full border-collapse text-left">
                        <thead>
                            <tr class="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-[0.18em] text-slate-400">
                                <th class="px-5 py-4 font-semibold text-center">Barang</th>
                                <th class="px-5 py-4 font-semibold text-center">Harga Satuan</th>
                                <th class="px-5 py-4 font-semibold text-center">Qty</th>
                                <th class="px-5 py-4 font-semibold text-center">Subtotal</th>
                                <th class="px-5 py-4 font-semibold text-center">Aksi</th>
                            </tr>
                        </thead>
                        <tbody id="cartTableBody">
                            <tr id="cartEmptyRow">
                                <td colspan="5" class="px-5 py-16 text-center">
                                    <div class="flex flex-col items-center justify-center gap-4 text-slate-400">
                                        <div class="flex h-16 w-16 items-center justify-center rounded-full bg-slate-100 text-slate-500">
                                            <i data-lucide="shopping-cart" class="h-8 w-8"></i>
                                        </div>
                                        <div>
                                            <p class="text-lg font-medium text-slate-500">Belum ada barang ditambahkan</p>
                                            <p class="mt-1 text-sm">Pilih barang dari sidebar untuk mengisi keranjang.</p>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>

        <aside class="fixed right-0 top-20 bottom-0 w-[320px] overflow-y-auto border-l border-slate-200 bg-white/95 backdrop-blur px-4 py-6">
            <div class="space-y-6">
                <section class="rounded-2xl border border-slate-200 bg-white p-4 shadow-[0_10px_25px_rgba(15,23,42,0.08)]">
                    <h2 class="text-lg font-extrabold text-slate-900">Detail Transaksi</h2>
                    <div class="mt-5 space-y-5 text-sm text-slate-600">
                        <div>
                            <div class="flex items-center justify-between">
                                <span>Total item</span>
                                <span id="detailTotalItem" class="font-semibold text-slate-900">0</span>
                            </div>
                            <div class="mt-2 h-px bg-slate-300"></div>
                        </div>
                        <div>
                            <div class="flex items-center justify-between">
                                <span>Subtotal</span>
                                <span id="detailSubtotal" class="font-semibold text-slate-900">Rp 0</span>
                            </div>
                            <div class="mt-2 h-px bg-slate-300"></div>
                        </div>
                        <div>
                            <div class="flex items-center justify-between">
                                <span>PPN(11%)</span>
                                <span id="detailPpn" class="font-semibold text-slate-900">Rp 0</span>
                            </div>
                            <div class="mt-2 h-px bg-slate-300"></div>
                        </div>
                    </div>

                    <div class="mt-5 rounded-xl bg-[#0044ff] px-4 py-4 text-white shadow-sm">
                        <div class="flex items-center justify-between text-sm font-medium">
                            <span>TOTAL:</span>
                            <span id="grandTotalText">Rp 0</span>
                        </div>
                    </div>

                    <button type="button" id="confirmTransactionBtn" class="relative mt-4 flex w-full items-center justify-center rounded-xl bg-[#0044ff] px-4 py-4 text-sm font-semibold text-white shadow-lg shadow-[#0044ff]/20 transition-transform hover:-translate-y-0.5 text-center">
                        <i data-lucide="check" class="absolute left-4 h-4 w-4 shrink-0"></i>
                        <span class="w-full text-center">Konfirmasi Transaksi</span>
                    </button>
                </section>

                <form id="checkoutForm" action="${pageContext.request.contextPath}/kasir/checkout" method="POST" class="hidden">
                    <input type="hidden" name="paymentMethod" id="checkoutPaymentMethod" value="tunai">
                    <div id="checkoutInputs"></div>
                </form>
            </div>
        </aside>
    </div>

    <div id="confirmTransactionModal" class="fixed inset-0 z-[60] hidden items-center justify-center px-4 py-6">
        <div class="absolute inset-0 bg-slate-950/45 backdrop-blur-[2px]"></div>
        <div class="relative w-full max-w-lg overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-[0_30px_80px_rgba(15,23,42,0.28)]">
            <div class="flex items-start justify-between border-b border-slate-100 px-6 py-5">
                <div>
                    <p class="text-xl font-bold text-slate-900">Konfirmasi Transaksi</p>
                    <p class="mt-1 text-sm text-slate-500">Pastikan detail transaksi sudah benar sebelum diproses.</p>
                </div>
                <button type="button" id="confirmTransactionClose" class="rounded-full bg-slate-100 p-2 text-slate-500 hover:bg-slate-200 hover:text-slate-700">
                    <i data-lucide="x" class="h-4 w-4"></i>
                </button>
            </div>
            <div class="px-6 py-5">
                <div id="confirmTransactionSummary" class="mt-4 max-h-56 space-y-3 overflow-y-auto pr-1"></div>
                <div class="mt-5 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm text-slate-600">
                    <div class="flex items-center justify-between">
                        <span>Subtotal</span>
                        <span id="confirmTransactionSubtotal" class="font-semibold text-slate-900">Rp 0</span>
                    </div>
                    <div class="mt-2 flex items-center justify-between">
                        <span>PPN (11%)</span>
                        <span id="confirmTransactionPpn" class="font-semibold text-slate-900">Rp 0</span>
                    </div>
                    <div class="mt-3 flex items-center justify-between border-t border-slate-200 pt-3 text-base">
                        <span class="font-semibold text-slate-700">Total</span>
                        <span id="confirmTransactionTotal" class="font-bold text-[#0044ff]">Rp 0</span>
                    </div>
                </div>
            </div>
            <div class="flex items-center justify-between border-t border-slate-100 bg-slate-50 px-6 py-4">
                <button type="button" id="confirmTransactionCancel" class="rounded-xl bg-rose-100 px-5 py-3 text-sm font-semibold text-rose-700 hover:bg-rose-200">Cancel</button>
                <button type="button" id="confirmTransactionOk" class="rounded-xl bg-[#0044ff] px-5 py-3 text-sm font-semibold text-white shadow-sm hover:opacity-95">OK</button>
            </div>
        </div>
    </div>

    <%@ include file="_profileModal.jspf" %>

    <script src="${pageContext.request.contextPath}/assets/js/kasir-transaksi.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>