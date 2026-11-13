package model;

import java.sql.Timestamp;

/**
 * Model representing a hotel guest/customer.
 */
public class Customer {
    private int customerId;
    private String fullName;
    private String email;
    private String phone;
    private String address;
    private String idProofType; // 'Passport', 'Aadhaar', 'Driving License', 'National ID'
    private String idProofNumber;
    private Timestamp createdAt;

    public Customer() {
    }

    public Customer(int customerId, String fullName, String email, String phone, String address, String idProofType, String idProofNumber, Timestamp createdAt) {
        this.customerId = customerId;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.idProofType = idProofType;
        this.idProofNumber = idProofNumber;
        this.createdAt = createdAt;
    }

    public Customer(String fullName, String email, String phone, String address, String idProofType, String idProofNumber) {
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.idProofType = idProofType;
        this.idProofNumber = idProofNumber;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getIdProofType() {
        return idProofType;
    }

    public void setIdProofType(String idProofType) {
        this.idProofType = idProofType;
    }

    public String getIdProofNumber() {
        return idProofNumber;
    }

    public void setIdProofNumber(String idProofNumber) {
        this.idProofNumber = idProofNumber;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
