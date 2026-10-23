import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:patient_flow/core/config/supabase_config.dart';
import 'package:patient_flow/features/auth/domain/user_role.dart';

class AuthConfigurationException implements Exception {
  final String message;

  const AuthConfigurationException(this.message);

  @override
  String toString() => message;
}

class AuthRoleException implements Exception {
  final String message;

  const AuthRoleException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  SupabaseClient get _client {
    if (!SupabaseConfig.isConfigured) {
      throw const AuthConfigurationException(
        'Please configure your Supabase URL and publishable key first',
      );
    }

    return Supabase.instance.client;
  }

  Future<void> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw const AuthRoleException(
        'Unable to sign in. Please try again.',
      );
    }

    final accountRole = user.appMetadata['role']?.toString();

    if (role == UserRole.admin && accountRole != 'admin') {
      await _client.auth.signOut();

      throw const AuthRoleException(
        'This account does not have administrator access.',
      );
    }

    if (role == UserRole.patient && accountRole == 'admin') {
      await _client.auth.signOut();

      throw const AuthRoleException(
        'This is an admin account. Please choose Admin.',
      );
    }
  }

  Future<bool> signUpPatient({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'role': 'patient',
      },
    );

    final requiresEmailConfirmation = response.session == null;

    if (response.session != null) {
      await _client.auth.signOut();
    }

    return requiresEmailConfirmation;
  }
}