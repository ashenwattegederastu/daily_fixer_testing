package com.dailyfixer.util;

/**
 * Utility class for converting color names to hex codes.
 * Extracted from JSP to follow separation of concerns.
 */
public class ColorHelper {
    
    /**
     * Converts a color name to its hex code representation.
     * @param colorName The name of the color (e.g., "red", "blue")
     * @return The hex code for the color (e.g., "#ff0000" for red)
     */
    public static String getColorCode(String colorName) {
        if (colorName == null) return "#cccccc";
        String color = colorName.toLowerCase().trim();
        
        switch (color) {
            case "red": return "#ff0000";
            case "blue": return "#0000ff";
            case "green": return "#00ff00";
            case "yellow": return "#ffff00";
            case "black": return "#000000";
            case "white": return "#ffffff";
            case "gray": case "grey": return "#808080";
            case "orange": return "#ffa500";
            case "purple": return "#800080";
            case "pink": return "#ffc0cb";
            case "brown": return "#a52a2a";
            case "navy": return "#000080";
            case "teal": return "#008080";
            case "cyan": return "#00ffff";
            case "magenta": return "#ff00ff";
            case "lime": return "#00ff00";
            case "maroon": return "#800000";
            case "olive": return "#808000";
            case "silver": return "#c0c0c0";
            case "gold": return "#ffd700";
            default: 
                // Try to parse as hex color if it starts with #
                if (color.startsWith("#") && color.length() == 7) {
                    return color;
                }
                // Default gray for unknown colors
                return "#cccccc";
        }
    }
}
