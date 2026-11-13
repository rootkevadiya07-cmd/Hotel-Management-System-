package model;

/**
 * Encapsulates aggregated metrics and KPI statistics for the Admin Dashboard.
 */
public class DashboardStats {
    private int totalRooms;
    private int availableRooms;
    private int occupiedRooms;
    private int maintenanceRooms;
    private int totalCustomers;
    private int totalBookings;
    private double totalRevenue;
    private int todayCheckIns;
    private int todayCheckOuts;
    private int totalStaff;

    public DashboardStats() {
    }

    public int getTotalRooms() {
        return totalRooms;
    }

    public void setTotalRooms(int totalRooms) {
        this.totalRooms = totalRooms;
    }

    public int getAvailableRooms() {
        return availableRooms;
    }

    public void setAvailableRooms(int availableRooms) {
        this.availableRooms = availableRooms;
    }

    public int getOccupiedRooms() {
        return occupiedRooms;
    }

    public void setOccupiedRooms(int occupiedRooms) {
        this.occupiedRooms = occupiedRooms;
    }

    public int getMaintenanceRooms() {
        return maintenanceRooms;
    }

    public void setMaintenanceRooms(int maintenanceRooms) {
        this.maintenanceRooms = maintenanceRooms;
    }

    public int getTotalCustomers() {
        return totalCustomers;
    }

    public void setTotalCustomers(int totalCustomers) {
        this.totalCustomers = totalCustomers;
    }

    public int getTotalBookings() {
        return totalBookings;
    }

    public void setTotalBookings(int totalBookings) {
        this.totalBookings = totalBookings;
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public int getTodayCheckIns() {
        return todayCheckIns;
    }

    public void setTodayCheckIns(int todayCheckIns) {
        this.todayCheckIns = todayCheckIns;
    }

    public int getTodayCheckOuts() {
        return todayCheckOuts;
    }

    public void setTodayCheckOuts(int todayCheckOuts) {
        this.todayCheckOuts = todayCheckOuts;
    }

    public int getTotalStaff() {
        return totalStaff;
    }

    public void setTotalStaff(int totalStaff) {
        this.totalStaff = totalStaff;
    }

    public double getOccupancyRate() {
        if (totalRooms == 0) return 0.0;
        return ((double) occupiedRooms / totalRooms) * 100.0;
    }
}
