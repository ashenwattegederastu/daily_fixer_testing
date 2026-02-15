package com.dailyfixer.dao;

import com.dailyfixer.model.Service;
import com.dailyfixer.model.User;
import com.dailyfixer.util.HashUtil;
import com.dailyfixer.util.TestDBConnection;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests for database layer.
 * Tests complete user workflows with H2 in-memory database.
 */
class DatabaseIntegrationIT {

    private UserDAOTestHelper userDAO;
    private ServiceDAOTestHelper serviceDAO;

    @BeforeEach
    void setUp() throws Exception {
        userDAO = new UserDAOTestHelper();
        serviceDAO = new ServiceDAOTestHelper();
        TestDBConnection.clearAllTables();
    }

    @Test
    @DisplayName("Integration: User registration and service creation flow")
    void testUserRegistrationAndServiceCreation() throws Exception {
        // Step 1: Register a new technician
        User technician = new User();
        technician.setFirstName("John");
        technician.setLastName("TechPro");
        technician.setUsername("johntechpro");
        technician.setEmail("john.tech@example.com");
        technician.setPassword(HashUtil.sha256("securePassword123"));
        technician.setPhoneNumber("0771234567");
        technician.setCity("Colombo");
        technician.setRole("technician");
        technician.setStatus("active");

        int technicianId = userDAO.saveUser(technician);
        assertTrue(technicianId > 0, "Technician should be saved successfully");

        // Step 2: Verify technician can be retrieved
        User retrievedTechnician = userDAO.getUserById(technicianId);
        assertNotNull(retrievedTechnician);
        assertEquals("johntechpro", retrievedTechnician.getUsername());
        assertEquals("technician", retrievedTechnician.getRole());

        // Step 3: Technician creates a service
        Service plumbingService = new Service();
        plumbingService.setTechnicianId(technicianId);
        plumbingService.setServiceName("Professional Plumbing");
        plumbingService.setDescription("All types of plumbing repairs and installations");
        plumbingService.setCategory("Plumbing");
        plumbingService.setPricingType("fixed");
        plumbingService.setFixedRate(8000.00);
        plumbingService.setInspectionCharge(500.00);
        plumbingService.setTransportCharge(300.00);
        plumbingService.setAvailableDates("Monday to Friday, 9 AM - 5 PM");

        serviceDAO.addService(plumbingService);

        // Step 4: Verify service is created and retrievable
        List<Service> services = serviceDAO.getServicesByTechnician(technicianId);
        assertEquals(1, services.size());

        Service retrievedService = services.get(0);
        assertEquals("Professional Plumbing", retrievedService.getServiceName());
        assertEquals("Plumbing", retrievedService.getCategory());
        assertEquals(8000.00, retrievedService.getFixedRate(), 0.01);
    }

    @Test
    @DisplayName("Integration: User login validation workflow")
    void testUserLoginWorkflow() throws Exception {
        // Step 1: Register a user
        String plainPassword = "myPassword123";
        String hashedPassword = HashUtil.sha256(plainPassword);

        User user = new User();
        user.setFirstName("Alice");
        user.setLastName("Johnson");
        user.setUsername("alicejohnson");
        user.setEmail("alice@example.com");
        user.setPassword(hashedPassword);
        user.setPhoneNumber("0777777777");
        user.setCity("Galle");
        user.setRole("user");
        user.setStatus("active");

        int userId = userDAO.saveUser(user);
        assertTrue(userId > 0);

        // Step 2: Simulate login with correct credentials
        User loggedInUser = userDAO.findByUsernameAndPassword("alicejohnson", hashedPassword);
        assertNotNull(loggedInUser, "User should be able to login with correct credentials");
        assertEquals("alice@example.com", loggedInUser.getEmail());
        assertEquals("user", loggedInUser.getRole());

        // Step 3: Simulate login with incorrect credentials
        String wrongPassword = HashUtil.sha256("wrongPassword");
        User failedLogin = userDAO.findByUsernameAndPassword("alicejohnson", wrongPassword);
        assertNull(failedLogin, "Login should fail with incorrect password");
    }

