package com.nimbus.driver.domain.repository;

import com.nimbus.driver.domain.entity.DriverDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface DriverDocumentRepository extends JpaRepository<DriverDocument, UUID> {
    List<DriverDocument> findByDriverId(UUID driverId);
    List<DriverDocument> findByDriverIdAndDocumentType(UUID driverId, DriverDocument.DocumentType documentType);
    boolean existsByDriverIdAndDocumentTypeAndVerifiedTrue(UUID driverId, DriverDocument.DocumentType documentType);
}
