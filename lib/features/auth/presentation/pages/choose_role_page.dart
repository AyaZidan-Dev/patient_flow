import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_flow/core/theme/app_colors.dart';
import 'package:patient_flow/features/auth/domain/user_role.dart';

class ChooseRolePage extends StatelessWidget {
  const ChooseRolePage({super.key});

  void _openLogin(BuildContext context, UserRole role) {
    context.go('/login/${role.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/onboarding'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to Patient Flow',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose how you want to continue.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.subtitle,
                ),
              ),
              const SizedBox(height: 36),
              _RoleCard(
                icon: Icons.person_rounded,
                title: 'Continue as Patient',
                description: 'Find doctors and book your appointments.',
                onTap: () => _openLogin(context, UserRole.patient),
              ),
              const SizedBox(height: 18),
              _RoleCard(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Continue as Admin',
                description: 'Sign in to manage doctors and their information.',
                onTap: () => _openLogin(context, UserRole.admin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: AppColors.subtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}