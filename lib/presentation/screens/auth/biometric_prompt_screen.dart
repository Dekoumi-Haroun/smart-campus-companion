import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/biometric_service.dart';
import '../../blocs/auth/auth_cubit.dart';

/// Prompts the user for biometric verification before granting access.
///
/// Shown when a valid session exists and biometric login is enabled.
/// Automatically triggers the biometric prompt on screen load.
class BiometricPromptScreen extends StatefulWidget {
  const BiometricPromptScreen({super.key});

  @override
  State<BiometricPromptScreen> createState() => _BiometricPromptScreenState();
}

class _BiometricPromptScreenState extends State<BiometricPromptScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Trigger biometric prompt after the first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    final success = await _biometricService.authenticate();

    if (!mounted) return;
    setState(() => _isAuthenticating = false);

    if (success) {
      context.read<AuthCubit>().confirmBiometric();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fingerprint_rounded,
                  size: 96,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.biometricPromptTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.biometricPromptSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Retry button.
                if (!_isAuthenticating)
                  FilledButton.icon(
                    onPressed: _authenticate,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text(AppStrings.tryAgain),
                  ),

                if (_isAuthenticating) const CircularProgressIndicator(),

                const SizedBox(height: 20),

                // Fallback to password.
                TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().skipBiometric();
                  },
                  child: const Text(AppStrings.biometricFallback),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
