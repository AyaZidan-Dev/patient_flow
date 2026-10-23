import 'package:go_router/go_router.dart';
import 'package:patient_flow/features/admin/presentation/pages/admin_doctors_page.dart';
import 'package:patient_flow/features/admin/presentation/pages/create_edit_doctor_page.dart';
import 'package:patient_flow/features/appointments/domain/appointment_model.dart';
import 'package:patient_flow/features/appointments/presentation/pages/appointment_success_page.dart';
import 'package:patient_flow/features/appointments/presentation/pages/select_date_time_page.dart';
import 'package:patient_flow/features/auth/domain/user_role.dart';
import 'package:patient_flow/features/auth/presentation/pages/choose_role_page.dart';
import 'package:patient_flow/features/auth/presentation/pages/login_page.dart';
import 'package:patient_flow/features/auth/presentation/pages/sign_up_page.dart';
import 'package:patient_flow/features/doctors/presentation/pages/doctor_details_page.dart';
import 'package:patient_flow/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:patient_flow/features/patient/presentation/pages/home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/choose-role',
      builder: (context, state) => const ChooseRolePage(),
    ),
    GoRoute(
      path: '/login/:role',
      builder: (context, state) {
        final roleName = state.pathParameters['role'];

        final role = UserRole.values.firstWhere(
              (item) => item.name == roleName,
          orElse: () => UserRole.patient,
        );

        return LoginPage(role: role);
      },
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return HomePage(
          initialSearch: state.uri.queryParameters['search'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/doctors/:id',
      builder: (context, state) {
        return DoctorDetailsPage(
          doctorId: state.pathParameters['id']!,
        );
      },
    ),
    GoRoute(
      path: '/appointments/book/:doctorId',
      builder: (context, state) {
        return SelectDateTimePage(
          doctorId: state.pathParameters['doctorId']!,
        );
      },
    ),
    GoRoute(
      path: '/appointments/success',
      builder: (context, state) {
        final confirmation = state.extra;

        return AppointmentSuccessPage(
          confirmation: confirmation is AppointmentConfirmation
              ? confirmation
              : null,
        );
      },
    ),
    GoRoute(
      path: '/admin/doctors',
      builder: (context, state) => const AdminDoctorsPage(),
    ),
    GoRoute(
      path: '/admin/doctors/new',
      builder: (context, state) => const CreateEditDoctorPage(),
    ),
    GoRoute(
      path: '/admin/doctors/:id/edit',
      builder: (context, state) {
        return CreateEditDoctorPage(
          doctorId: state.pathParameters['id']!,
        );
      },
    ),
  ],
);