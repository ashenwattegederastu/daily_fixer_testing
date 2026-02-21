# DailyFixer Booking System - Setup Guide

## Database Setup

### 1. Run the Migration
Execute the migration file to create all required tables:

```bash
mysql -u your_username -p dfguidestore < src/main/resources/migrations/booking_system_migration.sql
```

This will create:
- `service_categories` (with default categories)
- `technician_availability`
- `bookings`
- `booking_cancellations`
- `chats`
- `chat_messages`

### 2. Verify Tables
```sql
USE dfguidestore;
SHOW TABLES;

-- Should show all new tables
-- Verify categories were inserted:
SELECT * FROM service_categories;
```

## Application Configuration

### Google Maps API Key (Optional)
The booking form includes Google Maps for location selection. To enable it:

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs:
   - Maps JavaScript API
   - Places API
   - Geocoding API
3. Update `src/main/webapp/pages/bookings/create-booking.jsp` line 10:
```jsp
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE&libraries=places"></script>
```

**Note:** The system will work without Maps, but location features will be limited.

## Building the Application

```bash
# Clean and compile
mvn clean compile

# Package as WAR
mvn clean package

# The WAR file will be in target/dailyfixer-1.0-SNAPSHOT.war
```

## Deploying to Tomcat 11

### Option 1: Copy WAR File
```bash
cp target/dailyfixer-1.0-SNAPSHOT.war /path/to/tomcat/webapps/
```

### Option 2: Maven Tomcat Plugin (if configured)
```bash
mvn tomcat7:deploy
```

## URL Routes

### Public Routes
- `/services` - Browse and search services
- `/bookings/create?serviceId=X` - Create a booking

### Technician Routes (requires login as technician)
- `/availability` - Manage availability
- `/bookings/requests` - View pending booking requests
- `/bookings/calendar` - View accepted bookings
- `/chats` - View all chats
- `/chats/view?chatId=X` - View specific chat

### User Routes (requires login)
- View bookings from user dashboard
- `/chats` - View all chats
- `/chats/view?chatId=X` - View specific chat

## Testing the System

### 1. As a Technician:
1. Login as a technician user
2. Navigate to `/availability`
3. Set your availability (e.g., Weekdays, 09:00-17:00)
4. Create a service (use existing service management)
5. Wait for booking requests at `/bookings/requests`
6. Accept a booking
7. Go to `/bookings/calendar` to see accepted bookings
8. Chat with customer
9. Mark booking as complete

### 2. As a User:
1. Login as a regular user
2. Go to `/services` (or click "Book a Technician" in header)
3. Browse services
4. Click "Book Now" on a service
5. Fill in booking form:
   - Select date and time
   - Enter phone number
   - Describe problem
   - Select location on map (if Maps enabled)
6. Submit booking
7. Wait for technician to accept
8. View bookings in user dashboard
9. Chat with technician after acceptance
10. Confirm completion when technician marks done

## Troubleshooting

### Database Connection Issues
Check `src/main/java/com/dailyfixer/util/DBConnection.java` for database configuration.

### Migration Already Applied
If tables already exist, the migration will fail. Either:
- Drop existing tables first
- Or comment out `CREATE TABLE IF NOT EXISTS` for existing tables

### Maps Not Loading
- Verify API key is correct
- Check browser console for JavaScript errors
- Ensure Google Maps APIs are enabled in Google Cloud Console

### Build Errors
```bash
# Clean and rebuild
mvn clean install -U

# Skip tests if needed
mvn clean install -DskipTests
```

### Chat Messages Not Updating
- The chat uses basic polling (5-second intervals)
- Check browser console for fetch errors
- For production, consider implementing WebSockets

## Default Service Categories

The migration inserts these categories:
1. Plumbing
2. Electrical
3. Carpentry
4. Painting
5. HVAC
6. Appliance Repair
7. Cleaning
8. Landscaping
9. Other

You can add more via:
```sql
INSERT INTO service_categories (name, description) VALUES ('Category Name', 'Description');
```

## Security Notes

1. **SQL Injection Protection**: All queries use PreparedStatements
2. **XSS Protection**: Ensure JSP escaping is enabled
3. **Authentication**: All routes check session user
4. **Authorization**: Role-based checks in servlets
5. **API Keys**: Never commit real API keys to version control

## Performance Tips

1. **Database Indexes**: Already included in migration
2. **Connection Pooling**: Configure in Tomcat's context.xml
3. **Chat Polling**: Consider WebSockets for production
4. **Image Optimization**: Compress service images before upload

## Next Steps

1. Run database migration
2. Build and deploy application
3. Create test users (technician and regular user)
4. Test the complete booking workflow
5. Configure Google Maps API (optional)
6. Set up email notifications (future enhancement)

## Support

For issues or questions, refer to:
- `IMPLEMENTATION_SUMMARY.md` for detailed implementation info
- Source code comments in servlets and DAOs
- Jakarta EE documentation
- MySQL 8 documentation