    @Test
    @DisplayName("Integration: Multiple technicians with multiple services")
    void testMultipleTechniciansMultipleServices() throws Exception {
        // Create first technician
        User tech1 = new User();
        tech1.setFirstName("Bob");
        tech1.setLastName("Electrician");
        tech1.setUsername("bobelectric");
        tech1.setEmail("bob@electric.com");
        tech1.setPassword(HashUtil.sha256("password"));
        tech1.setPhoneNumber("0711111111");
        tech1.setCity("Colombo");
        tech1.setRole("technician");
        tech1.setStatus("active");
        int tech1Id = userDAO.saveUser(tech1);

        // Create second technician
        User tech2 = new User();
        tech2.setFirstName("Carol");
        tech2.setLastName("Carpenter");
        tech2.setUsername("carolcarpenter");
        tech2.setEmail("carol@carpenter.com");
        tech2.setPassword(HashUtil.sha256("password"));
        tech2.setPhoneNumber("0722222222");
        tech2.setCity("Kandy");
        tech2.setRole("technician");
        tech2.setStatus("active");
        int tech2Id = userDAO.saveUser(tech2);

        // Tech1 creates electrical services
        Service electricService1 = new Service();
        electricService1.setTechnicianId(tech1Id);
        electricService1.setServiceName("House Wiring");
        electricService1.setCategory("Electrical");
        electricService1.setPricingType("fixed");
        electricService1.setFixedRate(15000.00);
        serviceDAO.addService(electricService1);

        Service electricService2 = new Service();
        electricService2.setTechnicianId(tech1Id);
        electricService2.setServiceName("Fan Installation");
        electricService2.setCategory("Electrical");
        electricService2.setPricingType("fixed");
        electricService2.setFixedRate(3000.00);
        serviceDAO.addService(electricService2);

        // Tech2 creates carpentry services
        Service carpentryService = new Service();
        carpentryService.setTechnicianId(tech2Id);
        carpentryService.setServiceName("Custom Furniture");
        carpentryService.setCategory("Carpentry");
        carpentryService.setPricingType("hourly");
        carpentryService.setHourlyRate(2500.00);
        serviceDAO.addService(carpentryService);

        // Verify services are correctly associated
        List<Service> tech1Services = serviceDAO.getServicesByTechnician(tech1Id);
        List<Service> tech2Services = serviceDAO.getServicesByTechnician(tech2Id);

        assertEquals(2, tech1Services.size());
        assertEquals(1, tech2Services.size());

        assertTrue(tech1Services.stream().allMatch(s -> s.getTechnicianId() == tech1Id));
        assertTrue(tech2Services.stream().allMatch(s -> s.getTechnicianId() == tech2Id));

        assertTrue(tech1Services.stream().anyMatch(s -> s.getServiceName().equals("House Wiring")));
        assertTrue(tech1Services.stream().anyMatch(s -> s.getServiceName().equals("Fan Installation")));
        assertTrue(tech2Services.stream().anyMatch(s -> s.getServiceName().equals("Custom Furniture")));
    }

    @Test
    @DisplayName("Integration: User registration validation - duplicate username")
    void testDuplicateUsernameValidation() throws Exception {
        // Create first user
        User user1 = new User();
        user1.setFirstName("First");
        user1.setLastName("User");
        user1.setUsername("duplicateuser");
        user1.setEmail("user1@example.com");
        user1.setPassword("password1");
        user1.setPhoneNumber("0731111111");
        user1.setCity("Colombo");
        user1.setRole("user");
        userDAO.saveUser(user1);

        // Check if username is taken before attempting to create second user
        boolean usernameTaken = userDAO.isUsernameTaken("duplicateuser");
        assertTrue(usernameTaken, "Username should be detected as taken");

        // Verify different username is available
        boolean newUsernameTaken = userDAO.isUsernameTaken("newuniqueuser");
        assertFalse(newUsernameTaken, "New username should be available");
    }

    @Test
    @DisplayName("Integration: User registration validation - duplicate email")
    void testDuplicateEmailValidation() throws Exception {
        // Create first user
        User user1 = new User();
        user1.setFirstName("First");
        user1.setLastName("User");
        user1.setUsername("user1");
        user1.setEmail("duplicate@example.com");
        user1.setPassword("password1");
        user1.setPhoneNumber("0731111111");
        user1.setCity("Colombo");
        user1.setRole("user");
        userDAO.saveUser(user1);

        // Check if email is taken
        boolean emailTaken = userDAO.isEmailTaken("duplicate@example.com");
        assertTrue(emailTaken, "Email should be detected as taken");

        // Verify different email is available
        boolean newEmailTaken = userDAO.isEmailTaken("newemail@example.com");
        assertFalse(newEmailTaken, "New email should be available");
    }

