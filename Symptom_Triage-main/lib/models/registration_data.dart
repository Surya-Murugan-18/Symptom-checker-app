class RegistrationData {
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? dob;
  String? age;
  String? gender;
  String? location;
  String? contact;
  List<Map<String, dynamic>> emergencyContacts = [];
  bool hasChronicIllness = false;
  String? chronicIllnessDetails;
  bool takesRegularMedicine = false;
  String? bloodPressureLevel;

  RegistrationData({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.dob,
    this.age,
    this.gender,
    this.location,
    this.contact,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'dob': dob,
      'age': int.tryParse(age ?? '0'),
      'gender': gender,
      'location': location,
      'phoneNumber': contact,
      'emergencyContacts': emergencyContacts,
      'hasChronicIllness': hasChronicIllness,
      'chronicIllnessDetails': chronicIllnessDetails,
      'takesRegularMedicine': takesRegularMedicine,
      'bloodPressureLevel': bloodPressureLevel,
    };
  }
}
