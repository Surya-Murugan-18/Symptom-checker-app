package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.Doctor;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface DoctorRepository extends JpaRepository<Doctor, Long> {
    Optional<Doctor> findByEmail(String email);

    List<Doctor> findBySpecializationContainingIgnoreCase(String specialization);

    List<Doctor> findByLocationContainingIgnoreCase(String location);

    List<Doctor> findTop10ByOrderByRatingDesc();

    List<Doctor> findByIsVerifiedTrue();

    List<Doctor> findByIsVerifiedTrueAndSpecializationContainingIgnoreCase(String specialization);

    @org.springframework.data.jpa.repository.Query("SELECT d FROM Doctor d WHERE d.isVerified = true AND (LOWER(d.firstName) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(d.lastName) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(d.specialization) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<Doctor> searchVerifiedDoctors(@org.springframework.data.repository.query.Param("query") String query);

    @org.springframework.data.jpa.repository.Query("SELECT DISTINCT d.specialization FROM Doctor d WHERE d.isVerified = true AND d.specialization IS NOT NULL")
    List<String> findDistinctSpecializations();
}
