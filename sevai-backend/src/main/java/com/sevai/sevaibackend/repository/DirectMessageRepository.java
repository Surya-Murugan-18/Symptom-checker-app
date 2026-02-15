package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.DirectMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DirectMessageRepository extends JpaRepository<DirectMessage, Long> {

    // Fetch conversation between user and doctor, ordered by timestamp
    List<DirectMessage> findByUserIdAndDoctorIdOrderByTimestampAsc(Long userId, Long doctorId);

    @org.springframework.data.jpa.repository.Query("SELECT DISTINCT m.doctorId FROM DirectMessage m WHERE m.userId = :userId")
    List<Long> findDoctorIdsByUserId(Long userId);

    @org.springframework.data.jpa.repository.Query("SELECT DISTINCT m.userId FROM DirectMessage m WHERE m.doctorId = :doctorId")
    List<Long> findUserIdsByDoctorId(Long doctorId);
}
