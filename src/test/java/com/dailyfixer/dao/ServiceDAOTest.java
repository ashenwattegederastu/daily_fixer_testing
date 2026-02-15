package com.dailyfixer.dao;

import com.dailyfixer.model.Service;
import com.dailyfixer.model.User;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for ServiceDAO using H2 in-memory database.
 */
class ServiceDAOTest {

    private ServiceDAOTestHelper serviceDAO;
    private UserDAOTestHelper userDAO;
    private int technicianId;

    @BeforeEach
    void setUp() throws Exception {
        serviceDAO = new ServiceDAOTestHelper();
        userDAO = new UserDAOTestHelper();
        TestDBConnection.clearAllTables();

        // Create a technician user for testing
        User technician = new User();
        technician.setFirstName("Tech");
        technician.setLastName("Nician");
        technician.setUsername("technician1");
        technician.setEmail("tech@example.com");
        technician.setPassword("password");
        technician.setPhoneNumber("1234567890");
        technician.setCity("Colombo");
        technician.setRole("technician");
        technicianId = userDAO.saveUser(technician);
    }

    @Test
    @DisplayName("Should add service successfully")
    void testAddService() throws Exception {
        // Arrange
        Service service = new Service();
        service.setTechnicianId(technicianId);
        service.setServiceName("Plumbing Repair");
        service.setDescription("Expert plumbing services");
        service.setCategory("Plumbing");
        service.setPricingType("fixed");
        service.setFixedRate(5000.00);
        service.setInspectionCharge(500.00);
        service.setTransportCharge(200.00);
        service.setAvailableDates("Mon-Fri");

        // Act
        serviceDAO.addService(service);

        // Assert - verify by retrieving all services for this technician
        List<Service> services = serviceDAO.getServicesByTechnician(technicianId);
        assertEquals(1, services.size());
        assertEquals("Plumbing Repair", services.get(0).getServiceName());
    }

    @Test
    @DisplayName("Should retrieve service by ID")
    void testGetServiceById() throws Exception {
        // Arrange
        Service service = new Service();
        service.setTechnicianId(technicianId);
        service.setServiceName("Electrical Work");
        service.setDescription("Electrical repairs and installations");
        service.setCategory("Electrical");
        service.setPricingType("hourly");
        service.setHourlyRate(2000.00);
        service.setInspectionCharge(300.00);
        service.setTransportCharge(150.00);
        service.setAvailableDates("Weekends");
        serviceDAO.addService(service);

        // Get the service ID from the list
        List<Service> services = serviceDAO.getServicesByTechnician(technicianId);
        int serviceId = services.get(0).getServiceId();

        // Act
        Service retrievedService = serviceDAO.getServiceById(serviceId);

        // Assert
        assertNotNull(retrievedService);
        assertEquals(serviceId, retrievedService.getServiceId());
        assertEquals("Electrical Work", retrievedService.getServiceName());
        assertEquals("Electrical", retrievedService.getCategory());
        assertEquals("hourly", retrievedService.getPricingType());
        assertEquals(2000.00, retrievedService.getHourlyRate(), 0.01);
    }

    @Test
    @DisplayName("Should return null for non-existent service ID")
    void testGetServiceById_NotFound() throws Exception {
        // Act
        Service service = serviceDAO.getServiceById(9999);

        // Assert
        assertNull(service);
    }

    @Test
    @DisplayName("Should retrieve all services by technician")
    void testGetServicesByTechnician() throws Exception {
        // Arrange - Add multiple services
        Service service1 = new Service();
        service1.setTechnicianId(technicianId);
        service1.setServiceName("Service 1");
        service1.setDescription("Description 1");
        service1.setCategory("Category 1");
        service1.setPricingType("fixed");
        service1.setFixedRate(3000.00);
        serviceDAO.addService(service1);

        Service service2 = new Service();
        service2.setTechnicianId(technicianId);
        service2.setServiceName("Service 2");
        service2.setDescription("Description 2");
        service2.setCategory("Category 2");
        service2.setPricingType("hourly");
        service2.setHourlyRate(1500.00);
        serviceDAO.addService(service2);

        // Act
        List<Service> services = serviceDAO.getServicesByTechnician(technicianId);

        // Assert
        assertEquals(2, services.size());
        assertTrue(services.stream().anyMatch(s -> s.getServiceName().equals("Service 1")));
        assertTrue(services.stream().anyMatch(s -> s.getServiceName().equals("Service 2")));
    }

