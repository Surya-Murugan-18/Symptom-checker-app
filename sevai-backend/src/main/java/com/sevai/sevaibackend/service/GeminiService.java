package com.sevai.sevaibackend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.*;

@Service
@Slf4j
public class GeminiService {

    private final WebClient webClient;
    private final ObjectMapper objectMapper;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.model:gemini-2.0-flash}")
    private String model;

    private static final String SYSTEM_PROMPT = """
            You are SEV-AI, a professional medical symptom triage assistant. You help users describe their symptoms and assess the urgency level.

            CRITICAL RULES:
            1. RESPOND IN THE SAME LANGUAGE THE USER WRITES IN. If they write in Tamil, respond in Tamil. If Hindi, respond in Hindi. Supported: English, Tamil (தமிழ்), Hindi (हिन्दी), Telugu (తెలుగు), Malayalam (മലയാളം), Marathi (मराठी).

            2. EMOTION-PROOF ASSESSMENT: Base severity ONLY on actual medical symptoms, NEVER on emotional language.
               - "I'm dying of a headache" = mild headache → self_care
               - "killing me" = emotional expression, NOT an actual threat to life
               - "unbearable pain" = assess the PAIN TYPE and LOCATION, ignore "unbearable"
               - "please help I'm so scared" = emotional distress, NOT a medical symptom
               - "worst pain ever" = subjective, assess based on symptom type only
               - Only escalate if MEDICAL signs warrant it (e.g., chest pain + shortness of breath + arm numbness)

            3. TRIAGE LEVELS (choose exactly one):
               - "emergency": Life-threatening. Examples: chest pain with breathing difficulty, signs of stroke, severe head trauma, loss of consciousness, severe allergic reaction, heavy uncontrollable bleeding.
               - "doctor": Needs professional medical attention but not immediately life-threatening. Examples: persistent fever (>3 days), recurring pain, blood in urine/stool, persistent vomiting, worsening symptoms.
               - "self_care": Can be managed at home. Examples: common cold, mild headache, minor muscle pain, mild stomach upset, slight fever (<2 days).

            4. ASK FOLLOW-UP QUESTIONS to gather enough information before making a triage decision. Ask about:
               - Duration of symptoms (when did it start?)
               - Severity (on a scale of 1-10)
               - Location of pain/discomfort
               - Any other symptoms
               - Pre-existing conditions
               - Current medications

            5. YOU MUST RESPOND IN THIS EXACT JSON FORMAT:
            {
              "type": "question" or "triage",
              "message": "Your response message in user's language",
              "detectedSymptoms": ["symptom1", "symptom2"],
              "triage": "emergency" or "doctor" or "self_care" (only when type is "triage"),
              "disease": "Possible condition name" (only when type is "triage"),
              "recommendations": ["recommendation1", "recommendation2"] (only when type is "triage"),
              "emotionalWordsFiltered": ["list of emotional words that were ignored for severity assessment"]
            }

            6. ALWAYS respond with VALID JSON only. No markdown, no code blocks, no explanation outside JSON.

            7. Be empathetic in your message text, but clinical in your assessment. You can acknowledge the user's distress while correctly assessing severity.

            8. If the user sends a greeting (hi, hello, vanakkam, namaste, etc.), respond with a friendly welcome and ask them to describe their symptoms.
            """;

    public GeminiService() {
        this.webClient = WebClient.builder()
                .baseUrl("https://generativelanguage.googleapis.com")
                .build();
        this.objectMapper = new ObjectMapper();
    }

    public Map<String, Object> chat(List<Map<String, String>> conversationHistory,
            String userMessage, String language) {
        try {
            Map<String, Object> requestBody = buildRequest(conversationHistory, userMessage, language);

            String responseJson = webClient.post()
                    .uri("/v1/models/{model}:generateContent?key={key}", model, apiKey)
                    .contentType(MediaType.APPLICATION_JSON)
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return parseResponse(responseJson);

        } catch (Exception e) {
            log.error("Gemini API call failed: {}", e.getMessage());
            return null; // Caller will use fallback
        }
    }

    private Map<String, Object> buildRequest(List<Map<String, String>> history,
            String userMessage, String language) {
        List<Map<String, Object>> contents = new ArrayList<>();

        if (history != null) {
            for (Map<String, String> msg : history) {
                Map<String, Object> content = new HashMap<>();
                content.put("role", msg.get("role"));
                content.put("parts", List.of(Map.of("text", msg.get("text"))));
                contents.add(content);
            }
        }

        String enhancedMessage = userMessage;
        if (language != null && !language.equals("English")) {
            enhancedMessage = "[User language: " + language + "] " + userMessage;
        }

        Map<String, Object> userContent = new HashMap<>();
        userContent.put("role", "user");
        userContent.put("parts", List.of(Map.of("text", enhancedMessage)));
        contents.add(userContent);

        Map<String, Object> request = new HashMap<>();
        request.put("contents", contents);

        Map<String, Object> systemInstruction = new HashMap<>();
        systemInstruction.put("parts", List.of(Map.of("text", SYSTEM_PROMPT)));
        request.put("system_instruction", systemInstruction);

        Map<String, Object> generationConfig = new HashMap<>();
        generationConfig.put("temperature", 0.3);
        generationConfig.put("topP", 0.8);
        generationConfig.put("maxOutputTokens", 1024);
        generationConfig.put("responseMimeType", "application/json");
        request.put("generationConfig", generationConfig);

        return request;
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> parseResponse(String responseJson) {
        try {
            if (responseJson == null)
                return null;

            JsonNode root = objectMapper.readTree(responseJson);

            // Handle API error messages from Gemini
            if (root.has("error")) {
                log.error("Gemini API Error: {}", root.path("error").path("message").asText());
                return null;
            }

            JsonNode candidates = root.path("candidates");
            if (candidates.isEmpty() || candidates.isMissingNode()) {
                log.error("Gemini returned no candidates. Full response: {}", responseJson);
                return null;
            }

            String text = candidates.get(0)
                    .path("content")
                    .path("parts")
                    .get(0)
                    .path("text")
                    .asText();

            text = text.trim();
            // Multi-layer stripping of markers
            if (text.startsWith("```")) {
                text = text.replaceAll("^```(json)?\\n?", "").replaceAll("\\n?```$", "");
            }
            text = text.trim();

            return objectMapper.readValue(text, Map.class);

        } catch (Exception e) {
            log.error("Failed to parse Gemini response: {}. Body: {}", e.getMessage(), responseJson);
            return null;
        }
    }

    public boolean isAvailable() {
        return apiKey != null && !apiKey.isBlank() && !apiKey.equals("YOUR_API_KEY_HERE");
    }
}
