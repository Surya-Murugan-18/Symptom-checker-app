
class Appointment {
  final int id;
  final String date;
  final String time;
  final String status;
  final String? type;
  final String? doctorName;
  final String? location;
  final String? notes;
  final bool isPersonal;
  final Map<String, dynamic>? doctor; // For platform bookings

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    this.type,
    this.doctorName,
    this.location,
    this.notes,
    this.isPersonal = false,
    this.doctor,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'PENDING',
      type: json['type'],
      doctorName: json['doctorName'],
      location: json['location'],
      notes: json['notes'],
      isPersonal: json['isPersonal'] ?? false,
      doctor: json['doctor'],
    );
  }

  // Helper to get display name
  String get displayDoctorName {
    if (isPersonal) {
      return doctorName ?? 'Unknown Doctor';
    } else if (doctor != null) {
      final firstName = doctor!['firstName'] ?? '';
      final lastName = doctor!['lastName'] ?? '';
      return "Dr. $firstName $lastName";
    }
    return 'Unknown Doctor';
  }

  // Helper to get location
  String get displayLocation {
    if (isPersonal) {
      return location ?? 'Not specified';
    } else if (doctor != null) {
      return doctor!['hospitalName'] ?? doctor!['location'] ?? 'Clinic';
    }
    return 'Not specified';
  }
}
