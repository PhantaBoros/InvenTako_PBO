<%@ page import="dao.UserDAO" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Cek apakah user adalah admin
    User loggedInUser = (User) session.getAttribute("user");
    if (loggedInUser == null || !"admin".equals(loggedInUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Ambil daftar user yang pending
    UserDAO dao = new UserDAO();
    List<User> pendingUsers = dao.getPendingUsers();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Manager - Admin Panel</title>
    <link rel="stylesheet" href="../assets/css/admin.css" />
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Panel Admin</h1>
            <p>Kelola Persetujuan Akun Manager Baru</p>
        </div>

        <div class="nav-bar">
            <a href="kelola_manager.jsp" class="active">Kelola Manager</a>
            <form action="../AuthServlet" method="POST" style="display: inline;">
                <input type="hidden" name="action" value="logout">
                <button type="submit" class="btn logout" style="border: none; padding: 8px 15px;">Logout</button>
            </form>
        </div>

        <div class="content">
            <%
                String successMsg = request.getParameter("success");
                String errorMsg = request.getParameter("error");
                
                if ("approve".equals(successMsg)) {
            %>
                <div class="message success">✓ Akun manager berhasil disetujui!</div>
            <%
                } else if ("decline".equals(successMsg)) {
            %>
                <div class="message success">✓ Akun manager berhasil ditolak!</div>
            <%
                } else if (errorMsg != null) {
            %>
                <div class="message error">✗ Terjadi kesalahan! Silakan coba lagi.</div>
            <%
                }
            %>

            <h2 class="section-title">Persetujuan Akun Manager Baru</h2>

            <div class="table-wrapper">
                <% if (pendingUsers.isEmpty()) { %>
                    <div class="empty-message">
                        <p>Tidak ada akun yang menunggu persetujuan 😊</p>
                        <p style="font-size: 12px; margin-top: 10px; color: #bbb;">Semua akun manager telah diproses</p>
                    </div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>No</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                int no = 1;
                                for (User user : pendingUsers) {
                            %>
                            <tr>
                                <td><%= no++ %></td>
                                <td><strong><%= user.getUsername() %></strong></td>
                                <td><%= user.getEmail() %></td>
                                <td><span class="badge badge-manager"><%= user.getRole() %></span></td>
                                <td><span class="badge badge-pending">PENDING</span></td>
                                <td>
                                    <div class="action-buttons">
                                        <form action="../AuthServlet" method="POST" style="display: inline;">
                                            <input type="hidden" name="action" value="approve">
                                            <input type="hidden" name="userId" value="<%= user.getId() %>">
                                            <button type="submit" class="btn btn-approve">✓ Setujui</button>
                                        </form>
                                        <form action="../AuthServlet" method="POST" style="display: inline;" onsubmit="return confirmDecline(this,event);">
                                            <input type="hidden" name="action" value="decline">
                                            <input type="hidden" name="userId" value="<%= user.getId() %>">
                                            <button type="submit" class="btn btn-decline">✗ Tolak</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>
    <!-- Custom modal -->
    <div id="customModalBackdrop" class="modal-backdrop" aria-hidden="true">
        <div class="modal" role="dialog" aria-modal="true">
            <h3 id="customModalTitle">Konfirmasi</h3>
            <p id="customModalMessage">Pesan</p>
            <div class="modal-actions">
                <button id="customModalCancel" class="btn cancel">Batal</button>
                <button id="customModalConfirm" class="btn confirm">Ya</button>
            </div>
        </div>
    </div>
    <script src="../assets/js/admin.js" defer></script>
</body>
</html>
