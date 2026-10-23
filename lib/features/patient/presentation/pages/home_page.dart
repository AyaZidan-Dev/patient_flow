import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_flow/core/theme/app_colors.dart';
import 'package:patient_flow/features/doctors/data/doctors_repository.dart';
import 'package:patient_flow/features/doctors/domain/doctor_model.dart';

class HomePage extends StatefulWidget {
  final String initialSearch;

  const HomePage({
    super.key,
    this.initialSearch = '',
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DoctorsRepository _repository = DoctorsRepository();

  late final TextEditingController _searchController;
  late Future<List<Doctor>> _doctorsFuture;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.initialSearch,
    );

    _doctorsFuture = _repository.getActiveDoctors(
      searchQuery: widget.initialSearch,
    );
  }

  void _searchDoctors(String query) {
    setState(() {
      _doctorsFuture = _repository.getActiveDoctors(
        searchQuery: query,
      );
    });
  }

  void _reloadDoctors() {
    setState(() {
      _doctorsFuture = _repository.getActiveDoctors(
        searchQuery: _searchController.text,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _reloadDoctors,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh doctors',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find Your Doctor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find the right care for your health.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.subtitle,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _searchController,
                onChanged: _searchDoctors,
                decoration: InputDecoration(
                  hintText: 'Search name, specialty, or location',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _searchDoctors('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Available Doctors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Doctor>>(
                  future: _doctorsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 52,
                              color: AppColors.subtitle,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Unable to load doctors.',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _reloadDoctors,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    }

                    final doctors = snapshot.data ?? [];

                    if (doctors.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 56,
                              color: AppColors.subtitle,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No doctors available yet.'
                                  : 'No doctors match your search.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.subtitle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: doctors.length,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];

                        return _DoctorCard(
                          doctor: doctor,
                          onTap: () {
                            context.push('/doctors/${doctor.id}');
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 76,
                  height: 86,
                  child: doctor.imageUrl != null &&
                      doctor.imageUrl!.isNotEmpty
                      ? Image.network(
                    doctor.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const _DoctorPlaceholder();
                    },
                  )
                      : const _DoctorPlaceholder(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.subtitle,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.subtitle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${doctor.experienceYears} years experience',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.subtitle,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorPlaceholder extends StatelessWidget {
  const _DoctorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Icon(
        Icons.medical_services_rounded,
        color: AppColors.primary,
        size: 34,
      ),
    );
  }
}