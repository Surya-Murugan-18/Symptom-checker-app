class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type; // APPOINTMENT, MEDICATION, EMERGENCY, GENERAL
  final bool isRead;
  final DateTime createdAt;
  final int? appointmentId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.appointmentId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'GENERAL',
      isRead: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      appointmentId: json['appointmentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'read': isRead,
      'createdAt': createdAt.toIso8601String(),
      'appointmentId': appointmentId,
    };
  }
}
