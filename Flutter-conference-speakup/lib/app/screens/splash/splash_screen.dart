import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/animations/screen_animations.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/image_strings.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/text_strings.dart';
import 'package:flutter_conference_speakup/core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Core animations
  late BrandRevealAnim _emblemAnim;
  late GlowPulseAnim _glowAnim;
  late SlideUpFadeAnim _logoAnim;
  late FadeInAnim _taglineAnim;
  late StaggeredCascadeAnim _featureAnim;
  late ExitAnim _exitAnim;

  // Pulse rings (2 staggered)
  late RingPulseAnim _ring1;
  late RingPulseAnim _ring2;

  // Shimmer bar
  late AnimationController _shimmerController;
  late Animation<double> _shimmerValue;

  @override
  void initState() {
    super.initState();

    _emblemAnim = BrandRevealAnim(vsync: this, duration: const Duration(milliseconds: 1000));
    _glowAnim = GlowPulseAnim(vsync: this);
    _logoAnim = SlideUpFadeAnim(vsync: this, beginOffset: const Offset(0, 0.25));
    _taglineAnim = FadeInAnim(vsync: this, duration: const Duration(milliseconds: 800));
    _featureAnim = StaggeredCascadeAnim(
      vsync: this,
      itemCount: 3,
      totalDuration: const Duration(milliseconds: 1000),
      beginOffset: const Offset(0, 0.2),
    );
    _exitAnim = ExitAnim(vsync: this);

    _ring1 = RingPulseAnim(vsync: this, duration: const Duration(milliseconds: 2800));
    _ring2 = RingPulseAnim(vsync: this, duration: const Duration(milliseconds: 2800));

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shimmerValue = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));

    // Phase 1: logo + tagline show first
    _logoAnim.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _taglineAnim.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _featureAnim.forward();

    // Hold so user can read
    await Future.delayed(const Duration(milliseconds: 1200));

    // Phase 2: logo + text leave
    _logoAnim.controller.reverse();
    _taglineAnim.controller.reverse();
    _featureAnim.controller.reverse();
    await Future.delayed(const Duration(milliseconds: 600));

    // Phase 3: emblem + rings come in last
    _emblemAnim.forward();
    _ring1.repeat();
    Future.delayed(const Duration(milliseconds: 400), () => _ring2.repeat());

    await Future.delayed(const Duration(milliseconds: 350));
    _glowAnim.forward();

    // Phase 4: shimmer loading bar
    await Future.delayed(const Duration(milliseconds: 400));
    _shimmerController.repeat(reverse: true);

    // Hold then exit
    await Future.delayed(const Duration(milliseconds: 1400));
    _shimmerController.stop();
    await _exitAnim.forward();

    if (mounted) _navigate();
  }

  void _navigate() {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final hasSeenOnboarding = LocalStorageService.hasSeenOnboarding;

    if (isLoggedIn) {
      context.go('/home');
    } else if (hasSeenOnboarding) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _emblemAnim.dispose();
    _glowAnim.dispose();
    _logoAnim.dispose();
    _taglineAnim.dispose();
    _featureAnim.dispose();
    _exitAnim.dispose();
    _ring1.dispose();
    _ring2.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: AnimatedBuilder(
          animation: _exitAnim.controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _exitAnim.fade,
              child: ScaleTransition(
                scale: _exitAnim.scale,
                child: child,
              ),
            );
          },
          child: Stack(
            children: [
              // ── Ambient background ──
              _SplashBackground(isDark: isDark),

              // ── Floating particles ──
              ..._buildParticles(isDark),

              // ── Center content (Stack so each group is independently centered) ──
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── Logo + text group (shows first, leaves before emblem) ──
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SlideTransition(
                          position: _logoAnim.slide,
                          child: FadeTransition(
                            opacity: _logoAnim.fade,
                            child: Image.asset(
                              SImages.brandLogo,
                              width: 180,
                              color: isDark ? Colors.white : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: SSizes.sm),
                        FadeTransition(
                          opacity: _taglineAnim.fade,
                          child: Text(
                            STexts.appTagline,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? SColors.textDarkSecondary
                                  : SColors.textLightSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Emblem group (shows last, center-center) ──
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ring 1
                          AnimatedBuilder(
                            animation: _ring1.controller,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: _ring1.scale.value,
                                child: Opacity(
                                  opacity: _ring1.opacity.value,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: SColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Ring 2 (offset timing)
                          AnimatedBuilder(
                            animation: _ring2.controller,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: _ring2.scale.value,
                                child: Opacity(
                                  opacity: _ring2.opacity.value,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: SColors.primary,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Glow halo
                          AnimatedBuilder(
                            animation: _glowAnim.value,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: SColors.primary.withValues(
                                        alpha: 0.35 * _glowAnim.value.value,
                                      ),
                                      blurRadius: 100 * _glowAnim.value.value,
                                      spreadRadius: 30 * _glowAnim.value.value,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: AnimatedBuilder(
                              animation: _emblemAnim.controller,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _emblemAnim.rotation.value,
                                  child: Transform.scale(
                                    scale: _emblemAnim.scale.value,
                                    child: FadeTransition(
                                      opacity: _emblemAnim.fade,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: SColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.asset(
                                    SImages.brandEmblem,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom shimmer progress bar ──
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _glowAnim.value,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _shimmerValue,
                      builder: (context, _) {
                        return Container(
                          width: 48,
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                SColors.primary.withValues(alpha: 0.1),
                                SColors.primary.withValues(alpha: 0.6),
                                SColors.primary.withValues(alpha: 0.1),
                              ],
                              stops: [
                                (_shimmerValue.value - 0.3).clamp(0.0, 1.0),
                                _shimmerValue.value,
                                (_shimmerValue.value + 0.3).clamp(0.0, 1.0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  List<Widget> _buildParticles(bool isDark) {
    final rng = Random(42); // fixed seed for deterministic positions
    return List.generate(8, (i) {
      final size = 3.0 + rng.nextDouble() * 4;
      final top = rng.nextDouble();
      final left = rng.nextDouble();
      return Positioned(
        top: top * MediaQuery.of(context).size.height,
        left: left * MediaQuery.of(context).size.width,
        child: FadeTransition(
          opacity: _glowAnim.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SColors.primary.withValues(
                alpha: isDark ? 0.15 + rng.nextDouble() * 0.1 : 0.08 + rng.nextDouble() * 0.06,
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
//  Premium ambient background: multi-point glow
// ─────────────────────────────────────────────
class _SplashBackground extends StatelessWidget {
  final bool isDark;
  const _SplashBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left blue glow
        Positioned(
          top: -120,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  blurRadius: 250,
                  spreadRadius: 80,
                ),
              ],
            ),
          ),
        ),
        // Center-right teal glow
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withValues(alpha: isDark ? 0.08 : 0.04),
                  blurRadius: 180,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        // Bottom-right purple glow
        Positioned(
          bottom: -140,
          right: -120,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.12 : 0.06),
                  blurRadius: 250,
                  spreadRadius: 80,
                ),
              ],
            ),
          ),
        ),
        // Bottom-left subtle warm glow
        Positioned(
          bottom: -60,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SColors.primary.withValues(alpha: isDark ? 0.06 : 0.03),
                  blurRadius: 150,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
