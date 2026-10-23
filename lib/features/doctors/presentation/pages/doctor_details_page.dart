import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_flow/core/theme/app_colors.dart';
import 'package:patient_flow/features/doctors/data/doctors_repository.dart';
import 'package:patient_flow/features/doctors/domain/doctor_model.dart';

class DoctorDetailsPage extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsPage({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  final DoctorsRepository _repository = DoctorsRepository();

  late Future<Doctor> _doctorFuture;

  @override
  void initState() {
    super.initState();
    _doctorFuture = _repository.getDoctorById(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: FutureBuilder<Doctor>(
        future: _doctorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 52,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load doctor details.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.text),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _doctorFuture =
                              _repository.getDoctorById(widget.doctorId);
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final doctor = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 230,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: doctor.imageUrl != null &&
                      doctor.imageUrl!.isNotEmpty
                      ? Image.network(
                    doctor.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.medical_services_rounded,
                        color: AppColors.primary,
                        size: 90,
                      );
                    },
                  )
                      : const Icon(
                    Icons.medical_services_rounded,
                    color: AppColors.primary,
                    size: 90,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  doctor.fullName,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.specialty,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: doctor.location,
                ),
                const SizedBox(height: 18),
                _DetailRow(
                  icon: Icons.work_outline_rounded,
                  title: 'Experience',
                  value: '${doctor.experienceYears} years',
                ),
                const SizedBox(height: 28),
                const Text(
                  'About Doctor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  doctor.about.isEmpty
                      ? 'No additional information available.'
                      : doctor.about,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.subtitle,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: () {
                      context.push('/appointments/book/${doctor.id}');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.subtitle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
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