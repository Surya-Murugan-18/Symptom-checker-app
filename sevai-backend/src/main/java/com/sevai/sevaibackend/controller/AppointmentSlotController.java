package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.AppointmentSlot;
import com.sevai.sevaibackend.repository.AppointmentSlotRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/slots")
@CrossOrigin(origins = "*")
public class AppointmentSlotController {

    private final AppointmentSlotRepository slotRepo;

    public AppointmentSlotController(AppointmentSlotRepository slotRepo) {
        this.slotRepo = slotRepo;
    }

    @PostMapping
    public ResponseEntity<AppointmentSlot> create(@RequestBody AppointmentSlot slot) {
        slot.setAvailable(true);
        return ResponseEntity.ok(slotRepo.save(slot));
    }

    @GetMapping("/doctor/{doctorId}")
    public List<AppointmentSlot> getByDoctor(@PathVariable Long doctorId, @RequestParam String date) {
        return slotRepo.findByDoctorIdAndDate(doctorId, date);
    }

    @GetMapping("/doctor/{doctorId}/available")
    public List<AppointmentSlot> getAvailableByDoctor(@PathVariable Long doctorId, @RequestParam String date) {
        return slotRepo.findByDoctorIdAndDateAndIsAvailableTrue(doctorId, date);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        slotRepo.deleteById(id);
        return ResponseEntity.ok().build();
    }
}
