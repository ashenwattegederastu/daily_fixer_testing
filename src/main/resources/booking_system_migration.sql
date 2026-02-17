-- ============================================================================
-- DailyFixer Booking System Migration
-- ============================================================================
-- This migration adds tables for:
-- 1. Technician Availability Management
-- 2. Booking System with Status Flow
-- 3. Cancellation Tracking
-- 4. Chat/Messaging System
-- ============================================================================

USE df_testing;

-- ============================================================================
-- 1. TECHNICIAN AVAILABILITY TABLE
-- ============================================================================
DROP TABLE IF EXISTS `technician_availability`;
CREATE TABLE `technician_availability` (
  `availability_id` INT NOT NULL AUTO_INCREMENT,
  `technician_id` INT NOT NULL,
  `availability_mode` ENUM('WEEKDAYS', 'WEEKENDS', 'CUSTOM') NOT NULL DEFAULT 'WEEKDAYS',
  `monday` TINYINT(1) DEFAULT 0,
  `tuesday` TINYINT(1) DEFAULT 0,
  `wednesday` TINYINT(1) DEFAULT 0,
  `thursday` TINYINT(1) DEFAULT 0,
  `friday` TINYINT(1) DEFAULT 0,
  `saturday` TINYINT(1) DEFAULT 0,
  `sunday` TINYINT(1) DEFAULT 0,
  `start_time` TIME NOT NULL DEFAULT '09:00:00',
  `end_time` TIME NOT NULL DEFAULT '17:00:00',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`availability_id`),
  UNIQUE KEY `unique_technician` (`technician_id`),
  CONSTRAINT `fk_availability_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 2. BOOKINGS TABLE
-- ============================================================================
DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings` (
  `booking_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `technician_id` INT NOT NULL,
  `service_id` INT NOT NULL,
  `booking_date` DATE NOT NULL,
  `booking_time` TIME NOT NULL,
  `phone_number` VARCHAR(20) NOT NULL,
  `problem_description` TEXT,
  `location_address` VARCHAR(500),
  `location_latitude` DECIMAL(9, 6),
  `location_longitude` DECIMAL(9, 6),
  `status` ENUM('REQUESTED', 'ACCEPTED', 'REJECTED', 'CANCELLED', 'TECHNICIAN_COMPLETED', 'FULLY_COMPLETED') NOT NULL DEFAULT 'REQUESTED',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`booking_id`),
  KEY `idx_bookings_user` (`user_id`),
  KEY `idx_bookings_technician` (`technician_id`),
  KEY `idx_bookings_service` (`service_id`),
  KEY `idx_bookings_status` (`status`),
  KEY `idx_bookings_date` (`booking_date`),
  CONSTRAINT `fk_bookings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bookings_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bookings_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 3. BOOKING CANCELLATIONS TABLE
-- ============================================================================
DROP TABLE IF EXISTS `booking_cancellations`;
CREATE TABLE `booking_cancellations` (
  `cancellation_id` INT NOT NULL AUTO_INCREMENT,
  `booking_id` INT NOT NULL,
  `cancelled_by` INT NOT NULL,
  `cancellation_reason` TEXT NOT NULL,
  `cancelled_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`cancellation_id`),
  KEY `idx_cancellations_booking` (`booking_id`),
  KEY `idx_cancellations_user` (`cancelled_by`),
  CONSTRAINT `fk_cancellations_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cancellations_user` FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 4. CHAT CONVERSATIONS TABLE
-- ============================================================================
DROP TABLE IF EXISTS `chat_conversations`;
CREATE TABLE `chat_conversations` (
  `conversation_id` INT NOT NULL AUTO_INCREMENT,
  `booking_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `technician_id` INT NOT NULL,
  `last_message_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation_id`),
  UNIQUE KEY `unique_booking_conversation` (`booking_id`),
  KEY `idx_conversations_user` (`user_id`),
  KEY `idx_conversations_technician` (`technician_id`),
  CONSTRAINT `fk_conversations_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversations_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversations_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 5. CHAT MESSAGES TABLE
-- ============================================================================
DROP TABLE IF EXISTS `chat_messages`;
CREATE TABLE `chat_messages` (
  `message_id` INT NOT NULL AUTO_INCREMENT,
  `conversation_id` INT NOT NULL,
  `sender_id` INT NOT NULL,
  `message_text` TEXT NOT NULL,
  `is_read` TINYINT(1) DEFAULT 0,
  `sent_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `idx_messages_conversation` (`conversation_id`),
  KEY `idx_messages_sender` (`sender_id`),
  KEY `idx_messages_read` (`is_read`),
  KEY `idx_messages_sent` (`sent_at`),
  CONSTRAINT `fk_messages_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversations` (`conversation_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Composite index for booking queries
CREATE INDEX `idx_bookings_tech_status` ON `bookings` (`technician_id`, `status`);
CREATE INDEX `idx_bookings_user_status` ON `bookings` (`user_id`, `status`);

-- Index for unread message counts
CREATE INDEX `idx_messages_unread` ON `chat_messages` (`conversation_id`, `is_read`);

-- ============================================================================
-- INITIAL DATA (Optional)
-- ============================================================================

-- Set default availability for existing technicians (Weekdays 9 AM - 5 PM)
INSERT INTO `technician_availability` (`technician_id`, `availability_mode`, `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `start_time`, `end_time`)
SELECT `user_id`, 'WEEKDAYS', 1, 1, 1, 1, 1, '09:00:00', '17:00:00'
FROM `users`
WHERE `role` = 'technician'
ON DUPLICATE KEY UPDATE `availability_id` = `availability_id`;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
