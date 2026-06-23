<%-- 
    Document   : register
    Created on : 12 Jun 2026, 14.26.42
    Author     : Muhammad Sabiq AZ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html class="light" lang="en">
<head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Register Account | InvenTako</title>
<!-- Fonts: Manrope & Inter -->
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>
<!-- Material Symbols -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
    tailwind.config = {
        darkMode: "class",
        theme: {
            extend: {
                "colors": {
                    "primary-container": "#2e5bff",
                    "secondary-fixed-dim": "#b9c7df",
                    "on-secondary-fixed-variant": "#3a485b",
                    "on-primary": "#ffffff",
                    "on-secondary-container": "#57657a",
                    "on-background": "#191c1e",
                    "on-surface": "#191c1e",
                    "on-secondary-fixed": "#0d1c2e",
                    "on-primary-container": "#efefff",
                    "inverse-primary": "#b8c3ff",
                    "outline-variant": "#c4c5d9",
                    "tertiary-fixed": "#ffdbcf",
                    "on-surface-variant": "#434656",
                    "primary-fixed-dim": "#b8c3ff",
                    "on-error": "#ffffff",
                    "background": "#f7f9fb",
                    "secondary-fixed": "#d5e3fc",
                    "on-tertiary-container": "#ffece6",
                    "tertiary-fixed-dim": "#ffb59b",
                    "on-error-container": "#93000a",
                    "on-tertiary": "#ffffff",
                    "surface-variant": "#e0e3e5",
                    "secondary": "#515f74",
                    "inverse-surface": "#2d3133",
                    "surface": "#f7f9fb",
                    "surface-container-lowest": "#ffffff",
                    "tertiary": "#993100",
                    "surface-container-highest": "#e0e3e5",
                    "primary-fixed": "#dde1ff",
                    "error": "#ba1a1a",
                    "error-container": "#ffdad6",
                    "outline": "#747688",
                    "surface-tint": "#124af0",
                    "surface-bright": "#f7f9fb",
                    "on-primary-fixed-variant": "#0035be",
                    "inverse-on-surface": "#eff1f3",
                    "on-tertiary-fixed": "#380d00",
                    "surface-container": "#eceef0",
                    "on-tertiary-fixed-variant": "#812800",
                    "surface-container-high": "#e6e8ea",
                    "primary": "#0040e0",
                    "on-primary-fixed": "#001356",
                    "surface-dim": "#d8dadc",
                    "surface-container-low": "#f2f4f6",
                    "tertiary-container": "#c24100",
                    "secondary-container": "#d5e3fc",
                    "on-secondary": "#ffffff"
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
    body { font-family: 'Inter', sans-serif; }
    .font-headline { font-family: 'Manrope', sans-serif; }
    .material-symbols-outlined {
        font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        vertical-align: middle;
    }
    .btn-gradient {
        background: linear-gradient(135deg, #0040e0 0%, #2e5bff 100%);
    }
    .glass-panel {
        background: rgba(255, 255, 255, 0.8);
        backdrop-filter: blur(12px);
    }
</style>
</head>
<body class="bg-surface text-on-surface min-h-screen flex flex-col">

<%-- ============================================================
     JSP SCRIPTLET: Ambil pesan error/sukses dari Servlet
     Servlet wajib set: request.setAttribute("errorMessage", "...")
                        request.setAttribute("successMessage", "...")
     ============================================================ --%>
<%
    String errorMessage   = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    // Pertahankan nilai input bila ada error agar tidak harus isi ulang
    String paramEmail    = request.getParameter("email")    != null ? request.getParameter("email")    : "";
    String paramUsername = request.getParameter("username") != null ? request.getParameter("username") : "";
%>

<!-- Top Navigation Suppression: Per instructions, suppress nav for Transactional screens -->
<main class="flex-grow flex items-center justify-center p-6 sm:p-12">
    <!-- Auth Container -->
    <div class="w-full max-w-[440px] flex flex-col gap-8">

        <!-- Branding Anchor -->
        <div class="text-center">
            <h1 class="font-headline font-extrabold text-3xl tracking-tighter mb-2" style="color: #2E5BFF;">InvenTako</h1>
        </div>

        <!-- Main Register Card -->
        <div class="bg-surface-container-lowest rounded-xl p-8 sm:p-10 transition-all duration-300">
            <header class="mb-8">
                <h2 class="font-headline font-bold text-2xl text-on-surface tracking-tight">Create Account</h2>
                <p class="text-on-surface-variant text-sm mt-1">Enter your details to initialize your account.</p>
            </header>

            <%-- ============================================================
                 JSP: Tampilkan pesan error dari Servlet (jika ada)
                 ============================================================ --%>
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div id="alertError" class="flex items-center gap-3 bg-error-container text-on-error-container rounded-lg px-4 py-3 mb-6 text-sm font-medium">
                <span class="material-symbols-outlined text-base" style="font-size:18px;">error</span>
                <span><%= errorMessage %></span>
            </div>
            <% } %>

            <%-- ============================================================
                 JSP: Tampilkan pesan sukses dari Servlet (jika ada)
                 ============================================================ --%>
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div id="alertSuccess" class="flex items-center gap-3 bg-secondary-container text-on-secondary-container rounded-lg px-4 py-3 mb-6 text-sm font-medium">
                <span class="material-symbols-outlined text-base" style="font-size:18px;">check_circle</span>
                <span><%= successMessage %></span>
            </div>
            <% } %>

            <%-- ============================================================
                 FORM: action mengarah ke AuthServlet?action=register, method POST
                 ============================================================ --%>
            <form class="flex flex-col gap-6" action="AuthServlet?action=register" method="POST" id="formRegister">

                <!-- Username Field -->
                <div class="space-y-1.5">
                    <label class="block text-xs font-bold uppercase tracking-widest text-on-surface-variant ml-1" for="username">
                        Username
                    </label>
                    <input
                        id="username"
                        name="username"
                        required
                        class="w-full bg-surface-container-low border-none focus:ring-2 focus:ring-primary/20 rounded-lg p-4 text-sm font-medium transition-all outline-none text-on-surface"
                        placeholder="johndoe"
                        type="text"
                        value="<%= paramUsername %>"
                    />
                </div>

                <!-- Email Field -->
                <div class="space-y-1.5">
                    <label class="block text-xs font-bold uppercase tracking-widest text-on-surface-variant ml-1" for="email">
                        Email
                    </label>
                    <input
                        id="email"
                        name="email"
                        required
                        class="w-full bg-surface-container-low border-none focus:ring-2 focus:ring-primary/20 rounded-lg p-4 text-sm font-medium transition-all outline-none text-on-surface"
                        placeholder="name@gmail.com"
                        type="email"
                        value="<%= paramEmail %>"
                    />
                </div>

                <!-- Password Field -->
                <div class="space-y-1.5">
                    <label class="block text-xs font-bold uppercase tracking-widest text-on-surface-variant ml-1" for="password">
                        Password
                    </label>
                    <div class="relative">
                        <input
                            id="password"
                            name="password"
                            required
                            class="w-full bg-surface-container-low border-none focus:ring-2 focus:ring-primary/20 rounded-lg p-4 text-sm font-medium transition-all outline-none text-on-surface"
                            placeholder="••••••••"
                            type="password"
                        />
                    </div>
                </div>

                <!-- Confirm Password Field -->
                <div class="space-y-1.5">
                    <label class="block text-xs font-bold uppercase tracking-widest text-on-surface-variant ml-1" for="confirmPassword">
                        Confirm Password
                    </label>
                    <div class="relative">
                        <input
                            id="confirmPassword"
                            name="confirmPassword"
                            required
                            class="w-full bg-surface-container-low border-none focus:ring-2 focus:ring-primary/20 rounded-lg p-4 text-sm font-medium transition-all outline-none text-on-surface"
                            placeholder="••••••••"
                            type="password"
                        />
                    </div>
                </div>

                <!-- Action Button -->
                <div class="pt-2">
                    <button
                        id="btnRegister"
                        type="submit"
                        class="w-full py-4 rounded-xl font-headline font-bold text-sm tracking-wide transition-transform active:scale-95 shadow-lg shadow-primary/10 text-surface-container-lowest"
                        style="background-color: #2E5BFF;"
                    >
                        Register Account
                    </button>
                </div>

            </form>

            <!-- Footer Links -->
            <div class="mt-10 text-center">
                <p class="text-on-surface-variant text-sm font-medium">
                    Already have an account?
                    <a class="text-primary font-bold ml-1 hover:underline underline-offset-4 decoration-2" href="login.jsp">Sign In</a>
                </p>
            </div>
        </div>

    </div>
</main>

<!-- Decoration Element: Precision Line -->
<div class="fixed top-0 left-0 w-1 h-full bg-primary opacity-20"></div>
<div class="fixed top-0 right-0 w-1 h-full bg-primary opacity-20"></div>

<%-- ============================================================
     MODAL (dipertahankan untuk validasi client-side)
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
    // FUNGSI KONTROL MODAL
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
    document.getElementById('formRegister').addEventListener('submit', function(event) {
        const email           = document.getElementById('email').value.trim();
        const password        = document.getElementById('password').value.trim();
        const confirmPassword = document.getElementById('confirmPassword').value.trim();
        const username        = document.getElementById('username').value.trim();

        // Cek kekosongan
        if (!username || !email || !password || !confirmPassword) {
            event.preventDefault();
            showModal('Data Belum Lengkap', 'Semua field wajib diisi!', 'Mengerti');
            return;
        }

        // Cek format email (opsional, sesuai aturan bisnis asli)
        if (!email.endsWith('@gmail.com')) {
            event.preventDefault();
            showModal('Format Tidak Sesuai', 'Harus menggunakan email @gmail.com!', 'Mengerti');
            return;
        }

        // Cek kesesuaian password
        if (password !== confirmPassword) {
            event.preventDefault();
            showModal('Password Tidak Cocok', 'Password dan konfirmasi password harus sama!', 'Mengerti');
            return;
        }

        // Jika semua valid, form akan di-submit ke AuthServlet?action=register (POST)
    });
</script>

</body>
</html>
