package com.dailyfixer.dao;

import com.dailyfixer.model.Vehicle;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for VehicleDAO using H2 in-memory database.
 */
class VehicleDAOTest {

    private VehicleDAOTestHelper vehicleDAO;
    private static final int TEST_DRIVER_ID = 1;

    @BeforeEach
    void setUp() throws Exception {
        vehicleDAO = new VehicleDAOTestHelper();
        TestDBConnection.clearAllTables();
    }

    @Test
    @DisplayName("Should add vehicle and return generated ID")
    void testAddVehicle() {
        // Arrange
        Vehicle vehicle = new Vehicle();
        vehicle.setDriverId(TEST_DRIVER_ID);
        vehicle.setVehicleType("Car");
        vehicle.setBrand("Toyota");
        vehicle.setModel("Camry");
        vehicle.setPlateNumber("ABC-1234");
        vehicle.setFareFirstKm(150.00);
        vehicle.setFareNextKm(80.00);

        // Act
        boolean result = vehicleDAO.addVehicle(vehicle);

        // Assert
        assertTrue(result);
        assertTrue(vehicle.getId() > 0, "Vehicle ID should be generated");
    }

    @Test
    @DisplayName("Should retrieve vehicle by ID")
    void testGetVehicleById() {
        // Arrange
        Vehicle vehicle = new Vehicle();
        vehicle.setDriverId(TEST_DRIVER_ID);
        vehicle.setVehicleType("Van");
        vehicle.setBrand("Honda");
        vehicle.setModel("Odyssey");
        vehicle.setPlateNumber("XYZ-5678");
        vehicle.setFareFirstKm(200.00);
        vehicle.setFareNextKm(100.00);
        vehicleDAO.addVehicle(vehicle);
        int vehicleId = vehicle.getId();

        // Act
        Vehicle retrieved = vehicleDAO.getVehicleById(vehicleId);

        // Assert
        assertNotNull(retrieved);
        assertEquals(vehicleId, retrieved.getId());
        assertEquals("Van", retrieved.getVehicleType());
        assertEquals("Honda", retrieved.getBrand());
        assertEquals("Odyssey", retrieved.getModel());
        assertEquals("XYZ-5678", retrieved.getPlateNumber());
        assertEquals(200.00, retrieved.getFareFirstKm(), 0.01);
        assertEquals(100.00, retrieved.getFareNextKm(), 0.01);
    }

    @Test
    @DisplayName("Should return null for non-existent vehicle ID")
    void testGetVehicleById_NotFound() {
        // Act
        Vehicle vehicle = vehicleDAO.getVehicleById(9999);

        // Assert
        assertNull(vehicle);
    }

    @Test
    @DisplayName("Should retrieve all vehicles for a driver")
    void testGetVehiclesByDriver() {
        // Arrange
        Vehicle vehicle1 = new Vehicle();
        vehicle1.setDriverId(TEST_DRIVER_ID);
        vehicle1.setVehicleType("Car");
        vehicle1.setBrand("Nissan");
        vehicle1.setModel("Altima");
        vehicle1.setPlateNumber("ABC-1111");
        vehicle1.setFareFirstKm(140.00);
        vehicle1.setFareNextKm(75.00);
        vehicleDAO.addVehicle(vehicle1);

        Vehicle vehicle2 = new Vehicle();
        vehicle2.setDriverId(TEST_DRIVER_ID);
        vehicle2.setVehicleType("SUV");
        vehicle2.setBrand("Ford");
        vehicle2.setModel("Explorer");
        vehicle2.setPlateNumber("ABC-2222");
        vehicle2.setFareFirstKm(250.00);
        vehicle2.setFareNextKm(120.00);
        vehicleDAO.addVehicle(vehicle2);

        // Act
        List<Vehicle> vehicles = vehicleDAO.getVehiclesByDriver(TEST_DRIVER_ID);

        // Assert
        assertEquals(2, vehicles.size());
        assertTrue(vehicles.stream().anyMatch(v -> v.getBrand().equals("Nissan")));
        assertTrue(vehicles.stream().anyMatch(v -> v.getBrand().equals("Ford")));
    }

    @Test
    @DisplayName("Should return empty list for driver with no vehicles")
    void testGetVehiclesByDriver_NoVehicles() {
        // Act
        List<Vehicle> vehicles = vehicleDAO.getVehiclesByDriver(999);

        // Assert
        assertNotNull(vehicles);
        assertEquals(0, vehicles.size());
    }

    @Test
    @DisplayName("Should update vehicle successfully")
    void testUpdateVehicle() {
        // Arrange
        Vehicle vehicle = new Vehicle();
        vehicle.setDriverId(TEST_DRIVER_ID);
        vehicle.setVehicleType("Car");
        vehicle.setBrand("Mazda");
        vehicle.setModel("3");
        vehicle.setPlateNumber("DEF-3333");
        vehicle.setFareFirstKm(130.00);
        vehicle.setFareNextKm(70.00);
        vehicleDAO.addVehicle(vehicle);
        int vehicleId = vehicle.getId();

        // Act
        vehicle.setModel("6");
        vehicle.setPlateNumber("DEF-6666");
        vehicle.setFareFirstKm(160.00);
        vehicle.setFareNextKm(85.00);
        boolean updated = vehicleDAO.updateVehicle(vehicle);

        // Assert
        assertTrue(updated);
        Vehicle retrieved = vehicleDAO.getVehicleById(vehicleId);
        assertEquals("6", retrieved.getModel());
        assertEquals("DEF-6666", retrieved.getPlateNumber());
        assertEquals(160.00, retrieved.getFareFirstKm(), 0.01);
        assertEquals(85.00, retrieved.getFareNextKm(), 0.01);
    }

