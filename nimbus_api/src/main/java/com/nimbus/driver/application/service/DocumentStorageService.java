package com.nimbus.driver.application.service;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;
import java.util.UUID;

/**
 * Stores driver/vehicle document uploads outside the web root.
 *
 * <p>The returned key is opaque and generated server-side; the original
 * filename is never used on disk. Files are served only through an
 * authenticated controller that checks document ownership. For production
 * deployments this class can be replaced by an S3/GCS adapter without
 * changing the document metadata contract.</p>
 */
@Service
@Slf4j
public class DocumentStorageService {

    private final Path root;
    private final long maxBytes;

    public DocumentStorageService(
            @Value("${app.upload.dir:./data/uploads}") String uploadDir,
            @Value("${app.upload.max-document-bytes:10485760}") long maxBytes) {
        this.root = Path.of(uploadDir).toAbsolutePath().normalize().resolve("documents");
        this.maxBytes = maxBytes;
    }

    /** Stores a validated upload and returns its opaque key. */
    public StoredDocument store(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new NimbusException(ErrorCode.BAD_REQUEST,
                    "Document file is required", HttpStatus.BAD_REQUEST);
        }
        if (file.getSize() > maxBytes) {
            throw new NimbusException(ErrorCode.BAD_REQUEST,
                    "Document must be " + (maxBytes / (1024 * 1024)) + " MB or smaller",
                    HttpStatus.BAD_REQUEST);
        }

        byte[] header;
        try (InputStream in = file.getInputStream()) {
            header = in.readNBytes(16);
        } catch (IOException e) {
            throw new NimbusException(ErrorCode.BAD_REQUEST,
                    "Could not read the uploaded file", HttpStatus.BAD_REQUEST);
        }
        DetectedType type = detectType(header);
        if (type == null) {
            throw new NimbusException(ErrorCode.BAD_REQUEST,
                    "Only JPG, PNG, WebP or PDF documents are allowed",
                    HttpStatus.BAD_REQUEST);
        }

        String key = "doc-" + UUID.randomUUID() + "." + type.extension;
        try {
            Files.createDirectories(root);
            Path target = root.resolve(key).normalize();
            if (!target.startsWith(root)) {
                throw new IOException("Invalid storage path");
            }
            Files.copy(file.getInputStream(), target);
            return new StoredDocument(key, type.contentType);
        } catch (IOException e) {
            log.error("Document upload failed: {}", e.getMessage());
            throw new NimbusException(ErrorCode.INTERNAL_ERROR,
                    "Failed to store document", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /** Loads a previously stored key, rejecting traversal outside the root. */
    public Resource load(String key) {
        if (key == null || key.isBlank()) {
            throw new NimbusException(ErrorCode.NOT_FOUND,
                    "Document file not found", HttpStatus.NOT_FOUND);
        }
        Path path = root.resolve(key).normalize();
        if (!path.startsWith(root) || !Files.isRegularFile(path)) {
            throw new NimbusException(ErrorCode.NOT_FOUND,
                    "Document file not found", HttpStatus.NOT_FOUND);
        }
        return new FileSystemResource(path);
    }

    /** Content type derived from the stored extension (never user input). */
    public String contentType(String key) {
        String extension = "";
        int dot = key != null ? key.lastIndexOf('.') : -1;
        if (dot >= 0) extension = key.substring(dot + 1).toLowerCase(Locale.ROOT);
        return switch (extension) {
            case "pdf" -> "application/pdf";
            case "png" -> "image/png";
            case "webp" -> "image/webp";
            default -> "image/jpeg";
        };
    }

    /** Best-effort cleanup when the database write fails after storing. */
    public void deleteQuietly(String key) {
        if (key == null || key.isBlank()) return;
        try {
            Files.deleteIfExists(root.resolve(key).normalize());
        } catch (IOException e) {
            log.warn("Could not delete orphaned document {}: {}", key, e.getMessage());
        }
    }

    private DetectedType detectType(byte[] h) {
        if (h.length >= 3 && (h[0] & 0xFF) == 0xFF && (h[1] & 0xFF) == 0xD8
                && (h[2] & 0xFF) == 0xFF) {
            return new DetectedType("jpg", "image/jpeg");
        }
        if (h.length >= 8 && (h[0] & 0xFF) == 0x89 && h[1] == 'P' && h[2] == 'N'
                && h[3] == 'G' && (h[4] & 0xFF) == 0x0D && (h[5] & 0xFF) == 0x0A
                && (h[6] & 0xFF) == 0x1A && (h[7] & 0xFF) == 0x0A) {
            return new DetectedType("png", "image/png");
        }
        if (h.length >= 12 && h[0] == 'R' && h[1] == 'I' && h[2] == 'F' && h[3] == 'F'
                && h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P') {
            return new DetectedType("webp", "image/webp");
        }
        if (h.length >= 4 && h[0] == '%' && h[1] == 'P' && h[2] == 'D' && h[3] == 'F') {
            return new DetectedType("pdf", "application/pdf");
        }
        return null;
    }

    private record DetectedType(String extension, String contentType) {
    }

    public record StoredDocument(String key, String contentType) {
    }
}
