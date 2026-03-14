import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../providers/onboarding_provider.dart';
import '../../../shared/widgets/app_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      emoji: '💰',
      title: 'Take Control\nof Your Money',
      subtitle:
          'Track every shilling you earn and spend. Know exactly where your money goes every day.',
      color: AppColors.primary,
    ),
    _OnboardingPage(
      emoji: '📊',
      title: 'Smart Budgets\nfor Every Category',
      subtitle:
          'Set spending limits on food, transport, entertainment and more. Get alerted before you overspend.',
      color: Color(0xFF4ECDC4),
    ),
    _OnboardingPage(
      emoji: '🎯',
      title: 'Reach Your\nSavings Goals',
      subtitle:
          'Planning to buy a laptop, travel, or save for rent? Set goals and track your progress visually.',
      color: Color(0xFF6BCB77),
    ),
    _OnboardingPage(
      emoji: '🔒',
      title: '100% Private\n& Offline',
      subtitle:
          'All your data stays on your device. No internet required. No accounts. Just you and your finances.',
      color: Color(0xFFC77DFF),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) =>
                    _OnboardingPageView(page: _pages[i]),
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? _pages[_currentPage].color
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: AppButton(
                label: _currentPage == _pages.length - 1
                    ? 'Get Started 🚀'
                    : 'Next',
                onPressed: _nextPage,
              ),
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

// ── Page data model ───────────────────────────────────────────────────────────

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

// ── Page view widget ──────────────────────────────────────────────────────────

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 72)),
            ),
          ),

          const SizedBox(height: AppSizes.xxl),

          Text(
            page.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSizes.md),

          Text(
            page.subtitle,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
