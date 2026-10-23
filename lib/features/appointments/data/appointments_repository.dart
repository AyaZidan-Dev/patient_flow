import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:patient_flow/features/appointments/domain/appointment_model.dart';

class AppointmentBookingException implements Exception {
  final String message;
  final bool slotUnavailable;

  const AppointmentBookingException(
      this.message, {
        this.slotUnavailable = false,
      });

  @override
  String toString() => message;
}

class AppointmentsRepository {
  final SupabaseClient _client;

  AppointmentsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:00';
  }

  Future<Set<String>> getBookedAppointmentTimes({
    required String doctorId,
    required DateTime date,
  }) async {
    final response = await _client.rpc(
      'get_booked_appointment_times',
      params: {
        'p_doctor_id': doctorId,
        'p_appointment_date': _formatDate(date),
      },
    );

    if (response is! List) {
      return <String>{};
    }

    return response.map((row) {
      final item = Map<String, dynamic>.from(row as Map);
      final value = item['appointment_time']?.toString() ?? '';

      return value.length >= 5 ? value.substring(0, 5) : value;
    }).where((value) {
      return RegExp(r'^\d{2}:\d{2}$').hasMatch(value);
    }).toSet();
  }

  Future<Appointment> createAppointment({
    required String doctorId,
    required DateTime date,
    required int hour,
    required int minute,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw const AppointmentBookingException(
        'Please log in before booking an appointment.',
      );
    }

    try {
      final response = await _client
          .from('appointments')
          .insert({
        'patient_id': user.id,
        'doctor_id': doctorId,
        'appointment_date': _formatDate(date),
        'appointment_time': _formatTime(hour, minute),
      })
          .select()
          .single();

      return Appointment.fromMap(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const AppointmentBookingException(
          'This time slot has just been booked.',
          slotUnavailable: true,
        );
      }

      if (error.code == '42501') {
        throw const AppointmentBookingException(
          'You do not have permission to book this appointment.',
        );
      }

      throw AppointmentBookingException(
        'Could not save the appointment: ${error.message}',
      );
    }
  }
}