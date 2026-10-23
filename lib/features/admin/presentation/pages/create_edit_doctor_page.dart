import 'package:flutter/material.dart';
import 'package:patient_flow/core/theme/app_colors.dart';
import 'package:patient_flow/features/doctors/data/doctors_repository.dart';
import 'package:patient_flow/features/doctors/domain/doctor_model.dart';

class CreateEditDoctorPage extends StatefulWidget {
  final String? doctorId;

  const CreateEditDoctorPage({
    super.key,
    this.doctorId,
  });

  @override
  State<CreateEditDoctorPage> createState() =>
      _CreateEditDoctorPageState();
}

class _CreateEditDoctorPageState
    extends State<CreateEditDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _aboutController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final DoctorsRepository _repository = DoctorsRepository();

  bool _isActive = true;
  bool _isSaving = false;
  bool _isLoadingDoctor = false;
  String? _loadError;

  bool get _isEditing => widget.doctorId != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _loadDoctor();
    }
  }

  Future<void> _loadDoctor() async {
    setState(() {
      _isLoadingDoctor = true;
      _loadError = null;
    });

    try {
      final doctor = await _repository.getDoctorById(
        widget.doctorId!,
      );

      if (!mounted) return;

      _fillForm(doctor);

      setState(() {
        _isLoadingDoctor = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingDoctor = false;
        _loadError = 'Unable to load doctor information.';
      });
    }
  }

  void _fillForm(Doctor doctor) {
    _nameController.text = doctor.fullName;
    _specialtyController.text = doctor.specialty;
    _locationController.text = doctor.location;
    _experienceController.text = doctor.experienceYears.toString();
    _aboutController.text = doctor.about;
    _imageUrlController.text = doctor.imageUrl ?? '';
    _isActive = doctor.isActive;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    final experienceYears = int.tryParse(
      _experienceController.text.trim(),
    );

    if (experienceYears == null || experienceYears < 0) {
      _showMessage('Enter a valid experience value.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final values = {
        'fullName': _nameController.text.trim(),
        'specialty': _specialtyController.text.trim(),
        'location': _locationController.text.trim(),
        'experienceYears': experienceYears,
        'about': _aboutController.text.trim(),
        'imageUrl': _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        'isActive': _isActive,
      };

      if (_isEditing) {
        await _repository.updateDoctor(
          id: widget.doctorId!,
          fullName: values['fullName'] as String,
          specialty: values['specialty'] as String,
          location: values['location'] as String,
          experienceYears: values['experienceYears'] as int,
          about: values['about'] as String,
          imageUrl: values['imageUrl'] as String?,
          isActive: values['isActive'] as bool,
        );
      } else {
        await _repository.createDoctor(
          fullName: values['fullName'] as String,
          specialty: values['specialty'] as String,
          location: values['location'] as String,
          experienceYears: values['experienceYears'] as int,
          about: values['about'] as String,
          imageUrl: values['imageUrl'] as String?,
          isActive: values['isActive'] as bool,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (_) {
      _showMessage(
        'Unable to save doctor. Please check your connection and permissions.',
      );
    }  finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _aboutController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDoctor) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Doctor')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Doctor')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loadDoctor,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Doctor' : 'Create Doctor'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                _isEditing
                    ? 'Update doctor information'
                    : 'Add a new doctor',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the doctor details below.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.subtitle,
                ),
              ),
              const SizedBox(height: 28),
              _FieldLabel(label: 'Full Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter doctor name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Doctor name is required';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'Specialty'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Cardiology',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Specialty is required';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'Location'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'City, area, or clinic address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'Experience in Years'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter years of experience',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
                validator: (value) {
                  final experience = int.tryParse(
                    value?.trim() ?? '',
                  );

                  if (experience == null || experience < 0) {
                    return 'Enter a valid number of years';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'About Doctor'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _aboutController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter doctor information',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'Image URL (Optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: 'https://example.com/doctor.png',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                validator: (value) {
                  final imageUrl = value?.trim() ?? '';

                  if (imageUrl.isEmpty) return null;

                  final uri = Uri.tryParse(imageUrl);

                  if (uri == null ||
                      !uri.hasScheme ||
                      (uri.scheme != 'https' && uri.scheme != 'http') ||
                      uri.host.isEmpty) {
                    return 'Enter a valid image URL';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                  title: const Text(
                    'Active Doctor',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  subtitle: const Text(
                    'Active doctors are visible to patients.',
                    style: TextStyle(
                      color: AppColors.subtitle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveDoctor,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 23,
                    width: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _isEditing ? 'Save Changes' : 'Create Doctor',
                    style: const TextStyle(
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
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}