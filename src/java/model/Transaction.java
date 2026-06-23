/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class Transaction {
    private int    id;
    private String noNota;
    private String tanggal;
    private long   totalBelanja;
    private long   uangTunai;
    private long   kembalian;
    private String status;
    private String kasirName;

    // Constructor kosong
    public Transaction() {}

    // Constructor penuh
    public Transaction(int id, String noNota, String tanggal, long totalBelanja, long uangTunai, long kembalian, String status, String kasirName) {
        this.id           = id;
        this.noNota       = noNota;
        this.tanggal      = tanggal;
        this.totalBelanja = totalBelanja;
        this.uangTunai    = uangTunai;
        this.kembalian    = kembalian;
        this.status       = status;
        this.kasirName    = kasirName;
    }

    // Getter & Setter
    public int getId() { 
        return id; 
    }
    
    public void setId(int id) { 
        this.id = id; 
    }

    public String getNoNota() { 
        return noNota; 
    }
    
    public void setNoNota(String noNota) { 
        this.noNota = noNota; 
    }

    public String getTanggal() { 
        return tanggal; 
    }

    public void setTanggal(String tanggal) { 
        this.tanggal = tanggal; 
    }

    public long getTotalBelanja() { 
        return totalBelanja; 
    }
    
    public void setTotalBelanja(long totalBelanja) { 
        this.totalBelanja = totalBelanja; 
    }

    public long getUangTunai() { 
        return uangTunai; 
    }
    
    public void setUangTunai(long uangTunai) { 
        this.uangTunai = uangTunai; 
    }

    public long getKembalian() { 
        return kembalian; 
    }
    
    public void setKembalian(long kembalian) { 
        this.kembalian = kembalian; 
    }

    public String getStatus() { 
        return status; 
    }
    
    public void setStatus(String status) { 
        this.status = status; 
    }

    public String getKasirName() { 
        return kasirName; 
    }
    
    public void setKasirName(String kasirName) { 
        this.kasirName = kasirName; 
    }
}
