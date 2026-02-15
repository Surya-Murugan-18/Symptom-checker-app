import 'package:symtom_checker/models/doctor_model.dart';

class Patient {
  final int id;
  final String firstName;
  final String lastName;
  final String? gender;
  final int? age;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.age,
  });

  String get fullName => '$firstName $lastName';

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'],
      age: json['age'],
    );
  }
}

class Appointment {
  final int id;
  final Doctor doctor;
  final Patient? patient;
  final DateTime date;
  final String time; // e.g., "10:30 AM"
  final String status; // PENDING, ACCEPTED, PAID, COMPLETED, CANCELED
  final String? reason;
  final bool paid;

  Appointment({
    required this.id,
    required this.doctor,
    this.patient,
    required this.date,
    required this.time,
    required this.status,
    this.reason,
    this.paid = false,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctor: Doctor.fromJson(json['doctor']),
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      status: json['status'] ?? 'PENDING',
      reason: json['reason'],
      paid: json['paid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': doctor.toJson(),
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'status': status,
      'reason': reason,
      'paid': paid,
    };
  }
}