    @Test
    @DisplayName("Integration: Service deletion workflow")
    void testServiceDeletionWorkflow() throws Exception {
        // Create technician
        User technician = new User();
        technician.setFirstName("Delete");
        technician.setLastName("Test");
        technician.setUsername("deletetech");
        technician.setEmail("delete@test.com");
        technician.setPassword("password");
        technician.setPhoneNumber("0741234567");
        technician.setCity("Colombo");
        technician.setRole("technician");
        int techId = userDAO.saveUser(technician);

        // Create multiple services
        for (int i = 1; i <= 3; i++) {
            Service service = new Service();
            service.setTechnicianId(techId);
            service.setServiceName("Service " + i);
            service.setCategory("Category");
            service.setPricingType("fixed");
            service.setFixedRate(1000.00 * i);
            serviceDAO.addService(service);
        }

        // Verify all services are created
        List<Service> allServices = serviceDAO.getServicesByTechnician(techId);
        assertEquals(3, allServices.size());

        // Delete one service
        int serviceIdToDelete = allServices.get(1).getServiceId();
        serviceDAO.deleteService(serviceIdToDelete);

        // Verify service is deleted
        Service deletedService = serviceDAO.getServiceById(serviceIdToDelete);
        assertNull(deletedService);

        // Verify other services still exist
        List<Service> remainingServices = serviceDAO.getServicesByTechnician(techId);
        assertEquals(2, remainingServices.size());
        assertFalse(remainingServices.stream().anyMatch(s -> s.getServiceId() == serviceIdToDelete));
    }

    @Test
    @DisplayName("Integration: Complete booking preparation workflow")
    void testBookingPreparationWorkflow() throws Exception {
        // Step 1: Customer registers
        User customer = new User();
        customer.setFirstName("Customer");
        customer.setLastName("Name");
        customer.setUsername("customer1");
        customer.setEmail("customer@example.com");
        customer.setPassword(HashUtil.sha256("customerpass"));
        customer.setPhoneNumber("0751234567");
        customer.setCity("Galle");
        customer.setRole("user");
        customer.setStatus("active");
        int customerId = userDAO.saveUser(customer);
        assertTrue(customerId > 0);

        // Step 2: Technician registers
        User technician = new User();
        technician.setFirstName("Technician");
        technician.setLastName("Expert");
        technician.setUsername("techexpert");
        technician.setEmail("tech@example.com");
        technician.setPassword(HashUtil.sha256("techpass"));
        technician.setPhoneNumber("0761234567");
        technician.setCity("Galle");
        technician.setRole("technician");
        technician.setStatus("active");
        int techId = userDAO.saveUser(technician);
        assertTrue(techId > 0);

        // Step 3: Technician creates service
        Service service = new Service();
        service.setTechnicianId(techId);
        service.setServiceName("AC Repair");
        service.setDescription("Air conditioning repair and maintenance");
        service.setCategory("HVAC");
        service.setPricingType("fixed");
        service.setFixedRate(6000.00);
        service.setInspectionCharge(500.00);
        service.setTransportCharge(400.00);
        service.setAvailableDates("Weekdays");
        serviceDAO.addService(service);

        // Step 4: Customer can view technician's services
        List<Service> availableServices = serviceDAO.getServicesByTechnician(techId);
        assertEquals(1, availableServices.size());
        Service availableService = availableServices.get(0);
        assertEquals("AC Repair", availableService.getServiceName());

        // Step 5: Verify all participants exist and have correct roles
        User verifyCustomer = userDAO.getUserById(customerId);
        User verifyTechnician = userDAO.getUserById(techId);

        assertEquals("user", verifyCustomer.getRole());
        assertEquals("technician", verifyTechnician.getRole());

        // This validates the basic data setup needed for a booking
        // In a real system, a booking table would be created here
        assertNotNull(verifyCustomer);
        assertNotNull(verifyTechnician);
        assertNotNull(availableService);
    }
}
