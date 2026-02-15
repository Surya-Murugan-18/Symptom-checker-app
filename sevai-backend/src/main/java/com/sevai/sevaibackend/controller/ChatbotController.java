package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.service.EnhancedChatbotService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChatbotController {

    private final EnhancedChatbotService chatbotService;

    @PostMapping("/message")
    public ResponseEntity<Map<String, Object>> handleMessage(@RequestBody Map<String, String> request) {
        String sessionId = request.get("sessionId");
        String userId = request.get("userId");
        String message = request.get("message");
        String language = request.get("language");

        Map<String, Object> response = chatbotService.processMessage(sessionId, userId, message, language);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of(
                "status", "healthy",
                "service", "SEV-AI Chatbot",
                "version", "1.0.0"));
    }
}
