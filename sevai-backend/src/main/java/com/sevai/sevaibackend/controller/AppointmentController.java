package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.Appointment;
import com.sevai.sevaibackend.entity.Doctor;
import com.sevai.sevaibackend.entity.User;
import com.sevai.sevaibackend.repository.AppointmentRepository;
import com.sevai.sevaibackend.repository.DoctorRepository;
import com.sevai.sevaibackend.repository.UserRepository;
import com.sevai.sevaibackend.repository.NotificationRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/appointments")
@CrossOrigin(origins = "*")
public class AppointmentController {

    private final AppointmentRepository appointmentRepo;
    private final UserRepository userRepo;
    private final DoctorRepository doctorRepo;
    private final NotificationRepository notifRepo;

    public AppointmentController(AppointmentRepository appointmentRepo,
            UserRepository userRepo,
            DoctorRepository doctorRepo,
            NotificationRepository notifRepo) {
        this.appointmentRepo = appointmentRepo;
        this.userRepo = userRepo;
        this.doctorRepo = doctorRepo;
        this.notifRepo = notifRepo;
    }

    @PostMapping
    public ResponseEntity<?> book(@RequestBody Map<String, Object> req) {
        if (req.get("patientId") == null || req.get("doctorId") == null) {
            return ResponseEntity.badRequest().body("Missing patientId or doctorId");
        }

        Long patientId = Long.valueOf(req.get("patientId").toString());
        Long doctorId = Long.valueOf(req.get("doctorId").toString());

        User patient = userRepo.findById(patientId).orElse(null);
        Doctor doctor = doctorRepo.findById(doctorId).orElse(null);

        if (patient == null || doctor == null) {
            return ResponseEntity.badRequest().body("Invalid patient or doctor ID");
        }

        Appointment appt = Appointment.builder()
                .patient(patient)
                .doctor(doctor)
                .date(req.get("date").toString())
                .time(req.get("time").toString())
                .status("PENDING")
                .reason(req.getOrDefault("reason", "").toString())
                .notes(req.getOrDefault("notes", "").toString())
                .build();

        Appointment savedAppt = appointmentRepo.save(appt);

        // Notify Doctor
        notifRepo.save(com.sevai.sevaibackend.entity.Notification.builder()
                .doctor(doctor)
                .title("New Booking Request")
                .message("You have a new booking from " + patient.getFirstName() + " for " + appt.getDate())
                .type("BOOKING")
                .isRead(false)
                .appointmentId(savedAppt.getId())
                .build());

        return ResponseEntity.ok(savedAppt);
    }

    @PostMapping("/personal")
    public ResponseEntity<?> addPersonalReminder(@RequestBody Map<String, Object> req) {
        if (req.get("patientId") == null) {
            return ResponseEntity.badRequest().body("Missing patientId");
        }

        Long patientId = Long.valueOf(req.get("patientId").toString());
        User patient = userRepo.findById(patientId).orElse(null);

        if (patient == null) {
            return ResponseEntity.badRequest().body("User not found");
        }

        Appointment appt = Appointment.builder()
                .patient(patient)
                .doctor(null) // No internal doctor
                .isPersonal(true)
                .doctorName(req.getOrDefault("doctorName", "").toString())
                .location(req.getOrDefault("location", "").toString())
                .type(req.getOrDefault("type", "General").toString())
                .date(req.get("date").toString())
                .time(req.get("time").toString())
                .status("SCHEDULED")
                .reason(req.getOrDefault("reason", "").toString())
                .notes(req.getOrDefault("notes", "").toString())
                .build();

        Appointment savedAppt = appointmentRepo.save(appt);
        return ResponseEntity.ok(savedAppt);
    }

    @GetMapping("/user/{userId}")
    public List<Appointment> getByUser(@PathVariable Long userId) {
        return appointmentRepo.findByPatientId(userId);
    }

