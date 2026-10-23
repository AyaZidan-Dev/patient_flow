import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:patient_flow/features/doctors/domain/doctor_model.dart';

class DoctorsRepository {
  final SupabaseClient _client;

  DoctorsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Doctor _mapDoctor(dynamic row) {
    return Doctor.fromMap(
      Map<String, dynamic>.from(row as Map),
    );
  }

  Future<List<Doctor>> getActiveDoctors({
    String searchQuery = '',
  }) async {
    final response = await _client
        .from('doctors')
        .select()
        .eq('is_active', true)
        .order('full_name');

    final doctors = response.map(_mapDoctor).toList();
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return doctors;

    return doctors.where((doctor) {
      return doctor.fullName.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query) ||
          doctor.location.toLowerCase().contains(query);
    }).toList();
  }

  Future<List<Doctor>> getDoctorsForAdmin() async {
    final response = await _client
        .from('doctors')
        .select()
        .order('full_name');

    return response.map(_mapDoctor).toList();
  }

  Future<Doctor> getDoctorById(String id) async {
    final response = await _client
        .from('doctors')
        .select()
        .eq('id', id)
        .single();

    return _mapDoctor(response);
  }

  Map<String, dynamic> _doctorPayload({
    required String fullName,
    required String specialty,
    required String location,
    required int experienceYears,
    required String about,
    required String? imageUrl,
    required bool isActive,
  }) {
    return {
      'full_name': fullName.trim(),
      'specialty': specialty.trim(),
      'location': location.trim(),
      'experience_years': experienceYears,
      'about': about.trim(),
      'image_url': imageUrl == null || imageUrl.trim().isEmpty
          ? null
          : imageUrl.trim(),
      'is_active': isActive,
    };
  }

  Future<Doctor> createDoctor({
    required String fullName,
    required String specialty,
    required String location,
    required int experienceYears,
    required String about,
    required String? imageUrl,
    required bool isActive,
  }) async {
    final response = await _client
        .from('doctors')
        .insert(
      _doctorPayload(
        fullName: fullName,
        specialty: specialty,
        location: location,
        experienceYears: experienceYears,
        about: about,
        imageUrl: imageUrl,
        isActive: isActive,
      ),
    )
        .select()
        .single();

    return _mapDoctor(response);
  }

  Future<Doctor> updateDoctor({
    required String id,
    required String fullName,
    required String specialty,
    required String location,
    required int experienceYears,
    required String about,
    required String? imageUrl,
    required bool isActive,
  }) async {
    final payload = _doctorPayload(
      fullName: fullName,
      specialty: specialty,
      location: location,
      experienceYears: experienceYears,
      about: about,
      imageUrl: imageUrl,
      isActive: isActive,
    );

    payload['updated_at'] = DateTime.now().toUtc().toIso8601String();

    final response = await _client
        .from('doctors')
        .update(payload)
        .eq('id', id)
        .select()
        .single();

    return _mapDoctor(response);
  }
}