package com.nimbus.kernel.domain.repository;

import com.nimbus.kernel.domain.entity.UserDevice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for user device operations.
 */
@Repository
public interface UserDeviceRepository extends JpaRepository<UserDevice, UUID> {
    List<UserDevice> findByUserId(UUID userId);
    Optional<UserDevice> findByUserIdAndDeviceId(UUID userId, String deviceId);
    Optional<UserDevice> findByPushToken(String pushToken);
    void deleteByDeviceId(String deviceId);
}