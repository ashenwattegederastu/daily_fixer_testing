package com.dailyfixer.model;

public class Vehicle {
    private int id;
    private int driverId;
    private String vehicleType;
    private String brand;
    private String model;
    private String plateNumber;
    private byte[] picture;
    private double fareFirstKm;
    private double fareNextKm;

    // ✅ Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getDriverId() { return driverId; }
    public void setDriverId(int driverId) { this.driverId = driverId; }

    public String getVehicleType() { return vehicleType; }
    public void setVehicleType(String vehicleType) { this.vehicleType = vehicleType; }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getPlateNumber() { return plateNumber; }
    public void setPlateNumber(String plateNumber) { this.plateNumber = plateNumber; }

    public byte[] getPicture() { return picture; }
    public void setPicture(byte[] picture) { this.picture = picture; }

    public double getFareFirstKm() { return fareFirstKm; }
    public void setFareFirstKm(double fareFirstKm) { this.fareFirstKm = fareFirstKm; }

    public double getFareNextKm() { return fareNextKm; }
    public void setFareNextKm(double fareNextKm) { this.fareNextKm = fareNextKm; }
}
