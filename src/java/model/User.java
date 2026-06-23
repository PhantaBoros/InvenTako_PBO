/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Muhammad Sabiq AZ
 */
public class User {
    private int    id;
    private String username;
    private String email;
    private String password;
    private String role;
    private String shift;
    private int    managerId;  // untuk kasir: ID manager pemilik toko
    private String status;     // status akun: 'pending' atau 'approved'

    // Constructor kosong
    public User() {}

    // Constructor penuh
    public User(int id, String username, String email, String password, String role) {
        this.id       = id;
        this.username = username;
        this.email    = email;
        this.password = password;
        this.role     = role;
    }

    // Getter & Setter
    public int getId() { 
        return id; 
    }
    public void setId(int id) { 
        this.id = id; 
    }

    public String getUsername() { 
        return username; 
    }
    public void setUsername(String username) { 
        this.username = username; 
    }

    public String getEmail() { 
        return email; 
    }
    public void setEmail(String email) { 
        this.email = email; 
    }

    public String getPassword() { 
        return password; 
    }
    public void setPassword(String password) { 
        this.password = password; 
    }

    public String getRole() { 
        return role; 
    }
    public void setRole(String role) { 
        this.role = role; 
    }

    public String getShift() { 
        return shift; 
    }
    public void setShift(String shift) { 
        this.shift = shift; 
    }

    public int getManagerId() { 
        return managerId; 
    }
    public void setManagerId(int managerId) { 
        this.managerId = managerId; 
    }

    public String getStatus() { 
        return status; 
    }
    public void setStatus(String status) { 
        this.status = status; 
    }
}
