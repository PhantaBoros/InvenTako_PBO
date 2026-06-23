-- ============================================================
-- DATABASE: inventakoo
-- Export untuk Tubes PBO - InvenTako
-- ============================================================

CREATE DATABASE IF NOT EXISTS inventakoo;
USE inventakoo;

-- ============================================================
-- TABEL: users
-- Menyimpan semua user (admin, manager, kasir)
-- Kolom 'status': 'pending' (belum di-approve) / 'approved' (sudah aktif)
-- Kolom 'manager_id': untuk kasir → menunjuk ID manager pemilik toko
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    role        VARCHAR(20)  NOT NULL,       -- 'admin', 'manager', 'kasir'
    shift       VARCHAR(20)  DEFAULT NULL,   -- hanya untuk kasir: 'pagi', 'siang', 'sore', 'malem'
    manager_id  INT          DEFAULT NULL,   -- hanya untuk kasir: ID manager pemilik toko
    status      VARCHAR(20)  DEFAULT 'approved', -- 'pending' untuk manager baru, 'approved' untuk aktif
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================
-- TABEL: products
-- Menyimpan data barang per toko (per manager)
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    kode        VARCHAR(50)  NOT NULL,
    nama        VARCHAR(100) NOT NULL,
    kategori    VARCHAR(50)  NOT NULL,
    harga       BIGINT       NOT NULL,
    stok        INT          NOT NULL DEFAULT 0,
    manager_id  INT          NOT NULL,       -- barang milik toko manager mana
    FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- TABEL: transactions
-- Menyimpan data transaksi yang dilakukan kasir
-- ============================================================
CREATE TABLE IF NOT EXISTS transactions (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    no_nota        VARCHAR(50)  NOT NULL,
    tanggal        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    total_belanja  BIGINT       NOT NULL,
    uang_tunai     BIGINT       NOT NULL,
    kembalian      BIGINT       NOT NULL,
    status         VARCHAR(20)  DEFAULT 'selesai',
    kasir_id       INT          NOT NULL,    -- kasir yang melakukan transaksi
    FOREIGN KEY (kasir_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- TABEL: transaction_details
-- Menyimpan detail item per transaksi
-- ============================================================
CREATE TABLE IF NOT EXISTS transaction_details (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id  INT          NOT NULL,
    nama_barang     VARCHAR(100) NOT NULL,
    qty             INT          NOT NULL,
    harga_satuan    BIGINT       NOT NULL,
    subtotal        BIGINT       NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
);

-- ============================================================
-- DATA AWAL: Akun admin (langsung approved, bisa login)
-- Email: admin@gmail.com | Password: admin123
-- ============================================================
INSERT INTO users (username, email, password, role, status)
VALUES ('Admin', 'admin@gmail.com', 'admin123', 'admin', 'approved');
