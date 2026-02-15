package com.sevai.sevaibackend.service;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Call;
import com.twilio.type.PhoneNumber;
import com.twilio.type.Twiml;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Slf4j
public class TwilioService {

    @Value("${twilio.account.sid}")
    private String accountSid;

    @Value("${twilio.auth.token}")
    private String authToken;

    @Value("${twilio.phone.number}")
    private String fromNumber;

    @Value("${emergency.phone.number}")
    private String defaultEmergencyNumber;

    @PostConstruct
    public void init() {
        if (accountSid != null && !accountSid.startsWith("ACxxxx")) {
            Twilio.init(accountSid, authToken);
            log.info("Twilio initialized with Account SID: {}", accountSid);
        } else {
            log.warn("Twilio configuration is missing or invalid (using placeholders). Emergency calls will not work.");
        }
    }

    public String triggerEmergencyCall(String userPhoneNumber, List<String> symptoms, String urgency) {
        try {
            String toInfo = (userPhoneNumber != null && !userPhoneNumber.isEmpty()) ? userPhoneNumber
                    : defaultEmergencyNumber;

            String symptomList = (symptoms != null && !symptoms.isEmpty())
                    ? String.join(", ", symptoms)
                    : "critical symptoms detected";

            String urgencyLevel = (urgency != null) ? urgency : "emergency";

            // Construct TwiML
            String twimlString = "<Response>" +
                    "<Say voice=\"Polly.Joanna\">" +
                    "This is an emergency alert from the Sevai AI system. " +
                    "A patient has reported " + symptomList + ". " +
                    "The urgency level is " + urgencyLevel + ". " +
                    "Please respond immediately." +
                    "</Say>" +
                    "<Pause length=\"1\"/>" +
                    "<Say voice=\"Polly.Joanna\">" +
                    "Repeating: Emergency alert. Patient symptoms include " + symptomList + ". " +
                    "Immediate medical attention is required." +
                    "</Say>" +
                    "</Response>";

            Call call = Call.creator(
                    new PhoneNumber(toInfo),
                    new PhoneNumber(fromNumber),
                    new Twiml(twimlString))
                    .create();

            log.info("Emergency call triggered. SID: {}", call.getSid());
            return call.getSid();

        } catch (Exception e) {
            log.error("Failed to trigger emergency call: {}", e.getMessage());
            throw new RuntimeException("Failed to trigger emergency call: " + e.getMessage());
        }
    }
}
