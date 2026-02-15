package com.sevai.sevaibackend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    /**
     * Sends a password reset OTP code to the user's email.
     */
    public void sendResetCode(String toEmail, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject("SEV-AI Password Reset Code");
        message.setText(
                "Hello,\n\n" +
                        "Your password reset code is: " + code + "\n\n" +
                        "This code will expire shortly. If you did not request a password reset, please ignore this email.\n\n"
                        +
                        "— SEV-AI Team");
        mailSender.send(message);
        System.out.println("📧 Reset code sent to: " + toEmail);
    }
}
