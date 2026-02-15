package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.dto.AboutYouRequest;
import com.sevai.sevaibackend.entity.User;
import com.sevai.sevaibackend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository userRepo;

    public UserController(UserRepository userRepo) {
        this.userRepo = userRepo;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<?> getProfile(@PathVariable Long userId) {
        return userRepo.findById(userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{userId}")
    public ResponseEntity<?> updateProfile(@PathVariable Long userId,
            @RequestBody Map<String, Object> updates) {
        try {
            System.out.println("🔄 Updating profile for user: " + userId);
            User user = userRepo.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            if (updates.containsKey("firstName") && updates.get("firstName") != null)
                user.setFirstName(updates.get("firstName").toString());
            if (updates.containsKey("lastName") && updates.get("lastName") != null)
                user.setLastName(updates.get("lastName").toString());
            if (updates.containsKey("email") && updates.get("email") != null)
                user.setEmail(updates.get("email").toString());
            if (updates.containsKey("contact") && updates.get("contact") != null)
                user.setContact(updates.get("contact").toString());
            if (updates.containsKey("location") && updates.get("location") != null)
                user.setLocation(updates.get("location").toString());
            if (updates.containsKey("gender") && updates.get("gender") != null)
                user.setGender(updates.get("gender").toString());
            if (updates.containsKey("dob") && updates.get("dob") != null)
                user.setDob(updates.get("dob").toString());
            if (updates.containsKey("weight") && updates.get("weight") != null)
                user.setWeight(updates.get("weight").toString());
            if (updates.containsKey("bloodPressureLevel") && updates.get("bloodPressureLevel") != null)
                user.setBloodPressureLevel(updates.get("bloodPressureLevel").toString());
            if (updates.containsKey("photoUrl") && updates.get("photoUrl") != null)
                user.setPhotoUrl(updates.get("photoUrl").toString());

            // Medfriend Support
            if (updates.containsKey("medfriendName") && updates.get("medfriendName") != null)
                user.setMedfriendName(updates.get("medfriendName").toString());
            if (updates.containsKey("medfriendContact") && updates.get("medfriendContact") != null)
                user.setMedfriendContact(updates.get("medfriendContact").toString());
            if (updates.containsKey("medfriendEmail") && updates.get("medfriendEmail") != null)
                user.setMedfriendEmail(updates.get("medfriendEmail").toString());

            User saved = userRepo.save(user);
            System.out.println("✅ Profile updated successfully for user: " + userId);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            System.err.println("❌ Error updating profile: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error updating profile: " + e.getMessage());
        }
    }

    @PutMapping("/{userId}/about-you")
    public User updateAboutYou(@PathVariable Long userId,
            @RequestBody AboutYouRequest req) {

        User user = userRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setLanguage(req.getLanguage());
        user.setHasChronicIllness(req.getHasChronicIllness());
        user.setChronicIllnessDetails(req.getChronicIllnessDetails());
        user.setTakesRegularMedicine(req.getTakesRegularMedicine());

        return userRepo.save(user);
    }
}
