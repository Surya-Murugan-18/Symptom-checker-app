package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.HealthData;
import com.sevai.sevaibackend.repository.HealthDataRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
@CrossOrigin
public class HealthDataController {

    private final HealthDataRepository repository;

    public HealthDataController(HealthDataRepository repository) {
        this.repository = repository;
    }

    // Endpoint for ESP32 to push data
    @PostMapping("/push")
    public ResponseEntity<?> pushData(@RequestBody HealthData data) {
        System.out.println("📥 RECEIVED IOT DATA: " + data);
        data.setTimestamp(LocalDateTime.now());

        // Basic status logic
        if (data.getHeartRate() != null) {
            if (data.getHeartRate() > 100 || data.getHeartRate() < 60) {
                data.setStatus("Abnormal");
            } else {
                data.setStatus("Normal");
            }
        }

        repository.save(data);
        return ResponseEntity.ok(Map.of("message", "Data received"));
    }

    // Endpoint for Flutter to fetch latest data
    @GetMapping("/latest/{email}")
    public ResponseEntity<?> getLatest(@PathVariable String email) {
        System.out.println("📤 FETCHING LATEST DATA FOR: " + email);
        return repository.findFirstByEmailOrderByTimestampDesc(email)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
