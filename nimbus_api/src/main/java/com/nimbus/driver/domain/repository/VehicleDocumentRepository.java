package com.nimbus.driver.domain.repository;

import com.nimbus.driver.domain.entity.VehicleDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface VehicleDocumentRepository extends JpaRepository<VehicleDocument, UUID> {
    List<VehicleDocument> findByVehicleId(UUID vehicleId);
    boolean existsByVehicleIdAndVerifiedTrue(UUID vehicleId);
}
