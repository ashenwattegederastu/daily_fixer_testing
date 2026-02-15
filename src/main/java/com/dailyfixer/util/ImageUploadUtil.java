package com.dailyfixer.util;

import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * Utility class for handling guide image uploads.
 * Stores images in assets/images/uploads/guides/
 */
public class ImageUploadUtil {

    private static final String UPLOAD_DIR = "assets/images/uploads/guides";

    /**
     * Saves the main image for a guide.
     * 
     * @param imagePart  The uploaded file part
     * @param guideId    The guide ID
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved image (for storing in DB)
     */
    public static String saveGuideMainImage(Part imagePart, int guideId, String webAppPath) throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }

        String fileName = "main_" + guideId + "_" + System.currentTimeMillis() + getExtension(imagePart);
        String relativePath = UPLOAD_DIR + "/" + fileName;

        saveFile(imagePart, webAppPath, relativePath);
        return relativePath;
    }

    /**
     * Saves a step image.
     * 
     * @param imagePart  The uploaded file part
     * @param stepId     The step ID
     * @param imageIndex The index of the image within the step
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved image
     */
    public static String saveStepImage(Part imagePart, int stepId, int imageIndex, String webAppPath)
            throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }

        String fileName = "step_" + stepId + "_" + imageIndex + "_" + System.currentTimeMillis()
                + getExtension(imagePart);
        String relativePath = UPLOAD_DIR + "/" + fileName;

        saveFile(imagePart, webAppPath, relativePath);
        return relativePath;
    }

    /**
     * Saves a temporary image during guide creation (before guide ID is known).
     * 
     * @param imagePart  The uploaded file part
     * @param prefix     A prefix like "temp_main" or "temp_step_0_0"
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved image
     */
    public static String saveTempImage(Part imagePart, String prefix, String webAppPath) throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }

        String fileName = prefix + "_" + System.currentTimeMillis() + getExtension(imagePart);
        String relativePath = UPLOAD_DIR + "/" + fileName;

        saveFile(imagePart, webAppPath, relativePath);
        return relativePath;
    }

    /**
     * Deletes an image file.
     * 
     * @param imagePath  The relative path to the image
     * @param webAppPath The absolute path to the webapp directory
     */
    public static void deleteImage(String imagePath, String webAppPath) {
        if (imagePath == null || imagePath.isEmpty()) {
            return;
        }

        try {
            Path fullPath = Paths.get(webAppPath, imagePath);
            Files.deleteIfExists(fullPath);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void saveFile(Part imagePart, String webAppPath, String relativePath) throws IOException {
        Path uploadPath = Paths.get(webAppPath, UPLOAD_DIR);

        // Create directory if it doesn't exist
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        Path filePath = Paths.get(webAppPath, relativePath);

        try (InputStream input = imagePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private static String getExtension(Part part) {
        String submittedFileName = part.getSubmittedFileName();
        if (submittedFileName != null && submittedFileName.contains(".")) {
            return submittedFileName.substring(submittedFileName.lastIndexOf("."));
        }

        // Default to .jpg if no extension found
        String contentType = part.getContentType();
        if (contentType != null) {
            if (contentType.contains("png"))
                return ".png";
            if (contentType.contains("gif"))
                return ".gif";
            if (contentType.contains("webp"))
                return ".webp";
        }
        return ".jpg";
    }
}
