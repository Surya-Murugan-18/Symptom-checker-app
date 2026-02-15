package com.sevai.sevaibackend.entity;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Doctor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String firstName;
    private String lastName;
    private String email;
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;
    private String specialization;
    private String qualification;
    private Integer experienceYears;
    private String hospital;
    private Double consultationFee;
    private double rating;
    private String phone;
    @Column(columnDefinition = "TEXT")
    private String photoUrl;
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean isVerified;
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean isOnline;
    private String gender;
    private String location;
}
