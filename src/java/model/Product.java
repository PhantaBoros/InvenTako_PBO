/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Muhammad Sabiq AZ
 */
public class Product {
    private int    id;
    private String kode;
    private String nama;
    private String kategori;
    private long   harga;
    private int    stok;
    private int    managerId;

    // Constructor kosong
    public Product() {}

    // Constructor penuh
    public Product(int id, String kode, String nama, String kategori, long harga, int stok) {
        this.id       = id;
        this.kode     = kode;
        this.nama     = nama;
        this.kategori = kategori;
        this.harga    = harga;
        this.stok     = stok;
    }

    // Constructor dengan managerId
    public Product(int id, String kode, String nama, String kategori, long harga, int stok, int managerId) {
        this(id, kode, nama, kategori, harga, stok);
        this.managerId = managerId;
    }

    // Getter & Setter
    public int getId() { 
        return id; 
    }
    public void setId(int id) { 
        this.id = id; 
    }

    public String getKode() { 
        return kode; 
    }
    public void setKode(String kode) { 
        this.kode = kode; 
    }

    public String getNama() { 
        return nama; 
    }
    public void setNama(String nama) { 
        this.nama = nama; 
    }

    public String getKategori() { 
        return kategori; 
    }
    public void setKategori(String kategori) { 
        this.kategori = kategori; 
    }

    public long getHarga() { 
        return harga; 
    }
    public void setHarga(long harga) { 
        this.harga = harga; 
    }

    public int getStok() { 
        return stok; 
    }
    public void setStok(int stok) { 
        this.stok = stok; 
    }

    public int getManagerId() { 
        return managerId; 
    }
    public void setManagerId(int managerId) { 
        this.managerId = managerId; 
    }
}
