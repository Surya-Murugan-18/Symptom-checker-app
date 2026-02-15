package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findTop50ByUserIdOrderByCreatedAtDesc(Long userId);

    List<Notification> findByUserIdAndIsReadFalse(Long userId);

    List<Notification> findTop50ByDoctorIdOrderByCreatedAtDesc(Long doctorId);

    List<Notification> findByDoctorIdAndIsReadFalse(Long doctorId);
}
