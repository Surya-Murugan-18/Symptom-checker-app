package com.sevai.sevaibackend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Appointment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private User patient;

    @ManyToOne
    @JoinColumn(name = "doctor_id")
    private Doctor doctor;

    private String date; // e.g. "2026-02-15"
    private String time; // e.g. "10:30 AM"
    private String status; // PENDING, ACCEPTED, REJECTED, PAID, COMPLETED, CANCELLED
    private String notes;
    private String reason;
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean paid;
    private String paymentId;

    // PERSONAL REMINDER FIELDS
    private String doctorName; // For external doctors
    private String location;
    private String type;
    @Column(columnDefinition = "boolean default false")
    private boolean isPersonal;
}
