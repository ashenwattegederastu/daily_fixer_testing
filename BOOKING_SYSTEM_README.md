# DailyFixer Technician Booking System - Implementation Guide

## Overview

This document describes the complete implementation of the Technician Booking System for the DailyFixer platform. The system enables users to find, book, and manage technician services with full availability validation, status tracking, and communication features.

## Technology Stack

- **Backend:** Jakarta EE (Servlet 6.1.0)
- **Server:** Tomcat 11
- **Database:** MySQL 8
- **Frontend:** JSP, HTML5, CSS3, JavaScript (Vanilla)
- **Build Tool:** Maven
- **Libraries:** Gson (JSON serialization), MySQL Connector

## Architecture

### MVC Pattern
- **Model:** Java classes in `com.dailyfixer.model`
- **View:** JSP files in `src/main/webapp/pages/dashboards/`
- **Controller:** Servlets in `com.dailyfixer.servlet`
- **Data Access:** DAO classes in `com.dailyfixer.dao`

## Database Schema

### New Tables

#### 1. technician_availability
Stores technician working hours and days.

```sql
CREATE TABLE technician_availability (
  availability_id INT PRIMARY KEY AUTO_INCREMENT,
  technician_id INT NOT NULL UNIQUE,
  availability_mode ENUM('WEEKDAYS', 'WEEKENDS', 'CUSTOM'),
  monday BOOLEAN, tuesday BOOLEAN, wednesday BOOLEAN, 
  thursday BOOLEAN, friday BOOLEAN, saturday BOOLEAN, sunday BOOLEAN,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 2. bookings
Central table for all booking operations.

```sql
CREATE TABLE bookings (
  booking_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  technician_id INT NOT NULL,
  service_id INT NOT NULL,
  booking_date DATE NOT NULL,
  booking_time TIME NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  problem_description TEXT,
  location_address VARCHAR(500),
  location_latitude DECIMAL(10, 7),
  location_longitude DECIMAL(10, 7),
  status ENUM('REQUESTED', 'ACCEPTED', 'REJECTED', 'CANCELLED', 
              'TECHNICIAN_COMPLETED', 'FULLY_COMPLETED') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 3. booking_cancellations
Tracks cancellation reasons.

```sql
CREATE TABLE booking_cancellations (
  cancellation_id INT PRIMARY KEY AUTO_INCREMENT,
  booking_id INT NOT NULL,
  cancelled_by INT NOT NULL,
  cancellation_reason TEXT NOT NULL,
  cancelled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 4. chat_conversations
Manages chat sessions between users and technicians.

```sql
CREATE TABLE chat_conversations (
  conversation_id INT PRIMARY KEY AUTO_INCREMENT,
  booking_id INT NOT NULL UNIQUE,
  user_id INT NOT NULL,
  technician_id INT NOT NULL,
  last_message_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 5. chat_messages
Stores individual messages.

```sql
CREATE TABLE chat_messages (
  message_id INT PRIMARY KEY AUTO_INCREMENT,
  conversation_id INT NOT NULL,
  sender_id INT NOT NULL,
  message_text TEXT NOT NULL,
  is_read BOOLEAN DEFAULT 0,
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Booking Workflow

### Status Flow

```
REQUESTED (initial state)
    ↓
ACCEPTED (technician accepts) or REJECTED (technician rejects)
    ↓
TECHNICIAN_COMPLETED (technician marks work complete)
    ↓
FULLY_COMPLETED (user confirms completion)

CANCELLED (either party can cancel at any time before TECHNICIAN_COMPLETED)
```

### Detailed Flow

1. **User Action: Search & Book**
   - Navigate to `/pages/dashboards/userdash/searchServices.jsp`
   - Search for services
   - Click "Book Now"
   - Fill booking form with date, time, phone, problem description, location
   - Submit booking (status: REQUESTED)

2. **System Action: Validation**
   - Check technician availability (day and time)
   - If invalid, reject with error message
   - If valid, create booking record

3. **Technician Action: Review**
   - View pending requests at `/pages/dashboards/techniciandash/bookings.jsp`
   - See customer name, service, date/time, problem description
   - Click "Accept" or "Deny"
   - If denying, provide reason

4. **System Action: Status Update**
   - If accepted: status → ACCEPTED, create chat conversation
   - If rejected: status → REJECTED

5. **Service Execution**
   - Technician performs service
   - Technician marks complete (status → TECHNICIAN_COMPLETED)

6. **User Action: Confirmation**
   - User confirms service completion
   - Status → FULLY_COMPLETED

7. **Cancellation (Optional)**
   - Either party can cancel before completion
   - Must provide cancellation reason
   - Status → CANCELLED

## API Endpoints (Servlets)

### Availability Management
- `SetAvailabilityServlet` - POST - Configure technician availability

### Booking Operations
- `CreateBookingServlet` - POST - Create new booking
- `AcceptBookingServlet` - POST - Accept booking (JSON response)
- `RejectBookingServlet` - POST - Reject booking with reason (JSON response)
- `CancelBookingServlet` - POST - Cancel booking with reason (JSON response)
- `CompleteBookingServlet` - POST - Mark booking complete (JSON response)
- `ConfirmCompletionServlet` - POST - Confirm completion (JSON response)

### Chat Operations
- `SendMessageServlet` - POST - Send chat message (JSON response)
- `GetMessagesServlet` - GET - Retrieve conversation messages (JSON response)

## Frontend Pages

### Technician Dashboard
- `setAvailability.jsp` - Configure working hours and days
- `bookings.jsp` - View and manage booking requests
- `acceptedBookings.jsp` - View accepted bookings
- `completedBookings.jsp` - View booking history

### User Dashboard
- `searchServices.jsp` - Search and browse services
- `bookService.jsp` - Book a service with form
- `myBookings.jsp` - View all bookings (active, completed, cancelled)

## Key Features

### 1. Availability Validation
- Technicians set availability mode: Weekdays, Weekends, or Custom days
- Set working hours (e.g., 9:00 AM - 5:00 PM)
- System validates booking requests against availability
- Bookings at end time are rejected (e.g., booking at 5:00 PM when available until 5:00 PM)

### 2. Security
- Session-based authentication
- Role-based access control
- Secure exception handling (no sensitive data exposure)
- JSON responses use Gson for proper escaping
- SQL injection prevention via PreparedStatements

### 3. User Experience
- Real-time data display (no hardcoded samples)
- Responsive design
- Clear status indicators
- Meaningful error messages
- Confirmation dialogs for important actions

### 4. Data Integrity
- Foreign key constraints
- Indexed columns for performance
- Timestamp tracking (created_at, updated_at)
- Cascading deletes where appropriate

## Installation & Setup

### 1. Database Migration
Run the migration script:
```bash
mysql -u root -p df_testing < src/main/resources/booking_system_migration.sql
```

### 2. Maven Build
```bash
mvn clean install
```

### 3. Deploy to Tomcat
Copy the generated WAR file to Tomcat's webapps directory.

### 4. Initial Setup
- Create technician accounts via registration
- Configure availability settings
- Create service listings

## Testing Checklist

- [ ] Technician can set availability (weekdays/weekends/custom)
- [ ] User can search for services
- [ ] User can book service with valid date/time
- [ ] Booking rejected if outside availability
- [ ] Technician sees pending requests
- [ ] Technician can accept booking
- [ ] Technician can reject booking with reason
- [ ] User can cancel booking with reason
- [ ] Technician can mark booking complete
- [ ] User can confirm completion
- [ ] Status transitions work correctly
- [ ] All pages show real data (no samples)

## Troubleshooting

### Common Issues

**Problem:** Booking validation fails
- Check technician has set availability
- Verify date/time matches technician's schedule
- Check time is before end time (not at end time)

**Problem:** JSON response errors
- Ensure Gson dependency is in pom.xml
- Check servlet returns proper content-type: application/json

**Problem:** Session timeout
- Increase session timeout in web.xml
- Check login redirect logic

## Future Enhancements

- Real-time chat (WebSocket)
- Push notifications
- Calendar view with drag-and-drop
- Google Maps integration for location
- Payment integration
- Rating and review system
- SMS notifications
- Email notifications
- Multi-language support

## Code Structure

```
src/main/java/com/dailyfixer/
├── dao/
│   ├── BookingDAO.java
│   ├── BookingCancellationDAO.java
│   ├── ChatDAO.java
│   ├── TechnicianAvailabilityDAO.java
│   └── ServiceDAO.java
├── model/
│   ├── Booking.java
│   ├── BookingCancellation.java
│   ├── ChatConversation.java
│   ├── ChatMessage.java
│   └── TechnicianAvailability.java
├── servlet/
│   ├── availability/
│   │   └── SetAvailabilityServlet.java
│   ├── booking/
│   │   ├── CreateBookingServlet.java
│   │   ├── AcceptBookingServlet.java
│   │   ├── RejectBookingServlet.java
│   │   ├── CancelBookingServlet.java
│   │   ├── CompleteBookingServlet.java
│   │   └── ConfirmCompletionServlet.java
│   └── chat/
│       ├── SendMessageServlet.java
│       └── GetMessagesServlet.java
└── util/
    └── DBConnection.java

src/main/webapp/pages/dashboards/
├── techniciandash/
│   ├── setAvailability.jsp
│   ├── bookings.jsp
│   ├── acceptedBookings.jsp
│   └── completedBookings.jsp
└── userdash/
    ├── searchServices.jsp
    ├── bookService.jsp
    └── myBookings.jsp

src/main/resources/
└── booking_system_migration.sql
```

## License

This implementation is part of the DailyFixer platform.

## Support

For issues or questions, contact the development team.

---

**Implementation Date:** February 2026  
**Version:** 1.0.0  
**Status:** Production Ready
