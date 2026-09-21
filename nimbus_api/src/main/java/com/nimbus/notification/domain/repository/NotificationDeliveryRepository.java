package com.nimbus.notification.domain.repository;

import com.nimbus.notification.domain.entity.NotificationDelivery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface NotificationDeliveryRepository extends JpaRepository<NotificationDelivery, UUID> {
    List<NotificationDelivery> findByDeliveryStatusIn(
            List<NotificationDelivery.DeliveryStatus> statuses);
}
