<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Booking - Daily Fixer</title>
    <jsp:include page="../shared/header.jsp" />
    <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>
</head>
<body>
    <div style="max-width: 800px; margin: 2rem auto; padding: 0 1rem;">
        <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem; color: var(--foreground);">Book Service</h1>
        
        <c:if test="${not empty error}">
            <div style="background: var(--destructive); color: var(--destructive-foreground); padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                ${error}
            </div>
        </c:if>
        
        <div style="background: var(--card); padding: 1.5rem; border-radius: var(--radius); margin-bottom: 2rem; box-shadow: var(--shadow-sm);">
            <h2 style="font-size: 1.5rem; font-weight: 600; margin-bottom: 0.5rem;">${service.serviceName}</h2>
            <p style="color: var(--muted-foreground); margin-bottom: 0.5rem;">${service.description}</p>
            <p style="font-size: 1.25rem; font-weight: 700; color: var(--primary);">
                <c:choose>
                    <c:when test="${service.pricingType == 'fixed'}">LKR ${service.fixedRate}</c:when>
                    <c:otherwise>LKR ${service.hourlyRate}/hr</c:otherwise>
                </c:choose>
            </p>
        </div>
        
        <c:if test="${not empty availability}">
            <div style="background: var(--accent); padding: 1rem; border-radius: 0.5rem; margin-bottom: 1.5rem;">
                <p style="font-weight: 600; margin-bottom: 0.5rem;">Technician Availability:</p>
                <p>Available: ${availability.startTime} - ${availability.endTime}</p>
                <p>Days: 
                    <c:if test="${availability.monday}">Mon </c:if>
                    <c:if test="${availability.tuesday}">Tue </c:if>
                    <c:if test="${availability.wednesday}">Wed </c:if>
                    <c:if test="${availability.thursday}">Thu </c:if>
                    <c:if test="${availability.friday}">Fri </c:if>
                    <c:if test="${availability.saturday}">Sat </c:if>
                    <c:if test="${availability.sunday}">Sun</c:if>
                </p>
            </div>
        </c:if>
        
        <form method="post" action="${pageContext.request.contextPath}/bookings/create">
            <input type="hidden" name="serviceId" value="${service.serviceId}">
            <input type="hidden" name="latitude" id="latitude">
            <input type="hidden" name="longitude" id="longitude">
            
            <div style="background: var(--card); padding: 1.5rem; border-radius: var(--radius); box-shadow: var(--shadow-sm);">
                <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;">Booking Details</h3>
                
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Booking Date *</label>
                    <input type="date" name="bookingDate" required 
                           style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input);">
                </div>
                
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Booking Time *</label>
                    <input type="time" name="bookingTime" required 
                           style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input);">
                </div>
                
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Phone Number *</label>
                    <input type="tel" name="phoneNumber" required pattern="[0-9]{10}" placeholder="0771234567"
                           style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input);">
                </div>
                
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Problem Description *</label>
                    <textarea name="problemDescription" required rows="4" placeholder="Describe your problem in detail..."
                              style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input); resize: vertical;"></textarea>
                </div>
                
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Location *</label>
                    <input type="text" id="locationSearch" placeholder="Search for your location..." 
                           style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input); margin-bottom: 0.5rem;">
                    <div id="map" style="width: 100%; height: 300px; border-radius: 0.5rem; border: 1px solid var(--border);"></div>
                    <input type="text" name="locationAddress" id="locationAddress" required readonly placeholder="Selected address will appear here"
                           style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input); margin-top: 0.5rem;">
                </div>
                
                <button type="submit" style="width: 100%; background: var(--primary); color: var(--primary-foreground); padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; font-size: 1rem; cursor: pointer;">
                    Submit Booking Request
                </button>
            </div>
        </form>
    </div>
    
    <script>
        let map, marker, geocoder;
        
        function initMap() {
            // Default to Colombo, Sri Lanka
            const defaultLocation = { lat: 6.9271, lng: 79.8612 };
            
            map = new google.maps.Map(document.getElementById('map'), {
                center: defaultLocation,
                zoom: 13
            });
            
            geocoder = new google.maps.Geocoder();
            
            marker = new google.maps.Marker({
                map: map,
                draggable: true,
                position: defaultLocation
            });
            
            // Add click listener to map
            map.addListener('click', function(event) {
                placeMarker(event.latLng);
            });
            
            // Add drag listener to marker
            marker.addListener('dragend', function(event) {
                updateAddress(event.latLng);
            });
            
            // Search box
            const input = document.getElementById('locationSearch');
            const searchBox = new google.maps.places.SearchBox(input);
            
            searchBox.addListener('places_changed', function() {
                const places = searchBox.getPlaces();
                if (places.length === 0) return;
                
                const place = places[0];
                if (!place.geometry || !place.geometry.location) return;
                
                map.setCenter(place.geometry.location);
                placeMarker(place.geometry.location);
            });
        }
        
        function placeMarker(location) {
            marker.setPosition(location);
            map.panTo(location);
            updateAddress(location);
        }
        
        function updateAddress(location) {
            document.getElementById('latitude').value = location.lat();
            document.getElementById('longitude').value = location.lng();
            
            geocoder.geocode({ location: location }, function(results, status) {
                if (status === 'OK' && results[0]) {
                    document.getElementById('locationAddress').value = results[0].formatted_address;
                }
            });
        }
        
        // Initialize map when page loads
        window.addEventListener('load', initMap);
    </script>
</body>
</html>
