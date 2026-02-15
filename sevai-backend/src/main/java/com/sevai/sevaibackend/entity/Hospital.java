package com.sevai.sevaibackend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Hospital {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String address;
    private double latitude;
    private double longitude;
    private String phone;
    private String type; // HOSPITAL, CLINIC, PHARMACY
    private double rating;
    private String imageUrl;
    private boolean is24Hours;
    private String specialties;
}
