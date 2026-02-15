package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.Medication;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MedicationRepository extends JpaRepository<Medication, Long> {
    List<Medication> findByUserId(Long userId);

    List<Medication> findByUserIdAndIsActiveTrue(Long userId);

    List<Medication> findByUserIdAndIsActiveFalse(Long userId);
}
