<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Calendar - Technician Dashboard</title>
    <jsp:include page="../../shared/header.jsp" />
</head>
<body>
    <div style="max-width: 1200px; margin: 2rem auto; padding: 0 1rem;">
        <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem; color: var(--foreground);">My Bookings</h1>
        
        <c:if test="${param.completed}">
            <div style="background: #10b981; color: white; padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                Booking marked as completed!
            </div>
        </c:if>
        
        <c:if test="${param.cancelled}">
            <div style="background: #f59e0b; color: white; padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                Booking cancelled successfully.
            </div>
        </c:if>
        
        <c:if test="${empty bookings}">
            <div style="text-align: center; padding: 3rem; background: var(--card); border-radius: var(--radius);">
                <p style="font-size: 1.125rem; color: var(--muted-foreground);">No active bookings found.</p>
            </div>
        </c:if>
        
        <div style="display: grid; gap: 1.5rem;">
            <c:forEach var="booking" items="${bookings}">
                <div style="background: var(--card); border-radius: var(--radius); padding: 1.5rem; box-shadow: var(--shadow-sm); border: 1px solid var(--border);">
                    <div style="display: grid; grid-template-columns: 1fr auto; gap: 1rem; margin-bottom: 1rem;">
                        <div>
                            <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 0.5rem;">${booking.serviceName}</h3>
                            <p style="color: var(--muted-foreground); margin-bottom: 0.25rem;"><strong>Customer:</strong> ${booking.userName}</p>
                            <p style="color: var(--muted-foreground); margin-bottom: 0.25rem;"><strong>Phone:</strong> ${booking.phoneNumber}</p>
                            <p style="color: var(--muted-foreground); margin-bottom: 0.25rem;"><strong>Date:</strong> ${booking.bookingDate} at ${booking.bookingTime}</p>
                        </div>
                        <div>
                            <c:choose>
                                <c:when test="${booking.status == 'ACCEPTED'}">
                                    <span style="display: inline-block; background: #10b981; color: white; padding: 0.25rem 0.75rem; border-radius: 0.25rem; font-size: 0.875rem; font-weight: 600;">ACCEPTED</span>
                                </c:when>
                                <c:when test="${booking.status == 'TECHNICIAN_COMPLETED'}">
                                    <span style="display: inline-block; background: var(--primary); color: var(--primary-foreground); padding: 0.25rem 0.75rem; border-radius: 0.25rem; font-size: 0.875rem; font-weight: 600;">AWAITING USER CONFIRM</span>
                                </c:when>
                            </c:choose>
                        </div>
                    </div>
                    
                    <div style="background: var(--muted); padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                        <p style="font-weight: 600; margin-bottom: 0.5rem;">Problem Description:</p>
                        <p style="color: var(--muted-foreground);">${booking.problemDescription}</p>
                    </div>
                    
                    <div style="background: var(--muted); padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                        <p style="font-weight: 600; margin-bottom: 0.5rem;">Location:</p>
                        <p style="color: var(--muted-foreground); margin-bottom: 0.5rem;">${booking.locationAddress}</p>
                        <c:if test="${not empty booking.locationLatitude && not empty booking.locationLongitude}">
                            <a href="https://www.google.com/maps?q=${booking.locationLatitude},${booking.locationLongitude}" target="_blank"
                               style="color: var(--primary); text-decoration: underline;">View on Google Maps</a>
                        </c:if>
                    </div>
                    
                    <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                        <a href="${pageContext.request.contextPath}/chats/view?chatId=${booking.bookingId}" 
                           style="flex: 1; text-align: center; background: var(--primary); color: var(--primary-foreground); padding: 0.75rem; border-radius: 0.5rem; text-decoration: none; font-weight: 600; min-width: 150px;">
                            Open Chat
                        </a>
                        
                        <c:if test="${booking.status == 'ACCEPTED'}">
                            <form method="post" action="${pageContext.request.contextPath}/bookings/complete" style="flex: 1; min-width: 150px;">
                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                <input type="hidden" name="completionType" value="technician">
                                <button type="submit" style="width: 100%; background: #10b981; color: white; padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer;">
                                    Mark as Complete
                                </button>
                            </form>
                        </c:if>
                        
                        <button onclick="showCancelModal(${booking.bookingId})" 
                                style="flex: 1; background: var(--destructive); color: var(--destructive-foreground); padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer; min-width: 150px;">
                            Cancel Booking
                        </button>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
    
    <!-- Cancel Modal -->
    <div id="cancelModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;">
        <div style="background: var(--card); padding: 2rem; border-radius: var(--radius); max-width: 500px; width: 90%;">
            <h3 style="font-size: 1.5rem; font-weight: 600; margin-bottom: 1rem;">Cancel Booking</h3>
            <form id="cancelForm" method="post" action="${pageContext.request.contextPath}/bookings/cancel">
                <input type="hidden" name="bookingId" id="cancelBookingId">
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Reason for Cancellation *</label>
                    <textarea name="cancellationReason" required rows="4" placeholder="Please provide a reason..."
                              style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input); resize: vertical;"></textarea>
                </div>
                <div style="display: flex; gap: 1rem;">
                    <button type="submit" style="flex: 1; background: var(--destructive); color: var(--destructive-foreground); padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer;">
                        Cancel Booking
                    </button>
                    <button type="button" onclick="closeCancelModal()" style="flex: 1; background: var(--secondary); color: var(--secondary-foreground); padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer;">
                        Close
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function showCancelModal(bookingId) {
            document.getElementById('cancelBookingId').value = bookingId;
            document.getElementById('cancelModal').style.display = 'flex';
        }
        
        function closeCancelModal() {
            document.getElementById('cancelModal').style.display = 'none';
        }
    </script>
</body>
</html>
