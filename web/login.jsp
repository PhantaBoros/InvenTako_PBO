<%-- 
    Document   : login.jsp
    Created on : 12 Jun 2026, 14.26.06
    Author     : Muhammad Sabiq AZ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html class="light" lang="en">
<head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>InvenTako | Sign In</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
<script id="tailwind-config">
    tailwind.config = {
        darkMode: "class",
        theme: {
            extend: {
                "colors": {
                    "primary": "#0040e0",
                    "surface-tint": "#124af0",
                    "on-error": "#ffffff",
                    "error": "#ba1a1a",
                    "on-surface-variant": "#434656",
                    "surface-container": "#eceef0",
                    "error-container": "#ffdad6",
                    "on-tertiary": "#ffffff",
                    "tertiary-fixed": "#ffdbcf",
                    "background": "#f7f9fb",
                    "on-error-container": "#93000a",
                    "secondary-fixed": "#d5e3fc",
                    "on-surface": "#191c1e",
                    "on-tertiary-fixed-variant": "#812800",
                    "surface-container-high": "#e6e8ea",
                    "primary-fixed-dim": "#b8c3ff",
                    "primary-container": "#2e5bff",
                    "secondary": "#515f74",
                    "on-secondary-container": "#57657a",
                    "on-secondary-fixed": "#0d1c2e",
                    "inverse-surface": "#2d3133",
                    "surface-dim": "#d8dadc",
                    "on-background": "#191c1e",
                    "inverse-on-surface": "#eff1f3",
                    "on-secondary-fixed-variant": "#3a485b",
                    "on-primary": "#ffffff",
                    "surface": "#f7f9fb",
                    "tertiary-fixed-dim": "#ffb59b",
                    "inverse-primary": "#b8c3ff",
                    "outline": "#747688",
                    "surface-bright": "#f7f9fb",
                    "outline-variant": "#c4c5d9",
                    "surface-container-highest": "#e0e3e5",
                    "on-primary-container": "#efefff",
                    "primary-fixed": "#dde1ff",
                    "secondary-fixed-dim": "#b9c7df",
                    "on-primary-fixed-variant": "#0035be",
                    "on-secondary": "#ffffff",
                    "surface-container-low": "#f2f4f6",
                    "surface-variant": "#e0e3e5",
                    "tertiary-container": "#c24100",
                    "surface-container-lowest": "#ffffff",
                    "tertiary": "#993100",
                    "on-tertiary-container": "#ffece6",
                    "secondary-container": "#d5e3fc",
                    "on-tertiary-fixed": "#380d00",
                    "on-primary-fixed": "#001356"
                },
                "borderRadius": {
                    "DEFAULT": "0.125rem",
                    "lg": "0.25rem",
                    "xl": "0.5rem",
                    "full": "0.75rem"
                },
                "fontFamily": {
                    "headline": ["Manrope"],
                    "body": ["Inter"],
                    "label": ["Inter"]
                }
            },
        },
    }
</script>
<style>
    .material-symbols-outlined {
        font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
    }
    body { font-family: 'Inter', sans-serif; }
    h1, h2, h3 { font-family: 'Manrope', sans-serif; }
    .glass-panel {
        background: rgba(255, 255, 255, 0.7);
        backdrop-filter: blur(12px);
    }
</style>
</head>
<body class="bg-surface text-on-surface min-h-screen flex flex-col items-center justify-center p-6 relative overflow-y-auto">

<%-- ============================================================
     JSP SCRIPTLET: Ambil pesan error/sukses dari Servlet
     Servlet wajib set: request.setAttribute("errorMessage", "...")
                        request.setAttribute("successMessage", "...")
     ============================================================ --%>
<%
    String errorMessage   = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>

<!-- Abstract Background Elements -->
<div class="absolute top-[-10%] left-[-5%] w-[40%] h-[60%] bg-primary/5 rounded-full blur-[120px]"></div>
<div class="absolute bottom-[-10%] right-[-5%] w-[40%] h-[60%] bg-primary-container/5 rounded-full blur-[120px]"></div>

<!-- Main Branding -->
<div class="mb-12 text-center relative z-10">
    <div class="flex items-center justify-center gap-3">
        <span class="text-2xl font-extrabold tracking-tight text-primary font-headline">InvenTako</span>
    </div>
</div>

