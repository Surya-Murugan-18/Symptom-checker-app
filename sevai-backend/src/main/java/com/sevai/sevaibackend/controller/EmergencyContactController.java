package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.EmergencyContact;
import com.sevai.sevaibackend.entity.User;
import com.sevai.sevaibackend.repository.EmergencyContactRepository;
import com.sevai.sevaibackend.repository.UserRepository;
import com.sevai.sevaibackend.service.TwilioService;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class EmergencyContactController {

    private final EmergencyContactRepository emergencyRepo;
    private final UserRepository userRepo;
    private final TwilioService twilioService;

    public EmergencyContactController(EmergencyContactRepository emergencyRepo,
            UserRepository userRepo,
            TwilioService twilioService) {
        this.emergencyRepo = emergencyRepo;
        this.userRepo = userRepo;
        this.twilioService = twilioService;
        System.out.println("✅ EmergencyContactController initialized");
    }

    @PostMapping("/users/{userId}/emergency")
    public ResponseEntity<?> add(
            @PathVariable Long userId,
            @RequestBody EmergencyContact contact) {

        System.out.println("📩 POST Emergency Contact request for userId: " + userId);
        if (contact != null) {
            System.out.println("📦 Contact Data: Name=" + contact.getName() + ", Phone=" + contact.getPhone());
        }

        if (contact.getName() == null ||
                contact.getPhone() == null ||
                contact.getRelation() == null) {

            return ResponseEntity.badRequest().body("All fields are required");
        }

        User user = userRepo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "User not found"));

        emergencyRepo.findByUserIdAndPhone(userId, contact.getPhone())
                .ifPresent(c -> {
                    throw new ResponseStatusException(
                            HttpStatus.CONFLICT,
                            "Emergency contact already exists");
                });

        contact.setUser(user);
        return ResponseEntity.ok(emergencyRepo.save(contact));
    }

    @GetMapping("/users/{userId}/emergency")
    public List<EmergencyContact> get(@PathVariable Long userId) {
        return emergencyRepo.findByUserId(userId);
    }

    @PutMapping("/emergency/{contactId}")
    public ResponseEntity<?> update(
            @PathVariable Long contactId,
            @RequestBody EmergencyContact updated) {

        if (updated.getName() == null ||
                updated.getPhone() == null ||
                updated.getRelation() == null) {

            return ResponseEntity.badRequest().body("All fields are required");
        }

        EmergencyContact existing = emergencyRepo.findById(contactId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Contact not found"));

        Long userId = existing.getUser().getId();

        emergencyRepo.findByUserIdAndPhone(userId, updated.getPhone())
                .ifPresent(c -> {
                    if (!c.getId().equals(contactId)) {
                        throw new ResponseStatusException(
                                HttpStatus.CONFLICT,
                                "Phone already exists");
                    }
                });

        existing.setName(updated.getName());
        existing.setPhone(updated.getPhone());
        existing.setRelation(updated.getRelation());

        return ResponseEntity.ok(emergencyRepo.save(existing));
    }

    @DeleteMapping("/emergency/{contactId}")
    public ResponseEntity<Void> delete(@PathVariable Long contactId) {
        emergencyRepo.deleteById(contactId);
        return ResponseEntity.noContent().build();
    }

    // 🚨 Emergency Trigger Endpoint
    @PostMapping("/emergency/trigger")
    public ResponseEntity<?> triggerEmergency(@RequestBody Map<String, Object> request) {
        try {
            System.out.println("🚨 Emergency Trigger Request: " + request);

            String contactNumber = (String) request.get("contact_number");
            List<String> symptoms = (List<String>) request.get("symptoms");
            String urgency = (String) request.get("urgency");
            Object userIdObj = request.get("userId");

            // 🔍 If contactNumber is missing, try to fetch it from the database for the
            // given userId
            if ((contactNumber == null || contactNumber.isEmpty()) && userIdObj != null) {
                Long userId = Long.valueOf(userIdObj.toString());
                List<EmergencyContact> contacts = emergencyRepo.findByUserId(userId);
                if (!contacts.isEmpty()) {
                    contactNumber = contacts.get(0).getPhone();
                    System.out.println("✅ Found contact in DB: " + contactNumber);
                }
            }

            if (twilioService == null) {
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                        .body("Twilio service is not initialized");
            }

            String callSid = twilioService.triggerEmergencyCall(contactNumber, symptoms, urgency);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "callSid", callSid,
                    "message", "Emergency call triggered successfully"));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }
}