    @Test
    @DisplayName("Should delete vehicle successfully")
    void testDeleteVehicle() {
        // Arrange
        Vehicle vehicle = new Vehicle();
        vehicle.setDriverId(TEST_DRIVER_ID);
        vehicle.setVehicleType("Motorcycle");
        vehicle.setBrand("Yamaha");
        vehicle.setModel("R15");
        vehicle.setPlateNumber("GHI-4444");
        vehicle.setFareFirstKm(80.00);
        vehicle.setFareNextKm(40.00);
        vehicleDAO.addVehicle(vehicle);
        int vehicleId = vehicle.getId();

        // Act
        boolean deleted = vehicleDAO.deleteVehicle(vehicleId);

        // Assert
        assertTrue(deleted);
        Vehicle retrieved = vehicleDAO.getVehicleById(vehicleId);
        assertNull(retrieved);
    }

    @Test
    @DisplayName("Should handle vehicle with picture")
    void testVehicleWithPicture() {
        // Arrange
        byte[] pictureData = "fake-vehicle-image".getBytes();
        Vehicle vehicle = new Vehicle();
        vehicle.setDriverId(TEST_DRIVER_ID);
        vehicle.setVehicleType("Luxury Car");
        vehicle.setBrand("Mercedes");
        vehicle.setModel("S-Class");
        vehicle.setPlateNumber("JKL-5555");
        vehicle.setPicture(pictureData);
        vehicle.setFareFirstKm(500.00);
        vehicle.setFareNextKm(250.00);

        // Act
        vehicleDAO.addVehicle(vehicle);
        Vehicle retrieved = vehicleDAO.getVehicleById(vehicle.getId());

        // Assert
        assertNotNull(retrieved.getPicture());
        assertArrayEquals(pictureData, retrieved.getPicture());
    }

    @Test
    @DisplayName("Should isolate vehicles between different drivers")
    void testDriverIsolation() {
        // Arrange
        int driver1Id = 1;
        int driver2Id = 2;

        Vehicle driver1Vehicle = new Vehicle();
        driver1Vehicle.setDriverId(driver1Id);
        driver1Vehicle.setVehicleType("Car");
        driver1Vehicle.setBrand("BMW");
        driver1Vehicle.setModel("3 Series");
        driver1Vehicle.setPlateNumber("D1-1111");
        driver1Vehicle.setFareFirstKm(300.00);
        driver1Vehicle.setFareNextKm(150.00);
        vehicleDAO.addVehicle(driver1Vehicle);

        Vehicle driver2Vehicle = new Vehicle();
        driver2Vehicle.setDriverId(driver2Id);
        driver2Vehicle.setVehicleType("Car");
        driver2Vehicle.setBrand("Audi");
        driver2Vehicle.setModel("A4");
        driver2Vehicle.setPlateNumber("D2-2222");
        driver2Vehicle.setFareFirstKm(320.00);
        driver2Vehicle.setFareNextKm(160.00);
        vehicleDAO.addVehicle(driver2Vehicle);

        // Act
        List<Vehicle> driver1Vehicles = vehicleDAO.getVehiclesByDriver(driver1Id);
        List<Vehicle> driver2Vehicles = vehicleDAO.getVehiclesByDriver(driver2Id);

        // Assert
        assertEquals(1, driver1Vehicles.size());
        assertEquals(1, driver2Vehicles.size());
        assertEquals("BMW", driver1Vehicles.get(0).getBrand());
        assertEquals("Audi", driver2Vehicles.get(0).getBrand());
    }

    @Test
    @DisplayName("Should handle different vehicle types")
    void testDifferentVehicleTypes() {
        // Arrange
        String[] vehicleTypes = {"Car", "Van", "SUV", "Motorcycle", "Truck"};
        
        for (String type : vehicleTypes) {
            Vehicle vehicle = new Vehicle();
            vehicle.setDriverId(TEST_DRIVER_ID);
            vehicle.setVehicleType(type);
            vehicle.setBrand("TestBrand");
            vehicle.setModel("TestModel");
            vehicle.setPlateNumber("TEST-" + type);
            vehicle.setFareFirstKm(100.00);
            vehicle.setFareNextKm(50.00);
            vehicleDAO.addVehicle(vehicle);
        }

        // Act
        List<Vehicle> vehicles = vehicleDAO.getVehiclesByDriver(TEST_DRIVER_ID);

        // Assert
        assertEquals(5, vehicles.size());
        for (String type : vehicleTypes) {
            assertTrue(vehicles.stream().anyMatch(v -> v.getVehicleType().equals(type)));
        }
    }

    @Test
    @DisplayName("Should handle zero fare rates")
    void testZeroFareRates() {
        // Arrange
        Vehicle vehicle = new Vehicle();
        vehicle.setDriverId(TEST_DRIVER_ID);
        vehicle.setVehicleType("Free Ride");
        vehicle.setBrand("Charity");
        vehicle.setModel("Service");
        vehicle.setPlateNumber("FREE-0000");
        vehicle.setFareFirstKm(0.00);
        vehicle.setFareNextKm(0.00);

        // Act
        vehicleDAO.addVehicle(vehicle);
        Vehicle retrieved = vehicleDAO.getVehicleById(vehicle.getId());

        // Assert
        assertEquals(0.00, retrieved.getFareFirstKm(), 0.01);
        assertEquals(0.00, retrieved.getFareNextKm(), 0.01);
    }
}
