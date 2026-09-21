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
     * Get a specific complaint (admin/support only).
     */
    @Transactional(readOnly = true)
    public Complaint getComplaint(UUID complaintId) {
        return complaintRepository.findById(complaintId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));
    }

    /**
     * Update complaint status (admin/support only).
     */
    public void updateComplaintStatus(UUID complaintId, Complaint.ComplaintStatus status, String resolution) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));

        complaint.updateStatus(status, resolution);
        complaintRepository.save(complaint);
    }

    /**
     * List all open complaints (admin support).
     */
    @Transactional(readOnly = true)
    public List<Complaint> getOpenComplaints() {
        return complaintRepository.findByStatus(Complaint.ComplaintStatus.OPEN);
    }
}
