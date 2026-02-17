-- ============================================================================
-- DailyFixer Booking System - Location Coordinate Fix
-- ============================================================================
-- This migration fixes the DECIMAL precision for location coordinates
-- 
-- Problem: DECIMAL(10, 7) was too restrictive and caused data truncation errors
-- Solution: Change to DECIMAL(9, 6) which is the standard for GPS coordinates
-- 
-- DECIMAL(9, 6) provides:
-- - 9 total digits with 6 after decimal point = 3 digits before decimal
-- - Range: -999.999999 to 999.999999
-- - Sufficient for latitude (-90 to 90) and longitude (-180 to 180)
-- - Standard GPS precision of 6 decimal places (≈0.11 meter accuracy)
-- ============================================================================

USE df_testing;

-- Modify the bookings table to fix coordinate precision
ALTER TABLE `bookings` 
  MODIFY COLUMN `location_latitude` DECIMAL(9, 6),
  MODIFY COLUMN `location_longitude` DECIMAL(9, 6);

-- Verify the changes
DESCRIBE bookings;