    @GetMapping("/doctor/{doctorId}")
    public List<Appointment> getByDoctor(@PathVariable Long doctorId) {
        return appointmentRepo.findByDoctorId(doctorId);
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<?> cancel(@PathVariable Long id) {
        return appointmentRepo.findById(id).map(appt -> {
            appt.setStatus("CANCELLED");

            // Notify Doctor
            notifRepo.save(com.sevai.sevaibackend.entity.Notification.builder()
                    .doctor(appt.getDoctor())
                    .title("Appointment Cancelled")
                    .message("The appointment with " + appt.getPatient().getFirstName() + " has been cancelled.")
                    .type("CANCELLATION")
                    .isRead(false)
                    .appointmentId(appt.getId())
                    .build());

            return ResponseEntity.ok(appointmentRepo.save(appt));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/complete")
    public ResponseEntity<?> complete(@PathVariable Long id) {
        return appointmentRepo.findById(id).map(appt -> {
            appt.setStatus("COMPLETED");

            // Notify Patient
            notifRepo.save(com.sevai.sevaibackend.entity.Notification.builder()
                    .user(appt.getPatient())
                    .title("Appointment Completed")
                    .message("Your appointment with Dr. " + appt.getDoctor().getFirstName()
                            + " is marked as completed. We hope you feel better!")
                    .type("COMPLETION")
                    .isRead(false)
                    .appointmentId(appt.getId())
                    .build());

            return ResponseEntity.ok(appointmentRepo.save(appt));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/accept")
    public ResponseEntity<?> accept(@PathVariable Long id) {
        return appointmentRepo.findById(id).map(appt -> {
            appt.setStatus("ACCEPTED");

            // Notify Patient
            notifRepo.save(com.sevai.sevaibackend.entity.Notification.builder()
                    .user(appt.getPatient())
                    .title("Appointment Accepted")
                    .message("Dr. " + appt.getDoctor().getFirstName() + " " + appt.getDoctor().getLastName()
                            + " has accepted your appointment. Please proceed with payment.")
                    .type("ACCEPTANCE")
                    .isRead(false)
                    .appointmentId(appt.getId())
                    .build());

            return ResponseEntity.ok(appointmentRepo.save(appt));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/pay")
    public ResponseEntity<?> pay(@PathVariable Long id, @RequestBody Map<String, String> req) {
        return appointmentRepo.findById(id).map(appt -> {
            appt.setPaid(true);
            appt.setPaymentId(req.get("paymentId"));
            appt.setStatus("PAID");

            // Notify Doctor
            notifRepo.save(com.sevai.sevaibackend.entity.Notification.builder()
                    .doctor(appt.getDoctor())
                    .title("Payment Received")
                    .message("Payment received for appointment with " + appt.getPatient().getFirstName())
                    .type("PAYMENT")
                    .isRead(false)
                    .appointmentId(appt.getId())
                    .build());

            return ResponseEntity.ok(appointmentRepo.save(appt));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/reject")
    public ResponseEntity<?> reject(@PathVariable Long id) {
        return appointmentRepo.findById(id).map(appt -> {
            appt.setStatus("REJECTED");

            // Notify Patient
            notifRepo.save(com.sevai.sevaibackend.entity.Notification.builder()
                    .user(appt.getPatient())
                    .title("Appointment Rejected")
                    .message("Dr. " + appt.getDoctor().getFirstName() + " " + appt.getDoctor().getLastName()
                            + " has rejected your appointment request.")
                    .type("REJECTION")
                    .isRead(false)
                    .appointmentId(appt.getId())
                    .build());

            return ResponseEntity.ok(appointmentRepo.save(appt));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/reschedule")
    public ResponseEntity<?> reschedule(@PathVariable Long id, @RequestBody Map<String, String> req) {
        return appointmentRepo.findById(id).map(appt -> {
            appt.setDate(req.get("date"));
            appt.setTime(req.get("time"));
            appt.setStatus("PENDING"); // Requires re-approval

            // Notify Doctor
            notifRepo.save(com.sevai.sevaibackend.entity.Notification.builder()
                    .doctor(appt.getDoctor())
                    .title("Appointment Rescheduled")
                    .message(appt.getPatient().getFirstName() + " has rescheduled their appointment to "
                            + appt.getDate())
                    .type("RESCHEDULE")
                    .isRead(false)
                    .appointmentId(appt.getId())
                    .build());

            return ResponseEntity.ok(appointmentRepo.save(appt));
        }).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id) {
        return appointmentRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