<!-- Login Container -->
<main class="w-full max-w-md relative z-10">
    <div class="surface-container-lowest rounded-xl p-8 shadow-[0_32px_64px_-12px_rgba(25,28,30,0.04)] border border-outline-variant/10">
        <header class="mb-8">
            <h1 class="text-3xl font-extrabold text-on-surface mb-2 font-headline">Sign In</h1>
            <p class="text-on-surface-variant text-sm">Welcome back to your Inventory Management.</p>
        </header>

        <%-- ============================================================
             JSP: Tampilkan pesan error dari Servlet (jika ada)
             ============================================================ --%>
        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
        <div id="alertError" class="flex items-center gap-3 bg-error-container text-on-error-container rounded-lg px-4 py-3 mb-6 text-sm font-medium">
            <span class="material-symbols-outlined text-base">error</span>
            <span><%= errorMessage %></span>
        </div>
        <% } %>

        <%-- ============================================================
             JSP: Tampilkan pesan sukses dari Servlet (jika ada)
             ============================================================ --%>
        <% if (successMessage != null && !successMessage.isEmpty()) { %>
        <div id="alertSuccess" class="flex items-center gap-3 bg-secondary-container text-on-secondary-container rounded-lg px-4 py-3 mb-6 text-sm font-medium">
            <span class="material-symbols-outlined text-base">check_circle</span>
            <span><%= successMessage %></span>
        </div>
        <% } %>

        <%-- ============================================================
             FORM: action mengarah ke AuthServlet, method POST
             ============================================================ --%>
        <form action="AuthServlet" method="POST" class="space-y-6">
            <%-- Hidden field untuk membedakan aksi di Servlet --%>
            <input type="hidden" name="action" value="login"/>

            <!-- Email Field -->
            <div class="space-y-2">
                <label class="block text-xs font-bold text-on-surface-variant tracking-wider uppercase ml-1" for="email">
                    Email Address
                </label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <span class="material-symbols-outlined text-outline text-lg">mail</span>
                    </div>
                    <input
                        class="block w-full pl-12 pr-4 py-3.5 bg-surface-container-low border-none rounded-lg focus:ring-2 focus:ring-primary/20 focus:bg-surface-container-lowest transition-all text-on-surface placeholder:text-outline"
                        id="email"
                        name="email"
                        placeholder="name@gmail.com"
                        required
                        type="email"
                        <%-- Pertahankan nilai input bila ada error agar tidak harus isi ulang --%>
                        value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
                    />
                </div>
            </div>

            <!-- Password Field -->
            <div class="space-y-2">
                <div class="flex justify-between items-center px-1">
                    <label class="block text-xs font-bold text-on-surface-variant tracking-wider uppercase" for="password">
                        Password
                    </label>
                </div>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <span class="material-symbols-outlined text-outline text-lg">lock</span>
                    </div>
                    <input
                        class="block w-full pl-12 pr-12 py-3.5 bg-surface-container-low border-none rounded-lg focus:ring-2 focus:ring-primary/20 focus:bg-surface-container-lowest transition-all text-on-surface placeholder:text-outline"
                        id="password"
                        name="password"
                        placeholder="••••••••"
                        required
                        type="password"
                    />
                </div>
            </div>

            <!-- Action Button -->
            <div class="pt-4">
                <button
                    class="w-full bg-gradient-to-br from-primary to-primary-container text-on-primary font-bold py-4 px-6 rounded-lg shadow-lg shadow-primary/10 hover:shadow-primary/20 hover:scale-[1.01] active:scale-[0.98] transition-all flex items-center justify-center gap-2"
                    type="submit"
                    id="btnLogin"
                >
                    <span>Access InvenTako</span>
                    <span class="material-symbols-outlined text-xl">arrow_forward</span>
                </button>
            </div>
        </form>

        <footer class="mt-8 pt-8 border-t border-outline-variant/10 text-center">
            <p class="text-on-surface-variant text-sm font-medium">
                New to the InvenTako?
                <a class="text-primary font-bold hover:underline underline-offset-4 ml-1" href="register.jsp">Register for an account</a>
            </p>
        </footer>
    </div>
</main>

<!-- Contextual Aesthetic Feature -->
<div class="hidden lg:block fixed bottom-12 right-12 w-64 h-64 opacity-20 pointer-events-none">
    <div class="w-full h-full border border-primary/40 rounded-full flex items-center justify-center animate-pulse">
        <div class="w-48 h-48 border border-primary/30 rounded-full flex items-center justify-center">
            <div class="w-32 h-32 border border-primary/20 rounded-full"></div>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: Digunakan untuk menampilkan pesan dari Servlet
     via JavaScript jika diperlukan untuk validasi client-side
     ============================================================ --%>
<div id="customModal" class="hidden fixed inset-0 z-50 items-center justify-center p-4 sm:p-6 bg-on-background/20 backdrop-blur-sm transition-opacity duration-300">
    <div class="bg-surface-container-lowest w-full max-w-sm rounded-xl p-8 shadow-[0_8px_32px_rgba(25,28,30,0.08)] border border-outline-variant/20 flex flex-col items-center text-center transform transition-all duration-300 scale-100 opacity-100">
        <h2 id="modalTitle" class="font-headline text-2xl font-bold text-on-surface mb-3 tracking-tight">Notifikasi</h2>
        <p id="modalMessage" class="font-body text-base text-on-surface-variant mb-8 leading-relaxed">
            Pesan akan muncul di sini.
        </p>
        <button id="modalButton" onclick="closeModal()" class="w-full bg-gradient-to-br from-primary to-primary-container text-on-primary font-bold py-3 px-6 rounded-lg shadow-sm hover:shadow-lg hover:scale-[1.02] transition-all focus:outline-none">
            Tutup
        </button>
    </div>
</div>

<script>
    // ============================================================
    // FUNGSI KONTROL MODAL (dipertahankan untuk validasi client-side)
    // ============================================================
    function showModal(title, message, buttonText = "Tutup", onClickFn = null) {
        document.getElementById('modalTitle').innerText = title;
        document.getElementById('modalMessage').innerText = message;
        document.getElementById('modalButton').innerText = buttonText;

        const modal = document.getElementById('customModal');
        modal.classList.remove('hidden');
        modal.classList.add('flex');

        if (onClickFn) {
            document.getElementById('modalButton').onclick = onClickFn;
        } else {
            document.getElementById('modalButton').onclick = closeModal;
        }
    }

    function closeModal() {
        const modal = document.getElementById('customModal');
        modal.classList.add('hidden');
        modal.classList.remove('flex');
    }

    // ============================================================
    // VALIDASI CLIENT-SIDE (opsional, sebelum POST ke Servlet)
    // ============================================================
    document.getElementById('btnLogin').closest('form').addEventListener('submit', function(event) {
        const email    = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value.trim();

        if (!email || !password) {
            event.preventDefault();
            showModal('Data Belum Lengkap', 'Email dan Password wajib diisi!', 'Mengerti');
        }
        // Jika valid, form akan di-submit secara normal ke AuthServlet (POST)
    });
</script>

</body>
</html>
