import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  late BrandRevealAnim _emblemAnim;
  late SlideUpFadeAnim _logoAnim;
  late GlowPulseAnim _glowAnim;
  late FadeInAnim _taglineAnim;
  late ExitAnim _exitAnim;

  @override
  void initState() {
    super.initState();
    _emblemAnim = BrandRevealAnim(vsync: this);
    _logoAnim = SlideUpFadeAnim(vsync: this);
    _glowAnim = GlowPulseAnim(vsync: this);
    _taglineAnim = FadeInAnim(vsync: this);
    _exitAnim = ExitAnim(vsync: this);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _emblemAnim.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _glowAnim.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _logoAnim.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _taglineAnim.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
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
    _logoAnim.dispose();
    _glowAnim.dispose();
    _taglineAnim.dispose();
    _exitAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
            // ── Ambient glow background ──
            _SplashBackground(isDark: isDark),

            // ── Center content ──
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Glow ring behind emblem ──
                  AnimatedBuilder(
                    animation: _glowAnim.value,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: SColors.primary.withOpacity(
                                0.3 * _glowAnim.value.value,
                              ),
                              blurRadius: 80 * _glowAnim.value.value,
                              spreadRadius: 20 * _glowAnim.value.value,
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
                      child: Image.asset(
                        SImages.brandEmblem,
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),

                  const SizedBox(height: SSizes.xl),

                  // ── Logo text ──
                  SlideTransition(
                    position: _logoAnim.slide,
                    child: FadeTransition(
                      opacity: _logoAnim.fade,
                      child: Image.asset(
                        SImages.brandLogo,
                        width: 200,
                        color: isDark ? Colors.white : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: SSizes.md),

                  // ── Tagline ──
                  FadeTransition(
                    opacity: _taglineAnim.fade,
                    child: Text(
                      STexts.appTagline,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom loading indicator ──
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineAnim.fade,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: SColors.primary.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  final bool isDark;
  const _SplashBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left blue glow
        Positioned(
          top: -100,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SColors.primary.withOpacity(isDark ? 0.12 : 0.06),
                  blurRadius: 200,
                  spreadRadius: 60,
                ),
              ],
            ),
          ),
        ),
        // Bottom-right purple glow
        Positioned(
          bottom: -120,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(isDark ? 0.10 : 0.05),
                  blurRadius: 200,
                  spreadRadius: 60,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
