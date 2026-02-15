package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.Hospital;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface HospitalRepository extends JpaRepository<Hospital, Long> {
    List<Hospital> findByType(String type);

    List<Hospital> findByNameContainingIgnoreCase(String name);
}
