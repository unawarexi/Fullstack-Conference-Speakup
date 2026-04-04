import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/animations/screen_animations.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/image_strings.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/text_strings.dart';
import 'package:flutter_conference_speakup/core/services/storage_service.dart';

// ─────────────────────────────────────────────
//  Data model for each onboarding page
// ─────────────────────────────────────────────
class _OnboardingData {
  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final String imagePath;
  final Color accentColor;

  const _OnboardingData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imagePath,
    required this.accentColor,
  });
}

const List<_OnboardingData> _kPages = [
  _OnboardingData(
    tag: '01 — Connect',
    title: 'Crystal-Clear\nVideo Calls',
    subtitle: STexts.onboardingSubtitle1,
    icon: Icons.videocam_rounded,
    imagePath: SImages.onboarding1,
    accentColor: SColors.primary,
  ),
  _OnboardingData(
    tag: '02 — Collaborate',
    title: 'Real-Time\nTeam Chat',
    subtitle: STexts.onboardingSubtitle2,
    icon: Icons.chat_bubble_rounded,
    imagePath: SImages.onboarding2,
    accentColor: Color(0xFF8B5CF6),
  ),
  _OnboardingData(
    tag: '03 — Trust',
    title: 'End-to-End\nEncrypted',
    subtitle: STexts.onboardingSubtitle3,
    icon: Icons.lock_rounded,
    imagePath: SImages.onboarding3,
    accentColor: SColors.success,
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const _AmbientBackground(),
          SafeArea(
            child: SResponsive.isDesktop(context)
                ? _DesktopLayout(
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
                  )
                : _MobileLayout(
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
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Ambient Background (glow blobs + grid)
// ─────────────────────────────────────────────
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridOpacity = isDark ? 0.04 : 0.06;
    final blueGlowOpacity = isDark ? 0.18 : 0.10;
    final purpleGlowOpacity = isDark ? 0.14 : 0.08;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter(opacity: gridOpacity)),
        ),
        Positioned(
          top: -160,
          left: -120,
          child: _GlowBlob(
            size: 500,
            color: SColors.primary.withOpacity(blueGlowOpacity),
          ),
        ),
        Positioned(
          bottom: -180,
          right: -140,
          child: _GlowBlob(
            size: 420,
            color: const Color(0xFF8B5CF6).withOpacity(purpleGlowOpacity),
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: size * 0.6, spreadRadius: size * 0.1)],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double opacity;
  const _GridPainter({this.opacity = 0.04});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SColors.primary.withOpacity(opacity)
      ..strokeWidth = 1;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.opacity != opacity;
}

// ─────────────────────────────────────────────
//  Desktop Layout  (side-by-side)
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
          child: Padding(
            padding: const EdgeInsets.all(SSizes.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Logo(),
                const Spacer(),
                Expanded(
                  flex: 8,
                  child: Center(
                    child: _PhoneMockupCarousel(
                      pageController: pageController,
                      currentPage: currentPage,
                      onPageChanged: onPageChanged,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
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
                      _StepIndicator(current: currentPage, total: _kPages.length),
                      if (currentPage < _kPages.length - 1)
                        _SkipButton(onTap: onSkip),
                    ],
                  ),
                  const Spacer(flex: 2),

                  FadeTransition(
                    opacity: fadeAnim,
                    child: SlideTransition(
                      position: slideAnim,
                      child: _TagChip(label: data.tag, color: data.accentColor),
                    ),
                  ),
                  const SizedBox(height: SSizes.lg),

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

                  _DotRow(current: currentPage, total: _kPages.length),
                  const SizedBox(height: SSizes.xl),

                  _CTAButton(
                    label: currentPage < _kPages.length - 1 ? 'Continue' : 'Get Started',
                    accentColor: data.accentColor,
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
                              color: data.accentColor,
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
//  Mobile Layout  (stacked)
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
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Top bar
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SResponsive.pagePadding(context),
            vertical: SSizes.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _Logo(compact: true),
              if (currentPage < _kPages.length - 1) _SkipButton(onTap: onSkip),
            ],
          ),
        ),

        // Visual area
        SizedBox(
          height: size.height * 0.42,
          child: _PhoneMockupCarousel(
            pageController: pageController,
            currentPage: currentPage,
            onPageChanged: onPageChanged,
            compact: true,
          ),
        ),

        const SizedBox(height: SSizes.sm),

        // Content card
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(isDark ? 0.7 : 0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(color: colorScheme.outline, width: 1),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              SSizes.sectionSpacing,
              SSizes.xl,
              SSizes.sectionSpacing,
              SSizes.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: fadeAnim,
                  child: SlideTransition(
                    position: slideAnim,
                    child: _TagChip(label: data.tag, color: data.accentColor),
                  ),
                ),
                const SizedBox(height: SSizes.md),

                FadeTransition(
                  opacity: fadeAnim,
                  child: SlideTransition(
                    position: slideAnim,
                    child: Text(
                      data.title,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
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
                        color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                _DotRow(current: currentPage, total: _kPages.length),
                const SizedBox(height: SSizes.pagePadding),

                _CTAButton(
                  label: currentPage < _kPages.length - 1 ? 'Continue' : 'Get Started',
                  accentColor: data.accentColor,
                  onTap: onNext,
                ),
                const SizedBox(height: SSizes.sm + SSizes.xs),

                Center(
                  child: Text.rich(
                    TextSpan(
                      text: STexts.alreadyHaveAccount,
                      style: TextStyle(
                        color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: data.accentColor,
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
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Phone Mockup Carousel
// ─────────────────────────────────────────────
class _PhoneMockupCarousel extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final bool compact;

  const _PhoneMockupCarousel({
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
        return Center(
          child: _PhoneMockup(
            data: _kPages[i],
            compact: compact,
            isActive: i == currentPage,
          ),
        );
      },
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  final _OnboardingData data;
  final bool compact;
  final bool isActive;

  const _PhoneMockup({
    required this.data,
    this.compact = false,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final w = compact ? 180.0 : 240.0;
    final h = compact ? 320.0 : 440.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = theme.colorScheme.outline;
    final bgColor = theme.scaffoldBackgroundColor;

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.92,
      duration: Duration(milliseconds: SSizes.animSlow),
      curve: Curves.easeOutCubic,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          color: cardColor,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: data.accentColor.withOpacity(isDark ? 0.25 : 0.15),
              blurRadius: 60,
              spreadRadius: -10,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.12),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ImagePlaceholder(accentColor: data.accentColor),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      bgColor.withOpacity(0.7),
                      bgColor.withOpacity(0.95),
                    ],
                    stops: const [0, 0.4, 0.75, 1],
                  ),
                ),
              ),
            ),

            // ── Notch ──
            Positioned(
              top: 12,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  width: 80,
                  height: 22,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                ),
              ),
            ),

            // ── Bottom overlay ──
            Positioned(
              bottom: 20,
              left: SSizes.md, right: SSizes.md,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [data.accentColor, const Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.tag,
                          style: TextStyle(
                            color: data.accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          data.title.replaceAll('\n', ' '),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Live badge ──
            Positioned(
              top: 50,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(SSizes.radiusFull),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: data.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: data.accentColor, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: data.accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Image Placeholder
// ─────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  final Color accentColor;
  const _ImagePlaceholder({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final elevatedColor = isDark ? SColors.darkElevated : SColors.lightElevated;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                accentColor.withOpacity(isDark ? 0.15 : 0.08),
                elevatedColor,
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(SSizes.radiusLg),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Icon(Icons.image_outlined, color: accentColor.withOpacity(0.5), size: 28),
            ),
            const SizedBox(height: SSizes.sm + SSizes.xs),
            Text(
              'Place your image here',
              style: TextStyle(
                color: accentColor.withOpacity(0.4),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Shared small widgets
// ─────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final bool compact;
  const _Logo({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 28 : 34,
          height: compact ? 28 : 34,
          decoration: BoxDecoration(
            gradient: SColors.accentGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.videocam_rounded,
              color: Colors.white, size: compact ? 16 : 18),
        ),
        const SizedBox(width: 10),
        Text(
          STexts.appName,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: compact ? 16 : 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SSizes.chipPadding, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(SSizes.radiusFull),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DotRow extends StatelessWidget {
  final int current;
  final int total;
  const _DotRow({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final accentColor = _kPages[current].accentColor;
    final inactiveColor = Theme.of(context).colorScheme.outline;

    return Row(
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: SSizes.sm),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? accentColor : inactiveColor,
            borderRadius: BorderRadius.circular(SSizes.radiusXs),
          ),
        );
      }),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final accentColor = _kPages[current].accentColor;
    final inactiveColor = Theme.of(context).colorScheme.outline;

    return Row(
      children: List.generate(total, (i) {
        final isDone = i <= current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          margin: const EdgeInsets.only(right: 6),
          width: isDone ? 24 : 16,
          height: 4,
          decoration: BoxDecoration(
            color: isDone ? accentColor : inactiveColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.sm),
        foregroundColor: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusFull),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: const Text(
        'Skip',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _CTAButton extends StatefulWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _CTAButton({
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _pressCtrl;
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: double.infinity,
          height: SSizes.buttonHeightLg,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.accentColor, widget.accentColor.withBlue(200)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(SSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: SSizes.sm),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: SSizes.iconSm),
            ],
          ),
        ),
      ),
    );
  }
}
