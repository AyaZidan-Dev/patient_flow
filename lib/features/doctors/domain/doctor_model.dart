class Doctor {
  final String id;
  final String fullName;
  final String specialty;
  final String location;
  final int experienceYears;
  final String about;
  final String? imageUrl;
  final bool isActive;

  const Doctor({
    required this.id,
    required this.fullName,
    required this.specialty,
    required this.location,
    required this.experienceYears,
    required this.about,
    required this.imageUrl,
    required this.isActive,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      specialty: map['specialty'] as String,
      location: map['location'] as String,
      experienceYears:
      (map['experience_years'] as num?)?.toInt() ?? 0,
      about: map['about'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}