package com.dailyfixer.util;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for ColorHelper utility class.
 */
public class ColorHelperTest {
    
    @Test
    public void testBasicColorConversion() {
        assertEquals("#ff0000", ColorHelper.getColorCode("red"));
        assertEquals("#0000ff", ColorHelper.getColorCode("blue"));
        assertEquals("#00ff00", ColorHelper.getColorCode("green"));
        assertEquals("#ffff00", ColorHelper.getColorCode("yellow"));
        assertEquals("#000000", ColorHelper.getColorCode("black"));
        assertEquals("#ffffff", ColorHelper.getColorCode("white"));
    }
    
    @Test
    public void testCaseInsensitivity() {
        assertEquals("#ff0000", ColorHelper.getColorCode("RED"));
        assertEquals("#0000ff", ColorHelper.getColorCode("Blue"));
        assertEquals("#00ff00", ColorHelper.getColorCode("GREEN"));
        assertEquals("#ffa500", ColorHelper.getColorCode("OrAnGe"));
    }
    
    @Test
    public void testGrayVariants() {
        assertEquals("#808080", ColorHelper.getColorCode("gray"));
        assertEquals("#808080", ColorHelper.getColorCode("grey"));
        assertEquals("#808080", ColorHelper.getColorCode("GRAY"));
        assertEquals("#808080", ColorHelper.getColorCode("GREY"));
    }
    
    @Test
    public void testExtendedColors() {
        assertEquals("#ffa500", ColorHelper.getColorCode("orange"));
        assertEquals("#800080", ColorHelper.getColorCode("purple"));
        assertEquals("#ffc0cb", ColorHelper.getColorCode("pink"));
        assertEquals("#a52a2a", ColorHelper.getColorCode("brown"));
        assertEquals("#000080", ColorHelper.getColorCode("navy"));
        assertEquals("#008080", ColorHelper.getColorCode("teal"));
        assertEquals("#00ffff", ColorHelper.getColorCode("cyan"));
        assertEquals("#ff00ff", ColorHelper.getColorCode("magenta"));
        assertEquals("#00ff00", ColorHelper.getColorCode("lime"));
        assertEquals("#800000", ColorHelper.getColorCode("maroon"));
        assertEquals("#808000", ColorHelper.getColorCode("olive"));
        assertEquals("#c0c0c0", ColorHelper.getColorCode("silver"));
        assertEquals("#ffd700", ColorHelper.getColorCode("gold"));
    }
    
    @Test
    public void testHexColorPassthrough() {
        assertEquals("#abc123", ColorHelper.getColorCode("#abc123"));
        assertEquals("#abcdef", ColorHelper.getColorCode("#ABCDEF")); // Converted to lowercase
        assertEquals("#123456", ColorHelper.getColorCode("#123456"));
    }
    
    @Test
    public void testInvalidHexColors() {
        // Invalid hex colors should return default gray
        assertEquals("#cccccc", ColorHelper.getColorCode("#abc")); // too short
        assertEquals("#cccccc", ColorHelper.getColorCode("#abcdefgh")); // too long
        assertEquals("#cccccc", ColorHelper.getColorCode("abc123")); // missing #
    }
    
    @Test
    public void testUnknownColors() {
        assertEquals("#cccccc", ColorHelper.getColorCode("unknown"));
        assertEquals("#cccccc", ColorHelper.getColorCode("notacolor"));
        assertEquals("#cccccc", ColorHelper.getColorCode("random"));
    }
    
    @Test
    public void testNullAndEmpty() {
        assertEquals("#cccccc", ColorHelper.getColorCode(null));
        assertEquals("#cccccc", ColorHelper.getColorCode(""));
        assertEquals("#cccccc", ColorHelper.getColorCode("   ")); // whitespace only
    }
    
    @Test
    public void testWhitespaceHandling() {
        assertEquals("#ff0000", ColorHelper.getColorCode("  red  "));
        assertEquals("#0000ff", ColorHelper.getColorCode(" blue "));
        assertEquals("#00ff00", ColorHelper.getColorCode("green   "));
    }
}
