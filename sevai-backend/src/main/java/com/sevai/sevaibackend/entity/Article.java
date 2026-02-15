package com.sevai.sevaibackend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Article {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    private String author;
    private String category; // HEALTH_TIPS, NUTRITION, FITNESS, MENTAL_HEALTH, DISEASE_AWARENESS
    private String imageUrl;
    private String publishedDate;
    private int readTimeMinutes;
}
