import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/constants/app_assets.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/theme/app_colors.dart';
import 'package:werdi/core/theme/app_durations.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:werdi/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _exitController;
  Timer? _navTimer;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _exitController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _navTimer = Timer(const Duration(milliseconds: 2800), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted || _navigating) return;
    _navigating = true;
    await _exitController.forward();
    if (!mounted) return;
    final done = await OnboardingPage.isCompleted();
    if (!mounted) return;
    context.goNamed(done ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _pulseController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoSize = (MediaQuery.sizeOf(context).width * 0.4).clamp(130.0, 200.0);
    final glow = isDark ? AppColors.brandAccent : AppColors.brandPrimary;

    return AppScaffold(
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          final exit = Curves.easeInCubic.transform(_exitController.value);
          return Opacity(
            opacity: 1 - exit,
            child: Transform.scale(
              scale: 1 - (exit * 0.08),
              child: child,
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: logoSize + 90,
                height: logoSize + 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size.square(logoSize + 90),
                          painter: _RipplePainter(
                            progress: _pulseController.value,
                            color: glow,
                          ),
                        );
                      },
                    ),
                    Image.asset(
                      AppAssets.logo,
                      width: logoSize,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .fadeIn(duration: 700.ms, curve: Curves.easeOutCubic)
                        .scale(
                          begin: const Offset(0.65, 0.65),
                          end: const Offset(1, 1),
                          duration: 900.ms,
                          curve: Curves.easeOutBack,
                        )
                        .then(delay: 150.ms)
                        .shimmer(
                          duration: 1100.ms,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.authWelcomeTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              )
                  .animate(delay: 280.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.25, end: 0),
              const SizedBox(height: 8),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ).animate(delay: 400.ms).fadeIn(duration: 450.ms),
              const SizedBox(height: 40),
              const _LoadingDots(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.55, 0.55),
              end: const Offset(1, 1),
              delay: (index * 140).ms,
              duration: 550.ms,
            );
      }),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final radius = (size.shortestSide / 2) * (0.5 + phase * 0.4);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = color.withValues(alpha: (1 - phase) * 0.4);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
