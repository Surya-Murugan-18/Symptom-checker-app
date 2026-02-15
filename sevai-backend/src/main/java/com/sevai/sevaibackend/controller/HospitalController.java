package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.Hospital;
import com.sevai.sevaibackend.repository.HospitalRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/hospitals")
@CrossOrigin(origins = "*")
public class HospitalController {

    private final HospitalRepository hospitalRepo;

    public HospitalController(HospitalRepository hospitalRepo) {
        this.hospitalRepo = hospitalRepo;
    }

    @GetMapping
    public List<Hospital> getAll() {
        return hospitalRepo.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id) {
        return hospitalRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/type/{type}")
    public List<Hospital> getByType(@PathVariable String type) {
        return hospitalRepo.findByType(type);
    }

    @GetMapping("/search")
    public List<Hospital> search(@RequestParam String query) {
        return hospitalRepo.findByNameContainingIgnoreCase(query);
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Hospital hospital) {
        return ResponseEntity.ok(hospitalRepo.save(hospital));
    }
}
