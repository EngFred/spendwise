import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_button.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final success = await BiometricService.instance.authenticate();
      if (!mounted) return;

      if (success) {
        ref.read(sessionUnlockedProvider.notifier).unlock();
        context.go('/dashboard');
      } else {
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
            _errorMessage = 'Authentication failed. Try again.';
          });
        }
      }
    } on BiometricException catch (e) {
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _errorMessage = 'Something went wrong. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon + Title (always the same)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                AppStrings.appName,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Your finances are locked',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: AppSizes.xxl),

              // ── DYNAMIC BOTTOM SECTION ──
              // We wrap EVERY state in a full-width container.
              // This prevents the layout from shifting left when switching states.
              SizedBox(
                width: double.infinity,
                child: _isAuthenticating
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            'Verifying your identity...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_errorMessage != null) ...[
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: AppColors.expense,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: AppSizes.lg),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: 'Unlock with Biometrics',
                              onPressed: _authenticate,
                              icon: Icons.fingerprint,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
