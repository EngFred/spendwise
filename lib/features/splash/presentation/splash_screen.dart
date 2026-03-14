import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/onboarding/providers/onboarding_provider.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../core/router/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    // Hide system UI for full immersion during splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Navigate after animations complete
    Future.delayed(const Duration(seconds: 7), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final isOnboardingDone = ref.read(onboardingProvider).value ?? false;
    if (!isOnboardingDone) {
      context.go('/onboarding');
      return;
    }

    final settings = ref.read(settingsProvider).value;
    if (settings != null && settings.biometricLock) {
      // Lock session so the router redirect sends to /lock
      ref.read(sessionUnlockedProvider.notifier).lock();
      context.go('/lock');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: Stack(
        children: [
          // ── Animated background gradient blobs ──────────────────────
          _AnimatedBlob(
            controller: _particleController,
            color: AppColors.primary.withOpacity(0.15),
            size: size.width * 0.8,
            offsetFactor: 0.2,
            xAlign: -0.3,
            yAlign: -0.5,
          ),
          _AnimatedBlob(
            controller: _particleController,
            color: const Color(0xFF10B981).withOpacity(0.08),
            size: size.width * 0.6,
            offsetFactor: 0.15,
            xAlign: 0.6,
            yAlign: 0.4,
            phaseShift: 0.5,
          ),

          // ── Dot grid overlay ────────────────────────────────────────
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

          // ── Main content ────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with layered animations
                _buildLogo(),
                const SizedBox(height: 32),
                // App name
                _buildAppName(),
                const SizedBox(height: 8),
                // Tagline
                _buildTagline(),
                const SizedBox(height: 64),
                // Loading indicator
                _buildLoader(),
              ],
            ),
          ),

          // ── Bottom version text ─────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Version 1.0.0',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.2),
                letterSpacing: 1.5,
              ),
            ).animate(delay: 2000.ms).fadeIn(duration: 600.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
            )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.5, 1.5),
              duration: 1200.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(duration: 800.ms),

        // Inner ring
        Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
            )
            .animate(delay: 200.ms)
            .scale(
              begin: const Offset(0.0, 0.0),
              end: const Offset(1.0, 1.0),
              duration: 800.ms,
              curve: Curves.elasticOut,
            ),

        // Logo image
        Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            )
            .animate(delay: 100.ms)
            .scale(
              begin: const Offset(0.0, 0.0),
              end: const Offset(1.0, 1.0),
              duration: 700.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildAppName() {
    const name = 'SpendWise';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(name.length, (i) {
        return Text(
              name[i],
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withOpacity(0.6),
                    blurRadius: 20,
                  ),
                ],
              ),
            )
            .animate(delay: Duration(milliseconds: 600 + (i * 60)))
            .slideY(
              begin: 0.5,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: 400.ms);
      }),
    );
  }

  Widget _buildTagline() {
    return Text(
          'Track · Save · Grow',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.45),
            letterSpacing: 3,
          ),
        )
        .animate(delay: 1400.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildLoader() {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          // Animated progress bar
          ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withOpacity(0.8),
                  ),
                  minHeight: 3,
                ),
              )
              .animate(delay: 1600.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.5, end: 0, duration: 400.ms),
        ],
      ),
    );
  }
}

// ── Animated background blob ─────────────────────────────────────────────────

class _AnimatedBlob extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double size;
  final double offsetFactor;
  final double xAlign;
  final double yAlign;
  final double phaseShift;

  const _AnimatedBlob({
    required this.controller,
    required this.color,
    required this.size,
    required this.offsetFactor,
    required this.xAlign,
    required this.yAlign,
    this.phaseShift = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final phase = (controller.value + phaseShift) % 1.0;
        final offset = offsetFactor * (0.5 - (phase - 0.5).abs() * 2);
        return Align(
          alignment: Alignment(xAlign + offset, yAlign + offset * 0.5),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
            ),
          ),
        );
      },
    );
  }
}

// ── Dot grid painter ─────────────────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}
