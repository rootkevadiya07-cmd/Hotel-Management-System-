package model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model representing a hotel staff member.
 */
public class Staff {
    private int staffId;
    private String fullName;
    private String role;
    private String shift; // 'Morning', 'Evening', 'Night'
    private String phone;
    private String email;
    private double salary;
    private String status; // 'Active', 'On Leave', 'Terminated'
    private Date hireDate;
    private Timestamp createdAt;

    public Staff() {
    }

    public Staff(int staffId, String fullName, String role, String shift, String phone, String email, double salary, String status, Date hireDate, Timestamp createdAt) {
        this.staffId = staffId;
        this.fullName = fullName;
        this.role = role;
        this.shift = shift;
        this.phone = phone;
        this.email = email;
        this.salary = salary;
        this.status = status;
        this.hireDate = hireDate;
        this.createdAt = createdAt;
    }

    public Staff(String fullName, String role, String shift, String phone, String email, double salary, String status, Date hireDate) {
        this.fullName = fullName;
        this.role = role;
        this.shift = shift;
        this.phone = phone;
        this.email = email;
        this.salary = salary;
        this.status = status;
        this.hireDate = hireDate;
    }

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
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

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public double getSalary() {
        return salary;
    }

    public void setSalary(double salary) {
        this.salary = salary;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getHireDate() {
        return hireDate;
    }

    public void setHireDate(Date hireDate) {
        this.hireDate = hireDate;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
