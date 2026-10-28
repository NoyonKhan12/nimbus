package com.nimbus.driver.domain.repository;

import com.nimbus.driver.domain.entity.Vehicle;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Repository for vehicle operations.
 */
@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, UUID> {

    List<Vehicle> findByDriverId(UUID driverId);

    Page<Vehicle> findByStatus(Vehicle.VehicleStatus status, Pageable pageable);
}
