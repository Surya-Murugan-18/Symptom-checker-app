package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.Medication;
import com.sevai.sevaibackend.entity.User;
import com.sevai.sevaibackend.repository.MedicationRepository;
import com.sevai.sevaibackend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class MedicationController {

    private final MedicationRepository medicationRepo;
    private final UserRepository userRepo;

    public MedicationController(MedicationRepository medicationRepo, UserRepository userRepo) {
        this.medicationRepo = medicationRepo;
        this.userRepo = userRepo;
    }

    @PostMapping("/users/{userId}/medications")
    public ResponseEntity<?> add(@PathVariable Long userId, @RequestBody Medication med) {
        User user = userRepo.findById(userId).orElse(null);
        if (user == null)
            return ResponseEntity.notFound().build();

        med.setUser(user);
        med.setActive(true);
        return ResponseEntity.ok(medicationRepo.save(med));
    }

    @GetMapping("/users/{userId}/medications")
    public List<Medication> getActive(@PathVariable Long userId) {
        return medicationRepo.findByUserIdAndIsActiveTrue(userId);
    }

    @GetMapping("/users/{userId}/medications/all")
    public List<Medication> getAll(@PathVariable Long userId) {
        return medicationRepo.findByUserId(userId);
    }

    @GetMapping("/users/{userId}/medications/history")
    public List<Medication> getHistory(@PathVariable Long userId) {
        return medicationRepo.findByUserIdAndIsActiveFalse(userId);
    }

    @PutMapping("/medications/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Medication updated) {
        return medicationRepo.findById(id).map(med -> {
            med.setName(updated.getName());
            med.setDosage(updated.getDosage());
            med.setFrequency(updated.getFrequency());
            med.setTimeSlots(updated.getTimeSlots());
            med.setEndDate(updated.getEndDate());
            med.setNotes(updated.getNotes());
            med.setType(updated.getType());
            med.setActive(updated.isActive());
            return ResponseEntity.ok(medicationRepo.save(med));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/medications/{id}/stop")
    public ResponseEntity<?> stop(@PathVariable Long id) {
        return medicationRepo.findById(id).map(med -> {
            med.setActive(false);
            return ResponseEntity.ok(medicationRepo.save(med));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/medications/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        medicationRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // ── Pill Tracking & Adherence ──

    @PostMapping("/medications/{id}/take-dose")
    public ResponseEntity<?> takeDose(@PathVariable Long id) {
        return medicationRepo.findById(id).map(med -> {
            // Increment doses taken
            med.setDosesTaken((med.getDosesTaken() != null ? med.getDosesTaken() : 0) + 1);

            // Decrement pill count if tracking inventory
            if (med.getPillsRemaining() != null && med.getPillsRemaining() > 0) {
                med.setPillsRemaining(med.getPillsRemaining() - 1);
            }

            medicationRepo.save(med);

            // Build response with refill warning if applicable
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("medication", med);
            response.put("pillsRemaining", med.getPillsRemaining());

            boolean needsRefill = med.getPillsRemaining() != null
                    && med.getRefillThreshold() != null
                    && med.getPillsRemaining() <= med.getRefillThreshold();
            response.put("refillWarning", needsRefill);

            return ResponseEntity.ok(response);
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/medications/{id}/skip-dose")
    public ResponseEntity<?> skipDose(@PathVariable Long id) {
        return medicationRepo.findById(id).map(med -> {
            med.setDosesSkipped((med.getDosesSkipped() != null ? med.getDosesSkipped() : 0) + 1);
            return ResponseEntity.ok(medicationRepo.save(med));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/medications/{id}/refill")
    public ResponseEntity<?> refill(@PathVariable Long id, @RequestBody java.util.Map<String, Integer> body) {
        return medicationRepo.findById(id).map(med -> {
            Integer count = body.get("pillCount");
            if (count != null) {
                med.setPillsTotal(count);
                med.setPillsRemaining(count);
            }
            return ResponseEntity.ok(medicationRepo.save(med));
        }).orElse(ResponseEntity.notFound().build());
    }
}
