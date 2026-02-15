package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.Doctor;
import com.sevai.sevaibackend.repository.DoctorRepository;
import com.sevai.sevaibackend.security.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/doctors")
@CrossOrigin(origins = "*")
public class DoctorController {

    private final DoctorRepository doctorRepo;
    private final com.sevai.sevaibackend.repository.AppointmentRepository appointmentRepo;
    private final PasswordEncoder encoder;
    private final JwtService jwt;

    public DoctorController(DoctorRepository doctorRepo,
            com.sevai.sevaibackend.repository.AppointmentRepository appointmentRepo,
            PasswordEncoder encoder,
            JwtService jwt) {
        this.doctorRepo = doctorRepo;
        this.appointmentRepo = appointmentRepo;
        this.encoder = encoder;
        this.jwt = jwt;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Doctor doctor) {
        if (doctor == null || doctor.getEmail() == null) {
            System.out.println("❌ Registration failed: Doctor or Email is null");
            return ResponseEntity.badRequest().body("Invalid doctor data");
        }
        if (doctorRepo.findByEmail(doctor.getEmail()).isPresent()) {
            System.out.println("❌ Registration failed: Email already exists: " + doctor.getEmail());
            return ResponseEntity.badRequest().body("Email already exists");
        }
        try {
            doctor.setPassword(encoder.encode(doctor.getPassword()));
            doctor.setVerified(true); // ✅ Dynamic visibility: auto-verified
            doctorRepo.save(doctor);
            System.out.println("✅ Doctor registered successfully: " + doctor.getEmail());
            return ResponseEntity.ok("Doctor registered successfully");
        } catch (Exception e) {
            System.out.println("❌ Registration failed: " + e.getMessage());
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> req) {
        Doctor doctor = doctorRepo.findByEmail(req.get("email")).orElse(null);
        if (doctor == null || !encoder.matches(req.get("password"), doctor.getPassword())) {
            return ResponseEntity.status(401).body("Invalid email or password");
        }
        return ResponseEntity.ok(Map.of(
                "token", jwt.generateToken(doctor.getEmail()),
                "doctorId", doctor.getId(),
                "firstName", doctor.getFirstName(),
                "lastName", doctor.getLastName(),
                "specialization", doctor.getSpecialization(),
                "photoUrl", doctor.getPhotoUrl() != null ? doctor.getPhotoUrl() : "assets/D10.png",
                "name", doctor.getFirstName() + " " + doctor.getLastName()));
    }

    @GetMapping("/{id}/stats")
    public ResponseEntity<?> getStats(@PathVariable Long id) {
        String today = java.time.LocalDate.now().toString();
        Map<String, Object> stats = Map.of(
                "newBookings", appointmentRepo.countByDoctorIdAndStatus(id, "PENDING"),
                "activeConsultations", appointmentRepo.countByDoctorIdAndStatus(id, "PAID"),
                "completedConsultations", appointmentRepo.countByDoctorIdAndStatus(id, "COMPLETED"),
                "todayAppointments", appointmentRepo.countByDoctorIdAndDate(id, today));
        return ResponseEntity.ok(stats);
    }

    @PutMapping("/{id}/toggle-online")
    public ResponseEntity<?> toggleOnline(@PathVariable Long id, @RequestBody Map<String, Boolean> req) {
        return doctorRepo.findById(id).map(doctor -> {
            doctor.setOnline(req.get("isOnline"));
            return ResponseEntity.ok(doctorRepo.save(doctor));
        }).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/today")
    public List<com.sevai.sevaibackend.entity.Appointment> getTodayAppointments(@PathVariable Long id) {
        String today = java.time.LocalDate.now().toString();
        return appointmentRepo.findByDoctorIdAndDate(id, today);
    }

    @GetMapping
    public List<Doctor> getAll() {
        return doctorRepo.findAll(); // ✅ Show all registered doctors
    }

    @GetMapping("/search")
    public List<Doctor> search(@RequestParam String query) {
        return doctorRepo.findBySpecializationContainingIgnoreCase(query);
    }

    @GetMapping("/top")
    public List<Doctor> topDoctors() {
        return doctorRepo.findTop10ByOrderByRatingDesc();
    }

    // Only verified doctors visible to patients
    @GetMapping("/verified")
    public List<Doctor> verifiedDoctors() {
        return doctorRepo.findByIsVerifiedTrue();
    }

    // Search only among verified doctors
    @GetMapping("/verified/search")
    public List<Doctor> searchVerified(@RequestParam String query) {
        return doctorRepo.searchVerifiedDoctors(query);
    }

    @GetMapping("/specializations")
    public List<String> getSpecializations() {
        return doctorRepo.findDistinctSpecializations();
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Doctor updatedDoctor) {
        return doctorRepo.findById(id).map(doctor -> {
            if (updatedDoctor.getFirstName() != null)
                doctor.setFirstName(updatedDoctor.getFirstName());
            if (updatedDoctor.getLastName() != null)
                doctor.setLastName(updatedDoctor.getLastName());
            if (updatedDoctor.getPhone() != null)
                doctor.setPhone(updatedDoctor.getPhone());
            if (updatedDoctor.getSpecialization() != null)
                doctor.setSpecialization(updatedDoctor.getSpecialization());
            if (doctor.isVerified() != updatedDoctor.isVerified())
                doctor.setVerified(updatedDoctor.isVerified());
            if (updatedDoctor.getConsultationFee() != null)
                doctor.setConsultationFee(updatedDoctor.getConsultationFee());
            if (updatedDoctor.getPhotoUrl() != null)
                doctor.setPhotoUrl(updatedDoctor.getPhotoUrl());
            doctorRepo.save(doctor);
            return ResponseEntity.ok(doctor);
        }).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id) {
        return doctorRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
