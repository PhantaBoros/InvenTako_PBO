/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

public class Kasir extends User{
    private Timestamp createdAt;

    // Constructor kosong
    public Kasir() {
        this.setRole("kasir");
    }

    // Constructor dengan data lengkap
    public Kasir(int id, String username, String email, String password) {
        this.setId(id);
        this.setUsername(username);
        this.setEmail(email);
        this.setPassword(password);
        this.setRole("kasir");
    }

    // Getter & Setter createdAt
    public Timestamp getCreatedAt() { 
        return createdAt; 
    }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = createdAt; 
    }
}
