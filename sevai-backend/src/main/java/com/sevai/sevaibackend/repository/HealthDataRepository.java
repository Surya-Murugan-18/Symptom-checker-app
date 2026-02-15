package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.HealthData;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface HealthDataRepository extends JpaRepository<HealthData, Long> {
    Optional<HealthData> findFirstByEmailOrderByTimestampDesc(String email);
}
