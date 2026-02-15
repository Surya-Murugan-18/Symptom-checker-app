package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.HealthRecord;
import com.sevai.sevaibackend.entity.User;
import com.sevai.sevaibackend.repository.HealthRecordRepository;
import com.sevai.sevaibackend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class HealthRecordController {

    private final HealthRecordRepository healthRepo;
    private final UserRepository userRepo;

    public HealthRecordController(HealthRecordRepository healthRepo, UserRepository userRepo) {
        this.healthRepo = healthRepo;
        this.userRepo = userRepo;
    }

    @PostMapping("/users/{userId}/health-records")
    public ResponseEntity<?> add(@PathVariable Long userId, @RequestBody HealthRecord record) {
        User user = userRepo.findById(userId).orElse(null);
        if (user == null)
            return ResponseEntity.notFound().build();

        record.setUser(user);
        return ResponseEntity.ok(healthRepo.save(record));
    }

    @GetMapping("/users/{userId}/health-records")
    public List<HealthRecord> getAll(@PathVariable Long userId) {
        return healthRepo.findByUserIdOrderByRecordedAtDesc(userId);
    }

    @GetMapping("/users/{userId}/health-records/type/{type}")
    public List<HealthRecord> getByType(@PathVariable Long userId, @PathVariable String type) {
        return healthRepo.findByUserIdAndTypeOrderByRecordedAtDesc(userId, type);
    }

    @DeleteMapping("/health-records/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        healthRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
