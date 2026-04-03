import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/image_strings.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';
import 'package:video_confrence_app/core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Emblem (icon) animations ──
  late AnimationController _emblemController;
  late Animation<double> _emblemScale;
  late Animation<double> _emblemFade;
  late Animation<double> _emblemRotation;

  // ── Logo text animations ──
  late AnimationController _logoController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;

  // ── Glow pulse ──
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  // ── Tagline animations ──
  late AnimationController _taglineController;
  late Animation<double> _taglineFade;

  // ── Exit animation ──
  late AnimationController _exitController;
  late Animation<double> _exitFade;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();

    // ── Emblem: scale up + fade in + subtle rotation ──
    _emblemController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _emblemScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _emblemController, curve: Curves.easeOutBack),
    );
    _emblemFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _emblemController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _emblemRotation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(parent: _emblemController, curve: Curves.easeOutCubic),
    );

    // ── Logo text: slide up + fade in ──
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic));

    // ── Glow pulse behind emblem ──
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // ── Tagline ──
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // ── Exit ──
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Phase 1: Emblem scales in
    await Future.delayed(const Duration(milliseconds: 200));
    _emblemController.forward();

    // Phase 2: Glow pulse starts
    await Future.delayed(const Duration(milliseconds: 400));
    _glowController.forward();

    // Phase 3: Logo text slides up
    await Future.delayed(const Duration(milliseconds: 400));
    _logoController.forward();

    // Phase 4: Tagline fades in
    await Future.delayed(const Duration(milliseconds: 500));
    _taglineController.forward();

    // Phase 5: Hold, then exit
    await Future.delayed(const Duration(milliseconds: 1000));
    await _exitController.forward();

    if (mounted) {
      _navigate();
    }
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
    _emblemController.dispose();
    _logoController.dispose();
    _glowController.dispose();
    _taglineController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _exitFade,
            child: ScaleTransition(
              scale: _exitScale,
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
                    animation: _glowAnim,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: SColors.primary.withOpacity(
                                0.3 * _glowAnim.value,
                              ),
                              blurRadius: 80 * _glowAnim.value,
                              spreadRadius: 20 * _glowAnim.value,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _emblemController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _emblemRotation.value,
                          child: Transform.scale(
                            scale: _emblemScale.value,
                            child: FadeTransition(
                              opacity: _emblemFade,
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
                    position: _logoSlide,
                    child: FadeTransition(
                      opacity: _logoFade,
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
                    opacity: _taglineFade,
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
                opacity: _taglineFade,
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
