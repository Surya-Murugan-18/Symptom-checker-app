package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    List<Appointment> findByPatientId(Long patientId);

    List<Appointment> findByDoctorId(Long doctorId);

    List<Appointment> findByPatientIdAndStatus(Long patientId, String status);

    List<Appointment> findByDoctorIdAndDate(Long doctorId, String date);

    long countByDoctorIdAndStatus(Long doctorId, String status);

    long countByDoctorIdAndDate(Long doctorId, String date);
}
