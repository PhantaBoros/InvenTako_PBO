<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Transaction"%>
<%@page import="model.TransactionDetail"%>
<%@page import="java.util.List"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.util.Locale"%>
<%
    Transaction transaction = (Transaction) request.getAttribute("transaction");
    List<TransactionDetail> details = (List<TransactionDetail>) request.getAttribute("details");
    DecimalFormatSymbols symbols = new DecimalFormatSymbols(new Locale("id", "ID"));
    symbols.setGroupingSeparator('.');
    DecimalFormat formatter = new DecimalFormat("#,###", symbols);
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Struk Pembayaran | InvenTako</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
        }
        @media print {
            @page {
                margin: 8mm;
            }
            html, body {
                background: white !important;
                padding: 0 !important;
                margin: 0 !important;
                min-height: 100vh !important;
                height: 100vh !important;
            }
            body {
                display: flex !important;
                align-items: center !important;
                justify-content: center !important;
                position: relative !important;
            }
            .no-print {
                display: none !important;
            }
            body > :not(.print-header-top-right):not(.print-container) {
                display: none !important;
            }
            .print-container {
                border: none !important;
                box-shadow: none !important;
                padding: 0 !important;
                margin: 0 auto !important;
                width: 100% !important;
                max-width: 100% !important;
                break-inside: avoid !important;
                page-break-inside: avoid !important;
            }
            .print-header-top-right {
                position: absolute;
                top: 0;
                right: 0;
                display: block !important;
                font-size: 12px;
                color: #475569;
                font-weight: 600;
                font-family: 'Inter', sans-serif;
            }
            #receipt-print-box {
                padding: 10px !important;
                break-inside: avoid !important;
                page-break-inside: avoid !important;
            }
            #receipt-print-box .my-4 {
                margin-top: 0.5rem !important;
                margin-bottom: 0.5rem !important;
            }
            #receipt-print-box .my-2 {
                margin-top: 0.35rem !important;
                margin-bottom: 0.35rem !important;
            }
            #receipt-print-box .space-y-4 > * + * {
                margin-top: 0.7rem !important;
            }
            #receipt-print-box .space-y-2 > * + * {
                margin-top: 0.35rem !important;
            }
        }
    </style>
</head>
<body class="bg-slate-900/40 backdrop-blur-[2px] min-h-screen flex items-center justify-center p-4">
    <!-- Custom Print Header (Hanya muncul saat dicetak di pojok kanan atas kertas) -->
    <div class="hidden print:block print-header-top-right">
        Struk Pembayaran | InvenTako
    </div>
    <div class="w-full max-w-lg bg-white rounded-3xl border border-slate-200 shadow-2xl p-6 print-container">
        <div class="mb-5 flex items-center justify-between no-print">
            <h2 class="text-xl font-bold text-slate-900">Struk Pembayaran</h2>
        </div>

        <!-- Receipt Box to Print -->
        <div id="receipt-print-box" class="border border-slate-200 bg-white rounded-2xl p-6 shadow-sm">
            <!-- Store Header -->
            <div class="text-center">
                <h3 class="text-xl font-extrabold text-slate-900 tracking-wide uppercase">InvenTako</h3>
            </div>

            <!-- Separator -->
            <div class="border-t border-dashed border-slate-300 my-4"></div>

            <!-- Transaction Info -->
            <div class="space-y-2 text-sm text-slate-700">
                <div class="flex justify-between items-center">
                    <span>No Transaksi</span>
                    <span class="font-bold text-slate-900"><%= transaction.getNoNota() %></span>
                </div>
                <div class="flex justify-between items-center">
                    <span>Tanggal</span>
                    <span class="font-bold text-slate-900"><%= transaction.getTanggal() %></span>
                </div>
            </div>

            <!-- Separator -->
            <div class="border-t border-dashed border-slate-300 my-4"></div>

            <!-- Item List -->
            <div class="space-y-4">
                <% for (TransactionDetail detail : details) { %>
                <div class="text-sm">
                    <div class="flex justify-between items-start gap-4">
                        <span class="font-medium text-slate-800"><%= detail.getNamaBarang() %></span>
                        <span class="font-semibold text-slate-900">Rp <%= formatter.format(detail.getSubtotal()) %></span>
                    </div>
                    <div class="text-xs text-slate-400 mt-0.5">
                        <%= detail.getQty() %> x Rp <%= formatter.format(detail.getHargaSatuan()) %>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Separator -->
            <div class="border-t border-dashed border-slate-300 my-4"></div>

            <!-- Totals / Payment info -->
            <div class="space-y-2 text-sm text-slate-700">
                <% 
                    long itemsSubtotal = 0;
                    for (TransactionDetail detail : details) {
                        itemsSubtotal += detail.getSubtotal();
                    }
                    long ppn = transaction.getTotalBelanja() - itemsSubtotal;
                %>
                <div class="flex justify-between items-center">
                    <span>Subtotal</span>
                    <span class="font-medium text-slate-900">Rp <%= formatter.format(itemsSubtotal) %></span>
                </div>
                <div class="flex justify-between items-center">
                    <span>PPN (11%)</span>
                    <span class="font-medium text-slate-900">Rp <%= formatter.format(ppn) %></span>
                </div>
                <div class="border-t border-dashed border-slate-300 my-2"></div>
                <div class="flex justify-between items-center text-base font-extrabold text-[#0044ff]">
                    <span>TOTAL</span>
                    <span>Rp <%= formatter.format(transaction.getTotalBelanja()) %></span>
                </div>
                <div class="flex justify-between items-center">
                    <span>Bayar</span>
                    <span class="font-semibold text-slate-900">Rp <%= formatter.format(transaction.getUangTunai()) %></span>
                </div>
                <% if (transaction.getKembalian() > 0) { %>
                <div class="flex justify-between items-center">
                    <span>Kembalian</span>
                    <span class="font-semibold text-slate-900">Rp <%= formatter.format(transaction.getKembalian()) %></span>
                </div>
                <% } %>
            </div>

            <!-- Separator -->
            <div class="border-t border-dashed border-slate-300 my-4"></div>

            <!-- Footer Message -->
        </div>

        <!-- Action Buttons -->
        <div class="flex gap-4 mt-6 no-print">
            <button type="button" onclick="window.print()" class="flex-1 rounded-xl bg-[#0044ff] px-4 py-3 font-semibold text-white hover:bg-blue-700 shadow-md transition-all text-center">Cetak Struk</button>
            <a href="${pageContext.request.contextPath}/kasir/transaksi.jsp" class="flex-1 rounded-xl bg-slate-200 px-4 py-3 font-semibold text-slate-700 hover:bg-slate-300 transition-all text-center">Tutup</a>
        </div>
    </div>
    <script>
        window.addEventListener('DOMContentLoaded', () => {
            window.print();
        });

        // Kosongkan judul saat cetak agar default header Chrome (tengah atas) hilang, 
        // lalu kembalikan setelah dialog cetak ditutup.
        window.onbeforeprint = () => {
            document.title = "";
        };
        window.onafterprint = () => {
            document.title = "Struk Pembayaran | InvenTako";
        };
    </script>
</body>
</html>
