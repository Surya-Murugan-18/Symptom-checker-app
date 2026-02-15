class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String? token;
  String? email;
  String? firstName;
  String? lastName;
  int? userId;
  String? gender;
  String? dob;
  String? location;
  String? contact;
  String? language;
  bool? hasChronicIllness;
  String? chronicIllnessDetails;
  bool? takesRegularMedicine;
  String? weight;
  String? bloodPressureLevel;
  String? photoUrl;
  List<Map<String, dynamic>>? emergencyContacts;

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    if (first.isEmpty && last.isEmpty) return 'User';
    return '$first $last'.trim();
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  void clear() {
    token = null;
    email = null;
    firstName = null;
    lastName = null;
    userId = null;
    gender = null;
    dob = null;
    location = null;
    contact = null;
    language = null;
    hasChronicIllness = null;
    chronicIllnessDetails = null;
    takesRegularMedicine = null;
    weight = null;
    bloodPressureLevel = null;
    photoUrl = null;
    emergencyContacts = null;
  }
}
