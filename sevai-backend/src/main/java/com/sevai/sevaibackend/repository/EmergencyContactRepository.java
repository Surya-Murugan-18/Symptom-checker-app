package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.EmergencyContact;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
public interface EmergencyContactRepository
        extends JpaRepository<EmergencyContact, Long> {

    List<EmergencyContact> findByUserId(Long userId);

    Optional<EmergencyContact> findByUserIdAndPhone(Long userId, String phone);
}

