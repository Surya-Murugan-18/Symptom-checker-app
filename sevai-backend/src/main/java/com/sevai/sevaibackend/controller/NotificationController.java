package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.Notification;
import com.sevai.sevaibackend.entity.User;
import com.sevai.sevaibackend.repository.NotificationRepository;
import com.sevai.sevaibackend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class NotificationController {

    private final NotificationRepository notifRepo;
    private final UserRepository userRepo;

    public NotificationController(NotificationRepository notifRepo, UserRepository userRepo) {
        this.notifRepo = notifRepo;
        this.userRepo = userRepo;
    }

    @GetMapping("/users/{userId}/notifications")
    public List<Notification> getAll(@PathVariable Long userId) {
        return notifRepo.findTop50ByUserIdOrderByCreatedAtDesc(userId);
    }

    @GetMapping("/doctors/{doctorId}/notifications")
    public List<Notification> getDoctorNotifications(@PathVariable Long doctorId) {
        return notifRepo.findTop50ByDoctorIdOrderByCreatedAtDesc(doctorId);
    }

    @GetMapping("/users/{userId}/notifications/unread")
    public List<Notification> getUnread(@PathVariable Long userId) {
        return notifRepo.findByUserIdAndIsReadFalse(userId);
    }

    @PutMapping("/notifications/{id}/read")
    public ResponseEntity<?> markRead(@PathVariable Long id) {
        return notifRepo.findById(id).map(n -> {
            n.setRead(true);
            return ResponseEntity.ok(notifRepo.save(n));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/users/{userId}/notifications")
    public ResponseEntity<?> create(@PathVariable Long userId, @RequestBody Map<String, String> req) {
        User user = userRepo.findById(userId).orElse(null);
        if (user == null)
            return ResponseEntity.notFound().build();

        Notification notif = Notification.builder()
                .user(user)
                .title(req.get("title"))
                .message(req.get("message"))
                .type(req.getOrDefault("type", "GENERAL"))
                .isRead(false)
                .build();

        return ResponseEntity.ok(notifRepo.save(notif));
    }

    @DeleteMapping("/notifications/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        notifRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
