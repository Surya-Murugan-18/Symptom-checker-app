package com.sevai.sevaibackend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AppointmentSlot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long doctorId;
    private String date; // e.g. "2026-02-15"
    private String startTime; // e.g. "09:00 AM"
    private String endTime; // e.g. "09:30 AM"
    private boolean isAvailable;
}
