package com.sevai.sevaibackend.service;

import com.sevai.sevaibackend.entity.ChatMessage;
import com.sevai.sevaibackend.entity.ChatSession;
import com.sevai.sevaibackend.entity.Disease;
import com.sevai.sevaibackend.entity.Symptom;
import com.sevai.sevaibackend.repository.ChatSessionRepository;
import com.sevai.sevaibackend.repository.DiseaseRepository;
import com.sevai.sevaibackend.repository.SymptomRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class EnhancedChatbotService {

    private final ChatSessionRepository chatSessionRepository;
    private final DiseaseRepository diseaseRepository;
    private final SymptomRepository symptomRepository;
    private final GeminiService geminiService;

    private static final int MAX_HISTORY = 10;

    // Localization for fallback
    private static final Map<String, Map<String, String>> LOCALIZATION = Map.of(
            "Tamil", Map.of(
                    "greeting",
                    "வணக்கம்! நான் SEV-AI, உங்கள் சுகாதார உதவியாளர். உங்களுக்கு உதவ உங்கள் அறிகுறிகளை விளக்கவும்.",
                    "out_of_scope",
                    "மன்னிக்கவும், நான் ஆரோக்கியம் தொடர்பான கேள்விகளுக்கு மட்டுமே பதிலளிக்க முடியும். உங்கள் அறிகுறிகளை விவரிக்கவும்.",
                    "emergency",
                    "⚠️ அவசர எச்சரிக்கை: உங்கள் அறிகுறிகள் அவசரநிலையைக் குறிக்கின்றன. தயவுசெய்து உடனடியாக மருத்துவ உதவியை நாடவும் அல்லது அவசர சேவைகளை (108) அழைக்கவும்.",
                    "assessment", "உங்கள் அறிகுறிகளின் அடிப்படையில், இது %s ஆக இருக்கலாம்.",
                    "more_info",
                    "எனக்கு இன்னும் கொஞ்சம் தகவல் தேவை. வலி, சோர்வு அல்லது குமட்டல் போன்ற வேறு ஏதேனும் அறிகுறிகளை நீங்கள் கவனித்தீர்களா?",
                    "next_question",
                    "புரிந்துகொண்டேன். நன்றாகப் புரிந்துகொள்ள உதவ, உங்கள் முக்கிய அறிகுறி என்ன மற்றும் அது எப்போது தொடங்கியது என்று விவரிக்க முடியுமா?",
                    "are_you_experiencing", "எனக்குத் தெரிகிறது. உங்களுக்கும் %s இருக்கிறதா?",
                    "any_other_symptoms",
                    "காய்ச்சல் அல்லது வலி போன்ற வேறு ஏதேனும் அறிகுறிகளை நீங்கள் அனுபவிக்கிறீர்களா?"),
            "Hindi", Map.of(
                    "greeting",
                    "नमस्ते! मैं SEV-AI हूँ, आपका स्वास्थ्य सहायक। कृपया अपने लक्षणों का वर्णन करें ताकि मैं आपकी सहायता कर सकूँ।",
                    "out_of_scope",
                    "क्षमा करें, मैं केवल स्वास्थ्य संबंधी प्रश्नों का उत्तर दे सकता हूँ। कृपया अपने लक्षणों का वर्णन करें।",
                    "emergency",
                    "⚠️ आपातकालीन अलर्ट: आपके लक्षण आपातकाल का संकेत देते हैं। कृपया तत्काल चिकित्सा सहायता लें या आपातकालीन सेवाओं (108) को कॉल करें।",
                    "assessment", "आपके लक्षणों के आधार पर, यह %s हो सकता है।",
                    "more_info",
                    "मुझे थोड़ी और जानकारी चाहिए। क्या आपने दर्द, थकान या मतली जैसे किसी अन्य लक्षण पर ध्यान दिया है?",
                    "next_question",
                    "मैं समझ गया। मुझे बेहतर समझने में मदद करने के लिए, क्या आप अपने मुख्य लक्षण का वर्णन कर सकते हैं और यह कब शुरू हुआ?",
                    "are_you_experiencing", "मैं देखता हूँ। क्या आप %s भी अनुभव कर रहे हैं?",
                    "any_other_symptoms", "क्या आप किसी अन्य लक्षण का अनुभव कर रहे हैं, जैसे बुखार या दर्द?"),
            "English", Map.of(
                    "greeting",
                    "Hello! I am SEV-AI, your health assistant. Please describe your symptoms so I can help you.",
                    "out_of_scope",
                    "I apologize, but I can only assist with health-related inquiries. Please describe any medical symptoms you are experiencing.",
                    "emergency",
                    "⚠️ EMERGENCY ALERT: Your symptoms suggest a potential emergency. Please seek immediate medical attention or call emergency services (108).",
                    "assessment", "Based on your symptoms, this could be %s.",
                    "more_info",
                    "I need a bit more information. Have you noticed any other symptoms like pain, fatigue, or nausea?",
                    "next_question",
                    "I understand. To help me understand better, could you describe your main symptom and when it started?",
                    "are_you_experiencing", "I see. Are you also experiencing %s?",
                    "any_other_symptoms", "Are you experiencing any other symptoms, such as fever or pain?"),
            "Malayalam", Map.of(
                    "greeting",
                    "നമസ്കാരം! ഞാൻ SEV-AI, നിങ്ങളുടെ ആരോഗ്യ സഹായി. നിങ്ങളെ സഹായിക്കാൻ നിങ്ങളുടെ ലക്ഷണങ്ങൾ വിശദീകരിക്കുക.",
                    "out_of_scope",
                    "ക്ഷമിക്കണം, എനിക്ക് ആരോഗ്യ സംബന്ധമായ ചോദ്യങ്ങൾക്ക് മാത്രമേ മറുപടി നൽകാൻ കഴിയൂ. നിങ്ങളുടെ ലക്ഷണങ്ങൾ വിവരിക്കുക.",
                    "emergency",
                    "⚠️ അടിയന്തര മുന്നറിയിപ്പ്: നിങ്ങളുടെ ലക്ഷണങ്ങൾ ഒരു അടിയന്തര സാഹചര്യത്തെ സൂചിപ്പിക്കുന്നു. ദയവായി ഉടൻ വൈദ്യസഹായം തേടുക അല്ലെങ്കിൽ അടിയന്തര സേവനങ്ങളെ (108) വിളിക്കുക.",
                    "assessment", "നിങ്ങളുടെ ലക്ഷണങ്ങൾ അടിസ്ഥാനമാക്കി, ഇത് %s ആകാൻ സാധ്യതയുണ്ട്.",
                    "more_info",
                    "എനിക്ക് കുറച്ചുകൂടി വിവരങ്ങൾ വേണം. വേദന, തളർച്ച അല്ലെങ്കിൽ ഓക്കാനം പോലുള്ള മറ്റ് ലക്ഷണങ്ങൾ ശ്രദ്ധിച്ചോ?",
                    "next_question",
                    "എനിക്ക് മനസ്സിലായി. നന്നായി മനസ്സിലാക്കാൻ സഹായിക്കുന്നതിന്, നിങ്ങളുടെ പ്രധാന ലക്ഷണം എന്താണെന്നും അത് എപ്പോൾ തുടങ്ങിയെന്നും വിവരിക്കാമോ?",
                    "are_you_experiencing", "എനിക്ക് മനസ്സിലാകുന്നു. നിങ്ങൾക്ക് %s അനുഭവപ്പെടുന്നുണ്ടോ?",
                    "any_other_symptoms", "പനി അല്ലെങ്കിൽ വേദന പോലുള്ള മറ്റ് ലക്ഷണങ്ങൾ നിങ്ങൾ അനുഭവിക്കുന്നുണ്ടോ?"));

    private List<String> cachedSymptomNames;

    @PostConstruct
    public void init() {
        refreshSymptomCache();
    }

    public void refreshSymptomCache() {
        cachedSymptomNames = symptomRepository.findAll().stream()
                .map(Symptom::getName)
                .collect(Collectors.toList());
        log.info("Cached {} symptoms for chatbot.", cachedSymptomNames.size());
    }

    public Map<String, Object> processMessage(String sessionId, String userId, String message, String language) {
        ChatSession session = chatSessionRepository.findById(sessionId)
                .orElse(ChatSession.builder()
                        .sessionId(sessionId)
                        .userId(userId)
                        .language(language)
                        .questionsAskedCount(0)
                        .detectedSymptoms(new ArrayList<>())
                        .conversationHistory(new ArrayList<>())
                        .build());

        // 0. If previous assessment was complete, start fresh for a new interaction
        if (session.isAssessmentComplete() && detectSymptoms(message).isEmpty()
                && !isEmergency(session.getDetectedSymptoms())) {
            session.setDetectedSymptoms(new ArrayList<>());
            session.setQuestionsAskedCount(0);
            session.setAssessmentComplete(false);
        }

        // 1. Detect symptoms locally for database analytics
        List<String> newSymptoms = detectSymptoms(message);
        for (String s : newSymptoms) {
            if (!session.getDetectedSymptoms().contains(s)) {
                session.getDetectedSymptoms().add(s);
            }
        }
        session.setQuestionsAskedCount(session.getQuestionsAskedCount() + 1);

        // 2. Prepare history for Gemini
        List<Map<String, String>> history = session.getConversationHistory().stream()
                .map(m -> Map.of("role", m.getRole(), "text", m.getText()))
                .collect(Collectors.toList());

        // 3. Try Gemini AI (Multilingual & Smart)
        Map<String, Object> response = geminiService.chat(history, message, language);

        // 4. Update internal session history
        session.getConversationHistory().add(new ChatMessage("user", message));

        if (response != null) {
            String aiMessage = response.getOrDefault("message", "").toString();
            session.getConversationHistory().add(new ChatMessage("model", aiMessage));

            // Check if AI completed triage
            if ("triage".equals(response.get("type"))) {
                session.setAssessmentComplete(true);
            }
        } else {
            // 5. Fallback to rule-based logic if AI fails
            log.warn("Gemini Service failed, using rule-based fallback for sessionId: {}", sessionId);
            response = handleFallback(session, message, language);

            // If it's a greeting or out of scope, maybe clear some state
            if (response.get("message").toString()
                    .equals(LOCALIZATION.get(language != null ? language : "English").get("greeting"))) {
                session.setDetectedSymptoms(new ArrayList<>());
                session.setAssessmentComplete(false);
            }

            session.getConversationHistory().add(new ChatMessage("model", response.get("message").toString()));
        }

        // Limit history size
        if (session.getConversationHistory().size() > MAX_HISTORY * 2) {
            session.setConversationHistory(session.getConversationHistory()
                    .subList(session.getConversationHistory().size() - (MAX_HISTORY * 2),
                            session.getConversationHistory().size()));
        }

        chatSessionRepository.save(session);
        return response;
    }

    private Map<String, Object> handleFallback(ChatSession session, String message, String language) {
        Map<String, Object> response = new HashMap<>();
        String lang = (language != null && LOCALIZATION.containsKey(language)) ? language : "English";
        Map<String, String> texts = LOCALIZATION.get(lang);

        String lowerMessage = message.toLowerCase().trim();

        // 1. Rejected keywords (Out of scope / Safety - Strict)
        if (lowerMessage.matches(
                ".*\\b(cigarette|alcohol|smoke|buy|movie|song|joke|weather|money|date|dating|love|sexy|porn|girl|boy|friend|play|game|video|youtube|google|search|how are you|who are you|your name|what can you do|bad words|sex|abuse|swear|insult|kill|idiot|stupid)\\b.*")) {
            response.put("type", "question");
            response.put("message", texts.get("out_of_scope"));
            return response;
        }

        // 2. Pure Greetings (Strict)
        if (lowerMessage.matches("^(hi|hello|hey|vanakkam|namaste|hi there|like you)$")) {
            response.put("type", "question");
            response.put("message", texts.get("greeting"));
            return response;
        }

        if (isEmergency(session.getDetectedSymptoms())) {
            response.put("type", "triage");
            response.put("triage", "emergency");
            response.put("message", texts.get("emergency"));
            response.put("detectedSymptoms", session.getDetectedSymptoms());
            session.setAssessmentComplete(true);
        } else if (session.getQuestionsAskedCount() >= 3) {
            Disease assessment = performAssessment(session.getDetectedSymptoms());
            if (assessment != null) {
                response.put("type", "triage");
                response.put("message", String.format(texts.get("assessment"), assessment.getName()));
                response.put("triage", determineUrgency(assessment));
                response.put("description", assessment.getDescription());
                response.put("recommendations", assessment.getPrecautions());
                session.setAssessmentComplete(true);
            } else {
                response.put("type", "question");
                response.put("message", texts.get("more_info"));
            }
        } else {
            response.put("type", "question");
            response.put("message", generateNextQuestion(session.getDetectedSymptoms(), lang));
        }
        return response;
    }

    private List<String> detectSymptoms(String message) {
        if (cachedSymptomNames == null || cachedSymptomNames.isEmpty()) {
            refreshSymptomCache();
        }

        String lowerMessage = message.toLowerCase();
        return cachedSymptomNames.stream()
                .map(String::toLowerCase)
                .filter(name -> lowerMessage.contains(name))
                .distinct()
                .collect(Collectors.toList());
    }

    private boolean isEmergency(List<String> symptoms) {
        List<String> emergencySymptoms = Arrays.asList("chest pain", "breathlessness", "unconscious",
                "severe bleeding");
        return symptoms.stream().anyMatch(s -> emergencySymptoms.contains(s.toLowerCase()));
    }

    private Disease performAssessment(List<String> symptoms) {
        List<Disease> allDiseases = diseaseRepository.findAll();
        Disease bestMatch = null;
        long maxMatches = 0;

        for (Disease disease : allDiseases) {
            long matches = disease.getSymptoms().stream()
                    .filter(s -> symptoms.contains(s.getName()))
                    .count();

            if (matches > maxMatches) {
                maxMatches = matches;
                bestMatch = disease;
            }
        }
        return bestMatch;
    }

    private String determineUrgency(Disease disease) {
        return "doctor";
    }

    private String generateNextQuestion(List<String> detected, String lang) {
        Map<String, String> texts = LOCALIZATION.get(lang);

        if (detected.isEmpty()) {
            return texts.get("next_question");
        }

        List<Disease> candidates = diseaseRepository.findAll().stream()
                .filter(d -> d.getSymptoms().stream().anyMatch(s -> detected.contains(s.getName())))
                .collect(Collectors.toList());

        if (!candidates.isEmpty()) {
            Disease candidate = candidates.get(0);
            Optional<Symptom> nextSymptom = candidate.getSymptoms().stream()
                    .filter(s -> !detected.contains(s.getName()))
                    .findFirst();

            if (nextSymptom.isPresent()) {
                return String.format(texts.get("are_you_experiencing"), nextSymptom.get().getName());
            }
        }

        return texts.get("any_other_symptoms");
    }
}
