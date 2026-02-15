package com.sevai.sevaibackend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
public class HealthData {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String email; // Linked to user email
    private Integer heartRate;
    private Integer spo2;
    private Double temperature;
    private Integer steps;
    private Integer respiratoryRate;
    private String status; // e.g., "Normal", "High", "Critical"

    private LocalDateTime timestamp;
}
