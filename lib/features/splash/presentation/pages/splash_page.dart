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
      duration: AppDurations.pulse,
    )..repeat(reverse: true);
    _exitController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );

    _navTimer = Timer(const Duration(milliseconds: 2400), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted || _navigating) return;
    _navigating = true;
    await _exitController.forward();
    if (!mounted) return;
    context.goNamed(AppRoutes.onboarding);
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
    final logoSize = (MediaQuery.sizeOf(context).width * 0.42).clamp(140.0, 220.0);
    final glow = isDark ? AppColors.brandAccent : AppColors.brandPrimary;

    return AppScaffold(
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          final exit = Curves.easeInCubic.transform(_exitController.value);
          return Opacity(
            opacity: 1 - exit,
            child: Transform.scale(
              scale: 1 - (exit * 0.06),
              child: child,
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: logoSize + 80,
                height: logoSize + 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size.square(logoSize + 80),
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
                        .fadeIn(
                          duration: AppDurations.slow,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.72, 0.72),
                          end: const Offset(1, 1),
                          duration: AppDurations.slow,
                          curve: Curves.easeOutBack,
                        )
                        .then(delay: 200.ms)
                        .shimmer(
                          duration: 900.ms,
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.authWelcomeTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
              )
                  .animate(delay: 350.ms)
                  .fadeIn(duration: AppDurations.normal)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 8),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              )
                  .animate(delay: 480.ms)
                  .fadeIn(duration: AppDurations.normal)
                  .slideY(begin: 0.15, end: 0),
              const SizedBox(height: 36),
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
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
              delay: (index * 120).ms,
              duration: 500.ms,
              curve: Curves.easeInOut,
            )
            .fadeIn(delay: (index * 120).ms);
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
    for (var i = 0; i < 2; i++) {
      final phase = (progress + i * 0.5) % 1.0;
      final radius = (size.shortestSide / 2) * (0.55 + phase * 0.35);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: (1 - phase) * 0.35);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
