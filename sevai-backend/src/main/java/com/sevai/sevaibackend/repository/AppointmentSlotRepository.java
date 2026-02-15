package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.AppointmentSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AppointmentSlotRepository extends JpaRepository<AppointmentSlot, Long> {
    List<AppointmentSlot> findByDoctorIdAndDate(Long doctorId, String date);

    List<AppointmentSlot> findByDoctorIdAndDateAndIsAvailableTrue(Long doctorId, String date);
}
