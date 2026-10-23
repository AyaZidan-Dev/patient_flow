import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_flow/core/theme/app_colors.dart';
import 'package:patient_flow/features/appointments/domain/appointment_model.dart';

class AppointmentSuccessPage extends StatelessWidget {
  final AppointmentConfirmation? confirmation;

  const AppointmentSuccessPage({
    super.key,
    this.confirmation,
  });

  @override
  Widget build(BuildContext context) {
    final appointment = confirmation;

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointment Status')),
        body: const Center(
          child: Text('Appointment confirmation is unavailable.'),
        ),
      );
    }

    final date = MaterialLocalizations.of(context)
        .formatMediumDate(appointment.scheduledAt);

    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(appointment.scheduledAt),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 76,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Appointment Booked!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your appointment has been saved successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.subtitle,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ConfirmationRow(
                        icon: Icons.medical_services_rounded,
                        label: 'Doctor',
                        value: appointment.doctorName,
                      ),
                      const SizedBox(height: 20),
                      _ConfirmationRow(
                        icon: Icons.calendar_month_rounded,
                        label: 'Date',
                        value: date,
                      ),
                      const SizedBox(height: 20),
                      _ConfirmationRow(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value: time,
                      ),
                      const SizedBox(height: 20),
                      _ConfirmationRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: appointment.location,
                      ),
                      const SizedBox(height: 20),
                      _ConfirmationRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Booking ID',
                        value: appointment.appointmentId,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: () => context.go('/home'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.subtitle,
                ),
              ),
              const SizedBox(height: 5),
              SelectableText(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}