class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      doctorId: map['doctor_id'] as String,
      appointmentDate: DateTime.parse(
        map['appointment_date'] as String,
      ),
      appointmentTime: map['appointment_time'] as String,
      status: map['status'] as String,
    );
  }
}

class AppointmentConfirmation {
  final String appointmentId;
  final String doctorName;
  final String location;
  final DateTime scheduledAt;

  const AppointmentConfirmation({
    required this.appointmentId,
    required this.doctorName,
    required this.location,
    required this.scheduledAt,
  });
}