    @Test
    @DisplayName("Should return empty list for technician with no services")
    void testGetServicesByTechnician_NoServices() throws Exception {
        // Act
        List<Service> services = serviceDAO.getServicesByTechnician(technicianId);

        // Assert
        assertNotNull(services);
        assertEquals(0, services.size());
    }

    @Test
    @DisplayName("Should delete service successfully")
    void testDeleteService() throws Exception {
        // Arrange
        Service service = new Service();
        service.setTechnicianId(technicianId);
        service.setServiceName("Service to Delete");
        service.setDescription("This service will be deleted");
        service.setCategory("Test");
        service.setPricingType("fixed");
        service.setFixedRate(1000.00);
        serviceDAO.addService(service);

        List<Service> servicesBeforeDelete = serviceDAO.getServicesByTechnician(technicianId);
        int serviceId = servicesBeforeDelete.get(0).getServiceId();

        // Act
        serviceDAO.deleteService(serviceId);

        // Assert
        Service deletedService = serviceDAO.getServiceById(serviceId);
        assertNull(deletedService);

        List<Service> servicesAfterDelete = serviceDAO.getServicesByTechnician(technicianId);
        assertEquals(0, servicesAfterDelete.size());
    }

    @Test
    @DisplayName("Should handle service with fixed rate pricing")
    void testServiceWithFixedRate() throws Exception {
        // Arrange
        Service service = new Service();
        service.setTechnicianId(technicianId);
        service.setServiceName("Fixed Rate Service");
        service.setDescription("Service with fixed pricing");
        service.setCategory("General");
        service.setPricingType("fixed");
        service.setFixedRate(7500.00);
        service.setHourlyRate(0.00);
        service.setInspectionCharge(500.00);
        service.setTransportCharge(300.00);
        serviceDAO.addService(service);

        // Act
        List<Service> services = serviceDAO.getServicesByTechnician(technicianId);
        Service retrievedService = services.get(0);

        // Assert
        assertEquals("fixed", retrievedService.getPricingType());
        assertEquals(7500.00, retrievedService.getFixedRate(), 0.01);
        assertEquals(0.00, retrievedService.getHourlyRate(), 0.01);
    }

    @Test
    @DisplayName("Should handle service with hourly rate pricing")
    void testServiceWithHourlyRate() throws Exception {
        // Arrange
        Service service = new Service();
        service.setTechnicianId(technicianId);
        service.setServiceName("Hourly Rate Service");
        service.setDescription("Service with hourly pricing");
        service.setCategory("General");
        service.setPricingType("hourly");
        service.setFixedRate(0.00);
        service.setHourlyRate(2500.00);
        service.setInspectionCharge(400.00);
        service.setTransportCharge(250.00);
        serviceDAO.addService(service);

        // Act
        List<Service> services = serviceDAO.getServicesByTechnician(technicianId);
        Service retrievedService = services.get(0);

        // Assert
        assertEquals("hourly", retrievedService.getPricingType());
        assertEquals(0.00, retrievedService.getFixedRate(), 0.01);
        assertEquals(2500.00, retrievedService.getHourlyRate(), 0.01);
    }

    @Test
    @DisplayName("Should isolate services between different technicians")
    void testMultipleTechnicians() throws Exception {
        // Arrange - Create another technician
        User technician2 = new User();
        technician2.setFirstName("Another");
        technician2.setLastName("Tech");
        technician2.setUsername("technician2");
        technician2.setEmail("tech2@example.com");
        technician2.setPassword("password");
        technician2.setPhoneNumber("9876543210");
        technician2.setCity("Kandy");
        technician2.setRole("technician");
        int technicianId2 = userDAO.saveUser(technician2);

        // Add service for first technician
        Service service1 = new Service();
        service1.setTechnicianId(technicianId);
        service1.setServiceName("Tech1 Service");
        service1.setCategory("Category1");
        service1.setPricingType("fixed");
        service1.setFixedRate(5000.00);
        serviceDAO.addService(service1);

        // Add service for second technician
        Service service2 = new Service();
        service2.setTechnicianId(technicianId2);
        service2.setServiceName("Tech2 Service");
        service2.setCategory("Category2");
        service2.setPricingType("hourly");
        service2.setHourlyRate(3000.00);
        serviceDAO.addService(service2);

        // Act
        List<Service> tech1Services = serviceDAO.getServicesByTechnician(technicianId);
        List<Service> tech2Services = serviceDAO.getServicesByTechnician(technicianId2);

        // Assert
        assertEquals(1, tech1Services.size());
        assertEquals(1, tech2Services.size());
        assertEquals("Tech1 Service", tech1Services.get(0).getServiceName());
        assertEquals("Tech2 Service", tech2Services.get(0).getServiceName());
    }
}
