package com.sevai.sevaibackend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatSession {
    @Id
    private String sessionId;

    private String userId;
    private String language;
    private int questionsAskedCount;

    @ElementCollection(fetch = FetchType.EAGER)
    @Builder.Default
    private List<String> detectedSymptoms = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @Builder.Default
    private List<ChatMessage> conversationHistory = new ArrayList<>();

    @Builder.Default
    private boolean assessmentComplete = false;
}
