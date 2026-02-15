package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.dto.*;
import com.sevai.sevaibackend.entity.User;
import com.sevai.sevaibackend.repository.UserRepository;
import com.sevai.sevaibackend.security.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;
import com.sevai.sevaibackend.service.EmailService;

import com.sevai.sevaibackend.entity.EmergencyContact;
import java.util.ArrayList;
import java.util.List;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import java.util.Collections;
import org.springframework.beans.factory.annotation.Value;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin
public class AuthController {

    private final UserRepository repo;
    private final PasswordEncoder encoder;
    private final JwtService jwt;
    private final EmailService emailService;

    @Value("${google.client.id}")
    private String googleClientId;

    private final ConcurrentHashMap<String, String> resetCodes = new ConcurrentHashMap<>();

    public AuthController(UserRepository repo,
            PasswordEncoder encoder,
            JwtService jwt,
            EmailService emailService) {
        this.repo = repo;
        this.encoder = encoder;
        this.jwt = jwt;
        this.emailService = emailService;
    }

    @PostMapping("/google")
    public ResponseEntity<?> googleLogin(@RequestBody GoogleLoginRequest req) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(),
                    new GsonFactory())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();

            GoogleIdToken idToken = verifier.verify(req.idToken);
            if (idToken == null) {
                return ResponseEntity.status(401).body("Invalid ID token");
            }

            Payload payload = idToken.getPayload();
            String email = payload.getEmail();
            String firstName = (String) payload.get("given_name");
            String lastName = (String) payload.get("family_name");
            String picture = (String) payload.get("picture");

            User user = repo.findFirstByEmail(email).orElse(null);

            if (user == null) {
                // Auto-register new user via Google
                user = new User();
                user.setEmail(email);
                user.setFirstName(firstName);
                user.setLastName(lastName);
                user.setPhotoUrl(picture);
                user.setPassword(encoder.encode("GOOGLE_OAUTH_USER_" + email)); // dummy password
                repo.save(user);
            }

            List<LoginResponse.EmergencyContactDTO> contacts = new ArrayList<>();
            if (user.getEmergencyContacts() != null) {
                for (EmergencyContact ec : user.getEmergencyContacts()) {
                    LoginResponse.EmergencyContactDTO dto = new LoginResponse.EmergencyContactDTO();
                    dto.id = ec.getId();
                    dto.name = ec.getName();
                    dto.phone = ec.getPhone();
                    dto.relation = ec.getRelation();
                    contacts.add(dto);
                }
            }

            return ResponseEntity.ok(
                    new LoginResponse(user.getId(), jwt.generateToken(user.getEmail()), user.getEmail(),
                            user.getFirstName(), user.getLastName(),
                            user.getGender(), user.getDob(), user.getLocation(), user.getContact(),
                            user.getLanguage(), user.getHasChronicIllness(), user.getChronicIllnessDetails(),
                            user.getTakesRegularMedicine(), user.getWeight(), user.getBloodPressureLevel(),
                            user.getPhotoUrl(), contacts));

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error verifying Google token: " + e.getMessage());
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest req) {

        if (req.password == null || req.password.isBlank()) {
            return ResponseEntity.badRequest().body("Password is required");
        }

        if (repo.findFirstByEmail(req.email).isPresent()) {
            return ResponseEntity.badRequest().body("Email already exists");
        }

        User u = new User();
        u.setFirstName(req.firstName);
        u.setLastName(req.lastName);
        u.setEmail(req.email);
        u.setPassword(encoder.encode(req.password));
        u.setGender(req.gender);
        u.setDob(req.dob);
        u.setLocation(req.location);
        u.setContact(req.contact);

        // Health Info
        u.setLanguage(req.language);
        u.setHasChronicIllness(req.hasChronicIllness);
        u.setChronicIllnessDetails(req.chronicIllnessDetails);
        u.setTakesRegularMedicine(req.takesRegularMedicine);
        u.setWeight(req.weight);
        u.setBloodPressureLevel(req.bloodPressureLevel);

        // Emergency Contacts
        if (req.emergencyContacts != null && !req.emergencyContacts.isEmpty()) {
            List<EmergencyContact> contacts = new ArrayList<>();
            for (RegisterRequest.EmergencyContactRegisterDTO dto : req.emergencyContacts) {
                EmergencyContact ec = new EmergencyContact();
                ec.setName(dto.name);
                ec.setPhone(dto.phoneNumber);
                ec.setRelation(dto.relationship);
                ec.setUser(u);
                contacts.add(ec);
            }
            u.setEmergencyContacts(contacts);
        }

        repo.save(u);
        return ResponseEntity.ok("registered");
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {

        User user = repo.findFirstByEmail(req.email).orElse(null);

        if (user == null ||
                !encoder.matches(req.password, user.getPassword())) {
            return ResponseEntity.status(401)
                    .body("Invalid email or password");
        }

        List<LoginResponse.EmergencyContactDTO> contacts = new ArrayList<>();
        if (user.getEmergencyContacts() != null) {
            for (EmergencyContact ec : user.getEmergencyContacts()) {
                LoginResponse.EmergencyContactDTO dto = new LoginResponse.EmergencyContactDTO();
                dto.id = ec.getId();
                dto.name = ec.getName();
                dto.phone = ec.getPhone();
                dto.relation = ec.getRelation();
                contacts.add(dto);
            }
        }

        return ResponseEntity.ok(
                new LoginResponse(user.getId(), jwt.generateToken(user.getEmail()), user.getEmail(),
                        user.getFirstName(), user.getLastName(),
                        user.getGender(), user.getDob(), user.getLocation(), user.getContact(),
                        user.getLanguage(), user.getHasChronicIllness(), user.getChronicIllnessDetails(),
                        user.getTakesRegularMedicine(), user.getWeight(), user.getBloodPressureLevel(),
                        user.getPhotoUrl(), contacts));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> req) {
        String email = req.get("email");
        if (repo.findFirstByEmail(email).isEmpty()) {
            return ResponseEntity.badRequest().body("Email not found");
        }

        String code = String.format("%04d", new Random().nextInt(9999));
        resetCodes.put(email, code);

        try {
            emailService.sendResetCode(email, code);
            return ResponseEntity.ok(Map.of(
                    "message", "Reset code sent to your email"));
        } catch (Exception e) {
            System.out.println("❌ Failed to send email: " + e.getMessage());
            return ResponseEntity.ok(Map.of(
                    "message", "Reset code generated (email delivery failed)",
                    "code", code // Fallback: return code if email fails
            ));
        }
    }

    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@RequestBody Map<String, String> req) {
        String email = req.get("email");
        String code = req.get("code");

        String storedCode = resetCodes.get(email);
        if (storedCode == null || !storedCode.equals(code)) {
            return ResponseEntity.badRequest().body("Invalid or expired code");
        }

        return ResponseEntity.ok(Map.of("message", "Code verified", "verified", true));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> req) {
        String email = req.get("email");
        String code = req.get("code");
        String newPassword = req.get("newPassword");

        String storedCode = resetCodes.get(email);
        if (storedCode == null || !storedCode.equals(code)) {
            return ResponseEntity.badRequest().body("Invalid or expired code");
        }

        User user = repo.findFirstByEmail(email).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body("User not found");
        }

        user.setPassword(encoder.encode(newPassword));
        repo.save(user);
        resetCodes.remove(email);

        return ResponseEntity.ok(Map.of("message", "Password reset successfully"));
    }
}
