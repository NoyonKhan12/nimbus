package com.nimbus.complaint.application.service;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.complaint.application.ComplaintRequest;
import com.nimbus.complaint.domain.entity.Complaint;
import com.nimbus.complaint.domain.repository.ComplaintRepository;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;

/**
 * Complaint management service.
 *
 * <p>Complaints are submitted by users and reviewed by support/operations.
 * Each complaint has an audit trail of status changes.</p>
 */
@Service
@RequiredArgsConstructor
@Transactional
public class ComplaintService {

    private final ComplaintRepository complaintRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final com.nimbus.audit.application.service.AuditService auditService;
    private final com.nimbus.notification.application.service.NotificationService notificationService;

    /**
     * Submit a complaint.
     */
    public void createComplaint(UUID userId, ComplaintRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Validate category
        Complaint.ComplaintCategory category;
        try {
            category = Complaint.ComplaintCategory.valueOf(request.getCategory().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Invalid complaint category", HttpStatus.BAD_REQUEST);
        }

        Booking booking = null;
        if (request.getBookingId() != null) {
            booking = bookingRepository.findById(request.getBookingId())
                    .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));
            boolean isPassenger = booking.getPassenger() != null
                    && booking.getPassenger().getId().equals(userId);
            boolean isDriver = booking.getRide() != null
                    && booking.getRide().getCreator() != null
                    && booking.getRide().getCreator().getId().equals(userId);
            if (!isPassenger && !isDriver) {
                throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
            }
        }

        Complaint complaint = Complaint.builder()
                .booking(booking)
                .user(user)
                .category(category)
                .description(request.getDescription())
                .status(Complaint.ComplaintStatus.OPEN)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        complaintRepository.save(complaint);
    }

    /**
     * Get user's complaints.
     */
    @Transactional(readOnly = true)
    public List<Complaint> getUserComplaints(UUID userId) {
        return complaintRepository.findByUserId(userId);
    }

    /**
     * Get a specific complaint. Only the complainant or staff can read it.
     */
    @Transactional(readOnly = true)
    public Complaint getComplaint(UUID complaintId, UUID userId, boolean staff) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));
        if (!staff && (complaint.getUser() == null
                || !complaint.getUser().getId().equals(userId))) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }
        return complaint;
    }

    /**
     * Update complaint status (admin/support only). Every resolution change
     * is audited (guide §19/§20) and the complainant is notified.
     */
    public void updateComplaintStatus(UUID complaintId, Complaint.ComplaintStatus status, String resolution) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));

        String oldStatus = complaint.getStatus() != null ? complaint.getStatus().name() : null;
        complaint.updateStatus(status, resolution);
        complaintRepository.save(complaint);

        UUID actorId = currentUserIdOrNull();
        auditService.logAction(actorId, "COMPLAINT_STATUS_CHANGED", "COMPLAINT", complaintId,
                "status=" + oldStatus, "status=" + status.name());

        try {
            notificationService.sendNotification(complaint.getUser().getId(),
                    com.nimbus.notification.domain.entity.Notification.NotificationType.COMPLAINT_STATUS,
                    "Complaint update",
                    "Your complaint status is now " + status.name() + ".",
                    java.util.Map.of("complaintId", complaintId.toString(),
                            "status", status.name()));
        } catch (Exception e) {
            org.slf4j.LoggerFactory.getLogger(ComplaintService.class)
                    .warn("Complaint notification failed: {}", e.getMessage());
        }
    }

    private UUID currentUserIdOrNull() {
        var auth = org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return token.getUserId();
        }
        return null;
    }

    /**
     * List all open complaints (admin support).
     */
    @Transactional(readOnly = true)
    public List<Complaint> getOpenComplaints() {
        return complaintRepository.findByStatus(Complaint.ComplaintStatus.OPEN);
    }

    /** Complaints by status (admin operations, guide §20). */
    @Transactional(readOnly = true)
    public List<Complaint> getComplaintsByStatus(Complaint.ComplaintStatus status) {
        return complaintRepository.findByStatus(status);
    }

    /** All complaints (admin operations, guide §20). */
    @Transactional(readOnly = true)
    public List<Complaint> getAllComplaints() {
        return complaintRepository.findAll();
    }
}
