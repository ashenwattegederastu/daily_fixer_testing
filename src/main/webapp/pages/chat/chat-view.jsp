<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat - Daily Fixer</title>
    <jsp:include page="../shared/header.jsp" />
</head>
<body>
    <div style="max-width: 900px; margin: 2rem auto; padding: 0 1rem;">
        <div style="background: var(--card); border-radius: var(--radius); box-shadow: var(--shadow-lg); overflow: hidden;">
            <!-- Chat Header -->
            <div style="background: var(--primary); color: var(--primary-foreground); padding: 1.5rem; border-bottom: 1px solid var(--border);">
                <h2 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 0.25rem;">
                    <c:choose>
                        <c:when test="${sessionScope.currentUser.role == 'technician'}">
                            ${chat.userName}
                        </c:when>
                        <c:otherwise>
                            ${chat.technicianName}
                        </c:otherwise>
                    </c:choose>
                </h2>
                <p style="font-size: 0.875rem; opacity: 0.9;">${chat.serviceName}</p>
            </div>
            
            <!-- Messages Container -->
            <div id="messagesContainer" style="height: 500px; overflow-y: auto; padding: 1.5rem; background: var(--background);">
                <c:forEach var="message" items="${messages}">
                    <div style="margin-bottom: 1rem; display: flex; ${message.senderId == sessionScope.currentUser.userId ? 'justify-content: flex-end' : 'justify-content: flex-start'};">
                        <div style="max-width: 70%; ${message.senderId == sessionScope.currentUser.userId ? 'background: var(--primary); color: var(--primary-foreground);' : 'background: var(--card); color: var(--foreground); border: 1px solid var(--border);'} padding: 0.75rem 1rem; border-radius: 1rem;">
                            <p style="margin-bottom: 0.25rem;">${message.message}</p>
                            <p style="font-size: 0.75rem; opacity: 0.7; text-align: right;">
                                <c:choose>
                                    <c:when test="${message.senderId != sessionScope.currentUser.userId}">
                                        ${message.senderName} • 
                                    </c:when>
                                </c:choose>
                                ${message.createdAt}
                            </p>
                        </div>
                    </div>
                </c:forEach>
            </div>
            
            <!-- Message Input -->
            <div style="padding: 1.5rem; border-top: 1px solid var(--border); background: var(--card);">
                <form method="post" action="${pageContext.request.contextPath}/chats/send" style="display: flex; gap: 1rem;">
                    <input type="hidden" name="chatId" value="${chat.chatId}">
                    <input type="text" name="message" required placeholder="Type your message..." 
                           style="flex: 1; padding: 0.75rem 1rem; border: 1px solid var(--border); border-radius: 9999px; background: var(--input);">
                    <button type="submit" style="background: var(--primary); color: var(--primary-foreground); padding: 0.75rem 1.5rem; border: none; border-radius: 9999px; font-weight: 600; cursor: pointer;">
                        Send
                    </button>
                </form>
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 1rem;">
            <a href="${pageContext.request.contextPath}/chats" style="color: var(--primary); text-decoration: none; font-weight: 600;">
                ← Back to Chats
            </a>
        </div>
    </div>
    
    <script>
        // Auto-scroll to bottom of messages
        const container = document.getElementById('messagesContainer');
        container.scrollTop = container.scrollHeight;
        
        // Poll for new messages every 5 seconds using AJAX
        let lastMessageCount = ${messages.size()};
        
        setInterval(function() {
            fetch('${pageContext.request.contextPath}/chats/messages?chatId=${chat.chatId}')
                .then(response => response.json())
                .then(data => {
                    if (data.messages && data.messages.length > lastMessageCount) {
                        // New messages available, reload page
                        location.reload();
                    }
                })
                .catch(err => console.error('Error polling messages:', err));
        }, 5000);
    </script>
</body>
</html>
