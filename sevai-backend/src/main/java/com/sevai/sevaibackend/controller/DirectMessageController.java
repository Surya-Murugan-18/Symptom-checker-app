package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.DirectMessage;
import com.sevai.sevaibackend.repository.DirectMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/messages")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // Allow requests from Flutter app
public class DirectMessageController {

    private final DirectMessageRepository messageRepository;
    private final com.sevai.sevaibackend.repository.DoctorRepository doctorRepository;
    private final com.sevai.sevaibackend.repository.UserRepository userRepository;

    @GetMapping("/{userId}/{doctorId}")
    public ResponseEntity<List<DirectMessage>> getMessages(
            @PathVariable Long userId,
            @PathVariable Long doctorId) {
        return ResponseEntity.ok(messageRepository.findByUserIdAndDoctorIdOrderByTimestampAsc(userId, doctorId));
    }

    @GetMapping("/conversations/{userId}")
    public ResponseEntity<List<com.sevai.sevaibackend.entity.Doctor>> getConversations(@PathVariable Long userId) {
        // 1. Get distinct doctor IDs from messages
        List<Long> doctorIds = messageRepository.findDoctorIdsByUserId(userId);

        // 2. Fetch doctor details
        List<com.sevai.sevaibackend.entity.Doctor> doctors = doctorRepository.findAllById(doctorIds);

        return ResponseEntity.ok(doctors);
    }

    @GetMapping("/conversations/doctor/{doctorId}")
    public ResponseEntity<List<com.sevai.sevaibackend.entity.User>> getConversationsForDoctor(
            @PathVariable Long doctorId) {
        // 1. Get distinct user IDs from messages
        List<Long> userIds = messageRepository.findUserIdsByDoctorId(doctorId);

        // 2. Fetch user details
        List<com.sevai.sevaibackend.entity.User> users = userRepository.findAllById(userIds);

        return ResponseEntity.ok(users);
    }

    private final com.sevai.sevaibackend.repository.NotificationRepository notificationRepository;

    @PostMapping("/send")
    public ResponseEntity<DirectMessage> sendMessage(@RequestBody Map<String, Object> request) {
        Long userId = Long.valueOf(request.get("userId").toString());
        Long doctorId = Long.valueOf(request.get("doctorId").toString());
        String content = request.get("content").toString();
        Boolean isUserSender = Boolean.valueOf(request.get("isUserSender").toString());

        DirectMessage message = DirectMessage.builder()
                .userId(userId)
                .doctorId(doctorId)
                .content(content)
                .isUserSender(isUserSender)
                .timestamp(LocalDateTime.now())
                .build();

        DirectMessage savedMessage = messageRepository.save(message);

        // Notify recipient
        if (isUserSender) {
            // User sent message to Doctor
            doctorRepository.findById(doctorId).ifPresent(doctor -> {
                userRepository.findById(userId).ifPresent(user -> {
                    notificationRepository.save(com.sevai.sevaibackend.entity.Notification.builder()
                            .doctor(doctor)
                            .title("New Message")
                            .message("New message from " + user.getFirstName() + ": "
                                    + (content.length() > 30 ? content.substring(0, 30) + "..." : content))
                            .type("MESSAGE")
                            .isRead(false)
                            .build());
                });
            });
        } else {
            // Doctor sent message to User
            userRepository.findById(userId).ifPresent(user -> {
                doctorRepository.findById(doctorId).ifPresent(doctor -> {
                    notificationRepository.save(com.sevai.sevaibackend.entity.Notification.builder()
                            .user(user)
                            .title("New Message")
                            .message("Dr. " + doctor.getFirstName() + " sent you a message")
                            .type("MESSAGE")
                            .isRead(false)
                            .build());
                });
            });
        }

        return ResponseEntity.ok(savedMessage);
    }
}
