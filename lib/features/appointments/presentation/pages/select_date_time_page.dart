import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_flow/core/theme/app_colors.dart';
import 'package:patient_flow/features/doctors/data/doctors_repository.dart';
import 'package:patient_flow/features/doctors/domain/doctor_model.dart';
import 'package:patient_flow/features/appointments/data/appointments_repository.dart';
import 'package:patient_flow/features/appointments/domain/appointment_model.dart';

class SelectDateTimePage extends StatefulWidget {
  final String doctorId;

  const SelectDateTimePage({
    super.key,
    required this.doctorId,
  });

  @override
  State<SelectDateTimePage> createState() =>
      _SelectDateTimePageState();
}

class _SelectDateTimePageState extends State<SelectDateTimePage> {
  final DoctorsRepository _doctorsRepository = DoctorsRepository();
  final AppointmentsRepository _appointmentsRepository =
  AppointmentsRepository();

  late Future<Doctor> _doctorFuture;
  late DateTime _selectedDate;

  TimeOfDay? _selectedTime;
  Set<String> _bookedTimes = {};

  bool _isBooking = false;
  bool _isLoadingBookedTimes = true;
  bool _availabilityError = false;

  int _availabilityRequestId = 0;

  static const List<TimeOfDay> _availableTimes = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 9, minute: 30),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 10, minute: 30),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 11, minute: 30),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 13, minute: 30),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 14, minute: 30),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    _doctorFuture = _doctorsRepository.getDoctorById(
      widget.doctorId,
    );

    _loadBookedTimes();
  }

  String _timeKey(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  bool _isFutureTime(TimeOfDay time) {
    final slot = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );

    return slot.isAfter(DateTime.now());
  }

  Future<void> _loadBookedTimes() async {
    final requestId = ++_availabilityRequestId;
    final date = _selectedDate;

    setState(() {
      _isLoadingBookedTimes = true;
      _availabilityError = false;
      _bookedTimes = {};
      _selectedTime = null;
    });

    try {
      final bookedTimes =
      await _appointmentsRepository.getBookedAppointmentTimes(
        doctorId: widget.doctorId,
        date: date,
      );

      if (!mounted || requestId != _availabilityRequestId) return;

      setState(() {
        _bookedTimes = bookedTimes;
      });
    } catch (_) {
      if (!mounted || requestId != _availabilityRequestId) return;

      setState(() {
        _availabilityError = true;
      });
    } finally {
      if (mounted && requestId == _availabilityRequestId) {
        setState(() {
          _isLoadingBookedTimes = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      helpText: 'Select Appointment Date',
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    });

    await _loadBookedTimes();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _findAnotherDoctor(Doctor doctor) {
    final uri = Uri(
      path: '/home',
      queryParameters: {
        'search': doctor.specialty,
      },
    );

    context.go(uri.toString());
  }

  Future<void> _showSlotUnavailableDialog(Doctor doctor) async {
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.event_busy_rounded,
            color: AppColors.primary,
            size: 44,
          ),
          title: const Text(
            'This time is unavailable',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'This appointment time has already been booked. '
                'You can choose another available time or find another '
                'doctor in the same specialty.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop('time');
                },
                child: const Text('Choose Another Time'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop('doctor');
                },
                child: const Text('Find Another Doctor'),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (action == 'time') {
      await _loadBookedTimes();
    } else if (action == 'doctor') {
      _findAnotherDoctor(doctor);
    }
  }

  Future<void> _bookAppointment(Doctor doctor) async {
    final selectedTime = _selectedTime;

    if (selectedTime == null) {
      _showMessage('Please select an available time.');
      return;
    }

    if (_availabilityError || _isLoadingBookedTimes) {
      _showMessage('Please check appointment availability first.');
      return;
    }

    if (_bookedTimes.contains(_timeKey(selectedTime))) {
      await _showSlotUnavailableDialog(doctor);
      await _loadBookedTimes();
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final appointment =
      await _appointmentsRepository.createAppointment(
        doctorId: doctor.id,
        date: _selectedDate,
        hour: selectedTime.hour,
        minute: selectedTime.minute,
      );

      if (!mounted) return;

      final scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      context.go(
        '/appointments/success',
        extra: AppointmentConfirmation(
          appointmentId: appointment.id,
          doctorName: doctor.fullName,
          location: doctor.location,
          scheduledAt: scheduledAt,
        ),
      );
    } on AppointmentBookingException catch (error) {
      if (!mounted) return;

      if (error.slotUnavailable) {
        await _loadBookedTimes();

        if (!mounted) return;

        await _showSlotUnavailableDialog(doctor);
      } else {
        _showMessage(error.message);
      }
    } catch (_) {
      _showMessage(
        'Unable to book this appointment. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
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
                    const Text(
                      'Unable to load doctor information.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _doctorFuture =
                              _doctorsRepository.getDoctorById(
                                widget.doctorId,
                              );
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

          final visibleTimes = _availableTimes
              .where(_isFutureTime)
              .toList();

          final hasBookedTimes = visibleTimes.any(
                (time) => _bookedTimes.contains(_timeKey(time)),
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose Your Appointment',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select your preferred date and time.',
                        style: TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                          ),
                          label: Text(
                            MaterialLocalizations.of(context)
                                .formatMediumDate(_selectedDate),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Available Times',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_isLoadingBookedTimes)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_availabilityError)
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Unable to check available times.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.error),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _loadBookedTimes,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else if (visibleTimes.isEmpty)
                          const Text(
                            'No future time slots are available. Please choose another date.',
                            style: TextStyle(
                              color: AppColors.subtitle,
                              height: 1.5,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 12,
                            children: visibleTimes.map((time) {
                              final isBooked =
                              _bookedTimes.contains(_timeKey(time));

                              final isSelected =
                                  _selectedTime?.hour == time.hour &&
                                      _selectedTime?.minute == time.minute;

                              return SizedBox(
                                width: 100,
                                child: Column(
                                  children: [
                                    ChoiceChip(
                                      label: Text(time.format(context)),
                                      selected: isSelected,
                                      onSelected: _isBooking
                                          ? null
                                          : (selected) async {
                                        if (isBooked) {
                                          await _showSlotUnavailableDialog(
                                            doctor,
                                          );
                                          return;
                                        }

                                        setState(() {
                                          _selectedTime =
                                          selected ? time : null;
                                        });
                                      },
                                      selectedColor: AppColors.primary,
                                      backgroundColor: isBooked
                                          ? AppColors.error.withOpacity(0.08)
                                          : AppColors.white,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? AppColors.white
                                            : isBooked
                                            ? AppColors.error
                                            : AppColors.text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      side: BorderSide(
                                        color: isBooked
                                            ? AppColors.error.withOpacity(0.4)
                                            : isSelected
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    if (isBooked)
                                      const Text(
                                        'Booked',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.error,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      if (!_isLoadingBookedTimes &&
                          !_availabilityError &&
                          hasBookedTimes) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Some times are already booked.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Choose another available time, or find another doctor in the same specialty.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColors.subtitle,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _findAnotherDoctor(doctor);
                                  },
                                  icon: const Icon(
                                    Icons.search_rounded,
                                  ),
                                  label: const Text(
                                    'Find Another Doctor',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _isBooking ||
                        _isLoadingBookedTimes ||
                        _availabilityError ||
                        _selectedTime == null
                        ? null
                        : () => _bookAppointment(doctor),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isBooking
                        ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Confirm Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}