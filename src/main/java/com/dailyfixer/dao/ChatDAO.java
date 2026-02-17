package com.dailyfixer.dao;

import com.dailyfixer.model.ChatConversation;
import com.dailyfixer.model.ChatMessage;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    public int createConversation(ChatConversation conversation) throws Exception {
        String sql = "INSERT INTO chat_conversations (booking_id, user_id, technician_id) " +
                     "VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, conversation.getBookingId());
            stmt.setInt(2, conversation.getUserId());
            stmt.setInt(3, conversation.getTechnicianId());

            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public ChatConversation getConversationByBookingId(int bookingId) throws Exception {
        String sql = "SELECT * FROM chat_conversations WHERE booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToConversation(rs);
                }
            }
        }
        return null;
    }

    public ChatConversation getConversationById(int conversationId) throws Exception {
        String sql = "SELECT * FROM chat_conversations WHERE conversation_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, conversationId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToConversation(rs);
                }
            }
        }
        return null;
    }

    public List<ChatConversation> getConversationsByUserId(int userId) throws Exception {
        String sql = "SELECT c.*, " +
                     "(SELECT COUNT(*) FROM chat_messages WHERE conversation_id = c.conversation_id AND sender_id != ? AND is_read = 0) as unread_count, " +
                     "(SELECT message_text FROM chat_messages WHERE conversation_id = c.conversation_id ORDER BY sent_at DESC LIMIT 1) as last_message " +
                     "FROM chat_conversations c " +
                     "WHERE c.user_id = ? OR c.technician_id = ? " +
                     "ORDER BY c.last_message_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.setInt(3, userId);

            List<ChatConversation> conversations = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ChatConversation conv = mapResultSetToConversation(rs);
                    conv.setUnreadCount(rs.getInt("unread_count"));
                    conv.setLastMessageText(rs.getString("last_message"));
                    conversations.add(conv);
                }
            }
            return conversations;
        }
    }

    public int sendMessage(ChatMessage message) throws Exception {
        String sql = "INSERT INTO chat_messages (conversation_id, sender_id, message_text) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, message.getConversationId());
            stmt.setInt(2, message.getSenderId());
            stmt.setString(3, message.getMessageText());

            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public List<ChatMessage> getMessagesByConversationId(int conversationId) throws Exception {
        String sql = "SELECT m.*, u.first_name, u.last_name " +
                     "FROM chat_messages m " +
                     "JOIN users u ON m.sender_id = u.user_id " +
                     "WHERE m.conversation_id = ? " +
                     "ORDER BY m.sent_at ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, conversationId);

            List<ChatMessage> messages = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ChatMessage message = mapResultSetToMessage(rs);
                    message.setSenderName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    messages.add(message);
                }
            }
            return messages;
        }
    }

    public void markMessagesAsRead(int conversationId, int userId) throws Exception {
        String sql = "UPDATE chat_messages SET is_read = 1 " +
                     "WHERE conversation_id = ? AND sender_id != ? AND is_read = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, conversationId);
            stmt.setInt(2, userId);

            stmt.executeUpdate();
        }
    }

    public int getUnreadMessageCount(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM chat_messages m " +
                     "JOIN chat_conversations c ON m.conversation_id = c.conversation_id " +
                     "WHERE (c.user_id = ? OR c.technician_id = ?) AND m.sender_id != ? AND m.is_read = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.setInt(3, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private ChatConversation mapResultSetToConversation(ResultSet rs) throws SQLException {
        ChatConversation conversation = new ChatConversation();
        conversation.setConversationId(rs.getInt("conversation_id"));
        conversation.setBookingId(rs.getInt("booking_id"));
        conversation.setUserId(rs.getInt("user_id"));
        conversation.setTechnicianId(rs.getInt("technician_id"));
        conversation.setLastMessageAt(rs.getTimestamp("last_message_at"));
        conversation.setCreatedAt(rs.getTimestamp("created_at"));
        return conversation;
    }

    private ChatMessage mapResultSetToMessage(ResultSet rs) throws SQLException {
        ChatMessage message = new ChatMessage();
        message.setMessageId(rs.getInt("message_id"));
        message.setConversationId(rs.getInt("conversation_id"));
        message.setSenderId(rs.getInt("sender_id"));
        message.setMessageText(rs.getString("message_text"));
        message.setRead(rs.getBoolean("is_read"));
        message.setSentAt(rs.getTimestamp("sent_at"));
        return message;
    }
}
