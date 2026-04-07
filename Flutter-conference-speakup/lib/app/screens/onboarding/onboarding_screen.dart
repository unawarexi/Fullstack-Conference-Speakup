import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/animations/screen_animations.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/text_strings.dart';
import 'package:flutter_conference_speakup/core/services/storage_service.dart';

import 'widgets/ambient_background.dart';
import 'widgets/shared_widgets.dart';
import 'widgets/video_call_visual.dart';
import 'widgets/team_chat_visual.dart';
import 'widgets/secure_visual.dart';

// ─────────────────────────────────────────────
//  Data model for each onboarding page
// ─────────────────────────────────────────────
class _OnboardingData {
  final String title;
  final String subtitle;
  final Widget Function(BuildContext context, bool compact) visualBuilder;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.visualBuilder,
  });
}

final List<_OnboardingData> _kPages = [
  _OnboardingData(
    title: 'Crystal-Clear\nVideo Calls',
    subtitle: STexts.onboardingSubtitle1,
    visualBuilder: (ctx, compact) => const VideoCallVisual(compact: true),
  ),
  _OnboardingData(
    title: 'Real-Time\nTeam Chat',
    subtitle: STexts.onboardingSubtitle2,
    visualBuilder: (ctx, compact) => const TeamChatVisual(compact: true),
  ),
  _OnboardingData(
    title: 'End-to-End\nEncrypted',
    subtitle: STexts.onboardingSubtitle3,
    visualBuilder: (ctx, compact) => const SecureVisual(compact: true),
  ),
];

// ─────────────────────────────────────────────
//  Main Onboarding Screen
// ─────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late FadeInAnim _fadeAnim;
  late SlideUpFadeAnim _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeAnim = FadeInAnim(
      vsync: this,
      duration: Duration(milliseconds: SSizes.animSlow),
    );
    _slideAnim = SlideUpFadeAnim(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      beginOffset: const Offset(0, 0.12),
    );

    _fadeAnim.forward();
    _slideAnim.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeAnim.dispose();
    _slideAnim.dispose();
    super.dispose();
  }

  void _animateIn() {
    _fadeAnim.reset();
    _slideAnim.reset();
    _fadeAnim.forward();
    _slideAnim.forward();
  }

  void _nextPage() {
    if (_currentPage < _kPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    LocalStorageService.setOnboardingComplete();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = SResponsive.isDesktop(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            const AmbientBackground(),
            if (isDesktop)
              SafeArea(
                child: _DesktopLayout(
                  currentPage: _currentPage,
                  pageController: _pageController,
                  fadeAnim: _fadeAnim.fade,
                  slideAnim: _slideAnim.slide,
                  onPageChanged: (i) {
                    setState(() => _currentPage = i);
                    _animateIn();
                  },
                  onNext: _nextPage,
                  onSkip: _skip,
                ),
              )
            else
              _MobileLayout(
                currentPage: _currentPage,
                pageController: _pageController,
                fadeAnim: _fadeAnim.fade,
                slideAnim: _slideAnim.slide,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _animateIn();
                },
                onNext: _nextPage,
                onSkip: _skip,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Desktop Layout (side-by-side)
// ─────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final int currentPage;
  final PageController pageController;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _DesktopLayout({
    required this.currentPage,
    required this.pageController,
    required this.fadeAnim,
    required this.slideAnim,
    required this.onPageChanged,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final data = _kPages[currentPage];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // ── LEFT: visual (55%) ──
        Expanded(
          flex: 55,
          child: _VisualCarousel(
            pageController: pageController,
            currentPage: currentPage,
            onPageChanged: onPageChanged,
          ),
        ),

        // ── RIGHT: copy + controls (45%) ──
        Expanded(
          flex: 45,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: SSizes.xl, horizontal: SSizes.lg),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(isDark ? 0.6 : 0.85),
              borderRadius: BorderRadius.circular(SSizes.radiusXl + 8),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const OnboardingEmblem(),
                      if (currentPage < _kPages.length - 1)
                        SkipButton(onTap: onSkip),
                    ],
                  ),
                  const SizedBox(height: SSizes.lg),
                  StepIndicator(current: currentPage, total: _kPages.length),
                  const Spacer(flex: 2),

                  FadeTransition(
                    opacity: fadeAnim,
                    child: SlideTransition(
                      position: slideAnim,
                      child: Text(
                        data.title,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1.1,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: SSizes.pagePadding),

                  FadeTransition(
                    opacity: fadeAnim,
                    child: SlideTransition(
                      position: slideAnim,
                      child: Text(
                        data.subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                          height: 1.65,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  DotRow(current: currentPage, total: _kPages.length),
                  const SizedBox(height: SSizes.xl),

                  CTAButton(
                    label: currentPage < _kPages.length - 1 ? 'Continue' : 'Get Started',
                    onTap: onNext,
                  ),
                  const SizedBox(height: SSizes.md),

                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: STexts.alreadyHaveAccount,
                        style: TextStyle(
                          color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: SColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Mobile Layout (fullscreen visual + overlay card)
// ─────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final int currentPage;
  final PageController pageController;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _MobileLayout({
    required this.currentPage,
    required this.pageController,
    required this.fadeAnim,
    required this.slideAnim,
    required this.onPageChanged,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final data = _kPages[currentPage];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // ── Fullscreen visual carousel (edge-to-edge, behind notch) ──
        Positioned.fill(
          child: _VisualCarousel(
            pageController: pageController,
            currentPage: currentPage,
            onPageChanged: onPageChanged,
            compact: true,
          ),
        ),

        // ── Dark glassmorphism bottom sheet ──
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(isDark ? 0.55 : 0.50),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.12), width: 1),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  SSizes.sectionSpacing,
                  SSizes.lg,
                  SSizes.sectionSpacing,
                  SSizes.lg + bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emblem + Skip row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const OnboardingEmblem(compact: true),
                        if (currentPage < _kPages.length - 1)
                          SkipButton(onTap: onSkip),
                      ],
                    ),
                    const SizedBox(height: SSizes.md),

                    FadeTransition(
                      opacity: fadeAnim,
                      child: SlideTransition(
                        position: slideAnim,
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: SSizes.sm + SSizes.xs),

                    FadeTransition(
                      opacity: fadeAnim,
                      child: SlideTransition(
                        position: slideAnim,
                        child: Text(
                          data.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: SSizes.lg),

                    DotRow(current: currentPage, total: _kPages.length),
                    const SizedBox(height: SSizes.pagePadding),

                    CTAButton(
                      label: currentPage < _kPages.length - 1 ? 'Continue' : 'Get Started',
                      onTap: onNext,
                    ),
              
            
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Visual Carousel (swipeable slide visuals)
// ─────────────────────────────────────────────
class _VisualCarousel extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final bool compact;

  const _VisualCarousel({
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: _kPages.length,
      onPageChanged: onPageChanged,
      itemBuilder: (ctx, i) {
        final child = _kPages[i].visualBuilder(ctx, compact);

        if (compact) {
          // Mobile: full-bleed visuals, edge-to-edge
          return AnimatedOpacity(
            opacity: i == currentPage ? 1.0 : 0.5,
            duration: Duration(milliseconds: SSizes.animSlow),
            child: child,
          );
        }

        // Desktop: centered with scale animation
        return Center(
          child: AnimatedScale(
            scale: i == currentPage ? 1.0 : 0.92,
            duration: Duration(milliseconds: SSizes.animSlow),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: i == currentPage ? 1.0 : 0.5,
              duration: Duration(milliseconds: SSizes.animSlow),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
