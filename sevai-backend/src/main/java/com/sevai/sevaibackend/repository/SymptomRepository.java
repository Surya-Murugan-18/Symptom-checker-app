package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.Symptom;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface SymptomRepository extends JpaRepository<Symptom, Long> {
    Optional<Symptom> findByName(String name);
}
