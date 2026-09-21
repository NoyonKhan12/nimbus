package com.nimbus.driver.domain.repository;

import com.nimbus.driver.domain.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Repository for vehicle operations.
 */
@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, UUID> {
}
