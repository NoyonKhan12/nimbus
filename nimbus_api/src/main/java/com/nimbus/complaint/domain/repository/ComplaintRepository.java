package com.nimbus.complaint.domain.repository;

import com.nimbus.complaint.domain.entity.Complaint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, UUID> {
    List<Complaint> findByUserId(UUID userId);
    List<Complaint> findByStatus(Complaint.ComplaintStatus status);
    Optional<Complaint> findByBookingId(UUID bookingId);
}
