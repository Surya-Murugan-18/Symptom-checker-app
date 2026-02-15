class DoctorSession {
  static final DoctorSession _instance = DoctorSession._internal();
  factory DoctorSession() => _instance;
  DoctorSession._internal();

  String? token;
  int? doctorId;
  String? firstName;
  String? lastName;
  String? email;
  String? specialization;
  String? photoUrl;
  String? phone;

  String get fullName {
    final f = firstName ?? '';
    final l = lastName ?? '';
    return '$f $l'.trim();
  }

  void clear() {
    token = null;
    doctorId = null;
    firstName = null;
    lastName = null;
    email = null;
    specialization = null;
    photoUrl = null;
    phone = null;
  }
}
