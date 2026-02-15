package com.sevai.sevaibackend.entity;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Medication {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    private String name;
    private String dosage;
    private String frequency; // DAILY, TWICE_DAILY, WEEKLY
    private String startDate;
    private String endDate;
    private String timeSlots; // "08:00,14:00,20:00"
    @JsonProperty("isActive")
    private boolean isActive;
    private String notes;
    private String type; // TABLET, CAPSULE, SYRUP, INJECTION

    // Pill Inventory Tracking
    private Integer pillsTotal; // Total pills when refilled (e.g., 30)
    private Integer pillsRemaining; // Decrements each time "Taken" is pressed
    private Integer refillThreshold; // Alert when pillsRemaining <= this (e.g., 5)

    // Adherence Tracking
    private Integer dosesTaken; // Total doses marked as taken
    private Integer dosesMissed; // Total doses skipped/missed
    private Integer dosesSkipped; // Total doses deliberately skipped
}
