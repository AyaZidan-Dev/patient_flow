import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_flow/core/theme/app_colors.dart';
import 'package:patient_flow/features/doctors/data/doctors_repository.dart';
import 'package:patient_flow/features/doctors/domain/doctor_model.dart';

class AdminDoctorsPage extends StatefulWidget {
  const AdminDoctorsPage({super.key});

  @override
  State<AdminDoctorsPage> createState() => _AdminDoctorsPageState();
}

class _AdminDoctorsPageState extends State<AdminDoctorsPage> {
  final DoctorsRepository _repository = DoctorsRepository();
  final TextEditingController _searchController =
  TextEditingController();

  late Future<List<Doctor>> _doctorsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _repository.getDoctorsForAdmin();
  }

  void _reloadDoctors() {
    setState(() {
      _doctorsFuture = _repository.getDoctorsForAdmin();
    });
  }

  Future<void> _openCreatePage() async {
    final result = await context.push<bool>('/admin/doctors/new');

    if (result == true && mounted) {
      _reloadDoctors();
    }
  }

  Future<void> _openEditPage(Doctor doctor) async {
    final result = await context.push<bool>(
      '/admin/doctors/${doctor.id}/edit',
    );

    if (result == true && mounted) {
      _reloadDoctors();
    }
  }

  Future<void> _refreshDoctors() async {
    final future = _repository.getDoctorsForAdmin();

    setState(() {
      _doctorsFuture = future;
    });

    try {
      await future;
    } catch (_) {}
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
        title: const Text(
          'Doctors Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _reloadDoctors,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh doctors',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePage,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Doctor'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage your doctors',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add new doctors or update their information.',
                style: TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search doctors',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                            const Text(
                              'Unable to load doctors.',
                              style: TextStyle(
                                color: AppColors.text,
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

                    final allDoctors = snapshot.data ?? [];

                    final doctors = allDoctors.where((doctor) {
                      return doctor.fullName
                          .toLowerCase()
                          .contains(_searchQuery) ||
                          doctor.specialty
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          doctor.location
                              .toLowerCase()
                              .contains(_searchQuery);
                    }).toList();

                    if (doctors.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refreshDoctors,
                        child: ListView(
                          physics:
                          const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 100),
                            Icon(
                              Icons.medical_services_outlined,
                              size: 60,
                              color: AppColors.subtitle.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                allDoctors.isEmpty
                                    ? 'No doctors added yet.'
                                    : 'No doctors match your search.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.subtitle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshDoctors,
                      child: ListView.separated(
                        physics:
                        const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: doctors.length,
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];

                          return _AdminDoctorCard(
                            doctor: doctor,
                            onEdit: () => _openEditPage(doctor),
                          );
                        },
                      ),
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

class _AdminDoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onEdit;

  const _AdminDoctorCard({
    required this.doctor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: AppColors.primary,
              size: 28,
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
                const SizedBox(height: 5),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  doctor.location,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: doctor.isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: doctor.isActive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primary,
            tooltip: 'Edit doctor',
          ),
        ],
      ),
    );
  }
}