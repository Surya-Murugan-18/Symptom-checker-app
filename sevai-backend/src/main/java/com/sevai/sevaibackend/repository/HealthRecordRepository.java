package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.HealthRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface HealthRecordRepository extends JpaRepository<HealthRecord, Long> {
    List<HealthRecord> findByUserIdOrderByRecordedAtDesc(Long userId);

    List<HealthRecord> findByUserIdAndTypeOrderByRecordedAtDesc(Long userId, String type);
}
