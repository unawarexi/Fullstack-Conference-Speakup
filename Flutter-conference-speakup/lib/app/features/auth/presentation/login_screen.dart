import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/animations/screen_animations.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/image_strings.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/text_strings.dart';
import 'package:flutter_conference_speakup/app/features/auth/usecases/login_usecase.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late LoginUseCase _loginUseCase;
  late SheetRevealAnim _sheetAnim;

  @override
  void initState() {
    super.initState();
    _sheetAnim = SheetRevealAnim(vsync: this);
    _sheetAnim.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginUseCase = LoginUseCase(
      ref: ref,
      context: context,
      onStateChanged: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _sheetAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = SResponsive.isDesktop(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: isDesktop ? _buildDesktop(context) : _buildMobile(context),
      ),
    );
  }

  // ─────────────── MOBILE LAYOUT ───────────────
  Widget _buildMobile(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        // ── Top half: hero image with brand overlay ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.55,
          child: _HeroSection(isDark: isDark),
        ),

        // ── Bottom sheet: auth form (no handle) ──
        Positioned(
          top: size.height * 0.50,
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: _sheetAnim.slide,
            child: FadeTransition(
              opacity: _sheetAnim.fade,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? SColors.darkSurface.withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.97),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : SColors.lightBorder.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        SSizes.pagePadding + 4,
                        SSizes.lg + 8,
                        SSizes.pagePadding + 4,
                        SSizes.xl,
                      ),
                      child: _buildForm(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────── DESKTOP LAYOUT ───────────────
  Widget _buildDesktop(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // ── Left: hero visual (50%) ──
        Expanded(
          child: _HeroSection(isDark: isDark, isDesktop: true),
        ),

        // ── Right: form (50%) ──
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SlideTransition(
                position: _sheetAnim.slide,
                child: FadeTransition(
                  opacity: _sheetAnim.fade,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SSizes.xxl,
                      vertical: SSizes.xl,
                    ),
                    child: _buildForm(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────── AUTH FORM ───────────────
  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;
    final secondaryColor = isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Greeting ──
        Text(
          'Welcome to ${STexts.appName}',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: SSizes.xs),
        Text(
          'Sign in to continue',
          style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
        ),
        const SizedBox(height: SSizes.sectionSpacing),

        // ── Google button ──
        _OAuthButton(
          label: STexts.continueWithGoogle,
          assetIcon: SImages.googleIcon,
          isLoading: _loginUseCase.isGoogleLoading,
          onTap: _loginUseCase.signInWithGoogle,
        ),
        const SizedBox(height: SSizes.sm + 4),
        // ── GitHub button ──
        _OAuthButton(
          label: STexts.continueWithGithub,
          assetIcon: SImages.githubIcon,
          invertIconInDark: true,
          isLoading: _loginUseCase.isGithubLoading,
          onTap: _loginUseCase.signInWithGithub,
        ),

        const SizedBox(height: SSizes.xl),

        // ── Policy text ──
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
            child: Text.rich(
              TextSpan(
                text: 'By continuing, you agree to our ',
                style: TextStyle(color: mutedColor, fontSize: 11, height: 1.5),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.push('/terms'),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.push('/privacy'),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Hero section: full-bleed image + brand overlay
// ─────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final bool isDark;
  final bool isDesktop;

  const _HeroSection({required this.isDark, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Full-bleed conference image ──
        Image.asset(
          SImages.onboarding5,
          fit: BoxFit.cover,
        ),

        // ── Dark gradient overlay for readability ──
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // ── Primary accent glow ──
        Positioned(
          top: -60,
          left: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SColors.primary.withValues(alpha: 0.2),
                  blurRadius: 120,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),

        // ── Brand content centered ──
        Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: isDesktop ? 0 : MediaQuery.of(context).padding.top + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emblem with glow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: SColors.primary.withValues(alpha: 0.35),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      SImages.brandEmblem,
                      width: isDesktop ? 100 : 72,
                      height: isDesktop ? 100 : 72,
                    ),
                  ),
                ),
                SizedBox(height: isDesktop ? SSizes.lg : SSizes.md),
                // Logo text (always white on image)
                Image.asset(
                  SImages.brandLogo,
                  width: isDesktop ? 180 : 140,
                  color: Colors.white,
                ),
                const SizedBox(height: SSizes.sm),
                Text(
                  STexts.appTagline,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w400,
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
//  OAuth button — asset icon + Cupertino press feel
// ─────────────────────────────────────────────
class _OAuthButton extends StatefulWidget {
  final String label;
  final String assetIcon;
  final bool invertIconInDark;
  final bool isLoading;
  final VoidCallback onTap;

  const _OAuthButton({
    required this.label,
    required this.assetIcon,
    this.invertIconInDark = false,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  State<_OAuthButton> createState() => _OAuthButtonState();
}

class _OAuthButtonState extends State<_OAuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          height: SSizes.buttonHeightMd + 4,
          decoration: BoxDecoration(
            color: _pressed
                ? (isDark ? SColors.darkHover : SColors.lightHover)
                : (isDark ? SColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(
              color: isDark
                  ? SColors.darkBorder.withValues(alpha: 0.6)
                  : SColors.lightBorder,
            ),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? CupertinoActivityIndicator(
                    radius: 10,
                    color: isDark ? SColors.textDark : SColors.textLight,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        widget.assetIcon,
                        width: 22,
                        height: 22,
                        color: widget.invertIconInDark && isDark
                            ? Colors.white
                            : null,
                      ),
                      const SizedBox(width: SSizes.sm + 4),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? SColors.textDark : SColors.textLight,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
