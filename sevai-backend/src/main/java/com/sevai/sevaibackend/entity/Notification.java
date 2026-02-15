package com.sevai.sevaibackend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "doctor_id")
    private Doctor doctor;

    private String title;
    private String message;
    private String type; // APPOINTMENT, MEDICATION, EMERGENCY, GENERAL, ACCEPTANCE, REJECTION
    private boolean isRead;
    private LocalDateTime createdAt;
    private Long appointmentId;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
