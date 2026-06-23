/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.security.Timestamp;

public class Manager extends User{
    private Timestamp createdAt;

    // Constructor kosong
    public Manager() {
        super();
        this.setRole("manager");
    }

    // Constructor dengan data lengkap
    public Manager(int id, String username, String email, String password) {
        super(id, username, email, password, "manager");
    }

    // Getter & Setter createdAt
    public Timestamp getCreatedAt() { 
        return createdAt; 
    }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = createdAt; 
    }
}
