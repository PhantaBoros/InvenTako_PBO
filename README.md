# 📦 InvenTako - Aplikasi Manajemen Barang dan Transaksi Kasir

Aplikasi berbasis Web (Java EE / JSP) yang dikembangkan untuk memenuhi Tugas Besar mata kuliah Pemrograman Berorientasi Objek (PBO). Aplikasi ini dirancang untuk mendigitalisasi operasional ritel dengan fungsionalitas transaksi Kasir (Point of Sales) dan dashboard analitik Manager, menggunakan hak akses (role) yang tersegregasi secara ketat.

## 👥 Kelompok Pengembang
* **Muhammad Sabiq Al-Zabbar**
* **Putri Salwa Salsabila**
* **Salman Muhammad Zumhur**
* **Azmin Rafie**

## 🛠️ Arsitektur & Teknologi yang Digunakan
* **Bahasa Pemrograman**: Java (Servlet, JSP)
* **Arsitektur**: murni Model-View-Controller (MVC) menggunakan DAO Pattern
* **Web Server**: Apache Tomcat / GlassFish
* **Database**: MySQL (dilengkapi pencegahan SQL Injection via PreparedStatement)
* **IDE**: Apache NetBeans (Sistem build Ant)
* **Frontend**: HTML5, Tailwind CSS, JavaScript (termasuk visualisasi Chart.js)

## 🔑 Fitur & Hak Akses (Role-Based Access Control)
1. **Admin**: Memiliki kendali otorisasi terpusat untuk memproses persetujuan (Terima/Tolak) pendaftaran akun Manager baru.
2. **Manager**: Memiliki akses ke Dashboard visual interaktif, mengelola CRUD data inventaris barang, melihat laporan riwayat transaksi, dan mendaftarkan akun Kasir.
3. **Kasir**: Memiliki sistem validasi *shift* operasional, menginput transaksi *checkout* keranjang secara *real-time*, menghitung pajak otomatis, dan mencetak struk belanja berformat PDF instan.
4. **Keamanan**: Implementasi algoritma *password hashing* untuk mengamankan data seluruh level pengguna.

---

## 🚀 Cara Menjalankan Project (Local Development)

### Prasyarat (Prerequisites)
Pastikan kamu sudah menginstal beberapa software berikut:
- **Java Development Kit (JDK)** (Disarankan versi 8 atau yang lebih baru).
- **XAMPP** (Untuk menjalankan MySQL Server).
- **Apache NetBeans IDE** (Sangat direkomendasikan karena project ini menggunakan format struktur NetBeans).
- **Web Server** seperti Apache Tomcat atau GlassFish.

### Langkah-langkah Instalasi

**1. Clone Repository**
Buka Terminal atau Command Prompt, kemudian jalankan perintah berikut untuk mengunduh source code:
`git clone https://github.com/PhantaBoros/InvenTako_PBO.git`
`cd InvenTako_PBO`

**2. Setup Database (MySQL)**
- Buka aplikasi **XAMPP Control Panel** dan klik **Start** pada modul **MySQL** (dan Apache jika perlu).
- Buka browser dan masuk ke `http://localhost/phpmyadmin`.
- Buat database baru dengan nama `tubes_pbo` (atau sesuaikan dengan nama di kode).
- Import file konfigurasi database `.sql` yang telah disediakan di dalam folder project ini ke dalam database yang baru dibuat.

**3. Buka Project di NetBeans**
- Buka **Apache NetBeans IDE**.
- Pilih menu **File > Open Project...**
- Cari folder `InvenTako_PBO` hasil clone tadi, lalu klik **Open Project**.

**4. Konfigurasi Koneksi Database**
- Buka file konfigurasi koneksi database di package `src/java/...`.
- Pastikan *username*, *password*, dan *nama database* pada JDBC URL sudah sesuai dengan konfigurasi XAMPP lokalmu. 
- Contoh default bawaan XAMPP: Username: `root`, Password: `(kosong)`, DB URL: `jdbc:mysql://localhost:3306/tubes_pbo`.

**5. Build dan Jalankan Aplikasi**
- Di panel *Projects* (sebelah kiri NetBeans), klik kanan pada nama project.
- Pilih **Clean and Build** untuk mengompilasi ulang class dan memastikan tidak ada error.
- Klik kanan lagi pada project, lalu pilih **Run**.
- NetBeans akan secara otomatis menyalakan server Tomcat/GlassFish dan meluncurkan antarmuka InvenTako di browser default.

---
**Catatan Penting:** Pastikan library `MySQL JDBC Driver` sudah ditambahkan pada folder *Libraries* project ini di NetBeans agar *backend* dapat berkomunikasi dengan database secara lancar.