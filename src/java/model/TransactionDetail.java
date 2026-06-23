/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class TransactionDetail {
    private int    id;
    private int    transactionId;
    private String namaBarang;
    private int    qty;
    private long   hargaSatuan;
    private long   subtotal;

    // Constructor kosong
    public TransactionDetail() {}

    // Constructor penuh
    public TransactionDetail(int id, int transactionId, String namaBarang, int qty, long hargaSatuan, long subtotal) {
        this.id            = id;
        this.transactionId = transactionId;
        this.namaBarang    = namaBarang;
        this.qty           = qty;
        this.hargaSatuan   = hargaSatuan;
        this.subtotal      = subtotal;
    }

    // Getter & Setter
    public int getId() { 
        return id; 
    }

    public void setId(int id) { 
        this.id = id; 
    }

    public int getTransactionId() { 
        return transactionId; 
    }
    
    public void setTransactionId(int transactionId) { 
        this.transactionId = transactionId; 
    }

    public String getNamaBarang() { 
        return namaBarang; 
    }
    
    public void setNamaBarang(String namaBarang) { 
        this.namaBarang = namaBarang; 
    }

    public int getQty() { 
        return qty; 
    }
    
    public void setQty(int qty) { 
        this.qty = qty; 
    }

    public long getHargaSatuan() { 
        return hargaSatuan; 
    }
    public void setHargaSatuan(long hargaSatuan) { 
        this.hargaSatuan = hargaSatuan; 
    }

    public long getSubtotal() { 
        return subtotal; 
    }
    
    public void setSubtotal(long subtotal) { 
        this.subtotal = subtotal; 
    }
}
