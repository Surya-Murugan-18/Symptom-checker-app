class Doctor {
  final int? id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? specialization;
  final String? qualification;
  final int? experienceYears;
  final String? hospital;
  final double rating;
  final String? photoUrl;
  final String? phone;
  final double? consultationFee;
  final String? description;
  final String? distanceText;
  final bool isVerified;
  final String? gender;
  final String? location;

  Doctor({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.specialization,
    this.qualification,
    this.experienceYears,
    this.hospital,
    this.rating = 0.0,
    this.photoUrl,
    this.phone,
    this.consultationFee,
    this.description,
    this.distanceText,
    this.isVerified = false,
    this.gender,
    this.location,
  });

  String get fullName => 'Dr. $firstName $lastName';

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      specialization: json['specialization'] ?? 'General',
      qualification: json['qualification'],
      experienceYears: json['experienceYears'],
      hospital: json['hospital'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      photoUrl: json['photoUrl'] ?? json['profileImageUrl'],
      phone: json['phone'],
      consultationFee: json['consultationFee'] != null
          ? (json['consultationFee']).toDouble()
          : null,
      description: json['description'],
      distanceText: json['distanceText'] ?? '800m away',
      isVerified: json['verified'] ?? json['isVerified'] ?? false,
      gender: json['gender'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'specialization': specialization,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'hospital': hospital,
      'rating': rating,
      'photoUrl': photoUrl,
      'phone': phone,
      'consultationFee': consultationFee,
      'description': description,
      'distanceText': distanceText,
      'isVerified': isVerified,
      'gender': gender,
      'location': location,
    };
  }
}
