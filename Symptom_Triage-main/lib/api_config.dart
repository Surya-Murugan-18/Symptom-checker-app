import 'package:flutter/foundation.dart';

class ApiConfig {
  // Use http://10.0.2.2:8081 for Android Emulator
  // Use http://localhost:8081 for iOS Simulator, Web, or Desktop
  // Use your computer's IP (e.g., http://192.168.1.5:8081) for physical devices
  static const String _liveIp = "192.168.137.231"; 
  static const String baseUrl = kIsWeb 
      ? "http://localhost:8081/api" 
      : "http://$_liveIp:8081/api";

  // Auth endpoints
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String googleLogin = "$baseUrl/auth/google";

  // Chatbot endpoint
  static const String chat = "$baseUrl/v1/chat/message"; // Pointing to our chatbot controller

  // Other endpoints
  static const String appointments = "$baseUrl/appointments";
  static const String healthRecords = "$baseUrl/health-records";
  static const String notifications = "$baseUrl/notifications";
  static const String articles = "$baseUrl/articles";
  static const String emergency = "$baseUrl/v1/emergency";

  // Doctor endpoints
  static const String doctors = "$baseUrl/doctors";
  static const String doctorsVerified = "$baseUrl/doctors/verified";
  static const String doctorsTop = "$baseUrl/doctors/top";
  static String doctorById(int id) => "$baseUrl/doctors/$id";
  static String doctorsVerifiedSearch(String query) => "$baseUrl/doctors/verified/search?query=$query";

  static String get healthLatest => '$baseUrl/health/latest';
  static String get healthPush => '$baseUrl/health/push';

  // Supabase / Care Companion AI Config
  static const String supabaseUrl = "https://qhhsgflsrgvplnnxokqt.supabase.co";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFoaHNnZmxzcmd2cGxubnhva3F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5NjYxNDMsImV4cCI6MjA4NjU0MjE0M30.InOJf9S6R4MUzBKuvM8ChIjvEkgSD4NlFEu025WHmdk";
  static const String careCompanionChat = "$supabaseUrl/functions/v1/triage-chat";
  static const String careCompanionEmergency = "$supabaseUrl/functions/v1/trigger-emergency";
}
